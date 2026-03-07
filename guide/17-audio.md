# Chapter 17 — Audio

Every system you have built so far works in silence. The battle system resolves turns, the dialogue box types out text, scene transitions fade to black — but none of it makes a sound. This chapter adds background music and sound effects through a centralized AudioManager autoload.

If you have worked with a service layer in Angular — a singleton that manages a shared resource and exposes a clean API to the rest of the application — AudioManager follows the same pattern. It owns all audio playback, handles crossfading between tracks, and provides a pooled SFX system so multiple sounds can overlap without creating and destroying nodes.

## What We Are Building

- **Audio bus layout**: Master > BGM and Master > SFX, configured in the editor
- **AudioManager autoload**: a single script that manages all game audio
- **BGM playback**: one track at a time, with smooth crossfading between tracks
- **BGM push/pop stack**: save the current track before battle, restore it after
- **SFX pool**: eight pre-allocated AudioStreamPlayer nodes with priority levels
- **Volume control**: per-bus volume that persists to disk through SaveManager
- **Per-scene BGM**: each area calls `AudioManager.play_bgm()` in its `_ready()`

## Audio Buses

Godot routes all audio through **buses**. A bus is a processing channel — think of it as a named volume knob that controls a category of sound. Every project starts with a single `Master` bus. We add two child buses: `BGM` for background music and `SFX` for sound effects.

### Setting Up Buses in the Editor

1. Open the **Audio** tab at the bottom of the editor (next to Animation and Shader)
2. Click **Add Bus** twice to create two new buses
3. Rename them `BGM` and `SFX`
4. For each, click the **Send** dropdown and select `Master`

The bus hierarchy is now:

```
Master
├── BGM
└── SFX
```

This structure lets you adjust music and sound effects independently while Master controls overall game volume. When you mute Master, everything goes silent. When you lower BGM, only music gets quieter.

### How Bus Routing Works

Every `AudioStreamPlayer` node has a `bus` property — a string that names which bus it sends audio to. The default is `"Master"`. We will set BGM players to `"BGM"` and SFX players to `"SFX"`.

The `AudioServer` singleton controls buses at runtime. To change a bus's volume:

```gdscript
# AudioServer uses bus indices, not names
var bus_index: int = AudioServer.get_bus_index("BGM")
AudioServer.set_bus_volume_db(bus_index, -10.0)  # reduce by 10 dB
```

Volume is measured in **decibels** (dB). Zero dB is full volume. Negative values reduce volume logarithmically — `-6 dB` is roughly half as loud, `-20 dB` is very quiet, and `-80 dB` is effectively silent. This matches how human hearing works: perceived loudness is logarithmic, not linear.

Godot provides conversion functions between linear (0.0 to 1.0) and decibel scales:

```gdscript
var db: float = linear_to_db(0.5)    # ≈ -6.02 dB
var linear: float = db_to_linear(db)  # 0.5
```

**Engineering parallel:** Audio buses are like middleware in an HTTP pipeline. Each request (audio signal) passes through a chain of processors (buses) before reaching the output. Each processor can modify the signal independently.

## The AudioManager Autoload

Create a new script and register it as an autoload named `AudioManager`.

### Node Structure

AudioManager creates its child nodes in code rather than using a `.tscn` file. This keeps the autoload self-contained — one script, no scene dependency.

```gdscript
# autoloads/audio_manager.gd
extends Node

signal bgm_changed(stream: AudioStream)

const SFX_POOL_SIZE: int = 8
const DEFAULT_FADE_TIME: float = 1.0

var _bgm_player: AudioStreamPlayer
var _bgm_fade_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0
var _bgm_stack: Array[Dictionary] = []
var _bgm_volume_db: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_bgm_players()
	_setup_sfx_pool()


func _setup_bgm_players() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	_bgm_player.bus = "BGM"
	_bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_bgm_player)

	_bgm_fade_player = AudioStreamPlayer.new()
	_bgm_fade_player.name = "BGMFadePlayer"
	_bgm_fade_player.bus = "BGM"
	_bgm_fade_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_bgm_fade_player)


func _setup_sfx_pool() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % i
		player.bus = "SFX"
		add_child(player)
		_sfx_pool.append(player)
```

Key decisions:

- **`process_mode = PROCESS_MODE_ALWAYS`** on both the manager and BGM players. When the scene tree is paused (during the pause menu), music should keep playing. Without this, pausing the game would freeze the audio mid-note.
- **Two BGM players.** One plays the current track. The other handles the outgoing track during a crossfade. You cannot crossfade with a single player — you need two sources that overlap briefly.
- **Eight SFX players.** This pool lets up to eight sounds play simultaneously. A sword slash, a hit reaction, and a UI click can all overlap. Eight is generous for a 2D JRPG — you rarely need more than four or five concurrent effects.

## BGM Playback and Crossfading

The simplest BGM function plays a track immediately if nothing is playing, or crossfades if something already is:

```gdscript
func play_bgm(stream: AudioStream, fade_time: float = DEFAULT_FADE_TIME) -> void:
	if not stream:
		stop_bgm(fade_time)
		return
	# Don't restart the same track
	if _bgm_player.stream == stream and _bgm_player.playing:
		return

	if _bgm_player.playing:
		_crossfade_bgm(stream, fade_time)
	else:
		_bgm_player.stream = stream
		_bgm_player.volume_db = _bgm_volume_db
		_bgm_player.play()

	bgm_changed.emit(stream)


func stop_bgm(fade_time: float = DEFAULT_FADE_TIME) -> void:
	if not _bgm_player.playing:
		return
	var tween := create_tween()
	tween.tween_property(_bgm_player, "volume_db", -80.0, fade_time)
	tween.tween_callback(_bgm_player.stop)
```

The guard `if _bgm_player.stream == stream and _bgm_player.playing` prevents restarting a track that is already playing. Without it, entering a scene that plays the same BGM as the previous scene would restart the music from the beginning — a jarring experience.

### Crossfading

Crossfading means fading out the old track while simultaneously fading in the new one. The two tracks overlap during the transition, creating a smooth handoff:

```gdscript
func _crossfade_bgm(new_stream: AudioStream, fade_time: float) -> void:
	# Move current track to the fade player
	_bgm_fade_player.stream = _bgm_player.stream
	_bgm_fade_player.volume_db = _bgm_player.volume_db
	_bgm_fade_player.play(_bgm_player.get_playback_position())

	# Start the new track on the main player at silence
	_bgm_player.stream = new_stream
	_bgm_player.volume_db = -80.0
	_bgm_player.play()

	# Fade in new, fade out old — simultaneously
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_bgm_player, "volume_db", _bgm_volume_db, fade_time)
	tween.tween_property(_bgm_fade_player, "volume_db", -80.0, fade_time)
	tween.set_parallel(false)
	tween.tween_callback(_bgm_fade_player.stop)
```

The technique:

1. Copy the currently-playing stream and its playback position to `_bgm_fade_player`
2. Start the new stream on `_bgm_player` at `-80 dB` (silent)
3. Use a parallel Tween to fade the new player up and the old player down simultaneously
4. When the fade completes, stop the fade player to free the audio resource

**`set_parallel(true)`** tells the Tween to run subsequent steps at the same time instead of sequentially. We switch it back to `false` before adding the stop callback so the stop waits until both fades finish.

**`get_playback_position()`** returns how many seconds into the track the player currently is. We use this to start the fade player at the exact same position, so the outgoing track continues seamlessly during the crossfade rather than restarting from the beginning.

## BGM Push/Pop Stack

When the player enters a battle, you want to switch to battle music. When the battle ends, you want to return to the overworld track — at the same position where it left off. A stack solves this naturally:

```gdscript
func push_bgm() -> void:
	var entry := {
		"stream": _bgm_player.stream,
		"position": _bgm_player.get_playback_position() if _bgm_player.playing else 0.0,
		"playing": _bgm_player.playing,
	}
	_bgm_stack.append(entry)


func pop_bgm(fade_time: float = DEFAULT_FADE_TIME) -> void:
	if _bgm_stack.is_empty():
		return
	var entry: Dictionary = _bgm_stack.pop_back()
	var stream: AudioStream = entry.get("stream")
	if not stream or not entry.get("playing", false):
		stop_bgm(fade_time)
		return

	var pos: float = entry.get("position", 0.0)
	if _bgm_player.playing:
		# Crossfade back to the stacked track at its saved position
		_bgm_fade_player.stream = _bgm_player.stream
		_bgm_fade_player.volume_db = _bgm_player.volume_db
		_bgm_fade_player.play(_bgm_player.get_playback_position())

		_bgm_player.stream = stream
		_bgm_player.volume_db = -80.0
		_bgm_player.play(pos)

		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(_bgm_player, "volume_db", _bgm_volume_db, fade_time)
		tween.tween_property(_bgm_fade_player, "volume_db", -80.0, fade_time)
		tween.set_parallel(false)
		tween.tween_callback(_bgm_fade_player.stop)
	else:
		_bgm_player.stream = stream
		_bgm_player.volume_db = -80.0
		_bgm_player.play(pos)
		var tween := create_tween()
		tween.tween_property(_bgm_player, "volume_db", _bgm_volume_db, fade_time / 2.0)

	bgm_changed.emit(stream)
```

### Usage in Battle Flow

```gdscript
# In BattleManager, when starting a battle:
func start_battle(enemies: Array[Resource]) -> void:
	AudioManager.push_bgm()
	AudioManager.play_bgm(battle_bgm)
	# ... transition to battle scene

# When battle ends:
func _on_battle_ended(victory: bool) -> void:
	AudioManager.pop_bgm()
	# ... transition back to overworld
```

The stack supports nesting. If a cutscene within a battle plays a fanfare, that is a second push. Each pop restores the previous state. This is the same pattern as a call stack or browser history — last in, first out.

## SFX Playback with Priority

Sound effects use a pool of pre-allocated players with round-robin assignment. When you call `play_sfx()`, it picks the next player in the pool, assigns the sound, and plays it:

```gdscript
enum SfxPriority {
	CRITICAL,
	NORMAL,
	AMBIENT,
}


func play_sfx(
	stream: AudioStream,
	priority: SfxPriority = SfxPriority.NORMAL,
	volume_db: float = 0.0,
) -> void:
	if not stream:
		return
	var idx: int = _get_sfx_player_index(priority)
	if idx == -1:
		return
	var player: AudioStreamPlayer = _sfx_pool[idx]
	player.stream = stream
	player.volume_db = volume_db
	player.play()
	if priority == SfxPriority.NORMAL:
		_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE


func _get_sfx_player_index(priority: SfxPriority) -> int:
	match priority:
		SfxPriority.AMBIENT:
			# Only play if a player is free
			for i in SFX_POOL_SIZE:
				if not _sfx_pool[i].playing:
					return i
			return -1  # All busy — skip this sound
		SfxPriority.CRITICAL:
			# Find a free player, or fall back to round-robin
			for i in SFX_POOL_SIZE:
				if not _sfx_pool[i].playing:
					return i
			return _sfx_index
		_:  # NORMAL
			return _sfx_index
```

The three priority levels solve different needs:

- **NORMAL** — default for most SFX (menu clicks, sword hits). Round-robin means each new sound claims the next slot regardless of whether it is busy. If all eight are playing, the oldest gets interrupted. This is fine — eight simultaneous sounds already exceeds what the player can distinguish.
- **CRITICAL** — for sounds that must always play (level-up fanfare, critical hit). Tries to find a free slot first. If none are free, falls back to round-robin so the sound still plays.
- **AMBIENT** — for background sounds (wind, water). Only plays if a slot is free. If all are busy, the ambient sound is silently dropped. Better to skip an ambient sound than to cut off a gameplay-critical one.

**Engineering parallel:** This is a connection pool. Like a database connection pool that reuses connections instead of creating new ones for each query, the SFX pool reuses AudioStreamPlayer nodes instead of instantiating and freeing them for each sound.

### Making the Priority Logic Testable

The index selection logic is a pure function of pool size, current index, and busy state. Extract it as a static method so you can unit test it without audio hardware:

```gdscript
static func compute_sfx_player_index(
	pool_size: int,
	current_index: int,
	busy_mask: Array[bool],
	priority: SfxPriority,
) -> int:
	match priority:
		SfxPriority.AMBIENT:
			for i in pool_size:
				if not busy_mask[i]:
					return i
			return -1
		SfxPriority.CRITICAL:
			for i in pool_size:
				if not busy_mask[i]:
					return i
			return current_index
		_:
			return current_index
```

Then `_get_sfx_player_index()` calls this with the actual pool state:

```gdscript
func _get_sfx_player_index(priority: SfxPriority) -> int:
	var busy: Array[bool] = []
	for p: AudioStreamPlayer in _sfx_pool:
		busy.append(p.playing)
	return compute_sfx_player_index(SFX_POOL_SIZE, _sfx_index, busy, priority)
```

## Per-Scene BGM

Each area scene sets its own background music in `_ready()`:

```gdscript
# scenes/forest/forest.gd
extends Node2D

const FOREST_BGM: String = "res://assets/music/Wandering Through Quiet Lands.ogg"


func _ready() -> void:
	var bgm := load(FOREST_BGM) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm)
```

Because `play_bgm()` checks whether the requested track is already playing, transitioning between two forest sub-areas that share the same BGM will not restart the music. The track continues seamlessly.

For scenes that should have no music (a tense cutscene, a quiet moment):

```gdscript
func _ready() -> void:
	AudioManager.stop_bgm(2.0)  # slow 2-second fade to silence
```

## Volume Control and Persistence

Players expect to adjust volume in a settings menu and have those settings persist between sessions. This involves two layers:

1. **AudioServer** — the runtime volume control
2. **Disk persistence** — saving settings to a JSON file

### Converting Between UI Sliders and Decibels

A settings slider shows 0 to 100. AudioServer speaks decibels. The conversion:

```gdscript
# settings_data.gd

const SILENT_DB: float = -80.0

static func percent_to_db(percent: int) -> float:
	var clamped := clampi(percent, 0, 100)
	if clamped == 0:
		return SILENT_DB
	return linear_to_db(clamped / 100.0)


static func db_to_percent(db: float) -> int:
	if db <= SILENT_DB:
		return 0
	return clampi(int(round(db_to_linear(db) * 100.0)), 0, 100)
```

The `linear_to_db()` and `db_to_linear()` functions are Godot built-ins. We clamp to `SILENT_DB` (-80 dB) instead of negative infinity because a slider at zero should be silent, not mathematically undefined.

### Applying Volume to a Bus

```gdscript
static func apply_volume(bus_name: String, percent: int) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_warning("Bus '%s' not found" % bus_name)
		return
	AudioServer.set_bus_volume_db(idx, percent_to_db(percent))
```

### Saving and Loading Settings

```gdscript
const SETTINGS_PATH := "user://settings.json"

static func save_settings(master: int, bgm: int, sfx: int) -> void:
	var data := {
		"version": 1,
		"master_volume": clampi(master, 0, 100),
		"bgm_volume": clampi(bgm, 0, 100),
		"sfx_volume": clampi(sfx, 0, 100),
	}
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


static func load_settings() -> Dictionary:
	var defaults := {"master_volume": 100, "bgm_volume": 100, "sfx_volume": 100}
	if not FileAccess.file_exists(SETTINGS_PATH):
		return defaults
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return defaults
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return defaults
	var data: Variant = json.data
	if data is not Dictionary:
		return defaults
	return {
		"master_volume": clampi(int(data.get("master_volume", 100)), 0, 100),
		"bgm_volume": clampi(int(data.get("bgm_volume", 100)), 0, 100),
		"sfx_volume": clampi(int(data.get("sfx_volume", 100)), 0, 100),
	}
```

### Restoring Settings at Startup

In `AudioManager._ready()`, after creating the player nodes, load and apply the saved settings:

```gdscript
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_bgm_players()
	_setup_sfx_pool()
	_apply_saved_settings()


func _apply_saved_settings() -> void:
	var settings := SettingsData.load_settings()
	SettingsData.apply_volume("Master", settings["master_volume"])
	SettingsData.apply_volume("BGM", settings["bgm_volume"])
	SettingsData.apply_volume("SFX", settings["sfx_volume"])
```

This ensures volumes are correct from the very first frame, before any scene has a chance to play audio.

## How It Connects

AudioManager integrates with systems built in previous chapters:

- **GameManager (Ch 5):** Scene transitions trigger area `_ready()`, which calls `play_bgm()`
- **BattleManager (Ch 10):** Battle start calls `push_bgm()` then `play_bgm(battle_music)`. Battle end calls `pop_bgm()` to restore overworld music
- **DialogueBox (Ch 7):** Dialogue choices and advances play UI SFX via `play_sfx()`
- **SaveManager (Ch 15):** Volume settings are persisted independently from game saves — changing the volume does not dirty the save file
- **Pause menu (Ch 18):** `PROCESS_MODE_ALWAYS` ensures music keeps playing while the game is paused. The settings menu reads and writes bus volumes in real time

## Common Mistakes

**Forgetting `PROCESS_MODE_ALWAYS`.** If AudioManager uses the default `PROCESS_MODE_PAUSABLE`, pausing the scene tree (for the pause menu) freezes all audio. Music stops mid-note. Set `process_mode = Node.PROCESS_MODE_ALWAYS` on the manager node and both BGM players.

**Creating and freeing AudioStreamPlayer nodes per sound.** This causes allocation churn and can produce audio glitches if a node is freed while its stream is still decoding. The pool pattern avoids both problems.

**Using `volume_db = 0.0` to mean "silent."** Zero dB is full volume. Silent is approximately `-80 dB`. This is a common trap if you are used to linear 0-to-1 volume scales.

**Not guarding against null streams.** If an audio file fails to load (wrong path, missing import), `AudioStreamPlayer.stream` will be null and calling `play()` will produce an error. Always check `if not stream: return` before playing.

**Restarting BGM on every scene enter.** If two adjacent scenes use the same background track, a naive `play_bgm()` in both `_ready()` functions would restart the music at the transition. The guard check (`if _bgm_player.stream == stream and _bgm_player.playing: return`) prevents this.

## What Is Next

You have sound, but no way for the player to adjust it. In the next chapter, we build the complete UI layer — HUD, pause menu, battle interface, and a settings screen with those volume sliders. AudioManager provides the backend; the UI provides the controls.

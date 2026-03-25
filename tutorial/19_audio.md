# Module 19: Audio — Music and Sound Effects

## What We Have So Far

A complete, saveable JRPG with exploration, combat, quests, and party management. But it's silent. JRPGs are defined by their music as much as their gameplay — time to fix that.

## What We're Building This Module

Background music for each area, battle music with crossfade transitions, sound effects for attacks and menus, and volume controls via audio buses.

## Audio in Godot

Godot provides two audio player nodes:

| Node | Use Case |
|------|----------|
| **AudioStreamPlayer** | Non-positional audio: BGM, UI sounds, fanfares |
| **AudioStreamPlayer2D** | Positional 2D audio: footsteps, environmental sounds |

For a JRPG, most audio is non-positional — music plays at full volume regardless of camera position, menu sounds don't have a source in the world.

> **See:** [AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html) — the non-positional audio player.

## Audio Formats

| Format | Best For | Why |
|--------|----------|-----|
| **OGG Vorbis** (.ogg) | Music | Small files, good quality, supports looping |
| **WAV** (.wav) | Sound effects | No decode latency (plays instantly), larger files |
| **MP3** (.mp3) | Music (alternative) | Widely supported but slightly worse loop support |

Import audio by placing files in your project folder. Godot auto-imports them.

## MusicManager Autoload

We want music to crossfade between tracks (not abruptly cut), survive scene changes, and remember the overworld track during battle.

Create `res://autoloads/music_manager.gd`:

```gdscript
extends Node
## Manages background music with crossfading. Autoload as MusicManager.

@onready var _player_a: AudioStreamPlayer = $PlayerA
@onready var _player_b: AudioStreamPlayer = $PlayerB

var _active_player: AudioStreamPlayer
var _current_track_path: String = ""
var _previous_track_path: String = ""
var _crossfade_duration: float = 1.0


func _ready() -> void:
    _active_player = _player_a
    _player_a.bus = "Music"
    _player_b.bus = "Music"


func play_music(track_path: String, crossfade: bool = true) -> void:
    if track_path == _current_track_path:
        return

    var stream: AudioStream = load(track_path) as AudioStream
    if not stream:
        push_error("MusicManager: failed to load " + track_path)
        return

    _current_track_path = track_path

    if crossfade and _active_player.playing:
        _crossfade_to(stream)
    else:
        _active_player.stream = stream
        _active_player.volume_db = 0.0
        _active_player.play()


func _crossfade_to(new_stream: AudioStream) -> void:
    var old_player := _active_player
    var new_player := _player_b if _active_player == _player_a else _player_a

    new_player.stream = new_stream
    new_player.volume_db = -40.0
    new_player.play()

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(old_player, "volume_db", -40.0, _crossfade_duration)
    tween.tween_property(new_player, "volume_db", 0.0, _crossfade_duration)
    tween.chain().tween_callback(old_player.stop)

    _active_player = new_player


func stop_music(fade_duration: float = 0.5) -> void:
    var tween := create_tween()
    tween.tween_property(_active_player, "volume_db", -40.0, fade_duration)
    tween.tween_callback(_active_player.stop)
    _current_track_path = ""


func remember_track() -> void:
    _previous_track_path = _current_track_path


func resume_previous_track() -> void:
    if _previous_track_path:
        play_music(_previous_track_path)
```

Create the scene `res://autoloads/music_manager.tscn`:

1. Create a new scene with **Node** as root. Rename it to `MusicManager`.
2. Add two **AudioStreamPlayer** children. Name them `PlayerA` and `PlayerB`.
3. Attach `music_manager.gd` to the root node.
4. Save as `res://autoloads/music_manager.tscn`.
5. Register as autoload: **Project → Project Settings → Autoload** → add the `.tscn` file (not the `.gd` file — autoloads that need child nodes use the scene).

```
MusicManager (Node)
├── PlayerA (AudioStreamPlayer)
└── PlayerB (AudioStreamPlayer)
```

### Audio Assets

You'll need audio files to test with. If you don't have music/SFX yet:
- **Free music:** [Kenney](https://kenney.nl/assets?q=audio) has free audio packs, or search [opengameart.org](https://opengameart.org) for "JRPG music."
- **Placeholder:** Any `.ogg` or `.wav` file works. You can create a silent `.ogg` file with Audacity (Generate → Silence → Export as OGG) to test the system without audio.
- Create folders `res://audio/music/` and `res://audio/sfx/` and place your files there.
- **Looping:** Select a music `.ogg` file in the FileSystem dock, go to the **Import** tab, and check **Loop** to make it repeat. Click **Reimport**.

### Using MusicManager in Scenes

Each area scene plays its track in `_ready()`:

```gdscript
# In willowbrook.gd
func _ready() -> void:
    MusicManager.play_music("res://audio/music/town_theme.ogg")
    # ... rest of setup

# In whisperwood.gd
func _ready() -> void:
    MusicManager.play_music("res://audio/music/forest_theme.ogg")

# In crystal_cavern.gd
func _ready() -> void:
    MusicManager.play_music("res://audio/music/dungeon_theme.ogg")
```

### Battle Music

Before transitioning to battle, remember the current track:

```gdscript
# In SceneManager.start_battle():
MusicManager.remember_track()
MusicManager.play_music("res://audio/music/battle_theme.ogg")

# In SceneManager.return_from_battle():
MusicManager.resume_previous_track()
```

## Sound Effects

SFX are simpler — play once, no crossfading. You can either add AudioStreamPlayer nodes to scenes or create a simple SFX utility:

```gdscript
# Simple approach: preload and play in the script that needs it
const SFX_ATTACK := preload("res://audio/sfx/attack_hit.wav")
const SFX_MENU_CURSOR := preload("res://audio/sfx/menu_cursor.wav")

func _play_sfx(stream: AudioStream) -> void:
    var player := AudioStreamPlayer.new()
    player.stream = stream
    player.bus = "SFX"
    add_child(player)
    player.play()
    player.finished.connect(player.queue_free)
```

Common SFX to add:
- **Menu cursor** — when navigating buttons
- **Menu select** — when pressing a button
- **Attack hit** — when damage is dealt
- **Heal** — when HP is restored
- **Level up** — jingle on level up
- **Victory fanfare** — short victory theme
- **Door/chest open** — when interacting with objects

## Audio Buses

Audio buses let you control volume separately for music and SFX.

### Setting Up Buses

1. Open the **Audio** tab at the bottom of the editor.
2. You'll see a `Master` bus. Click **Add Bus** twice.
3. Rename the new buses to `Music` and `SFX`.
4. Both should route to `Master` (the default).

Now you have three buses:
```
Master ← Music (BGM)
       ← SFX (sound effects)
```

### Controlling Volume

Use `AudioServer` to adjust bus volumes:

```gdscript
# Volume is in decibels. 0 = full volume, -80 = effectively silent
AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -10.0)
AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), -5.0)

# Mute a bus
AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), true)
```

> **See:** [Audio buses](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html) — setting up bus layout, routing, and effects.

> **See:** [AudioServer](https://docs.godotengine.org/en/stable/classes/class_audioserver.html) — runtime bus control.

> **See:** [AudioBusLayout](https://docs.godotengine.org/en/stable/classes/class_audiobuslayout.html) — the resource that stores bus configuration.

### Volume Settings UI

A simple settings panel with sliders:

```gdscript
extends PanelContainer

@onready var _music_slider: HSlider = $VBox/MusicSlider
@onready var _sfx_slider: HSlider = $VBox/SFXSlider


func _ready() -> void:
    _music_slider.min_value = 0.0
    _music_slider.max_value = 1.0
    _music_slider.step = 0.05
    _music_slider.value = 0.8
    _music_slider.value_changed.connect(_on_music_volume_changed)

    _sfx_slider.min_value = 0.0
    _sfx_slider.max_value = 1.0
    _sfx_slider.step = 0.05
    _sfx_slider.value = 0.8
    _sfx_slider.value_changed.connect(_on_sfx_volume_changed)


func _on_music_volume_changed(value: float) -> void:
    var db: float = linear_to_db(value)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), db)


func _on_sfx_volume_changed(value: float) -> void:
    var db: float = linear_to_db(value)
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), db)
```

`linear_to_db()` converts a 0-1 slider value to decibels. At 0, it returns -INF (silent). At 1, it returns 0 (full volume).

## Autoload Reference Card (Final)

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 6 | Scene transitions with fade effects |
| InventoryManager | 10 | Item storage, add/remove, signals |
| BattleManager | 11 | Battle state machine, turn queue |
| GameManager | 16 | Game flags, world state tracking |
| QuestManager | 16 | Quest tracking, objective checking |
| PartyManager | 17 | Party roster, recruitment, stats |
| **MusicManager** | **19** | **BGM crossfading, battle music** |

## What We've Learned

- **AudioStreamPlayer** handles non-positional audio (BGM, SFX). **AudioStreamPlayer2D** is for positional audio.
- **OGG** for music, **WAV** for SFX.
- **MusicManager** uses two players for crossfading: one fading out, one fading in.
- **Audio buses** (Master, Music, SFX) enable independent volume control.
- **`linear_to_db()`** converts slider values (0-1) to decibels for AudioServer.
- **Remember/resume** pattern handles battle music transitions gracefully.
- SFX play once and self-destruct via `finished.connect(queue_free)`.

## What You Should See

- Each area plays its own background music
- Music crossfades smoothly when transitioning between areas
- Battle music plays during combat, then the overworld track resumes
- Attack hits, menu navigation, and level-ups have sound effects
- Volume sliders control music and SFX independently

## Next Module

The game sounds alive. In **Module 20: Title Screen and Game Flow**, we'll build the complete game loop — title screen, new game, continue, pause menu, victory ending, and credits.

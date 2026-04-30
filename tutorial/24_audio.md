# Module 24: Audio (Music and Sound Effects)

## What We Have So Far

A complete, saveable JRPG vertical slice with exploration, combat, quests, and party management. But it's silent. JRPGs are defined by their music as much as their gameplay. Time to fix that.

## What We're Building This Module

Background music for each area, battle music with crossfade transitions, sound effects for attacks and menus, and volume controls via audio buses.

## Audio in Godot

Godot provides two audio player nodes:

| Node | Use Case |
|------|----------|
| **AudioStreamPlayer** | Non-positional audio: BGM, UI sounds, fanfares |
| **AudioStreamPlayer2D** | Positional 2D audio: footsteps, environmental sounds |

For a JRPG, most audio is non-positional. Music plays at full volume regardless of camera position, and menu sounds don't have a source in the world.

> **See:** [AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html), the non-positional audio player.

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
var _crossfade_tween: Tween


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
    if _crossfade_tween and _crossfade_tween.is_valid():
        _crossfade_tween.kill()

    var old_player := _active_player
    var new_player := _player_b if _active_player == _player_a else _player_a

    new_player.stream = new_stream
    new_player.volume_db = -40.0
    new_player.play()

    _crossfade_tween = create_tween()
    _crossfade_tween.set_parallel(true)
    _crossfade_tween.tween_property(old_player, "volume_db", -40.0, _crossfade_duration)
    _crossfade_tween.tween_property(new_player, "volume_db", 0.0, _crossfade_duration)
    _crossfade_tween.chain().tween_callback(old_player.stop)

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
5. Register as autoload: **Project → Project Settings → Autoload** → add the `.tscn` file, name it `MusicManager`.

> **Warning:** All previous autoloads used `.gd` files. MusicManager is different because it needs AudioStreamPlayer child nodes. When registering, browse to `music_manager.tscn`, NOT `music_manager.gd`. If you register the `.gd` file, the AudioStreamPlayer nodes won't exist and you'll get null reference errors.

```
MusicManager (Node)
├── PlayerA (AudioStreamPlayer)
└── PlayerB (AudioStreamPlayer)
```

### Audio Assets

You'll need audio files to test with. If you don't have music/SFX yet:
- **Free music:** [Kenney](https://kenney.nl/assets?q=audio) has free audio packs, or search [opengameart.org](https://opengameart.org) for "JRPG music." The [Kenney Music Jingles pack](https://kenney.nl/assets/music-jingles) has short loops that work well for testing.
- **Placeholder (no downloads needed):** If you have Audacity (free at audacityteam.org), create silence files: File > New, then Generate > Silence (30 seconds), then File > Export Audio > OGG format. Save four copies as `town_theme.ogg`, `forest_theme.ogg`, `dungeon_theme.ogg`, and `battle_theme.ogg`. This lets you test crossfading and battle music transitions without real audio.
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

Play any battle in Chrono Trigger with the volume off, then play it again with sound. The difference is dramatic. The sword slash, the critical hit crunch, the heal chime: these audio cues give every action weight and feedback. Sound effects are the fastest way to make a game feel polished, because the player's brain processes audio feedback faster than visual feedback. A silent menu cursor feels broken; add a tiny click and it feels responsive.

SFX are simpler: play once, no crossfading. You can either add AudioStreamPlayer nodes to scenes or create a simple SFX utility:

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

Use this self-destruct pattern only with non-looping SFX. Godot does not emit `finished` when a stream loops forever, so a looping ambient sound should be owned by a scene node or manager instead.

Common SFX to add:
- **Menu cursor:** when navigating buttons
- **Menu select:** when pressing a button
- **Attack hit:** when damage is dealt
- **Heal:** when HP is restored
- **Level up:** jingle on level up
- **Victory fanfare:** short victory theme
- **Door/chest open:** when interacting with objects

## Audio Buses

In Undertale, the music is so integral to the storytelling that many players want it louder than the sound effects, while others find the battle SFX distracting and want to turn them down. Without separate audio buses, the only option is a single master volume slider that controls everything at once. Separate buses for music and SFX are a baseline accessibility feature that players expect.

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

> **See:** [Audio buses](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html), for setting up bus layout, routing, and effects.

> **See:** [AudioServer](https://docs.godotengine.org/en/stable/classes/class_audioserver.html), for runtime bus control.

> **See:** [AudioBusLayout](https://docs.godotengine.org/en/stable/classes/class_audiobuslayout.html), the resource that stores bus configuration.

### Volume Settings UI

No two players listen to games the same way. Some play with headphones at night and need everything quieter; others play through speakers in a noisy room. A game without volume settings forces every player into the developer's preferred mix. It is one of the most common complaints in indie game reviews: "no volume controls."

Create `res://ui/settings/settings_panel.tscn`:

```
SettingsPanel (PanelContainer)
└── VBox (VBoxContainer)
    ├── MusicLabel (Label: "Music Volume")
    ├── MusicSlider (HSlider)
    ├── SFXLabel (Label: "SFX Volume")
    └── SFXSlider (HSlider)
```

Save the script as `res://ui/settings/settings_panel.gd`:

```gdscript
extends PanelContainer
## Persistent volume settings panel. Press Escape to close.

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "audio"
const DEFAULT_MUSIC_VOLUME := 0.8
const DEFAULT_SFX_VOLUME := 0.8

@onready var _music_slider: HSlider = $VBox/MusicSlider
@onready var _sfx_slider: HSlider = $VBox/SFXSlider


func _ready() -> void:
    _music_slider.min_value = 0.0
    _music_slider.max_value = 1.0
    _music_slider.step = 0.05

    _sfx_slider.min_value = 0.0
    _sfx_slider.max_value = 1.0
    _sfx_slider.step = 0.05

    var settings := _load_settings()
    var music_volume: float = float(settings.get("music_volume", DEFAULT_MUSIC_VOLUME))
    var sfx_volume: float = float(settings.get("sfx_volume", DEFAULT_SFX_VOLUME))
    _music_slider.value = music_volume
    _sfx_slider.value = sfx_volume
    _apply_bus_volume("Music", music_volume)
    _apply_bus_volume("SFX", sfx_volume)

    _music_slider.value_changed.connect(_on_music_volume_changed)
    _sfx_slider.value_changed.connect(_on_sfx_volume_changed)


func _on_music_volume_changed(value: float) -> void:
    _apply_bus_volume("Music", value)
    _save_settings()


func _on_sfx_volume_changed(value: float) -> void:
    _apply_bus_volume("SFX", value)
    _save_settings()


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        queue_free()
        get_viewport().set_input_as_handled()


func _apply_bus_volume(bus_name: String, value: float) -> void:
    var bus_index: int = AudioServer.get_bus_index(bus_name)
    if bus_index == -1:
        return
    AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))


func _load_settings() -> Dictionary:
    var config := ConfigFile.new()
    var error := config.load(SETTINGS_PATH)
    if error != OK:
        return {}
    return {
        music_volume = config.get_value(
            SETTINGS_SECTION, "music_volume", DEFAULT_MUSIC_VOLUME,
        ),
        sfx_volume = config.get_value(
            SETTINGS_SECTION, "sfx_volume", DEFAULT_SFX_VOLUME,
        ),
    }


func _save_settings() -> void:
    var config := ConfigFile.new()
    config.set_value(SETTINGS_SECTION, "music_volume", _music_slider.value)
    config.set_value(SETTINGS_SECTION, "sfx_volume", _sfx_slider.value)
    var error := config.save(SETTINGS_PATH)
    if error != OK:
        push_warning("Failed to save audio settings: " + error_string(error))
```

`linear_to_db()` converts a 0-1 slider value to decibels. At 0, it returns -INF (silent). At 1, it returns 0 (full volume).

`ConfigFile` writes the slider values to `user://settings.cfg`, Godot's platform-specific writable user-data directory. The settings live outside save slots, so changing volume from the title screen also affects a loaded game.

> **See:** [ConfigFile](https://docs.godotengine.org/en/stable/classes/class_configfile.html), for simple INI-style user settings.

## Autoload Reference Card (Final)

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| GameManager | 20 | Game flags, world state tracking |
| QuestManager | 20 | Quest tracking, objective checking |
| PartyManager | 21 | Party roster, recruitment, stats |
| SaveManager | 22 | Save/load game state to JSON |
| **MusicManager** | **24** | **BGM crossfading, battle music** |

## Engineering Contract

- **Global state:** MusicManager owns current and previous BGM; SettingsPanel writes audio preferences to `user://settings.cfg`.
- **Public surface:** `play_music()`, `remember_track()`, `resume_previous_track()`, one-shot SFX helpers, and volume sliders.
- **Invariant:** Music and SFX buses exist before runtime volume controls target them.
- **Failure behavior:** Missing audio streams or bus names log/return without crashing gameplay.
- **Copy semantics:** Audio streams are shared assets; AudioStreamPlayer nodes are short-lived runtime playback owners.

## Engine Gotcha

Audio bus volume is decibels, not slider units. Convert 0.0-1.0 UI values with `linear_to_db()` before calling AudioServer.

## What We've Learned

- **AudioStreamPlayer** handles non-positional audio (BGM, SFX). **AudioStreamPlayer2D** is for positional audio.
- **OGG** for music, **WAV** for SFX.
- **MusicManager** uses two players for crossfading: one fading out, one fading in.
- **Audio buses** (Master, Music, SFX) enable independent volume control.
- **`linear_to_db()`** converts slider values (0-1) to decibels for AudioServer.
- **Remember/resume** pattern handles battle music transitions gracefully.
- SFX play once and self-destruct via `finished.connect(queue_free)`.
- **ConfigFile** persists music and SFX volume to `user://settings.cfg` across restarts.

## What You Should See

- Each area plays its own background music
- Music crossfades smoothly when transitioning between areas
- Battle music plays during combat, then the overworld track resumes
- Attack hits, menu navigation, and level-ups have sound effects
- Volume sliders control music and SFX independently
- Volume settings persist after closing and reopening the game

## Next Module

The game sounds alive. In **Module 25: Title Screen and Game Flow**, we'll build the complete game loop: title screen, new game, continue, pause menu, victory ending, and credits.

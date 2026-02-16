---
name: add-audio
description: Add audio to the game — background music, sound effects, or an audio management system. Use when adding music, SFX, or setting up audio buses.
argument-hint: <audio-type> [details...]
disable-model-invocation: true
---

# Add Audio

Set up audio for: **$ARGUMENTS**

## Step 1 — Research

Before adding audio, consult:
- `docs/godot-docs/tutorials/audio/audio_buses.rst` — Audio bus system
- `docs/godot-docs/tutorials/audio/audio_streams.rst` — Stream types (OGG, WAV, MP3)
- `docs/godot-docs/tutorials/audio/sync_with_audio.rst` — Syncing gameplay to audio
- `docs/godot-docs/classes/class_audiostreamplayer.rst` — Non-positional audio
- `docs/godot-docs/classes/class_audiostreamplayer2d.rst` — Positional 2D audio

## Step 2 — Determine Audio Type

| Type | Node | Use Case |
|------|------|----------|
| Background music (BGM) | AudioStreamPlayer | Title screen, overworld, battle, town themes |
| Sound effects (SFX) | AudioStreamPlayer | Menu clicks, level up, item pickup |
| Positional SFX | AudioStreamPlayer2D | Footsteps, NPC voices, environmental sounds |
| Ambient loops | AudioStreamPlayer | Wind, rain, cave dripping |

### Audio Format Recommendations

| Format | Best For | Notes |
|--------|----------|-------|
| OGG Vorbis (`.ogg`) | Music, long loops | Good compression, supports looping |
| WAV (`.wav`) | Short SFX | No compression delay, instant playback |
| MP3 (`.mp3`) | Music (alternative) | Widely available, slightly worse looping |

## Step 3 — Audio Manager (if needed)

If the project doesn't have an audio manager yet, create one:

### Audio Manager Pattern

```gdscript
class_name AudioManager
extends Node
## Global audio manager for BGM and SFX playback.
##
## Register as autoload: AudioManager


signal bgm_changed(track_name: String)


const FADE_DURATION: float = 1.0


@export var master_volume: float = 1.0
@export var bgm_volume: float = 0.8
@export var sfx_volume: float = 1.0


var _current_bgm: String = ""


@onready var _bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var _sfx_player: AudioStreamPlayer = $SFXPlayer


func _ready() -> void:
    _apply_volumes()


## Play background music. Crossfades if music is already playing.
func play_bgm(stream: AudioStream, fade_in: bool = true) -> void:
    if _bgm_player.playing and fade_in:
        var tween := create_tween()
        tween.tween_property(_bgm_player, "volume_db",
                -40.0, FADE_DURATION)
        tween.tween_callback(func() -> void:
            _bgm_player.stream = stream
            _bgm_player.volume_db = linear_to_db(bgm_volume)
            _bgm_player.play()
        )
    else:
        _bgm_player.stream = stream
        _bgm_player.volume_db = linear_to_db(bgm_volume)
        _bgm_player.play()


## Stop background music with optional fade out.
func stop_bgm(fade_out: bool = true) -> void:
    if fade_out and _bgm_player.playing:
        var tween := create_tween()
        tween.tween_property(_bgm_player, "volume_db",
                -40.0, FADE_DURATION)
        tween.tween_callback(_bgm_player.stop)
    else:
        _bgm_player.stop()


## Play a one-shot sound effect.
func play_sfx(stream: AudioStream) -> void:
    _sfx_player.stream = stream
    _sfx_player.volume_db = linear_to_db(sfx_volume)
    _sfx_player.play()


## Set master volume (0.0 to 1.0).
func set_master_volume(volume: float) -> void:
    master_volume = clampf(volume, 0.0, 1.0)
    AudioServer.set_bus_volume_db(
            AudioServer.get_bus_index("Master"),
            linear_to_db(master_volume),
    )


func _apply_volumes() -> void:
    set_master_volume(master_volume)
    _bgm_player.volume_db = linear_to_db(bgm_volume)
    _sfx_player.volume_db = linear_to_db(sfx_volume)
```

### Scene structure for AudioManager

```
AudioManager (Node)
├── BGMPlayer (AudioStreamPlayer) — bus: "Music"
└── SFXPlayer (AudioStreamPlayer) — bus: "SFX"
```

## Step 4 — Audio Bus Setup

Recommend the user set up audio buses in the Godot editor:

```
Master
├── Music    (for BGM)
├── SFX      (for sound effects)
└── Ambient  (for ambient loops)
```

Configure in: **Project > Project Settings > Audio > Buses** or the bottom Audio panel.

## Step 5 — Adding Sound to Scenes

### Playing SFX from any script

```gdscript
# If using AudioManager autoload
const CLICK_SFX: AudioStream = preload("res://assets/audio/sfx/click.wav")
AudioManager.play_sfx(CLICK_SFX)

# If using a local AudioStreamPlayer2D
@onready var _sfx: AudioStreamPlayer2D = $SFXPlayer
_sfx.stream = preload("res://assets/audio/sfx/footstep.wav")
_sfx.play()
```

### Playing BGM on scene load

```gdscript
const TOWN_THEME: AudioStream = preload("res://assets/audio/bgm/town.ogg")

func _ready() -> void:
    AudioManager.play_bgm(TOWN_THEME)
```

## Step 6 — Report

After setup, report:
1. Files created (scripts, scenes)
2. Audio bus configuration needed (editor task)
3. How to play sounds from other scripts
4. Recommended audio file organization:
   ```
   game/assets/audio/
   ├── bgm/        # Background music (.ogg)
   ├── sfx/        # Sound effects (.wav)
   └── ambient/    # Ambient loops (.ogg)
   ```
5. Autoload registration needed (if audio manager created)

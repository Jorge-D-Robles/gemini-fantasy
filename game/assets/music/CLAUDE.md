# game/assets/music/

Background music tracks for all game scenes and events. **OGG files are gitignored** — only `.import` sidecar files are committed. Music files must exist on disk in both the main repo and worktree for Godot to play them.

## Track Index

| File | Suggested Use | Duration | Loop |
|------|--------------|----------|------|
| `Battle Theme Organ.ogg` | Standard random encounters | ~1:30 | Yes |
| `Battle! Intro.ogg` | Battle intro sting / boss phase transition | ~0:30 | No |
| `Castle.ogg` | Overgrown Ruins, dungeon exploration | ~0:45 | Yes |
| `Desert Theme.ogg` | Desert/arid region (future content) | ~3:30 | Yes |
| `Epic Boss Battle 1st section.ogg` | Boss encounters (The Last Gardener, etc.) | ~1:00 | Yes |
| `Main Character.ogg` | Title screen, character theme | ~0:45 | Yes |
| `My Hometown.ogg` | Roothollow (alternate/evening) | ~2:15 | Yes |
| `Peaceful Days.ogg` | Verdant Forest, calm exploration | ~1:20 | Yes |
| `Success!.ogg` | Battle victory fanfare | ~0:20 | No |
| `Town Theme Day.ogg` | Roothollow (daytime, primary) | ~2:30 | Yes |
| `Town Theme Night.ogg` | Roothollow (nighttime/post-crisis) | ~2:40 | Yes |
| `Welcoming Heart Piano.ogg` | Title screen (alternate), emotional cutscenes | ~1:30 | Yes |

## Scene-to-Track Mapping

Use these assignments when wiring `AudioManager.play_bgm()` into scene scripts:

| Scene / Event | Track | Fade Time |
|--------------|-------|-----------|
| Title screen | `Main Character.ogg` or `Welcoming Heart Piano.ogg` | 0.0 (instant) |
| Roothollow (town) | `Town Theme Day.ogg` | 1.0 |
| Verdant Forest | `Peaceful Days.ogg` | 1.5 |
| Overgrown Ruins | `Castle.ogg` | 1.5 |
| Random encounter | `Battle Theme Organ.ogg` | 0.5 |
| Boss battle | `Epic Boss Battle 1st section.ogg` | 0.5 |
| Victory | `Success!.ogg` | 0.0 (instant) |
| Post-victory (return to field) | Restore previous scene BGM | 1.0 |

## AudioManager API

All BGM playback goes through the `AudioManager` autoload (see `game/autoloads/CLAUDE.md`).

### Playing BGM

```gdscript
# Load and play with crossfade
var bgm: AudioStream = load("res://assets/music/Town Theme Day.ogg")
if bgm:
    AudioManager.play_bgm(bgm, 1.0)
else:
    push_warning("BGM not loaded — reopen Godot editor to import")
```

### Stopping BGM

```gdscript
# Fade out over 1 second
AudioManager.stop_bgm(1.0)
```

### Playing Victory Fanfare

```gdscript
# Stop battle music, play fanfare (no crossfade — instant start)
AudioManager.stop_bgm(0.3)
await get_tree().create_timer(0.3).timeout
var fanfare: AudioStream = load("res://assets/music/Success!.ogg")
if fanfare:
    AudioManager.play_bgm(fanfare, 0.0)
```

### Restoring Field Music After Battle

```gdscript
# Store the current BGM path before starting battle
var previous_bgm_path: String = ""

func _on_battle_starting() -> void:
    if AudioManager._bgm_player.stream:
        previous_bgm_path = AudioManager._bgm_player.stream.resource_path

func _on_battle_ended(_victory: bool) -> void:
    if previous_bgm_path != "":
        var stream: AudioStream = load(previous_bgm_path)
        if stream:
            AudioManager.play_bgm(stream, 1.0)
```

## Godot Audio Best Practices

### Audio Bus Routing

The project uses two buses defined in `default_bus_layout.tres`:

```
Master
 +-- BGM   (background music — AudioManager routes here automatically)
 +-- SFX   (sound effects — AudioManager routes here automatically)
```

`AudioManager` sets `bus = "BGM"` on its BGM players and `bus = "SFX"` on its SFX pool at creation time. You do not need to set bus routing manually when using the AudioManager API.

### Volume Control

```gdscript
# Set BGM volume (decibels: 0.0 = full, -80.0 = silent)
AudioManager.set_bgm_volume(-5.0)

# Bus-level volume (affects all players on that bus)
var bus_idx: int = AudioServer.get_bus_index("BGM")
AudioServer.set_bus_volume_db(bus_idx, linear_to_db(0.7))  # 70% volume

# Convert between linear (0.0-1.0) and decibel scales
var db: float = linear_to_db(slider_value)      # for UI sliders
var linear: float = db_to_linear(volume_db)      # for display
```

### Crossfade Behavior

`AudioManager.play_bgm()` automatically crossfades when music is already playing:
- Two internal `AudioStreamPlayer` nodes handle the crossfade
- Old track fades out on `_bgm_fade_player` while new track fades in on `_bgm_player`
- Default fade duration is 1.0 second (configurable via the `fade_time` parameter)
- Calling `play_bgm()` with the same stream that's already playing is a no-op (safe to call repeatedly)

### OGG Import Settings

After adding new `.ogg` files, Godot must import them. Reopen the editor, then configure:

1. Select the `.ogg` file in the FileSystem dock
2. Open the **Import** tab (top of Inspector panel)
3. Set **Loop** to `true` for BGM tracks, `false` for one-shot stings (victory, intro)
4. Click **Reimport**

If you skip this step, `load()` returns `null` and music will not play.

### Loading Patterns

**Always null-check loaded audio streams.** A missing `.import` file causes `load()` to return `null` silently.

```gdscript
# Correct — null-safe loading
var stream: AudioStream = load("res://assets/music/Peaceful Days.ogg") as AudioStream
if stream == null:
    push_error("Failed to load BGM — reopen Godot editor to import")
    return
AudioManager.play_bgm(stream)
```

**Use `load()` (not `preload()`)** for music tracks. BGM files are large (0.5-5 MB) and loading them at parse time via `preload()` wastes memory. Load on demand when entering a scene.

**Use constants for paths** to avoid typos and enable easy remapping:

```gdscript
const BGM_TOWN: String = "res://assets/music/Town Theme Day.ogg"
const BGM_FOREST: String = "res://assets/music/Peaceful Days.ogg"
const BGM_BATTLE: String = "res://assets/music/Battle Theme Organ.ogg"

func _ready() -> void:
    var stream: AudioStream = load(BGM_TOWN) as AudioStream
    if stream:
        AudioManager.play_bgm(stream)
```

### Scene Integration Pattern

The recommended pattern for wiring BGM into overworld scenes:

```gdscript
# In a scene script (e.g., roothollow.gd)
const SCENE_BGM_PATH: String = "res://assets/music/Town Theme Day.ogg"

func _ready() -> void:
    # ... other setup ...
    _start_scene_music()

func _start_scene_music() -> void:
    var bgm: AudioStream = load(SCENE_BGM_PATH) as AudioStream
    if bgm:
        AudioManager.play_bgm(bgm, 1.5)
```

For battle scenes, stop field music before starting battle BGM, then restore after:

```gdscript
# In battle_scene.gd or the encounter handler
func _start_battle_music() -> void:
    var battle_bgm: AudioStream = load("res://assets/music/Battle Theme Organ.ogg")
    if battle_bgm:
        AudioManager.play_bgm(battle_bgm, 0.5)

func _play_victory_fanfare() -> void:
    var fanfare: AudioStream = load("res://assets/music/Success!.ogg")
    if fanfare:
        AudioManager.play_bgm(fanfare, 0.0)
```

## File Format Requirements

- **Format:** OGG Vorbis (`.ogg`) — best compression/quality ratio for Godot
- **Sample rate:** 44100 Hz (standard)
- **Channels:** Stereo preferred, mono acceptable
- **Naming:** Use descriptive names with spaces (Godot handles them fine in `res://` paths)

## Adding New Tracks

1. Place the `.ogg` file in `/Users/robles/repos/games/gemini-fantasy/game/assets/music/`
2. Copy to worktree if applicable: `/Users/robles/repos/games/gemini-fantasy/.worktrees/<branch>/game/assets/music/`
3. Reopen the Godot editor to trigger `.import` generation
4. Configure loop settings in the Import tab (see above)
5. Update this file's Track Index table
6. Add the track path to the relevant scene script
7. Test with `/scene-preview` or in-game playback

## Dependencies

- `AudioManager` autoload (`game/autoloads/audio_manager.gd`) — all playback goes through this
- `default_bus_layout.tres` — defines BGM and SFX buses
- `GameManager` — scene transitions may trigger BGM changes
- `BattleManager` — battle start/end events trigger music swaps
- `docs/game-design/06-audio-design.md` — full audio design spec with character themes, adaptive music plans

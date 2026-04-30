# Module 27: Part VI Review and Cheat Sheet

This module is a reference companion for Part VI (Modules 24-26) and a capstone for the entire tutorial series. Use it as a quick-lookup sheet when you need to remember how something works, or read it straight through as a review of everything we built.

## Part VI in Review

Part VI was about finishing the tutorial JRPG vertical slice. We weren't adding core mechanics; we were taking twenty-plus modules of existing work and making the result feel playable from title screen to credits.

Module 24 tackled audio, the change that probably does the most for how the game feels. A silent game feels like a tech demo. Add music and sound effects and it starts feeling like a real game. We built a MusicManager autoload with crossfading, set up audio buses for independent volume control, added SFX that play and self-destruct, and persisted volume sliders to `user://settings.cfg`. Module 25 closed the game flow. We built the title screen, the pause menu, the game over screen, the victory ending, and the credits. Every path through the game now leads to a clear next step, either back to the title screen or into the load flow. There are no dead ends.

Module 26 was the finish line: a full playtesting walkthrough, a troubleshooting guide for the bugs you will encounter, performance advice, export instructions, and a roadmap for where to take Crystal Saga next. That's the finish line.

### Module 24: Audio (Music and Sound Effects)
- Built a **MusicManager autoload** with two AudioStreamPlayers for seamless crossfading between tracks
- Learned the difference between **AudioStreamPlayer** (non-positional: BGM, UI sounds) and **AudioStreamPlayer2D** (positional: footsteps, environmental audio)
- Set up **audio buses** (Master, Music, SFX) for independent volume control, used `linear_to_db()` to convert slider values to decibels, and saved slider values with `ConfigFile`
- Implemented the **remember/resume pattern** for battle music: save the overworld track before combat, restore it after
- Created self-destructing SFX players using `finished.connect(queue_free)` for one-shot sounds

### Module 25: Title Screen and Game Flow
- Built a **title screen** with New Game (fresh state initialization), Continue (save slot loading), and Settings (volume controls)
- Created a **pause menu** as an autoload using `process_mode = ALWAYS` and `get_tree().paused`, while delegating inventory, equipment, and quest log opening to the public APIs from Modules 12, 21, and 20
- Implemented **Game Over** and **Victory Ending** screens that replaced placeholder defeat/victory behavior from earlier modules
- Built **scrolling credits** using a Tween on the label's Y position
- Completed the **game flow**: victory returns through credits to the title screen, while defeat routes through Game Over with a load-or-title choice

### Module 26: Finish Line (Polish, Export, and Next Steps)
- Walked through a **full playtesting checklist** covering every system from title screen to credits
- Catalogued **common bugs** (player walking through walls, null references during scene changes, dialogue not advancing) with concrete fixes
- Covered **performance basics**: removing unused `_process()` methods, caching with `@onready`, object pooling
- Learned to **export the game** as a standalone executable using export templates and presets
- Mapped out **extension points** for the future: status effects, elemental weaknesses, limit breaks, procedural dungeons, mobile export

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|----------------|------------|
| AudioStreamPlayer | Node that plays audio without spatial positioning | All BGM, UI sounds, and fanfares use this | Module 24 |
| AudioStreamPlayer2D | Node that plays audio with 2D positional falloff | Environmental sounds that get louder/quieter based on distance | Module 24 |
| Audio Bus | A mixing channel that groups audio streams for shared volume/effects | Lets players control music and SFX volumes independently | Module 24 |
| Crossfading | Blending one audio track out while another blends in | Prevents jarring cuts when the player moves between areas | Module 24 |
| `linear_to_db()` | Built-in function converting a 0.0-1.0 range to decibels | Sliders use linear values but AudioServer expects decibels | Module 24 |
| `process_mode` | Per-node setting controlling whether a node runs while the tree is paused | The pause menu must process input even when everything else is frozen | Module 25 |
| `get_tree().paused` | Global pause toggle for the scene tree | Stops all gameplay when the pause menu opens | Module 25 |
| ConfigFile | Simple section/key file saved under `user://settings.cfg` | Lets volume settings persist outside individual save slots | Module 24 |
| Game Loop | The complete flow from launch to credits and back | Every game needs a way in, a way through, and a way back to the start | Module 25 |
| Export Templates | Platform-specific build templates Godot uses to create executables | Required to build a standalone application from your project | Module 26 |
| Export Preset | Configuration specifying platform, output path, and build options | Each target platform (Windows, macOS, Linux) gets its own preset | Module 26 |

## Cheat Sheet

### Audio System Setup

Use **AudioStreamPlayer** for anything the player hears at full volume regardless of position (BGM, menu sounds, victory fanfares). Use **AudioStreamPlayer2D** for sounds that exist in the game world (a river, a blacksmith's hammer, footsteps on gravel).

```gdscript
# Non-positional: background music, UI bleeps
var bgm_player := AudioStreamPlayer.new()
bgm_player.bus = "Music"
add_child(bgm_player)

# Positional: a waterfall that gets louder as you approach
var waterfall := AudioStreamPlayer2D.new()
waterfall.bus = "SFX"
waterfall.max_distance = 300.0  # audible within 300 pixels
waterfall.stream = preload("res://audio/sfx/waterfall_loop.ogg")
add_child(waterfall)
```

**Format choices:** OGG Vorbis for music (small files, loop support), WAV for sound effects (no decode latency, plays instantly).

> **See:** [AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html) | [AudioStreamPlayer2D](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer2d.html)

### Background Music (BGM)

The MusicManager autoload uses two AudioStreamPlayers (A and B) to crossfade between tracks. When a new track starts, one player fades out while the other fades in.

```gdscript
# In MusicManager autoload (music_manager.gd):
var _crossfade_tween: Tween


func play_music(track_path: String, crossfade: bool = true) -> void:
    if track_path == _current_track_path:
        return  # Already playing this track

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
```

Each area scene calls `MusicManager.play_music()` in its `_ready()`:

```gdscript
func _ready() -> void:
    MusicManager.play_music("res://audio/music/town_theme.ogg")
```

Battle music uses the remember/resume pattern:

```gdscript
# Before entering battle:
MusicManager.remember_track()
MusicManager.play_music("res://audio/music/battle_theme.ogg")

# After leaving battle:
MusicManager.resume_previous_track()
```

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html) | [AudioStream](https://docs.godotengine.org/en/stable/classes/class_audiostream.html)

### Sound Effects (SFX)

SFX are fire-and-forget. Create a player, play the sound, free the node when it finishes.

```gdscript
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

**Common SFX to add:** menu cursor, menu select, attack hit, heal, level-up jingle, victory fanfare, door/chest open.

> **See:** [AudioStreamPlayer.finished](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html#signals)

### Audio Bus Layout

Set up three buses in the Audio tab at the bottom of the editor:

```
Master
├── Music   (BGM players route here)
└── SFX     (sound effect players route here)
```

Both Music and SFX route to Master. The Master bus controls overall volume. Each sub-bus controls its category independently.

Runtime control uses the [AudioServer](https://docs.godotengine.org/en/stable/classes/class_audioserver.html) singleton:

```gdscript
# Set volume (0 dB = full, -80 dB = effectively silent)
var bus_index: int = AudioServer.get_bus_index("Music")
AudioServer.set_bus_volume_db(bus_index, -10.0)

# Mute a bus entirely
AudioServer.set_bus_mute(bus_index, true)
```

> **See:** [Audio buses](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html) | [AudioBusLayout](https://docs.godotengine.org/en/stable/classes/class_audiobuslayout.html)

### Volume Settings UI

An [HSlider](https://docs.godotengine.org/en/stable/classes/class_hslider.html) from 0.0 to 1.0 converted to decibels via `linear_to_db()`, with the chosen values persisted through [ConfigFile](https://docs.godotengine.org/en/stable/classes/class_configfile.html):

```gdscript
extends PanelContainer

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

At slider value 0, `linear_to_db()` returns `-INF` (silence). At 1, it returns `0` (full volume). The curve is logarithmic, matching human perception. `user://settings.cfg` is separate from `user://saves/`, so audio preferences persist across restarts and across save slots.

> **See:** [@GlobalScope.linear_to_db()](https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#class-globalscope-method-linear-to-db)

### Title Screen Architecture

```
TitleScreen (Control, full_rect)
├── Background (TextureRect or ColorRect)
├── Logo (Label: "Crystal Saga")
├── MenuContainer (VBoxContainer, centered)
│   ├── NewGameButton (Button: "New Game")
│   ├── ContinueButton (Button: "Continue")
│   └── SettingsButton (Button: "Settings")
└── VersionLabel (Label: "v1.0")
```

```gdscript
extends Control

@onready var _new_game_btn: Button = $MenuContainer/NewGameButton
@onready var _continue_btn: Button = $MenuContainer/ContinueButton
@onready var _settings_btn: Button = $MenuContainer/SettingsButton


func _ready() -> void:
    MusicManager.play_music("res://audio/music/title_theme.ogg")

    _new_game_btn.pressed.connect(_on_new_game)
    _continue_btn.pressed.connect(_on_continue)
    _settings_btn.pressed.connect(_on_settings)

    # Disable Continue if no saves exist
    _continue_btn.disabled = not _any_saves_exist()
    _new_game_btn.grab_focus()


func _on_new_game() -> void:
    _initialize_fresh_state()
    SceneManager.change_scene("res://scenes/willowbrook/willowbrook.tscn")


func _on_continue() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.load_game(slot)


func _initialize_fresh_state() -> void:
    GameManager.from_save_data({})
    InventoryManager.from_save_data({gold = 100, items = []})
    var potion: ItemData = load("res://data/items/potion.tres")
    if potion:
        InventoryManager.add_item(potion, 3)

    PartyManager.from_save_data({members = []})
    var aiden := ResourceLoader.load(
        "res://data/characters/aiden.tres", "", ResourceLoader.CACHE_MODE_IGNORE,
    ) as CharacterData
    if aiden:
        aiden.current_hp = aiden.max_hp
        aiden.current_mp = aiden.max_mp
        aiden.current_xp = 0
        PartyManager.add_member(aiden)

    QuestManager.from_save_data({active = [], completed = [], turned_in = []})


func _any_saves_exist() -> bool:
    for i in range(1, SaveManager.MAX_SLOTS + 1):
        if SaveManager.slot_exists(i):
            return true
    return false
```

Set the title screen as the project's **Main Scene** in Project -> Project Settings -> General -> Application -> Run -> Main Scene.

> **See:** [Button](https://docs.godotengine.org/en/stable/classes/class_button.html) | [Control](https://docs.godotengine.org/en/stable/classes/class_control.html) | [VBoxContainer](https://docs.godotengine.org/en/stable/classes/class_vboxcontainer.html)

### Game Flow State Machine

The complete game loop:

```
┌──────────────────────────────────────────────┐
│                TITLE SCREEN                   │
│  New Game -> Initialize fresh state           │
│  Continue -> Load save slot                   │
│  Settings -> Volume controls                  │
└──────────────┬───────────────────┬────────────┘
               |                   |
        [Fresh Start]        [Load Save]
               |                   |
          Willowbrook  <- Restored Scene
               |
          Whisperwood (explore, pendant quest)
               |
         Crystal Cavern (dungeon, random battles, boss)
               |
          [Boss Fight]
               |
       ┌───────┴────────┐
    Victory           Defeat
       |                 |
    Ending           Game Over
       |                 |
    Credits      Load Save or Title Screen
       |
  Title Screen

At any time during gameplay:
  Escape -> Pause Menu
    -> Resume / Inventory / Equipment / Quest Log / Settings / Quit to Title
  Save Crystal -> Save Game
```

There are no dead ends in the flow. Victory returns to the title screen after credits, and defeat gives the player a clear load-or-title decision.

### Pause Menu

The pause menu is an **autoload scene** (`.tscn`, not `.gd`) because it needs child nodes. It lives on a [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html) at layer 50 so it renders above everything.

```gdscript
extends CanvasLayer
## The in-game pause menu. Autoload as PauseMenu.

var _is_open: bool = false

@onready var _background: ColorRect = $Background
@onready var _resume_btn: Button = $Background/Panel/VBox/ResumeButton
@onready var _quit_btn: Button = $Background/Panel/VBox/QuitButton


func _ready() -> void:
    _background.visible = false
    process_mode = Node.PROCESS_MODE_ALWAYS

    _resume_btn.pressed.connect(close)
    _quit_btn.pressed.connect(_quit_to_title)
    $Background/Panel/VBox/InventoryButton.pressed.connect(_open_inventory)
    $Background/Panel/VBox/EquipmentButton.pressed.connect(_open_equipment)
    $Background/Panel/VBox/QuestLogButton.pressed.connect(_open_quest_log)
    $Background/Panel/VBox/SettingsButton.pressed.connect(_open_settings)


func _unhandled_input(event: InputEvent) -> void:
    if not event.is_action_pressed("ui_cancel"):
        return
    if not _can_pause_current_scene() and not _is_open:
        return

    if _is_open:
        close()
    else:
        open()
    get_viewport().set_input_as_handled()


func open() -> void:
    if not _can_pause_current_scene():
        return
    _is_open = true
    _background.visible = true
    get_tree().paused = true
    _resume_btn.grab_focus()


func close() -> void:
    _is_open = false
    _background.visible = false
    get_tree().paused = false


func _can_pause_current_scene() -> bool:
    var current_scene := get_tree().current_scene
    return current_scene and current_scene.is_in_group("pause_allowed")


func _hide_for_submenu() -> void:
    _is_open = false
    _background.visible = false


func _open_inventory() -> void:
    var inv := get_tree().get_first_node_in_group("inventory_screens")
    if inv and inv.has_method("open_from_pause"):
        _hide_for_submenu()
        inv.call("open_from_pause")


func _open_equipment() -> void:
    var equipment := get_tree().get_first_node_in_group("equipment_panels")
    if equipment and equipment.has_method("open_from_pause"):
        _hide_for_submenu()
        equipment.call("open_from_pause")


func _open_quest_log() -> void:
    var log_panel := get_tree().get_first_node_in_group("quest_logs")
    if log_panel and log_panel.has_method("open_from_pause"):
        _hide_for_submenu()
        log_panel.call("open_from_pause")


func _open_settings() -> void:
    var panel: PanelContainer = preload("res://ui/settings/settings_panel.tscn").instantiate()
    add_child(panel)


func _quit_to_title() -> void:
    close()
    SceneManager.change_scene("res://ui/title_screen/title_screen.tscn")
```

The two critical pieces: `process_mode = Node.PROCESS_MODE_ALWAYS` ensures the pause menu still receives input when the tree is paused. `get_tree().paused = true` freezes every other node in the game. The `_can_pause_current_scene()` guard uses the `pause_allowed` group so Escape opens the menu only in overworld/dungeon gameplay scenes, not in battle, title, ending, game over, or credits.

> **See:** [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html) | [SceneTree.paused](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-property-paused) | [Node.process_mode](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-property-process-mode)

### Scene Transitions with Fades

The SceneManager (built in Module 7) uses an [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html) with a [ColorRect](https://docs.godotengine.org/en/stable/classes/class_colorrect.html) to fade to black between scenes. For simpler cases or one-off transitions, a Tween works just as well:

```gdscript
# Tween-based fade-to-black (alternative to AnimationPlayer approach)
func _fade_and_change(scene_path: String) -> void:
    var overlay := ColorRect.new()
    overlay.color = Color.BLACK
    overlay.modulate.a = 0.0
    overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(overlay)

    var tween := create_tween()
    tween.tween_property(overlay, "modulate:a", 1.0, 0.5)
    await tween.finished

    get_tree().change_scene_to_file(scene_path)
```

The SceneManager autoload is the preferred approach because it persists across scene changes, handles spawn points, and emits `transition_started` / `transition_finished` signals that other systems can listen for.

> **See:** [SceneTree.change_scene_to_file()](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-change-scene-to-file) | [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html) | [ColorRect](https://docs.godotengine.org/en/stable/classes/class_colorrect.html)

### Export and Distribution

1. **Install export templates:** Editor -> Manage Export Templates -> Download and Install.
2. **Create a preset:** Project -> Export -> Add... -> choose your platform (Windows, macOS, Linux).
3. **Build:** Click "Export Project", choose an output location. Godot creates a standalone executable and a `.pck` file containing all game data.

The `.pck` file holds every resource in your project (scenes, scripts, art, audio). The executable is a thin wrapper that loads and runs the `.pck`. Together, they are your distributable game.

> **See:** [Exporting projects](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html)

### Polish Checklist

A reference list of polish items to consider before shipping. None of these are required for the tutorial vertical slice, but each one makes the experience noticeably better:

- **Screen shake** on big hits (offset the camera briefly using a Tween)
- **Damage numbers** that float up and fade out
- **Button hover/focus sounds** on every menu (play SFX_MENU_CURSOR on focus_entered)
- **Hit flash** on sprites when taking damage (modulate white briefly)
- **Fade-in on scene load** (not just fade-out on exit)
- **Victory fanfare** that plays before the results screen
- **Save confirmation** ("Game saved!" label that fades out after 2 seconds)
- **Accessibility:** keyboard/gamepad navigation for all menus, readable font sizes, colorblind-friendly palette
- **Input prompts** that match the connected device (keyboard icons vs. gamepad icons)
- **Loading indicator** if any scene takes more than a fraction of a second to load

## The Complete Architecture

After 26 modules, Crystal Saga is made up of eight autoloads, five major systems, three game areas, and dozens of scripts that wire them together. Here is how everything fits.

### Autoloads (Global Singletons)

These eight nodes live at the root of the scene tree for the entire lifetime of the game. They never get freed, they survive scene changes, and any script can access them by name.

| Autoload | Type | Module | Responsibility |
|----------|------|--------|----------------|
| **SceneManager** | `.tscn` | 7 | Fade transitions between scenes, spawn point management |
| **InventoryManager** | `.gd` | 12 | Item storage, gold, add/remove/use items, `inventory_changed` signal |
| **GameManager** | `.gd` | 20 | Boolean flags tracking quest progress and persistent world-object state |
| **QuestManager** | `.gd` | 20 | Quest lifecycle (start, advance, complete, turn in), objective checking |
| **PartyManager** | `.gd` | 21 | Party roster, member recruitment, stat access, equipment slots |
| **SaveManager** | `.gd` | 22 | Serialize all autoload state to JSON in `user://`, load it back, slot management |
| **MusicManager** | `.tscn` | 24 | BGM playback, crossfading, battle music remember/resume |
| **PauseMenu** | `.tscn` | 25 | Global pause overlay, inventory/quest/settings access during gameplay |

### Custom Resources (Data Layer)

Every piece of game content is a [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html) subclass defined in GDScript and instantiated as `.tres` files. This is the data-driven architecture at the heart of Crystal Saga.

| Resource Class | Module | What It Describes |
|---------------|--------|-------------------|
| `ItemData` | 9 | Name, description, type (consumable/equipment), stat effects |
| `CharacterData` | 9 | HP, MP, ATK, DEF, growth, level, XP, equipment slots |
| `NPCData` | 9 | Name, dialogue lines, portrait, interaction behavior |
| `EnemyData` | 17 | Stats, battle sprite, loot table, XP reward, AI behavior type |
| `QuestData` | 20 | Title, description, objectives, rewards |
| `EncounterData` | 17 | Enemy group composition, encounter weight |

`AbilityData` is intentionally not in this implemented-resource table. Module 15 leaves Magic visible but disabled so a future ability system can add spell data, MP costs, elements, and target rules without distracting from the core attack/defend/item battle loop.

### The Battle System

The battle system is the most architecturally complex part of the game. It uses a **node-based state machine** where each state is a child node of the BattleManager.

```
Battle (Node2D, script: battle_manager.gd)
├── BattleUI (CanvasLayer)
│   ├── BattleMenu
│   └── TargetSelect
└── StateMachine (BattleStateMachine)
    ├── Intro
    ├── TurnStart
    ├── PlayerChoice
    ├── ActionExecute
    ├── CheckResult
    ├── Victory
    └── Defeat
```

State transitions go through `BattleManager.transition_to_state(state_name, context)`, which keeps the private `BattleStateMachine` node owned by the battle root. Each state has `enter()`, `process()`, and `exit()` methods. The BattleManager also manages the **turn queue**, ordering combatants by speed.

### Scene Structure

Each game area follows the same layered pattern from Module 5: separate TileMapLayer nodes for ground/detail/above-player art, entity nodes for the player and NPCs, and zone triggers for exits and encounters.

```
AreaRoot (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── YSortGroup (Node2D)
│   ├── Objects (TileMapLayer)
│   ├── Player (CharacterBody2D)
│   └── NPCs / chests / save crystals
├── AbovePlayer (TileMapLayer)
├── EncounterZones (Node2D)
├── Transitions (Node2D)
└── SpawnPoints (Node2D)
```

### UI Layer

UI screens are Control nodes that overlay the game world. Some are scene-local children that stay available in gameplay scenes (dialogue box, inventory, quest log), others are instantiated on demand (shop, settings, game over, ending), and PauseMenu is a persistent autoload scene.

| Screen | Module | Trigger |
|--------|--------|---------|
| DialogueBox | 11 | NPC interaction |
| InventoryScreen | 12 | Pause menu or dedicated button |
| BattleUI | 14-15 | Entering a battle |
| EquipmentPanel | 21 | Pause menu |
| ShopUI | 21 | Talking to a shopkeeper, buy/sell modal |
| QuestLog | 20 | Pause menu |
| SettingsPanel | 24 | Title screen or pause menu |
| TitleScreen | 25 | Game launch, quit-to-title |
| PauseMenu | 25 | Escape key during gameplay |
| GameOver | 25 | Party wipe |
| Ending / Credits | 25 | Defeating the final boss |

### How Systems Connect

The real complexity of a JRPG is not any single system but the connections between them. Here is how the major systems talk to each other:

```
Player interacts with NPC
  -> DialogueBox displays text (Module 11)
  -> Dialogue checks GameManager flags to pick the right lines (Module 20)
  -> Dialogue may start a quest via QuestManager (Module 20)
  -> Dialogue may recruit a party member via PartyManager (Module 21)
  -> Dialogue may open the ShopUI directly (Module 21)
  -> ShopUI.shop_closed unfreezes the player interaction state

Player enters a Crystal Cavern encounter zone
  -> EncounterSystem rolls for a random battle (Module 17)
  -> MusicManager.remember_track() saves current BGM (Module 24)
  -> SceneManager transitions to battle scene (Module 7)
  -> BattleManager runs the fight (Modules 14-18)
  -> Victory: XP -> active party CharacterData, gold/loot -> InventoryManager (Module 18)
  -> MusicManager.resume_previous_track() (Module 24)
  -> SceneManager returns to overworld (Module 7)

Player uses save crystal
  -> SaveManager gathers state from all autoloads (Module 22)
  -> GameManager.to_save_data(), InventoryManager.to_save_data(),
     PartyManager.to_save_data(), QuestManager.to_save_data()
  -> Writes JSON to user://saves/ (Module 22)

Player changes audio settings
  -> SettingsPanel updates AudioServer buses (Module 24)
  -> ConfigFile saves music_volume and sfx_volume to user://settings.cfg

Player defeats final boss
  -> VictoryState detects enemy_data.id == "crystal_guardian"
  -> Missing enemy IDs push a warning before detection
  -> VictoryState syncs HP/MP, sets boss_defeated and world boss flags (Module 25)
  -> SceneManager loads Ending scene (Module 25)
  -> Ending auto-advances to Credits (Module 25)
  -> Credits return to TitleScreen (Module 25)
```

### The Patterns That Scale

Three patterns recur throughout the entire architecture. If you internalize these, you can extend Crystal Saga (or build a new game) by applying them to new content:

1. **Autoload for global state.** Any system that needs to survive scene changes and be accessible from anywhere becomes an autoload. The save system serializes all autoloads to capture the complete game state.

2. **Resource for data.** Any piece of content that can be described as a bundle of properties (an item, a character, an enemy, a quest) becomes a custom Resource class with `.tres` instances. This separates data from behavior and makes content easy to author.

3. **State machine for complex flow.** Any system with distinct modes (player movement: idle/walk/interact; battle: intro/turn/player/action/result/victory/defeat; quest: inactive/active/complete/turned-in) becomes a state machine. Enum-based for simple cases, node-based for complex ones.

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Registering MusicManager or PauseMenu as `.gd` instead of `.tscn` | Null reference errors on `$PlayerA`, `$Background` | Register the `.tscn` file in Project Settings -> Autoload, not the `.gd` file |
| Not setting `process_mode = ALWAYS` on the pause menu | Pause menu does not respond to input when the game is paused | Set `process_mode = Node.PROCESS_MODE_ALWAYS` in `_ready()` |
| Calling `get_tree().paused = true` without unpausing on resume | Game stays frozen after closing the pause menu | Ensure `close()` sets `get_tree().paused = false` |
| Gating PauseMenu by scene path | Pause opens during battle or other `res://scenes/` screens | Add only gameplay roots to `pause_allowed` and check that group |
| Leaving EquipmentPanel out of PauseMenu | Gear exists but the player cannot equip it from gameplay | Add EquipmentButton and open the `equipment_panels` group through `open_from_pause()` |
| Using cached `load()` for a mutable character Resource | New Game carries stats from previous play session | Load a fresh runtime copy with `ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)` before modifying it |
| Slider value passed directly to `set_bus_volume_db()` | Volume curve feels wrong (too quiet in the middle) | Convert with `linear_to_db(value)` first; it handles the logarithmic curve |
| Music plays over itself when re-entering the same area | Two copies of the same track stacked | Check `track_path == _current_track_path` and return early if already playing |
| Forgetting to check `is_instance_valid()` during scene transitions | Crash: "Attempting to call on freed instance" | Guard node access with `if is_instance_valid(node):` in callbacks that may fire during or after a transition |
| SFX player never freed after playing | Orphaned AudioStreamPlayer nodes accumulate in the scene tree | Connect `player.finished` to `player.queue_free` so one-shot sounds clean up after themselves |
| Save slot Cancel emits no selected slot | Continue, Retry, or save crystal waits forever | Emit `slot_selected(0)` on cancel and have every caller `return` when `slot == 0` |
| Listing Magic as implemented before an ability system exists | Review docs reference nonexistent `AbilityData` snippets | Keep Magic disabled and list `AbilityData` only as a future extension until the resource and execution path exist |

## Official Godot Documentation

### Audio

- [AudioStreamPlayer](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html): non-positional audio playback
- [AudioStreamPlayer2D](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer2d.html): positional 2D audio playback
- [AudioStream](https://docs.godotengine.org/en/stable/classes/class_audiostream.html): base class for audio data
- [AudioStreamOggVorbis](https://docs.godotengine.org/en/stable/classes/class_audiostreamoggvorbis.html): OGG Vorbis audio stream
- [AudioStreamWAV](https://docs.godotengine.org/en/stable/classes/class_audiostreamwav.html): WAV audio stream
- [AudioServer](https://docs.godotengine.org/en/stable/classes/class_audioserver.html): runtime bus control
- [AudioBusLayout](https://docs.godotengine.org/en/stable/classes/class_audiobuslayout.html): bus configuration resource
- [Audio buses (tutorial)](https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html): setting up bus layout and routing

### UI and Controls

- [Control](https://docs.godotengine.org/en/stable/classes/class_control.html): base class for UI nodes
- [Button](https://docs.godotengine.org/en/stable/classes/class_button.html): clickable/focusable button
- [HSlider](https://docs.godotengine.org/en/stable/classes/class_hslider.html): horizontal slider widget
- [Label](https://docs.godotengine.org/en/stable/classes/class_label.html): text display
- [RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html): BBCode-enabled text display
- [VBoxContainer](https://docs.godotengine.org/en/stable/classes/class_vboxcontainer.html): vertical layout container
- [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html): panel background for UI
- [ColorRect](https://docs.godotengine.org/en/stable/classes/class_colorrect.html): solid color rectangle
- [TextureRect](https://docs.godotengine.org/en/stable/classes/class_texturerect.html): texture display
- [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html): rendering layer for UI overlays

### Scene Management and Flow

- [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html): the scene tree, pausing, scene changes
- [SceneTree.change_scene_to_file()](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-change-scene-to-file): switching scenes
- [Node.process_mode](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-property-process-mode): per-node pause behavior
- [Pausing games (tutorial)](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html): how pausing works

### Animation and Tweening

- [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html): procedural animation
- [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html): keyframe animation playback

### Utility

- [@GlobalScope.linear_to_db()](https://docs.godotengine.org/en/stable/classes/class_@globalscope.html#class-globalscope-method-linear-to-db): linear to decibel conversion
- [ConfigFile](https://docs.godotengine.org/en/stable/classes/class_configfile.html): INI-style settings storage under `user://`
- [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html): base class for data objects
- [ResourceLoader](https://docs.godotengine.org/en/stable/classes/class_resourceloader.html): advanced runtime resource loading, including cache modes
- [FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html): file I/O for save/load

### Export and Performance

- [Exporting projects (tutorial)](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html): building standalone executables
- [Performance (tutorial)](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html): optimization best practices

## Where to Go from Here

You have built a complete tutorial JRPG vertical slice: a working game with a title screen, three areas, NPCs, a battle system, quests, saves, audio, and credits. The architecture is modular: autoloads for global state, Resources for data, state machines for complex flow, signals for decoupled communication. These patterns apply outside Crystal Saga and outside Godot. State machines show up in networking code. The Resource pattern is data-driven design. Signals are the Observer pattern. What you learned here is game architecture, not just one engine's API.

The best next step is to keep working on this project. Pick one of the extension ideas from Module 26 (status effects, elemental damage, limit breaks, more party members, procedural dungeons) and build it. You already have the save/load serialization pattern, the Resource data layer, and the state machine framework. A status effect system is a new Resource class, a new array on CharacterData, and a new step in the battle turn loop. Elemental damage belongs in a future `AbilityData` resource plus enemy weakness/resistance data, then flows through the existing damage formula. Each one teaches you something new while reinforcing what you already know.

## Tutorial Lint Checklist

Before publishing another pass over the series, run:

```bash
python3 tutorial/tools/check_tutorial.py
```

Then do the semantic checks the script cannot prove:

- Review modules mirror exact implementation names, state names, public APIs, layered scene structure, and save schema.
- Every resource in a final architecture table was actually implemented, or is explicitly marked future scope.
- Every persistent ID introduced in a module is saved later or labeled future save tracking.
- Every awaitable dialog has a cancellation path that resumes callers.
- Every save field written by `to_save_data()` is restored by `from_save_data()`.

When you're ready for a new project, try a different genre. A platformer teaches physics and level design, a roguelike teaches procedural generation, a visual novel teaches branching narrative. The fundamentals (scenes, signals, state machines, data-driven design) carry over from everything you built here. When you get stuck: the [official Godot documentation](https://docs.godotengine.org/en/stable/), the [Godot community forums](https://forum.godotengine.org/), [GDQuest](https://www.gdquest.com/) for structured courses, and the [Godot Discord](https://discord.gg/godotengine) for real-time help. The community is active and helpful. Use it.

Good luck with whatever you build next.

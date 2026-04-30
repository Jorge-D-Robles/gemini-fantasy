# Merged Tutorial Part VI: Finishing the Game

This generated file combines the tutorial Markdown files for this tutorial part.

## Included Files

- `24_audio.md`
- `25_title_screen_and_game_flow.md`
- `26_finish_line.md`
- `27_part_vi_review.md`

---

<!-- Source: 24_audio.md -->

# Module 24: Audio (Music and Sound Effects)

## What We Have So Far

A complete, saveable JRPG with exploration, combat, quests, and party management. But it's silent. JRPGs are defined by their music as much as their gameplay. Time to fix that.

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


---

<!-- Source: 25_title_screen_and_game_flow.md -->

# Module 25: Title Screen and Game Flow

## What We Have So Far

Every system is built: exploration, combat, quests, party, inventory, save/load, audio. But the game starts by dropping the player directly into Willowbrook. There's no title screen, no pause menu, no credits. Time to complete the game loop.

## What We're Building This Module

The title screen (New Game / Continue / Settings), a pause menu, the complete game flow from launch to credits, and the victory ending.

## The Title Screen

The title screen is the first thing every player sees. Final Fantasy VII's iconic opening (Cloud standing before the Shinra reactor, the logo fading in, the music swelling) set the tone for the entire 40-hour experience before the player pressed a single button. A title screen establishes mood, gives the player clear entry points, and signals "this is a finished product, not a tech demo."

Create `res://ui/title_screen/title_screen.tscn`:

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

Script `res://ui/title_screen/title_screen.gd`:

```gdscript
extends Control
## The game's title screen.

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
    # Show save slot dialog from Module 22
    var dialog_scene := preload("res://ui/save_slot_dialog/save_slot_dialog.tscn")
    var dialog: Control = dialog_scene.instantiate()
    add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.load_game(slot)


func _on_settings() -> void:
    # Show the persistent volume settings panel from Module 24
    var settings_scene := preload("res://ui/settings/settings_panel.tscn")
    var panel: PanelContainer = settings_scene.instantiate()
    add_child(panel)
    # Center it on screen
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.grab_focus()


func _initialize_fresh_state() -> void:
    # Reset all autoloads to starting state
    GameManager.from_save_data({})

    # Reset inventory
    InventoryManager.from_save_data({gold = 100, items = []})
    var potion: ItemData = load("res://data/items/potion.tres")
    if potion:
        InventoryManager.add_item(potion, 3)

    # Reset party to just the hero
    PartyManager.from_save_data({members = []})
    var aiden := ResourceLoader.load(
        "res://data/characters/aiden.tres", "", ResourceLoader.CACHE_MODE_IGNORE,
    ) as CharacterData
    if aiden:
        aiden.current_hp = aiden.max_hp
        aiden.current_mp = aiden.max_mp
        aiden.current_xp = 0
        PartyManager.add_member(aiden)

    # Reset quests
    QuestManager.from_save_data({active = [], completed = [], turned_in = []})


func _any_saves_exist() -> bool:
    for i in range(1, SaveManager.MAX_SLOTS + 1):
        if SaveManager.slot_exists(i):
            return true
    return false
```

Notice the New Game path uses the same cache-bypass pattern from Module 22. We load a fresh `CharacterData` definition from disk, then initialize its runtime fields. That gives us a truly pristine new run even if the player leveled up, changed gear, returned to the title screen, and started over without restarting the executable.

Set `res://ui/title_screen/title_screen.tscn` as the project's **Main Scene**: go to **Project → Project Settings → General → Application → Run → Main Scene** and select the title screen `.tscn` file.

## The Pause Menu

In every Zelda game since the original, pressing Start opens an equipment and item screen. The pause menu is not just a way to stop the action. It is the player's home base, the place they go to check inventory, review quests, change equipment, or adjust settings. Without it, the player has no way to manage their party between battles.

The pause menu is accessible from anywhere during gameplay.

Before building the pause menu, set up the groups it needs to find UI nodes across scenes. In **each area scene** (Willowbrook, Whisperwood, Crystal Cavern):

1. Make sure the scene already contains an **InventoryScreen** instance from Module 12 and a **QuestLog** instance from Module 20 as direct children of the scene root.
2. Select the **InventoryScreen** instance node → open the **Node** dock (next to Inspector) → **Groups** tab → type `inventory_screens` → click **Add**
3. Select the **QuestLog** instance node → same process → add to group `quest_logs`

The pause menu uses `get_first_node_in_group()` to find these nodes regardless of which scene is loaded.

Create `res://ui/pause_menu/pause_menu.tscn` and **register it as an autoload** named `PauseMenu` (Project -> Project Settings -> Autoload tab -> browse to `pause_menu.tscn`, name it `PauseMenu`). Since the pause menu needs child nodes (ColorRect, buttons), we register the `.tscn` file, not the `.gd` file, just like the MusicManager in Module 24.

Scene tree:

```
PauseMenu (CanvasLayer, layer = 50, process_mode = ALWAYS)
└── Background (ColorRect, semi-transparent black)
    └── Panel (PanelContainer, centered)
        └── VBox (VBoxContainer)
            ├── ResumeButton (Button)
            ├── InventoryButton (Button)
            ├── QuestLogButton (Button)
            ├── SettingsButton (Button)
            └── QuitButton (Button)
```

```gdscript
extends CanvasLayer
## The in-game pause menu.

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
    if not current_scene:
        return false
    return current_scene.scene_file_path.begins_with("res://scenes/")


func _hide_for_submenu() -> void:
    _is_open = false
    _background.visible = false


func _open_inventory() -> void:
    # Use Module 12's public API instead of toggling visibility directly.
    var inv := get_tree().get_first_node_in_group("inventory_screens")
    if inv and inv.has_method("open_from_pause"):
        _hide_for_submenu()
        inv.call("open_from_pause")


func _open_quest_log() -> void:
    # Use Module 20's public API instead of toggling visibility directly.
    var log_panel := get_tree().get_first_node_in_group("quest_logs")
    if log_panel and log_panel.has_method("open_from_pause"):
        _hide_for_submenu()
        log_panel.call("open_from_pause")


func _open_settings() -> void:
    # Show the settings panel from Module 24
    var settings_scene := preload("res://ui/settings/settings_panel.tscn")
    var panel: PanelContainer = settings_scene.instantiate()
    add_child(panel)


func _quit_to_title() -> void:
    close()
    SceneManager.change_scene("res://ui/title_screen/title_screen.tscn")
```

> **See:** [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html). Covers `process_mode` and `get_tree().paused`.

> **Note:** The pause menu's `process_mode = ALWAYS` ensures it receives input even when the tree is paused. The SceneManager also needs `ALWAYS` to handle transitions during pause.

## The Game Over Screen

Dragon Quest popularized the gentle game over: instead of erasing your progress, the king revives you at the last church but takes half your gold. The Game Over screen is a critical piece of player experience design; it determines whether failure feels punishing or fair. Offering "Load Last Save" versus "Return to Title" gives the player agency after defeat.

Module 18's defeat state sends the player back to Willowbrook as a placeholder. Now we'll build a proper Game Over screen with options.

Create `res://ui/game_over/game_over.tscn`:

```
GameOver (Control, Layout: Full Rect)
└── VBox (VBoxContainer, centered)
    ├── GameOverLabel (Label: "Game Over", font_size: 32)
    ├── Spacer (Control, custom_minimum_size: y=20)
    ├── RetryButton (Button: "Load Last Save")
    ├── TitleButton (Button: "Return to Title")
```

```gdscript
extends Control
## The Game Over screen. Shown when the party is wiped.

@onready var _retry_btn: Button = $VBox/RetryButton
@onready var _title_btn: Button = $VBox/TitleButton


func _ready() -> void:
    _retry_btn.pressed.connect(_on_retry)
    _title_btn.pressed.connect(_on_title)

    # Disable retry if no save exists
    var has_save: bool = false
    for i in range(1, SaveManager.MAX_SLOTS + 1):
        if SaveManager.slot_exists(i):
            has_save = true
            break
    _retry_btn.disabled = not has_save
    if has_save:
        _retry_btn.grab_focus()
    else:
        _title_btn.grab_focus()


func _on_retry() -> void:
    # Show save slot dialog so the player picks which save to load
    var dialog_scene := preload("res://ui/save_slot_dialog/save_slot_dialog.tscn")
    var dialog: Control = dialog_scene.instantiate()
    add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.load_game(slot)


func _on_title() -> void:
    SceneManager.change_scene("res://ui/title_screen/title_screen.tscn")
```

Now update the defeat state in `res://systems/battle/states/defeat_state.gd` to use this screen (replacing the Module 18 placeholder):

```gdscript
extends BattleState
## Party wiped. Show Game Over screen.


func enter(_context: Dictionary = {}) -> void:
    print("DEFEAT")
    print("The party has fallen...")
    battle_manager.battle_lost.emit()

    await get_tree().create_timer(2.0).timeout

    # Show the Game Over screen instead of reloading Willowbrook
    SceneManager.change_scene("res://ui/game_over/game_over.tscn")
```

## The Ending

The ending of a JRPG is the payoff for everything the player invested. Chrono Trigger has thirteen different endings, and players chase them because each one provides narrative closure for the characters they spent hours with. Even a short ending scene transforms "you beat the boss" into "you finished the story."

When the Crystal Guardian is defeated, trigger the ending. Open `res://systems/battle/states/victory_state.gd` and add this check at the beginning of the `enter()` method, before the reward calculation:

```gdscript
# Add at the top of victory_state.gd enter() method:
# Check if this was the final boss fight
var is_boss_fight: bool = false
for enemy in battle_manager.enemies:
    if enemy.enemy_data and enemy.enemy_data.id == "crystal_guardian":
        is_boss_fight = true
        break

if is_boss_fight:
    GameManager.set_flag("boss_defeated")
    await get_tree().create_timer(2.0).timeout
    SceneManager.change_scene("res://ui/ending/ending.tscn")
    return  # Skip normal victory flow
```

Create a simple ending scene `res://ui/ending/ending.tscn`:

```
Ending (Control, Layout: Full Rect)
└── StoryText (RichTextLabel, Layout: Full Rect, BBCode Enabled)
```

```gdscript
extends Control
## The victory ending scene.

var _can_skip: bool = false


func _ready() -> void:
    MusicManager.play_music("res://audio/music/ending_theme.ogg")

    var label := $StoryText as RichTextLabel
    label.text = "[center]The Crystal Guardian falls, and the cavern fills with light.\n\n"
    label.text += "The ancient crystals hum with renewed energy.\n\n"
    label.text += "Aiden and Lira emerge from the cavern,\n"
    label.text += "the fragments of memory swirling around them.\n\n"
    label.text += "The world is safe... for now.\n\n"
    label.text += "[b]Thank you for playing Crystal Saga.[/b][/center]"

    # Allow skipping after a brief delay
    await get_tree().create_timer(2.0).timeout
    _can_skip = true
    await get_tree().create_timer(6.0).timeout
    _go_to_credits()


func _unhandled_input(event: InputEvent) -> void:
    if _can_skip and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")):
        _go_to_credits()


func _go_to_credits() -> void:
    SceneManager.change_scene("res://ui/credits/credits.tscn")
```

## Credits

Credits serve two purposes: they honor the people who made the game, and they give the player a moment to decompress after the climax. The scrolling credits in Final Fantasy VI, set to the character themes medley, are remembered as one of the greatest moments in gaming, not because of gameplay, but because of the emotional space they create. Even for a solo project, credits signal "this is a complete work."

Create `res://ui/credits/credits.tscn`:

```
Credits (Control, Layout: Full Rect)
└── CreditsLabel (Label, Horizontal Alignment: Center)
```

```gdscript
extends Control
## Scrolling credits.

@onready var _credits_label: Label = $CreditsLabel


func _ready() -> void:
    _credits_label.text = "CRYSTAL SAGA\n\n"
    _credits_label.text += "Created with Godot Engine\n\n"
    _credits_label.text += "Game Design & Programming\nYour Name\n\n"
    _credits_label.text += "Art Assets\n[Your source]\n\n"
    _credits_label.text += "Music\n[Your source]\n\n"
    _credits_label.text += "Built following the JRPG in Godot tutorial\n\n"
    _credits_label.text += "Thank you for playing!"

    _credits_label.position.y = get_viewport_rect().size.y

    # Wait one frame so the label's size is calculated after setting text
    await get_tree().process_frame

    var tween := create_tween()
    tween.tween_property(
        _credits_label, "position:y",
        -_credits_label.size.y,
        15.0,  # 15 seconds to scroll
    )
    tween.finished.connect(_return_to_title)


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
        _return_to_title()


func _return_to_title() -> void:
    SceneManager.change_scene("res://ui/title_screen/title_screen.tscn")
```

## The Complete Game Loop

```
┌──────────────────────────────────────────────┐
│                TITLE SCREEN                   │
│  New Game → Initialize fresh state            │
│  Continue → Load save slot                    │
│  Settings → Volume controls                  │
└──────────────┬───────────────────┬────────────┘
               ↓                   ↓
        [Fresh Start]        [Load Save]
               ↓                   ↓
          Willowbrook  ←──── Restored Scene
               ↓
          Whisperwood (explore, pendant quest)
               ↓
         Crystal Cavern (dungeon, random battles, boss)
               ↓
       ┌── BOSS FIGHT ──┐
       ↓                 ↓
    Victory           Defeat
       ↓                 ↓
    Ending           Game Over
       ↓                 ↓
    Credits      Load Save or Title Screen
       ↓
  Title Screen

At any time during gameplay:
  Escape → Pause Menu
    → Resume / Inventory / Quest Log / Settings / Quit to Title
  Save Crystal → Save Game
```

There are no dead ends now. Victory rolls through ending and credits back to the title screen, while defeat routes through a Game Over screen that lets the player load a save or return to the title.

## Autoload Reference Card (Final)

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| GameManager | 20 | Game flags, world state tracking |
| QuestManager | 20 | Quest tracking, objective checking |
| PartyManager | 21 | Party roster, recruitment, stats |
| SaveManager | 22 | Save/load game state to JSON |
| MusicManager | 24 | BGM crossfading, battle music |
| **PauseMenu** | **25** | **Global pause menu (UI autoload)** |

## Engineering Contract

- **Global state:** PauseMenu is a persistent autoload scene; Title/GameOver/Ending are scene flow endpoints.
- **Public surface:** New Game initialization, Continue/Retry save slot loading, pause open/close, settings access, ending/credits navigation.
- **Invariant:** Every blocking dialog has a cancellation path, and every game-over/victory route leads to load or title.
- **Failure behavior:** Slot `0` means cancel and returns without loading; no caller waits forever.
- **Copy semantics:** New Game loads fresh mutable character data with `ResourceLoader.CACHE_MODE_IGNORE`.

## Engine Gotcha

Paused games still need UI input. Set the pause menu's `process_mode` to `Node.PROCESS_MODE_ALWAYS` before relying on Escape or button callbacks while the tree is paused.

## What We've Learned

- The **title screen** initializes fresh state from pristine character definitions for New Game or opens the save slot dialog for Continue.
- The **pause menu** uses `process_mode = ALWAYS`, gates itself to gameplay scenes, and opens Inventory/Quest Log through the public APIs from Modules 12 and 20.
- **Quit to title** changes scene back to the title screen; the next New Game or Continue choice decides what state to load.
- The **ending** triggers after the boss is defeated, leading to credits then title.
- **Credits** scroll with a simple Tween on the label's Y position.
- The complete **game flow** ensures victory, defeat, and quit all lead to a clear next step instead of a dead end.

## What You Should See

- Game launches to the title screen
- "New Game" starts fresh in Willowbrook with 3 Potions and 100 gold
- "Continue" opens the save slot dialog and loads the selected save
- Escape opens the pause menu during gameplay scenes, but not on the title screen or ending screens
- Defeating the Crystal Guardian shows the ending and credits
- Losing a battle opens the Game Over screen with Load Last Save and Return to Title
- Credits and Quit to Title both bring you back to the title screen

## Next Module

The game is complete. In **Module 26: Finish Line**, we'll walk through a full playtest, cover common bugs and fixes, discuss performance, export the game as a standalone build, and explore where to take Crystal Saga from here.


---

<!-- Source: 26_finish_line.md -->

# Module 26: Finish Line (Polish, Export, and Next Steps)

## What We Have

A complete tutorial JRPG vertical slice. Let that sink in. Across the series, you've built:

- A tile-based overworld with three connected areas
- An animated player character with a state machine
- Scene transitions with fade effects
- NPCs with dialogue, a typewriter text effect, and branching choices
- A data-driven architecture using custom Resources
- An inventory system with consumable items
- A turn-based battle system with a node-based state machine
- Player actions: attack, defend, item use, and a disabled Magic slot reserved for a future ability system
- Enemy AI with three behavior types
- Random encounters with weighted probability
- A dungeon with treasure chests, a save crystal, and a boss fight
- XP, leveling, stat growth, and loot drops
- A quest system with game flags and reactive dialogue
- Party management with a recruitable companion
- Equipment that modifies combat stats
- Shops and an inn
- Save and load with JSON serialization
- Background music with crossfading
- Sound effects via audio buses
- A title screen, pause menu, ending, and credits
- A complete game loop

That's a real tutorial game: a playable JRPG vertical slice with every major system in place. It is not a content-complete commercial RPG yet, but the architecture can support more content and polish.

## Playtesting Walkthrough

Play through Crystal Saga from start to finish and verify each checkpoint:

### 1. Title Screen
- [ ] Title screen appears on launch
- [ ] "New Game" starts with correct initial state (3 Potions, 100 gold, Aiden only)
- [ ] "Continue" is disabled when no saves exist

### 2. Willowbrook
- [ ] Player spawns in town center
- [ ] Town music plays
- [ ] Walking into NPCs shows interaction prompt
- [ ] Shopkeeper opens the shop (buy Potions, equipment)
- [ ] Innkeeper offers rest for 10 gold
- [ ] Fynn mentions his lost pendant (starts quest)
- [ ] Lira can be recruited after two conversations

### 3. Whisperwood
- [ ] Music crossfades when entering the forest
- [ ] Scene transitions to and from Willowbrook still work
- [ ] The forest reads clearly as an exploration connector, not a battle arena
- [ ] The pendant can be found (requires a pickup object in Whisperwood; see Module 16's treasure chest pattern)

### 4. Crystal Cavern
- [ ] Dungeon music plays
- [ ] Treasure chests give items
- [ ] Save crystal saves the game
- [ ] Encounter zones have harder enemies
- [ ] Boss room door requires the Crystal Key (if you created this item; otherwise leave `required_item_id` empty)
- [ ] Crystal Guardian dialogue plays before the fight

### 5. Boss Battle
- [ ] Boss has higher stats, tougher fight
- [ ] Defeating the boss triggers the ending
- [ ] Game over on party wipe opens the Game Over screen, with load-or-title options

### 6. Ending and Credits
- [ ] Ending text displays after boss
- [ ] Credits scroll and return to title
- [ ] "Continue" opens the save slot dialog and loads the selected save (if the player saved before the boss)

### 7. Systems Integration
- [ ] Save/load preserves all state correctly
- [ ] Quest log shows correct objective states for active quests
- [ ] Equipment changes are reflected in battle
- [ ] Pause menu works during gameplay and stays inactive on title/ending screens
- [ ] Audio volume controls persist across restarts via `user://settings.cfg`

## Common Bugs and Fixes

### "Player walks through walls"
- **Cause:** TileMap tiles don't have physics collision set.
- **Fix:** Select the tile in the TileSet editor, add collision on the Physics Layer.

### "Scene change crashes with null reference"
- **Cause:** Code runs on a node that was just freed during scene change.
- **Fix:** Check `is_instance_valid(node)` before accessing nodes during transitions.

### "Dialogue box doesn't advance"
- **Cause:** Input event consumed by another system.
- **Fix:** Ensure the dialogue box uses `_unhandled_input()` and calls `set_input_as_handled()`.

### "Enemy HP goes negative"
- **Cause:** `take_damage()` doesn't clamp to 0.
- **Fix:** `current_hp = max(0, current_hp - damage)`.

### "Save file loads wrong data"
- **Cause:** Resource paths changed since the save was written.
- **Fix:** Use stable paths. Add a version field to saves for migration.

### "Music plays over itself"
- **Cause:** MusicManager not checking if the same track is already playing.
- **Fix:** Check `track_path == _current_track_path` before starting.

### "Inventory shows stale data after using an item in battle"
- **Cause:** Battle creates a new Tween that outlives the inventory reference.
- **Fix:** Refresh inventory UI on `inventory_changed` signal.

## Performance Basics

2D JRPGs are not performance-intensive, but a few things to watch:

### Avoid `_process()` on everything
Nodes with empty `_process()` methods still cost a function call per frame. Remove the template `_process()` from scripts that don't need per-frame updates.

### Cache node references with `@onready`
```gdscript
# Good: cached once
@onready var sprite: Sprite2D = $Sprite

# Bad: looked up every frame
func _process(delta):
    get_node("Sprite").visible = true
```

### Object pool for damage numbers
If you're creating many floating damage numbers per battle, consider reusing label nodes instead of creating and freeing them each time.

### TileMap optimization
Large tilemaps with thousands of tiles are fine. Godot optimizes them into rendering quadrants. But avoid calling `set_cell()` in `_process()`.

> **See:** [Performance best practices](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html), the official performance guide.

## Exporting the Game

Until you export, your game only runs inside the Godot editor. Exporting creates a standalone application that anyone can play without installing Godot, the same way players download a game from Steam or itch.io. Cave Story was built by one person over five years, and the moment Daisuke Amaya exported it and uploaded it to his website, it went from a personal project to one of the most influential indie games ever made.

### Step 1: Install Export Templates

Go to **Editor → Manage Export Templates → Download and Install**. This downloads platform-specific build templates.

### Step 2: Create an Export Preset

1. Go to **Project → Export**.
2. Click **Add...** and choose your platform (Windows, macOS, or Linux).
3. Configure the preset name and output path.

### Step 3: Build

Click **Export Project** and choose where to save the build. Godot creates a standalone executable plus a `.pck` file containing all your game data.

Your game is now a real, distributable application.

> **See:** [Exporting projects](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html), the full export guide for all platforms.

## Balancing Your Game

You've built all the systems. Now comes the part that separates a frustrating game from a satisfying one: balance. No formula or system matters if the numbers don't feel right.

### Economy Balance

Your game has a gold economy: enemies drop gold, shops charge gold, inns cost gold. These form a loop:

```
Fight enemies → earn gold → buy equipment → fight harder enemies → earn more gold
```

Check this loop by doing the math on paper:

1. **How much gold does the player earn per dungeon run?** Average enemies per run * average gold per enemy. For Crystal Saga: ~8 fights * ~8 gold = ~64 gold per run.
2. **How much does the best available equipment cost?** Iron Sword = 50 gold, Leather Armor = 40 gold. Total to equip one character = ~90 gold.
3. **How many runs to afford a full equipment set?** 90 / 64 = ~1.5 dungeon runs. That feels about right; the player can gear up without excessive grinding.

If the answer to #3 is "10+ runs," your economy is too tight. If it's "they can buy everything after one fight," equipment upgrades don't feel meaningful. Aim for 1-3 dungeon runs to afford the next tier of gear.

The inn is a pressure valve. If it costs 10 gold and the player earns ~8 gold per fight, healing between runs costs roughly one fight's worth of gold. That's a fair tax.

### Combat Simulation

Here's a trick from professional RPG development: before playtesting manually, write a quick script that simulates hundreds of battles and prints the results. No UI needed, just pure math:

```gdscript
# Run this in a test script or the Output panel
func simulate_battle(attacker_atk: int, attacker_hp: int, defender_atk: int, defender_hp: int) -> Dictionary:
    var turns: int = 0
    var a_hp := attacker_hp
    var d_hp := defender_hp
    while a_hp > 0 and d_hp > 0:
        d_hp -= max(1, attacker_atk - 3 + randi_range(-2, 2))  # player hits enemy
        if d_hp <= 0:
            break
        a_hp -= max(1, defender_atk - 3 + randi_range(-2, 2))   # enemy hits player
        turns += 1
    return {player_won = a_hp > 0, turns = turns, remaining_hp = a_hp}
```

Run it 1,000 times with your actual stat values and check:
- **Win rate against regular enemies** should be 85-95%. Below 80% means the player will wipe too often. Above 98% means fights have no tension.
- **Average turns to win** should be 2-4 for trash mobs. Longer and fights feel like a slog. Shorter and enemies are just XP piñatas with no threat.
- **Remaining HP** after a fight tells you how many consecutive fights the player can handle before needing to heal. If they exit every fight at 95% HP, encounters have no strategic weight.

This approach lets you tune your damage formula, stat growth, and enemy stats without playing through the game dozens of times.

## Where to Go from Here

Crystal Saga is a foundation. Here's what you could add next, in rough order of complexity:

### More Content (Easy)
- New areas, NPCs, and quests using the existing systems
- More enemy types and encounter groups
- Additional items and equipment
- Extended dialogue for existing NPCs

### Status Effects System (Medium)
Generalize the Defend buff from Module 15 into a full system. The modifier pattern from Module 21 is the natural foundation: each status effect is a modifier with a duration.
- **Poison:** Lose HP each turn (3 turns). Implement as a tick effect that fires in CHECK_RESULT.
- **Sleep:** Skip turn, wakes on damage. Implement by intercepting the turn in TURN_START.
- **Stun:** Skip one turn. Same interception, but auto-clears after one skip.
- **Regen:** Heal HP each turn. Tick effect, opposite of Poison.
- **Buff/Debuff:** Temporary stat modifiers (the `add`/`mult` pattern from Module 21). Bravery adds +25% Attack for 3 turns; Slow reduces Speed by 50% for 2 turns.
- Each effect needs: type, duration (turns remaining), magnitude, a `tick()` method (for per-turn effects), and a modifier (for stat changes). Use unique IDs to prevent stacking the same buff; casting Bravery twice refreshes the duration instead of doubling the bonus.

### Elemental Weakness/Resistance (Medium)
Add elements to abilities and enemies:
- Fire, Ice, Lightning, Earth, Light, Dark
- Weakness = 2x damage, Resistance = 0.5x damage
- Adds strategic depth to magic and enemy design

### Limit Breaks (Medium)
Special abilities that charge as a character takes damage:
- A "limit gauge" that fills from 0 to 100
- At 100, a powerful unique ability becomes available
- Each character has a different limit break

### Advanced Dialogue (Medium-Hard)
- Speaker portraits that animate during dialogue
- Animated text effects (shake, wave, color change) via BBCode
- Cutscene system with camera movement and character positioning

### More Party Members (Medium)
Each new character needs: CharacterData, abilities, recruitment event, and unique battle behavior. The systems already support it; just add content.

### Procedural Dungeons (Hard)
Generate cave layouts from room templates:
- Define room shapes as small TileMapLayer sections
- Connect them with corridors via a generation algorithm
- Place enemies, chests, and the boss procedurally

### Controller Support Polish (Easy-Medium)
- Detect connected controller type (Xbox, PlayStation, Switch)
- Show matching button prompts in UI
- Analog stick deadzone tuning
- Vibration/rumble on hits

### Mobile Export (Medium)
- Touch controls (virtual D-pad, action buttons)
- Screen scaling for different aspect ratios
- Touch-friendly UI with larger buttons

## Recommended Resources

### Learning
- **[GDQuest](https://www.gdquest.com/):** High-quality Godot tutorials and courses
- **[KidsCanCode](https://kidscancode.org/godot_recipes/):** Godot recipes and patterns
- **[Official Godot docs](https://docs.godotengine.org/):** The reference we've cited throughout
- **[Godot community forums](https://forum.godotengine.org/):** Help and discussion

### Assets
- **[Kenney](https://kenney.nl/):** Free, high-quality 2D/3D game assets
- **[OpenGameArt](https://opengameart.org/):** Community-contributed free art
- **[itch.io asset packs](https://itch.io/game-assets):** Free and paid 2D art, including JRPG-specific packs
- **[Time Fantasy](https://finalbossblues.com/timefantasy/):** Professional JRPG tile and sprite packs

### Tools
- **[Aseprite](https://www.aseprite.org/):** Pixel art editor (paid, open source)
- **[Tiled](https://www.mapeditor.org/):** External tilemap editor (free)
- **[Audacity](https://www.audacityteam.org/):** Audio editing (free)

## Engineering Contract

- **Global state:** This module audits all existing autoload state rather than adding new systems.
- **Public surface:** Playtest checklist, troubleshooting guide, export steps, and extension roadmap.
- **Invariant:** The tutorial ships a vertical slice whose implemented systems agree with review modules and save/load contracts.
- **Failure behavior:** Any broken checkpoint becomes a concrete bug to fix before export.
- **Copy semantics:** Export packages project resources into a build; runtime user data remains under `user://`.

## Engine Gotcha

Exported builds do not write to `res://`. Save files and settings must use `user://`, and exported behavior should be tested separately from the editor.

## What We've Learned

- A finished tutorial vertical slice is more than isolated features; the title, save/load, audio, ending, and failure flows must all connect.
- Playtesting should follow the player's actual route through the game, not the order the systems were implemented.
- Save/load testing includes world-object flags, quest state, inventory, party stats, scene path, player position, and settings that live outside save slots.
- Performance work starts with simple habits: remove unused `_process()` methods, cache node references, and avoid per-frame tile edits.
- Exporting turns an editor project into a distributable application, but the build still needs the same gameplay verification as the editor version.

## What You Should See

After working through this module, your game should pass the full playtesting walkthrough above. Specifically:

- The title screen loads with New Game, Continue, and Settings buttons
- New Game starts in Willowbrook with Aiden, 3 Potions, and 100 gold
- You can walk through all three areas, talk to NPCs, buy items, and save at the crystal
- Random encounters trigger in Crystal Cavern, leading to turn-based battles
- The boss fight in the Crystal Cavern leads to the ending and credits
- Continue opens the save slot dialog and loads a saved game with all progress intact
- The game exports to a standalone executable that runs without the Godot editor

If any of these fail, check the Common Bugs section above and the troubleshooting tables in the review modules (08, 13, 19, 23, 27).

## What You've Accomplished

You started with an empty Godot project and a blinking cursor. Twenty-six modules later, you have:

- **Thousands of lines of GDScript** across dozens of scripts
- **8 autoloads** managing global game state and global UI (SceneManager, InventoryManager, GameManager, QuestManager, PartyManager, SaveManager, MusicManager, PauseMenu)
- **3 game areas** with hand-crafted tilemaps
- **A complete battle system** with state machines, AI, and animations
- **5 interlocking systems** (inventory, quests, party, save/load, audio)
- **A complete tutorial JRPG vertical slice** with a beginning, middle, and end

More importantly, you've learned the **patterns** that scale. The state machine pattern works for player movement, battle flow, quest tracking, and dialogue flow. The Resource pattern works for items, characters, enemies, quests, and encounters. The autoload pattern works for scene management, inventory, quests, party, save/load, audio, and pause UI. These patterns repeat everywhere in game development, not just in JRPGs.

## Closing Thoughts

JRPGs are a labor of love. They require patience: building systems, crafting worlds, writing dialogue, balancing combat, and testing everything together. But they're also one of the most rewarding genres to build, because every system connects to every other system, and when they all work together, the result is a game that feels whole.

Crystal Saga is small by commercial standards, but its tutorial architecture is complete enough to expand: more story, more areas, more characters, more mechanics. The foundation supports it.

## Next Module

In **Module 27: Part VI Review and Cheat Sheet**, we'll consolidate the audio, game-flow, polish, export, and final architecture into one reference you can use before extending the project.

The most important thing you can do now is **keep building**. Pick one of the "where to go from here" suggestions that excites you, and implement it. Then another. Each addition teaches you something new, and each one makes the game more yours.

Good luck. The world needs more JRPGs.


---

<!-- Source: 27_part_vi_review.md -->

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
- Created a **pause menu** as an autoload using `process_mode = ALWAYS` and `get_tree().paused`, while delegating inventory and quest log opening to the public APIs from Modules 12 and 20
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
    -> Resume / Inventory / Quest Log / Settings / Quit to Title
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
    if not current_scene:
        return false
    return current_scene.scene_file_path.begins_with("res://scenes/")


func _hide_for_submenu() -> void:
    _is_open = false
    _background.visible = false


func _open_inventory() -> void:
    var inv := get_tree().get_first_node_in_group("inventory_screens")
    if inv and inv.has_method("open_from_pause"):
        _hide_for_submenu()
        inv.call("open_from_pause")


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

The two critical pieces: `process_mode = Node.PROCESS_MODE_ALWAYS` ensures the pause menu still receives input when the tree is paused. `get_tree().paused = true` freezes every other node in the game. The `_can_pause_current_scene()` guard keeps Escape from opening the pause menu on title, ending, game over, or credits screens.

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

A reference list of polish items to consider before shipping. None of these are required to have a complete game, but each one makes the experience noticeably better:

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
| ShopUI | 21 | Talking to a shopkeeper |
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
  -> VictoryState detects boss ID, sets a GameManager world flag (Module 25)
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

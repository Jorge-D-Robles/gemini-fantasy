# Module 25: Title Screen and Game Flow

## What We Have So Far

Every system is built: exploration, combat, quests, party, inventory, save/load, audio. But the game starts by dropping the player directly into Willowbrook. There's no title screen, no pause menu, no credits. Time to complete the game loop.

## What We're Building This Module

The title screen (New Game / Continue / Settings), a pause menu, the complete game flow from launch to credits, and the victory ending.

## The Title Screen

The title screen is the first thing every player sees. Final Fantasy VII's iconic opening -- Cloud standing before the Shinra reactor, the logo fading in, the music swelling -- set the tone for the entire 40-hour experience before the player pressed a single button. A title screen establishes mood, gives the player clear entry points, and signals "this is a finished product, not a tech demo."

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
    # Show save slot selection, then load
    # Simplified: load slot 1 directly
    SaveManager.load_game(1)


func _on_settings() -> void:
    # Show the volume settings panel from Module 24
    var settings_scene := preload("res://ui/settings/settings_panel.tscn")
    var panel: PanelContainer = settings_scene.instantiate()
    add_child(panel)
    # Center it on screen
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.grab_focus()


func _initialize_fresh_state() -> void:
    # Reset all autoloads to starting state
    GameManager.load_flags({})

    # Reset inventory
    InventoryManager.from_save_data({gold = 100, items = []})
    var potion: ItemData = load("res://data/items/potion.tres")
    if potion:
        InventoryManager.add_item(potion, 3)

    # Reset party to just the hero
    PartyManager.from_save_data({members = []})
    var aiden: CharacterData = load("res://data/characters/aiden.tres")
    if aiden:
        # IMPORTANT: duplicate() creates a fresh copy. Without it, load() returns
        # the cached Resource, which may still have leveled-up stats from a
        # previous play session. This is a common Resource pitfall.
        aiden = aiden.duplicate()
        aiden.current_hp = aiden.max_hp
        aiden.current_mp = aiden.max_mp
        aiden.current_xp = 0
        aiden.level = 1
        PartyManager.add_member(aiden)

    # Reset quests
    QuestManager.from_save_data({active = [], completed = [], turned_in = []})


func _any_saves_exist() -> bool:
    for i in range(1, SaveManager.MAX_SLOTS + 1):
        if SaveManager.slot_exists(i):
            return true
    return false
```

Set `res://ui/title_screen/title_screen.tscn` as the project's **Main Scene**: go to **Project → Project Settings → General → Application → Run → Main Scene** and select the title screen `.tscn` file.

## The Pause Menu

In every Zelda game since the original, pressing Start opens an equipment and item screen. The pause menu is not just a way to stop the action -- it is the player's home base, the place they go to check inventory, review quests, change equipment, or adjust settings. Without it, the player has no way to manage their party between battles.

The pause menu is accessible from anywhere during gameplay.

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
    if event.is_action_pressed("ui_cancel"):
        if _is_open:
            close()
        else:
            open()
        get_viewport().set_input_as_handled()


func open() -> void:
    _is_open = true
    _background.visible = true
    get_tree().paused = true
    _resume_btn.grab_focus()


func close() -> void:
    _is_open = false
    _background.visible = false
    get_tree().paused = false


func _open_inventory() -> void:
    # Show the inventory screen from Module 12.
    # The InventoryScreen node must be in the "inventory_screens" group.
    # To set this up: in each scene that has an InventoryScreen instance,
    # select the InventoryScreen node → Node dock (next to Inspector) →
    # Groups tab → type "inventory_screens" → click Add.
    var inv := get_tree().get_first_node_in_group("inventory_screens")
    if inv:
        inv.visible = true


func _open_quest_log() -> void:
    # Show the quest log from Module 20.
    # Same group setup as inventory: select QuestLog node → Node dock →
    # Groups → add "quest_logs".
    var log_panel := get_tree().get_first_node_in_group("quest_logs")
    if log_panel:
        log_panel.visible = true
        log_panel.refresh()


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

Dragon Quest popularized the gentle game over: instead of erasing your progress, the king revives you at the last church but takes half your gold. The Game Over screen is a critical piece of player experience design -- it determines whether failure feels punishing or fair. Offering "Load Last Save" versus "Return to Title" gives the player agency after defeat.

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
    # Load the most recent save (slot 1 by default, or show slot dialog)
    SaveManager.load_game(1)


func _on_title() -> void:
    SceneManager.change_scene("res://ui/title_screen/title_screen.tscn")
```

Now update the defeat state in `res://systems/battle/states/defeat_state.gd` to use this screen (replacing the Module 18 placeholder):

```gdscript
extends BattleState
## Party wiped. Show Game Over screen.


func enter(_context: Dictionary = {}) -> void:
    print("--- DEFEAT ---")
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

Credits serve two purposes: they honor the people who made the game, and they give the player a moment to decompress after the climax. The scrolling credits in Final Fantasy VI, set to the character themes medley, are remembered as one of the greatest moments in gaming -- not because of gameplay, but because of the emotional space they create. Even for a solo project, credits signal "this is a complete work."

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
          Whisperwood (explore, random battles)
               ↓
         Crystal Cavern (dungeon, boss)
               ↓
       ┌── BOSS FIGHT ──┐
       ↓                 ↓
    Victory           Defeat
       ↓                 ↓
    Ending           Game Over
       ↓                 ↓
    Credits        Title Screen
       ↓
  Title Screen

At any time during gameplay:
  Escape → Pause Menu
    → Resume / Inventory / Quest Log / Settings / Quit to Title
  Save Crystal → Save Game
```

Every path loops back to the title screen. The game is a complete, closed loop.

## What We've Learned

- The **title screen** initializes fresh state for New Game or loads a save for Continue.
- The **pause menu** uses `process_mode = ALWAYS` and `get_tree().paused` to work during gameplay.
- **Quit to title** changes scene back to the title screen, resetting game state.
- The **ending** triggers after the boss is defeated, leading to credits then title.
- **Credits** scroll with a simple Tween on the label's Y position.
- The complete **game loop** ensures every path returns to the title screen.

## What You Should See

- Game launches to the title screen
- "New Game" starts fresh in Willowbrook with 3 Potions and 100 gold
- "Continue" loads the last save
- Escape opens the pause menu at any time
- Defeating the Crystal Guardian shows the ending and credits
- Everything loops back to the title screen

## Next Module

The game is complete. In **Module 26: Finish Line**, we'll walk through a full playtest, cover common bugs and fixes, discuss performance, export the game as a standalone build, and explore where to take Crystal Saga from here.

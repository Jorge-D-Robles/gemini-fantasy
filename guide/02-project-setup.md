# Chapter 2: Project Setup

Before writing game code, you need a project with the right renderer, viewport, input actions, folder structure, and conventions. This chapter is the equivalent of `ng new` plus your team's style guide — except you will understand every setting.

## Creating the Project

Open Godot and select **New Project**. Configure:

- **Project Name:** whatever you like
- **Project Path:** an empty directory
- **Renderer:** Mobile

### Why Mobile Renderer?

Godot offers three renderers:

| Renderer | Use Case |
|----------|----------|
| Forward+ | 3D games, advanced lighting, high-end hardware |
| Mobile | 2D games, mobile targets, older GPUs, pixel art |
| Compatibility | Lowest common denominator, web export, oldest hardware |

For a 2D pixel art JRPG, **Mobile** gives you everything you need (2D lighting, shaders, particles) without the overhead of Forward+. If you plan to export to web, switch to Compatibility — but Mobile is the right default for 2D.

After creating the project, Godot generates a `project.godot` file (the project manifest) and a `.godot/` directory (editor cache). The `.godot/` directory is regenerated automatically — never commit it to version control.

## Viewport and Pixel-Perfect Scaling

Pixel art requires precise control over how pixels are rendered. Open **Project > Project Settings > Display > Window** and configure:

| Setting | Value | Why |
|---------|-------|-----|
| Viewport Width | 320 | Base resolution width (NES/SNES scale) |
| Viewport Height | 180 | 16:9 aspect ratio at low resolution |
| Window Width Override | 1280 | 4x scaling for desktop (320 × 4) |
| Window Height Override | 720 | 4x scaling for desktop (180 × 4) |
| Stretch Mode | `viewport` | Renders at base resolution, then scales up |
| Stretch Aspect | `keep` | Adds black bars rather than distorting pixels |

With these settings, you design everything at 320x180 pixels. The engine scales up to fill the window while keeping pixels perfectly crisp. A 16x16 tile becomes 64x64 on screen at 4x scaling.

### Alternative: 640x360 Base Resolution

If 320x180 feels too constrained (very small UI text, limited screen space), use 640x360 with a 1280x720 window (2x scaling). This gives you more room for UI while still reading as pixel art. Choose one and stick with it — mixing base resolutions causes visual inconsistency.

### Texture Import Settings

For pixel art, textures must not be filtered or mipmapped. In Project Settings, under **Rendering > Textures**:

| Setting | Value | Why |
|---------|-------|-----|
| Default Texture Filter | `Nearest` | Sharp pixel edges, no blurring |

This applies globally. Individual textures can override this in their import settings, but you want `Nearest` as the default for any pixel art project.

## Input Actions

Godot's input system maps physical buttons to named **actions**. Instead of checking "is the A button pressed," you check "is the `interact` action pressed." This decouples your code from specific input devices.

Open **Project > Project Settings > Input Map** and add these actions:

| Action | Keyboard | Gamepad | Purpose |
|--------|----------|---------|---------|
| `move_left` | A, Left Arrow | Left Stick Left, D-Pad Left | Horizontal movement |
| `move_right` | D, Right Arrow | Left Stick Right, D-Pad Right | Horizontal movement |
| `move_up` | W, Up Arrow | Left Stick Up, D-Pad Up | Vertical movement |
| `move_down` | S, Down Arrow | Left Stick Down, D-Pad Down | Vertical movement |
| `interact` | E, Enter | A (Xbox), Cross (PS) | Talk to NPCs, interact with objects |
| `cancel` | Escape, Backspace | B (Xbox), Circle (PS) | Back out of menus, cancel actions |
| `menu` | Tab | Start | Open/close pause menu |
| `run` | Shift | X (Xbox), Square (PS) | Sprint while held |

Each action can have multiple physical inputs. The player code checks actions, not keys:

```gdscript
func _physics_process(_delta: float) -> void:
    var input_dir := Input.get_vector(
        "move_left", "move_right", "move_up", "move_down"
    )

    if input_dir != Vector2.ZERO:
        var speed := run_speed if Input.is_action_pressed("run") else move_speed
        velocity = input_dir.normalized() * speed
    else:
        velocity = Vector2.ZERO

    move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        _try_interact()
        get_viewport().set_input_as_handled()
```

`Input.get_vector()` returns a `Vector2` from four directional actions — it handles diagonal normalization automatically. `is_action_pressed()` checks if the action is currently held. `is_action_just_pressed()` checks if it was pressed this frame (single trigger, not repeating).

### Dead Zones

For gamepad sticks, set a dead zone of `0.2` on the directional actions to prevent stick drift from causing unintended movement. The Input Map editor has a dead zone slider per action.

## Project Folder Structure

A well-organized project separates concerns the same way a well-organized web application does. Create this folder structure inside the project root:

```
project_root/
├── project.godot           ← Project manifest
├── autoloads/              ← Global singletons (services)
├── resources/              ← Resource class definitions (data schemas)
├── data/                   ← .tres resource instances (data files)
│   ├── characters/
│   ├── enemies/
│   ├── abilities/
│   ├── items/
│   └── equipment/
├── systems/                ← Core game systems (battle, encounters, state machine)
├── entities/               ← Reusable scene prefabs (player, NPC, interactable)
│   ├── player/
│   ├── npc/
│   ├── interactable/
│   └── battle/
├── scenes/                 ← Level/area scenes (world maps, towns, dungeons)
├── ui/                     ← UI screens (HUD, menus, dialogue, battle UI)
├── events/                 ← Scripted story events and cutscenes
├── assets/                 ← Art and audio files
│   ├── sprites/
│   ├── tilesets/
│   ├── portraits/
│   ├── music/
│   └── sfx/
└── tests/                  ← Unit tests
```

### What Goes Where

| Directory | Analogy | Contains |
|-----------|---------|----------|
| `autoloads/` | Angular services (`providedIn: 'root'`) | Global state managers: GameManager, PartyManager, AudioManager, etc. |
| `resources/` | TypeScript interfaces/models | `.gd` files with `class_name` and `extends Resource` — data schemas |
| `data/` | JSON fixture files | `.tres` files — instances of Resource classes with actual data values |
| `systems/` | Business logic modules | State machine, battle engine, encounter system, progression math |
| `entities/` | Reusable components | Player, NPC, interactable objects — scenes placed in multiple levels |
| `scenes/` | Pages/routes | Complete level scenes (a town, a forest, a dungeon floor) |
| `ui/` | UI components | HUD overlay, dialogue box, battle menus, pause screen |
| `events/` | Workflow scripts | Scripted story sequences, cutscenes, recruitment events |
| `assets/` | Static assets | PNGs, OGGs, MP3s — raw art and audio |
| `tests/` | Test suites | Unit tests using the GUT testing framework |

### File Naming

Every file uses `snake_case`:

```
# Scripts
game_manager.gd
battler_data.gd
encounter_system.gd

# Scenes
player.tscn
battle_scene.tscn
dialogue_box.tscn

# Resources
goblin.tres
fire_potion.tres
iron_sword.tres
```

No spaces, no hyphens, no PascalCase in file names. Godot's `load()` function uses these paths directly — consistent naming prevents typos.

## GDScript Conventions

Establishing conventions now prevents arguments later. These match Godot's official style guide with additions for game development.

### Static Typing Everywhere

```gdscript
# Yes — every variable, parameter, and return type is explicit
var move_speed: float = 80.0
var facing: Facing = Facing.DOWN
var _is_active: bool = false

func calculate_damage(attack: int, defense: int) -> int:
    return maxi(attack - defense / 2, 1)

# Also yes — type inference with :=
var direction := Vector2.UP
var count := items.size()

# No — untyped code hides bugs
var speed = 80        # What type? int? float?
var items = []        # Array of what?
func do_thing(x):     # What is x?
    return x + 1      # What does this return?
```

Static typing catches errors at write time, enables autocompletion, and makes code self-documenting. Use explicit types for class-level variables and function signatures. Use `:=` for local variables where the type is obvious from the right-hand side.

### Naming Conventions

| Element | Convention | Example |
|---------|-----------|---------|
| Files | `snake_case` | `game_manager.gd`, `battler_data.gd` |
| Classes | `PascalCase` | `BattlerData`, `StateMachine`, `EncounterSystem` |
| Functions | `snake_case` | `calculate_damage()`, `get_active_party()` |
| Variables | `snake_case` | `move_speed`, `current_state` |
| Private members | `_snake_case` (leading underscore) | `_is_active`, `_state_stack` |
| Constants | `CONSTANT_CASE` | `MAX_HP`, `FADE_DURATION` |
| Signals | `snake_case` (past tense) | `damage_taken`, `dialogue_ended` |
| Enums | `PascalCase` name, `CONSTANT_CASE` values | `enum Facing { DOWN, UP, LEFT, RIGHT }` |

### Script Organization

Every script follows this order, top to bottom:

```gdscript
# 1. Annotations and metadata
class_name BattlerData
extends Resource

## Documentation comment for the class.

# 2. Signals
signal damage_taken(amount: int)
signal defeated

# 3. Enums
enum AiType {
    BASIC,
    AGGRESSIVE,
    DEFENSIVE,
    SUPPORT,
    BOSS,
}

# 4. Constants
const MAX_LEVEL: int = 99

# 5. Static variables
static var instance_count: int = 0

# 6. @export variables (grouped)
@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""

@export_group("Stats")
@export var max_hp: int = 100
@export var attack: int = 10

# 7. Regular variables
var current_hp: int = 0
var _is_defending: bool = false

# 8. @onready variables
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

# 9. Virtual/lifecycle methods
func _ready() -> void:
    pass


func _process(delta: float) -> void:
    pass


# 10. Public methods
func take_damage(amount: int) -> int:
    pass


func heal(amount: int) -> int:
    pass


# 11. Private methods
func _apply_defense_modifier(raw_damage: int) -> int:
    pass
```

This order is not arbitrary — it matches what a reader needs to know first. The signal declarations and exports define the node's public interface. The lifecycle methods show when things happen. Public methods show what the node does. Private methods are implementation details.

### Formatting Rules

```gdscript
# Tabs for indentation (not spaces)
func _ready() -> void:
	print("Ready")      # One tab

# Two blank lines between functions
func first_function() -> void:
    pass


func second_function() -> void:
    pass

# Lines under 100 characters

# Double quotes for strings
var name: String = "Kael"

# Trailing commas in multiline constructs
var stats: Dictionary = {
    "hp": 100,
    "attack": 15,
    "defense": 10,
}

enum GameState {
    OVERWORLD,
    BATTLE,
    DIALOGUE,
}

# Boolean operators as words, not symbols
if is_alive and not is_defending:
    take_damage(amount)

if has_item or gold >= price:
    buy_item()
```

### Comments

```gdscript
## Class-level documentation (double ##).
## Appears in Godot's built-in docs.
class_name BattlerData
extends Resource

# Regular comments explain "why", not "what"
# Clamp to 1 minimum to prevent zero-damage softlock
var damage: int = maxi(raw_damage, 1)

# Do NOT do this — the code already says what it does
var hp: int = 100  # Set hp to 100
```

Use `##` (double hash) for documentation comments on classes, signals, and exported variables. Godot's documentation system picks these up. Use `#` (single hash) for implementation notes that explain *why*, not *what*.

## The Golden Rule: Data | Logic | Presentation

This is the same separation you practice in web development — MVC, MVVM, or just "keep your business logic out of your templates." In a JRPG, it maps to:

| Layer | What | Where | Example |
|-------|------|-------|---------|
| **Data** | What things *are* | `resources/`, `data/` | BattlerData defines a goblin's stats |
| **Logic** | How things *behave* | `autoloads/`, `systems/` | BattleManager runs the turn loop |
| **Presentation** | How things *look* | `entities/`, `ui/`, `scenes/` | EnemyBattlerScene renders the goblin sprite |

This separation has the same benefits it does in web development:

- **Data is testable** — you can validate a Resource's fields without rendering anything
- **Logic is testable** — you can run damage calculations without a scene tree
- **Presentation is swappable** — you can redesign the battle UI without touching the battle engine

The concrete implementation:

```gdscript
# DATA — resource class (resources/enemy_data.gd)
class_name EnemyData
extends BattlerData

@export var ai_type: AiType = AiType.BASIC
@export var xp_reward: int = 10
@export var gold_reward: int = 5
```

```gdscript
# LOGIC — static utility (systems/battle/battler_damage.gd)
class_name BattlerDamage
extends RefCounted

static func compute_damage(
    attack: int,
    defense: int,
    base_damage: int,
) -> int:
    var defense_mod: float = maxf(
        1.0 - float(defense) / 100.0,
        0.1,
    )
    return maxi(roundi(float(base_damage + attack) * defense_mod), 1)
```

```gdscript
# PRESENTATION — visual scene (entities/battle/enemy_battler_scene.gd)
extends Node2D

@export var enemy_data: EnemyData

func show_damage_number(amount: int) -> void:
    var popup := DamagePopup.new()
    add_child(popup)
    popup.setup(amount, DamagePopup.PopupType.DAMAGE)
```

The damage formula lives in a static function with no dependencies on the scene tree. You can unit test it with pure input/output. The visual feedback lives in the scene script. The data lives in a `.tres` file. Each layer can change independently.

### Pure Functions for Game Logic

Static functions are the easiest code to test and reason about. Whenever possible, extract game logic into pure static functions:

```gdscript
# Pure function — no side effects, no scene tree access
static func compute_should_tick_playtime(state: GameState) -> bool:
    return state == GameState.OVERWORLD or state == GameState.MENU


# Pure function — deterministic damage calculation
static func compute_damage(attack: int, defense: int, base: int) -> int:
    var mod: float = maxf(1.0 - float(defense) / 100.0, 0.1)
    return maxi(roundi(float(base + attack) * mod), 1)


# Pure function — transition type based on scene pair
static func compute_transition_type(from: String, to: String) -> TransitionType:
    if from == "forest" and to == "village":
        return TransitionType.SLIDE_LEFT
    return TransitionType.FADE
```

These can be called from tests without instantiating nodes, creating scenes, or mocking anything. The autoload methods that use them are thin wrappers that read state and call the static function.

## Version Control

### What to Commit

```
project.godot            ← Project configuration
*.gd                     ← All scripts
*.tscn                   ← All scenes
*.tres                   ← All resources
*.cfg                    ← Editor/export configs
```

### What to Ignore

Create a `.gitignore` at the project root:

```gitignore
# Godot editor cache (regenerated on open)
.godot/

# OS metadata
.DS_Store
Thumbs.db

# Export builds
export/
builds/
```

The `.godot/` directory contains the import cache, shader cache, and editor state. It is fully regenerated when you open the project in the editor. Committing it creates enormous, meaningless diffs.

### Asset Imports

When you add a PNG or audio file to the project, Godot creates a `.import` file next to it (e.g., `player.png` gets `player.png.import`). These `.import` files describe how the asset should be processed (texture filter, compression, etc.) and **should be committed** — they are small text files that ensure consistent import settings across machines.

The actual imported data goes into `.godot/imported/` and should **not** be committed (it is covered by the `.godot/` ignore rule).

For large asset libraries (hundreds of PNGs, audio files), some teams gitignore the raw assets and distribute them separately. For a small-to-medium project, committing assets directly is simpler.

## Verifying the Setup

Before moving on, verify your project configuration. Open a new script and run this test scene:

```gdscript
# test_setup.gd — attach to a Node2D, run the scene (F6)
extends Node2D


func _ready() -> void:
    # Viewport size
    var vp: Vector2i = get_viewport().get_visible_rect().size
    print("Viewport: %dx%d" % [vp.x, vp.y])

    # Input actions
    var actions: Array[String] = [
        "move_left", "move_right", "move_up", "move_down",
        "interact", "cancel", "menu", "run",
    ]
    for action: String in actions:
        if InputMap.has_action(action):
            print("  [OK] %s" % action)
        else:
            print("  [MISSING] %s" % action)

    # Texture filter
    var filter: int = ProjectSettings.get_setting(
        "rendering/textures/canvas_textures/default_texture_filter"
    )
    print("Texture filter: %s" % ("Nearest (correct)" if filter == 0 else "NOT Nearest — fix this"))
```

Expected output:

```
Viewport: 320x180
  [OK] move_left
  [OK] move_right
  [OK] move_up
  [OK] move_down
  [OK] interact
  [OK] cancel
  [OK] menu
  [OK] run
Texture filter: Nearest (correct)
```

If the viewport is not 320x180, recheck your Display > Window settings. If actions are missing, add them in the Input Map. If the texture filter is wrong, change it in Rendering > Textures.

Delete this test script after verifying. It served its purpose.

## Common Mistakes

1. **Choosing Forward+ for a 2D game.** Forward+ adds 3D rendering overhead you do not need. Use Mobile for 2D projects.

2. **Forgetting to set texture filter to Nearest.** The default is `Linear`, which blurs pixel art into a smudgy mess. Set it once in Project Settings and forget it.

3. **Using `viewport` stretch mode with `expand` aspect.** This stretches your pixel art to fill non-matching aspect ratios, causing non-square pixels. Use `keep` to add letterboxing instead.

4. **Hardcoding keys instead of actions.** `Input.is_key_pressed(KEY_SPACE)` breaks gamepad support. Always use `Input.is_action_pressed("interact")` so the input map handles device abstraction.

5. **Committing `.godot/`.** It generates hundreds of megabytes of cache files. Gitignore it. If a teammate clones without it, opening the project in Godot regenerates everything.

6. **Flat folder structure.** Dumping everything into the root directory works for 5 files. At 50 files it is unnavigable. Establish the folder structure now while it costs nothing.

## What is Next

The project is configured. In the next chapter, we will create the Player — a `CharacterBody2D` with 4-directional movement, sprite animation, and interaction raycasting. This is where your game stops being a settings file and starts being a game.

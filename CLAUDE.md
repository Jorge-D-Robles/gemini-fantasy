# Gemini Fantasy

2D JRPG built with Godot 4.5, GDScript, mobile renderer. Licensed GPLv3.

## Project Structure

```
game/              # Godot project (scenes, scripts, assets)
docs/godot-docs/   # Official Godot documentation (git submodule)
```

## Godot Documentation Search Protocol

The full Godot docs are available at `docs/godot-docs/`. Use this 3-tier lookup system when writing or modifying GDScript code.

### Tier 1 -- Class Reference (API lookup)

Read the class file directly when you need properties, methods, or signals:

```
docs/godot-docs/classes/class_<classname_lowercase>.rst
```

Examples:
- `CharacterBody2D` -> `class_characterbody2d.rst`
- `AnimatedSprite2D` -> `class_animatedsprite2d.rst`
- `@GDScript` built-ins -> `class_@gdscript.rst`
- `@GlobalScope` -> `class_@globalscope.rst`

For large files (1000+ lines): read the Description section first (lines 1-100), then Grep within the file for specific methods/properties.

### Tier 2 -- Tutorial Search (how-to questions)

Grep within the relevant tutorial subdirectory. All paths relative to `docs/godot-docs/`:

| Directory | Covers |
|-----------|--------|
| `tutorials/2d/` | 2D rendering, tilemaps, sprites, movement, particles, parallax |
| `tutorials/scripting/gdscript/` | GDScript language, exports, typing, style guide |
| `tutorials/scripting/` | Signals, scenes, resources, autoloads, groups, scene tree |
| `tutorials/physics/` | CharacterBody2D, collision shapes, raycasting, Area2D |
| `tutorials/animation/` | AnimationPlayer, AnimationTree, cutout animation, 2D skeletons |
| `tutorials/ui/` | Control nodes, themes, containers, fonts, GUI navigation |
| `tutorials/inputs/` | InputEvent, input examples, controllers, mouse coordinates |
| `tutorials/navigation/` | Navigation2D, pathfinding, navigation agents/regions |
| `tutorials/audio/` | Audio buses, effects, streams, sync |
| `tutorials/io/` | Saving games, data paths, background loading |
| `tutorials/rendering/` | Viewports, multiple resolutions, renderers |
| `tutorials/best_practices/` | Scene organization, architecture, node alternatives |
| `getting_started/step_by_step/` | Nodes, scenes, signals, first script |
| `getting_started/first_2d_game/` | Complete 2D game tutorial (Dodge the Creeps) |

### Tier 3 -- Broad Search (fallback)

Grep across the entire `docs/godot-docs/` directory with `glob: "*.rst"`.

## When to Look Up Docs

- **ALWAYS** look up the class reference when using a Godot class for the first time in a task
- **ALWAYS** look up tutorials when implementing a new system (movement, combat, UI, tilemaps, saving, etc.)
- **SKIP** lookup for basic GDScript syntax (variables, loops, functions, conditionals)
- For complex questions spanning multiple docs, use `Task` with `subagent_type=Explore`

## Documentation Subagent Pattern

For complex lookups that need multiple files, spawn an Explore subagent:

```
Task(subagent_type="Explore", prompt=
  "Search the Godot documentation at docs/godot-docs/ for information about [TOPIC].
   Check class references at docs/godot-docs/classes/ and tutorials at docs/godot-docs/tutorials/.
   Also consult docs/godot-docs-index.md for topic-to-file mappings.
   Return: relevant class names, key methods/properties/signals, and any code examples found.")
```

## JRPG Core Classes

Classes most relevant to this project -- look these up first:

**Scene nodes**: Node2D, Sprite2D, AnimatedSprite2D, Camera2D, TileMapLayer, TileSet, Area2D, CharacterBody2D, CollisionShape2D, RayCast2D

**UI nodes**: Control, Label, RichTextLabel, TextureRect, NinePatchRect, Button, Panel, MarginContainer, VBoxContainer, HBoxContainer, GridContainer, ScrollContainer

**Systems**: AnimationPlayer, AnimationTree, AudioStreamPlayer, AudioStreamPlayer2D, Timer, Tween, SceneTree, PackedScene, Resource

**Input**: Input, InputEvent, InputMap

**Data**: @GDScript, @GlobalScope

## GDScript Code Style

Based on the official Godot style guide (`docs/godot-docs/tutorials/scripting/gdscript/gdscript_styleguide.rst`).

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| File names | snake_case | `yaml_parser.gd` |
| Class names | PascalCase | `class_name YAMLParser` |
| Node names | PascalCase | `Camera3D`, `Player` |
| Functions | snake_case | `func load_level():` |
| Variables | snake_case | `var particle_effect` |
| Signals | snake_case (past tense) | `signal door_opened` |
| Constants | CONSTANT_CASE | `const MAX_SPEED = 200` |
| Enum names | PascalCase (singular) | `enum Element` |
| Enum members | CONSTANT_CASE | `EARTH, WATER, AIR, FIRE` |

### Code Order in Scripts

```
01. @tool, @icon, @static_unload
02. class_name
03. extends
04. ## doc comment
05. signals
06. enums
07. constants
08. static variables
09. @export variables
10. remaining regular variables
11. @onready variables
12. _init() -> _ready() -> _process() -> _physics_process() -> other virtual methods
13. public methods
14. private methods (prefixed with _)
15. inner classes
```

### Key Rules

- Use **tabs** for indentation (Godot default)
- Use **static typing**: `var health: int = 0`, `func heal(amount: int) -> void:`
- Use `:=` for type inference when type is obvious: `var direction := Vector3(1, 2, 3)`
- Use explicit types when ambiguous: `var health: int = 0` (not `var health := 0`)
- Use `@export` for inspector-exposed variables
- Use `@onready` for node references: `@onready var health_bar: ProgressBar = get_node("UI/LifeBar")`
- Prefer `and`/`or`/`not` over `&&`/`||`/`!`
- Use **double quotes** for strings (single quotes only to avoid escapes)
- Use **trailing commas** in multiline arrays, dicts, enums
- Two blank lines between functions
- Lines under 100 characters (prefer 80)
- Prefer signals over direct method calls for decoupled communication
- One script per scene node (composition over inheritance)

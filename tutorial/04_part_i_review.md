# Module 4: Part I Review and Cheat Sheet

This module is a review and quick-reference for everything covered in Part I (Modules 1-3). Come back to this page whenever you need to look something up without re-reading the full modules.

## Part I in Review

You started Part I with nothing: no engine installed, no project, no code. Module 1 walked you through installing Godot, creating the Crystal Saga project, and understanding the mental model that underpins the entire engine -- everything is a node, and nodes compose into scenes. You placed a Sprite2D on screen, configured the project for pixel art, and ran your first build. The Godot icon on a gray background doesn't look like much, but it established the foundation: a project, a scene, a node, and a working feedback loop (edit, save, run, observe).

Module 2 gave you the language. You attached a script to that sprite and learned GDScript from the perspective of someone who already knows how to program. You wrote variables with static types, defined functions with return annotations, and discovered the virtual function system that drives Godot's game loop: `_ready()` for initialization, `_process(delta)` for per-frame logic. You wired up keyboard input through the Input Map and made the sprite move. By the end, your placeholder icon responded to arrow keys, moved at a consistent speed regardless of frame rate, and printed debug messages to the Output panel.

Module 3 shifted from "scripts that move things" to "scenes that *are* things." You built a Player scene from a CharacterBody2D with a Sprite2D and CollisionShape2D as children, learning why Godot favors composition over inheritance. You replaced direct position manipulation with `move_and_slide()`, switched from `_process()` to `_physics_process()`, and instanced the Player scene into your main scene. You also got your first taste of signals -- Godot's decoupled event system -- by connecting an Area2D's `body_entered` signal to a script function. The result: a reusable player character with physics-based movement that you can drop into any scene.

### Module 1: The Journey Begins

- Installed Godot 4.x and created the Crystal Saga project with the Compatibility renderer
- Learned Godot's core mental model: everything is a **node**, nodes compose into **scenes**, scenes save as `.tscn` files
- Explored the editor interface: Viewport, Scene dock, Inspector, FileSystem dock, Output panel
- Created a first scene with a Node2D root and a Sprite2D child, set a texture, positioned it, and saved
- Configured pixel art project settings: 640x360 viewport, 1280x720 window, `canvas_items` stretch mode, `Nearest` texture filtering

### Module 2: GDScript for Programmers

- Learned GDScript syntax: indentation-based blocks, static typing with `: Type` annotations, `extends` for inheritance
- Understood the virtual function lifecycle: `_ready()` runs once at initialization, `_process(delta)` runs every frame
- Used `delta` for frame-rate-independent movement and `Input.get_axis()` for clean directional input
- Discovered `@export` (expose variables in the Inspector) and `@onready` (safely cache node references after the tree is built)
- Used `print()` and the Output panel for basic debugging

### Module 3: Thinking in Scenes

- Built a reusable Player scene: CharacterBody2D with Sprite2D and CollisionShape2D children
- Learned the three physics body types (CharacterBody2D, RigidBody2D, StaticBody2D) and Area2D for detection zones
- Replaced `_process()` with `_physics_process()` and direct position changes with `velocity` + `move_and_slide()`
- Instanced the Player scene into the main scene, understanding how instancing hides internal structure
- Connected an Area2D `body_entered` signal through the editor, seeing how signals decouple node communication

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|----------------|------------|
| Node | The atomic building block of Godot; each type has one job (display image, play audio, handle collision) | Everything in your game is built from nodes | Module 1 |
| Scene | A saved tree of nodes (`.tscn` file) that can be instanced into other scenes | Keeps your game modular, testable, and reusable | Module 1 |
| Scene tree | The runtime hierarchy of every node currently in the game | How you navigate between nodes with `$`, `get_node()`, and `get_parent()` | Module 1 |
| Inspector | The editor panel that displays and edits all properties of the selected node | Your primary way to configure nodes without writing code | Module 1 |
| `res://` | Path prefix meaning "root of the project folder" | Every file reference in Godot code and scenes uses this prefix | Module 1 |
| GDScript | Godot's built-in scripting language, Python-like syntax designed for game development | The language you write all game logic in | Module 2 |
| Static typing | Optional type annotations (`var x: int = 5`) that catch errors at write-time | Better autocompletion, fewer runtime bugs | Module 2 |
| Virtual functions | Functions Godot calls for you at specific moments (`_ready`, `_process`, `_physics_process`) | The engine drives the game loop; you fill in the callbacks | Module 2 |
| Delta time | Time elapsed since the last frame, passed as `delta` to `_process()` and `_physics_process()` | Makes movement and animation frame-rate independent | Module 2 |
| Input Map | Named actions (like `ui_up`, `ui_right`) that abstract away raw keys and buttons | One code path works for keyboard, gamepad, and custom bindings | Module 2 |
| `@export` | Annotation that exposes a variable in the Inspector panel | Customize instances without editing scripts | Module 2 |
| `@onready` | Annotation that initializes a variable when `_ready()` fires | Safely cache node references after the scene tree is built | Module 2 |
| Composition | Building complex behavior by combining simple, focused nodes instead of deep inheritance | Keeps scenes modular and prevents monolithic scripts | Module 3 |
| CharacterBody2D | A physics body you control with code; uses `move_and_slide()` for collision response | The standard choice for player characters and NPCs in top-down games | Module 3 |
| `move_and_slide()` | Method on CharacterBody2D that moves along `velocity` and handles collision | Replaces manual position manipulation; handles delta internally | Module 3 |
| `_physics_process()` | Virtual function called at a fixed rate (60/sec) regardless of frame rate | Required for consistent physics and collision detection | Module 3 |
| Instancing | Placing one scene inside another; it appears as a single node with internals hidden | How you reuse scenes across multiple levels | Module 3 |
| Signals | Godot's event system; a node emits a signal, other nodes connect to it and respond | Decoupled communication between nodes without tight dependencies | Module 3 |

## Cheat Sheet

### The Godot Editor

| Area | Location | Purpose |
|------|----------|---------|
| Viewport | Center | Visual workspace where you see and arrange nodes; use 2D tab for our project |
| Scene dock | Top-left | Shows the node hierarchy of the open scene; add nodes with `+` button |
| Inspector | Right | Displays all properties of the selected node; edit values directly |
| FileSystem dock | Bottom-left | Project file browser; drag scenes from here to instance them |
| Output panel | Bottom | Shows `print()` output, errors, and warnings |
| Node tab | Right (next to Inspector) | Lists signals on the selected node; double-click to connect |

**Keyboard shortcuts used so far:**

| Shortcut | Action |
|----------|--------|
| F5 | Run the main scene |
| F6 | Run the currently open scene |
| F8 | Stop the running game |
| Ctrl+A / Cmd+A | Add a child node to the selected node |
| Ctrl+S / Cmd+S | Save the current scene |
| Ctrl+N / Cmd+N | Create a new scene |
| Ctrl+Space | Trigger autocompletion in the script editor |
| Ctrl+Click | Jump to definition in the script editor |
| Ctrl+/ / Cmd+/ | Toggle comment on selected lines |
| F1 | Open built-in documentation search |

### GDScript Essentials

**Variables and types:**

```gdscript
# Explicit type annotation (preferred)
var speed: float = 200.0
var player_name: String = "Aiden"
var health: int = 100
var is_alive: bool = true
var direction: Vector2 = Vector2.ZERO

# Type inference
var speed := 200.0          # inferred as float
var player_name := "Aiden"  # inferred as String

# Constants
const MAX_SPEED: float = 300.0
```

**Common types:**

| Type | Example | Use Case |
|------|---------|----------|
| `int` | `42` | Whole numbers (HP, damage, counts) |
| `float` | `3.14` | Decimals (speed, timers, delta) |
| `bool` | `true` / `false` | Flags and conditions |
| `String` | `"hello"` | Text (always double quotes) |
| `Vector2` | `Vector2(10, 20)` | 2D positions and directions |
| `Array` | `[1, 2, 3]` | Ordered lists |
| `Dictionary` | `{"hp": 100}` | Key-value pairs |

**Functions:**

```gdscript
# With parameters and return type
func calculate_damage(attack: int, defense: int) -> int:
    return max(1, attack - defense)

# Void return
func take_damage(amount: int) -> void:
    health -= amount

# Default parameters
func heal(amount: int = 10) -> void:
    health = min(health + amount, max_health)
```

**Control flow:**

```gdscript
# Conditionals
if health <= 0:
    print("Dead")
elif health < 20:
    print("Critical!")
else:
    print("Fine")

# Loops
for i in range(5):
    print(i)

for item in inventory:
    print(item.name)

# Match (like switch/case)
match state:
    "idle":
        velocity = Vector2.ZERO
    "walk":
        velocity = direction * speed
    _:
        pass  # default case
```

**Style rules:**

- Tabs for indentation (never spaces)
- Double quotes for strings
- Two blank lines between functions
- Use `and`, `or`, `not` instead of `&&`, `||`, `!`
- Private members prefixed with `_` (convention, not enforced)

### Node and Scene Fundamentals

**Node types introduced so far:**

| Node | Purpose |
|------|---------|
| [`Node2D`](https://docs.godotengine.org/en/stable/classes/class_node2d.html) | Generic 2D container node; good as a scene root |
| [`Sprite2D`](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html) | Displays a 2D image (texture) |
| [`CharacterBody2D`](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) | Player-controlled physics body with `move_and_slide()` |
| [`CollisionShape2D`](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) | Defines the collision boundary for a physics body or area |
| [`Area2D`](https://docs.godotengine.org/en/stable/classes/class_area2d.html) | Detection zone that emits signals when bodies enter/exit |
| [`Camera2D`](https://docs.godotengine.org/en/stable/classes/class_camera2d.html) | Controls what part of the world the player sees (mentioned, not yet used) |

**Scene composition pattern:**

```
Player (CharacterBody2D)       <-- root: handles movement and collision
├── Sprite2D                   <-- displays the character image
└── CollisionShape2D           <-- defines the hitbox
```

**Navigating the scene tree in code:**

```gdscript
$Sprite2D                     # get child by name (shorthand for get_node("Sprite2D"))
$"Long Node Name"             # quote names with spaces
$UI/HealthBar                 # traverse a path: child "UI", then its child "HealthBar"
get_parent()                  # the node above this one
get_tree()                    # the SceneTree object
get_node("/root/Main/Player") # absolute path from root
```

**Scene file conventions:**

- `.tscn` -- text scene file (human-readable, diffs well in git)
- `.tres` -- text resource file
- Name folders and files in `snake_case`
- Scene and its primary script share a name: `player.tscn` + `player.gd`

### Signals

**What signals do:** Let nodes communicate without knowing about each other. A node emits a signal ("something happened"), connected nodes respond ("run this function").

**Connecting in the editor:**

1. Select the node that emits the signal
2. Click the **Node** tab (right side, next to Inspector)
3. Double-click the signal you want to connect
4. Choose the receiving node and click **Connect**

Godot generates a callback function in the receiver's script:

```gdscript
func _on_test_zone_body_entered(body: Node2D) -> void:
    print("Something entered the zone: ", body.name)
```

**Key signal covered so far:**

| Signal | Emitted By | When |
|--------|-----------|------|
| [`body_entered`](https://docs.godotengine.org/en/stable/classes/class_area2d.html#signals) | Area2D | A physics body enters the area's collision shape |

**Signal cleanup:** When a node is freed (removed from the tree and deleted), all its signal connections are automatically disconnected. No manual cleanup needed.

### Input Handling

**The Input Map** (Project --> Project Settings --> Input Map) maps named actions to physical keys:

| Action | Default Key | To Add WASD |
|--------|------------|-------------|
| `ui_up` | Arrow Up | Add W |
| `ui_down` | Arrow Down | Add S |
| `ui_left` | Arrow Left | Add A |
| `ui_right` | Arrow Right | Add D |
| `ui_accept` | Enter, Space | -- |
| `ui_cancel` | Escape | -- |

**Checking input in code:**

```gdscript
# Is the key held down right now? (true every frame it's held)
Input.is_action_pressed("ui_right")

# Was the key just pressed this frame? (true for one frame only)
Input.is_action_just_pressed("ui_accept")

# Get a -1 to 1 axis value (clean way to get directional input)
Input.get_axis("ui_left", "ui_right")
```

**Clean directional input pattern:**

```gdscript
func _get_input_direction() -> Vector2:
    return Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down"),
    )
```

### CharacterBody2D Movement

**Module 2 pattern -- direct position manipulation (no collision):**

```gdscript
extends Sprite2D

@export var speed: float = 200.0


func _process(delta: float) -> void:
    var direction := _get_input_direction()
    if direction != Vector2.ZERO:
        direction = direction.normalized()
    position += direction * speed * delta
```

**Module 3 pattern -- physics-based movement with collision:**

```gdscript
extends CharacterBody2D

@export var speed: float = 200.0


func _physics_process(delta: float) -> void:
    var direction := Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down"),
    )
    if direction != Vector2.ZERO:
        direction = direction.normalized()
    velocity = direction * speed
    move_and_slide()
```

**Key differences:**

| | Module 2 (Sprite2D) | Module 3 (CharacterBody2D) |
|---|---|---|
| Loop | `_process(delta)` | `_physics_process(delta)` |
| Movement | `position += direction * speed * delta` | `velocity = direction * speed` then `move_and_slide()` |
| Delta handling | Manual (multiply by `delta`) | Automatic (`move_and_slide()` handles it) |
| Collision | None | Automatic via CollisionShape2D |

**Why normalize?** Without `direction.normalized()`, diagonal movement is approximately 41% faster than cardinal movement because the diagonal of a unit square is the square root of 2 (about 1.414). Normalizing makes the vector length exactly 1 in all directions.

**Motion mode:** Set CharacterBody2D's Motion Mode to **Floating** for top-down games. The default (Grounded) is for side-scrollers and adds floor/wall/ceiling logic you don't need.

### Project Settings Checklist

These settings were configured in Part I for pixel art rendering:

| Setting | Path in Project Settings | Value | Why |
|---------|--------------------------|-------|-----|
| Viewport Width | Display --> Window --> Viewport Width | `640` | Internal rendering resolution |
| Viewport Height | Display --> Window --> Viewport Height | `360` | Internal rendering resolution |
| Window Width Override | Display --> Window --> Window Width Override | `1280` | Window size on screen (2x viewport) |
| Window Height Override | Display --> Window --> Window Height Override | `720` | Window size on screen (2x viewport) |
| Stretch Mode | Display --> Window --> Stretch --> Mode | `canvas_items` | Scales viewport to fill window |
| Texture Filter | Rendering --> Textures --> Default Texture Filter | `Nearest` | Keeps pixels sharp instead of blurry |
| Main Scene | Application --> Run --> Main Scene | `res://main.tscn` | Which scene runs when you press F5 |

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Texture filter left on `Linear` | Sprites look blurry and smudged when the game runs | Project Settings --> Rendering --> Textures --> Default Texture Filter --> set to `Nearest` |
| Accessing `$NodeName` outside `@onready` | Null reference error at startup; the node hasn't entered the tree yet | Use `@onready var sprite: Sprite2D = $Sprite2D` instead of a plain `var` |
| CollisionShape2D with no shape assigned | Yellow warning triangle on the node; CharacterBody2D cannot detect collisions | Select the CollisionShape2D, click its Shape property in the Inspector, and create a new shape (e.g., RectangleShape2D) |
| Using `_process()` with `move_and_slide()` | Inconsistent collision detection; objects may clip through walls at low frame rates | Switch to `_physics_process()` for any code that calls `move_and_slide()` |
| Multiplying `velocity` by `delta` before `move_and_slide()` | Movement is extremely slow (double-applying delta) | Set `velocity` in pixels per second directly; `move_and_slide()` handles delta internally |
| Not normalizing diagonal input | Diagonal movement is roughly 41% faster than cardinal movement | Call `direction.normalized()` when the direction vector is non-zero |
| Main scene not set | Pressing F5 shows a dialog asking which scene to run, or nothing happens | Project Settings --> Application --> Run --> Main Scene --> set to `res://main.tscn` |
| WASD keys don't work | Arrow keys work but WASD does nothing | Open Project Settings --> Input Map, find each `ui_*` action, click `+`, and bind the WASD key |

## Official Godot Documentation

Every class, method, and concept referenced in Part I, organized by category. Bookmark these -- they're the official source of truth for anything not covered in this tutorial.

### Getting Started

- [Introduction to Godot](https://docs.godotengine.org/en/stable/getting_started/introduction/introduction_to_godot.html) -- engine overview and design philosophy
- [First look at the editor](https://docs.godotengine.org/en/stable/getting_started/introduction/first_look_at_the_editor_interface.html) -- editor panels and layout
- [Creating and importing projects](https://docs.godotengine.org/en/stable/getting_started/step_by_step/creating_and_importing_projects.html) -- project creation and the Project Manager
- [Nodes and Scenes](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html) -- the core building blocks

### GDScript

- [GDScript basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html) -- complete language reference (syntax, types, features)
- [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html) -- official naming and formatting conventions
- [Overridable functions](https://docs.godotengine.org/en/stable/tutorials/scripting/overridable_functions.html) -- full list of virtual functions (`_ready`, `_process`, `_enter_tree`, etc.)

### Scripting and Architecture

- [Nodes and scene instances](https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html) -- instancing scenes, composition, and reuse
- [Scene tree](https://docs.godotengine.org/en/stable/tutorials/scripting/scene_tree.html) -- runtime hierarchy, node ordering, and groups
- [Idle and physics processing](https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html) -- `_process()` vs `_physics_process()` and when to use each
- [Instancing with signals](https://docs.godotengine.org/en/stable/tutorials/scripting/instancing_with_signals.html) -- combining scene instancing with signal-based communication

### Input

- [Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html) -- input handling patterns and code samples
- [InputEvent](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html) -- how input events propagate through the scene tree

### Physics

- [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html) -- body types, collision layers, and physics concepts

### Class References

- [`Node`](https://docs.godotengine.org/en/stable/classes/class_node.html) -- base class for all nodes
- [`Node2D`](https://docs.godotengine.org/en/stable/classes/class_node2d.html) -- base class for 2D nodes (has `position`, `rotation`, `scale`)
- [`Sprite2D`](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html) -- displays a 2D texture
- [`CharacterBody2D`](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html) -- player-controlled physics body with `move_and_slide()`
- [`RigidBody2D`](https://docs.godotengine.org/en/stable/classes/class_rigidbody2d.html) -- physics-driven body with mass, friction, and forces
- [`StaticBody2D`](https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html) -- immovable collision body
- [`Area2D`](https://docs.godotengine.org/en/stable/classes/class_area2d.html) -- detection zone with `body_entered` / `body_exited` signals
- [`CollisionShape2D`](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html) -- defines collision boundaries for physics bodies and areas
- [`Camera2D`](https://docs.godotengine.org/en/stable/classes/class_camera2d.html) -- 2D camera that controls the viewport
- [`Label`](https://docs.godotengine.org/en/stable/classes/class_label.html) -- displays text on screen
- [`AudioStreamPlayer`](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html) -- plays audio
- [`AnimatedSprite2D`](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html) -- plays frame-based sprite animations
- [`TileMapLayer`](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html) -- renders a grid of tiles (mentioned, used in Part II)
- [`Vector2`](https://docs.godotengine.org/en/stable/classes/class_vector2.html) -- 2D vector used for positions, directions, and velocities
- [`Input`](https://docs.godotengine.org/en/stable/classes/class_input.html) -- global singleton for checking input state
- [`RectangleShape2D`](https://docs.godotengine.org/en/stable/classes/class_rectangleshape2d.html) -- rectangular collision shape

## What's Next

In **Part II: Building the World**, we'll put these foundations to work. Module 5 introduces TileMapLayers, and you'll build the town of Willowbrook as a multi-layered tile map with ground, paths, water, and collision walls your player character can actually bump into.

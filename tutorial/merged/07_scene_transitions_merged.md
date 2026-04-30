# Merged Tutorial Through Module 07

This generated file combines the tutorial Markdown files from Module 01 through Module 07.

## Included Files

- `01_the_journey_begins.md`
- `02_gdscript_for_programmers.md`
- `03_thinking_in_scenes.md`
- `04_part_i_review.md`
- `05_tilemaps_and_terrain.md`
- `06_player_character.md`
- `07_scene_transitions.md`

---

<!-- Source: 01_the_journey_begins.md -->

# Module 1: The Journey Begins

## What We're Building

By the end of this module, you'll have Godot installed, a brand new project created, and a sprite displayed on screen. It's not much to look at yet, but it's the foundation for everything that follows.

More importantly, you'll understand **how Godot thinks about games**: as trees of small, reusable building blocks called nodes, grouped into scenes. This mental model is what matters most to learn early, because every system we build in this tutorial (movement, combat, dialogue, inventory) is just a different arrangement of nodes in a scene tree.

## What is Godot?

Godot is a free, open-source game engine for 2D and 3D games. It runs on Windows, macOS, and Linux, and can export games to all of those platforms plus mobile and web. It's been in development since 2007, was open-sourced in 2014, and has grown rapidly since.

For our purposes (building a 2D JRPG), Godot is an excellent choice for three reasons:

1. **First-class 2D support.** Unlike engines that bolt 2D onto a 3D core, Godot's 2D system is purpose-built. Pixel-perfect rendering, tile maps, sprite animation, and 2D physics all work out of the box without fighting 3D abstractions.

2. **GDScript.** Godot's built-in scripting language is designed specifically for game development. If you've written Python, you'll feel at home immediately. It's tightly integrated with the editor: autocompletion, documentation, and debugging all work without extra setup.

3. **Scene system.** Godot's scene-based architecture maps naturally to JRPG design. A town is a scene. A battle screen is a scene. An NPC is a scene. A dialogue box is a scene. You compose them like building blocks, and each one is self-contained and reusable.

> **See:** [Introduction to Godot](https://docs.godotengine.org/en/stable/getting_started/introduction/introduction_to_godot.html), the official overview of the engine's capabilities and design philosophy.

## Installing Godot

Go to [godotengine.org/download](https://godotengine.org/download) and download the standard **Godot 4.6.2** release. This series is verified against Godot 4.6.2. Older Godot 4.x releases may work, but editor labels, default settings, and a few APIs can shift between stable branches, so treat 4.6.2 as the baseline unless you are deliberately compatibility-testing another version.

A few notes on the download:

- **Choose the standard version**, not the .NET version (that's for C# development; we're using GDScript).
- Godot is a single executable, no installer needed. Download it, extract it, and run it. On macOS, drag it to your Applications folder. On Windows, put it wherever you like.
- The download is small (around 60-80 MB). Godot is lightweight compared to other engines.

Launch Godot. You'll see the **Project Manager**.

## Creating a New Project

The Project Manager is where you create, import, and organize your Godot projects.

1. Click **Create** (or **New Project** in some versions).
2. **Project Name:** Type `CrystalSaga`.
3. **Project Path:** Choose a folder on your computer. Godot will create a subfolder with the project name.
4. **Renderer:** Select **Compatibility** (also labeled "OpenGL 3" in some versions). This renderer is ideal for 2D pixel art games. It's the simplest, most widely supported option, and gives us the crispest pixel rendering.
5. Click **Create & Edit**.

> **See:** [Creating and importing projects](https://docs.godotengine.org/en/stable/getting_started/step_by_step/creating_and_importing_projects.html), with more details on project creation options.

The editor opens. Take a breath; there's a lot on screen. Here's a quick breakdown.

## The Editor Interface

Godot's editor is divided into several main areas. Don't worry about memorizing all of them now. We'll use each one naturally as we build Crystal Saga.

### The Viewport (center)

The large area in the middle of the screen is the **viewport**. This is where you see and arrange your game's visual elements. At the top of the viewport, you'll see workspace tabs: **2D**, **3D**, **Script**, and **Asset Library**. Since we're making a 2D game, click **2D** if it's not already selected.

### The Scene Dock (top-left)

This panel shows the **scene tree**, the hierarchy of nodes in the currently open scene. Right now it's empty, because we haven't created a scene yet. It will say something like "Create Root Node" with buttons for common starting points.

### The Inspector (right)

When you select a node, the **Inspector** panel shows all of its properties. Think of it as a property editor: every setting a node has (position, color, texture, speed, etc.) can be adjusted here.

### The FileSystem Dock (bottom-left)

This is your project's file browser. It shows every file in your project folder: scripts, scenes, images, audio, everything. You'll spend a lot of time here organizing your game's assets.

### The Output Panel (bottom)

This is where `print()` output appears, along with errors and warnings. It's your primary debugging tool until we get to breakpoints later.

> **See:** [First look at Godot's interface](https://docs.godotengine.org/en/stable/getting_started/introduction/first_look_at_the_editor_interface.html), the official walkthrough of every panel and dock in the editor.

## Nodes: The Building Blocks

Here's the most important concept in Godot:

**Everything is a node.**

A node is the smallest building block of your game. There are dozens of node types, each with a specific purpose:

| Node Type | What It Does |
|-----------|-------------|
| `Sprite2D` | Displays an image |
| `Camera2D` | Controls what the player sees |
| `CharacterBody2D` | A body that moves and collides with physics |
| `CollisionShape2D` | Defines the shape of a collision area |
| `Label` | Displays text |
| `AudioStreamPlayer` | Plays audio |
| `TileMapLayer` | Renders a grid of tiles |
| `AnimatedSprite2D` | Plays sprite-based animations |

A single node doesn't do much on its own. The power comes from **combining them**. A playable character isn't one magical "Player" object. It's a tree of nodes working together:

```
CharacterBody2D (handles movement and collision)
├── Sprite2D (displays the character's image)
├── CollisionShape2D (defines the hitbox)
└── Camera2D (makes the viewport follow the character)
```

Each node does one thing well. Together, they create complex behavior. This is Godot's core philosophy: **composition over inheritance**.

> **See:** [Nodes and Scenes](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html), the official guide to understanding nodes, the scene tree, and how they compose together.

## Scenes: Reusable Node Trees

When you arrange nodes into a tree and save it, that's a **scene**. A scene is a `.tscn` file on disk that stores the entire tree: every node, every property, every connection.

Scenes are Godot's version of what other engines call "prefabs" or "blueprints." But scenes in Godot are more flexible:

- A scene can be **instanced** inside another scene. Your Player scene can be dropped into your Town scene, your Forest scene, your Battle scene, anywhere.
- When you instance a scene, it appears as a single node in the parent's tree, with all its internals hidden. This keeps things clean.
- Scenes can contain other scenes. Your Town scene might contain several NPC scenes, each of which contains a Sprite and a collision shape.

This maps well to how we think about JRPG structure:

```
Town Scene
├── TileMapLayer (the ground and buildings)
├── Player (a scene instance)
├── NPC_Shopkeeper (a scene instance)
├── NPC_Innkeeper (a scene instance)
└── ExitZone (triggers scene change to the forest)
```

Every scene is self-contained. The NPC scene doesn't know or care whether it's in a town or a dungeon. The Player scene works the same everywhere. This separation is what lets us build complex games without the code becoming a tangled mess.

> **See:** [Nodes and scene instances](https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html), the official tutorial on scene instancing and composition.

## Your First Scene: A Sprite on Screen

Time to put something on screen. We'll create a simple scene with a single `Sprite2D` node, the beginning of our player character.

### Step 1: Create the Root Node

In the **Scene** dock (top-left), you'll see buttons to create a root node. Click **2D Scene**. This creates a `Node2D` as the root, a generic 2D node that works as a container.

You'll see `Node2D` appear in the scene tree. Rename it by double-clicking the name and typing `Main`.

### Step 2: Add a Sprite

With `Main` selected, click the **+** button at the top of the Scene dock (or press `Ctrl+A` / `Cmd+A`) to add a child node. The "Create New Node" dialog appears.

Type `Sprite2D` in the search bar and select it. Click **Create**. You now have:

```
Main (Node2D)
└── Sprite2D
```

### Step 3: Give It a Texture

The Sprite2D node needs an image to display. We don't have character art yet, so we'll use Godot's built-in icon.

1. Select the `Sprite2D` node in the scene tree.
2. In the **Inspector** (right panel), find the **Texture** property.
3. Click the empty texture slot and select **Load**.
4. Navigate to and select `icon.svg`, Godot's logo, which is included in every new project.

You should see the Godot icon appear in the viewport. If it's hard to see, use the scroll wheel to zoom in, and middle-click-drag to pan around.

### Step 4: Position It

With the Sprite2D selected, look at the **Transform** section in the Inspector. Set:
- **Position** → x: `320`, y: `180`

This places the sprite in the center of the viewport. (We'll set the viewport to 640x360 shortly, so this position is already centered for our final resolution.) You can also just drag the sprite in the viewport to position it.

### Step 5: Save the Scene

Press `Ctrl+S` (`Cmd+S` on macOS). Save it as `main.tscn` in the root of your project.

> **Note:** Godot uses `.tscn` (text scene) for scene files and `.tres` (text resource) for resource files. Both are human-readable text formats. You can even open them in a text editor, though you rarely need to.

## Setting the Main Scene

When you press Play, Godot needs to know which scene to run first. This is the **main scene**.

If you haven't set one yet, Godot will prompt you the first time you press F5 (or the Play button ▶ in the top-right). It will ask if you want to use the currently open scene as the main scene. Click **Select Current**.

You can also set it manually:
1. Go to **Project → Project Settings**.
2. Under **General → Application → Run**, find the **Main Scene** property.
3. Set it to `res://main.tscn`.

> **Note:** `res://` is Godot's shorthand for "the root of the project folder." Every file path in Godot starts with `res://`. In Module 22 (Save and Load), we'll use another prefix, `user://`, which points to the user's save data folder.

## Running the Project

Press **F5** (or click the ▶ play button in the top-right corner of the editor).

A window appears showing the Godot icon on a gray background. That's your game running. It's not exciting yet, but it's real. Every JRPG you've ever played started as something like this: a single image on a screen.

Press the **X** on the game window (or press `F8`, or click the stop button in the editor) to close it.

> **Warning:** The game window and the editor are separate. Changes you make in the editor while the game is running won't appear until you stop and restart the game. This is different from some engines that support "live editing."

### A Note on the Play Buttons

The top-right of the editor has several play buttons:

| Button | Shortcut | What It Does |
|--------|----------|-------------|
| ▶ Play | F5 | Runs the main scene |
| ▶ Play Scene | F6 | Runs the currently open scene (useful for testing individual scenes) |
| ▶ Play Custom | (none) | Runs a specific scene you choose |
| ⏹ Stop | F8 | Stops the running game |

**F6 (Play Scene)** will become your best friend. When you're working on the battle scene, you don't want to play through the title screen and overworld to test it. Just hit F6 to run that scene directly.

## Project Settings for Pixel Art

Before we move on, we need to configure the project for pixel art, the visual style of most 2D JRPGs.

Go to **Project → Project Settings** and make these changes:

### Display Settings
Under **Display → Window**:
- **Viewport Width:** `640`
- **Viewport Height:** `360`
- **Window Width Override:** `1280`
- **Window Height Override:** `720`
- **Stretch → Mode:** `canvas_items`

The **viewport** (640x360) is the internal resolution your game renders at. The **window overrides** (1280x720) control how big the window appears on screen. Godot scales the viewport up to fill the window, at exactly 2x in our case. Every pixel in our game will be rendered at exactly 2x size, keeping art crisp.

### Texture Filtering
Under **Rendering → Textures**:
- **Default Texture Filter:** `Nearest`

This is critical for pixel art. The default `Linear` filter blurs pixels when scaling, turning your crisp sprites into smudgy mush. `Nearest` keeps every pixel sharp.

> **Warning:** If your sprites look blurry when you run the game, this setting is almost always the culprit. `Nearest` filtering is the #1 pixel art configuration step.

After changing these settings, run the game again (F5). The window will be larger (1280x720), and if you look closely at the Godot icon, its pixels should be crisp and sharp rather than blurry.

## Engineering Contract

- **Global state:** None yet; this module only creates the project shell.
- **Public surface:** A Godot project that opens cleanly in the verified editor version.
- **Invariant:** The project should run an empty or starter scene without import errors before Module 2.
- **Failure behavior:** Version/import problems are fixed now rather than carried forward.
- **Copy semantics:** Assets and Resources are still editor-owned; no runtime mutation is introduced.

## Engine Gotcha

Godot minor versions can change editor defaults, import behavior, and generated project metadata. This tutorial series is pinned to the verified baseline from this module; older 4.x versions may work, but they are not guaranteed unless you retest the full path.

## What We've Learned

Here are the key concepts from this module:

- **Godot** is a free game engine with excellent 2D support and a purpose-built scripting language (GDScript).
- **Nodes** are the atomic building blocks. Each type does one thing: display an image, handle physics, play audio, etc.
- **Scenes** are reusable trees of nodes, saved as `.tscn` files. They're Godot's fundamental unit of organization.
- The **scene tree** is the runtime hierarchy of all nodes currently in the game.
- The **Inspector** lets you edit any node's properties.
- **`res://`** is the path prefix for project files.
- For pixel art: set a small viewport size, use `canvas_items` stretch mode, and set texture filter to `Nearest`.

## What You Should See

When you press F5, you should see:
- A 1280x720 window opens
- The Godot icon (or your placeholder sprite) appears, with crisp pixel rendering
- The background is a default gray/blue color

If the sprite looks blurry, double-check that **Default Texture Filter** is set to `Nearest` in Project Settings. If you see a blank window with no sprite, make sure the **Main Scene** is set correctly (Project → Project Settings → Application → Run → Main Scene should be `res://main.tscn`).

## Next Module

We have a project, a scene, and a sprite, but it just sits there. In **Module 2: GDScript for Programmers**, we'll attach a script and make that sprite move with keyboard input. You'll learn GDScript's syntax, Godot's virtual function system, and the Input Map, the tools you'll use in every module that follows.


---

<!-- Source: 02_gdscript_for_programmers.md -->

# Module 2: GDScript for Programmers

## What We Have So Far

A Godot project called Crystal Saga with a single scene containing a Sprite2D, configured for pixel-perfect rendering.

## What We're Building This Module

A script attached to our sprite that responds to keyboard input and moves around the screen. Along the way, we'll learn GDScript's syntax, Godot's virtual function system, and how input works.

## GDScript at a Glance

This module assumes you already know how to program. The goal is not to teach variables, loops, or functions from scratch; it is to give you the GDScript and Godot-specific deltas that matter when you start attaching behavior to nodes.

GDScript is Godot's built-in scripting language. It looks like Python, but it is a separate language with engine-aware features: typed node references, exported Inspector properties, virtual callbacks, signals, Resources, and autoload access.

Here's a quick taste:

```gdscript
extends Sprite2D

var speed: float = 200.0
var health: int = 100

func _ready() -> void:
    print("Hello from Crystal Saga!")

func _process(delta: float) -> void:
    if health <= 0:
        print("Game over!")
```

The important deltas:

- **One script extends one Godot class.** `extends Sprite2D` means the script is the behavior for a `Sprite2D` node.
- **Static typing is optional but required in this series.** Use explicit types for public APIs, exports, onready variables, and function signatures.
- **Virtual callbacks are engine entrypoints.** Godot calls `_ready()`, `_process(delta)`, `_physics_process(delta)`, `_unhandled_input(event)`, and similar methods for you.
- **Node paths are runtime references.** `$ChildNode` is shorthand for `get_node("ChildNode")`; use `@onready` so the child exists before you cache it.
- **Editor and runtime are connected.** `@export` makes a variable editable per scene instance in the Inspector.

> **See:** [GDScript reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html), the complete language reference covering syntax, types, and features.

## Creating and Attaching a Script

We'll add behavior to our Sprite2D from Module 1.

1. Open your `main.tscn` scene.
2. Select the `Sprite2D` node in the scene tree.
3. Click the **Attach Script** button (the scroll icon with a green `+` at the top of the scene dock), or right-click the node and choose **Attach Script**.
4. In the dialog that appears:
   - **Language:** GDScript
   - **Path:** `res://sprite_2d.gd` (default is fine for now)
   - **Template:** Default
5. Click **Create**.

The editor switches to the **Script** workspace, showing your new script:

```gdscript
extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
```

This template gives us the two most important virtual functions. Here's what they do.

## Virtual Functions: `_ready()` and `_process()`

Godot doesn't ask you to write a game loop or manage update timing. Instead, it calls specific functions on your scripts at specific moments. These are called **virtual functions** (or callbacks).

### `_ready()`

Called **once**, when the node and all its children have entered the scene tree. This is where you initialize things: set starting values, cache references to other nodes, connect signals.

```gdscript
func _ready() -> void:
    print("I'm alive! My position is: ", position)
```

Try it now: replace the `pass` in `_ready()` with that print line, save the script, and press F5. You should see the message appear in the **Output** panel at the bottom of the editor. Stop the game (F8) and continue.

### `_process(delta)`

Called **every frame**, typically 60 times per second (or more, depending on the display). The `delta` parameter is the time in seconds since the last frame. This is where you handle movement, input, animation updates, and anything that needs to happen continuously.

Why `delta`? Because frame rates vary. If your game runs at 60 FPS on one machine and 30 FPS on another, moving 5 pixels per frame would make the player move twice as fast on the faster machine. By multiplying movement by `delta`, you make motion **frame-rate independent**:

```gdscript
func _process(delta: float) -> void:
    # Without delta: moves 5 pixels per frame (speed depends on FPS)
    # position.x += 5

    # With delta: moves 200 pixels per second (consistent regardless of FPS)
    position.x += 200.0 * delta
```

> **See:** [Idle and physics processing](https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html), which explains `_process()`, `_physics_process()`, and when to use each.

There's also **`_physics_process(delta)`**, which is called at a fixed rate (60 times per second by default, regardless of frame rate). We'll use this in Module 3 when we add physics-based movement. For now, `_process()` is all we need.

> **See:** [Overridable functions](https://docs.godotengine.org/en/stable/tutorials/scripting/overridable_functions.html), the full list of virtual functions Godot provides, including `_enter_tree()`, `_exit_tree()`, and `_input()`.

## Types and Data Shapes

GDScript supports dynamic typing, but we use static typing throughout the tutorial because the editor can catch API mismatches while you are wiring scenes together. That matters more than the syntax itself: most Godot bugs in this series come from the wrong node, Resource, or Dictionary shape crossing a boundary.

### Declaring Variables

```gdscript
# Explicit type annotation (our preferred style)
var speed: float = 200.0
var player_name: String = "Aiden"
var health: int = 100
var is_alive: bool = true

# Type inference with := (the type is inferred from the value)
var speed := 200.0          # float
var player_name := "Aiden"  # String

# No type (dynamic typing, works but we avoid it)
var speed = 200.0  # could be anything
```

### Common Engine Types

| Type | Example | Notes |
|------|---------|-------|
| `int` | `42` | Whole numbers |
| `float` | `3.14` | Decimal numbers |
| `bool` | `true`, `false` | |
| `String` | `"hello"` | Use double quotes |
| `Vector2` | `Vector2(10, 20)` | 2D position/direction (you'll use this *constantly*) |
| `Array[T]` | `[1, 2, 3]` | Ordered list; use typed arrays when the element type is known |
| `Dictionary` | `{hp = 100}` | Key-value pairs; useful for command payloads and save data |
| `NodePath` | `^"Sprite2D"` | Serialized path to a node |
| `Resource` | `load("res://data/items/potion.tres")` | Data asset loaded from disk |

### Constants

```gdscript
const MAX_SPEED: float = 300.0
const PLAYER_NAME: String = "Aiden"
```

Constants use `UPPER_SNAKE_CASE` and cannot be changed after declaration.

## Functions and Boundaries

```gdscript
# A function with parameters and a return type
func calculate_damage(attack: int, defense: int) -> int:
    return max(1, attack - defense)

# A function that returns nothing (void)
func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        die()

# A function with a default parameter
func heal(amount: int = 10) -> void:
    health = min(health + amount, max_health)
```

Notice the return type annotation (`-> int`, `-> void`). In tutorial code, a function's return type is part of its contract: if `remove_item()` returns `bool`, callers should be able to trust that `false` means nothing changed.

## Control Flow Differences

The syntax is familiar, but a few details are worth locking in:

```gdscript
# If / elif / else
if health <= 0:
    print("Dead")
elif health < 20:
    print("Critical!")
else:
    print("Fine")

# For loops
for i in range(5):          # 0, 1, 2, 3, 4
    print(i)

for item in inventory:      # iterate over an array
    print(item.name)

# While loops
while health > 0:
    health -= 1

# Match (like switch/case)
match direction:
    "up":
        velocity.y = -speed
    "down":
        velocity.y = speed
    _:
        velocity = Vector2.ZERO  # default case
```

The `match` statement routes behavior when a value can be one of several named options. That becomes important when we build state machines in Module 6 and battle command dispatch in Module 15.

> **Note:** GDScript uses `and`, `or`, and `not` instead of `&&`, `||`, and `!`. Both work, but `and`/`or`/`not` are the idiomatic choice and what we'll use throughout.

## The `@export` and `@onready` Annotations

These two annotations are GDScript-specific and very handy.

### `@export`: Edit in the Inspector

Think about Dragon Quest's towns. Every NPC shares the same basic behavior (stand in place, say a line of dialogue when you talk to them) but each one says something different. Without `@export`, you would need a separate script for every NPC: `guard_npc.gd`, `baker_npc.gd`, `child_npc.gd`, dozens of nearly identical files that differ only in their dialogue text. With `@export`, you write one `npc.gd` script and set each NPC's dialogue, name, and portrait directly in the editor. One script, dozens of unique characters.

`@export` exposes a variable in the Inspector panel, so you can tweak it per-instance without editing code:

```gdscript
@export var speed: float = 200.0
@export var player_name: String = "Aiden"
```

After adding these, select the node in the editor and look at the Inspector. You'll see `Speed` and `Player Name` as editable fields. This is how we'll customize NPCs, items, and other game objects without writing separate scripts for each one.

### `@onready`: Cache Node References

In a JRPG battle scene like Chrono Trigger's, you might update the HP bar, the character sprite, and the status icons every single frame, potentially hundreds of node lookups per second. Each `get_node()` call walks the scene tree by name, which is slow compared to using a cached reference. `@onready` grabs the reference once when the node loads and stores it in a variable, so every subsequent access is instant. It also guarantees the reference is valid; without it, you might try to grab a child node before it exists and get a null crash at startup.

`@onready` initializes a variable when `_ready()` is called, which is when the node tree is guaranteed to be built:

```gdscript
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $UI/HealthBar
```

The `$` operator is shorthand for `get_node()`. `$Sprite2D` means "find the child node named Sprite2D." `$UI/HealthBar` means "find the child named UI, then find its child named HealthBar."

> **Warning:** If you try to access `$Sprite2D` in a plain `var` declaration (outside `@onready`), it will fail because the node tree hasn't been built yet when `var` initializers run. Always use `@onready` for node references.

There's also `%UniqueName`, which finds a node by its **unique name** regardless of where it is in the tree. We'll use this later for UI elements that need to be found from anywhere.

## Input: Making Things Move

Now for the fun part: making our sprite respond to keyboard input.

### The Input Map

When Undertale launched, players immediately wanted to rebind controls. Some preferred WASD, others used gamepads, and accessibility needs varied. If Toby Fox had hard-coded "check if the Z key is pressed" throughout the codebase, adding gamepad support would have meant hunting down every key check and adding a parallel gamepad check beside it. Input actions solve this by putting a name between your code and the physical keys.

Godot doesn't check for raw key codes directly (though it can). Instead, it uses **actions**, named inputs that can be mapped to multiple keys, buttons, or axes. This means your game automatically works with both keyboard and gamepad without extra code.

The default project includes several built-in actions:

| Action | Default Keys |
|--------|-------------|
| `ui_up` | Arrow Up |
| `ui_down` | Arrow Down |
| `ui_left` | Arrow Left |
| `ui_right` | Arrow Right |
| `ui_accept` | Enter, Space |
| `ui_cancel` | Escape |

You can view and edit these in **Project → Project Settings → Input Map**.

> **Note:** The `ui_*` actions only map to arrow keys by default; WASD is **not** included. To add WASD support: open **Project → Project Settings → Input Map**, find `ui_up`, click the **+** button next to it, press **W**, and click **OK**. Repeat for `ui_down` (S), `ui_left` (A), and `ui_right` (D). Now both arrow keys and WASD will work.

> **Note:** `Input` is a Godot-provided global singleton. In Module 7, we will create our own project autoload, which is a script or scene Godot registers under `/root` for the lifetime of the game. Both are globally accessible by name, but engine singletons and project autoloads are different mechanisms.

### Checking Input

There are several ways to check input. The most common:

```gdscript
# Is the action currently held down? (returns true every frame it's held)
Input.is_action_pressed("ui_up")

# Was the action just pressed this frame? (returns true for one frame only)
Input.is_action_just_pressed("ui_accept")

# Was the action just released this frame?
Input.is_action_just_released("ui_accept")

# Get a value between -1 and 1 for an axis (useful for analog sticks)
Input.get_axis("ui_left", "ui_right")
```

> **See:** [Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html), the official tutorial covering input handling patterns.

### Moving the Sprite

Replace the contents of `sprite_2d.gd` with:

```gdscript
extends Sprite2D

@export var speed: float = 200.0


func _process(delta: float) -> void:
    var direction := Vector2.ZERO

    if Input.is_action_pressed("ui_right"):
        direction.x += 1.0
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1.0
    if Input.is_action_pressed("ui_down"):
        direction.y += 1.0
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1.0

    # Normalize to prevent faster diagonal movement
    if direction != Vector2.ZERO:
        direction = direction.normalized()

    position += direction * speed * delta
```

Here's what each part does:

1. **`var direction := Vector2.ZERO`**: We start with no movement. `Vector2.ZERO` is `Vector2(0, 0)`.
2. **Input checks**: We check each direction independently. Using `if` (not `elif`) allows diagonal movement.
3. **`direction.normalized()`**: Without this, moving diagonally would be ~41% faster than moving horizontally or vertically (because the diagonal of a unit square is √2 ≈ 1.414). Normalizing makes the vector length exactly 1 in all directions.
4. **`position += direction * speed * delta`**: Move the sprite by `speed` pixels per second in the input direction, scaled by `delta` for frame-rate independence.

Save the script and press F5. Use the arrow keys to move the sprite around (or WASD if you added those bindings above). The Godot icon slides smoothly across the screen.

> **JRPG Pattern:** This is "free movement," where the character moves smoothly in any direction. Some JRPGs use "grid-based movement" instead, where the character snaps from tile to tile. We'll discuss this tradeoff in Module 6 and implement free movement for Crystal Saga.

## `print()` Debugging

The simplest debugging tool is `print()`. It outputs to the **Output** panel at the bottom of the editor.

```gdscript
func _ready() -> void:
    print("Game started!")
    print("Speed is: ", speed)
    print("Position: ", position)

func _process(delta: float) -> void:
    # This will flood the output, so use sparingly!
    # print("Frame! Delta: ", delta)
    pass
```

Other useful output functions:

```gdscript
print("Normal message")              # White text in Output
push_warning("Something seems off")  # Yellow warning
push_error("Something broke!")        # Red error (doesn't crash)
printerr("Also an error")            # Error output
```

> **Warning:** Don't leave `print()` calls inside `_process()` in production code. Printing 60+ messages per second will slow your game down. Use them for debugging, then remove them.

## The Script Editor

A few tips for working in Godot's built-in script editor:

- **Ctrl+Click** on a function or variable name to jump to its definition.
- **F1** opens the built-in documentation search. Type any class name to see its full API.
- **Ctrl+Shift+D** duplicates the current line.
- **Ctrl+/** toggles comment on the selected lines.
- **Ctrl+Space** triggers autocompletion.

The built-in docs (F1) are very thorough. When you look up `Sprite2D`, you'll see every property, method, and signal the class has. We'll refer to these frequently.

## Common Gotchas

If you're coming from another language, watch for these:

### From Python
- GDScript is **not Python**. Many things look similar but work differently under the hood.
- GDScript has a `self` keyword, but you rarely need it. Member variables are accessed directly without it (`health`, not `self.health`). `self` exists for disambiguation when a local variable shadows a member variable.
- Dictionaries use `{"key": value}` syntax (with colons), not `{key: value}` without quotes (though GDScript also supports the `{key = value}` form).

### From JavaScript/TypeScript
- **Indentation matters.** Inconsistent tabs/spaces will cause errors.
- No semicolons. No braces for blocks.
- `null` is called `null` (same as JS), but types often use specific "empty" values like `Vector2.ZERO` or `""`.

### From C#/Java
- No class declarations; each `.gd` file is implicitly a class.
- `extends` instead of `: BaseClass` or `extends BaseClass`.
- No access modifiers (`public`, `private`). By convention, prefix private members with `_` (e.g., `_internal_var`).
- Arrays and dictionaries are dynamic, with no generics syntax (though typed arrays exist: `Array[int]`).

### Universal
- **Tabs for indentation**, not spaces. Godot enforces this by default.
- **Double quotes** for strings (single quotes work but double is convention).
- **Two blank lines** between functions. One blank line between logical sections within a function.

> **See:** [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html), the official style conventions for GDScript code.

## Putting It Together: A Complete First Script

Replace our movement code with a cleaner version. Copy this complete script into `sprite_2d.gd`, **replacing everything** that was there:

```gdscript
extends Sprite2D
## A simple movable sprite, our first step toward a player character.

@export var speed: float = 200.0


func _ready() -> void:
    print("Crystal Saga: sprite loaded at ", position)


func _process(delta: float) -> void:
    var direction := _get_input_direction()

    if direction != Vector2.ZERO:
        direction = direction.normalized()

    position += direction * speed * delta


func _get_input_direction() -> Vector2:
    return Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down"),
    )
```

Notice two improvements:

1. **`Input.get_axis()`**: This is a cleaner way to get directional input. It returns a float between -1 and 1, handling both keyboard and analog sticks automatically. We replaced four `if` blocks with a single `Vector2`.

2. **Extracted `_get_input_direction()`**: The input logic is now in its own function. The `_` prefix signals that it's a private helper. This is a habit worth building early; small functions with clear names make your code much easier to read and modify.

> **See:** [InputEvent](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html), a deep dive into Godot's input event system, including how events propagate through the scene tree.

## What We've Learned

- **GDScript** is Godot's scripting language, with Python-like syntax designed for game development.
- **Static typing** (`var x: int = 5`) catches bugs early and enables better autocompletion.
- **`_ready()`** runs once when the node enters the scene. **`_process(delta)`** runs every frame.
- **`delta`** makes movement frame-rate independent. Always multiply speed by `delta`.
- **Input actions** abstract away raw keys. `Input.is_action_pressed("ui_right")` works with keyboard and gamepad.
- **`Input.get_axis()`** is a clean way to get -1/0/1 directional input.
- **`@export`** exposes variables in the Inspector. **`@onready`** caches node references safely.
- **`$NodeName`** finds child nodes by path.
- **`print()`** is your basic debugging tool.

## Engineering Contract

- **New artifact:** `res://sprite_2d.gd`
- **Public editor surface:** exported `speed: float`
- **Runtime contract:** `_process(delta)` moves the sprite by pixels per second, not pixels per frame
- **Failure behavior:** bad node paths and type mismatches surface in the editor or Output panel
- **Boundary rule:** input is read through named actions, not raw key codes

## Engine Gotcha

`@onready` variables are initialized during `_ready()`. Plain member variable initializers run earlier, before child nodes are guaranteed to exist, so do not cache `$ChildNode` references without `@onready`.

## What You Should See

When you press F5:
- The sprite responds to arrow keys (and WASD if you added those bindings)
- Movement is smooth and consistent
- Diagonal movement is the same speed as cardinal movement (thanks to `normalized()`)
- The Output panel shows the startup print message

## Next Module

We have a moving sprite, but it's just a floating icon. In **Module 3: Thinking in Scenes**, we'll build a proper Player scene with collision physics, learn when to use `CharacterBody2D` vs other body types, and understand scene composition, the architectural principle that makes complex games manageable.


---

<!-- Source: 03_thinking_in_scenes.md -->

# Module 3: Thinking in Scenes

## What We Have So Far

A project with a Sprite2D that moves with keyboard input. But it's just a floating image: no collision, no physics, and if we wanted two players, we'd have to duplicate everything manually.

## What We're Building This Module

A proper Player **scene**, a reusable, self-contained character with physics-based movement and collision. We'll also learn the most important architectural principle in Godot: **scene composition**.

## Why Scenes, Not Scripts

In many engines, you think in terms of scripts: "I need a player script, an enemy script, a bullet script." In Godot, you think in terms of **scenes**: "I need a player scene, an enemy scene, a bullet scene."

A scene is a saved tree of nodes. It's a `.tscn` file on disk. When you instance a scene into another scene, it appears as a single node with its entire internal structure hidden. This means:

- The Player scene handles its own movement, animation, and collision. The Town scene just says "put a Player here."
- You can test each scene in isolation. Press F6 to run just the Player scene and verify it works before putting it in a level.
- Changes to the Player scene propagate everywhere it's instanced. Fix a bug once, and it's fixed in every level.

This is **composition over inheritance**, Godot's core design principle. It's what keeps complex games manageable.

> **See:** [Nodes and scene instances](https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html), the official guide to instancing scenes and thinking compositionally.

## Physics Bodies: Choosing the Right One

Before we build the Player scene, we need to understand the three types of physics bodies in Godot 2D. Each serves a different purpose:

### CharacterBody2D

A body you control directly with code. It moves where you tell it, and it handles collision detection and response through `move_and_slide()`. **This is what we use for the player character and NPCs.**

Use when: You want full control over movement. The character doesn't bounce or get pushed; you decide exactly how it responds to collisions.

For NPCs, choose based on intent. A shopkeeper who never moves can be a `StaticBody2D` with an `Area2D` interaction zone. An NPC who may walk, turn, join the party, or participate in cutscenes should be a `CharacterBody2D`. We use `CharacterBody2D` for actors that might later need movement behavior.

### RigidBody2D

A body governed by Godot's physics engine. It has mass, friction, and responds to forces. It bounces off walls, gets pushed by other bodies, and is affected by gravity.

Use when: You want realistic physics: a rolling boulder, a falling crate, a bouncing ball.

### StaticBody2D

A body that never moves. It exists purely for other bodies to collide with.

Use when: You need invisible walls, floors, or barriers. (In practice, we'll use TileMap collision instead, but the concept is the same.)

### Area2D

Not technically a physics body. It's a **detection zone**. It doesn't block movement; it detects when other bodies enter or exit it. We'll use these extensively for exit zones, interaction triggers, and encounter regions.

> **See:** [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html), which covers all body types, collision layers, and physics concepts.

For our player character, **CharacterBody2D** is the right choice. It gives us pixel-perfect collision without the unpredictability of a physics simulation. JRPGs need precise, deterministic movement, not bouncy physics.

## Building the Player Scene

We'll create a proper Player scene that we can reuse throughout the game.

### Step 1: Create a New Scene

1. Go to **Scene → New Scene** (or press `Ctrl+N`).
2. Click **Other Node** in the Scene dock.
3. Search for `CharacterBody2D` and create it.
4. Rename it to `Player`.
5. In the Inspector, find **Motion Mode** and set it to **Floating**. (The default, Grounded, is for side-scrollers. Floating is correct for top-down games because it disables floor/wall/ceiling logic.)

### Step 2: Add Child Nodes

With `Player` selected, add these children (click `+` or press `Ctrl+A`):

1. **Sprite2D**, for displaying the character's image
2. **CollisionShape2D**, for defining the collision hitbox

Your scene tree should look like:

```
Player (CharacterBody2D)
├── Sprite2D
└── CollisionShape2D
```

### Step 3: Configure the Sprite

Select the `Sprite2D` node. In the Inspector, set the **Texture** to `icon.svg` (the Godot logo; we'll replace this with real character art in Module 6).

### Step 4: Configure the Collision Shape

Select the `CollisionShape2D` node. In the Inspector:
1. Click the **Shape** property (currently `<empty>`).
2. Select **New RectangleShape2D**.
3. In the viewport, you'll see a blue rectangle. Drag its handles to roughly match the size of the sprite.

Alternatively, set the shape's **Size** in the Inspector to match your sprite dimensions. For the Godot icon, `Vector2(64, 64)` works. (We'll resize this to something much smaller in Module 5 when we switch to 16x16 tile-based environments.)

> **Warning:** A CollisionShape2D with no shape assigned will show a yellow warning triangle in the scene tree. Always assign a shape; otherwise, your CharacterBody2D can't detect collisions.

### Step 5: Save the Scene

Save as `res://player/player.tscn`. Create the `player` folder first: right-click in the **FileSystem** dock and choose **New Folder**, name it `player`. Keeping scenes organized in folders is a habit worth building now.

> **Note:** The convention is to name folders and files in `snake_case`. The scene file and its primary script should share a name: `player.tscn` and `player.gd`.

## `move_and_slide()`: Physics-Based Movement

In Module 2, we moved the sprite by directly modifying `position`. That works for a floating image, but it ignores collisions entirely; the sprite would pass through walls. `CharacterBody2D` gives us `move_and_slide()`, which moves the body and automatically handles collisions.

Attach a new script to the Player node. Save it as `res://player/player.gd`:

```gdscript
extends CharacterBody2D
## The player character. Handles input-based movement with collision.

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

This looks similar to our Module 2 script, but with key differences:

### `_physics_process()` instead of `_process()`

We switched from `_process()` to `_physics_process()`. Here's why:

- **`_process(delta)`** runs every *rendering* frame. The rate varies based on GPU load and display refresh rate.
- **`_physics_process(delta)`** runs at a *fixed* rate, 60 times per second by default, regardless of frame rate.

For physics-based movement (anything using `move_and_slide()`), always use `_physics_process()`. It ensures consistent collision detection. If physics runs at variable rates, objects can clip through walls during frame rate drops.

> **See:** [Idle and physics processing](https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html), which explains the difference in depth and when to use each.

### `velocity` and `move_and_slide()`

`CharacterBody2D` has a built-in `velocity` property (a `Vector2`). We set it to our desired direction × speed, then call `move_and_slide()`. This function:

1. Moves the body along the velocity vector
2. Detects collisions
3. Slides along surfaces instead of stopping dead
4. Automatically handles `delta` internally (which is why we don't multiply by `delta` ourselves)

> **Note:** `move_and_slide()` handles delta time internally. You set `velocity` in pixels per second, and the method figures out how far to move this physics tick. Don't multiply by `delta` when setting `velocity` for `move_and_slide()`.

> **See:** [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html), the full API reference for the class, including all properties and methods.

## Instancing the Player into a Scene

Now we need a scene to put our Player in. Go back to `main.tscn`:

1. Open `main.tscn`.
2. Delete the old `Sprite2D` node (select it, press **Delete** or right-click → **Delete Node**). Also delete the `sprite_2d.gd` file from the **FileSystem** dock (right-click → **Delete**). We won't need it anymore.
3. You should have just the `Main` (Node2D) root.
4. Drag `player/player.tscn` from the FileSystem dock into the viewport, or right-click `Main` and choose **Instance Child Scene** and select `player.tscn`.

Your scene tree now shows:

```
Main (Node2D)
└── Player (player.tscn instance)
```

Notice that the Player node has a little "link" icon, which indicates it's an **instance** of another scene. If you click the arrow next to it, you can expand it to see its children (Sprite2D, CollisionShape2D), but they're grayed out because they belong to the instanced scene.

Press F5. You should be able to move around, but there's nothing to collide with yet. We'll add walls in Module 5 when we build the tilemap.

## The Scene Tree at Runtime

When the game runs, every node exists in a single **scene tree**. The tree has a root (always called `root`), and everything branches from there:

```
root (Window)
└── Main (Node2D)
    └── Player (CharacterBody2D)
        ├── Sprite2D
        └── CollisionShape2D
```

You can navigate this tree in code:

```gdscript
# From any node, get the scene tree:
get_tree()

# Get the root:
get_tree().root

# Get a specific node by path:
get_node("/root/Main/Player")

# Get the parent of the current node:
get_parent()

# Get a child by name (shorthand with $):
$Sprite2D          # same as get_node("Sprite2D")
$"Long Node Name"  # use quotes for names with spaces
```

> **See:** [Scene tree](https://docs.godotengine.org/en/stable/tutorials/scripting/scene_tree.html), covering how the scene tree works at runtime, including node ordering and groups.

## Signals: A First Look

Signals are Godot's event system, a way for nodes to communicate without knowing about each other. A node emits a signal ("something happened"), and other nodes can connect to it ("when that happens, run this function").

Here's a simple example. Add an **Area2D** node to `main.tscn`:

1. Select the `Main` node.
2. Add a child **Area2D** node. Rename it to `TestZone`.
3. Add a **CollisionShape2D** as a child of `TestZone`.
4. Set the shape to a `RectangleShape2D` and make it reasonably large (e.g., 100x100 pixels).
5. Position it somewhere the player will walk into.

Before connecting the signal, the `Main` node needs a script. Right-click `Main` in the Scene dock and choose **Attach Script**. Accept the defaults (path: `res://main.gd`) and click **Create**.

Now connect the Area2D's signal:

1. Select the `TestZone` (Area2D) node.
2. Click the **Node** tab (right side of the editor, next to the Inspector tab; it has a signal icon).
3. Find `body_entered(body: Node2D)` in the signal list.
4. Double-click it. A connection dialog appears.
5. Select the `Main` node as the receiver and click **Connect**.

Godot creates a function in `Main`'s script:

```gdscript
func _on_test_zone_body_entered(body: Node2D) -> void:
    print("Something entered the zone: ", body.name)
```

Run the game and walk into the zone. The output panel prints the player's name. The Area2D detected the collision and told the Main node about it, without either node knowing the other's internal details.

> **Note:** This works because both the Player (CharacterBody2D) and the TestZone (Area2D) are on collision layer 1 by default. If `body_entered` doesn't fire, check that both nodes share a collision layer: select the node, expand **Collision** in the Inspector, and verify that at least one **Layer** bit matches the other node's **Mask** bit. All nodes default to layer 1 and mask 1, so this works out of the box. You only need to change layers when you want certain objects to ignore each other (e.g., letting projectiles pass through walls but hit enemies).

Once you've tested the signal, you can delete the `TestZone` node from `main.tscn`. It was just for learning. We won't need it going forward.

This is the signal pattern we'll use throughout Crystal Saga:
- Exit zones signal "the player wants to leave" → the SceneManager handles the transition (Module 7)
- NPCs signal "interaction started" → the dialogue system displays text (Module 11)
- The battle system signals "turn started" → the UI updates (Module 14)

### Signal Auto-Disconnection

An important detail: when a node is **freed** (removed from the tree and deleted), all signal connections involving that node are automatically cleaned up. You don't need to manually disconnect signals in most cases.

This matters when we start changing scenes in Module 7. When we leave a town and enter a forest, all the town's nodes are freed, and all their signal connections disappear cleanly. No dangling references, no crashes.

> **See:** [Instancing with signals](https://docs.godotengine.org/en/stable/tutorials/scripting/instancing_with_signals.html), which connects scene instancing with signal-based communication.

## Scene Files: `.tscn` Under the Hood

Scene files (`.tscn`) are plain text. You can open one in any text editor. Here's a simplified look at what `player.tscn` might contain:

```ini
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://player/player.gd" id="1"]
[ext_resource type="Texture2D" path="res://icon.svg" id="2"]

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1")
speed = 200.0

[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
shape = SubResource("RectangleShape2D_abc12")
```

You almost never need to edit these by hand, but knowing they're text files is useful:
- They diff well in version control (git).
- You can search for specific values if something seems wrong.
- Merge conflicts in `.tscn` files are manageable (if ugly).

## Organizing Your Project

Now is a good time to establish a folder structure. Here's the layout we'll use for Crystal Saga, growing as we add systems:

```
CrystalSaga/
├── project.godot         # Project configuration
├── icon.svg              # Default icon (we'll replace later)
├── player/
│   ├── player.tscn       # Player scene
│   └── player.gd         # Player script
└── main.tscn             # Test scene (will become our first level)
```

The pattern: **each "thing" gets a folder with its scene and script(s).** As the project grows, we'll add `npcs/`, `ui/`, `scenes/`, `resources/`, `autoloads/`, and more.

## What We've Learned

- **Scenes** are reusable node trees saved as `.tscn` files. They're Godot's primary organizational unit.
- **Scene composition**: complex behavior comes from combining simple, focused nodes, not from one monolithic script.
- **CharacterBody2D** is for player-controlled characters. **RigidBody2D** is for physics-driven objects. **Area2D** is for detection zones.
- **`move_and_slide()`** handles movement and collision response. Use it in `_physics_process()`.
- **`_physics_process()`** runs at a fixed rate for consistent physics. **`_process()`** runs every rendering frame.
- **Signals** let nodes communicate without tight coupling. `body_entered` on Area2D detects when bodies enter a zone.
- Signal connections are **automatically cleaned up** when a node is freed.
- **Instancing** lets you place one scene inside another, keeping internals hidden.

## Engineering Contract

- **New artifact:** reusable `Player` scene and `player.gd`
- **Public editor surface:** player speed and collision shape
- **Runtime contract:** movement uses `CharacterBody2D.move_and_slide()` and the player joins the `player` group
- **Failure behavior:** if no collision shape exists, movement works visually but collision will not block walls
- **Boundary rule:** levels find the player by group, not by hard-coded scene path

## Engine Gotcha

`CharacterBody2D` does not move automatically when you set `velocity`; you must call `move_and_slide()` during physics processing. For stationary collision, prefer `StaticBody2D` instead of writing a no-op movement body.

## What You Should See

When you press F5:
- The player (Godot icon) moves with arrow keys (and WASD if you added those bindings in Module 2)
- Walking into the TestZone prints a message in the Output panel
- The player moves smoothly with physics-based collision

## Next Module

We have a moving, collision-aware player, but the world is empty. In **Module 5: TileMaps and Terrain**, we'll build the town of Willowbrook using Godot's TileMapLayer system. We'll create a tileset from a sprite sheet, paint a multi-layered map, and give our player actual walls to bump into.


---

<!-- Source: 04_part_i_review.md -->

# Module 4: Part I Review and Cheat Sheet

This module is a review and quick-reference for everything covered in Part I (Modules 1-3). Come back to this page whenever you need to look something up without re-reading the full modules.

## Part I in Review

You started Part I with nothing: no engine installed, no project, no code. Module 1 walked you through installing Godot, creating the Crystal Saga project, and understanding the mental model behind the engine: everything is a node, and nodes compose into scenes. You placed a Sprite2D on screen, configured the project for pixel art, and ran your first build. The Godot icon on a gray background doesn't look like much, but it's what everything else builds from: a project, a scene, a node, and a working feedback loop (edit, save, run, observe).

Module 2 gave you the language. You attached a script to that sprite and learned GDScript from the perspective of someone who already knows how to program. You wrote variables with static types, defined functions with return annotations, and discovered the virtual function system that drives Godot's game loop: `_ready()` for initialization, `_process(delta)` for per-frame logic. You wired up keyboard input through the Input Map and made the sprite move. By the end, your placeholder icon responded to arrow keys, moved at a consistent speed regardless of frame rate, and printed debug messages to the Output panel.

Module 3 shifted from "scripts that move things" to "scenes that *are* things." You built a Player scene from a CharacterBody2D with a Sprite2D and CollisionShape2D as children, learning why Godot favors composition over inheritance. You replaced direct position manipulation with `move_and_slide()`, switched from `_process()` to `_physics_process()`, and instanced the Player scene into your main scene. You also got your first taste of signals (Godot's decoupled event system) by connecting an Area2D's `body_entered` signal to a script function. The result: a reusable player character with physics-based movement that you can drop into any scene.

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
Player (CharacterBody2D)       <- root: handles movement and collision
├── Sprite2D                   <- displays the character image
└── CollisionShape2D           <- defines the hitbox
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

- `.tscn`: text scene file (human-readable, diffs well in git)
- `.tres`: text resource file
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

**The Input Map** (Project -> Project Settings -> Input Map) maps named actions to physical keys:

| Action | Default Key | To Add WASD |
|--------|------------|-------------|
| `ui_up` | Arrow Up | Add W |
| `ui_down` | Arrow Down | Add S |
| `ui_left` | Arrow Left | Add A |
| `ui_right` | Arrow Right | Add D |
| `ui_accept` | Enter, Space | default |
| `ui_cancel` | Escape | default |

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

**Module 2 pattern: direct position manipulation (no collision):**

```gdscript
extends Sprite2D

@export var speed: float = 200.0


func _process(delta: float) -> void:
    var direction := _get_input_direction()
    if direction != Vector2.ZERO:
        direction = direction.normalized()
    position += direction * speed * delta
```

**Module 3 pattern: physics-based movement with collision:**

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
| Viewport Width | Display -> Window -> Viewport Width | `640` | Internal rendering resolution |
| Viewport Height | Display -> Window -> Viewport Height | `360` | Internal rendering resolution |
| Window Width Override | Display -> Window -> Window Width Override | `1280` | Window size on screen (2x viewport) |
| Window Height Override | Display -> Window -> Window Height Override | `720` | Window size on screen (2x viewport) |
| Stretch Mode | Display -> Window -> Stretch -> Mode | `canvas_items` | Scales viewport to fill window |
| Texture Filter | Rendering -> Textures -> Default Texture Filter | `Nearest` | Keeps pixels sharp instead of blurry |
| Main Scene | Application -> Run -> Main Scene | `res://main.tscn` | Which scene runs when you press F5 |

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Texture filter left on `Linear` | Sprites look blurry and smudged when the game runs | Project Settings -> Rendering -> Textures -> Default Texture Filter -> set to `Nearest` |
| Accessing `$NodeName` outside `@onready` | Null reference error at startup; the node hasn't entered the tree yet | Use `@onready var sprite: Sprite2D = $Sprite2D` instead of a plain `var` |
| CollisionShape2D with no shape assigned | Yellow warning triangle on the node; CharacterBody2D cannot detect collisions | Select the CollisionShape2D, click its Shape property in the Inspector, and create a new shape (e.g., RectangleShape2D) |
| Using `_process()` with `move_and_slide()` | Inconsistent collision detection; objects may clip through walls at low frame rates | Switch to `_physics_process()` for any code that calls `move_and_slide()` |
| Multiplying `velocity` by `delta` before `move_and_slide()` | Movement is extremely slow (double-applying delta) | Set `velocity` in pixels per second directly; `move_and_slide()` handles delta internally |
| Not normalizing diagonal input | Diagonal movement is roughly 41% faster than cardinal movement | Call `direction.normalized()` when the direction vector is non-zero |
| Main scene not set | Pressing F5 shows a dialog asking which scene to run, or nothing happens | Project Settings -> Application -> Run -> Main Scene -> set to `res://main.tscn` |
| WASD keys don't work | Arrow keys work but WASD does nothing | Open Project Settings -> Input Map, find each `ui_*` action, click `+`, and bind the WASD key |

## Official Godot Documentation

Every class, method, and concept referenced in Part I, organized by category. Bookmark these; they're the official source of truth for anything not covered in this tutorial.

### Getting Started

- [Introduction to Godot](https://docs.godotengine.org/en/stable/getting_started/introduction/introduction_to_godot.html): engine overview and design philosophy
- [First look at the editor](https://docs.godotengine.org/en/stable/getting_started/introduction/first_look_at_the_editor_interface.html): editor panels and layout
- [Creating and importing projects](https://docs.godotengine.org/en/stable/getting_started/step_by_step/creating_and_importing_projects.html): project creation and the Project Manager
- [Nodes and Scenes](https://docs.godotengine.org/en/stable/getting_started/step_by_step/nodes_and_scenes.html): the core building blocks

### GDScript

- [GDScript basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html): complete language reference (syntax, types, features)
- [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html): official naming and formatting conventions
- [Overridable functions](https://docs.godotengine.org/en/stable/tutorials/scripting/overridable_functions.html): full list of virtual functions (`_ready`, `_process`, `_enter_tree`, etc.)

### Scripting and Architecture

- [Nodes and scene instances](https://docs.godotengine.org/en/stable/tutorials/scripting/nodes_and_scene_instances.html): instancing scenes, composition, and reuse
- [Scene tree](https://docs.godotengine.org/en/stable/tutorials/scripting/scene_tree.html): runtime hierarchy, node ordering, and groups
- [Idle and physics processing](https://docs.godotengine.org/en/stable/tutorials/scripting/idle_and_physics_processing.html): `_process()` vs `_physics_process()` and when to use each
- [Instancing with signals](https://docs.godotengine.org/en/stable/tutorials/scripting/instancing_with_signals.html): combining scene instancing with signal-based communication

### Input

- [Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html): input handling patterns and code samples
- [InputEvent](https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html): how input events propagate through the scene tree

### Physics

- [Physics introduction](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html): body types, collision layers, and physics concepts

### Class References

- [`Node`](https://docs.godotengine.org/en/stable/classes/class_node.html): base class for all nodes
- [`Node2D`](https://docs.godotengine.org/en/stable/classes/class_node2d.html): base class for 2D nodes (has `position`, `rotation`, `scale`)
- [`Sprite2D`](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html): displays a 2D texture
- [`CharacterBody2D`](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html): player-controlled physics body with `move_and_slide()`
- [`RigidBody2D`](https://docs.godotengine.org/en/stable/classes/class_rigidbody2d.html): physics-driven body with mass, friction, and forces
- [`StaticBody2D`](https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html): immovable collision body
- [`Area2D`](https://docs.godotengine.org/en/stable/classes/class_area2d.html): detection zone with `body_entered` / `body_exited` signals
- [`CollisionShape2D`](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html): defines collision boundaries for physics bodies and areas
- [`Camera2D`](https://docs.godotengine.org/en/stable/classes/class_camera2d.html): 2D camera that controls the viewport
- [`Label`](https://docs.godotengine.org/en/stable/classes/class_label.html): displays text on screen
- [`AudioStreamPlayer`](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer.html): plays audio
- [`AnimatedSprite2D`](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html): plays frame-based sprite animations
- [`TileMapLayer`](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html): renders a grid of tiles (mentioned, used in Part II)
- [`Vector2`](https://docs.godotengine.org/en/stable/classes/class_vector2.html): 2D vector used for positions, directions, and velocities
- [`Input`](https://docs.godotengine.org/en/stable/classes/class_input.html): global singleton for checking input state
- [`RectangleShape2D`](https://docs.godotengine.org/en/stable/classes/class_rectangleshape2d.html): rectangular collision shape

## What's Next

In **Part II: Building the World**, we'll put these foundations to work. Module 5 introduces TileMapLayers, and you'll build the town of Willowbrook as a multi-layered tile map with ground, paths, water, and collision walls your player character can actually bump into.


---

<!-- Source: 05_tilemaps_and_terrain.md -->

# Module 5: The Overworld: TileMaps and Terrain

## What We Have So Far

A Player scene (CharacterBody2D with sprite and collision) that moves with keyboard input and handles physics. But the world is empty, just a blank screen.

## What We're Building This Module

The town of **Willowbrook**, Crystal Saga's starting village. We'll build it using Godot's TileMapLayer system: painting ground, paths, buildings, and water onto a grid, with collision so the player can't walk through walls.

By the end, you'll have a real place to explore.

## How TileMaps Work: A Conceptual Model

Imagine drawing the entire overworld of Chrono Trigger as a single image. It would be enormous, impossible to edit without redrawing entire sections, and you could not add collision without manually painting invisible walls on top. Tilemaps solve all of this. Because every grass patch uses the same 16x16 tile, the game only stores that tile image once and stamps it across the map. Editing is fast: to widen a path, you repaint a few cells instead of redrawing a building. And collision is built in: you mark wall tiles as solid once, and every wall in the game blocks the player automatically. This is why nearly every 2D RPG from Final Fantasy to Stardew Valley uses tilemaps.

Before we touch any code, here's the core idea.

A tilemap is a grid of small images (tiles) assembled into a larger scene, like placing mosaic tiles to create a picture. Instead of drawing an entire town as one massive image, you draw it from reusable 16x16 or 32x32 pixel pieces: a grass tile, a path tile, a wall tile, a roof tile.

Think of it like transparent sheets stacked on top of each other:

```
Layer 4: AbovePlayer:  treetops, roof overhangs (drawn on top of the player)
Layer 3: Objects:      trees, rocks, signs, fences
Layer 2: Detail:       flowers, cracks, path borders
Layer 1: Ground:       grass, dirt, water
```

Each layer is a separate **TileMapLayer** node. The ground layer covers every tile. The detail layer has sparse decorations. The object layer has things the player walks behind. The above-player layer draws on top of everything, including the player.

This is exactly how professional 2D games are built, including most of the JRPGs you've played.

> **See:** [Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html), creating TileSet resources from tile sheets.

> **See:** [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html), painting tiles, configuring layers, and adding physics to tiles.

## TileMapLayer, not TileMap

You may see older tutorials reference a node called `TileMap`. That node is **deprecated** as of Godot 4.3. The replacement is `TileMapLayer`, one node per layer, instead of one node with multiple internal layers.

`TileMapLayer` is simpler to use and gives you direct control over each layer as an independent node in the scene tree. Each layer can have its own z-order, visibility toggle, and physics settings.

Throughout this tutorial, we always use `TileMapLayer`.

> **See:** [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html), the API reference for the current tilemap node.

## Getting a Tile Sheet

To build a tilemap, you need a **tile sheet**, an image file containing all your tiles arranged in a grid.

For this tutorial, we recommend **Kenney's Tiny Town pack**, a free, public-domain tileset that includes everything we need:

1. Go to [kenney.nl/assets/tiny-town](https://kenney.nl/assets/tiny-town) and click **Download**.
2. Extract the ZIP file.
3. In the extracted folder, find `tilemap_packed.png` (at the root of the ZIP, not in a subfolder).
4. Create a `tilesets` folder in your project: right-click in the **FileSystem** dock → **New Folder** → name it `tilesets`.
5. Copy `tilemap_packed.png` into `res://tilesets/` (drag it into the FileSystem dock, or copy it into the folder on disk).
6. Rename it to `town_tiles.png` if you like, or keep the original name.

This sheet contains grass, paths, water, walls, trees, buildings, and more, all in a 16x16 grid. It's everything we need for Willowbrook.

> **Alternatives:** If you can't download assets, you can create a minimal placeholder. Open any image editor, create a 80x16 PNG with five 16x16 colored squares: green (#4a7c3f) for grass, brown (#8b6914) for path, blue (#3b6bb5) for water, gray (#808080) for walls, and tan (#c4a882) for floor. Save as `res://tilesets/town_tiles.png`. You can replace it with real art later.

For Crystal Saga, we need at least these tile types:
- Grass (walkable ground)
- Path/dirt (walkable)
- Water (not walkable)
- Wall/building exterior (not walkable)
- Building interior floor (walkable)

> **JRPG Pattern:** Most classic JRPGs use 16x16 pixel tiles. Some use 32x32 for more detail. The choice affects the overall aesthetic. We'll use **16x16** tiles for an authentic retro feel. You can use 32x32 if you prefer a more detailed look.

## Creating the TileSet

A **TileSet** is a resource that tells Godot how to interpret your tile sheet: where each tile is, how big they are, and what properties they have (collision, animation, etc.).

### Step 1: Create the Town Scene

1. Create a new scene (Scene → New Scene).
2. Add a **Node2D** as the root. Rename it to `Willowbrook`.
3. Create the folder structure first: right-click in the **FileSystem** dock → **New Folder** → name it `scenes`. Then right-click `scenes` → **New Folder** → name it `willowbrook`. Save as `res://scenes/willowbrook/willowbrook.tscn`.

### Step 2: Add the First TileMapLayer

1. With `Willowbrook` selected, add a child **TileMapLayer** node.
2. Rename it to `Ground`.

### Step 3: Create a TileSet

1. Select the `Ground` node.
2. In the Inspector, find the **Tile Set** property.
3. Click it and choose **New TileSet**.
4. Click the TileSet resource to expand it in the **Inspector** (right panel). Find the **Tile Size** property and set it to `16x16` (or your tile size).

> **Warning:** You must set the tile size before creating an atlas source. If the tile size doesn't match your tile sheet's grid, Godot will slice the image incorrectly, and every tile coordinate will be wrong. Set it first, then add the atlas.

### Step 4: Create an Atlas Source

The TileSet panel appears at the bottom of the editor.

1. In the TileSet panel, click the **+** button to add a source.
2. Choose **Atlas**.
3. Drag your tile sheet image (`town_tiles.png`) into the **Texture** property.
4. Godot will ask if you want to **create tiles automatically**. Click **Yes**.

You should see your tile sheet with a grid overlay. Each grid cell is one tile, and Godot has created a tile entry for each one.

> **Note:** If Godot doesn't prompt you automatically, click the three-dot menu (⋮) in the TileSet panel and choose **Create Tiles in Non-Transparent Texture Regions**. If that option isn't available, make sure your Tile Size matches your tile sheet's grid.

> **Warning:** If the grid doesn't align with your tiles, double-check that the **Tile Size** in the TileSet matches your tile sheet's grid size. Misaligned grids are the #1 tileset setup problem.

### Step 5: Save the TileSet as an External Resource

If you leave the TileSet embedded in one layer, each additional layer gets its own separate copy. When you later add collision to a wall tile, you would have to add it in four separate TileSets (one per layer) and keeping them synchronized becomes a nightmare. Saving the TileSet as an external `.tres` file means all layers reference the same data. Change a tile's collision once, and it applies everywhere.

Right now, the TileSet is embedded inside the `Ground` node. We want to share it across multiple layers.

1. Click the dropdown arrow next to the TileSet property.
2. Choose **Save** (or **Save As**).
3. Save it to `res://tilesets/town_tileset.tres`.

Now we can assign this same TileSet to other TileMapLayer nodes.

## Setting Up Multiple Layers

Add three more TileMapLayer nodes as children of `Willowbrook`:

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── Objects (TileMapLayer)
└── AbovePlayer (TileMapLayer)
```

For each new layer:
1. Set the **Tile Set** property to your saved `town_tileset.tres` (drag it from the FileSystem dock or click Load).

The layers are drawn in tree order: `Ground` first (bottom), `AbovePlayer` last (top). The player sprite should render between `Objects` and `AbovePlayer`. We'll handle this with Y-sorting in Module 6.

### Why Four Layers?

| Layer | Purpose | Example Tiles |
|-------|---------|---------------|
| Ground | Covers every cell. The base terrain. | Grass, dirt, water, stone |
| Detail | Sparse decorations on top of ground. | Flowers, path edges, cracks |
| Objects | Things the player walks behind (lower half) or in front of (upper half). | Trees, rocks, fences, signs |
| AbovePlayer | Drawn on top of everything, including the player. | Treetop canopy, roof overhangs, bridge railings |

This layering creates depth. The player walks on the ground, behind trees, and under overhanging roofs, all without any complex rendering tricks.

## Painting Tiles

Now for the fun part. Select a TileMapLayer node and start painting:

1. Select the `Ground` layer in the scene tree.
2. The TileMap editor panel appears at the bottom of the screen.
3. Select a tile from the tile palette (your tile sheet is shown as a grid of clickable tiles).
4. Click or click-and-drag in the viewport to paint tiles.

### Painting Tools

The TileMap editor toolbar offers several painting tools. All of them work in the **2D viewport**, not in the TileSet panel itself. Select a tile from the palette, then paint in the viewport.

| Tool | What It Does | Shortcut |
|------|-------------|----------|
| Paint | Place one tile at a time (click or drag) | Default mode |
| Line | Draw a straight line of tiles between two points | Hold **Shift** while in Paint mode |
| Rectangle | Fill a rectangular area with one drag | Hold **Ctrl+Shift** while in Paint mode |
| Bucket Fill | Fill a contiguous region with the selected tile | Separate tool button |
| Eraser | Remove tiles | **Right-click** in any mode |
| Picker | Grab a tile from the viewport to use as your brush | Hold **Ctrl** and click in Paint mode |

The Line and Rectangle modes are temporary holds, not separate tool buttons. You stay in Paint mode and hold the modifier keys when you need them. This is faster than switching tools constantly.

**Selecting multiple tiles:** In the TileSet palette at the bottom, click and drag to select a rectangular group of tiles. When you paint with a multi-tile selection, the entire group is placed as one unit. This is how you place multi-tile objects like buildings, large trees, or decorative structures that span several cells.

**Randomization:** If you select multiple individual tiles (Shift+click in the palette), the Paint tool randomly picks one of them for each cell you paint. This is useful for ground variation — select three or four grass variants, then paint freely and the ground gets natural-looking variety without you placing each variant by hand.

**Scattering:** Set the Scattering value above 0 in the TileMap toolbar to randomly skip cells while painting. Treat this as a rough-in tool only. For Crystal Saga, final decoration should be hand-edited: a few flowers by a path, cracks near old stone, grass tufts where they make visual sense. Do not leave broad percentage-painted decoration in the finished map.

> **See:** [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html), the official guide covering all painting tools, randomization, scattering, and patterns.

### Building Willowbrook

This is the creative part. You're designing a town by painting tiles directly in the Godot editor — there's no "right answer" and no grid template to follow. Think about what a small starting village looks like in the JRPGs you've played: a few buildings connected by paths, some trees and natural features, and a clear exit leading to the next area.

**Design goals for Willowbrook:**

- **Paths** that connect buildings and lead to an exit on the south edge (the player will walk to the forest in Module 7)
- **Two or three buildings** (a shop, an inn, and an elder's house are enough for now)
- **Some water** on one side — a pond or a stream running along an edge
- **Trees** around the perimeter to create natural boundaries and make the town feel nestled in the surrounding wilderness
- **Open space** — don't fill every cell. Leave room for the player to walk around, and leave some grass visible. Real towns have empty space.

**If you've never designed a tilemap before,** here's a starter layout to work from. You can modify it freely; the goal is to give you a concrete starting point rather than a blank canvas:

```
Key: . = grass, # = path, W = water, T = tree, B = building, _ = exit

          North
    T T T T T T T T T T
    T . . . B B . . . T
    T . . . # # . . . T
    T . B B # # . . . T
    T . . . # # B B . T
    T . . . # # . . . T
    T W W . # # . . . T
    T W W . # # . . . T
    T . . . # # . . . T
    T T T T _ _ T T T T
          South (exit)
```

Place buildings as 2x2 or 3x2 clusters of wall/roof tiles. The path runs north-south through town, with branches to each building. Water sits in the west. Trees ring the perimeter. The south edge has a gap for the exit to the forest (Module 7).

**Paint it layer by layer:**

1. **Ground layer first.** Select the `Ground` layer in the scene tree. Pick a grass tile from the palette. Use **Bucket Fill** to cover a generous area (around 30x20 tiles or larger — you can always shrink it later). Now switch to the **Paint** tool, select a path or dirt tile, and paint the paths by hand. Drag them in natural shapes: a main road through town, a few branches to the buildings. Add water tiles along one edge. Press **F6** to run the scene and walk around. Adjust until it feels like a good size — not so small that it's cramped, not so large that it's empty.

2. **Objects layer.** Select the `Objects` layer. Paint buildings as rectangular clusters of wall and roof tiles. Place trees around the edges and between buildings. Add fences, signs, or rocks where they make sense. Use **Ctrl+click** (Picker) to grab tiles from the viewport when you want to reuse something you already placed. If your tile sheet has multi-tile objects (like a 2x2 tree), select all the tiles as a group in the palette and place them together.

3. **Detail layer.** Select the `Detail` layer. This is for the finishing touches: flowers along paths, cracks in stone, grass variations over the base ground, path border tiles that soften the edge between dirt and grass. **Keep it sparse and intentional.** Place a few details where the player's eye should go. If you use Scattering to sketch ideas, immediately hand-edit the result so the final map does not look sprayed on.

4. **AbovePlayer layer.** If you have treetop canopy tiles or roof overhangs, place them on this layer. Anything here draws on top of the player sprite, which creates the illusion of walking under trees or into doorways.

After each layer, press **F6** to run and walk around. Does it look right? Is there enough room to move? Are the buildings visible? Adjust as you go.

> **Tip:** Middle-click and drag to pan the viewport. Scroll wheel to zoom. Right-click erases, and **Ctrl+click** picks a tile from the viewport. Get comfortable with these controls and painting goes fast.

## Adding Collision to Tiles

Right now, the player walks through everything. We need to mark certain tiles as solid.

### Step 1: Add a Physics Layer to the TileSet

1. Select any TileMapLayer node to access the TileSet.
2. In the Inspector, expand the TileSet resource.
3. Under **Physics Layers**, click **Add Element**.
4. This creates a physics layer that tiles can use for collision.

### Step 2: Mark Tiles as Solid

1. In the TileSet panel (bottom of editor), click the **Paint** tab (not "Setup" or "Select").
2. In the paint property dropdown (left side of the panel), select **Physics Layer 0**.
3. Now click on each tile that should be solid: wall tiles, water tiles, tree trunks, and building exteriors. Each click fills the tile with a blue collision rectangle.
4. If you need to remove collision from a tile, right-click it to clear it.

> **Alternative method:** If you prefer more control, switch to the **Select** tab instead. Click on a tile, then in the properties panel on the right, expand **Physics → Physics Layer 0**. Click **Add Collision Polygon**, or right-click the collision area and choose **Reset to default tile shape** to fill the entire tile. The Paint method above is faster for marking many tiles at once.

Repeat until every tile type that should block the player has collision: walls, water, tree trunks, building exteriors.

> **Note:** You only need to set collision on the tile *definition* in the TileSet, not on each placed tile individually. Once a tile type has collision, every instance of that tile on the map is solid.

> **Warning:** All four TileMapLayers share the same TileSet, so a tile marked as solid will block the player on *any* layer it appears. If the player seems stuck in open areas, check whether a ground tile (like grass or dirt) was accidentally given collision. Only mark tiles that should actually block movement: walls, water, tree trunks, and building exteriors.

### Step 3: Test It

First, resize the player's collision shape to fit the tile-based world. Open `player/player.tscn`, select the `CollisionShape2D` node, and in the Inspector set the shape's **Size** to `Vector2(14, 10)` and **Position** to `Vector2(0, 4)`. The 64x64 collision from Module 3 was sized for the Godot icon, and it's far too large for 16x16 tile corridors. The smaller shape represents the player's feet, so they can walk through tile-width paths.

Instance the Player scene into `Willowbrook` (drag `player/player.tscn` from the FileSystem dock into the viewport). Run with **F6** (which runs the current scene directly, not F5, which runs the main scene). Try walking into walls and water. The player should collide and slide along surfaces.

> **Note:** Your main scene is still `main.tscn` from Module 1. That's fine; we use F6 to test Willowbrook directly. In Module 7, we'll build a proper SceneManager and set up scene transitions.

## Camera2D: Following the Player

Play any early Legend of Zelda game and you will feel the camera snap rigidly to Link's position, where every pixel of movement translates directly to camera movement, which feels jittery at high speeds. Modern JRPGs like OMORI use camera smoothing so the viewport glides gently to follow the player, creating a more cinematic feel. Camera limits are equally important: without them, the camera reveals the void beyond the map edge when the player walks near a boundary, breaking the illusion that this is a real place. Pokemon never lets you see past the edge of a route for exactly this reason.

If your map is larger than the screen, you need a camera. Open the Player scene (`player.tscn`) and add a **Camera2D** node as a child:

```
Player (CharacterBody2D)
├── Sprite2D
├── CollisionShape2D
└── Camera2D
```

Select the Camera2D and set these properties in the Inspector:

- **Enabled:** `true` (should be by default)
- **Position Smoothing → Enabled:** `true`
- **Position Smoothing → Speed:** `5.0`

The camera now follows the player with a slight smoothing effect, which feels much better than rigid 1:1 tracking.

### Camera Limits

To prevent the camera from showing empty space beyond the map edges, set camera limits:

In the Camera2D Inspector:
- **Limit → Left:** `0`
- **Limit → Top:** `0`
- **Limit → Right:** your map's width in pixels (e.g., `640`)
- **Limit → Bottom:** your map's height in pixels (e.g., `480`)

To calculate your map's pixel dimensions: count the tiles you painted horizontally and vertically, then multiply by the tile size. For example, a 40×30 map with 16px tiles is 640×480 pixels. If you're unsure of your exact count, use a generous estimate like `800` × `600`. You can fine-tune later.

> **See:** [Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html), covering all Camera2D properties including limits, zoom, smoothing, and drag margins.

## Pixel-Perfect Rendering Checklist

If your tiles look blurry, have gaps between them, or shimmer when the camera moves, check these settings:

1. **Project Settings → Rendering → Textures → Default Texture Filter:** `Nearest` (set in Module 1)
2. **Project Settings → Display → Window → Stretch → Mode:** `canvas_items`
3. **Camera2D → Position Smoothing:** Keep the speed moderate (3-8). Very high values can cause sub-pixel jitter.
4. **Import settings on tile sheet:** Select the PNG in FileSystem, go to the Import tab, ensure **Filter** is `Nearest` (or `Off`). Click **Reimport**.

> **See:** [Viewport and canvas transforms](https://docs.godotengine.org/en/stable/tutorials/2d/2d_transforms.html), explaining how coordinates, viewports, and rendering relate in 2D.

> **Warning:** Blurry tiles and "pixel swimming" (tiles that seem to jitter by one pixel as the camera scrolls) are the most common visual issues in pixel art games. The fix is almost always in the texture filter and viewport stretch settings.

## Organizing the Scene

Your Willowbrook scene should now look like this:

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── Objects (TileMapLayer)
├── AbovePlayer (TileMapLayer)
└── Player (player.tscn instance)
```

Later (in Module 7), the Player will be spawned by the SceneManager rather than placed directly in the scene. But for now, having it here lets us test immediately.

## A Note on Tile Art

You're probably looking at your map and thinking it looks... rough. That's okay. Programmer art is a rite of passage. The important thing is that the *systems* work: the layers, the collision, the camera.

When you're ready, you can:
- Find free tile packs (Kenney, OpenGameArt, itch.io)
- Commission custom art
- Learn pixel art yourself (Aseprite is the standard tool)

Swapping the art is just changing the tile sheet image and reassigning it in the TileSet. The map layout, collision, and layer structure stay the same.

## Engineering Contract

- **Global state:** None; the map is scene-local content.
- **Public surface:** Named TileMapLayer nodes (`Ground`, `Detail`, `Objects`, `AbovePlayer`) that later modules can rely on.
- **Invariant:** Collision belongs on blocking tiles, visual decoration stays sparse and intentional, and player walkable space stays readable.
- **Failure behavior:** Bad tile coordinates or missing collision are corrected in the TileSet/scene before scripting depends on them.
- **Copy semantics:** TileSet and atlas resources are shared project assets; scene edits reference them rather than cloning them.

## Engine Gotcha

TileMapLayer is the Godot 4 workflow this series uses. Treat terrain painting and collision as editor-authored data: if a terrain set or collision layer is not configured in the TileSet, script calls cannot infer it for you.

## What We've Learned

- **TileMapLayer** nodes render grids of tiles from a **TileSet** resource.
- **TileSets** are created from tile sheet images (atlases). Set the tile size before creating the atlas.
- **Multiple layers** (Ground, Detail, Objects, AbovePlayer) create depth and visual richness.
- **Physics layers** on the TileSet make tiles solid. Set collision on the tile definition, not on each placed tile.
- **Camera2D** follows the player. Use position smoothing and limits for a polished feel.
- **Pixel-perfect settings:** `Nearest` texture filter, `canvas_items` stretch mode, and consistent tile sizes prevent blurriness and jitter.
- `TileMapLayer` replaces the deprecated `TileMap` node, using one node per layer.

## What You Should See

When you press F6 (to run the Willowbrook scene directly):
- A tiled town with ground, paths, and objects
- The player character walks around with arrow keys
- The player collides with walls, water, and solid objects
- The camera follows the player smoothly
- Tiles are crisp and pixel-perfect (no blurriness)

## Next Module

We have a town, but our player is still the Godot icon sliding around lifelessly. In **Module 6: Bringing the Player to Life**, we'll add sprite animations (walk cycles in four directions), implement a proper enum-based state machine, and add Y-sorting so the player walks behind trees and in front of paths.


---

<!-- Source: 06_player_character.md -->

# Module 6: Bringing the Player to Life

## What We Have So Far

A tiled town (Willowbrook) with collision, a camera that follows the player, and physics-based movement. But the player is still the Godot icon, sliding around without animation.

## What We're Building This Module

A fully animated player character with four-directional walk cycles, a proper state machine to manage behavior, and Y-sorting for correct depth rendering. By the end, the player character will have proper walk cycles and depth sorting. It'll look like an actual JRPG.

## Sprite Sheets and Walk Cycles

JRPG characters are typically drawn as **sprite sheets**, single images containing all animation frames arranged in a grid. A standard 4-direction character has frames like this:

```
Row 0: Walk Down:  frame 0, 1, 2, 3
Row 1: Walk Left:  frame 0, 1, 2, 3
Row 2: Walk Right: frame 0, 1, 2, 3
Row 3: Walk Up:    frame 0, 1, 2, 3
```

Each row is a direction, each column is a frame of the walk animation. Most JRPG characters use 3-4 frames per direction.

You have two options for the character sprite. **Option A** is fastest and works without downloading anything. **Option B** looks better if you have time.

### Option A: Godot Icon Fallback (recommended for first playthrough)

Use the Godot `icon.svg` as your character sprite. This is the fastest way to keep moving. Set up AnimatedSprite2D with single-frame animations using the icon for all 8 animations (`idle_down`, `idle_up`, `idle_left`, `idle_right`, `walk_down`, `walk_up`, `walk_left`, `walk_right`). The walk animations won't visually animate, but the state machine code will work correctly, and you can swap in real art later.

Skip ahead to the **"Adding Single-Frame Animations"** section below (search for that heading). You'll rejoin the main flow at **"The State Machine Pattern."** Here are the single-frame setup steps:

1. In the SpriteFrames panel, rename the `default` animation to `idle_down`.
2. Click "Add Animation" seven more times for: `idle_up`, `idle_left`, `idle_right`, `walk_down`, `walk_up`, `walk_left`, `walk_right`.
3. For each animation, drag `icon.svg` from the FileSystem dock into the frames area.
4. Set FPS to 8 and enable looping for the walk animations.

### Option B: Download a sprite sheet

Download a free character sprite sheet from one of these sources:

1. Go to [kenney.nl/assets/tiny-town](https://kenney.nl/assets/tiny-town) (the same pack from Module 5). In the extracted ZIP, `tilemap_packed.png` contains small 16x16 character tiles in the lower portion of the sheet.

2. Alternatively, search [opengameart.org](https://opengameart.org) for "JRPG character sprite sheet 16x16". Look for a sheet with **4 rows** (one per direction: down, left, right, up) and **3-4 columns** (frames per walk cycle).

> **Note:** If your sprite sheet has a different layout (e.g., 3 frames instead of 4, or rows in a different order like down/up/left/right), that's fine. Just adjust the frame selection when setting up animations below. The script we write works with any 4-direction animation names.

Save your sprite sheet to `res://player/player_spritesheet.png`.

## Setting Up AnimatedSprite2D

In the original Final Fantasy on NES, characters barely animated (they shuffled two frames when walking) and the world still felt more alive than a static sprite sliding across the screen like a chess piece. Walk cycle animation transforms a game object into a character. It conveys weight, personality, and direction. When Crono walks in Chrono Trigger, his cape bounces and his legs pump, even though it is only 4 frames of animation, it sells the illusion of a living person.

Open `player/player.tscn`. We're going to replace the `Sprite2D` with an `AnimatedSprite2D`, which handles frame-based animation natively.

1. **Delete** the existing `Sprite2D` node.
2. Add an **AnimatedSprite2D** node as a child of Player.
3. Rename it to `Sprite`.

Your scene tree:
```
Player (CharacterBody2D)
├── Sprite (AnimatedSprite2D)
├── CollisionShape2D
└── Camera2D
```

In Module 5, we resized the collision shape to `Vector2(14, 10)` to fit tile corridors. That size was matched to the Godot icon, which is wider than a typical 16x16 character sprite. Now that we're using an actual character, shrink it to fit: set the shape's **Size** to roughly `Vector2(12, 8)` and the **CollisionShape2D** node's **Position** (under Transform) to `Vector2(0, 4)` so it covers just the character's feet. We'll discuss why this "feet-only" collision matters later in this module.

### Creating a SpriteFrames Resource

A SpriteFrames resource is the animation library for a character. In games like Pokemon, every character has a consistent set of animations (walk_up, walk_down, walk_left, walk_right, idle), and the game engine picks the right one based on the character's current state and direction. By storing these as named animations, you can swap an entire character's appearance just by assigning a different SpriteFrames: replace the hero's animations with a disguise, or reuse the same walking logic for every NPC by giving each one unique SpriteFrames with their own art.

AnimatedSprite2D uses a **SpriteFrames** resource to define animations.

1. Select the `Sprite` (AnimatedSprite2D) node.
2. In the Inspector, find **Sprite Frames** and click to create a **New SpriteFrames**.
3. The SpriteFrames panel opens at the bottom of the editor.

### Adding Animations from a Sprite Sheet

In the SpriteFrames panel:

1. You'll see a `default` animation. Rename it to `idle_down`.
2. Click the **Add frames from Sprite Sheet** button (it has a grid pattern icon; hover over the buttons near the top of the SpriteFrames panel to find it).
3. Select your sprite sheet image.
4. Set the grid size to match your sheet (e.g., 4 columns × 4 rows for a 4-direction, 4-frame sheet).
5. Click the frames for the "facing down idle" pose (usually just the first frame of the down row).
6. Click **Add Frames**.

Repeat for each animation:
- `idle_down`: the standing frame facing down
- `idle_up`: standing facing up
- `idle_left`: standing facing left
- `idle_right`: standing facing right
- `walk_down`: all frames of the down walk cycle
- `walk_up`: all frames of the up walk cycle
- `walk_left`: all frames of the left walk cycle
- `walk_right`: all frames of the right walk cycle

Here's a reference table for a 4-column × 4-row sprite sheet (down/left/right/up):

| Animation | Row | Frames to Select |
|-----------|-----|-----------------|
| `idle_down` | 0 | Frame 0 only |
| `idle_left` | 1 | Frame 0 only |
| `idle_right` | 2 | Frame 0 only |
| `idle_up` | 3 | Frame 0 only |
| `walk_down` | 0 | Frames 0, 1, 2, 3 |
| `walk_left` | 1 | Frames 0, 1, 2, 3 |
| `walk_right` | 2 | Frames 0, 1, 2, 3 |
| `walk_up` | 3 | Frames 0, 1, 2, 3 |

For each walk animation, set the **FPS** to 8-10 (the number field at the top of the SpriteFrames panel, next to the loop toggle, the circular arrow icon). Also enable looping for walk animations by clicking that loop toggle. Idle animations can stay at the default speed since they're typically a single frame (or 2-3 frames for a breathing animation).

> **Warning:** Animation names must match **exactly** what the script expects. The code constructs names like `"walk_down"` and `"idle_left"` dynamically. If you name an animation `Walk_Down` or `walkdown`, it won't be found. Use all lowercase with an underscore: `idle_down`, `walk_up`, etc.

> **See:** [2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html), covering both AnimatedSprite2D and AnimationPlayer approaches to 2D animation.

> **See:** [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html), the full API reference.

### The Alternative: Sprite2D + AnimationPlayer

There's another way to animate sprites in Godot: using a regular `Sprite2D` with an `AnimationPlayer` that keyframes the `frame` property or `region_rect`. This approach is more powerful (you can animate any property), but more complex to set up.

For character walk cycles, `AnimatedSprite2D` is simpler and perfectly adequate. We'll use `AnimationPlayer` later for UI animations and battle effects where we need to animate multiple properties simultaneously.

> **See:** [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html), for when you need to animate arbitrary properties.

## The State Machine Pattern

Right now, our player script is simple: check input, set velocity, move. But as we add features, the logic gets tangled:

- Can the player move during dialogue? (No.)
- Can the player open the inventory while walking? (Yes, but movement should stop.)
- What happens when the player interacts with an NPC? (Face the NPC, stop moving, wait for dialogue to finish.)
- Can the player move during a cutscene? (No.)

Without structure, you end up with a mess of boolean flags: `is_talking`, `is_in_menu`, `can_move`, `is_cutscene_active`. Each new feature adds another flag, and the interactions between them become impossible to reason about.

The solution is a **state machine**: the player is always in exactly one state, and each state defines what the player can and can't do.

### Our Four States

```
IDLE:       standing still, can accept input
WALK:       moving, playing walk animation
INTERACT:   talking to NPC or object, movement disabled
DISABLED:   cutscene, battle transition, or menu, movement disabled
```

### The Rules

| From | To | When |
|------|----|------|
| IDLE | WALK | Movement input detected |
| WALK | IDLE | Movement input released |
| IDLE | INTERACT | Player presses interact near an NPC |
| INTERACT | IDLE | Dialogue finishes |
| Any | DISABLED | Cutscene starts / battle starts / menu opens |
| DISABLED | IDLE | Cutscene ends / battle ends / menu closes |

The key insight: **each state is a self-contained behavior.** The IDLE state checks for movement and interact input. The WALK state plays the walk animation and moves. The INTERACT state does nothing; it waits for a signal that dialogue is finished. The DISABLED state is completely inert.

This enum-based state machine is the right size for player movement: one script owns all states, and every state is only a few lines. In Module 14, battle flow gets complex enough that we switch to a node-based state machine, where each state is its own script. Same idea, different scale.

### Implementation

Replace the entire contents of `res://player/player.gd` with this state machine version:

```gdscript
extends CharacterBody2D
## The player character with state-machine-driven movement and animation.

# GDScript enums define a set of named integer constants.
# This creates State.IDLE = 0, State.WALK = 1, State.INTERACT = 2, State.DISABLED = 3.
# We use them instead of raw integers so the code reads as words, not magic numbers.
enum State { IDLE, WALK, INTERACT, DISABLED }

@export var speed: float = 200.0

var current_state: State = State.IDLE
var facing_direction: Vector2 = Vector2.DOWN  # Vector2(0, 1), positive Y is downward in Godot

@onready var sprite: AnimatedSprite2D = $Sprite


func _physics_process(_delta: float) -> void:
    match current_state:
        State.IDLE:
            _state_idle()
        State.WALK:
            _state_walk()
        State.INTERACT:
            _state_interact()
        State.DISABLED:
            _state_disabled()


func _state_idle() -> void:
    velocity = Vector2.ZERO
    _play_animation("idle")

    var direction := _get_input_direction()
    if direction != Vector2.ZERO:
        facing_direction = direction
        _change_state(State.WALK)


func _state_walk() -> void:
    var direction := _get_input_direction()

    if direction == Vector2.ZERO:
        _change_state(State.IDLE)
        return

    facing_direction = direction
    velocity = direction.normalized() * speed
    _play_animation("walk")
    move_and_slide()


func _state_interact() -> void:
    velocity = Vector2.ZERO
    # Waiting for interaction to complete. Controlled externally.


func _state_disabled() -> void:
    velocity = Vector2.ZERO
    # Completely inert: cutscene, menu, or battle transition.


func _change_state(new_state: State) -> void:
    current_state = new_state


func _get_input_direction() -> Vector2:
    return Vector2(
        Input.get_axis("ui_left", "ui_right"),
        Input.get_axis("ui_up", "ui_down"),
    )


func _play_animation(action: String) -> void:
    var direction_name := _direction_to_string(facing_direction)
    var anim_name := action + "_" + direction_name
    if sprite.sprite_frames.has_animation(anim_name):
        sprite.play(anim_name)


func _direction_to_string(direction: Vector2) -> String:
    # Determine the dominant axis for 4-directional facing
    if abs(direction.x) > abs(direction.y):
        return "right" if direction.x > 0 else "left"
    else:
        return "down" if direction.y >= 0 else "up"


## Call this from external systems to disable/enable the player.
func set_disabled(disabled: bool) -> void:
    if disabled:
        _change_state(State.DISABLED)
    else:
        _change_state(State.IDLE)


## Call this when the player starts interacting with something.
func start_interaction() -> void:
    _change_state(State.INTERACT)


## Call this when the interaction is complete.
func end_interaction() -> void:
    _change_state(State.IDLE)
```

Here's why we made these choices:

### The `match` Statement

```gdscript
match current_state:
    State.IDLE:
        _state_idle()
    State.WALK:
        _state_walk()
```

The `match` statement routes to the correct state handler each frame. Each state is a separate function with a clear name. This is much cleaner than nested `if/elif` blocks.

### Facing Direction

`facing_direction` is a `Vector2` that remembers which way the player last moved. We use it to choose the correct animation even when standing still (idle_down, idle_left, etc.).

The `_direction_to_string()` function converts a Vector2 direction into "up", "down", "left", or "right" by checking which axis has the larger magnitude. This handles diagonal input gracefully: if you press right and slightly down, you face right.

### Public Methods for External Control

`set_disabled()`, `start_interaction()`, and `end_interaction()` are **public methods** that other systems call to control the player's state. The dialogue system will call `start_interaction()` when a conversation begins and `end_interaction()` when it ends. The battle system will call `set_disabled(true)` during transitions.

This keeps the state machine's logic internal while providing a clean API for the rest of the game.

> **Spiral:** We'll revisit state machines in Module 14 when we build the battle system. The battle state machine is more complex (7+ states with complex transitions), so we'll upgrade from this enum-based approach to a **node-based** state machine. The enum approach works great for the player's 4 simple states.

## Y-Sorting: Correct Depth Ordering

Without Y-sorting, you get a common visual bug: the player walks south past a tree and the tree renders on top of them, but walking north past the same tree puts the player on top. In Final Fantasy VI, Y-sorting is what makes towns feel three-dimensional despite being flat 2D art. When Terra walks behind a market stall, the stall's roof covers her sprite. When she walks in front of it, she covers the stall. The engine draws objects sorted by their Y position: objects higher on the screen (further away) are drawn first, objects lower (closer) are drawn on top.

In a top-down 2D game, objects lower on the screen should appear in front of objects higher on the screen. This creates the illusion of depth. The player walks "behind" a tree when they're above it, and "in front of" a tree when they're below it.

Godot handles this with **Y-sort**. When enabled on a parent node, its children are drawn sorted by their Y position: lower Y values are drawn first (behind), higher Y values are drawn last (in front).

### Setting Up Y-Sort

In the Willowbrook scene:

> **Tip:** To reparent a node, drag it in the Scene dock and drop it onto the new parent node. The node moves in the tree hierarchy. You'll use this technique in the steps below.

1. Add a new **Node2D** as a child of `Willowbrook`. Rename it to `YSortGroup`.
2. In the Inspector, find **CanvasItem → Ordering → Y Sort Enabled** and turn it **on**.
3. Drag the `Objects` TileMapLayer onto `YSortGroup` to reparent it (it becomes a child of YSortGroup instead of Willowbrook).
4. Drag the `Player` instance onto `YSortGroup` the same way.
5. Select the `Objects` TileMapLayer. In the Inspector, find **CanvasItem → Ordering → Y Sort Enabled** and turn it **on** for this node too.

> **Warning:** This step is essential. Without `y_sort_enabled` on the `Objects` TileMapLayer itself, the individual tiles within the layer won't sort against the player. The entire layer renders as a single block, causing the player to appear always in front of or always behind all objects. If your trees and buildings are sorting incorrectly, this is the first thing to check.

Now set the Y Sort Origin for the Objects layer so tiles sort by their bottom edge:
1. With `Objects` still selected, find **Y Sort Origin** in the Inspector and set it to `16` (the tile height in pixels). This makes tiles sort based on their bottom edge rather than their top-left corner, which looks correct for trees, rocks, and buildings.

The AbovePlayer layer should **not** be Y-sorted with the player; it should always draw on top. Keep it outside the Y-sorted group, or set its Z-index higher.

> **See:** [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html), covering the `y_sort_enabled` property and how it affects rendering order.

### A Practical Scene Structure

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── YSortGroup (Node2D, y_sort_enabled = true)
│   ├── Objects (TileMapLayer, y_sort_origin adjusted)
│   └── Player (player.tscn instance)
└── AbovePlayer (TileMapLayer)
```

The `YSortGroup` node sorts the Objects layer tiles and the Player by their Y positions. Ground and Detail are always below everything. AbovePlayer is always on top.

## Adjusting the Collision Shape

We already set the collision shape values earlier in this module when we added the AnimatedSprite2D. This section explains the *reasoning* behind feet-only collision, so you understand why we chose those specific values.

With animated sprites, you want the collision shape to be:

- **Shorter** than the sprite, roughly the bottom third or half. This represents the player's "feet" area.
- **Offset downward** so it aligns with the feet, not the center of the sprite.

Our values (`Vector2(12, 8)` size, `Vector2(0, 4)` offset) give the player a small collision "footprint" that feels natural. The player's head and torso can overlap with objects above, but their feet are blocked by solid tiles.

> **JRPG Pattern:** Almost every JRPG uses "feet-only" collision. It's why you can walk close to a table and it looks like you're standing at the table, not being blocked a full character-width away.

## Grid-Based vs Free Movement

We've implemented **free movement**: the player moves smoothly in any direction at any time. This is what most modern JRPGs use (and what Crystal Saga will use).

The alternative is **grid-based movement**, where the player snaps from one tile to the next in discrete steps. This is what classic JRPGs (Final Fantasy I-VI, Dragon Quest I-V, Pokemon) use.

| Aspect | Free Movement | Grid-Based |
|--------|--------------|------------|
| Feel | Smooth, modern | Crisp, retro |
| Implementation | Simpler (what we've built) | More complex (tween between grid cells) |
| Collision | Per-pixel via physics | Per-tile via grid lookup |
| NPC interaction | Distance + facing direction | Adjacent tile check |
| Map alignment | Objects can be anywhere | Everything aligns to grid |

Grid-based movement is elegant for tile-heavy games but requires a different architecture (tweening between positions, checking the grid for obstacles before moving). We're using free movement because it's more flexible and natural-feeling for our scope.

## Engineering Contract

- **Global state:** None; player movement lives on the player scene instance.
- **Public surface:** The player joins the `"player"` group and exposes predictable movement/animation state.
- **Invariant:** Movement input produces one deterministic velocity per frame, then `move_and_slide()` resolves collisions.
- **Failure behavior:** Unknown or missing input actions should result in no movement, not script errors.
- **Copy semantics:** The player scene can be instanced in multiple maps; runtime state belongs to the instance.

## Engine Gotcha

`CharacterBody2D` does not move by assigning `position` directly. Set `velocity`, call `move_and_slide()`, and let Godot resolve collision against the physics world during the physics frame.

## What We've Learned

- **Sprite sheets** contain all animation frames. **AnimatedSprite2D** plays frame-based animations from a **SpriteFrames** resource.
- A **state machine** organizes player behavior into discrete states (IDLE, WALK, INTERACT, DISABLED), preventing conflicting behavior.
- The **enum + match** pattern is a clean way to implement a simple state machine.
- **Public methods** (`set_disabled`, `start_interaction`) give other systems controlled access to the state machine.
- **Y-sorting** creates correct depth ordering, where lower objects appear in front.
- **Feet-only collision** (small, low CollisionShape2D) feels natural in top-down JRPGs.
- **Free movement** is smoother and simpler than grid-based; Crystal Saga uses free movement.
- **Facing direction** persists so idle animations face the last movement direction.

## What You Should See

When you press F6 (running the Willowbrook scene):
- The player has animated walk cycles in four directions
- The player stands idle facing the last direction they moved
- Y-sorting works: the player walks behind trees and in front of paths
- Collision with the tilemap works (player stops at walls, can't walk through water)
- The feet-only collision allows the player's head to overlap slightly with objects

## Next Module

We have a living player in a real town, but there's nowhere to go. In **Module 7: Connecting Worlds**, we'll build a second area (Whisperwood Forest), create exit zones that trigger scene transitions, and build our first autoload (the SceneManager) that handles fade-to-black transitions between locations.


---

<!-- Source: 07_scene_transitions.md -->

# Module 7: Connecting Worlds: Scene Transitions

## What We Have So Far

An animated player character with a state machine, walking around the town of Willowbrook with proper collision and Y-sorting. But the town is an island, and there's no way to leave.

## What We're Building This Module

A second area (Whisperwood Forest), exit zones that detect when the player walks to the edge of a map, and a **SceneManager** autoload that handles smooth fade-to-black transitions between locations. By the end, Crystal Saga will have two areas you can walk between.

## Why Scenes Map to Locations

In a JRPG, each location is typically one scene:

- Willowbrook (town) → `willowbrook.tscn`
- Whisperwood (forest) → `whisperwood.tscn`
- Crystal Cavern (dungeon) → `crystal_cavern.tscn`
- Battle Screen → `battle.tscn`

When the player walks to the edge of town, the game transitions to the forest. When they walk to the forest entrance, it transitions back to town. This is a **scene change**: the current scene is freed (removed from memory), and the new scene is loaded and instanced.

The challenge: how do we manage these transitions cleanly? Who handles the fade effect? How does the new scene know where to spawn the player?

The answer is our first **autoload**.

## Autoloads: Your First Project Singleton

You've been using Godot-provided global singletons since Module 2. `Input`, `Engine`, `Time`, `Performance`, and `AudioServer` are built into the engine and are globally available by name.

Now we're going to create our own project autoload.

An **autoload** (also called a project singleton) is a scene or script that Godot registers under `/root`:
1. Is loaded automatically when the game starts
2. Persists across scene changes (it's never freed)
3. Is accessible from anywhere by name

This makes autoloads perfect for game-wide systems: scene management, inventory, audio, quest tracking, game state. We'll build several throughout this tutorial.

> **See:** [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html), the official guide to autoloads, including when and why to use them.

> **Warning:** Autoloads are powerful but easy to overuse. Not everything needs to be global. If a system only matters within a single scene (like the layout of a specific room), keep it local. We'll use autoloads for systems that genuinely need to persist across the entire game.

## Building the SceneManager

The SceneManager handles scene transitions: fading out, loading the new scene, fading in, and positioning the player at the correct spawn point.

### Step 1: Create the Script

Create a new folder `res://autoloads/` and a new script `res://autoloads/scene_manager.gd`:

```gdscript
extends Node
## Manages scene transitions with fade effects.
## Registered as an autoload. Accessible as SceneManager from anywhere.

signal transition_started
signal transition_finished

@onready var _color_rect: ColorRect = $TransitionLayer/ColorRect
@onready var _anim_player: AnimationPlayer = $TransitionLayer/AnimationPlayer

var _target_scene_path: String = ""
var _target_spawn_point: String = ""
var _is_transitioning: bool = false


func change_scene(scene_path: String, spawn_point: String = "default") -> void:
    if _is_transitioning:
        return

    _is_transitioning = true
    _target_scene_path = scene_path
    _target_spawn_point = spawn_point

    transition_started.emit()
    _anim_player.play("fade_out")
    await _anim_player.animation_finished

    get_tree().change_scene_to_file(_target_scene_path)

    # Wait for the new scene to be fully loaded and added to the tree.
    # change_scene_to_file() is deferred, so we need to wait for the swap.
    await get_tree().scene_changed

    _place_player_at_spawn()

    _anim_player.play("fade_in")
    await _anim_player.animation_finished

    _is_transitioning = false
    transition_finished.emit()


func _place_player_at_spawn() -> void:
    # Find the spawn point marker in the new scene
    var spawn_markers := get_tree().get_nodes_in_group("spawn_points")
    for marker in spawn_markers:
        if marker.name == _target_spawn_point:
            var player := get_tree().get_first_node_in_group("player")
            if player:
                player.global_position = marker.global_position
            return

    # If no matching spawn point, use "default"
    for marker in spawn_markers:
        if marker.name == "default":
            var player := get_tree().get_first_node_in_group("player")
            if player:
                player.global_position = marker.global_position
            return
```

### Step 2: Create the Scene

The SceneManager needs visible nodes (a ColorRect for the black overlay, an AnimationPlayer for the fade). Create a scene for it.

1. Create a new scene with `Node` as root. Rename it to `SceneManager`.
2. Set the root node's **Process → Mode** to **Always** in the Inspector. This ensures the SceneManager continues working even when the game is paused (which we'll use for the pause menu in Module 25).
3. Add a **CanvasLayer** child. Rename it to `TransitionLayer`. Set its **Layer** to `100` in the Inspector (so it draws on top of everything).

In every JRPG, the fade effects and dialogue boxes must render on top of the game world no matter where the camera is or how the scene is structured. In Earthbound, the swirling battle transition overlay covers everything: the map, the enemies, the party. A regular node would be affected by the camera's position and zoom, and could sort incorrectly with other nodes. CanvasLayer creates an entirely separate rendering surface that is immune to camera transforms and always draws at its designated layer number.

3. Inside `TransitionLayer`, add a **ColorRect** child. Set its color to black (`Color(0, 0, 0, 1)`).
4. Set the ColorRect to cover the full screen: **Layout → Anchors Preset → Full Rect** (or set all anchors to cover the viewport).
5. Set the ColorRect's **Modulate** alpha to `0` (fully transparent by default).
6. Add an **AnimationPlayer** as a child of `TransitionLayer`.

### Step 3: Create the Fade Animations

Select the AnimationPlayer and create two animations. Here's the step-by-step for the first one:

**`fade_out`** (0.3 seconds):
1. In the Animation panel at the bottom, click **Animation → New**. Name it `fade_out`.
2. Set the animation length to `0.3` (the number field next to the timeline).
3. Click **Add Track → Property Track**. Select the `ColorRect` node.
4. Choose the **`modulate`** property from the list.
5. Right-click the timeline at time `0.0` and choose **Insert Key**. Set the value's alpha to `0.0` (transparent).
6. Right-click at time `0.3` and insert another key. Set alpha to `1.0` (fully opaque/black).

> **See:** [Introduction to animations](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html), explaining how to create animations with property tracks in AnimationPlayer.

**`fade_in`** (0.3 seconds):
Same process, but reversed:
- At time 0: `modulate` alpha = `1.0` (fully black)
- At time 0.3: `modulate` alpha = `0.0` (transparent)

Attach the `scene_manager.gd` script to the root `SceneManager` node. Save the scene as `res://autoloads/scene_manager.tscn`.

> **Note:** We use a CanvasLayer with a high layer number (100) so the fade overlay draws on top of everything: UI, game world, particles, all of it. CanvasLayer nodes exist outside the normal rendering order.

> **See:** [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html), explaining how CanvasLayer works and why it's essential for UI and overlays.

### Step 4: Register the Autoload

1. Go to **Project → Project Settings → Autoload**.
2. Click the folder icon and select `res://autoloads/scene_manager.tscn`.
3. The name will auto-fill as `SceneManager`. Keep it.
4. Click **Add**.

Now `SceneManager` is globally accessible. Any script in the game can call `SceneManager.change_scene(...)`.

> **See:** [Change scenes manually](https://docs.godotengine.org/en/stable/tutorials/scripting/change_scenes_manually.html), covering the built-in `change_scene_to_file()` and why a wrapper autoload is often needed.

## Understanding `await`

The SceneManager uses `await`, a GDScript keyword that pauses the function until a signal is emitted, then resumes.

```gdscript
_anim_player.play("fade_out")
await _anim_player.animation_finished  # Pause here until the animation finishes
# ...this code runs after the animation is done
```

This makes async sequences (fade out → change scene → fade in) readable as linear code. Without `await`, you'd need callbacks or a state machine just for the transition.

`await` can wait for any signal:
```gdscript
await get_tree().create_timer(1.0).timeout  # Wait 1 second
await some_node.some_signal                  # Wait for a custom signal
```

## Exit Zones

In every JRPG from Dragon Quest to Pokemon, walking to the edge of a town seamlessly transitions you to the next area. The player never clicks a "leave town" button; they just walk south and the game detects that they have crossed an invisible boundary. The alternative, checking the player's position every frame with `if position.x > map_width` is fragile, hard-coded, and needs rewriting for every map shape. Exit zones are reusable: the same script works on every map edge, every door, and every warp point.

An **exit zone** is an Area2D that detects when the player enters it and triggers a scene change. We'll set up bidirectional exits between Willowbrook and Whisperwood.

### Creating an Exit Zone

In the Willowbrook scene, add an Area2D:

1. Add an **Area2D** child to `Willowbrook`. Rename it to `ExitToWhisperwood`.
2. Add a **CollisionShape2D** child to the Area2D.
3. Set the shape to a `RectangleShape2D` and position/size it at the map edge where the forest exit should be (e.g., along the south edge of the map).

Create a script for exit zones. Save as `res://scenes/exit_zone.gd`:

```gdscript
extends Area2D
## A zone that triggers a scene transition when the player enters.

@export_file("*.tscn") var target_scene: String
@export var target_spawn_point: String = "default"


func _ready() -> void:
    # In Module 3, we connected signals through the editor UI. That works when both
    # sender and receiver are in the same scene and you are placing nodes manually.
    # But the exit zone script is designed to be reusable: attach it to any Area2D
    # in any scene and it just works. Connecting the signal in code means the
    # connection is self-contained. As your game grows, code-based connections
    # become the standard for reusable components.
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        SceneManager.change_scene(target_scene, target_spawn_point)
```

> **Note:** The Area2D's default collision mask monitors layer 1, which is the same layer the player's CharacterBody2D is on by default. If you changed collision layers in Module 5, make sure the exit zone's **Collision → Mask** includes the player's layer.

Attach this script to `ExitToWhisperwood`. In the Inspector, set:
- **Target Scene:** `res://scenes/whisperwood/whisperwood.tscn`
- **Target Spawn Point:** `from_town`

> **Note:** `@export_file("*.tscn")` creates a file picker in the Inspector that only shows `.tscn` files. Much easier than typing paths manually.

### Player Groups

The exit zone checks `body.is_in_group("player")`. We need to add the player to this group.

**Groups** are tags you can assign to any node. A node can belong to multiple groups, and you can find all nodes in a group with `get_tree().get_nodes_in_group("name")` or get the first match with `get_tree().get_first_node_in_group("name")`. Think of them as labels for querying; they let systems find nodes without hard-coded paths.

1. Open `player.tscn`.
2. Select the `Player` (CharacterBody2D) root node.
3. Go to the **Node** tab (next to Inspector) → **Groups** section.
4. Type `player` and click **Add**.

> **See:** [Groups](https://docs.godotengine.org/en/stable/tutorials/scripting/groups.html): Godot's node tagging system. We'll use groups again in later modules for encounter zones, UI elements, and save points.

### Spawn Points

In Pokemon, walking from Route 1 into Viridian City places you at the south entrance. Flying to Viridian City places you at the Pokemon Center. Same destination, different spawn position depending on how you arrived. This is why spawn points need names: the SceneManager doesn't just load a scene, it loads a scene and places you at a specific named location.

A spawn point is a simple **Marker2D** node that marks where the player should appear. Add them to your scenes:

In `willowbrook.tscn`:
1. Add a **Marker2D** node. Rename it to `default`.
2. Position it where the player should start (town center).
3. Add it to the `spawn_points` group.
4. Add another Marker2D named `from_forest`, positioned near the south exit.
5. Add it to the `spawn_points` group too.

The SceneManager's `_place_player_at_spawn()` finds these markers by group and name, and teleports the player to the matching one.

## Building Whisperwood Forest

Create a second area to connect to:

1. Create a new folder: `res://scenes/whisperwood/`
2. Create a new scene: `Node2D` root, rename to `Whisperwood`.
3. Save as `res://scenes/whisperwood/whisperwood.tscn`.

Reuse the same TileSet from Module 5 (`town_tileset.tres`). Add TileMapLayers using the same workflow (Ground, Detail, Objects, AbovePlayer) and assign the TileSet to each. In Module 16, we'll create a dedicated dungeon tileset with a different aesthetic.

Design a simple forest area (at least 20x15 tiles). Use grass tiles for ground, tree tiles for borders, and path tiles through the center:
- Ground layer: paint grass everywhere, then carve a 3-tile-wide path winding through the middle
- Objects layer: build the north and south borders out of tree trunks, rocks, and shrubs; collision belongs on the trunk/rock tiles, not on the grass path
- AbovePlayer layer: add canopy tiles above the tree line so the player can walk "under" the leaves
- An entrance on the north side (connecting to Willowbrook)
- An exit on the south side (leading to the Crystal Cavern, which we'll build in Module 16)

**Whisperwood scene structure checklist** (make sure you have all of these):

1. `Whisperwood` (Node2D), root
2. `Ground` (TileMapLayer), grass, paths
3. `Detail` (TileMapLayer), small decorations
4. `YSortGroup` (Node2D, `y_sort_enabled = true`)
   - `Objects` (TileMapLayer, `y_sort_enabled = true`), trees, rocks
   - Player instance (`player.tscn`)
5. `AbovePlayer` (TileMapLayer), treetop canopy
6. Spawn points (Marker2D nodes, added to `spawn_points` group):
   - `from_town`: near the north entrance
   - `default`: same position as `from_town`
7. Exit zone:
   - `ExitToWillowbrook` (Area2D + `exit_zone.gd`) at the north edge, pointing to `res://scenes/willowbrook/willowbrook.tscn` with spawn point `from_forest`

If you test and see an empty forest with no player, check that you instanced `player.tscn` into the YSortGroup (not the root).

> **Note:** For now, we're placing the Player instance directly in each scene. This means there are technically multiple Player instances across scenes. That's fine because only one scene is loaded at a time. In a more complex setup, you might have the SceneManager spawn the player dynamically.

## Signal Lifecycle Across Scene Changes

An important detail to understand: when you call `get_tree().change_scene_to_file()`, the current scene is **freed**, and all its nodes are removed from the tree and deleted. This means:

1. All signal connections within that scene are cleaned up automatically (as we discussed in Module 3).
2. The SceneManager's signals (`transition_started`, `transition_finished`) still work because the SceneManager is an autoload, so it's never freed.
3. Any signals connected TO an autoload FROM a scene node are also cleaned up when the scene node is freed, so there are no dangling references.

This is why autoloads are the right home for cross-scene systems. They're the stable foundation that persists while the world changes around them.

## Testing the Flow

1. Set `willowbrook.tscn` as the main scene (Project Settings → Application → Run → Main Scene).
2. Press F5.
3. Walk the player to the south exit.
4. The screen should fade to black, then the forest appears, with the player at the `from_town` spawn point.
5. Walk north in the forest to return to Willowbrook, arriving at the `from_forest` spawn point.

If it works, congratulations. You have a connected game world.

### Troubleshooting

| Problem | Likely Cause |
|---------|-------------|
| Player doesn't trigger the exit zone | Player not in `player` group, or exit zone collision shape is missing |
| Scene changes but player is at wrong position | Spawn point name doesn't match, or spawn point isn't in `spawn_points` group |
| Fade effect not visible | CanvasLayer layer not high enough, or ColorRect not covering the screen |
| Crash on scene change | Target scene path is wrong. Check for typos in the Inspector |
| Player stuck after transition | `_is_transitioning` flag not reset. Check `await` chain |

## The Autoload Reference Card

We'll maintain this running table throughout the tutorial, adding each new autoload as we build it:

| Autoload | Module | Purpose |
|----------|--------|---------|
| **SceneManager** | 7 | Scene transitions with fade effects |

*Updated in future modules as we add more autoloads.*

## Engineering Contract

- **Global state:** `SceneManager` is a project autoload registered under `/root/SceneManager`.
- **Public surface:** `change_scene(scene_path, spawn_id)`, transition signals, and spawn-point lookup.
- **Invariant:** Scene paths and spawn IDs are stable strings shared by exits, maps, and future save/load.
- **Failure behavior:** Missing scenes or spawn points should log a clear error and fall back safely.
- **Copy semantics:** Scene changes replace scene instances; persistent data must live outside the outgoing scene.

## Engine Gotcha

`change_scene_to_file()` is deferred. Any code that needs the new scene's nodes must wait for `SceneTree.scene_changed` before looking up the player or spawn points.

## What We've Learned

- **Autoloads** are globally accessible singletons that persist across scene changes. `SceneManager` is our first custom one.
- `Input`, `Engine`, `Time`, etc. are Godot's built-in autoloads; you've been using them since Module 2.
- **`get_tree().change_scene_to_file()`** is Godot's built-in scene change, but it's abrupt. A SceneManager adds fade transitions and spawn point management.
- **`await`** pauses a function until a signal fires, making async sequences readable as linear code.
- **Area2D exit zones** detect the player and trigger scene changes.
- **Spawn points** (Marker2D nodes in groups) tell the SceneManager where to place the player in the new scene.
- **CanvasLayer** with a high layer number draws overlays on top of everything.
- Signal connections are **automatically cleaned up** when scene nodes are freed. Autoload signals persist.
- **`@export_file("*.tscn")`** creates a filtered file picker in the Inspector.

## What You Should See

When you press F5:
- Playing in Willowbrook, walking to the south edge triggers a fade-to-black
- The Whisperwood forest fades in with the player at the entrance
- Walking north in the forest fades back to Willowbrook
- Transitions are smooth (0.3s fade out, 0.3s fade in)
- Player appears at the correct spawn point each time

## Next Module

We can explore two areas now, but the world feels empty. Before we add NPCs and dialogue, we need to establish our **data architecture**. In **Module 9: Resources, The Data Layer**, we'll learn how to define game data (items, characters, NPC info) as reusable, editor-friendly Resource classes. This is the foundation every system from inventory to combat will build on.

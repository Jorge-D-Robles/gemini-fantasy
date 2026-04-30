# Merged Tutorial Through Module 03

This generated file combines the tutorial Markdown files from Module 01 through Module 03.

## Included Files

- `01_the_journey_begins.md`
- `02_gdscript_for_programmers.md`
- `03_thinking_in_scenes.md`

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

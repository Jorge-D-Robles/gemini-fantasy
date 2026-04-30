# Merged Tutorial Through Module 14

This generated file combines the tutorial Markdown files from Module 01 through Module 14.

## Included Files

- `01_the_journey_begins.md`
- `02_gdscript_for_programmers.md`
- `03_thinking_in_scenes.md`
- `04_part_i_review.md`
- `05_tilemaps_and_terrain.md`
- `06_player_character.md`
- `07_scene_transitions.md`
- `08_part_ii_review.md`
- `09_resources_data_layer.md`
- `10_npcs_and_interaction.md`
- `11_dialogue_system.md`
- `12_inventory_system.md`
- `13_part_iii_review.md`
- `14_battle_foundations.md`

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


---

<!-- Source: 08_part_ii_review.md -->

# Module 8: Part II Review and Cheat Sheet

This module is a review and quick reference for everything covered in Part II (Modules 5-7). No new code, no new features. Just a consolidated look at what you built and a cheat sheet you can flip back to when you need a reminder.

## Part II in Review

At the start of Part II, you had a Player scene (CharacterBody2D with a sprite and collision) that could move around and handle physics. But the "world" was a blank screen. There was nothing to see, nothing to collide with, and nowhere to go.

Over three modules, you turned that blank canvas into a real game world. You built the town of Willowbrook tile-by-tile using TileMapLayers, layering ground, paths, objects, and treetops into a scene with actual depth. You replaced the sliding Godot icon with a sprite-animated player character driven by a proper state machine, one that knows whether it's idle, walking, interacting, or disabled. You added Y-sorting so the player walks behind trees and in front of paths. And you connected Willowbrook to a second area, Whisperwood Forest, via exit zones and a SceneManager autoload that handles fade-to-black transitions and spawn point placement.

The result is the skeleton of a real JRPG: two connected areas you can walk between, with an animated hero, tile-based collision, camera smoothing, and clean scene transitions. Everything from here forward (NPCs, dialogue, inventory, combat) builds on this.

### Module 5: The Overworld — TileMaps and Terrain

- Built Willowbrook using **TileMapLayer** nodes (the replacement for the deprecated `TileMap` node), one per layer: Ground, Detail, Objects, and AbovePlayer.
- Created a **TileSet** resource from a tile sheet image, configured atlas sources, and shared the TileSet across all layers.
- Added **physics layers** to the TileSet so wall, water, and building tiles block the player, set once on the tile definition and applied to every instance automatically.
- Attached a **Camera2D** to the player with position smoothing and edge limits so the camera follows smoothly without showing empty space beyond the map.
- Configured **pixel-perfect rendering**: `Nearest` texture filter, `canvas_items` stretch mode, and consistent tile sizes to prevent blurriness and sub-pixel jitter.

### Module 6: Bringing the Player to Life

- Replaced the static Sprite2D with an **AnimatedSprite2D** driven by a **SpriteFrames** resource, with eight named animations: `idle_down/up/left/right` and `walk_down/up/left/right`.
- Implemented an **enum-based state machine** with four states (IDLE, WALK, INTERACT, DISABLED) and a `match` statement that routes each frame to the correct state handler.
- Added **public methods** (`set_disabled()`, `start_interaction()`, `end_interaction()`) so external systems can control the player without reaching into the state machine internals.
- Set up **Y-sorting** with a `YSortGroup` Node2D so the player renders in front of or behind objects based on vertical position, and used a **feet-only collision shape** for natural-feeling tile interaction.
- Tracked **facing direction** as a persistent Vector2 so idle animations face the last movement direction.

### Module 7: Connecting Worlds — Scene Transitions

- Built a **SceneManager autoload** that wraps `get_tree().change_scene_to_file()` with fade-out/fade-in transitions using a CanvasLayer, ColorRect, and AnimationPlayer.
- Learned what **autoloads** (singletons) are: nodes that load at startup, persist across scene changes, and are accessible by name from any script. Godot's built-in `Input`, `Engine`, and `Time` are autoloads; SceneManager is our first custom one.
- Created **exit zones** (Area2D nodes with a script) that detect the player entering and call `SceneManager.change_scene()` with a target scene path and spawn point name.
- Used **Marker2D nodes** in the `spawn_points` group as named spawn locations, so the SceneManager can place the player at the right spot after each transition.
- Used **`await`** to write the async fade-out / scene-change / fade-in sequence as readable linear code instead of a chain of callbacks.

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|----------------|------------|
| TileMapLayer | A node that renders a grid of tiles from a TileSet | Builds entire game worlds from small, reusable tile images | Module 5 |
| TileSet | A resource defining tile properties (atlas, collision, size) | Single source of truth for tile behavior; shared across layers | Module 5 |
| Atlas source | A tile sheet image mapped to a grid within a TileSet | Lets you paint tiles from a sprite sheet | Module 5 |
| Physics layer (tiles) | Collision data on tile definitions | Makes tiles solid without per-instance configuration | Module 5 |
| Camera2D | A node that controls the viewport's visible area | Follows the player, prevents showing empty space | Module 5 |
| AnimatedSprite2D | A node that plays frame-based animations from SpriteFrames | Character walk cycles, idle poses, direction-based animation | Module 6 |
| SpriteFrames | A resource holding named animation sequences | Defines frame order, FPS, and looping for each animation | Module 6 |
| State machine (enum) | A pattern where an enum tracks the current state and a `match` routes behavior | Prevents conflicting behaviors; each state is self-contained | Module 6 |
| Facing direction | A persistent Vector2 remembering the last movement direction | Idle animations face the correct way when the player stops | Module 6 |
| Y-sort | Rendering children by Y position (lower = in front) | Creates depth illusion in top-down 2D games | Module 6 |
| Autoload (singleton) | A scene/script that loads at startup and persists across scene changes | Global systems (scene management, inventory, audio) that survive scene swaps | Module 7 |
| SceneManager | Our custom autoload that handles scene transitions | Fade effects, spawn point placement, transition-safe scene changes | Module 7 |
| Exit zone | An Area2D that triggers a scene change when the player enters | Connects areas together at map edges | Module 7 |
| Spawn point | A Marker2D node in the `spawn_points` group | Tells the SceneManager where to place the player in a new scene | Module 7 |
| `await` | A keyword that pauses a function until a signal fires | Makes async sequences (fade out, change scene, fade in) readable as linear code | Module 7 |
| CanvasLayer | A node that renders on a separate layer outside normal draw order | Overlays (fade effect, UI) that draw on top of everything | Module 7 |

## Cheat Sheet

### TileMapLayer Setup

The full workflow for creating a tilemap from scratch:

1. **Create a TileSet resource:**
   - Add a TileMapLayer node to your scene.
   - In the Inspector, click Tile Set and choose New TileSet.
   - Set Tile Size (e.g., `16x16`) **before** creating an atlas.

2. **Add an atlas source:**
   - In the TileSet panel (bottom of editor), click **+** and choose Atlas.
   - Drag your tile sheet PNG into the Texture property.
   - Click Yes when prompted to create tiles automatically.

3. **Save the TileSet externally:**
   - Click the dropdown arrow next to the TileSet property in the Inspector.
   - Choose Save As, and save to something like `res://tilesets/town_tileset.tres`.

4. **Add more layers:**
   - Add additional TileMapLayer nodes as siblings.
   - Assign the same saved TileSet to each one.

5. **Add collision:**
   - Expand the TileSet resource in the Inspector. Under Physics Layers, click Add Element.
   - In the TileSet panel, switch to the Paint tab, select Physics Layer 0, and click each tile that should be solid.

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)        (tileset: town_tileset.tres)
├── Detail (TileMapLayer)        (tileset: town_tileset.tres)
├── Objects (TileMapLayer)       (tileset: town_tileset.tres)
└── AbovePlayer (TileMapLayer)   (tileset: town_tileset.tres)
```

### Tile Painting and Layers

**Layer organization:**

| Layer | Purpose | What Goes Here |
|-------|---------|----------------|
| Ground | Base terrain, covers every cell | Grass, dirt, water, stone |
| Detail | Sparse decorations over ground | Flowers, path edges, cracks |
| Objects | Things the player walks behind/in front of | Trees, rocks, fences, buildings |
| AbovePlayer | Always drawn on top of the player | Treetop canopy, roof overhangs |

**Collision setup:**
- Add a Physics Layer to the TileSet resource (Inspector, not per-node).
- Paint collision onto tile *definitions* in the TileSet panel's Paint tab.
- Every instance of that tile gets collision automatically.

**Painting tips:**
- Right-click while painting erases.
- Use **Ctrl+click** to eyedropper-pick a tile from the viewport.
- Use Bucket Fill for the ground layer first, then paint paths over it.
- Keep Detail sparse: a few flowers per area, not one on every tile.
- Scroll wheel zooms, middle-click-drag pans.

### Sprite Animations (AnimatedSprite2D)

**Setting up from a sprite sheet:**

1. Add an AnimatedSprite2D node. Create a New SpriteFrames resource on it.
2. In the SpriteFrames panel, rename `default` to `idle_down`.
3. Click the grid icon ("Add frames from Sprite Sheet"), select your sheet, set the grid size.
4. Click the frames you want, then Add Frames.
5. Repeat for all eight animations.

**Required animation names** (the script constructs these dynamically):

| Animation | Frames | Looping |
|-----------|--------|---------|
| `idle_down` | 1 frame (standing) | No |
| `idle_up` | 1 frame | No |
| `idle_left` | 1 frame | No |
| `idle_right` | 1 frame | No |
| `walk_down` | 3-4 frames | Yes |
| `walk_up` | 3-4 frames | Yes |
| `walk_left` | 3-4 frames | Yes |
| `walk_right` | 3-4 frames | Yes |

Set walk animation FPS to 8-10. Names must be **exact** (all lowercase, underscore separator) or the script won't find them.

**Playing animations from code:**

```gdscript
func _play_animation(action: String) -> void:
    var direction_name := _direction_to_string(facing_direction)
    var anim_name := action + "_" + direction_name
    if sprite.sprite_frames.has_animation(anim_name):
        sprite.play(anim_name)
```

### The State Machine Pattern (Enum-Based)

Define states as an enum, track the current state, and use `match` to route each frame to the correct handler. Each state is a separate function with clear responsibilities.

```gdscript
enum State { IDLE, WALK, INTERACT, DISABLED }

var current_state: State = State.IDLE


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


func _change_state(new_state: State) -> void:
    current_state = new_state
```

**State handlers** are self-contained. IDLE checks for input and transitions to WALK. WALK moves the player and transitions back to IDLE when input stops. INTERACT and DISABLED do nothing; they wait for external systems to release them.

**Transition rules:**

| From | To | Trigger |
|------|----|---------|
| IDLE | WALK | Movement input detected |
| WALK | IDLE | Movement input released |
| IDLE | INTERACT | Player presses interact near an NPC |
| INTERACT | IDLE | Dialogue finishes |
| Any | DISABLED | Cutscene, battle, or menu starts |
| DISABLED | IDLE | Cutscene, battle, or menu ends |

**External control:** other systems change the player's state through public methods, never by setting the enum directly:

```gdscript
func set_disabled(disabled: bool) -> void:
    if disabled:
        _change_state(State.DISABLED)
    else:
        _change_state(State.IDLE)


func start_interaction() -> void:
    _change_state(State.INTERACT)


func end_interaction() -> void:
    _change_state(State.IDLE)
```

### Y-Sorting

Y-sort makes children of a node render sorted by their Y position: higher on screen (lower Y value) draws first (behind), lower on screen (higher Y value) draws last (in front). This creates the illusion that the player walks behind trees and in front of paths.

**Setup:**

1. Create a Node2D child named `YSortGroup`.
2. Enable **CanvasItem > Ordering > Y Sort Enabled** on it.
3. Move the Objects TileMapLayer and the Player instance into `YSortGroup`.
4. Enable **Y Sort Enabled** on the Objects TileMapLayer too (so individual tiles sort against the player, not the entire layer as a block).
5. Set the Objects layer's **Y Sort Origin** to your tile height (e.g., `16`) so tiles sort by their bottom edge.

**Scene structure with Y-sort:**

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── YSortGroup (Node2D, y_sort_enabled = true)
│   ├── Objects (TileMapLayer, y_sort_enabled = true, y_sort_origin = 16)
│   └── Player (player.tscn instance)
└── AbovePlayer (TileMapLayer)
```

Ground and Detail are always behind everything. AbovePlayer is always on top. The YSortGroup handles the dynamic sorting between the player and objects.

### Scene Transitions and the SceneManager

**The SceneManager autoload** handles fade-out, scene change, and fade-in as a single async sequence. It lives at `res://autoloads/scene_manager.tscn` and is registered in Project Settings > Autoload.

**Changing scenes from any script:**

```gdscript
SceneManager.change_scene("res://scenes/whisperwood/whisperwood.tscn", "from_town")
```

The first argument is the scene file path. The second is the name of the Marker2D spawn point in the target scene. If omitted, it defaults to `"default"`.

**How it works internally:**

```gdscript
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
    await get_tree().scene_changed

    _place_player_at_spawn()

    _anim_player.play("fade_in")
    await _anim_player.animation_finished

    _is_transitioning = false
    transition_finished.emit()
```

**Spawn point placement:** the SceneManager finds Marker2D nodes in the `spawn_points` group and teleports the player to the one whose name matches:

```gdscript
func _place_player_at_spawn() -> void:
    var spawn_markers := get_tree().get_nodes_in_group("spawn_points")
    for marker in spawn_markers:
        if marker.name == _target_spawn_point:
            var player := get_tree().get_first_node_in_group("player")
            if player:
                player.global_position = marker.global_position
            return
```

**Exit zones** are Area2D nodes with this script:

```gdscript
extends Area2D
## A zone that triggers a scene transition when the player enters.

@export_file("*.tscn") var target_scene: String
@export var target_spawn_point: String = "default"


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        SceneManager.change_scene(target_scene, target_spawn_point)
```

### Autoloads

**What they are:** A scene or script that loads when the game starts, persists across all scene changes, and is accessible globally by name. Godot's built-in `Input`, `Engine`, and `Time` are autoloads. SceneManager is our first custom one.

**How to register one:**

1. Go to Project > Project Settings > Autoload.
2. Click the folder icon and select your `.tscn` or `.gd` file.
3. The name auto-fills (e.g., `SceneManager`). Click Add.

**When to use them:** Systems that need to survive scene changes and be accessible from anywhere: scene management, inventory, audio, game state. If a system only matters within one scene, keep it local.

**Signal lifecycle:** When a scene is freed (during a scene change), all signal connections from its nodes are cleaned up automatically. Autoload signals persist because autoloads are never freed. This is why cross-scene systems belong in autoloads.

**Autoload reference card** (updated as we build more):

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects and spawn point placement |

### Camera2D

**Setup:** Add a Camera2D as a child of the Player node.

```
Player (CharacterBody2D)
├── Sprite (AnimatedSprite2D)
├── CollisionShape2D
└── Camera2D
```

**Key properties in the Inspector:**

| Property | Value | Why |
|----------|-------|-----|
| Enabled | `true` | Makes this the active camera |
| Position Smoothing > Enabled | `true` | Smooth follow instead of rigid tracking |
| Position Smoothing > Speed | `5.0` | Balance between responsive and smooth (3-8 is the sweet spot) |
| Limit > Left | `0` | Prevent showing empty space left of the map |
| Limit > Top | `0` | Prevent showing empty space above the map |
| Limit > Right | map width in pixels | e.g., `640` for a 40-tile-wide map with 16px tiles |
| Limit > Bottom | map height in pixels | e.g., `480` for a 30-tile-tall map with 16px tiles |

**Pixel-perfect checklist** (check all four if tiles look blurry or jittery):

1. Project Settings > Rendering > Textures > Default Texture Filter: **Nearest**
2. Project Settings > Display > Window > Stretch > Mode: **canvas_items**
3. Camera2D Position Smoothing Speed: moderate (3-8)
4. Tile sheet import settings: Filter set to **Nearest** (or Off)

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| TileSet tile size doesn't match the tile sheet grid | Grid overlay is misaligned; tiles are cut off or overlap | Set Tile Size in the TileSet resource **before** creating the atlas. Must match your sprite sheet's grid (e.g., 16x16). |
| Collision set on the wrong layer | Player walks through walls, or can't walk on paths | Verify you added collision to the tile *definition* in the TileSet panel's Paint tab, not to a specific placed tile. Check that the physics layer index matches. |
| Animation name mismatch | Player freezes or plays the wrong animation | Names must be exact: `idle_down`, `walk_left`, etc. All lowercase, underscore separator. No spaces, no capitals. |
| Player not in the `player` group | Exit zones don't trigger; SceneManager can't find the player | Select the Player root node, go to Node tab > Groups, type `player`, click Add. |
| Spawn point not in the `spawn_points` group | Player appears at (0, 0) after a scene transition | Select each Marker2D spawn point, add it to the `spawn_points` group. The marker's node name must match the spawn point string passed to `change_scene()`. |
| Y-sort not enabled on the Objects TileMapLayer | Player is always in front of (or always behind) all objects | Enable Y Sort Enabled on both the YSortGroup Node2D **and** the Objects TileMapLayer. Set Y Sort Origin on the Objects layer to your tile height. |
| Texture filter set to Linear | Tiles look blurry, pixel art is smeared | Project Settings > Rendering > Textures > Default Texture Filter: Nearest. Also check the import settings on each tile sheet PNG. |
| Exit zone collision shape missing or mis-sized | Walking to the map edge does nothing | Make sure the Area2D has a CollisionShape2D child with a shape (RectangleShape2D) that covers the exit area. Check that the Area2D's collision mask includes the player's layer. |

## Official Godot Documentation

Everything referenced in Part II, organized by category. Bookmark the ones you find yourself looking up repeatedly.

### Tilemap System

- [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html): the node that renders a grid of tiles (replaces the deprecated TileMap)
- [TileSet](https://docs.godotengine.org/en/stable/classes/class_tileset.html): the resource that defines tile properties, atlas sources, and physics layers
- [Using TileSets](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html): tutorial on creating and configuring TileSets
- [Using TileMaps](https://docs.godotengine.org/en/stable/tutorials/2d/using_tilemaps.html): tutorial on painting tiles and setting up layers

### Player and Animation

- [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html): physics body for player movement with `move_and_slide()`
- [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html): node that plays frame-based animations from a SpriteFrames resource
- [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html): resource holding named animation sequences with frames, FPS, and loop settings
- [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html): alternative animation approach for keyframing arbitrary properties
- [2D Sprite Animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html): tutorial covering both AnimatedSprite2D and AnimationPlayer approaches
- [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html): defines the shape used for physics collision
- [RectangleShape2D](https://docs.godotengine.org/en/stable/classes/class_rectangleshape2d.html): rectangular collision shape used for player feet and exit zones

### Camera and Rendering

- [Camera2D](https://docs.godotengine.org/en/stable/classes/class_camera2d.html): viewport camera with smoothing, limits, zoom, and drag margins
- [Viewport and Canvas Transforms](https://docs.godotengine.org/en/stable/tutorials/2d/2d_transforms.html): how coordinates, viewports, and rendering relate in 2D

### Y-Sorting and Rendering Order

- [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html): base class for all 2D nodes; covers `y_sort_enabled`, visibility, modulate, and draw order
- [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html): 2D node used as the YSortGroup container

### Scene Transitions and Autoloads

- [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html): official guide to creating and registering autoloads
- [Change Scenes Manually](https://docs.godotengine.org/en/stable/tutorials/scripting/change_scenes_manually.html): the built-in `change_scene_to_file()` and why you often wrap it
- [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html): the tree that manages all nodes; provides `change_scene_to_file()`, `get_nodes_in_group()`, and `get_first_node_in_group()`
- [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html): renders on a separate layer; used for the fade overlay and UI
- [ColorRect](https://docs.godotengine.org/en/stable/classes/class_colorrect.html): solid-color rectangle used as the black fade overlay
- [Introduction to Animations](https://docs.godotengine.org/en/stable/tutorials/animation/introduction.html): creating property track animations in AnimationPlayer

### Interaction and Detection

- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html): trigger zone for detecting overlapping bodies (used for exit zones)
- [Marker2D](https://docs.godotengine.org/en/stable/classes/class_marker2d.html): lightweight position marker used for spawn points

### Input

- [Input](https://docs.godotengine.org/en/stable/classes/class_input.html): the global input singleton; `get_axis()`, `is_action_pressed()`
- [InputEvent](https://docs.godotengine.org/en/stable/classes/class_inputevent.html): base class for all input events

### GDScript

- [@export_file](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html): export annotation that creates a filtered file picker in the Inspector
- [Awaiting Signals](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals): how `await` pauses a function until a signal fires

## What's Next

In Part III, we add interactivity. **Module 9: Resources, the Data Layer** introduces Godot's Resource system, where we build custom data types for items, characters, and NPCs. This data layer is what the dialogue, inventory, and combat systems all read from.


---

<!-- Source: 09_resources_data_layer.md -->

# Module 9: Resources, the Data Layer

## What We Have So Far

A connected two-area game world (Willowbrook and Whisperwood) with scene transitions, a SceneManager autoload, and a player character with animation and a state machine.

## What We're Building This Module

The data architecture that powers everything from here forward. We'll learn Godot's **Resource** system and create custom data types for items, characters, and NPC information, all editable in the Inspector, all saved as `.tres` files, all type-safe.

This might seem like a detour from "making the game," but it's not. Every system we build after this (dialogue, inventory, combat, quests) will use Resources as their data backbone. Getting this right now saves us from painful refactors later.

## What is a Resource?

Every RPG you have ever played runs on a hidden spreadsheet. When the original Final Fantasy team designed their game in 1987, they kept binders full of handwritten tables: which weapon gives +5 attack, which spell costs 8 MP, which enemy has 120 HP. The game code didn't contain those numbers directly; it read them from data tables. This separation of data from code is what let the designers tune balance without rewriting programs. Godot's Resource system is the modern version of those binders: a structured, editor-friendly way to define game data that your code reads at runtime.

A **Resource** is Godot's universal data container. You've already used several:

- The `SpriteFrames` you created in Module 6 is a Resource
- The `TileSet` from Module 5 is a Resource
- The `RectangleShape2D` on your CollisionShape2D is a Resource
- Even GDScript files (`.gd`) are Resources

Resources are **data objects**: they hold information but don't have behavior tied to the scene tree. Unlike Nodes, they:

- Are not part of the scene tree
- Can be shared across multiple nodes (the same TileSet used by four TileMapLayers)
- Can be saved to disk as `.tres` files (text) or `.res` files (binary)
- Can be loaded and unloaded at any time
- Can be created and edited in the Inspector

> **See:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html), the official guide to Godot's Resource system.

> **See:** [Resource class](https://docs.godotengine.org/en/stable/classes/class_resource.html), the full API reference.

## Custom Resource Classes

Godot lets you define your own Resource types. This is very useful for game data. Instead of using raw dictionaries, you define structured data types with named, typed fields that the editor understands.

### Defining a Resource Class

First, create two new folders for our data architecture: `res://resources/` (for Resource class definitions) and `res://data/` with subdirectories `items/` and `characters/` (for data instances). Right-click in the FileSystem dock → **New Folder** to create each.

Create a new file at `res://resources/item_data.gd`:

```gdscript
extends Resource
class_name ItemData
## Data definition for an inventory item.

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM }
enum EquipSlot { NONE, WEAPON, ARMOR, ACCESSORY }

@export var id: String = ""  ## Unique identifier; match the .tres filename (e.g., "potion")
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D  ## Leave empty for now; we'll add item icons later
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var equip_slot: EquipSlot = EquipSlot.NONE

@export_group("Consumable Effects")
@export var hp_restore: int = 0
@export var mp_restore: int = 0

@export_group("Equipment Stats")
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var speed_bonus: int = 0

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0
```

Here's what's going on:

### `class_name ItemData`

This registers the class globally. After saving this file, `ItemData` becomes a recognized type everywhere in the project: in other scripts, in the Inspector, in the "Create New Resource" dialog.

### `@export` Properties

Every `@export` property appears as an editable field in the Inspector when you select a `.tres` file of this type. This is the key advantage over dictionaries: your data is **self-documenting and validated by the editor**.

### `@export_group("...")`

Groups `@export` properties under collapsible headers in the Inspector. Purely organizational, no runtime effect.

### `@export_multiline`

Shows a multiline text editor in the Inspector instead of a single-line field. Perfect for descriptions.

### Enums as Export Types

When you `@export` an enum variable, the Inspector shows a dropdown menu with the enum values. No typos, no invalid values.

## A Warning About Resources and Shared References

Resources are **shared by reference**. If you load the same `.tres` file in two places, both get the **same object in memory**. If one script modifies a field (e.g., `item.hp_restore = 99`), the other script sees the change too.

This is powerful for data that should be consistent everywhere (like item definitions). But it's dangerous for data that should be independent (like two characters each equipping the same sword). If you need an independent copy, call `resource.duplicate()`:

```gdscript
var my_copy: ItemData = shared_item.duplicate()
my_copy.hp_restore = 99  # Only affects my_copy, not the original
```

At runtime, never modify a Resource you loaded from a `.tres` unless you want the change to be visible everywhere. We'll revisit this pattern in Module 25 when we need a fresh copy of CharacterData for new games.

## Creating `.tres` Files

Now that we have the `ItemData` class, we'll create actual items.

### Method 1: In the Inspector

1. In the FileSystem dock, right-click on a folder (e.g., `res://data/items/`).
2. Choose **New Resource**.
3. Search for `ItemData` in the type list.
4. Click **Create**.
5. A new `.tres` file appears. Name it `potion.tres`.
6. Select it. The Inspector shows all the `@export` fields.
7. Fill in the values.

### Method 2: In Code (for testing)

```gdscript
var potion := ItemData.new()
potion.id = "potion"
potion.display_name = "Potion"
potion.description = "Restores 50 HP."
potion.item_type = ItemData.ItemType.CONSUMABLE
potion.hp_restore = 50
potion.buy_price = 25
potion.sell_price = 10
```

### Crystal Saga Items

Create these `.tres` files in `res://data/items/`:

**`potion.tres`** (ItemData)
- id: "potion"
- display_name: "Potion"
- description: "Restores 50 HP to one ally."
- item_type: CONSUMABLE
- hp_restore: 50
- buy_price: 25, sell_price: 10

**`ether.tres`** (ItemData)
- id: "ether"
- display_name: "Ether"
- description: "Restores 20 MP to one ally."
- item_type: CONSUMABLE
- mp_restore: 20
- buy_price: 50, sell_price: 20

**`iron_sword.tres`** (ItemData)
- id: "iron_sword"
- display_name: "Iron Sword"
- description: "A sturdy blade forged in Willowbrook."
- item_type: EQUIPMENT
- equip_slot: WEAPON
- attack_bonus: 5
- buy_price: 100, sell_price: 40

**`leather_armor.tres`** (ItemData)
- id: "leather_armor"
- display_name: "Leather Armor"
- description: "Light protection for the road ahead."
- item_type: EQUIPMENT
- equip_slot: ARMOR
- defense_bonus: 3
- buy_price: 80, sell_price: 30

## `preload()` vs `load()`, and When to Use Each

There are two ways to load resources in code:

### `preload()`

```gdscript
const POTION := preload("res://data/items/potion.tres")
```

- Loads at **compile time**: the resource is embedded in the script.
- The path must be a **string literal** (no variables).
- **Fast** at runtime because it's already loaded.
- Use for resources you always need: UI textures, commonly used items, sound effects.

### `load()`

```gdscript
var item: ItemData = load("res://data/items/" + item_id + ".tres") as ItemData
```

- Loads at **runtime**: the resource is read from disk when the line executes.
- The path can be a **variable** (dynamic paths).
- Slightly slower the first time (Godot caches after the first load).
- Use for resources loaded dynamically: items based on player inventory, enemies based on encounter data.

### The Null-Check Pattern

`load()` can fail if the path is wrong. Always check:

```gdscript
var item: ItemData = load(path) as ItemData
if item == null:
    push_error("Failed to load item: " + path)
    return
```

This pattern prevents crashes from typos in file paths. Get in the habit of checking `load()` results. You'll thank yourself when a missing file doesn't crash the game but instead prints a clear error message.

> **Note:** `preload()` will cause a compile-time error if the path is wrong, so it doesn't need a null check. `load()` fails silently (returns `null`), so always check.

## CharacterData Resource

Next, a Resource for character stats:

```gdscript
extends Resource
class_name CharacterData
## Base data for a party member or NPC.

@export var id: String = ""
@export var display_name: String = ""
@export var portrait: Texture2D
@export var overworld_sprite: SpriteFrames

@export_group("Base Stats")
@export var max_hp: int = 100
@export var max_mp: int = 20
@export var attack: int = 10
@export var defense: int = 8
@export var speed: int = 10
@export var level: int = 1

@export_group("Growth per Level")
@export var hp_growth: int = 12
@export var mp_growth: int = 4
@export var attack_growth: int = 2
@export var defense_growth: int = 1
@export var speed_growth: int = 1

# Runtime state (set in code, not in the Inspector)
var current_xp: int = 0
var current_hp: int = 0
var current_mp: int = 0
```

Save this as `res://resources/character_data.gd`.

These last three variables are intentionally **not** `@export` values. They are runtime state, not authoring data. You still set Aiden's starting stats in the Inspector, but the game tracks "how much HP does Aiden have right now?" and "how much XP has he earned toward the next level?" in these plain variables while the game is running. A value of `0` means "not initialized yet"; later modules will treat that as "start at max HP/MP" for a fresh run.

> **Important:** Always set the `id` field on every `.tres` file. The inventory system (Module 12) uses `id` to match and stack items. If two items have the same `id` (or both are left empty), they'll be treated as identical.

Create the hero's data at `res://data/characters/aiden.tres`:
- id: "aiden"
- display_name: "Aiden"
- max_hp: 120, max_mp: 15
- attack: 12, defense: 8, speed: 10
- hp_growth: 15, attack_growth: 3

We'll create Lira's data (the mage companion) in Module 21 when we implement party recruitment.

## NPCData Resource

NPCs need data too: their name, sprite, and what they say.

```gdscript
extends Resource
class_name NPCData
## Data for a non-player character in the overworld.

@export var id: String = ""
@export var display_name: String = ""
@export var sprite_frames: SpriteFrames
@export var facing_direction: Vector2 = Vector2.DOWN

@export_group("Dialogue")
@export var dialogue_lines: Array[String] = []
```

Save as `res://resources/npc_data.gd`.

This is a simple version. We'll replace `dialogue_lines: Array[String]` with a proper `DialogueLine` Resource in Module 11. When we do, you'll need to re-edit the NPC `.tres` files to use the new dialogue format, so keep your text values handy. But even this simple version is better than hardcoding NPC names and text in each scene.

## The Three-File Pattern

This pattern exists because RPGs are content-heavy games. Dragon Quest XI has over 300 items, 200 monsters, and dozens of characters, all sharing the same underlying structure but with different values. If every Potion required its own function and every Slime required its own script, the codebase would be unmanageable. By separating structure, data, and consumer, a designer can add a new healing herb by creating one data file. No code changes needed.

Resources follow a consistent pattern across the project:

```
1. Resource Class (.gd)     →  defines the structure
2. Data Instance (.tres)    →  holds specific values
3. Consumer Script (.gd)    →  uses the data at runtime
```

For items:
```
resources/item_data.gd     →  defines what an item IS (name, type, stats)
data/items/potion.tres     →  a specific item (Potion, 50 HP, 25 gold)
autoloads/inventory.gd     →  manages the player's collection of items
```

For characters:
```
resources/character_data.gd  →  defines what a character IS (stats, growth)
data/characters/aiden.tres   →  a specific character (Aiden, 120 HP, sword user)
player/player.gd             →  uses the data for movement speed, battle stats
```

This separation keeps your code clean:
- **Resource classes** change rarely (only when you add new fields)
- **Data instances** change often (tuning balance, adding content)
- **Consumer scripts** don't care about specific data values (they work with any ItemData, any CharacterData)

## Why Resources Over Dictionaries

You might be thinking: "I could just use a Dictionary for all this." You're right, and many tutorials do. But Resources have clear advantages:

| Feature | Dictionary | Resource |
|---------|-----------|----------|
| Editor integration | None (must edit in code) | Full Inspector UI |
| Type safety | None (any key, any value) | Typed `@export` properties |
| Autocompletion | None | Full IDE support |
| Sharing | Copy by reference (dangerous) | Explicit sharing via `.tres` files |
| Saving to disk | Manual JSON serialization | Built-in `.tres`/`.res` format |
| Validation | Manual checking | Editor validates types and enum values |

The editor integration alone is worth it. Game designers (including future you) can tweak item stats, enemy HP, and quest rewards without touching code.

### The Data-Driven Mindset

Resources aren't just a convenience. They represent a fundamental design philosophy: **separate your data from your logic.** This is the single most important architectural pattern in RPG development.

Consider two ways to define a Potion:

```gdscript
# Logic-driven (data baked into code):
func use_potion(target: CharacterData) -> void:
    target.current_hp = min(target.current_hp + 50, target.max_hp)
    print("Restored 50 HP!")

# Data-driven (code reads data):
func use_item(item: ItemData, target: CharacterData) -> void:
    target.current_hp = min(target.current_hp + item.hp_restore, target.max_hp)
    print("Restored " + str(item.hp_restore) + " HP!")
```

The first version requires a new function for every item. The second version works for *any* healing item: Potion (50 HP), Hi-Potion (150 HP), Elixir (full HP). One function, infinite items. The data (`hp_restore`) drives the behavior. Note that `current_hp` is runtime state on `CharacterData`, not part of the `.tres` file. We will start using it heavily in Module 18 when battles begin carrying HP and MP forward between scenes.

This pattern scales across your entire RPG. Enemies, abilities, quests, dialogue, shops, encounter tables: all of them should be **data that code acts upon**, not **code that contains data**. When you find yourself writing a `match` statement with dozens of cases for specific item names or enemy types, that's a signal to push the differences into data.

Every system we build from here on will follow this principle. The three-file pattern (class → data → consumer) is how we enforce it.

## Project Organization

Here's our growing file structure:

```
CrystalSaga/
├── autoloads/
│   ├── scene_manager.tscn
│   └── scene_manager.gd
├── data/
│   ├── characters/
│   │   └── aiden.tres
│   └── items/
│       ├── potion.tres
│       ├── ether.tres
│       ├── iron_sword.tres
│       └── leather_armor.tres
├── player/
│   ├── player.tscn
│   └── player.gd
├── resources/
│   ├── item_data.gd
│   ├── character_data.gd
│   └── npc_data.gd
├── scenes/
│   ├── willowbrook/
│   │   └── willowbrook.tscn
│   ├── whisperwood/
│   │   └── whisperwood.tscn
│   └── exit_zone.gd
└── tilesets/
    └── town_tileset.tres
```

Notice the pattern: `resources/` holds class definitions, `data/` holds instances. This keeps things clean as the project grows to dozens of items and characters.

## Engineering Contract

- **Global state:** None yet; Resources are data definitions loaded by later systems.
- **Public surface:** `ItemData`, `CharacterData`, and `NPCData` classes plus `.tres` instances under `res://data/`.
- **Invariant:** IDs and resource paths are stable because later inventory, party, quest, and save systems reference them.
- **Failure behavior:** A failed `load()` should be treated as missing content and handled before dereferencing.
- **Copy semantics:** Resource instances loaded normally are cached and shared; mutable runtime copies need explicit duplication or cache-bypass loading later.

## Engine Gotcha

Godot Resources are reference types. If you mutate a cached Resource at runtime, every holder of that same loaded instance can observe the mutation.

## What We've Learned

- **Resources** are Godot's data containers: type-safe, editor-friendly, saveable to disk.
- **Custom Resource classes** use `class_name` and `@export` to define structured data types.
- **`.tres` files** are Resource instances you create and edit in the Inspector.
- **`preload()`** loads at compile time (fast, constant paths only). **`load()`** loads at runtime (dynamic paths, must null-check).
- The **null-check pattern** (`if resource == null: push_error(...)`) prevents crashes from missing files.
- The **three-file pattern** separates structure (`.gd`), data (`.tres`), and behavior (consumer `.gd`).
- Resources are superior to dictionaries for game data: type safety, editor integration, autocompletion, and validation.
- **`@export_group()`** organizes Inspector fields. **`@export_multiline`** provides multiline text editing. Enum exports create dropdown menus.

## What You Should See

After this module:
- `ItemData`, `CharacterData`, and `NPCData` appear in the "Create New Resource" dialog
- Selecting a `.tres` file shows its typed properties in the Inspector
- Properties have appropriate editors: dropdowns for enums, texture pickers for `Texture2D`, multiline for descriptions
- No visual changes to the game yet. This module builds the foundation for everything that follows

## Next Module

We have data types. In **Module 10: NPCs and Interaction**, we'll use `NPCData` to populate Willowbrook with characters the player can approach and talk to. We'll build the interaction system: detecting nearby NPCs, showing a prompt, and handling the interaction input.


---

<!-- Source: 10_npcs_and_interaction.md -->

# Module 10: NPCs and Interaction

## What We Have So Far

A two-area game world with scene transitions, a data layer with Resource classes for items, characters, and NPCs, and an animated player with a state machine.

## What We're Building This Module

NPCs that stand in Willowbrook, face the player when approached, and respond to an interaction button press. We'll build a reusable NPC scene driven by `NPCData` resources, and create the interaction detection system.

## The Interaction Pattern

NPCs are how an RPG world comes alive. In Chrono Trigger, talking to the people of Guardia Castle tells you about the Millennial Fair, hints at the kingdom's history, and sets up plot points that pay off 20 hours later. Without NPCs, the player is just walking through empty geometry. The interaction system we're building here is the foundation for everything social in the game: shops, inns, quest-givers, lore-keepers, and story-critical characters all start with "walk up and press a button."

Most JRPGs use the same interaction flow:

1. Player walks near an NPC
2. A visual prompt appears (a floating "!" or "A" icon)
3. Player presses the interact button
4. The NPC faces the player
5. Something happens (dialogue starts, shop opens, quest updates)

We need three things to make this work:
- A way to **detect** nearby interactable objects
- A way to **signal** "the player wants to interact"
- A way for each interactable to **respond** differently

## Setting Up the Interact Input Action

First, define a custom input action for interaction.

1. Go to **Project → Project Settings → Input Map**.
2. At the top, type `interact` in the "Add New Action" field and click **Add**.
3. Click the **+** button next to the new `interact` action.
4. Press the key you want to use. **Z** is traditional for JRPGs, or use **Enter/Space**.
5. Add a second binding for gamepad: click **+** again, choose **Joypad Button**, and select the **A/Cross** button.

Now `Input.is_action_just_pressed("interact")` works for both keyboard and gamepad.

> **See:** [Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html), setting up and using custom input actions.

## The NPC Scene

Create a reusable NPC scene that can represent any character (a shopkeeper, an innkeeper, a traveler) by swapping out data.

### Scene Structure

Create a `res://npcs/` folder (this holds reusable entity scenes, separate from the area scenes in `scenes/`). Create `res://npcs/npc.tscn`:

```
NPC (CharacterBody2D)
├── Sprite (AnimatedSprite2D)
├── CollisionShape2D
├── InteractionZone (Area2D)
│   └── InteractionShape (CollisionShape2D)
└── InteractionPrompt (Label)
```

**Why CharacterBody2D?** Even though NPCs don't move, using CharacterBody2D makes them solid. The player collides with them and can't walk through them. StaticBody2D would also work, but CharacterBody2D is more flexible if we later want NPCs to wander.

### Node Configuration

**Sprite (AnimatedSprite2D):** The NPC's visual. For now, if you don't have NPC sprite sheets, set up single-frame animations using the Godot icon, just like we did for the player fallback in Module 6. Create `idle_down`, `idle_up`, `idle_left`, `idle_right` animations with the icon as the single frame. You can replace these with real NPC sprites later.

**CollisionShape2D:** The NPC's physical body. Same "feet-only" approach as the player.
- Shape: `RectangleShape2D`, small (e.g., 12x8)
- Offset downward to align with the sprite's feet

**InteractionZone (Area2D):** A larger area around the NPC that detects when the player is nearby.
- Its CollisionShape should be **larger** than the body. A circle with radius ~24px works well.
- This is the "can interact" range.

**InteractionPrompt (Label):** A text label showing "!" that appears above the NPC when the player is in range. Using a Label instead of a Sprite2D means we don't need any art assets.
- Set **Text** to `!`
- Set **Horizontal Alignment** to `Center`
- Position it above the sprite (e.g., `Vector2(-4, -20)`)
- Set **Visible** to `false` initially
- Optionally increase the font size in Theme Overrides

### The NPC Script

Create `res://npcs/npc.gd`:

```gdscript
extends CharacterBody2D
## A non-player character that can be interacted with.

signal interacted(npc: CharacterBody2D)

@export var npc_data: NPCData

var _player_in_range: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _interaction_prompt: Label = $InteractionPrompt
@onready var _interaction_zone: Area2D = $InteractionZone


func _ready() -> void:
    _interaction_zone.body_entered.connect(_on_player_entered)
    _interaction_zone.body_exited.connect(_on_player_exited)
    _interaction_prompt.visible = false

    if npc_data:
        _apply_npc_data()


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range:
        return

    if event.is_action_pressed("interact"):
        _face_player()
        get_viewport().set_input_as_handled()
        interacted.emit(self)


func _apply_npc_data() -> void:
    if npc_data.sprite_frames:
        _sprite.sprite_frames = npc_data.sprite_frames

    # Set initial facing direction
    var dir_name := _direction_to_string(npc_data.facing_direction)
    var idle_anim := "idle_" + dir_name
    if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
        _sprite.play(idle_anim)


func _face_player() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if not player:
        return

    var direction: Vector2 = (player.global_position - global_position).normalized()
    var dir_name := _direction_to_string(direction)
    var idle_anim := "idle_" + dir_name
    if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
        _sprite.play(idle_anim)


func _direction_to_string(direction: Vector2) -> String:
    if abs(direction.x) > abs(direction.y):
        return "right" if direction.x > 0 else "left"
    else:
        return "down" if direction.y >= 0 else "up"


func _on_player_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _interaction_prompt.visible = true


func _on_player_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _interaction_prompt.visible = false
```

Here's why we made these choices:

### `_unhandled_input()` vs `_input()` vs `_process()`

We use **`_unhandled_input()`** instead of checking input in `_process()`. There are three input callbacks:

Imagine you're playing Secret of Mana and you open the ring menu. You press a button to select an item, but that same press also swings your sword at the NPC behind you. That's what happens when game-world input doesn't respect UI focus. Choosing the right input callback prevents this class of bug entirely.

| Callback | When It Runs |
|----------|-------------|
| `_input(event)` | Every input event, before anything else processes it |
| `_unhandled_input(event)` | Only if no UI element or other node has consumed the event |
| `_process()` + `Input.is_action_pressed()` | Every frame, checks current input state |

`_unhandled_input()` is ideal for game-world interactions because:
- It doesn't fire when a UI menu is consuming input
- We can call `get_viewport().set_input_as_handled()` to prevent other nodes from also responding to the same press
- It's event-driven (fires once on press), not polled (checked every frame)

### The `interacted` Signal

The NPC emits `interacted(self)` when the player presses interact. It doesn't know or care what happens next: dialogue, a shop, a quest update. That's the responsibility of whatever system connects to this signal.

This is the **separation of concerns** principle. The NPC knows about proximity detection and facing. The dialogue system knows about displaying text. They communicate through signals.

### `@export var npc_data: NPCData`

Each NPC instance in the editor gets an `NPCData` resource assigned through the Inspector. Different data = different NPC. Same scene, different behavior.

## Placing NPCs in Willowbrook

Open `willowbrook.tscn` and instance the NPC scene three times:

1. Drag `npc.tscn` into the **YSortGroup** node in the scene tree (or use Instance Child Scene with YSortGroup selected). NPCs must be inside YSortGroup alongside the Player and Objects layer so they sort correctly by Y position.
2. Rename each instance: `Shopkeeper`, `Innkeeper`, `Traveler`.
3. Position them in appropriate spots: shopkeeper near a market stall, innkeeper by a house, traveler on the path.

**Important:** Add each NPC instance to the `npcs` group (select the NPC → **Node** tab → **Groups** → type `npcs` → click **Add**). The scene script below uses this group to find all NPCs.

For each NPC, create an NPCData `.tres` file in `res://data/npcs/` (create the folder first). Follow the same Inspector workflow from Module 9: right-click the folder → **New Resource** → search for `NPCData` → **Create**. Assign each to the corresponding NPC's `npc_data` export in the Inspector.

**`res://data/npcs/shopkeeper.tres`:**
- id: "shopkeeper"
- display_name: "Merchant Hilda"
- facing_direction: Vector2.DOWN
- dialogue_lines: ["Welcome to my shop!", "I have potions and gear for sale.", "Be careful in those woods."]

**`res://data/npcs/innkeeper.tres`:**
- id: "innkeeper"
- display_name: "Old Brennan"
- facing_direction: Vector2.DOWN
- dialogue_lines: ["Need a rest? 10 gold for a night.", "You look like you've seen some trouble."]

**`res://data/npcs/traveler.tres`:**
- id: "traveler"
- display_name: "Wandering Fynn"
- facing_direction: Vector2.LEFT
- dialogue_lines: ["I lost something precious in the Whisperwood...", "A pendant, silver with a blue stone.", "If you find it, I'd be forever grateful."]

> **JRPG Pattern:** Notice how the traveler's dialogue sets up a side quest. We're not implementing the quest system yet (that's Module 20), but the dialogue seeds the idea in the player's mind. Classic JRPGs do this constantly. NPCs hint at things that become important later.

### Using the Player's INTERACT State

When the player interacts with an NPC, we should transition the player to the INTERACT state (Module 6). For now, we'll connect this in the Willowbrook scene script.

Create `res://scenes/willowbrook/willowbrook.gd` and attach it to the root `Willowbrook` node (if you already have a script attached from a previous module, replace its contents):

```gdscript
extends Node2D
## The town of Willowbrook, Crystal Saga's starting village.


func _ready() -> void:
    # Connect NPC interaction signals
    for npc in get_tree().get_nodes_in_group("npcs"):
        npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: CharacterBody2D) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("start_interaction"):
        player.start_interaction()

    # For now, just print the dialogue. Module 11 will add the real dialogue UI.
    if npc.npc_data:
        for line in npc.npc_data.dialogue_lines:
            print(npc.npc_data.display_name + ": " + line)

    # End interaction after a short delay (placeholder)
    await get_tree().create_timer(0.5).timeout
    if player and player.has_method("end_interaction"):
        player.end_interaction()
```

This is a temporary placeholder. In Module 11, we'll replace the `print()` calls with a proper dialogue box. But it demonstrates the flow: NPC detects interaction → emits signal → scene script handles it → player enters INTERACT state → interaction completes → player returns to IDLE.

## Interaction Detection: RayCast2D Alternative

We used Area2D on the NPC for detection. There's an alternative approach: a **RayCast2D** on the player that points in the facing direction.

```
Player (CharacterBody2D)
├── Sprite
├── CollisionShape2D
├── Camera2D
└── InteractRay (RayCast2D)   ← points forward, detects NPCs
```

The RayCast approach:
- Points in the player's facing direction
- Checks if it hits an interactable
- The interact button only works if the ray is hitting something

**Pros:** More precise, since you can only interact with what you're facing. No "interacting with the NPC behind you" situations.
**Cons:** More setup, requires updating the ray direction when the player turns.

Both approaches are valid. We're using the Area2D approach because it's simpler to set up and understand. If you want to switch later, the NPC's `interacted` signal works the same either way.

> **See:** [RayCast2D](https://docs.godotengine.org/en/stable/classes/class_raycast2d.html), for the ray-based detection approach.

## Engineering Contract

- **Global state:** None; interaction range and prompts are local to each NPC instance.
- **Public surface:** NPC scenes expose an interaction signal or method and carry `NPCData`.
- **Invariant:** Only the player group can trigger interaction prompts and dialogue starts.
- **Failure behavior:** Missing `NPCData` should disable interaction or show a safe fallback line.
- **Copy semantics:** NPCData is shared content data; per-NPC runtime flags should not be written into the Resource.

## Engine Gotcha

Area2D overlap signals depend on collision layers and masks. If the prompt never appears, inspect the Area2D and player collision setup before changing dialogue code.

## What We've Learned

- **Custom input actions** (`interact`) work with both keyboard and gamepad. Define them in Project Settings → Input Map.
- The **interaction pattern**: Area2D detection zone → prompt appears → player presses interact → NPC responds via signal.
- **`_unhandled_input()`** is the right callback for game-world interactions. It respects UI focus and can mark events as handled.
- **`get_viewport().set_input_as_handled()`** prevents multiple nodes from responding to the same input.
- **`@export var npc_data: NPCData`** lets each NPC instance use different data without a separate script.
- The `interacted` signal keeps NPCs decoupled from dialogue, shops, and quests.
- **Scene scripts** (like `willowbrook.gd`) wire NPCs to game systems. The NPC doesn't know about dialogue; the scene connects them.
- **Triggers vs actions**: the NPC's Area2D + input detection is the *trigger* (when and where something happens). The response (dialogue, shop, quest update) is the *action* (what happens). This separation is deliberate; the same NPC scene works for shopkeepers, quest-givers, and flavor characters because the trigger mechanism is identical. Only the action wired up in the scene script differs.
- The player's **INTERACT state** (Module 6) freezes movement during interactions.

## What You Should See

When you press F6 (running Willowbrook):
- Three NPCs stand in town
- Walking near an NPC shows an interaction prompt icon
- Walking away hides the prompt
- Pressing the interact key near an NPC:
  - The NPC faces the player
  - Dialogue lines print to the Output panel
  - The player stops moving for a moment
  - The player resumes normal movement after the interaction

## Next Module

We can interact with NPCs, but the dialogue is just `print()` output. In **Module 11: The Dialogue System**, we'll build a proper dialogue box UI with a typewriter text effect, speaker names, multi-page conversations, and choice/branching dialogue. The NPCs will finally talk like real JRPG characters.


---

<!-- Source: 11_dialogue_system.md -->

# Module 11: The Dialogue System

## What We Have So Far

NPCs in Willowbrook that detect the player and emit interaction signals. But dialogue is just `print()` output. Time to fix that.

## What We're Building This Module

A full dialogue box UI: text appears with a typewriter effect, the speaker's name is displayed, conversations span multiple pages, and the player can make choices during branching dialogue. Players spend more time reading dialogue than doing almost anything else in a JRPG, so getting the textbox right matters.

The dialogue box is arguably the most important UI element in any JRPG. In Undertale, every character has a distinct voice expressed through text speed, font, and box style. Sans speaks in lowercase, Papyrus in all-caps, and Flowey's text box literally breaks apart during intense moments. Even without going that far, the difference between a raw `print()` dump and a proper typewriter textbox is the difference between reading a script and experiencing a conversation.

## UI Fundamentals: Control Nodes

Game UI needs to work at any screen size. When a player resizes the window or plays on a phone, the dialogue box should still be at the bottom, the health bar should still be in the corner, and menus should still be centered. Node2D nodes use fixed pixel coordinates that break when the resolution changes. Godot's Control nodes solve this with anchors and containers, the same layout system that powers every web browser and phone app, adapted for games.

Godot's UI system is built on **Control** nodes, a family of nodes designed specifically for user interfaces. Unlike Node2D (which uses pixel coordinates), Control nodes use **anchors**, **margins**, and **containers** to create responsive layouts.

Key Control nodes we'll use:

| Node | Purpose |
|------|---------|
| `PanelContainer` | A styled rectangle (background for our dialogue box) |
| `MarginContainer` | Adds padding around its child |
| `VBoxContainer` | Stacks children vertically |
| `HBoxContainer` | Stacks children horizontally |
| `Label` | Displays plain text |
| `RichTextLabel` | Displays text with BBCode formatting |
| `TextureRect` | Displays an image |

Control nodes automatically size and position themselves based on their parent container. **Anchors** define where a node pins itself relative to its parent (e.g., "Bottom Wide" means "stick to the bottom edge and stretch the full width"). **Containers** like VBoxContainer handle child arrangement automatically: you add children and the container lays them out. This means our dialogue box will work correctly regardless of screen resolution.

> **See:** [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html), how Control nodes position themselves.

> **See:** [GUI containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html), automatic layout with VBox, HBox, Grid, and Margin containers.

> **See:** [Control node gallery](https://docs.godotengine.org/en/stable/tutorials/ui/control_node_gallery.html), visual catalog of all Control nodes.

## The DialogueLine Resource

Before building the UI, we need to define the data format for dialogue. We created a basic `NPCData` with `dialogue_lines: Array[String]` in Module 9. Now we'll make a proper dialogue line resource.

Create `res://resources/dialogue_line.gd`:

```gdscript
extends Resource
class_name DialogueLine
## A single line of dialogue with speaker information.

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
```

Now update `NPCData` in `res://resources/npc_data.gd` to use it:

```gdscript
extends Resource
class_name NPCData
## Data for a non-player character in the overworld.

@export var id: String = ""
@export var display_name: String = ""
@export var sprite_frames: SpriteFrames
@export var facing_direction: Vector2 = Vector2.DOWN

@export_group("Dialogue")
@export var dialogue: Array[DialogueLine] = []
```

The `dialogue` array replaces the old `dialogue_lines`. Update each NPC `.tres` file to use the new format:

1. Open the `.tres` file (e.g., `shopkeeper.tres`) in the Inspector.
2. The old `dialogue_lines` field will be gone (replaced by `dialogue`). Click the `dialogue` array.
3. Click **Add Element**. An empty slot appears.
4. Click the empty slot and choose **New DialogueLine**.
5. Expand the new DialogueLine and fill in `speaker_name` (e.g., "Merchant Hilda") and `text` (the dialogue line). Leave `portrait` empty for now.
6. Repeat for each line of dialogue.

> **Tip:** Creating sub-resources inside arrays can feel clunky at first. Each array element needs to be clicked, then "New DialogueLine" selected, then expanded to fill in fields. It's tedious but straightforward.

> **Spiral:** This is the Resource pattern from Module 9 in action. We define a data type (`DialogueLine`), use it in another Resource (`NPCData`), and the editor gives us a clean UI for editing dialogue without touching code.

## Building the Dialogue Box Scene

Create `res://ui/dialogue_box/dialogue_box.tscn`:

### Scene Tree

```
DialogueBox (CanvasLayer, layer = 10)
└── PanelContainer
    └── MarginContainer
        └── VBoxContainer
            ├── SpeakerLabel (Label)
            └── TextLabel (RichTextLabel)
```

### Node Configuration

**DialogueBox (CanvasLayer)**
- Layer: `10` (draws above the game world but below the SceneManager's transition overlay at layer 100)

**PanelContainer**
- Layout → **Anchor Preset**: choose "Bottom Wide" from the preset dropdown (at the top of the 2D viewport when a Control node is selected)
- "Bottom Wide" sets all anchors to 1.0, which pins the panel to the very bottom edge. We want it to take up the bottom 25% of the screen, so manually change the **Top** anchor from `1.0` to `0.75` in the Inspector under **Layout → Anchor Points**
- Final anchors: left=0, right=1, bottom=1, top=0.75

**MarginContainer**
- Under Theme Overrides → Constants, set margins: left=16, right=16, top=12, bottom=12

**SpeakerLabel (Label)**
- Text: "" (empty, filled at runtime)
- Horizontal Alignment: Left
- Add a bold font or increase font size to distinguish the speaker name

**TextLabel (RichTextLabel)**
- BBCode Enabled: `true`
- Fit Content: `true`
- Scroll Active: `false`
- Text: "" (empty, filled at runtime)

The result is a dark panel at the bottom of the screen with a speaker name on top and dialogue text below, the classic JRPG textbox.

## The Typewriter Effect

The typewriter effect reveals text character by character, as if being typed. This is a staple of JRPG dialogue and gives the player time to read along.

We achieve this by tweening `visible_ratio` on the RichTextLabel:

```gdscript
# visible_ratio goes from 0.0 (no text visible) to 1.0 (all text visible)
var tween := create_tween()
tween.tween_property(text_label, "visible_ratio", 1.0, duration)
```

Why `visible_ratio` and not `visible_characters`?

- **`visible_characters`** is an `int`, the number of characters shown. Tweening it produces discrete jumps (0 chars, 1 char, 2 chars). For short lines, this looks choppy.
- **`visible_ratio`** is a `float` from 0.0 to 1.0. Tweening it produces smooth character-by-character reveal at a consistent rate regardless of line length.

> **See:** [RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html), the `visible_ratio` and `visible_characters` properties.

> **See:** [BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html), formatting text with colors, bold, italics, and more.

## The Dialogue Box Script

Create `res://ui/dialogue_box/dialogue_box.gd`:

```gdscript
extends CanvasLayer
## Displays dialogue with a typewriter effect.

signal dialogue_started
signal dialogue_finished
signal line_advanced

@export var characters_per_second: float = 30.0

var _lines: Array[DialogueLine] = []
var _current_line_index: int = 0
var _is_typing: bool = false
var _current_tween: Tween = null

@onready var _panel: PanelContainer = $PanelContainer
@onready var _speaker_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerLabel
@onready var _text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/TextLabel


func _ready() -> void:
    _panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
    if not _panel.visible:
        return

    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
        get_viewport().set_input_as_handled()

        if _is_typing:
            # Skip the typewriter effect: show all text immediately
            _skip_typing()
        else:
            # Advance to the next line
            _advance()


func start_dialogue(lines: Array[DialogueLine]) -> void:
    if lines.is_empty():
        return

    _lines = lines
    _current_line_index = 0
    _panel.visible = true
    dialogue_started.emit()
    _show_current_line()


func _show_current_line() -> void:
    var line: DialogueLine = _lines[_current_line_index]

    _speaker_label.text = line.speaker_name
    _speaker_label.visible = line.speaker_name != ""
    _text_label.text = line.text
    _text_label.visible_ratio = 0.0

    _start_typing()


func _start_typing() -> void:
    _is_typing = true

    # Calculate duration based on text length and speed
    var char_count: int = _text_label.get_total_character_count()
    var duration: float = char_count / characters_per_second

    # Kill any existing tween before creating a new one
    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()

    _current_tween = create_tween()
    _current_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
    _current_tween.finished.connect(_on_typing_finished)


func _skip_typing() -> void:
    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()
    _text_label.visible_ratio = 1.0
    _is_typing = false


func _on_typing_finished() -> void:
    _is_typing = false


func _advance() -> void:
    _current_line_index += 1
    line_advanced.emit()

    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _close() -> void:
    _panel.visible = false
    _lines.clear()
    _current_line_index = 0
    dialogue_finished.emit()
```

### Key Design Points

**Two-press interaction:**
- First press while text is typing: **skip** to show all text immediately.
- Press when text is fully shown: **advance** to the next line or close.

This is the standard JRPG dialogue control. Players who read fast can skip ahead, while slow readers have time.

**Tween lifecycle management:**
```gdscript
if _current_tween and _current_tween.is_valid():
    _current_tween.kill()
```

Before creating a new tween, we kill any existing one. This prevents overlapping tweens if the player advances quickly. `create_tween()` tweens are automatically cleaned up when the creating node is freed, but we might create multiple tweens during a single dialogue sequence.

> **Warning:** A Tween stored in a variable can outlive its creating node if the variable is held elsewhere. In our case, `_current_tween` is a member of the dialogue box itself, so it's cleaned up when the box is freed. But be careful with Tweens passed between objects.

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html), the Tween API, including `kill()`, `is_valid()`, and chaining methods.

## Connecting Dialogue to NPCs

Now we'll wire the dialogue system into the game. Add the dialogue box to the scene.

### Option A: Instance in Each Scene

Add an instance of `dialogue_box.tscn` to each scene that needs dialogue (Willowbrook, Whisperwood, etc.).

### Option B: Make It an Autoload (Better)

Since dialogue can happen anywhere, it's a good candidate for global access. But instead of a full autoload, we can instance it in the SceneManager (which is already an autoload and has a CanvasLayer).

For simplicity, we'll use **Option A** for now: instance the dialogue box in Willowbrook. We can refactor to a global approach later.

Instance `dialogue_box.tscn` as a **direct child of the `Willowbrook` root node** (not inside YSortGroup). The scene script below references it as `$DialogueBox`, so the name must match exactly.

Replace the contents of `willowbrook.gd` (the Module 10 version with `print()` dialogue is now obsolete):

```gdscript
extends Node2D
## The town of Willowbrook, Crystal Saga's starting village.

@onready var _dialogue_box: CanvasLayer = $DialogueBox


func _ready() -> void:
    _dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

    for npc in get_tree().get_nodes_in_group("npcs"):
        npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: CharacterBody2D) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("start_interaction"):
        player.start_interaction()

    if npc.npc_data and not npc.npc_data.dialogue.is_empty():
        _dialogue_box.start_dialogue(npc.npc_data.dialogue)


func _on_dialogue_finished() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("end_interaction"):
        player.end_interaction()
```

The flow:
1. Player presses interact near an NPC
2. NPC emits `interacted`
3. `willowbrook.gd` receives the signal
4. Player enters INTERACT state (frozen)
5. Dialogue box starts displaying lines
6. Player presses interact to advance through lines
7. When all lines are shown, `dialogue_finished` emits
8. Player returns to IDLE state

## Choice Dialogue (Branching)

Player choice is what separates a cutscene from a conversation. In Dragon Quest V, the game asks whether you want to marry Bianca or Nera, a choice that changes your party composition, your children's hair color, and NPC dialogue for the rest of the game. Even simple yes/no prompts like "Stay at the inn for 10 gold?" give the player agency.

Some dialogue needs player choices: "Yes/No" questions, multiple response options. We'll extend the system to support this.

First, **replace the entire contents of `res://resources/dialogue_line.gd`** with this updated version that adds a `choices` field:

```gdscript
extends Resource
class_name DialogueLine
## A single line of dialogue with speaker information and optional choices.

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var choices: Array[String] = []  # Empty = no choice, just advance
```

When `choices` is non-empty, instead of advancing on press, we show choice buttons.

Add a ChoiceContainer node to the dialogue box scene:

1. Open `dialogue_box.tscn`.
2. Select the **VBoxContainer** (the one containing SpeakerLabel and TextLabel).
3. Add a **VBoxContainer** child to it. Rename it to `ChoiceContainer`.
4. This is where choice buttons will appear dynamically.

Your updated scene tree:

```
DialogueBox (CanvasLayer)
└── PanelContainer
    └── MarginContainer
        └── VBoxContainer
            ├── SpeakerLabel (Label)
            ├── TextLabel (RichTextLabel)
            └── ChoiceContainer (VBoxContainer)
                # Buttons are added dynamically
```

Add the following to `dialogue_box.gd`: a new signal, a new `@onready` variable, and **replace** the existing `_show_current_line()` and `_advance()` methods with these updated versions. Also add the new `_show_choices()` and `_on_choice_pressed()` methods:

```gdscript
signal choice_made(choice_index: int)

@onready var _choice_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ChoiceContainer


func _show_current_line() -> void:
    var line: DialogueLine = _lines[_current_line_index]

    _speaker_label.text = line.speaker_name
    _speaker_label.visible = line.speaker_name != ""
    _text_label.text = line.text
    _text_label.visible_ratio = 0.0

    # Clear old choices
    for child in _choice_container.get_children():
        child.queue_free()
    _choice_container.visible = false

    _start_typing()


func _advance() -> void:
    var current_line: DialogueLine = _lines[_current_line_index]

    # If this line has choices, show them instead of advancing
    if not current_line.choices.is_empty() and _choice_container.get_child_count() == 0:
        _show_choices(current_line.choices)
        return

    _current_line_index += 1
    line_advanced.emit()

    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _show_choices(choices: Array[String]) -> void:
    _choice_container.visible = true

    for i in choices.size():
        var button := Button.new()
        button.text = choices[i]
        # .bind(i) attaches the value of i to the callback. When this button
        # is pressed, _on_choice_pressed receives i as its argument. Without
        # .bind(), we'd have no way to know which button was pressed.
        button.pressed.connect(_on_choice_pressed.bind(i))
        _choice_container.add_child(button)

    # Focus the first button for keyboard/gamepad navigation
    await get_tree().process_frame
    if _choice_container.get_child_count() > 0:
        _choice_container.get_child(0).grab_focus()


func _on_choice_pressed(index: int) -> void:
    choice_made.emit(index)
    _choice_container.visible = false

    # Clear choices and advance
    for child in _choice_container.get_children():
        child.queue_free()

    _current_line_index += 1
    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()
```

### The Complete `dialogue_box.gd`

After merging the base script with the choice additions, your complete file should look like this:

```gdscript
extends CanvasLayer
## Displays dialogue with a typewriter effect and optional choices.

signal dialogue_started
signal dialogue_finished
signal line_advanced
signal choice_made(choice_index: int)

@export var characters_per_second: float = 30.0

var _lines: Array[DialogueLine] = []
var _current_line_index: int = 0
var _is_typing: bool = false
var _current_tween: Tween = null

@onready var _panel: PanelContainer = $PanelContainer
@onready var _speaker_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerLabel
@onready var _text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/TextLabel
@onready var _choice_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ChoiceContainer


func _ready() -> void:
    _panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
    if not _panel.visible:
        return
    if _choice_container.visible:
        return  # Let the Button nodes handle input during choices

    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
        get_viewport().set_input_as_handled()

        if _is_typing:
            _skip_typing()
        else:
            _advance()


func start_dialogue(lines: Array[DialogueLine]) -> void:
    if lines.is_empty():
        return

    _lines = lines
    _current_line_index = 0
    _panel.visible = true
    dialogue_started.emit()
    _show_current_line()


func _show_current_line() -> void:
    var line: DialogueLine = _lines[_current_line_index]

    _speaker_label.text = line.speaker_name
    _speaker_label.visible = line.speaker_name != ""
    _text_label.text = line.text
    _text_label.visible_ratio = 0.0

    # Clear old choices
    for child in _choice_container.get_children():
        child.queue_free()
    _choice_container.visible = false

    _start_typing()


func _start_typing() -> void:
    _is_typing = true

    var char_count: int = _text_label.get_total_character_count()
    var duration: float = char_count / characters_per_second

    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()

    _current_tween = create_tween()
    _current_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
    _current_tween.finished.connect(_on_typing_finished)


func _skip_typing() -> void:
    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()
    _text_label.visible_ratio = 1.0
    _is_typing = false


func _on_typing_finished() -> void:
    _is_typing = false


func _advance() -> void:
    var current_line: DialogueLine = _lines[_current_line_index]

    if not current_line.choices.is_empty() and _choice_container.get_child_count() == 0:
        _show_choices(current_line.choices)
        return

    _current_line_index += 1
    line_advanced.emit()

    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _show_choices(choices: Array[String]) -> void:
    _choice_container.visible = true

    for i in choices.size():
        var button := Button.new()
        button.text = choices[i]
        button.pressed.connect(_on_choice_pressed.bind(i))
        _choice_container.add_child(button)

    await get_tree().process_frame
    if _choice_container.get_child_count() > 0:
        _choice_container.get_child(0).grab_focus()


func _on_choice_pressed(index: int) -> void:
    choice_made.emit(index)
    _choice_container.visible = false

    for child in _choice_container.get_children():
        child.queue_free()

    _current_line_index += 1
    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _close() -> void:
    _panel.visible = false
    _lines.clear()
    _current_line_index = 0
    dialogue_finished.emit()
```

> **Note:** In this basic implementation, choices don't affect what happens next; the dialogue continues linearly. In Module 20 (Quests), we'll connect choices to game flags that change story outcomes.

> **Note:** `grab_focus()` on the first button enables keyboard/gamepad navigation. Players can use up/down arrows to select and Enter/interact to confirm, no mouse needed. This is critical for JRPGs.

> **See:** [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html), how focus works for keyboard/gamepad UI navigation.

## Styling the Dialogue Box

The default PanelContainer looks plain. You can style it with a theme:

1. Select the PanelContainer.
2. In the Inspector, find **Theme Override → Styles → Panel**.
3. Create a **New StyleBoxFlat**.
4. Set:
   - **BG Color:** A dark blue or dark gray (e.g., `Color(0.1, 0.1, 0.2, 0.9)`)
   - **Border Width:** 2px on all sides
   - **Border Color:** White or light blue
   - **Corner Radius:** 4px for slightly rounded corners

This gives you the classic JRPG text box look. You can refine it later with custom fonts and themes.

## Freezing the Player During Dialogue

This is already handled by our state machine (Module 6). When `start_interaction()` is called, the player enters INTERACT state and stops processing input. When `end_interaction()` is called, the player returns to IDLE.

The dialogue box's `_unhandled_input` handles the interact/accept buttons for advancing text. Since the player's INTERACT state doesn't consume input events, the dialogue box can receive them normally.

## Engineering Contract

- **Global state:** None; the dialogue box is a UI scene controlled by its caller.
- **Public surface:** `start_dialogue(lines)`, `dialogue_finished`, and `choice_made`.
- **Invariant:** Input advances text only when the dialogue panel is visible and choices are not currently owning focus.
- **Failure behavior:** Empty dialogue arrays close cleanly instead of indexing past the end.
- **Copy semantics:** DialogueLine resources are read by the UI; transient UI state such as current line index stays inside the dialogue box.

## Engine Gotcha

Use `_unhandled_input()` for dialogue advance so UI buttons and focused choices get first chance to consume events. Otherwise the same accept press can both choose an option and advance the next line.

## What We've Learned

- **Control nodes** (PanelContainer, MarginContainer, VBoxContainer, Label, RichTextLabel) create responsive UI layouts.
- **CanvasLayer** renders UI on top of the game world at a specified layer.
- The **typewriter effect** uses `visible_ratio` (a float, tweened from 0.0 to 1.0) for smooth character reveal.
- **Two-press interaction:** first press skips typing, second press advances to the next line.
- **Choice dialogue** uses dynamically created Buttons with `grab_focus()` for keyboard navigation.
- **`DialogueLine`** is a Resource with speaker name, text, and optional choices, giving you clean data separation.
- **Tween lifecycle:** kill existing tweens before creating new ones. `create_tween()` tweens are auto-cleaned when the node is freed.
- `_unhandled_input()` respects UI focus: the dialogue box gets input events after UI buttons have had their chance.

## What You Should See

When you press F6 (running Willowbrook):
- Walk up to an NPC and press interact
- A dialogue box appears at the bottom of the screen
- The speaker's name is shown above the text
- Text appears character by character (typewriter effect)
- Press interact to skip the typing (text appears instantly)
- Press interact again to advance to the next line
- After the last line, the dialogue box disappears
- The player can move again

To test the choice system, edit one of your NPC `.tres` files (e.g., the innkeeper) and add `["Yes", "No"]` to the `choices` array on the last `DialogueLine`. When that line appears, two buttons should show up instead of auto-advancing. Selecting a choice dismisses the buttons and continues.

## Next Module

We have NPCs who talk. In **Module 12: The Inventory System**, we'll build an inventory the player can open with a menu key, display items in a grid, and use consumable items like potions. This is the first game system that requires both data (Resources from Module 9) and UI (patterns from this module) working together.


---

<!-- Source: 12_inventory_system.md -->

# Module 12: The Inventory System

## What We Have So Far

NPCs with a dialogue system, custom Resources for items and characters, scene transitions, and a connected two-area world. We've defined items like Potion and Iron Sword as `.tres` files, but the player can't actually carry or use them yet.

## What We're Building This Module

An inventory system with a global autoload for tracking items, a UI screen the player can open with a key, and the ability to use consumable items. We'll keep this focused; equipment and shops come in Module 21.

Inventory management is one of the defining verbs of the RPG genre. In Pokemon, deciding which six Pokemon to carry and which four moves each one knows is the core strategic layer. In Final Fantasy, choosing whether to spend your last Elixir on a random battle or save it for the boss creates tension that persists between fights. An inventory isn't just a list of stuff. It's a resource management puzzle that runs throughout the entire game.

## InventoryManager Autoload

The inventory needs to persist across scene changes, so it's an autoload.

Create `res://autoloads/inventory_manager.gd`:

```gdscript
extends Node
## Manages the player's inventory. Autoload, accessible as InventoryManager.

signal item_added(item: ItemData, new_count: int)
signal item_removed(item: ItemData, new_count: int)
signal inventory_changed
signal gold_changed(new_amount: int)

var gold: int = 100  # Starting gold
var _items: Array[Dictionary] = []  # [{item: ItemData, count: int}]


func add_item(item: ItemData, amount: int = 1) -> void:
    if amount <= 0:
        return

    for entry in _items:
        if entry.item.id == item.id:
            entry.count += amount
            item_added.emit(item, entry.count)
            inventory_changed.emit()
            return

    _items.append({item = item, count = amount})
    item_added.emit(item, amount)
    inventory_changed.emit()


func remove_item(item: ItemData, amount: int = 1) -> bool:
    if amount <= 0:
        return false

    for i in _items.size():
        if _items[i].item.id == item.id:
            var entry: Dictionary = _items[i]
            if entry.count < amount:
                return false

            entry.count -= amount
            var remaining: int = entry.count
            if remaining <= 0:
                _items.remove_at(i)
                remaining = 0
            else:
                _items[i] = entry
            item_removed.emit(item, remaining)
            inventory_changed.emit()
            return true
    return false


func has_item(item_id: String, amount: int = 1) -> bool:
    for entry in _items:
        if entry.item.id == item_id and entry.count >= amount:
            return true
    return false


func get_item_count(item_id: String) -> int:
    for entry in _items:
        if entry.item.id == item_id:
            return entry.count
    return 0


func get_all_items() -> Array[Dictionary]:
    return _items.duplicate(true)


func get_consumables() -> Array[Dictionary]:
    return _items.filter(
        func(entry: Dictionary) -> bool:
            return entry.item.item_type == ItemData.ItemType.CONSUMABLE
    ).duplicate(true)


func add_gold(amount: int) -> void:
    gold += amount
    gold_changed.emit(gold)


func spend_gold(amount: int) -> bool:
    if gold >= amount:
        gold -= amount
        gold_changed.emit(gold)
        return true
    return false
```

Register it as an autoload: **Project → Project Settings → Autoload** → add `inventory_manager.gd` as `InventoryManager`.

### Design Notes

**Signal-driven updates:** Every change emits a signal (`item_added`, `item_removed`, `inventory_changed`, `gold_changed`). The UI listens to these signals and updates itself. The InventoryManager never touches UI directly.

**ID-based matching:** Items are matched by their `id` string (`item.id == item_id`), not by object reference. This means two different `ItemData` instances with the same `id` are treated as the same item, which is important when loading from saves.

**`remove_item` returns bool:** Callers can check if the removal succeeded. Trying to remove an item the player doesn't have returns `false`.

**Autoload reference card:**

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| **InventoryManager** | **12** | **Item storage, add/remove, signals** |

## Adding a Menu Input Action

Before building the UI, define a `menu` action for opening the inventory:

1. **Project → Project Settings → Input Map**
2. Add a new action: `menu`
3. Bind it to **Tab** (or **I**) and the **Start/Menu** gamepad button

> **Note:** Avoid binding `menu` to Escape. Escape is already mapped to `ui_cancel`, which we'll use to *close* the inventory. Using the same key for both open and close works thanks to our `elif` structure in the script, but using different keys (Tab to open, Escape to close) is clearer and avoids confusion.

## The Inventory UI

Create `res://ui/inventory/inventory_screen.tscn`:

### Scene Tree

```
InventoryScreen (CanvasLayer, layer = 20)
└── PanelContainer (full screen, semi-transparent background)
    └── MarginContainer
        └── VBoxContainer
            ├── Header (HBoxContainer)
            │   ├── TitleLabel (Label: "Inventory")
            │   └── GoldLabel (Label: "Gold: 100")
            ├── ItemGrid (GridContainer, columns = 5)
            │   # ItemSlot scenes instanced here dynamically
            └── DescriptionLabel (RichTextLabel)
```

### The Item Slot Scene

Each slot in the grid is its own small scene. Create `res://ui/inventory/item_slot.tscn`:

```
ItemSlot (PanelContainer)
├── MarginContainer
│   └── VBoxContainer
│       ├── Icon (TextureRect)
│       └── CountLabel (Label)
```

Select the `Icon` (TextureRect) node and set **Custom Minimum Size** to `Vector2(32, 32)` so each slot has a reasonable size even without an icon texture.

> **Note:** Since we haven't set item icons in our `.tres` files yet, the inventory slots will show blank icon areas. That's expected. You'll see the count label (e.g., "3" for potions). To add placeholder icons, drag `res://icon.svg` into the `icon` field of each item `.tres` file.

Create `res://ui/inventory/item_slot.gd`:

```gdscript
extends PanelContainer
## A single item slot in the inventory grid.

signal slot_selected(item: ItemData)
signal slot_activated(item: ItemData)

var item_data: ItemData
var count: int = 0

@onready var _icon: TextureRect = $MarginContainer/VBoxContainer/Icon
@onready var _count_label: Label = $MarginContainer/VBoxContainer/CountLabel


func setup(item: ItemData, item_count: int) -> void:
    item_data = item
    count = item_count
    _icon.texture = item.icon
    _count_label.text = str(item_count) if item_count > 1 else ""

    # Make the slot focusable for keyboard/gamepad navigation
    focus_mode = Control.FOCUS_ALL


func _gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
        slot_activated.emit(item_data)
        accept_event()


func _notification(what: int) -> void:
    if what == NOTIFICATION_FOCUS_ENTER:
        slot_selected.emit(item_data)
```

> **See:** [TextureRect](https://docs.godotengine.org/en/stable/classes/class_texturerect.html): displaying images in UI.

> **See:** [GridContainer](https://docs.godotengine.org/en/stable/classes/class_gridcontainer.html): automatic grid layout for child nodes.

### The Inventory Screen Script

Create `res://ui/inventory/inventory_screen.gd`:

```gdscript
extends CanvasLayer
## The inventory screen. Opens/closes with the menu key.

const ItemSlotScene := preload("res://ui/inventory/item_slot.tscn")

@onready var _panel: PanelContainer = $PanelContainer
@onready var _item_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/ItemGrid
@onready var _gold_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Header/GoldLabel
@onready var _description_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel

var _is_open: bool = false


func _ready() -> void:
    _panel.visible = false
    InventoryManager.inventory_changed.connect(_refresh)
    InventoryManager.gold_changed.connect(_on_gold_changed)
    _update_gold_display()


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") and _is_open:
        close()
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("menu") and not _is_open:
        open()
        get_viewport().set_input_as_handled()


func open() -> void:
    _show()


func open_from_pause() -> void:
    _show()


func _show() -> void:
    _is_open = true
    _panel.visible = true
    get_tree().paused = true
    _refresh()


func close() -> void:
    _is_open = false
    _panel.visible = false
    get_tree().paused = false


func _refresh() -> void:
    # free() removes nodes immediately this frame. queue_free() defers removal
    # to the end of the frame. When repopulating a container, free() prevents
    # old and new children from briefly coexisting and causing layout flicker.
    for child in _item_grid.get_children():
        child.free()

    # Create slots for each item
    var items := InventoryManager.get_all_items()
    for entry in items:
        var slot: PanelContainer = ItemSlotScene.instantiate()
        _item_grid.add_child(slot)
        slot.setup(entry.item, entry.count)
        slot.slot_selected.connect(_on_slot_selected)
        slot.slot_activated.connect(_on_slot_activated)

    # Focus the first slot (deferred so the slot is ready)
    if _item_grid.get_child_count() > 0:
        _item_grid.get_child(0).call_deferred("grab_focus")


func _on_slot_selected(item: ItemData) -> void:
    _description_label.text = item.description


func _on_slot_activated(item: ItemData) -> void:
    if item.item_type == ItemData.ItemType.CONSUMABLE:
        _use_consumable(item)


func _use_consumable(item: ItemData) -> void:
    # For now, apply directly to a placeholder HP value
    # In Module 21, this will apply to the selected party member
    if item.hp_restore > 0:
        print("Restored ", item.hp_restore, " HP!")
    if item.mp_restore > 0:
        print("Restored ", item.mp_restore, " MP!")
    InventoryManager.remove_item(item)


func _update_gold_display() -> void:
    _gold_label.text = "Gold: " + str(InventoryManager.gold)


func _on_gold_changed(_amount: int) -> void:
    _update_gold_display()
```

`open()` and `open_from_pause()` intentionally go through the same `_show()` helper. Module 25's PauseMenu will call the public API instead of toggling `visible` directly, so the inventory always refreshes its slots, tracks `_is_open`, and owns the pause state the same way no matter how it was opened.

## Pausing the Game

When you open the menu in any Final Fantasy game, the world freezes. Enemies stop moving, timers stop counting, and the music continues. This isn't just a convenience; it's a promise to the player: "You are safe while making decisions." Without pausing, an enemy could kill you while you're scrolling through your item list.

When the inventory opens, we **pause the game** so enemies, NPCs, and the player don't move while the menu is up.

```gdscript
get_tree().paused = true   # Pause everything
get_tree().paused = false  # Resume everything
```

But wait: if everything is paused, how does the inventory UI itself continue to work? Through **`process_mode`**.

Every node has a `process_mode` property that controls whether it runs while paused:

| Mode | Behavior |
|------|----------|
| `PROCESS_MODE_INHERIT` | Same as parent (default) |
| `PROCESS_MODE_PAUSABLE` | Pauses when tree is paused |
| `PROCESS_MODE_WHEN_PAUSED` | Only runs when tree is paused |
| `PROCESS_MODE_ALWAYS` | Always runs, regardless of pause state |
| `PROCESS_MODE_DISABLED` | Never runs |

> **IMPORTANT:** Select the `InventoryScreen` (CanvasLayer) root node in the editor and set **Process → Mode** to **`Always`** in the Inspector. Without this, the inventory will open but immediately freeze because the paused game prevents it from processing input. The only way to recover would be to force-quit.

The SceneManager should also be `PROCESS_MODE_ALWAYS`. Go back to `scene_manager.tscn` and set its root node's **Process → Mode** to **`Always`** too. It needs to work during transitions regardless of pause state.

> **See:** [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html): the official guide to pausing and `process_mode`.

## Giving the Player Starting Items

To test the inventory, give the player some starting items. In `InventoryManager._ready()`:

```gdscript
func _ready() -> void:
    # Starting inventory for testing
    var potion: ItemData = load("res://data/items/potion.tres")
    if potion:
        add_item(potion, 3)
```

Or better, add items through game events. For now, the starting items are fine for testing.

## Integration: Adding the Inventory to Scenes

Add the inventory screen to each scene:

1. Open `willowbrook.tscn`. Right-click the root `Willowbrook` node → **Instance Child Scene** → select `res://ui/inventory/inventory_screen.tscn`.
2. Repeat for `whisperwood.tscn`.

Your scene tree should look like:

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── YSortGroup (Node2D)
│   ├── Objects (TileMapLayer)
│   ├── Player
│   ├── Shopkeeper (NPC)
│   ├── Innkeeper (NPC)
│   └── Traveler (NPC)
├── AbovePlayer (TileMapLayer)
├── DialogueBox (CanvasLayer)
└── InventoryScreen (CanvasLayer)
```

## Engineering Contract

- **Global state:** `InventoryManager` owns item stacks and gold as an autoload.
- **Public surface:** `add_item()`, `remove_item()`, `use_item()`, `get_all_items()`, `get_consumables()`, and inventory/gold signals.
- **Invariant:** Stack counts never go below zero; removal fails before mutation when the amount is invalid or unavailable.
- **Failure behavior:** Missing items, insufficient quantities, and non-positive amounts return `false`.
- **Copy semantics:** List getters return defensive array/dictionary copies; `ItemData` Resources inside entries remain shared definitions.

## Engine Gotcha

Autoload arrays are just normal mutable arrays. Returning the live array would let UI code accidentally mutate inventory internals, so read APIs return copies.

## What We've Learned

- **InventoryManager** autoload tracks items as `{item: ItemData, count: int}` entries with signal-driven updates.
- **Pausing** (`get_tree().paused = true`) freezes game logic. **`process_mode = ALWAYS`** lets UI continue during pause.
- **ItemSlot** scenes are instantiated dynamically in a **GridContainer** to form the inventory grid.
- **Focus-based navigation** (`focus_mode`, `grab_focus()`) makes UI work with keyboard and gamepad.
- **Signal pattern:** InventoryManager emits `inventory_changed` → UI refreshes. Manager never touches UI directly.
- **`_gui_input()`** handles input events on Control nodes. **`accept_event()`** prevents propagation (like `set_input_as_handled()` for UI).
- Items are consumed with `remove_item()`, and the grid refreshes automatically via the `inventory_changed` signal.

### Troubleshooting

| Problem | Likely Cause |
|---------|-------------|
| Inventory doesn't open when pressing Tab | `menu` input action not defined, or key not bound |
| Game freezes when inventory opens | `process_mode` not set to `Always` on the InventoryScreen CanvasLayer |
| Items stacking incorrectly or showing wrong item | Missing or duplicate `id` fields in `.tres` files (see Module 9) |
| Slots appear too small or empty | No icon set on items (expected; use Godot icon as placeholder), or TextureRect missing minimum size |
| Escape doesn't close inventory | `ui_cancel` not mapped to Escape (it is by default) |

## What You Should See

When you press F6 (running Willowbrook):
- Press Tab (or your menu key). The inventory screen opens
- The game world freezes behind the menu
- Items appear in a grid (3 Potions from starting inventory). Icons may be blank if you haven't set them
- Navigating slots with arrow keys highlights them and shows descriptions
- Pressing accept on a Potion uses it and decrements the count
- Pressing Escape closes the inventory and resumes the game

## Next Module

We have items and NPCs and dialogue. Now it's time for the biggest system in any JRPG: **combat**. In **Module 14: Battle Foundations**, we'll build the battle scene, implement a node-based state machine for battle flow, and create the turn order system. Combat is next.


---

<!-- Source: 13_part_iii_review.md -->

# Module 13: Part III Review and Cheat Sheet

This module is a review and quick-reference for everything covered in Part III (Modules 9-12). No new code here. Just a consolidated reference you can come back to when you need to remember how something works.

## Part III in Review

Part III is where Crystal Saga went from a world you walk through to a world you interact with. The central change was separating **data from logic** using Godot's Resource system. Instead of hardcoding item stats, NPC names, and dialogue text inside scripts, we defined structured data types (Resource classes), created instances of those types (`.tres` files), and wrote systems that consume the data without caring about specific values. This pattern (define a Resource class, populate `.tres` files, wire them into scripts) will repeat in every system we build from here forward.

With the data layer in place, we built three interconnected systems on top of it. NPCs use `NPCData` resources to configure their appearance and dialogue. The dialogue system reads `DialogueLine` resources and renders them in a typewriter-style textbox. The inventory system tracks `ItemData` resources and displays them in a navigable grid. Each system is decoupled from the others through signals: the NPC does not know about the dialogue box, the dialogue box does not know about the inventory, and the inventory does not know about either. They communicate through emit-and-connect wiring in the scene scripts.

The result is a working game architecture. Resources for data, signals for communication, autoloads for persistence, Control nodes for UI. These same patterns show up in the battle system, quest system, save/load, and everything else we build in the remaining parts. If any of these concepts feel shaky, this is a good place to review before moving into Part IV.

### Module 9: Resources, the Data Layer

- Learned that **Resources** are Godot's universal data container: type-safe, editor-friendly objects that can be saved as `.tres` files and shared across the project.
- Defined three custom Resource classes (`ItemData`, `CharacterData`, `NPCData`) using `class_name`, `@export`, `@export_group()`, `@export_multiline`, and enum-typed exports.
- Created `.tres` data files in the Inspector for potions, equipment, and the hero's stats, filling in typed fields through dropdown menus and text editors instead of writing raw data.
- Established the **three-file pattern**: a Resource class (`.gd`) defines the structure, a `.tres` file holds specific values, and a consumer script uses the data at runtime.
- Learned when to use `preload()` (compile-time, constant paths, no null check needed) versus `load()` (runtime, dynamic paths, always null-check the result).

### Module 10: NPCs and Interaction

- Built a reusable NPC scene (`CharacterBody2D` + `AnimatedSprite2D` + `Area2D` + `Label`) driven by an `@export var npc_data: NPCData`. Swapping the resource changes the NPC's identity without changing the script.
- Implemented the **Area2D interaction pattern**: the NPC's `InteractionZone` detects the player via `body_entered`/`body_exited` signals, toggles an interaction prompt, and listens for the `interact` input action.
- Used `_unhandled_input()` instead of `_input()` or `_process()` polling, so the NPC only responds to input that UI elements have not already consumed, and called `set_input_as_handled()` to prevent other nodes from double-processing the same press.
- Connected NPC signals to scene scripts (`willowbrook.gd`) to demonstrate **separation of concerns**: the NPC detects interaction and emits a signal; the scene script decides what to do with it.
- Defined a custom `interact` input action in Project Settings so the same code works for keyboard and gamepad.

### Module 11: The Dialogue System

- Created the `DialogueLine` Resource (speaker name, text, optional portrait, optional choices) and upgraded `NPCData` from `Array[String]` to `Array[DialogueLine]` for structured dialogue data.
- Built a dialogue box UI scene using **Control nodes** (`CanvasLayer` > `PanelContainer` > `MarginContainer` > `VBoxContainer` > `Label` + `RichTextLabel`) with anchors and containers for responsive layout.
- Implemented the **typewriter effect** by tweening `RichTextLabel.visible_ratio` from `0.0` to `1.0`, with proper tween lifecycle management (kill before creating a new one).
- Added the **two-press interaction** pattern (first press skips typing, second press advances or closes), the standard JRPG dialogue control.
- Extended dialogue with **branching choices**: dynamically creating `Button` nodes in a `ChoiceContainer`, using `grab_focus()` for keyboard navigation, and emitting `choice_made` signals.

### Module 12: The Inventory System

- Created the **InventoryManager autoload** to persist items across scene changes, tracking items as `{item: ItemData, count: int}` dictionaries matched by `item.id`.
- Built a signal-driven architecture: InventoryManager emits `item_added`, `item_removed`, `inventory_changed`, and `gold_changed`. The UI listens and refreshes, and the manager never touches UI directly.
- Constructed the inventory UI with dynamically instanced `ItemSlot` scenes in a `GridContainer`, each slot emitting `slot_selected` and `slot_activated` signals for description display and item use.
- Learned how **pausing** works: `get_tree().paused = true` freezes the game world, while `process_mode = PROCESS_MODE_ALWAYS` on the inventory's CanvasLayer lets the menu continue to function.
- Used `_gui_input()` and `accept_event()` for Control-node input handling, and `focus_mode = FOCUS_ALL` with `grab_focus()` for keyboard/gamepad-navigable item slots.

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|---------------|------------|
| Custom Resource class | A GDScript file extending `Resource` with `class_name` and `@export` properties | Defines a reusable, type-safe data structure editable in the Inspector | Module 9 |
| `.tres` file | A text-based Resource instance saved to disk | Holds specific data values (one potion, one sword) separate from code | Module 9 |
| Three-file pattern | Resource class `.gd` + data `.tres` + consumer `.gd` | Separates structure, data, and behavior so each can change independently | Module 9 |
| `preload()` vs `load()` | Compile-time vs runtime resource loading | `preload` for known assets, `load` for dynamic paths (with null check) | Module 9 |
| Null-check pattern | `if resource == null: push_error(...)` after `load()` | Prevents silent crashes from missing or mistyped file paths | Module 9 |
| Area2D interaction zone | A collision area larger than the NPC body | Detects when the player is close enough to interact | Module 10 |
| `_unhandled_input()` | Input callback that fires only if no other node consumed the event | Respects UI focus; prevents game-world input from firing during menus | Module 10 |
| `set_input_as_handled()` | Marks an input event as consumed | Prevents multiple nodes from responding to the same button press | Module 10 |
| Custom input actions | Named actions (e.g., `interact`, `menu`) defined in Project Settings | Decouples game logic from specific keys; supports keyboard and gamepad | Module 10 |
| CanvasLayer | A node that renders its children on a separate drawing layer | Draws UI on top of the game world regardless of camera position | Module 11 |
| `visible_ratio` | A float (0.0 to 1.0) controlling how much of a RichTextLabel's text is shown | Powers the typewriter effect via tweening | Module 11 |
| Tween lifecycle | Creating, chaining, killing, and checking validity of Tweens | Prevents overlapping animations when the player advances dialogue quickly | Module 11 |
| `grab_focus()` | Programmatically gives keyboard/gamepad focus to a Control node | Makes UI navigable without a mouse, which is critical for JRPGs | Module 11 |
| Autoload | A node auto-instanced at startup, accessible globally by name | Persists data (inventory, gold) across scene changes | Module 12 |
| `process_mode` | Controls whether a node runs during pause | Lets the inventory UI function while the game world is frozen | Module 12 |
| `_gui_input()` | Input callback specific to Control nodes | Handles button presses, focus changes, and mouse events on UI elements | Module 12 |
| Signal-driven UI updates | Manager emits signals; UI listens and refreshes itself | Keeps the data layer and presentation layer fully decoupled | Module 12 |

## Cheat Sheet

### Custom Resource Classes

Define a class:

```gdscript
# res://resources/item_data.gd
extends Resource
class_name ItemData
## Data definition for an inventory item.

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM }

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.CONSUMABLE

@export_group("Consumable Effects")
@export var hp_restore: int = 0
@export var mp_restore: int = 0
```

Create an instance in code (for testing):

```gdscript
var potion := ItemData.new()
potion.id = "potion"
potion.display_name = "Potion"
potion.hp_restore = 50
```

Create an instance in the editor: right-click a folder in the FileSystem dock, select **New Resource**, search for `ItemData`, click **Create**, name the file, and fill in the exported fields in the Inspector.

Load a `.tres` file at compile time:

```gdscript
const POTION := preload("res://data/items/potion.tres")
```

Load a `.tres` file at runtime (dynamic path):

```gdscript
var item: ItemData = load("res://data/items/" + item_id + ".tres") as ItemData
if item == null:
    push_error("Failed to load item: " + item_id)
    return
```

Duplicate to avoid shared-reference mutations:

```gdscript
var my_copy: ItemData = shared_item.duplicate()
my_copy.hp_restore = 99  # Only affects the copy
```

### The Resource Pattern (Data vs Logic)

The point: separate **what the data is** from **what the code does with it**.

```
resources/item_data.gd        : defines the shape (fields, types, enums)
data/items/potion.tres        : holds specific values (Potion, 50 HP, 25 gold)
autoloads/inventory_manager.gd: manages a collection of items at runtime
```

This separation means:
- **Game designers** (or future you) can tweak values in the Inspector without touching code.
- **Consumer scripts** work with any `ItemData`; they do not care whether it is a potion or a sword.
- **Resource classes** change rarely; data instances change often. Changes to data never break code.

The same pattern applies everywhere: `CharacterData` for stats, `NPCData` for NPC configuration, `DialogueLine` for dialogue content.

### Area2D Interaction Pattern

The NPC's `InteractionZone` (an `Area2D` with a `CollisionShape2D` larger than the NPC's body) detects proximity:

```gdscript
# In the NPC script
@onready var _interaction_zone: Area2D = $InteractionZone
@onready var _interaction_prompt: Label = $InteractionPrompt

var _player_in_range: bool = false


func _ready() -> void:
    _interaction_zone.body_entered.connect(_on_player_entered)
    _interaction_zone.body_exited.connect(_on_player_exited)
    _interaction_prompt.visible = false


func _on_player_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _interaction_prompt.visible = true


func _on_player_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _interaction_prompt.visible = false
```

Then handle input only when in range:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range:
        return

    if event.is_action_pressed("interact"):
        _face_player()
        get_viewport().set_input_as_handled()
        interacted.emit(self)
```

The key points: use `_unhandled_input()` (not `_input()` or `_process()` polling), check the `_player_in_range` flag, call `set_input_as_handled()` to prevent other nodes from also reacting, and emit a signal instead of performing the action directly.

### NPC Architecture

The NPC scene tree:

```
NPC (CharacterBody2D)
├── Sprite (AnimatedSprite2D)
├── CollisionShape2D           : small, feet-only (makes the NPC solid)
├── InteractionZone (Area2D)
│   └── InteractionShape       : large circle (~24px radius, detection range)
└── InteractionPrompt (Label)  : "!" text, hidden by default
```

The NPC is driven by data, not hardcoded values:

```gdscript
@export var npc_data: NPCData

func _apply_npc_data() -> void:
    if npc_data.sprite_frames:
        _sprite.sprite_frames = npc_data.sprite_frames

    var dir_name := _direction_to_string(npc_data.facing_direction)
    var idle_anim := "idle_" + dir_name
    if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
        _sprite.play(idle_anim)
```

Different `NPCData` `.tres` files produce different NPCs from the same scene. The scene script (`willowbrook.gd`) wires the NPC's `interacted` signal to game systems like dialogue.

### The Dialogue System

**Data format:** a `DialogueLine` Resource per line of conversation:

```gdscript
extends Resource
class_name DialogueLine

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var choices: Array[String] = []
```

**Starting dialogue:** pass an array of `DialogueLine` resources:

```gdscript
_dialogue_box.start_dialogue(npc.npc_data.dialogue)
```

**Typewriter effect:** tween `visible_ratio` on a `RichTextLabel`:

```gdscript
func _start_typing() -> void:
    _is_typing = true
    var char_count: int = _text_label.get_total_character_count()
    var duration: float = char_count / characters_per_second

    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()

    _current_tween = create_tween()
    _current_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
    _current_tween.finished.connect(_on_typing_finished)
```

**Two-press input:** skip typing on first press, advance on second:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if not _panel.visible:
        return
    if _choice_container.visible:
        return
    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
        get_viewport().set_input_as_handled()
        if _is_typing:
            _skip_typing()
        else:
            _advance()
```

**Branching choices:** dynamically create buttons when a `DialogueLine` has choices:

```gdscript
func _show_choices(choices: Array[String]) -> void:
    _choice_container.visible = true
    for i in choices.size():
        var button := Button.new()
        button.text = choices[i]
        button.pressed.connect(_on_choice_pressed.bind(i))
        _choice_container.add_child(button)

    await get_tree().process_frame
    if _choice_container.get_child_count() > 0:
        _choice_container.get_child(0).grab_focus()
```

**Signal flow** for a complete dialogue interaction:

```
Player presses interact near NPC
  -> NPC emits interacted(self)
  -> Scene script calls player.start_interaction() and dialogue_box.start_dialogue()
  -> DialogueBox emits dialogue_started
  -> [Player advances through lines]
  -> DialogueBox emits dialogue_finished
  -> Scene script calls player.end_interaction()
```

### RichTextLabel and BBCode

[`RichTextLabel`](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html) is a text display node that supports BBCode formatting. Enable it by setting `bbcode_enabled = true` in the Inspector.

Common tags for dialogue:

| BBCode | Effect | Example |
|--------|--------|---------|
| `[b]...[/b]` | Bold | `[b]Important[/b]` |
| `[i]...[/i]` | Italic | `[i]whispers[/i]` |
| `[color=red]...[/color]` | Text color | `[color=red]Danger![/color]` |
| `[wave]...[/wave]` | Wavy text animation | `[wave]magical energy[/wave]` |
| `[shake]...[/shake]` | Shaking text | `[shake]earthquake![/shake]` |

These tags work inside `DialogueLine.text` and render correctly with the typewriter effect because `visible_ratio` reveals already-formatted text.

Key `RichTextLabel` properties:

- `bbcode_enabled`: must be `true` for tags to render
- `visible_ratio`: float 0.0 to 1.0, controls how much text is visible (used for typewriter)
- `visible_characters`: int, same idea but discrete (we use `visible_ratio` for smoother tweening)
- `fit_content`: auto-sizes the node to fit the text
- `scroll_active`: set to `false` for dialogue boxes (we handle paging manually)

### Inventory System Architecture

**InventoryManager** (autoload), which tracks items and emits signals:

```gdscript
signal item_added(item: ItemData, new_count: int)
signal item_removed(item: ItemData, new_count: int)
signal inventory_changed
signal gold_changed(new_amount: int)

var gold: int = 100
var _items: Array[Dictionary] = []  # [{item: ItemData, count: int}]
```

**Core operations:**

```gdscript
# Add items
InventoryManager.add_item(potion, 3)

# Remove items (returns false if player doesn't have enough)
var success: bool = InventoryManager.remove_item(potion, 1)

# Check for items
if InventoryManager.has_item("potion", 2):
    print("Player has at least 2 potions")

# Get count
var count: int = InventoryManager.get_item_count("potion")

# Get filtered lists
var consumables: Array[Dictionary] = InventoryManager.get_consumables()

# Gold management
InventoryManager.add_gold(50)
var could_afford: bool = InventoryManager.spend_gold(100)
```

**ID-based matching:** items are matched by their `id` string, not by object reference. Two different `ItemData` objects with `id = "potion"` are treated as the same item. Always set unique `id` values on `.tres` files.

### UI Patterns for Lists

The inventory uses a common pattern for displaying dynamic lists of data in Godot UI:

**Container hierarchy:**

```
PanelContainer (background)
└── MarginContainer (padding)
    └── VBoxContainer (vertical stack)
        ├── Header (HBoxContainer)
        │   ├── TitleLabel
        │   └── GoldLabel
        ├── ItemGrid (GridContainer, columns = 5)
        │   # Slots instanced dynamically
        └── DescriptionLabel (RichTextLabel)
```

**Dynamic slot creation:** clear old slots, create new ones from data:

```gdscript
const ItemSlotScene := preload("res://ui/inventory/item_slot.tscn")

func _refresh() -> void:
    # Clear existing slots immediately (free, not queue_free)
    for child in _item_grid.get_children():
        child.free()

    # Create a slot for each inventory entry
    var items := InventoryManager.get_all_items()
    for entry in items:
        var slot: PanelContainer = ItemSlotScene.instantiate()
        _item_grid.add_child(slot)
        slot.setup(entry.item, entry.count)
        slot.slot_selected.connect(_on_slot_selected)
        slot.slot_activated.connect(_on_slot_activated)

    # Focus the first slot for keyboard navigation
    if _item_grid.get_child_count() > 0:
        _item_grid.get_child(0).call_deferred("grab_focus")
```

Why `free()` instead of `queue_free()`: when refreshing a list, you want the old children gone immediately so the new children appear in a clean container. `queue_free()` defers removal to the end of the frame, which can cause brief visual glitches where old and new slots overlap.

**Pausing the game while the menu is open:**

```gdscript
func open() -> void:
    _is_open = true
    _panel.visible = true
    get_tree().paused = true   # Freeze the game world
    _refresh()

func close() -> void:
    _is_open = false
    _panel.visible = false
    get_tree().paused = false  # Resume the game world
```

Set `process_mode = PROCESS_MODE_ALWAYS` on the InventoryScreen's root `CanvasLayer` node in the Inspector. Without this, the menu itself will freeze along with everything else.

### Signal Patterns Recap

Part III introduced several signal patterns. Here is every signal connection used across Modules 9-12:

**NPC interaction (Module 10):**

```gdscript
# NPC detects player proximity
_interaction_zone.body_entered.connect(_on_player_entered)
_interaction_zone.body_exited.connect(_on_player_exited)

# NPC emits when player presses interact
signal interacted(npc: CharacterBody2D)

# Scene script connects all NPCs in a group
for npc in get_tree().get_nodes_in_group("npcs"):
    npc.interacted.connect(_on_npc_interacted)
```

**Dialogue events (Module 11):**

```gdscript
# Dialogue box lifecycle signals
signal dialogue_started
signal dialogue_finished
signal line_advanced
signal choice_made(choice_index: int)

# Scene script connects to dialogue_finished for cleanup
_dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
```

**Inventory changes (Module 12):**

```gdscript
# InventoryManager emits on every change
signal item_added(item: ItemData, new_count: int)
signal item_removed(item: ItemData, new_count: int)
signal inventory_changed
signal gold_changed(new_amount: int)

# UI subscribes in _ready()
InventoryManager.inventory_changed.connect(_refresh)
InventoryManager.gold_changed.connect(_on_gold_changed)
```

**Item slot UI (Module 12):**

```gdscript
# Each slot emits when focused or activated
signal slot_selected(item: ItemData)
signal slot_activated(item: ItemData)

# Inventory screen connects after instancing each slot
slot.slot_selected.connect(_on_slot_selected)
slot.slot_activated.connect(_on_slot_activated)
```

The consistent pattern: the object that **knows something happened** emits a signal. The object that **needs to respond** connects to that signal. Neither needs a reference to the other's internals.

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Forgetting `class_name` on a Resource class | The type does not appear in "New Resource" dialog or `@export` type hints | Add `class_name YourType` on the second line of the `.gd` file, then re-save |
| Using `load()` without a null check | Game crashes with a null-reference error when a path is wrong | Always check: `var res = load(path) as Type` then `if res == null: push_error(...)` |
| Duplicate or empty `id` fields on `.tres` files | Items stack incorrectly in inventory; wrong item gets removed | Give every `.tres` file a unique `id` that matches the filename (e.g., `"potion"` for `potion.tres`) |
| Not setting `process_mode` to `Always` on the inventory CanvasLayer | Game freezes permanently when the inventory opens (pause locks the menu too) | Select the InventoryScreen root node in the editor, set **Process > Mode** to **Always** |
| Using `_input()` instead of `_unhandled_input()` for NPC interaction | Interact button fires even when a UI menu is open | Switch to `_unhandled_input()` and call `get_viewport().set_input_as_handled()` |
| Not killing the previous tween before creating a new one | Text glitches when the player advances dialogue rapidly, causing overlapping animations | Check `if _current_tween and _current_tween.is_valid(): _current_tween.kill()` before `create_tween()` |
| Using `queue_free()` when refreshing the item grid | Old and new item slots briefly overlap on screen | Use `free()` instead of `queue_free()` when clearing a container before immediately repopulating it |
| Forgetting to add the player to the `"player"` group | NPC interaction zone never detects the player; `body_entered` fires but `is_in_group("player")` is false | Select the Player node, go to Node tab > Groups, add `player` |

## Official Godot Documentation

### Core Classes

- [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html): base class for all resources; `duplicate()`, `resource_path`
- [Node](https://docs.godotengine.org/en/stable/classes/class_node.html): `_ready()`, `_process()`, `_unhandled_input()`, `process_mode`, `get_tree()`
- [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html): `paused`, `get_nodes_in_group()`, `get_first_node_in_group()`, `create_timer()`
- [Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html): `set_input_as_handled()`
- [InputEvent](https://docs.godotengine.org/en/stable/classes/class_inputevent.html): `is_action_pressed()`, `is_action_just_pressed()`

### Physics and Detection

- [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html): solid body used for NPCs (and the player)
- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html): `body_entered`, `body_exited` signals for proximity detection
- [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html): defines collision geometry
- [RectangleShape2D](https://docs.godotengine.org/en/stable/classes/class_rectangleshape2d.html): rectangular collision shape
- [CircleShape2D](https://docs.godotengine.org/en/stable/classes/class_circleshape2d.html): circular collision shape (used for interaction zones)
- [RayCast2D](https://docs.godotengine.org/en/stable/classes/class_raycast2d.html): alternative to Area2D for directional interaction detection

### Sprites and Animation

- [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html): sprite with named animations; `play()`, `sprite_frames`
- [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html): the resource that holds animation data; `has_animation()`

### UI and Control Nodes

- [Control](https://docs.godotengine.org/en/stable/classes/class_control.html): base UI node; `focus_mode`, `grab_focus()`, `_gui_input()`, anchors, margins
- [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html): renders children on a separate layer; `layer` property
- [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html): styled background panel
- [MarginContainer](https://docs.godotengine.org/en/stable/classes/class_margincontainer.html): adds padding around its child
- [VBoxContainer](https://docs.godotengine.org/en/stable/classes/class_vboxcontainer.html): stacks children vertically
- [HBoxContainer](https://docs.godotengine.org/en/stable/classes/class_hboxcontainer.html): stacks children horizontally
- [GridContainer](https://docs.godotengine.org/en/stable/classes/class_gridcontainer.html): lays out children in a grid; `columns` property
- [Label](https://docs.godotengine.org/en/stable/classes/class_label.html): plain text display
- [RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html): BBCode-formatted text; `visible_ratio`, `visible_characters`, `bbcode_enabled`, `fit_content`, `get_total_character_count()`
- [TextureRect](https://docs.godotengine.org/en/stable/classes/class_texturerect.html): displays an image in UI
- [Button](https://docs.godotengine.org/en/stable/classes/class_button.html): clickable button; `pressed` signal, `text`
- [StyleBoxFlat](https://docs.godotengine.org/en/stable/classes/class_styleboxflat.html): custom panel styles (bg color, border, corner radius)

### Animation and Tweening

- [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html): `tween_property()`, `kill()`, `is_valid()`, `finished` signal
- [Node.create_tween()](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-create-tween): creates a Tween bound to the node's lifetime

### Tutorials and Guides

- [Resources (tutorial)](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html): creating and using Resources
- [GDScript exports](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html): `@export`, `@export_group`, `@export_multiline`, enum exports
- [Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html): setting up custom input actions
- [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html): positioning Control nodes
- [GUI containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html): automatic layout with VBox, HBox, Grid, Margin containers
- [Control node gallery](https://docs.godotengine.org/en/stable/tutorials/ui/control_node_gallery.html): visual catalog of all Control nodes
- [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html): keyboard/gamepad focus navigation
- [BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html): text formatting with BBCode tags
- [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html): `SceneTree.paused` and `process_mode`

## What's Next

Part IV is combat. In Module 14 we build the battle scene, implement a node-based state machine for battle flow, and create the turn order system. Modules 15-18 add player actions, a dungeon, enemy AI, and a victory/leveling loop. Everything from Part III (Resources, signals, UI patterns) carries directly into it.


---

<!-- Source: 14_battle_foundations.md -->

# Module 14: Battle Foundations: State Machines and Turn Order

## What We Have So Far

A connected world with NPCs, dialogue, inventory, and Resources. Everything before this was building the world and its data. Now we tackle the battle system.

## What We're Building This Module

The battle scene skeleton: party and enemies displayed on screen, a state machine controlling the flow of combat, a turn order system, and transitions between the overworld and battle. By the end, battles will start and cycle through turns, even if we can't take actions yet (that's Module 15).

## Scaling Up: From Enum to Node-Based State Machine

A JRPG battle is one of the most complex state flows in all of game development. Think about a single turn in Final Fantasy VI: the game waits for your ATB gauge to fill, shows the command menu, you pick Magic, it shows the spell list, you pick Fire, it shows the target list, you pick an enemy, the character runs forward, the spell animation plays, damage numbers pop up, the game checks if anyone died, and then it moves to the next character. Each of those phases has different rules about what input is allowed, what's displayed, and what happens next.

In Module 6, we built an enum-based state machine for the player with four states. That approach works great for simple cases, but the battle system has significantly more states with complex transitions:

```
INTRO → TURN_START → PLAYER_CHOICE → ACTION_EXECUTE → CHECK_RESULT → VICTORY → DEFEAT
```

An enum-based `match` block for 7+ states becomes a single massive function that's hard to read and harder to modify. Each state might need its own `_process()`, `enter()`, and `exit()` logic. The node-based pattern handles this cleanly.

### The Node-Based Pattern

Each state is a **Node** with three methods (`enter`, `process`, `exit`), plus a reference to the battle manager. Save this as `res://systems/battle/battle_state.gd`:

```gdscript
extends Node
class_name BattleState
## Base class for all battle states.

var battle_manager: Node  # Set by BattleManager during _ready()

## Called when this state becomes active.
func enter(_context: Dictionary = {}) -> void:
    pass

## Called every frame while this state is active.
func process(_delta: float) -> void:
    pass

## Called when transitioning away from this state.
func exit() -> void:
    pass
```

The state machine node manages which state is active:

```gdscript
extends Node
class_name BattleStateMachine
## Manages battle state transitions.

signal state_changed(old_state: String, new_state: String)

var current_state: BattleState
var states: Dictionary = {}


func _ready() -> void:
    # Register all child nodes as states
    for child in get_children():
        if child is BattleState:
            states[child.name] = child
    if states.is_empty():
        push_error("BattleStateMachine: no states registered. Attach BattleState scripts to child nodes.")


func start(initial_state: String, context: Dictionary = {}) -> void:
    current_state = states.get(initial_state)
    if current_state:
        current_state.enter(context)


func transition_to(new_state_name: String, context: Dictionary = {}) -> void:
    var new_state: BattleState = states.get(new_state_name)
    if not new_state:
        push_error("BattleStateMachine: no state named " + new_state_name)
        return

    var old_name := current_state.name if current_state else ""

    if current_state:
        current_state.exit()

    current_state = new_state
    current_state.enter(context)
    state_changed.emit(old_name, new_state_name)


func _process(delta: float) -> void:
    if current_state:
        current_state.process(delta)
```

Save these as `res://systems/battle/battle_state.gd` and `res://systems/battle/battle_state_machine.gd`.

> **Spiral:** Compare this to Module 6's enum state machine. The enum approach uses `match` in `_physics_process` to route to different functions. The node approach uses polymorphism: each state is a separate Node, and the machine just calls `enter()`/`process()`/`exit()` on whichever one is current. Same pattern, different scale.

## BattlerData: Who's Fighting

Characters in an RPG exist in two contexts: their permanent identity (name, base stats, level) and their temporary battle state (current HP this fight, a defense buff that wears off next turn). In Final Fantasy, Cloud's base stats live on his character sheet, but when he uses Defend, the temporary defense boost only lasts until his next turn. We need a wrapper that holds both: the permanent data from CharacterData and the temporary state that exists only during one battle.

We need a Resource to represent someone in battle, combining their base stats with runtime battle state.

Create `res://resources/battler_data.gd`:

```gdscript
extends Resource
class_name BattlerData
## Runtime data for a combatant in battle.

@export var character_data: CharacterData
@export var is_player_controlled: bool = true

# Runtime state (not saved to .tres, set during battle)
var current_hp: int = 0
var current_mp: int = 0
var current_attack: int = 0
var current_defense: int = 0
var current_speed: int = 0
var defense_boost: int = 0  # Temporary boost from Defend action


func initialize_from_character() -> void:
    if not character_data:
        return
    current_hp = character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp
    current_mp = character_data.current_mp if character_data.current_mp > 0 else character_data.max_mp
    current_attack = character_data.attack
    current_defense = character_data.defense
    current_speed = character_data.speed


func get_effective_defense() -> int:
    return current_defense + defense_boost


func is_alive() -> bool:
    return current_hp > 0


func take_damage(amount: int) -> int:
    var actual_damage: int = max(1, amount)
    current_hp = max(0, current_hp - actual_damage)
    return actual_damage


func heal(amount: int) -> int:
    var old_hp := current_hp
    current_hp = min(current_hp + amount, character_data.max_hp)
    return current_hp - old_hp  # Actual amount healed
```

## The Battle Scene

Create `res://scenes/battle/battle.tscn`:

### Scene Layout

```
Battle (Node2D)
├── Background (TextureRect or ColorRect)
├── PartyPositions (Node2D)
│   ├── PartySlot0 (Marker2D)
│   ├── PartySlot1 (Marker2D)
│   └── PartySlot2 (Marker2D)
├── EnemyPositions (Node2D)
│   ├── EnemySlot0 (Marker2D)
│   ├── EnemySlot1 (Marker2D)
│   └── EnemySlot2 (Marker2D)
├── BattleUI (CanvasLayer)
│   └── ... (we'll build this in Module 15)
└── StateMachine (BattleStateMachine)
    ├── Intro (BattleState)
    ├── TurnStart (BattleState)
    ├── PlayerChoice (BattleState)
    ├── ActionExecute (BattleState)
    ├── CheckResult (BattleState)
    ├── Victory (BattleState)
    └── Defeat (BattleState)
```

Position the Marker2D nodes to create the classic JRPG battle layout. In the Inspector, set the `position` property for each:

| Node | Position | Role |
|------|----------|------|
| PartySlot0 | (240, 60) | Top party member |
| PartySlot1 | (240, 120) | Middle party member |
| PartySlot2 | (240, 180) | Bottom party member |
| EnemySlot0 | (80, 60) | Top enemy |
| EnemySlot1 | (80, 120) | Middle enemy |
| EnemySlot2 | (80, 180) | Bottom enemy |

Party on the right, enemies on the left, with space in the center for action animations.

For the background, add the `ColorRect` node first. Set its color to a dark blue-grey (e.g., `Color(0.15, 0.15, 0.25)`) and set its Layout to **Full Rect** (select the node, then in the toolbar use Layout → Full Rect).

### Battler Sprites

We need sprites for both party members and enemies in battle. Create a simple battler scene `res://entities/battle/battler_sprite.tscn`:

```
BattlerSprite (Node2D)
└── Sprite (Sprite2D)
```

With script `res://entities/battle/battler_sprite.gd`:

```gdscript
extends Node2D
## Visual representation of a combatant in battle.

var battler_data: BattlerData

@onready var _sprite: Sprite2D = $Sprite


func setup(data: BattlerData) -> void:
    battler_data = data
    add_to_group("battler_sprites")
    if data.character_data and data.character_data.portrait:
        _sprite.texture = data.character_data.portrait
    else:
        # Fallback so sprites are always visible during testing
        _sprite.texture = preload("res://icon.svg")
```

> **Important:** Battler sprites will be invisible until you set the `portrait` property on your CharacterData resources. For testing, open `res://data/characters/aiden.tres` in the Inspector and drag `res://icon.svg` into the `portrait` field. For enemies created in code, set `char_data.portrait = preload("res://icon.svg")` in the test battle setup. The fallback code above handles this automatically.

## The BattleManager

The battle manager orchestrates the entire fight. Create `res://systems/battle/battle_manager.gd` and **attach it to the `Battle` root node** in `battle.tscn`:

> **Note:** BattleManager is NOT an autoload. It is the root script of `battle.tscn`, which means it only exists while a battle is happening. The SceneManager loads the battle scene and calls its `initialize_battle()` method.

```gdscript
extends Node2D
## Orchestrates battle flow. Attached to the Battle scene root (Node2D).

signal battle_started(party: Array[BattlerData], enemies: Array[BattlerData])
signal turn_started(battler: BattlerData)
signal action_executed(attacker: BattlerData, target: BattlerData, damage: int)
signal battle_won
signal battle_lost

var party: Array[BattlerData] = []
var enemies: Array[BattlerData] = []
var turn_queue: Array[BattlerData] = []
var current_battler: BattlerData

@onready var _state_machine: BattleStateMachine = $StateMachine
@onready var _party_positions: Node2D = $PartyPositions
@onready var _enemy_positions: Node2D = $EnemyPositions

const BattlerSpriteScene := preload("res://entities/battle/battler_sprite.tscn")


func _ready() -> void:
    # Pass a reference to this manager into every state
    for state in _state_machine.states.values():
        state.battle_manager = self
    # Don't start the state machine here. Wait for initialize_battle()
    # to populate party and enemies first.
    #
    # NOTE: Child nodes' _ready() runs BEFORE the parent's _ready().
    # That means each state's _ready() has already fired by this point,
    # so battle_manager was null during their _ready(). Never access
    # battle_manager in a state's _ready(). Use enter() instead.


func initialize_battle(party_data: Array[BattlerData], enemy_data: Array[BattlerData]) -> void:
    party = party_data
    enemies = enemy_data

    # Initialize runtime stats
    for battler in party:
        battler.initialize_from_character()
    for battler in enemies:
        battler.initialize_from_character()

    # Spawn sprites
    _spawn_battler_sprites(party, _party_positions)
    _spawn_battler_sprites(enemies, _enemy_positions)

    battle_started.emit(party, enemies)

    # NOW start the state machine, data is ready
    _state_machine.start("Intro")


func transition_to_state(state_name: String, context: Dictionary = {}) -> void:
    _state_machine.transition_to(state_name, context)


func _spawn_battler_sprites(battlers: Array[BattlerData], positions: Node2D) -> void:
    var slots := positions.get_children()
    for i in battlers.size():
        if i >= slots.size():
            break
        var sprite_node: Node2D = BattlerSpriteScene.instantiate()
        slots[i].add_child(sprite_node)
        sprite_node.setup(battlers[i])
```

Turn order is what makes the Speed stat matter. In Dragon Quest, faster characters act first, which means a healer with high speed can save a dying ally before the enemy lands the killing blow. A slow but powerful warrior might deal massive damage but always acts last, creating the risk that the enemy attacks first. This single mechanic, who goes when, turns a stat number into a tactical consideration.

```gdscript
func build_turn_queue() -> void:
    turn_queue.clear()

    # Gather all alive combatants
    var all_battlers: Array[BattlerData] = []
    for b in party:
        if b.is_alive():
            all_battlers.append(b)
    for b in enemies:
        if b.is_alive():
            all_battlers.append(b)

    # Sort by speed (highest first). sort_custom() takes an inline function
    # (also called a lambda): func(a, b) -> bool returns true if a should
    # come before b. GDScript supports these for one-off comparisons.
    all_battlers.sort_custom(func(a: BattlerData, b: BattlerData) -> bool:
        return a.current_speed > b.current_speed
    )

    turn_queue = all_battlers


func get_next_battler() -> BattlerData:
    if turn_queue.is_empty():
        return null
    return turn_queue.pop_front()


func is_party_alive() -> bool:
    return party.any(func(b: BattlerData) -> bool: return b.is_alive())


func is_enemy_alive() -> bool:
    return enemies.any(func(b: BattlerData) -> bool: return b.is_alive())


func get_alive_enemies() -> Array[BattlerData]:
    return enemies.filter(func(b: BattlerData) -> bool: return b.is_alive())


func get_alive_party() -> Array[BattlerData]:
    return party.filter(func(b: BattlerData) -> bool: return b.is_alive())
```

## Implementing the Battle States

Each state is a small script. Here they are, one by one.

Save each state script in `res://systems/battle/states/`. After creating all the scripts, you need to **attach each script to its corresponding node** in the scene tree:

1. In the editor, select the **Intro** node under StateMachine.
2. In the Inspector, click the Script dropdown and choose **Load**, then select `intro_state.gd`.
3. Repeat for each state node: TurnStart → `turn_start_state.gd`, PlayerChoice → `player_choice_state.gd`, etc.

Alternatively, you can right-click each state node → **Attach Script** → change the path to the existing file.

### Intro State

Save as `res://systems/battle/states/intro_state.gd`:

```gdscript
extends BattleState
## Brief intro animation before combat begins.


func enter(_context: Dictionary = {}) -> void:
    # In a full game, play a swipe animation or battle start effect
    # For now, just wait briefly and proceed
    await get_tree().create_timer(0.5).timeout
    battle_manager.transition_to_state("TurnStart")
```

### TurnStart State

Save as `res://systems/battle/states/turn_start_state.gd`:

```gdscript
extends BattleState
## Builds the turn queue and starts processing turns.


func enter(_context: Dictionary = {}) -> void:
    battle_manager.build_turn_queue()
    _process_next_turn()


func _process_next_turn() -> void:
    var battler := battle_manager.get_next_battler()

    if battler == null:
        # All turns exhausted, start a new round
        battle_manager.transition_to_state("TurnStart")
        return

    battle_manager.current_battler = battler

    # Reset temporary buffs at the start of each turn
    battler.defense_boost = 0

    battle_manager.turn_started.emit(battler)

    if battler.is_player_controlled:
        battle_manager.transition_to_state("PlayerChoice", {battler = battler})
    else:
        battle_manager.transition_to_state("ActionExecute", {
            battler = battler,
            action = "enemy_turn",
        })
```

### PlayerChoice State

Save as `res://systems/battle/states/player_choice_state.gd`:

```gdscript
extends BattleState
## Waits for the player to choose an action.

var _active_battler: BattlerData


func enter(context: Dictionary = {}) -> void:
    _active_battler = context.get("battler")
    # Module 15 will add the battle menu UI here.
    # For now, auto-attack the first enemy as a placeholder.
    print(_active_battler.character_data.display_name + "'s turn! (auto-attacking)")
    await get_tree().create_timer(0.3).timeout

    var targets := battle_manager.get_alive_enemies()
    if targets.is_empty():
        return

    battle_manager.transition_to_state("ActionExecute", {
        battler = _active_battler,
        action = "attack",
        target = targets[0],
    })
```

### ActionExecute State

Save as `res://systems/battle/states/action_execute_state.gd`:

```gdscript
extends BattleState
## Executes the chosen action (attack, defend, magic, item, enemy AI).


func enter(context: Dictionary = {}) -> void:
    var battler: BattlerData = context.get("battler")
    var action: String = context.get("action", "attack")
    var target: BattlerData = context.get("target")

    match action:
        "attack":
            _execute_attack(battler, target)
        "enemy_turn":
            _execute_enemy_turn(battler)
        _:
            print("Unknown action: ", action)

    # Brief pause for the action to feel impactful
    await get_tree().create_timer(0.5).timeout

    battle_manager.transition_to_state("CheckResult")


func _execute_attack(attacker: BattlerData, target: BattlerData) -> void:
    var damage: int = max(1, attacker.current_attack - target.get_effective_defense())
    damage += randi_range(-2, 2)  # Small random variance
    damage = max(1, damage)

    var actual := target.take_damage(damage)
    battle_manager.action_executed.emit(attacker, target, actual)
    print(attacker.character_data.display_name + " attacks " +
          target.character_data.display_name + " for " + str(actual) + " damage!")


func _execute_enemy_turn(battler: BattlerData) -> void:
    # Simple AI: attack a random party member
    var targets := battle_manager.get_alive_party()
    if targets.is_empty():
        return

    var target: BattlerData = targets[randi() % targets.size()]
    _execute_attack(battler, target)
```

### CheckResult State

Save as `res://systems/battle/states/check_result_state.gd`:

```gdscript
extends BattleState
## Checks if the battle is over after an action.


func enter(_context: Dictionary = {}) -> void:
    if not battle_manager.is_enemy_alive():
        battle_manager.transition_to_state("Victory")
    elif not battle_manager.is_party_alive():
        battle_manager.transition_to_state("Defeat")
    else:
        # More turns to process, go back to TurnStart
        # The TurnStart state will get the next battler from the queue
        _process_next_in_queue()


func _process_next_in_queue() -> void:
    var battler := battle_manager.get_next_battler()

    if battler == null:
        # Round over, start a new round
        battle_manager.transition_to_state("TurnStart")
        return

    battle_manager.current_battler = battler
    battler.defense_boost = 0
    battle_manager.turn_started.emit(battler)

    if battler.is_player_controlled:
        battle_manager.transition_to_state("PlayerChoice", {battler = battler})
    else:
        battle_manager.transition_to_state("ActionExecute", {
            battler = battler,
            action = "enemy_turn",
        })
```

### Victory and Defeat States

Save as `res://systems/battle/states/victory_state.gd`:

```gdscript
# victory_state.gd
extends BattleState
## Battle won! Show results and return to overworld.


func enter(_context: Dictionary = {}) -> void:
    print("Victory! All enemies defeated!")
    battle_manager.battle_won.emit()
    # Module 18 will add XP, gold, and item drops here
    await get_tree().create_timer(2.0).timeout
    # Return to overworld (Module 18 will handle this properly)
```

Save as `res://systems/battle/states/defeat_state.gd`:

```gdscript
# defeat_state.gd
extends BattleState
## Party wiped. Game over flow.


func enter(_context: Dictionary = {}) -> void:
    print("Defeat... the party has fallen.")
    battle_manager.battle_lost.emit()
    # Module 18 will add the game over screen
    await get_tree().create_timer(2.0).timeout
```

## Transitioning to Battle

The overworld needs to trigger battle transitions. Update the SceneManager to support battle-specific transitions:

```gdscript
# Add to scene_manager.gd
# Place these two variables after the existing _is_transitioning variable.
# Place both methods after the existing _place_player_at_spawn() method.

var _previous_scene_path: String = ""
var _previous_player_position: Vector2 = Vector2.ZERO


func start_battle(encounter_data: Dictionary) -> void:
    if _is_transitioning:
        return

    _is_transitioning = true

    # Remember where we were
    var player := get_tree().get_first_node_in_group("player")
    if player:
        _previous_player_position = player.global_position
    _previous_scene_path = get_tree().current_scene.scene_file_path

    transition_started.emit()
    _anim_player.play("fade_out")
    await _anim_player.animation_finished

    get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
    await get_tree().scene_changed

    # Initialize the battle with encounter data
    var battle_scene := get_tree().current_scene
    if battle_scene.has_method("initialize_battle"):
        battle_scene.initialize_battle(
            encounter_data.get("party", []),
            encounter_data.get("enemies", []),
        )

    _anim_player.play("fade_in")
    await _anim_player.animation_finished
    _is_transitioning = false
    transition_finished.emit()


func return_from_battle() -> void:
    if _previous_scene_path.is_empty():
        return

    change_scene(_previous_scene_path, "default")
    # After scene loads, restore player position
    await transition_finished
    var player := get_tree().get_first_node_in_group("player")
    if player:
        player.global_position = _previous_player_position
```

## Testing the Battle

For now, you can test by adding a temporary button or trigger in Willowbrook that starts a battle. Add this to `willowbrook.gd`:

```gdscript
func _input(event: InputEvent) -> void:
    # Temporary: press B to start a test battle
    if event is InputEventKey and event.pressed and event.keycode == KEY_B:
        _start_test_battle()


func _start_test_battle() -> void:
    var hero_data := BattlerData.new()
    hero_data.character_data = load("res://data/characters/aiden.tres")
    hero_data.is_player_controlled = true

    # Create a temporary enemy
    var enemy_char := CharacterData.new()
    enemy_char.display_name = "Slime"
    enemy_char.max_hp = 30
    enemy_char.attack = 5
    enemy_char.defense = 2
    enemy_char.speed = 4

    var enemy_data := BattlerData.new()
    enemy_data.character_data = enemy_char
    enemy_data.is_player_controlled = false

    SceneManager.start_battle({
        party = [hero_data],
        enemies = [enemy_data],
    })
```

## The Battle Flow

Here's the complete state flow visualized:

```
[INTRO] → Brief pause/animation
    ↓
[TURN_START] → Build turn queue (sorted by speed)
    ↓
[PLAYER_CHOICE] or [ACTION_EXECUTE (enemy)]
    ↓                        ↓
(Player picks action)   (Enemy AI picks action)
    ↓                        ↓
[ACTION_EXECUTE] ←──────────┘
    ↓
[CHECK_RESULT]
    ↓
    ├── All enemies dead → [VICTORY]
    ├── All party dead → [DEFEAT]
    └── More turns → next battler in queue (PlayerChoice or ActionExecute)
         └── Queue empty → back to [TURN_START] for new round
```

Each state is isolated. Adding new actions (magic, items, defend) means adding branches in `PlayerChoice` and `ActionExecute`, not restructuring the entire flow.

> **See:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html): the base class for all scene tree nodes. The node-based state machine pattern uses `get_children()` and polymorphism.

> **See:** [SceneTree.create_timer()](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-create-timer): creates a one-shot timer. Used with `await` in states for pacing.

> **See:** [Array.sort_custom()](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-sort-custom): custom sorting with a callable. Used for speed-based turn ordering.

**Autoload reference card** (unchanged from Module 12; no new autoloads this module):

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |

> **Note:** BattleManager is NOT an autoload. It is the root script of `battle.tscn` and only exists during battles. The SceneManager loads the battle scene and calls `initialize_battle()` on it.

## State Machines vs State Stacks

We've now seen two kinds of state management in Crystal Saga. They solve different problems, and knowing which one to reach for will save you from architectural headaches as your game grows.

**State Machine** (mutually exclusive states): Only one state is active at a time. Transitioning from PLAYER_CHOICE to ACTION_EXECUTE *replaces* the active state. The battle system uses this because you're always in exactly one phase of combat.

**State Stack** (layered states): Multiple states can be active simultaneously, stacked on top of each other. Menus are the classic JRPG example: the game world stays loaded, the tree is paused, and a UI layer sits on top until the player closes it.

That is **not** what Crystal Saga's battle flow is doing right now. `SceneManager.start_battle()` stores the previous scene path and player position, changes to the battle scene, and `return_from_battle()` reconstructs the overworld scene afterward. The previous scene is destroyed and later rebuilt; it is not preserved underneath battle.

The same pattern applies to menus: opening the inventory pushes a new layer on top of the game. The game world is still there, just paused. Closing the menu pops the layer and the game resumes.

| Pattern | Active States | Example | When to Use |
|---------|--------------|---------|-------------|
| State Machine | Exactly one | Battle phases, player movement states | Mutually exclusive modes |
| State Stack | Many (layered) | Game + pause menu, game + dialogue, menu + sub-menu | Modes that overlay other modes |

The rule of thumb: if the previous state should be *destroyed* when you leave it, use a state machine or a scene swap. If it should be *preserved* underneath, use a state stack or overlay UI.

## Engineering Contract

- **Global state:** BattleManager is scene-local, not an autoload.
- **Public surface:** `initialize_battle()`, `transition_to_state()`, battle result signals, and read-only battle data used by states.
- **Invariant:** States transition through the BattleManager facade and do not reach into private `_state_machine` ownership.
- **Failure behavior:** Unknown state names log an error and leave the current state unchanged.
- **Copy semantics:** `BattlerData` is runtime battle state; persistent CharacterData is synced only at defined battle boundaries.

## Engine Gotcha

Node-based state machines are ordinary scene trees. Child state names are string keys, so renaming a state node without updating transition calls breaks runtime flow.

## What We've Learned

- **Node-based state machines** use child Nodes with `enter()`/`process()`/`exit()` methods, managed by a machine node. Better than enums for complex state flows.
- **State machines vs state stacks**: machines for exclusive states (battle phases), stacks for layered UI (pause and menus). Crystal Saga's current battle transition is a scene swap plus reconstruction, not an overworld-under-battle stack.
- **BattlerData** is a Resource combining character stats with runtime battle state (current HP, temporary buffs).
- **Turn order** is speed-based: sort all alive battlers by speed, process them in order.
- The **battle scene** has party on one side, enemies on the other, with Marker2D nodes for positioning.
- **State transitions** pass **context dictionaries** so states can share data (the active battler, the chosen target, the action type).
- The **SceneManager** remembers the previous scene and player position for returning from battle.
- Each battle state is a separate script file, easy to modify one state without touching others.

## What You Should See

When you press B (our temporary test trigger) in Willowbrook:
- Screen fades to black
- Battle scene appears with the hero and a Slime
- Output panel shows turn-by-turn combat:
  - "Aiden's turn! (auto-attacking)"
  - "Aiden attacks Slime for 10 damage!"
  - "Slime attacks Aiden for 5 damage!"
- Combat continues until one side is defeated
- "Victory!" or "Defeat..." appears in output

## Next Module

The battle runs automatically, and the player can't choose actions yet. In **Module 15: Player Actions**, we'll build the battle menu UI (Attack/Magic/Defend/Item), implement the command pattern for actions, add target selection, and create battle animations with Tweens. The battle system will go from print output to visual, interactive combat.

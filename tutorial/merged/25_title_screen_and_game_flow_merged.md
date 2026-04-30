# Merged Tutorial Through Module 25

This generated file combines the tutorial Markdown files from Module 01 through Module 25.

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
- `15_player_actions.md`
- `16_crystal_cavern.md`
- `17_enemies_and_ai.md`
- `18_victory_and_leveling.md`
- `19_part_iv_review.md`
- `20_quest_system.md`
- `21_party_and_equipment.md`
- `22_save_and_load.md`
- `23_part_v_review.md`
- `24_audio.md`
- `25_title_screen_and_game_flow.md`

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


---

<!-- Source: 15_player_actions.md -->

# Module 15: Player Actions: Attack, Defend, Magic, Items

## What We Have So Far

A battle system with a node-based state machine, turn order, and automatic combat. But the player can't make choices. Everything happens automatically.

## What We're Building This Module

The battle menu (Attack/Magic/Defend/Item), target selection, the damage formula, battle animations, and floating damage numbers. By the end, battles will be fully interactive.

## The Battle Menu UI

Create `res://ui/battle/battle_menu.tscn`:

```
BattleMenu (PanelContainer)
└── MarginContainer
    └── ActionList (VBoxContainer)
        ├── AttackButton (Button: "Attack")
        ├── MagicButton (Button: "Magic")
        ├── DefendButton (Button: "Defend")
        └── ItemButton (Button: "Item")
```

Script `res://ui/battle/battle_menu.gd`:

```gdscript
extends PanelContainer
## The main battle action menu.

signal action_chosen(action: String)

@onready var _attack_btn: Button = $MarginContainer/ActionList/AttackButton
@onready var _magic_btn: Button = $MarginContainer/ActionList/MagicButton
@onready var _defend_btn: Button = $MarginContainer/ActionList/DefendButton
@onready var _item_btn: Button = $MarginContainer/ActionList/ItemButton


func _ready() -> void:
    _attack_btn.pressed.connect(func() -> void: action_chosen.emit("attack"))
    _magic_btn.disabled = true
    _magic_btn.tooltip_text = "Magic is a future extension."
    _defend_btn.pressed.connect(func() -> void: action_chosen.emit("defend"))
    _item_btn.pressed.connect(func() -> void: action_chosen.emit("item"))


func show_menu() -> void:
    visible = true
    _attack_btn.grab_focus()


func hide_menu() -> void:
    visible = false
```

> **See:** [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html): focus navigation between buttons with keyboard/gamepad.

## The Command Pattern

In Final Fantasy X, the game shows you a preview of the turn order before you commit to an action. Choosing Haste on yourself moves your icon up in the queue; choosing a slow spell pushes it back. This preview is only possible because actions are data objects that can be inspected before execution. If "Attack" were just a function call, there would be nothing to preview. By representing actions as data, we separate the decision from the execution.

Each battle action follows the same interface: an attacker does something to a target. We structure this as a dictionary command:

```gdscript
var command: Dictionary = {
    action = "attack",     # What to do
    battler = battler,     # Who does it
    target = target,       # Who receives it
    item = null,           # Optional: which item (for item use)
}
```

This pattern keeps the action execution generic. The `ActionExecute` state doesn't need to know the details of every possible action; it just reads the command dictionary.

## Target Selection

Target selection is where strategy enters combat. In Earthbound, choosing to focus fire on the Territorial Oak instead of spreading damage across all enemies is often the difference between a clean fight and a party wipe. Without target selection, combat would be "press Attack and watch numbers happen." With it, every attack is a decision.

When the player chooses Attack, they need to pick which enemy to target. Create a target selection sub-system:

```gdscript
extends PanelContainer
## Shows a list of targets for the player to select.

signal target_selected(target: BattlerData)
signal cancelled

@onready var _target_list: VBoxContainer = $MarginContainer/TargetList


func show_targets(targets: Array[BattlerData]) -> void:
    visible = true

    for child in _target_list.get_children():
        child.queue_free()

    await get_tree().process_frame

    for target in targets:
        var button := Button.new()
        button.text = target.character_data.display_name + " (HP: " + str(target.current_hp) + ")"
        button.pressed.connect(func() -> void: target_selected.emit(target))
        _target_list.add_child(button)

    await get_tree().process_frame
    if _target_list.get_child_count() > 0:
        _target_list.get_child(0).grab_focus()


func hide_targets() -> void:
    visible = false


func _unhandled_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        cancelled.emit()
        get_viewport().set_input_as_handled()
```

Save this as `res://ui/battle/target_select.gd`, and create `res://ui/battle/target_select.tscn` with this scene tree:

```
TargetSelect (PanelContainer)
└── MarginContainer
    └── TargetList (VBoxContainer)
```

## Integrating the Battle Menu into the Battle Scene

Open `battle.tscn` and instance both UI scenes under the `BattleUI` CanvasLayer:

```
BattleUI (CanvasLayer, layer = 10)
├── BattleMenu (instance of battle_menu.tscn)
└── TargetSelect (instance of target_select.tscn)
```

Set both to **visible = false** initially in the Inspector.

## Updating the PlayerChoice State

This is the critical wiring that connects the menu to the state machine. **Replace** the contents of `res://systems/battle/states/player_choice_state.gd` (the Module 14 placeholder that auto-attacked):

```gdscript
extends BattleState
## Waits for the player to choose an action from the battle menu.

var _active_battler: BattlerData
var _battle_menu: PanelContainer
var _target_select: PanelContainer


func enter(context: Dictionary = {}) -> void:
    _active_battler = context.get("battler")

    # Find UI nodes in the battle scene
    _battle_menu = get_tree().current_scene.get_node("BattleUI/BattleMenu")
    _target_select = get_tree().current_scene.get_node("BattleUI/TargetSelect")

    # Connect signals
    _battle_menu.action_chosen.connect(_on_action_chosen)
    _target_select.target_selected.connect(_on_target_selected)
    _target_select.cancelled.connect(_on_target_cancelled)

    _battle_menu.show_menu()


func exit() -> void:
    _battle_menu.hide_menu()
    _target_select.hide_targets()

    # Disconnect to avoid duplicate connections on re-entry
    if _battle_menu.action_chosen.is_connected(_on_action_chosen):
        _battle_menu.action_chosen.disconnect(_on_action_chosen)
    if _target_select.target_selected.is_connected(_on_target_selected):
        _target_select.target_selected.disconnect(_on_target_selected)
    if _target_select.cancelled.is_connected(_on_target_cancelled):
        _target_select.cancelled.disconnect(_on_target_cancelled)


func _on_action_chosen(action: String) -> void:
    match action:
        "attack":
            _battle_menu.hide_menu()
            _target_select.show_targets(battle_manager.get_alive_enemies())
        "defend":
            battle_manager.transition_to_state("ActionExecute", {
                battler = _active_battler,
                action = "defend",
            })
        "item":
            # Item use in battle (simplified for now)
            var consumables := InventoryManager.get_consumables()
            if consumables.is_empty():
                print("No items!")
                _battle_menu.show_menu()
            else:
                # Use first consumable on self (simplified)
                var item: ItemData = consumables[0].item
                battle_manager.transition_to_state("ActionExecute", {
                    battler = _active_battler,
                    action = "item",
                    target = _active_battler,
                    item = item,
                })


func _on_target_selected(target: BattlerData) -> void:
    _target_select.hide_targets()
    battle_manager.transition_to_state("ActionExecute", {
        battler = _active_battler,
        action = "attack",
        target = target,
    })


func _on_target_cancelled() -> void:
    _target_select.hide_targets()
    _battle_menu.show_menu()
```

This wires the complete flow: menu appears → player picks action → target selection if needed → command passed to ActionExecute.

> **Note:** Magic is visible in the menu but disabled. We keep the button because most JRPG battle menus reserve space for spells, but `AbilityData` is a future extension, not part of this core tutorial. Item use is simplified for now: it picks the first consumable automatically. In a full game, you'd show an item selection sub-menu.

## The Damage Formula

### Why Stats Exist

Before writing a formula, think about *why* stats exist at all. There are three good reasons to add a stat to your RPG:

1. **The simulation needs it.** If you want to calculate "who hits harder," you need a Strength stat. If you want "who acts first," you need Speed. Stats are numbers that feed your combat math.
2. **It defines characters by difference.** A dragon should feel different from a goblin. If you only have HP and Attack, every enemy is just a bag of hit points. Speed, Defense, and Magic create variety.
3. **It creates player choices.** Stats that the player can influence (through equipment, levels, or buffs) give strategic depth. "Do I boost Attack or Defense?" is only meaningful if both stats feed into the formula.

If a stat doesn't serve at least one of these purposes, it's clutter.

### Our Damage Formula

A damage formula should be simple to understand, produce meaningful numbers, and allow for strategic depth. Here's ours:

```gdscript
static func calculate_damage(attacker: BattlerData, target: BattlerData) -> int:
    var raw: int = attacker.current_attack - target.get_effective_defense()
    var variance: int = randi_range(-2, 2)
    return max(1, raw + variance)
```

This means:
- **Raw damage** = attacker's attack minus target's effective defense
- **Variance** adds ±2 randomness
- **Minimum damage** is always 1 (you always do at least something)

The Defend action increases `defense_boost`, making `get_effective_defense()` return a higher value, reducing incoming damage.

> **JRPG Pattern:** Most JRPGs keep their damage formula visible and understandable. Players should be able to reason about "if I equip this sword (+5 attack), I'll do roughly 5 more damage per hit." Complex formulas with hidden multipliers frustrate players.

### Alternative Formulas Used in Real RPGs

Our formula is subtractive: `attack - defense = damage`. This is the simplest family of damage formulas, and it works well for small number ranges. But it has a quirk: if defense is close to attack, damage drops to nearly zero and the `max(1)` floor kicks in constantly. With large stat growth, damage can also spike hard. Here are three other approaches real RPGs use:

**Multiplicative (Final Fantasy style):**
```
base_damage = random(attack, attack * 2)
damage = base_damage - defense
```
The random range between 1x and 2x attack adds drama. A lucky hit does double. Defense still subtracts, but the higher ceiling means defense rarely walls you completely.

**Ratio-based (Pokemon style):**
```
damage = (attack / defense) * base_power * modifier
```
The ratio means doubling your attack always doubles your damage, regardless of the target's defense. This produces stable, predictable scaling. The `modifier` term handles type effectiveness, critical hits, and random variance.

**Armor-as-percentage:**
```
reduction = defense / (defense + constant)
damage = attack * (1.0 - reduction)
```
Defense gives diminishing returns. The first 10 points of defense reduce a lot of damage; the next 10 reduce less. This prevents any character from becoming truly invincible through stacking defense. Many action RPGs use this.

Our subtractive formula is the right choice for Crystal Saga's scope. If you extend the game significantly, revisit the formula when you notice balance problems (damage too low at high levels, or defense becoming meaningless).

### Accuracy, Evasion, and Critical Hits

Our formula always hits. That's fine for a tutorial game, but commercial JRPGs usually layer accuracy on top of damage. Here's the general pattern:

```
1. Roll hit chance:   base_accuracy + (attacker.speed / max_speed) / 2
2. Roll dodge chance: base_evasion + (target.speed - attacker.speed) * 0.01
3. If miss: show "MISS", deal 0 damage
4. Roll critical:     small flat chance (5-10%)
5. If critical:       damage * 1.5 or damage + bonus roll
6. Otherwise:         normal damage
```

The key design insight: **speed should do double duty**. It determines turn order (Module 14) *and* influences hit/dodge rates. This makes Speed a meaningful stat without adding separate Accuracy and Evasion stats to your character sheet.

We won't implement this in Crystal Saga, but if you find battles feel too deterministic, adding a miss chance (even just 5-10%) adds tension. Players remember the time they dodged a killing blow.

### Isolate Your Formulas

Put all combat math in one file (we use `calculate_damage()` as a static function). When you start tuning your game's balance, you'll change these numbers constantly. Having them scattered across battle states, AI scripts, and item effects makes tuning painful. One file, one place to tweak.

## Implementing All Actions

Update the `ActionExecute` state to handle each action:

```gdscript
extends BattleState
## Executes the chosen action with animation.

func enter(context: Dictionary = {}) -> void:
    var battler: BattlerData = context.get("battler")
    var action: String = context.get("action", "attack")
    var target: BattlerData = context.get("target")
    var item = context.get("item")

    match action:
        "attack":
            await _execute_attack(battler, target)
        "defend":
            _execute_defend(battler)
        "item":
            _execute_item(battler, target, item)
        "enemy_turn":
            await _execute_enemy_turn(battler)

    await get_tree().create_timer(0.3).timeout
    battle_manager.transition_to_state("CheckResult")


func _execute_attack(attacker: BattlerData, target: BattlerData) -> void:
    var damage := max(1, attacker.current_attack - target.get_effective_defense() + randi_range(-2, 2))
    damage = max(1, damage)

    await _play_attack_animation(attacker)
    var actual := target.take_damage(damage)
    _spawn_damage_number(target, actual)
    battle_manager.action_executed.emit(attacker, target, actual)


func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense  # Double defense for one turn
    print(battler.character_data.display_name + " defends!")


func _execute_item(user: BattlerData, target: BattlerData, item: ItemData) -> void:
    if not item:
        return
    if item.hp_restore > 0:
        var healed := target.heal(item.hp_restore)
        _spawn_damage_number(target, healed, true)
    InventoryManager.remove_item(item)


func _execute_enemy_turn(battler: BattlerData) -> void:
    var targets := battle_manager.get_alive_party()
    if targets.is_empty():
        return
    var target: BattlerData = targets[randi() % targets.size()]
    await _execute_attack(battler, target)
```

## Battle Animations with Tweens

Without animation, combat is just numbers changing in a log. The original Final Fantasy proved that even simple sprite slides (a character stepping forward, pausing, then stepping back) transform a math equation into a fight. Floating damage numbers, first popularized by Diablo and now standard in everything from Final Fantasy XIV to Fortnite, give the player instant visual feedback on what just happened. These two elements, motion and numbers, are the minimum viable "game feel" for turn-based combat.

Animations make combat feel impactful. The classic JRPG attack animation: the attacker slides forward, pauses, then slides back.

Add both `_play_attack_animation` and `_find_battler_sprite` to `res://systems/battle/states/action_execute_state.gd` (the same script as the action execution code above):

```gdscript
func _play_attack_animation(attacker: BattlerData) -> void:
    var sprite := _find_battler_sprite(attacker)
    if not sprite:
        return
    var direction := -1.0 if attacker.is_player_controlled else 1.0
    var original_pos: Vector2 = sprite.position

    var tween := create_tween()
    tween.tween_property(sprite, "position:x", original_pos.x + 30.0 * direction, 0.15)
    tween.tween_interval(0.1)
    tween.tween_property(sprite, "position:x", original_pos.x, 0.15)
    await tween.finished


func _find_battler_sprite(battler: BattlerData) -> Node2D:
    for sprite in get_tree().get_nodes_in_group("battler_sprites"):
        if sprite.battler_data == battler:
            return sprite
    return null
```

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html): `tween_property()`, `tween_interval()`, chaining, and `await finished`.

## Floating Damage Numbers

A small label that rises and fades when damage is dealt. Add this method to `action_execute_state.gd` alongside the animation methods:

```gdscript
func _spawn_damage_number(target: BattlerData, amount: int, is_heal: bool = false) -> void:
    var sprite_node := _find_battler_sprite(target)
    if not sprite_node:
        return

    var label := Label.new()
    label.text = str(amount)
    label.add_theme_color_override("font_color", Color.GREEN if is_heal else Color.WHITE)
    label.z_index = 100
    # Add the label as a child of the sprite (Node2D), not the scene root.
    # This ensures the label uses Node2D coordinates, matching the sprite's position.
    sprite_node.add_child(label)
    label.position = Vector2(0, -20)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", -50.0, 0.8)
    tween.tween_property(label, "modulate:a", 0.0, 0.8)
    tween.chain().tween_callback(label.queue_free)
```

This creates a label that floats upward and fades out over 0.8 seconds, then removes itself.

> **Note:** `set_parallel(true)` makes the next tweens run simultaneously (moving up AND fading at the same time). `chain()` returns to sequential mode for the cleanup callback.

## The Defend Action as a Temporary Buff

Defend doubles the battler's defense for one turn:

```gdscript
func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense
```

The boost is reset at the start of the battler's next turn (in the turn processing logic):

```gdscript
battler.defense_boost = 0  # Reset before the battler acts
```

This is the simplest form of a temporary status effect. In Module 26 (Next Steps), we'll discuss generalizing this into a full status effects system with poison, sleep, buffs, and debuffs.

## Complete action_execute_state.gd

For reference, here is the complete `res://systems/battle/states/action_execute_state.gd` with all methods from this module merged into one file:

```gdscript
extends BattleState
## Executes the chosen action with animation.

func enter(context: Dictionary = {}) -> void:
    var battler: BattlerData = context.get("battler")
    var action: String = context.get("action", "attack")
    var target: BattlerData = context.get("target")
    var item = context.get("item")

    match action:
        "attack":
            await _execute_attack(battler, target)
        "defend":
            _execute_defend(battler)
        "item":
            _execute_item(battler, target, item)
        "enemy_turn":
            await _execute_enemy_turn(battler)

    await get_tree().create_timer(0.3).timeout
    battle_manager.transition_to_state("CheckResult")


func _execute_attack(attacker: BattlerData, target: BattlerData) -> void:
    var damage := max(1, attacker.current_attack - target.get_effective_defense() + randi_range(-2, 2))
    damage = max(1, damage)

    await _play_attack_animation(attacker)
    var actual := target.take_damage(damage)
    _spawn_damage_number(target, actual)
    battle_manager.action_executed.emit(attacker, target, actual)


func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense
    print(battler.character_data.display_name + " defends!")


func _execute_item(user: BattlerData, target: BattlerData, item: ItemData) -> void:
    if not item:
        return
    if item.hp_restore > 0:
        var healed := target.heal(item.hp_restore)
        _spawn_damage_number(target, healed, true)
    InventoryManager.remove_item(item)


func _execute_enemy_turn(battler: BattlerData) -> void:
    var targets := battle_manager.get_alive_party()
    if targets.is_empty():
        return
    var target: BattlerData = targets[randi() % targets.size()]
    await _execute_attack(battler, target)


func _play_attack_animation(attacker: BattlerData) -> void:
    var sprite := _find_battler_sprite(attacker)
    if not sprite:
        return
    var direction := -1.0 if attacker.is_player_controlled else 1.0
    var original_pos: Vector2 = sprite.position

    var tween := create_tween()
    tween.tween_property(sprite, "position:x", original_pos.x + 30.0 * direction, 0.15)
    tween.tween_interval(0.1)
    tween.tween_property(sprite, "position:x", original_pos.x, 0.15)
    await tween.finished


func _find_battler_sprite(battler: BattlerData) -> Node2D:
    for sprite in get_tree().get_nodes_in_group("battler_sprites"):
        if sprite.battler_data == battler:
            return sprite
    return null


func _spawn_damage_number(target: BattlerData, amount: int, is_heal: bool = false) -> void:
    var sprite_node := _find_battler_sprite(target)
    if not sprite_node:
        return

    var label := Label.new()
    label.text = str(amount)
    label.add_theme_color_override("font_color", Color.GREEN if is_heal else Color.WHITE)
    label.z_index = 100
    sprite_node.add_child(label)
    label.position = Vector2(0, -20)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", -50.0, 0.8)
    tween.tween_property(label, "modulate:a", 0.0, 0.8)
    tween.chain().tween_callback(label.queue_free)
```

## Engineering Contract

- **Global state:** Player actions consume InventoryManager items but battle decisions stay scene-local.
- **Public surface:** Battle menu emits action strings; target select emits chosen battlers; ActionExecute consumes command dictionaries.
- **Invariant:** Commands only use implemented fields: `action`, `battler`, `target`, and optional `item`.
- **Failure behavior:** Magic remains disabled until a future ability system exists.
- **Copy semantics:** Commands hold references to current runtime battlers; they should be executed immediately, not saved.

## Engine Gotcha

Signals connected in `enter()` must be disconnected in `exit()`. Otherwise returning to PlayerChoice can stack duplicate signal connections and execute one button press multiple times.

## What We've Learned

- The **battle menu** uses VBoxContainer with Buttons and `grab_focus()` for keyboard navigation.
- **Target selection** presents enemy names as buttons; cancelling returns to the menu.
- The **command pattern** represents actions as dictionaries: `{action, battler, target, item}`.
- **Stats exist for three reasons:** the simulation needs them, they differentiate characters, and they create player choices. If a stat doesn't serve at least one purpose, remove it.
- **Damage formula:** `max(1, attack - defense + random_variance)`. Our subtractive formula is simple and transparent. Alternatives include multiplicative (Final Fantasy), ratio-based (Pokemon), and armor-as-percentage formulas, each with different scaling behavior.
- **Isolate your formulas** in one place. Combat math gets tweaked constantly during balancing; scattering it across files makes tuning painful.
- **Battle animations** use Tweens: slide forward → pause → slide back.
- **Floating damage numbers** rise and fade using parallel tweens.
- **Defend** is a temporary defense buff, the simplest status effect pattern.
- `set_parallel(true)` and `chain()` control Tween sequencing.

## What You Should See

When a battle starts:
- A menu appears: Attack / Magic / Defend / Item
- Selecting Attack shows enemy targets
- Choosing a target plays a slide animation and shows a damage number
- Defend doubles defense for one turn
- Using an Item consumes it from inventory
- The enemy takes its turn automatically
- Combat feels responsive and interactive

## Next Module

We have interactive battles, but we're fighting placeholder Slimes with a debug key. In **Module 16: The Crystal Cavern**, we'll build a dungeon with its own tilemap, encounter zones, treasure chests, and a boss room, giving the battle system a proper home.


---

<!-- Source: 16_crystal_cavern.md -->

# Module 16: The Crystal Cavern, Dungeon Design

## What We Have So Far

A town, a forest, a battle system with actions and animations, and an inventory. We need a destination, somewhere that tests the player's skills and rewards their preparation.

## What We're Building This Module

The **Crystal Cavern**: a dungeon area with a distinct tileset, multiple rooms connected by passages, treasure chests, encounter zones for random battles, a save crystal, and a boss room at the end. This is level design, not system design. We're applying everything we've learned about TileMaps, scene transitions, and interactables.

Dungeons are where RPGs test everything the player has prepared. In Zelda, each dungeon introduces a new item and then builds puzzles around mastering it. In Final Fantasy, dungeons are gauntlets that drain your party's resources over time. Each random battle costs HP and MP, and the question is whether you can reach the boss with enough left to win. A well-designed dungeon creates a rising tension curve: easy rooms at the start, harder encounters deeper in, a save point right before the climax, and a boss that demands everything you've learned.

## Dungeon vs Overworld Design

Dungeons differ from overworld areas in several ways:

| Aspect | Overworld (Willowbrook, Whisperwood) | Dungeon (Crystal Cavern) |
|--------|--------------------------------------|--------------------------|
| Tile palette | Grass, trees, paths, buildings | Cave walls, stone floor, crystals |
| Layout | Open, organic, free-roaming | Corridors, rooms, controlled flow |
| Collision | Boundary trees and water | Walls everywhere, tight spaces |
| Encounters | Occasional (forest only) | Frequent, every few steps |
| Items | Shops (buy) | Treasure chests (find) |
| Save points | Towns (convenient) | Rare (crystals, strategic) |
| Goal | Exploration and socializing | Challenge and progression |

## Cave Tileset Assets

You'll need cave or dungeon tiles for the Crystal Cavern. Here are your options:

**Option 1, free tileset pack:** Download the [Kenney 1-Bit Pack](https://kenney.nl/assets/1-bit-pack) which includes cave and dungeon tiles. Extract it and copy the relevant tile sheets to `res://assets/tilesets/`.

**Option 2, reuse and recolor:** Duplicate the TileSet from Module 5. Open the new TileSet resource, and in the Physics/Terrain tabs, you can reuse the same workflow. Many JRPG tileset packs include both outdoor and dungeon tiles in the same set.

**Option 3, placeholder tiles:** Open any image editor (GIMP, Paint.NET, Piskel, or even a browser-based pixel editor) and create a 64x16 PNG with four 16x16 colored squares side by side: dark grey for walls (`#404050`), lighter grey for walkable floor (`#737380`), blue-purple for crystal decorations (`#664DB3`), and black for void/pits (`#1A1A1A`). Save it as `res://assets/tilesets/cave_tiles.png`.

**Recommended:** Use Option 3 (placeholder tiles) to keep moving without interruption. You can swap in real art later. Options 1-2 look better but require downloading and importing external assets.

Whichever approach you use, the TileSet creation workflow is the same as Module 5:

1. Create a TileSet resource: right-click `res://scenes/crystal_cavern/` → New Resource → TileSet
2. Set the **Tile Size** to `16x16` (must be done before adding an atlas)
3. In the TileSet panel, click **+** → Atlas → drag your cave tile sheet into the Texture slot
4. Click **Yes** when prompted to create tiles automatically
5. Switch to the Paint tab, select **Physics Layer 0**, and paint collision on wall tiles
6. Save the TileSet as `res://scenes/crystal_cavern/cave_tileset.tres`
7. Assign it to each TileMapLayer in the Inspector

If any of these steps feel unclear, revisit Module 5's "Creating the TileSet" section for the full walkthrough.

## Building the Cave Tilemap

Create `res://scenes/crystal_cavern/crystal_cavern.tscn` with the familiar layer structure, but using cave-themed tiles:

```
CrystalCavern (Node2D)
├── Ground (TileMapLayer)      : stone floors, cave ground
├── Detail (TileMapLayer)      : cracks, rubble, small crystals
├── YSortGroup (Node2D, y_sort_enabled)
│   ├── Objects (TileMapLayer) : large crystal formations, stalagmites
│   ├── Player (instance)
│   └── ... (treasure chests, save crystal)
├── AbovePlayer (TileMapLayer) : cave ceiling overhangs, arches
├── Exits (Node2D)
│   ├── ExitToWhisperwood (Area2D + exit_zone.gd)
│   └── ... (spawn points)
├── EncounterZones (Node2D)
│   ├── MainCorridor (Area2D + CollisionShape2D)
│   └── DeepCavern (Area2D + CollisionShape2D)
├── EncounterSystem (Node)
├── DialogueBox (instance)
└── InventoryScreen (instance)
```

Instance the DialogueBox and InventoryScreen the same way as in Willowbrook: drag `dialogue_box.tscn` and `inventory_screen.tscn` from the FileSystem dock into the CrystalCavern root node. These are needed for treasure chest messages and the pause menu inventory.

### Room-Based Layout

Design the dungeon as connected rooms:

```
[Entrance] → [Main Corridor] → [Fork]
                                  ├→ [Dead End, Treasure]
                                  └→ [Deep Cavern] → [Boss Room]
                                       ↑
                                  [Save Crystal]
```

Each "room" is a region of the tilemap. Passages connect them. The fork creates a simple decision: explore the dead end for treasure, or push ahead toward the boss.

### Design Tips

- **Walls on all sides.** Unlike overworld areas with natural boundaries (trees, water), dungeon rooms need explicit walls. Fill everything with wall tiles, then carve out rooms and corridors.
- **Varied room shapes.** Rectangles are fine, but an L-shaped room or a round cavern adds visual interest.
- **Visual landmarks.** Place unique crystal formations or broken pillars at decision points so the player can orient themselves.
- **Width variety.** Tight corridors create tension. Open rooms offer relief. Alternate between them.

> **Spiral:** All the TileMapLayer skills from Module 5 apply here: multiple layers, physics on wall tiles, pixel-perfect settings. The only difference is the tile palette.

## Treasure Chests

Treasure chests are the oldest reward mechanism in RPGs. In the original Dragon Quest, finding a chest in a dungeon was a moment of genuine excitement, because the player risked death to explore a dead end and the chest validated that risk. Chests serve two design purposes: they reward exploration (players who check every corner find better gear) and they pace the dungeon (a Potion in a mid-dungeon chest might be the difference between reaching the boss and having to retreat).

A chest is an interactable that gives the player an item. It's a reusable scene.

Create `res://entities/interactable/treasure_chest.tscn`:

```
TreasureChest (StaticBody2D)
├── Sprite (Sprite2D)          : closed/open chest image
├── CollisionShape2D           : blocks walking through
├── InteractionZone (Area2D)
│   └── CollisionShape2D
└── InteractionPrompt (Label, hidden)  : text "!", font_size 12
```

> **Note:** We use a `Label` for the interaction prompt (just like the NPC prompt in Module 10) because it works without any art assets. If you prefer, you can swap it for a `Sprite2D` with a custom icon later.

Script `res://entities/interactable/treasure_chest.gd`:

```gdscript
extends StaticBody2D
## A treasure chest that gives the player an item when opened.

signal opened

@export var item: ItemData
@export var item_count: int = 1
@export var chest_id: String = ""  # Stable ID; Module 22 uses this for save tracking

var is_opened: bool = false

@onready var _sprite: Sprite2D = $Sprite
@onready var _prompt: Label = $InteractionPrompt
@onready var _zone: Area2D = $InteractionZone

var _player_in_range: bool = false


func _ready() -> void:
    _zone.body_entered.connect(_on_body_entered)
    _zone.body_exited.connect(_on_body_exited)
    _prompt.visible = false
    add_to_group("interactables")


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range or is_opened:
        return
    if event.is_action_pressed("interact"):
        _open()
        get_viewport().set_input_as_handled()


func _open() -> void:
    is_opened = true
    _prompt.visible = false
    # Change sprite to open chest (if you have one)
    # _sprite.frame = 1  # or swap texture

    if item:
        InventoryManager.add_item(item, item_count)
        print("Found: " + item.display_name + " x" + str(item_count))

    opened.emit()


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and not is_opened:
        _player_in_range = true
        _prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _prompt.visible = false
```

For this module, `is_opened` is scene-local runtime state. The `chest_id` export is a stable identifier we will use in Module 22 when save/load starts persisting opened chests through `GameManager` world flags.

Place chests in the dungeon using the editor:
- **Dead End room:** A Potion and an Ether
- **Before boss room:** An Iron Sword (if the player hasn't bought one)

Set the `@export var item` in the Inspector by dragging the `.tres` file into the slot.

## The Save Crystal

The save crystal before a boss room is one of the most recognizable design patterns in JRPGs. In every Final Fantasy game, seeing that glowing crystal means two things: "danger is ahead" and "you won't lose your progress." Save points are as much a narrative device as a mechanical one; they build anticipation. The absence of save points in a long corridor creates anxiety; their appearance after a tough fight creates relief.

A classic JRPG save point, a glowing crystal the player interacts with. For now, it just prints "Game saved!". We'll wire it to the actual save system in Module 22.

Create `res://entities/interactable/save_crystal.tscn`:

```
SaveCrystal (StaticBody2D)
├── Sprite (Sprite2D)          : crystal image (use any placeholder sprite)
├── CollisionShape2D           : blocks walking through (RectangleShape2D, 16x16)
├── InteractionZone (Area2D)
│   └── CollisionShape2D       : interaction radius (CircleShape2D, radius ~24)
└── InteractionPrompt (Label, visible = false)  : text "!", font_size 12
```

Script `res://entities/interactable/save_crystal.gd`:

```gdscript
extends StaticBody2D
## A save crystal. Lets the player save their game.

var _player_in_range: bool = false

@onready var _prompt: Label = $InteractionPrompt
@onready var _zone: Area2D = $InteractionZone


func _ready() -> void:
    _zone.body_entered.connect(_on_body_entered)
    _zone.body_exited.connect(_on_body_exited)
    _prompt.visible = false
    add_to_group("save_points")


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range:
        return
    if event.is_action_pressed("interact"):
        _activate()
        get_viewport().set_input_as_handled()


func _activate() -> void:
    # Module 22 will add actual saving here
    print("Your progress has been saved!")
    # Optional: heal the party at save points (common JRPG pattern)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _prompt.visible = false
```

Place the save crystal in the room before the boss, the classic "save point before the big fight" pattern.

## Encounter Zones

Encounter zones define where random battles can happen and which enemies appear. We'll set up the zones now and wire them to the encounter system in Module 17.

Add `Area2D` nodes to mark the encounter regions. For now, just create the Area2D nodes with CollisionShape2D children, but **don't attach scripts yet**. We'll create the encounter system and encounter zone scripts in Module 17.

For each encounter zone:
1. Create an **Area2D** node (e.g., `MainCorridor`) as a child of `EncounterZones`.
2. Add a **CollisionShape2D** child with a **RectangleShape2D**.
3. Size the rectangle to cover the room or corridor where encounters should happen (e.g., 200x100 pixels for a corridor).

Also add an **EncounterSystem** node (plain `Node`) as a direct child of the `CrystalCavern` root, **not** inside `EncounterZones`. We'll attach a script to this in Module 17.

Place two zones:
- **MainCorridor** covers the entrance corridor (easy enemies)
- **DeepCavern** covers the deeper rooms (harder enemies)

## The Boss Room Door

A locked passage that requires a key item or a quest flag. Create `res://entities/interactable/boss_door.tscn`:

```
BossDoor (StaticBody2D)
├── Sprite (Sprite2D)
├── CollisionShape2D
├── InteractionZone (Area2D)
│   └── InteractionShape (CollisionShape2D, larger radius)
└── InteractionPrompt (Label, text "!", visible = false)
```

Save the script as `res://entities/interactable/boss_door.gd`:

```gdscript
extends StaticBody2D
## A locked door that opens when the player has the right item or flag.

@export var required_item_id: String = ""
@export var unlock_message: String = "The door is locked."
@export var open_message: String = "The door opens!"

var is_unlocked: bool = false
var _player_in_range: bool = false

@onready var _interaction_zone: Area2D = $InteractionZone
@onready var _interaction_prompt: Label = $InteractionPrompt


func _ready() -> void:
    _interaction_zone.body_entered.connect(_on_body_entered)
    _interaction_zone.body_exited.connect(_on_body_exited)
    _interaction_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range or is_unlocked:
        return
    if event.is_action_pressed("interact"):
        _try_open()
        get_viewport().set_input_as_handled()


func _try_open() -> void:
    if required_item_id.is_empty() or InventoryManager.has_item(required_item_id):
        is_unlocked = true
        print(open_message)
        queue_free()
    else:
        print(unlock_message)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _interaction_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _interaction_prompt.visible = false
```

For Crystal Saga, the boss room door could require a "Crystal Key" found in the treasure room, creating a simple puzzle: explore the dead end before you can face the boss.

## Connecting the Scenes

Wire the scene transitions using the same exit zone pattern from Module 7:

1. **Crystal Cavern entrance exit:** Add an Area2D child inside the `Exits` node. Attach `exit_zone.gd` (from `res://scenes/exit_zone.gd` or wherever you saved it in Module 7). Set the exports: `target_scene` = `res://scenes/whisperwood/whisperwood.tscn`, `target_spawn` = `from_cavern`. Add a CollisionShape2D covering the cave entrance.
2. **Whisperwood south exit:** Open `whisperwood.tscn` and add a new exit zone Area2D. Set `target_scene` = `res://scenes/crystal_cavern/crystal_cavern.tscn`, `target_spawn` = `from_whisperwood`.

Add spawn points (Marker2D nodes as children of Exits, added to the `spawn_points` group):
- In Crystal Cavern: `from_whisperwood` at the cave entrance, `default` at the same position
- In Whisperwood: `from_cavern` near the south exit

> **See:** [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html), the node used for each tile layer. Same class as Module 5, now with a cave tileset.

> **See:** [StaticBody2D](https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html), used for treasure chests, save crystals, and boss doors (solid, non-moving objects).

> **See:** [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html), used for interaction zones and encounter regions. The `body_entered`/`body_exited` signals detect when the player enters.

## Engineering Contract

- **Global state:** None in this module; save crystal and chest persistence are wired in Module 22.
- **Public surface:** Dungeon scenes expose encounter zones, boss triggers, save crystals, exits, and stable object IDs.
- **Invariant:** Treasure chest IDs are stable strings even before save/load uses them.
- **Failure behavior:** Missing chest items or IDs should warn during testing rather than silently corrupt progression.
- **Copy semantics:** Scene-local `is_opened` state resets on reload until Module 22 stores it in GameManager flags.

## Engine Gotcha

Area2D triggers do not block movement by themselves. Use StaticBody2D or TileMapLayer collision for walls/objects, and Area2D only for interaction or trigger volumes.

## What We've Learned

- **Dungeon design** uses tight corridors, connected rooms, and controlled flow, different from open overworld areas.
- **Treasure chests** are interactable StaticBody2D nodes with `@export var item: ItemData`.
- **Save crystals** mark locations where the player can save (wired in Module 22).
- **Encounter zones** (Area2D) define regions where random battles trigger.
- **Locked doors** check for key items before opening, a simple puzzle design.
- **Room-based layout** with forks, dead ends, and a boss room creates exploration incentive.

## What You Should See

When you enter Crystal Cavern from Whisperwood:
- A distinct cave tilemap with stone floors and crystal walls
- Multiple connected rooms with corridors between them
- Treasure chests that give items when opened
- A save crystal that responds to interaction
- A boss room door at the far end
- Encounter zones marked (we'll add random battles next module)

## Next Module

The dungeon exists but is quiet, with no monsters. In **Module 17: Enemies and AI**, we'll create enemy types, build an encounter system that triggers random battles as you walk, design basic enemy AI, and create the Crystal Guardian boss.


---

<!-- Source: 17_enemies_and_ai.md -->

# Module 17: Enemies and AI

## What We Have So Far

Three connected areas (town, forest, dungeon), a battle system with interactive menus, and encounter zones in the Crystal Cavern waiting for enemies.

## What We're Building This Module

Enemy data types, three enemy species with basic AI, a random encounter system that triggers battles while walking, encounter groups, and the Crystal Guardian boss fight.

## EnemyData Resource

Enemies need different data than party members. A Slime doesn't have equipment slots or growth rates, but it does have XP rewards, gold drops, and an AI personality. In Pokemon, every species has a catch rate, habitat, and evolution chain, data that makes no sense on a trainer's character sheet. By giving enemies their own Resource type, we can tailor the Inspector to show exactly what matters for enemy design.

Enemies need their own data. Create `res://resources/enemy_data.gd`:

```gdscript
extends Resource
class_name EnemyData
## Data definition for an enemy combatant.

enum AIType { AGGRESSIVE, CAUTIOUS, BALANCED }

@export var id: String = ""
@export var display_name: String = ""
@export var sprite: Texture2D
@export var ai_type: AIType = AIType.BALANCED

@export_group("Stats")
@export var max_hp: int = 30
@export var max_mp: int = 0
@export var attack: int = 8
@export var defense: int = 3
@export var speed: int = 5

@export_group("Rewards")
@export var xp_reward: int = 10
@export var gold_reward: int = 5
@export var drop_item: ItemData
@export_range(0.0, 1.0) var drop_chance: float = 0.25  # Shows a slider in the Inspector clamped to 0-1
```

> `@export_range(min, max)` constrains the Inspector widget to a slider within the given range. Useful for probabilities, percentages, and any value with natural bounds.

> Notice AIController (below) has `class_name` but no `extends` line. When omitted, GDScript scripts extend `RefCounted` by default. Since AIController only has static methods and is never instanced as a node, that's fine.

Create three enemies as `.tres` files in `res://data/enemies/`. Follow the same workflow from Module 9: right-click the folder in the FileSystem dock, choose **New Resource**, search for `EnemyData`, click **Create**, name the file, then fill in the exported fields in the Inspector.

**`cave_bat.tres`**, fast, weak, aggressive
- display_name: "Cave Bat", ai_type: AGGRESSIVE
- HP: 20, attack: 6, defense: 2, speed: 12
- XP: 8, gold: 3
- sprite: assign a small bat image or `res://icon.svg` as a placeholder

**`crystal_slime.tres`**, moderate, balanced
- display_name: "Crystal Slime", ai_type: BALANCED
- HP: 35, attack: 8, defense: 5, speed: 4
- XP: 12, gold: 6, drop: Potion (25%)
- sprite: assign a slime image or `res://icon.svg`

**`stone_golem.tres`**, tanky, cautious
- display_name: "Stone Golem", ai_type: CAUTIOUS
- HP: 60, attack: 12, defense: 10, speed: 2
- XP: 25, gold: 15, drop: Ether (20%)
- sprite: assign a golem image or `res://icon.svg`

## Enemy AI

Enemy AI is what makes each monster feel like a distinct creature rather than a bag of hit points. In Final Fantasy VI, the Behemoth counters every physical attack with a claw swipe, teaching players to use magic instead. Cactuars always flee, making them exciting to encounter. These behaviors come from simple AI rules, not complex neural networks, just "if HP is low, heal; otherwise, attack the weakest target." Three or four personality types are enough to make combat feel varied.

Each enemy needs to decide what to do on its turn. Create `res://systems/battle/ai_controller.gd` for the AI logic:

```gdscript
class_name AIController
## Enemy AI decision-making. Static methods, no instance needed.

static func choose_enemy_action(
    battler: BattlerData,
    enemy_data: EnemyData,
    party: Array[BattlerData],
    allies: Array[BattlerData],
) -> Dictionary:
    match enemy_data.ai_type:
        EnemyData.AIType.AGGRESSIVE:
            return _ai_aggressive(battler, party)
        EnemyData.AIType.CAUTIOUS:
            return _ai_cautious(battler, party)
        EnemyData.AIType.BALANCED:
            return _ai_balanced(battler, party)
        _:
            return _ai_balanced(battler, party)


static func _ai_aggressive(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    # Always attack the target with the lowest HP
    var weakest: BattlerData = targets[0]
    for t in targets:
        if t.current_hp < weakest.current_hp:
            weakest = t
    return {action = "attack", battler = battler, target = weakest}


static func _ai_cautious(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    # Defend when HP is below 30%, otherwise attack randomly
    var hp_ratio: float = float(battler.current_hp) / float(battler.character_data.max_hp)
    if hp_ratio < 0.3:
        return {action = "defend", battler = battler, target = battler}
    var target: BattlerData = targets[randi() % targets.size()]
    return {action = "attack", battler = battler, target = target}


static func _ai_balanced(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    # 70% attack, 30% defend
    var target: BattlerData = targets[randi() % targets.size()]
    if randf() < 0.3:
        return {action = "defend", battler = battler, target = battler}
    return {action = "attack", battler = battler, target = target}
```

## The Encounter System

### EncounterData Resource

Define which enemies appear together. Save as `res://resources/encounter_data.gd`:

```gdscript
extends Resource
class_name EncounterData
## Defines a possible random encounter: which enemies appear as a group.

@export var enemies: Array[EnemyData] = []
@export_range(0.0, 1.0) var weight: float = 1.0  # Relative probability
```

Create encounter groups as `.tres` files in `res://data/encounters/` (same workflow: right-click folder → New Resource → search `EncounterData` → Create):

**`cave_bats.tres`:** 3 Cave Bats (weight: 1.0, common)
**`slime_pair.tres`:** 2 Crystal Slimes (weight: 0.6, uncommon)
**`golem.tres`:** 1 Stone Golem (weight: 0.3, rare)

#### The Oddment Table Pattern

The weighted selection we're using here has a name: the **oddment table** (also called a weighted random table or loot table). It's one of the most reusable patterns in RPG development. The weights don't need to sum to 1.0 or 100; they're *relative*. Cave Bats at 1.0 are roughly 3x more likely than a Stone Golem at 0.3. The actual probabilities are:

| Encounter | Weight | Probability |
|-----------|--------|-------------|
| Cave Bats | 1.0 | 1.0 / 1.9 = 53% |
| Crystal Slimes | 0.6 | 0.6 / 1.9 = 32% |
| Stone Golem | 0.3 | 0.3 / 1.9 = 16% |

The power of this pattern: you can add or remove entries without recalculating the others. If you add a new "Crystal Spider" encounter at weight 0.4, all existing probabilities shift proportionally. No manual rebalancing needed. You'll see this same pattern used for item drops, shop stock, NPC dialogue variety, and AI decision-making in commercial RPGs.

### The Step Counter System

Random encounters trigger based on a step counter. Create `res://systems/encounter_system.gd` and attach it to the `EncounterSystem` node in `crystal_cavern.tscn`:

```gdscript
extends Node
## Tracks player movement and triggers random encounters in encounter zones.

signal encounter_triggered(encounter: EncounterData)

var _step_count: int = 0
var _threshold: int = 0
var _in_encounter_zone: bool = false
var _current_encounters: Array[EncounterData] = []
var _encounter_rate: float = 0.6  # 60% chance per threshold hit; tune this for your dungeon
var _last_player_position: Vector2 = Vector2.ZERO

const STEP_DISTANCE: float = 16.0  # One tile = one step


func _process(_delta: float) -> void:
    if not _in_encounter_zone:
        return

    var player := get_tree().get_first_node_in_group("player")
    if not player:
        return

    var distance: float = player.global_position.distance_to(_last_player_position)
    if distance >= STEP_DISTANCE:
        _last_player_position = player.global_position
        _step_count += 1
        _check_encounter()


func _check_encounter() -> void:
    if _step_count >= _threshold:
        _step_count = 0
        _threshold = randi_range(8, 20)  # Next threshold in 8-20 steps

        if randf() < _encounter_rate and not _current_encounters.is_empty():
            var encounter: EncounterData = _pick_weighted_encounter()
            if encounter:
                encounter_triggered.emit(encounter)


func _pick_weighted_encounter() -> EncounterData:
    if _current_encounters.is_empty():
        push_warning("EncounterSystem: no encounters configured.")
        return null

    var total_weight: float = 0.0
    for enc in _current_encounters:
        total_weight += max(0.0, enc.weight)

    if total_weight <= 0.0:
        push_warning("EncounterSystem: encounter weights must be greater than 0.")
        return null

    var roll: float = randf() * total_weight
    var cumulative: float = 0.0
    for enc in _current_encounters:
        cumulative += max(0.0, enc.weight)
        if roll <= cumulative:
            return enc

    return null


func enter_zone(encounters: Array[EncounterData], rate: float) -> void:
    _in_encounter_zone = true
    _current_encounters = encounters
    _encounter_rate = rate
    _threshold = randi_range(10, 25)
    _step_count = 0
    var player := get_tree().get_first_node_in_group("player")
    if player:
        _last_player_position = player.global_position


func exit_zone() -> void:
    _in_encounter_zone = false
    _current_encounters.clear()
```

> **See:** [Random number generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html), covering `randi_range()`, `randf()`, and weighted random selection.

### Tuning Encounter Rates

The encounter system has two knobs: the **step threshold** (how far you walk before a check) and the **encounter rate** (chance of a fight when the check fires). Getting these right is critical to how your game feels.

**Too frequent** (fight every 5 steps): the player feels trapped. Exploration becomes a chore. They'll dread every hallway.

**Too rare** (fight every 50 steps): the dungeon feels empty. The player reaches the boss under-leveled because they didn't fight enough.

**The sweet spot** for a JRPG dungeon is roughly one encounter every 15-25 steps. Our system achieves this through the combination of `randi_range(8, 20)` for the threshold and a 60% encounter rate. Here's the math:

- Average threshold: ~14 steps
- Average checks before a fight: 1 / 0.6 = ~1.7 checks
- Expected steps between encounters: 14 * 1.7 = ~24 steps

For different zones, vary the rate rather than the threshold:
- **Safe corridors near save points:** 10% rate (rare encounters, the player can breathe)
- **Main dungeon rooms:** 40-60% rate (steady pressure)
- **Deep/dangerous areas:** 80% rate (tense, limited exploration time)

One more trick real JRPGs use: no encounters within a few steps of entering a zone. Our threshold starts at `randi_range(10, 25)` on `enter_zone()`, which naturally gives the player a grace period when entering a new area.

### Wiring Encounter Zones

Create a new script for the encounter zones we placed in Module 16. Save as `res://systems/encounter_zone.gd`, then attach it to each encounter zone Area2D node (MainCorridor, DeepCavern):

```gdscript
extends Area2D
## Marks a region where random encounters can happen.

@export var encounters: Array[EncounterData] = []
@export var encounter_rate: float = 0.1

# ../../EncounterSystem means: go up two levels in the scene tree (from
# MainCorridor → EncounterZones → CrystalCavern), then down to EncounterSystem.
# We've used $ for child access before; ../ navigates to the parent.
@onready var _encounter_system: Node = $"../../EncounterSystem"


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and _encounter_system:
        _encounter_system.enter_zone(encounters, encounter_rate)


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player") and _encounter_system:
        _encounter_system.exit_zone()
```

### Adding enemy_data to BattlerData

Before wiring encounters to battles, we need a way for the victory flow (Module 18) to access enemy rewards. Open `res://resources/battler_data.gd` and add this property:

```gdscript
# Add to battler_data.gd, stores the EnemyData for reward calculation
var enemy_data: EnemyData = null
```

### Connecting Encounters to Battles

The EncounterSystem emits `encounter_triggered`, but nothing starts a battle yet. Create the Crystal Cavern scene script. Save as `res://scenes/crystal_cavern/crystal_cavern.gd` and attach to the CrystalCavern root node:

```gdscript
extends Node2D
## Crystal Cavern dungeon scene.

@onready var _encounter_system: Node = $EncounterSystem


func _ready() -> void:
    _encounter_system.encounter_triggered.connect(_on_encounter_triggered)


func _on_encounter_triggered(encounter: EncounterData) -> void:
    # Convert EnemyData to BattlerData for the battle system
    var enemy_battlers: Array[BattlerData] = []
    for ed in encounter.enemies:
        enemy_battlers.append(_enemy_to_battler(ed))

    # Build party (temporary, Module 21 adds a proper PartyManager)
    var hero := BattlerData.new()
    hero.character_data = load("res://data/characters/aiden.tres")
    hero.is_player_controlled = true

    # Must use Dictionary format, matches SceneManager.start_battle() from Module 14
    SceneManager.start_battle({party = [hero], enemies = enemy_battlers})


func _enemy_to_battler(enemy_data: EnemyData) -> BattlerData:
    var battler := BattlerData.new()
    var char_data := CharacterData.new()
    char_data.display_name = enemy_data.display_name
    char_data.portrait = enemy_data.sprite if enemy_data.sprite else preload("res://icon.svg")
    char_data.max_hp = enemy_data.max_hp
    char_data.max_mp = enemy_data.max_mp
    char_data.attack = enemy_data.attack
    char_data.defense = enemy_data.defense
    char_data.speed = enemy_data.speed
    battler.character_data = char_data
    battler.is_player_controlled = false
    battler.enemy_data = enemy_data
    return battler
```

That `char_data.portrait = ed.sprite` line is the bridge between your enemy data and the battle presentation. `BattlerSprite` already knows how to read `character_data.portrait`, so once you fill in the `sprite` field on each `EnemyData` resource, those visuals now appear in battle automatically.

### Using AI in Battle

Now update the `_execute_enemy_turn` method in `res://systems/battle/states/action_execute_state.gd` to use the AI controller instead of random targeting:

```gdscript
func _execute_enemy_turn(battler: BattlerData) -> void:
    var targets := battle_manager.get_alive_party()
    if targets.is_empty():
        return

    # Use AI controller if enemy has EnemyData, otherwise random
    if battler.enemy_data:
        var command: Dictionary = AIController.choose_enemy_action(
            battler, battler.enemy_data, targets, battle_manager.get_alive_enemies(),
        )
        var target: BattlerData = command.get("target", targets[0])
        match command.get("action", "attack"):
            "attack":
                await _execute_attack(battler, target)
            "defend":
                _execute_defend(battler)
    else:
        var target: BattlerData = targets[randi() % targets.size()]
        await _execute_attack(battler, target)
```

## The Boss: Crystal Guardian

The Crystal Guardian is a stronger enemy with a pre-battle dialogue.

**`crystal_guardian.tres`** (EnemyData) in `res://data/enemies/`:
- display_name: "Crystal Guardian"
- ai_type: AGGRESSIVE
- HP: 200, attack: 15, defense: 8, speed: 6
- XP: 100, gold: 50

The boss room trigger starts dialogue, then transitions to battle. Save as `res://entities/interactable/boss_trigger.gd` and attach to an Area2D node in the boss room:

```gdscript
extends Area2D
## Triggers the boss fight with a pre-battle cutscene.

@export var boss_data: EnemyData
var _triggered: bool = false


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and not _triggered:
        _triggered = true
        _start_boss_sequence()


func _start_boss_sequence() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("set_disabled"):
        player.set_disabled(true)

    # Pre-boss dialogue
    var line := DialogueLine.new()
    line.speaker_name = "Crystal Guardian"
    line.text = "You dare disturb the crystals? Prepare yourself!"

    var dialogue_box = get_tree().current_scene.get_node_or_null("DialogueBox")
    if dialogue_box:
        dialogue_box.start_dialogue([line])
        await dialogue_box.dialogue_finished

    # Start the boss battle
    _start_boss_battle()


func _start_boss_battle() -> void:
    var hero := BattlerData.new()
    hero.character_data = load("res://data/characters/aiden.tres")
    hero.is_player_controlled = true

    var boss := _enemy_to_battler(boss_data)

    SceneManager.start_battle({
        party = [hero],
        enemies = [boss],
    })
```

## Flee Mechanic

The Flee command is a pressure valve. In Dragon Quest, when you're deep in a dungeon with 10 HP and no Potions, the ability to run from a random encounter is the difference between a tense retreat to the save point and a frustrating game over. Flee also makes Speed matter outside of turn order: a fast party escapes easily, while slow characters are trapped.

Add a "Flee" option. First, add the flee logic to `res://systems/battle/ai_controller.gd`:

```gdscript
static func attempt_flee(party: Array[BattlerData], enemies: Array[BattlerData]) -> bool:
    var party_speed: float = 0.0
    for b in party:
        party_speed += b.current_speed
    party_speed /= party.size()

    var enemy_speed: float = 0.0
    for b in enemies:
        enemy_speed += b.current_speed
    enemy_speed /= enemies.size()

    # Base 50% chance, modified by speed ratio
    var chance: float = 0.5 + (party_speed - enemy_speed) * 0.05
    chance = clampf(chance, 0.1, 0.9)  # Always 10-90% chance

    return randf() < chance
```

Then add a Flee button to `res://ui/battle/battle_menu.tscn` (add a 5th Button node named `FleeButton` in the ActionList) and wire it in `battle_menu.gd`:

```gdscript
@onready var _flee_btn: Button = $MarginContainer/ActionList/FleeButton

# Add in _ready():
_flee_btn.pressed.connect(func() -> void: action_chosen.emit("flee"))
```

Handle flee in the PlayerChoice state (`player_choice_state.gd`), inside the `_on_action_chosen` match block:

```gdscript
        "flee":
            var success := AIController.attempt_flee(
                battle_manager.get_alive_party(),
                battle_manager.get_alive_enemies(),
            )
            if success:
                print("Escaped!")
                SceneManager.return_from_battle()
            else:
                print("Couldn't escape!")
                # Wasted turn, go to next battler
                battle_manager.transition_to_state("CheckResult")
```

> **JRPG Pattern:** Most JRPGs don't let you flee from boss battles. Add a `can_flee: bool` to your EncounterData and disable the Flee button when it's false.

> **See:** [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html). EnemyData and EncounterData both extend Resource. The `@export_group` and `@export_range` annotations organize the Inspector.

> **See:** [Random number generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html), covering `randi_range()`, `randf()`, and weighted random selection used throughout the encounter and AI systems.

## Engineering Contract

- **Global state:** Encounter logic starts battles through SceneManager but encounter counters are scene-local.
- **Public surface:** `EncounterData`, `EnemyData`, enemy-to-battler conversion, encounter zones, and AI action selection.
- **Invariant:** Encounter pools must contain enemies and have positive total weight before a battle can be rolled.
- **Failure behavior:** Empty pools or non-positive weights return no encounter and log a warning instead of crashing.
- **Copy semantics:** EnemyData is static content; BattlerData is the mutable runtime copy used in combat.

## Engine Gotcha

Random encounter systems often fail at boundaries: empty arrays, zero weights, and missing Resources. Guard those cases before calling `randf_range()` or indexing into an encounter pool.

## What We've Learned

- **EnemyData** Resource defines enemy stats, AI type, rewards, and loot drops.
- **Three AI types** (aggressive, cautious, balanced) create varied combat encounters with simple weighted logic.
- **The step counter** triggers encounters after a semi-random number of movement steps, with tunable frequency per zone.
- **Oddment tables** (weighted random selection) are a reusable pattern for encounters, loot drops, AI decisions, and more. Weights are relative, so adding entries doesn't require rebalancing existing ones.
- **Encounter rate tuning** combines step thresholds with probability checks. Different zones should feel different (safe corridors vs. dangerous depths).
- **Boss fights** use pre-battle dialogue sequences and stronger enemy data.
- **Flee mechanic** uses speed-based probability with bounded randomness.

## What You Should See

When exploring the Crystal Cavern:
- Random battles trigger after walking a number of steps
- Different enemies appear (bats, slimes, golems)
- Each enemy behaves differently based on AI type
- Entering the boss room triggers dialogue, then a boss battle
- The Flee option sometimes works, sometimes doesn't

## Next Module

We can fight, but nothing happens after winning. In **Module 18: Victory, Rewards, and Leveling**, we'll add XP distribution, a leveling system, gold and item drops, the victory fanfare, and the game-over flow.


---

<!-- Source: 18_victory_and_leveling.md -->

# Module 18: Victory, Rewards, and Leveling

## What We Have So Far

Interactive combat with enemies, AI, random encounters, and a boss fight. But winning a battle does nothing: no rewards, no progression.

## What We're Building This Module

Post-battle rewards (XP, gold, item drops), a leveling system with stat growth curves, the victory fanfare screen, and the game-over/defeat flow.

## Preparing the Data Layer

Before building the victory and leveling flows, make sure `CharacterData` still has the runtime properties we introduced in Module 9. We are finally going to put them to work here.

### CharacterData Runtime State

If your `res://resources/character_data.gd` does not already include these plain variables, add them now:

```gdscript
# Add to character_data.gd, runtime state (below the @export vars)
var current_xp: int = 0
var current_hp: int = 0  # Tracks HP between battles
var current_mp: int = 0  # Tracks MP between battles
```

> **Why both CharacterData and BattlerData have HP/MP:** BattlerData holds HP/MP *during* a battle (it's temporary, created fresh each fight). CharacterData holds HP/MP *between* battles (persistent across scenes). At battle start, `BattlerData.initialize_from_character()` copies from CharacterData. At battle end, we sync back.

### The XP Curve

We need a formula for "how much XP to reach the next level." This is one of the most important tuning knobs in your RPG. The curve shape determines the pacing of the entire game.

#### Why Levels Matter (Beyond Numbers)

Levels serve four purposes in a JRPG:

1. **Reward feedback.** The number going up *is* the reward. It's Pavlovian: fight → XP → level up → dopamine. Fast early levels hook the player.
2. **Narrative pacing.** Level roughly tracks where the player is in the story. A level 5 party is in the early game; a level 30 party is near the end. Designers use this to gate content.
3. **Complexity drip-feed.** New abilities unlock at specific levels, introducing mechanics gradually instead of dumping everything on the player at once.
4. **Content gating.** An area with level 15 enemies is implicitly locked until the party reaches that range. No locked doors needed.

#### Real RPG XP Formulas

Different curves produce very different game feel. Here are formulas reverse-engineered from real games:

| Game | Formula | Feel |
|------|---------|------|
| D&D 3.5 | `500 * level^2 - 500 * level` | Very steep. High levels are rare achievements. |
| Pokemon (fast group) | `round(0.8 * level^3)` | Moderate curve. Grinding is possible but not required. |
| Disgaea | `round(0.04 * level^3 + 0.8 * level^2 + 2 * level)` | Shallow. Levels come fast because *everything* levels. |

The general formula is:

```
xp_for_level = base_xp * level ^ exponent
```

- `base_xp` controls the overall cost of leveling. Higher = slower progression.
- `exponent` controls how much harder each successive level gets. At 1.0, every level costs the same XP. At 2.0 (quadratic), costs increase rapidly. At 3.0 (cubic), later levels take dramatically longer.

#### Our Curve

A simple quadratic curve works well for Crystal Saga's scope. Add this static function to `res://resources/character_data.gd`:

```gdscript
# A static func belongs to the class itself, not an instance. Call it as
# CharacterData.xp_for_level(5) without needing a CharacterData object.
# Useful for utility calculations that don't depend on instance data.
static func xp_for_level(level: int) -> int:
    return level * level * 10
```

| Level | XP to Next Level | Total XP |
|-------|-----------------|----------|
| 1 → 2 | 10 | 10 |
| 2 → 3 | 40 | 50 |
| 3 → 4 | 90 | 140 |
| 4 → 5 | 160 | 300 |
| 5 → 6 | 250 | 550 |
| 10 → 11 | 1,000 | 3,850 |

This is `base_xp=10, exponent=2`. Early levels come fast (10 XP for level 2), later levels take real effort (1,000 XP for level 11). If playtesting reveals that leveling feels too slow or too fast, change the `10` multiplier first, then consider adjusting the exponent.

> **Tuning tip:** Print the XP table for your expected level range (1-15 for Crystal Saga) and compare it against enemy XP rewards. If a single battle gives enough XP to level up, your curve is too shallow. If the player needs 50+ fights to level, it's too steep. Aim for 4-8 fights per level in the mid-game.

### Stat Growth

When a character levels up, their stats increase based on **growth rates** defined in CharacterData.

> **Spiral:** These growth rate fields (`hp_growth`, `mp_growth`, `attack_growth`, `defense_growth`, `speed_growth`) were defined in Module 9's CharacterData class. Verify your `aiden.tres` has non-zero values for all growth fields (e.g., hp_growth: 12, attack_growth: 3). If they default to 0, Aiden won't gain stats on level-up.

#### The Importance of Variance

If every level-up gives exactly +3 Attack, the progression feels mechanical. Real JRPGs add randomness: sometimes you get +2, sometimes +4. This makes each level-up a micro-event. The player watches the numbers and thinks "nice, +4 Strength this time!"

Some RPGs use dice notation for this. A growth rate of "3d2" means "roll three 2-sided dice" (range 3-6, weighted toward the middle). Faster-growing stats use more dice with higher sides; slower stats use fewer dice. We'll keep it simpler with `randi_range`, but the principle is the same: **growth rate = base value + bounded randomness**.

Different characters should grow differently. A warrior gains more HP and Attack per level; a mage gains more MP and Magic. These growth rate differences, compounded over 15-20 levels, make characters feel distinct even if they start similar.

#### The Calculate-Before-Apply Pattern

Notice that `level_up()` returns a `gains` dictionary *and* applies the gains in the same call. This is a simplification. In a polished RPG, you'd split this into two steps:

1. **Calculate** the level-up (what stats *would* increase), returning a preview
2. **Apply** the level-up (actually modify the character), called after the UI finishes displaying

This separation lets you show an animated victory screen where stats tick up one by one, HP bars extend, and "Level Up!" flashes before the numbers are committed. For Crystal Saga, combining both steps is fine. But if you build a victory screen with animated stat bars later, refactor `level_up()` into `create_level_up() -> Dictionary` and `apply_level_up(gains: Dictionary)`.

#### Implementation

Add this method to `res://resources/character_data.gd`:

> **Note:** `level_up()` modifies the Resource's properties at runtime. These changes persist in memory (because Resources are shared by reference) but do NOT modify the `.tres` file on disk. This is the correct behavior; runtime progression should not overwrite base data.

```gdscript
func level_up() -> Dictionary:
    level += 1
    var gains: Dictionary = {
        hp = hp_growth + randi_range(0, 2),
        mp = mp_growth + randi_range(0, 1),
        attack = attack_growth + randi_range(0, 1),
        defense = defense_growth + randi_range(0, 1),
        speed = speed_growth,
    }
    var old_max_hp: int = max_hp
    var old_max_mp: int = max_mp
    max_hp += gains.hp
    max_mp += gains.mp
    current_hp = min(current_hp + (max_hp - old_max_hp), max_hp)
    current_mp = min(current_mp + (max_mp - old_max_mp), max_mp)
    attack += gains.attack
    defense += gains.defense
    speed += gains.speed
    return gains
```

The small random variance (`randi_range(0, 1)` or `(0, 2)`) makes each level-up feel slightly different. HP gets the widest variance because it's the largest number and small fluctuations are less noticeable.

Crystal Saga uses the **gain the delta** rule for HP and MP: if max HP increases by 10, current HP also increases by 10, without exceeding the new max. This feels better than "max increases but current HP stays the same" and is less generous than a full heal on every level-up.

### Centralizing XP Awards

Battles are awarding XP now, and quests will start awarding XP once PartyManager exists in Module 21. Rather than duplicate the level-up loop in multiple systems, give `CharacterData` one helper that owns the "gain XP, maybe level up several times" flow.

Add this below `level_up()` in `res://resources/character_data.gd`:

```gdscript
func grant_xp(xp: int) -> Array[Dictionary]:
    current_xp += xp

    var level_ups: Array[Dictionary] = []
    var required: int = CharacterData.xp_for_level(level)
    while current_xp >= required:
        current_xp -= required
        var gains: Dictionary = level_up()
        level_ups.append({
            level = level,
            gains = gains,
        })
        required = CharacterData.xp_for_level(level)

    return level_ups
```

This helper returns a small summary for each level-up so the caller can print messages or build UI around it without owning the math itself.

## The Victory Flow

Now that the data layer is ready, update the Victory battle state (`res://systems/battle/states/victory_state.gd`) to show rewards:

```gdscript
extends BattleState
## Battle won. Calculate and display rewards.


func enter(_context: Dictionary = {}) -> void:
    print("VICTORY")

    var total_xp: int = 0
    var total_gold: int = 0
    var dropped_items: Array[ItemData] = []

    # Calculate rewards from all enemies
    for enemy in battle_manager.enemies:
        if enemy.enemy_data:
            total_xp += enemy.enemy_data.xp_reward
            total_gold += enemy.enemy_data.gold_reward
            if enemy.enemy_data.drop_item and randf() < enemy.enemy_data.drop_chance:
                dropped_items.append(enemy.enemy_data.drop_item)

    # Distribute XP to party members
    var xp_per_member: int = total_xp / max(1, battle_manager.get_alive_party().size())
    for battler in battle_manager.get_alive_party():
        _apply_xp(battler, xp_per_member)

    # Sync battle HP/MP back to CharacterData for persistence
    for battler in battle_manager.party:
        if battler.character_data:
            battler.character_data.current_hp = battler.current_hp
            battler.character_data.current_mp = battler.current_mp

    # Grant gold
    InventoryManager.add_gold(total_gold)
    print("Gained " + str(total_gold) + " gold!")

    # Grant dropped items
    for item in dropped_items:
        InventoryManager.add_item(item)
        print("Found: " + item.display_name + "!")

    battle_manager.battle_won.emit()

    # Wait for player to acknowledge
    await get_tree().create_timer(2.0).timeout
    # Return to overworld
    SceneManager.return_from_battle()


func _apply_xp(battler: BattlerData, xp: int) -> void:
    if not battler.character_data:
        return

    var char_data: CharacterData = battler.character_data
    print(char_data.display_name + " gained " + str(xp) + " XP!")
    for result in char_data.grant_xp(xp):
        var gains: Dictionary = result.gains
        print(char_data.display_name + " reached level " + str(result.level) + "!")
        print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
              ", DEF +" + str(gains.defense))
```

Item drops turn every battle into a small gamble. In Pokemon, rare wild encounters might hold rare items; in Final Fantasy, stealing from bosses yields unique equipment. The probability doesn't need to be high; even a 10% chance of a rare drop creates a "did I get it?" moment after every fight. Drops should complement shop inventory, not replace it: shops sell reliable basics, drops reward persistence with something special.

## The Defeat Flow

When the party is wiped:

```gdscript
extends BattleState
## Party wiped. Show game over screen.


func enter(_context: Dictionary = {}) -> void:
    print("DEFEAT")
    print("The party has fallen...")
    battle_manager.battle_lost.emit()

    await get_tree().create_timer(2.0).timeout

    # Return to title screen (or last save point)
    # For now, just reload the main scene
    SceneManager.change_scene("res://scenes/willowbrook/willowbrook.tscn", "default")
```

Module 25 replaces this with a proper Game Over screen with options (load save, return to title).

## Post-Battle State Restoration

HP carry-over is the hidden engine of dungeon tension. In every classic Final Fantasy, the real challenge isn't any single battle. It's surviving the entire dungeon with limited healing. Each random encounter chips away at your HP and MP, and the question becomes: "Do I use my last Ether now, or save it for the boss?" This resource attrition is what makes save crystals feel like oases and inns feel like home.

After a victorious battle, the party returns to the overworld with their current HP/MP intact. Two things make this work:

1. **HP/MP sync**: the Victory state writes `battler.current_hp` and `battler.current_mp` back to `battler.character_data` (see the sync code above). Without this, the party would return to full HP after every fight.
2. **Resource sharing**: CharacterData resources are shared by reference. When the battle modifies stats via `level_up()`, that change persists across scenes automatically.

For now, since we don't have a formal PartyManager yet (Module 21), the CharacterData resource at `res://data/characters/aiden.tres` is loaded via `load()`, which caches it. All code that loads the same path gets the same object during the current run, which is what lets battle results persist across scenes. In Module 22 and Module 25, we'll start loading **fresh runtime copies** for save/load and New Game so a brand-new run always starts from pristine base data on disk.

> **JRPG Pattern:** After normal battles, HP/MP carry over (no free heals). Save points and inns restore them. This creates a resource management game: do you use that Potion now or save it for the boss?

> **See:** [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html). Resources loaded with `load()` are cached and shared by reference. Runtime changes to exported properties persist in memory but don't write back to the `.tres` file.

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html). For future enhancements, Tweens can animate the victory screen (stat bars filling, XP counters incrementing).

## Engineering Contract

- **Global state:** Victory writes rewards into PartyManager and InventoryManager through their public APIs.
- **Public surface:** XP gain, level-up, reward calculation, loot rolls, and post-battle HP/MP sync.
- **Invariant:** Level-up max HP/MP gains also increase current HP/MP by the same delta, capped at the new max.
- **Failure behavior:** Dead party members do not receive XP in the base tutorial flow.
- **Copy semantics:** Battle HP/MP lives on BattlerData until victory syncs it back to CharacterData.

## Engine Gotcha

Resource mutation is now intentional: party CharacterData is runtime state. New Game and load flows must avoid reusing mutated cached Resources when they need pristine base data.

## What We've Learned

- **XP distribution** divides total XP among alive party members.
- **Levels serve four purposes:** reward feedback, narrative pacing, complexity drip-feed, and content gating. They're not just a number.
- **XP curve shape** (`base_xp * level ^ exponent`) determines game pacing. A quadratic curve (exponent 2) starts fast and ramps up. Compare your curve against enemy XP rewards to check pacing.
- **Stat growth** per level uses base growth rates plus bounded randomness. Variance makes each level-up feel like a micro-event. Different characters should grow differently to feel distinct.
- **Calculate before apply:** for a polished victory screen, separate `create_level_up()` (returns preview data) from `apply_level_up()` (commits changes). This enables animated stat displays.
- **Loot drops** use probability (`randf() < drop_chance`) on each defeated enemy.
- **Victory flow:** calculate rewards → distribute XP → check level ups → grant gold/items → return to overworld.
- **Defeat flow:** display game over → return to title or last save.
- Character progression is centralized through `CharacterData.grant_xp()`, so battles and later quest rewards can use the same level-up path.
- Runtime CharacterData changes persist during the current play session because systems share the same active character resources.

## What You Should See

After winning a battle:
- "VICTORY" appears in the output panel
- XP, gold, and item drops are listed (e.g., "Aiden gained 12 XP!", "Gained 6 gold!")
- Characters may level up: "Aiden reached level 2!" with stat increases
- After 2 seconds, the game returns to the overworld at the player's previous position
- HP/MP carry over from the battle (if you took damage, your HP stays reduced)

After losing a battle:
- "DEFEAT" appears in the output panel
- The game reloads Willowbrook (placeholder for proper Game Over screen in Module 25)

**Concrete example:** If Aiden (level 1, 0 XP) defeats 2 Crystal Slimes (12 XP each), he gains 24 XP total. Since level 1→2 requires only 10 XP, he levels up to level 2 with 14 XP remaining.

## Next Module

Next up, **Module 19** reviews everything from Part IV with cheat sheets and common mistakes. Then in **Module 20: The Quest System and Game Flags**, we'll add a game-wide flag system for tracking world state, quest data with objectives, a quest log UI, and make NPCs react differently based on what the player has accomplished.


---

<!-- Source: 19_part_iv_review.md -->

# Module 19: Part IV Review and Cheat Sheet

Part IV built the combat core of Crystal Saga. This module is your reference for everything covered in Modules 14 through 18: the battle system architecture, player actions, dungeon design, enemy AI, and the victory/leveling loop.

## Part IV in Review

Before Part IV, Crystal Saga had a connected world with no conflict. After it, we had a fully playable combat loop. We started in Module 14 by confronting the limits of the enum-based state machine from Module 6 and replacing it with a node-based architecture that could handle the complexity of a battle system with seven distinct states. That architecture (one Node per state, each with `enter()`, `process()`, and `exit()`) is what the rest of the battle system sits on.

With the state machine running, Module 15 filled in the player's side: a battle menu, target selection, the damage formula, and Tween-based animations. The battle went from auto-playing print statements to interactive combat with floating damage numbers. Module 16 then gave us somewhere to fight by building the Crystal Cavern, introducing dungeon design principles, treasure chests, save crystals, and encounter zones. The dungeon was a natural application of TileMapLayer skills from Part II, but with cave tiles and a tighter, more controlled layout.

Module 17 populated the dungeon with enemies. EnemyData resources defined stats and rewards, three AI strategies gave each creature personality, and the encounter system tied walking to random battles using a step counter with weighted encounter pools. The Crystal Guardian boss capped the dungeon with a scripted fight. Finally, Module 18 closed the loop: XP distribution, a quadratic leveling curve, stat growth, gold and item drops, and the flows for both victory and defeat. After Module 18, winning a battle means something. Characters get stronger, and the party returns to the overworld with their battle scars intact.

### Module 14: Battle Foundations

- Upgraded from the enum-based state machine (Module 6) to a **node-based state machine** where each state is a Node child with `enter()`, `process()`, and `exit()` methods.
- Created **BattlerData**, a Resource that combines CharacterData stats with runtime battle state (current HP/MP, temporary defense boosts).
- Built the **battle scene** with Marker2D slots for party (right side) and enemies (left side), battler sprites, and a StateMachine node with seven child states.
- Implemented **speed-based turn ordering** using `Array.sort_custom()` to build a turn queue each round.
- Added `start_battle()` and `return_from_battle()` to SceneManager, storing the previous scene path and player position for seamless transitions.

### Module 15: Player Actions

- Built the **battle menu** (Attack/Magic/Defend/Item) as a PanelContainer with VBoxContainer and Buttons. Attack, Defend, and Item emit `action_chosen`; Magic stays disabled for future ability work.
- Implemented the **command pattern** using dictionaries (`{action, battler, target, item}`) to keep action execution generic.
- Created **target selection** UI that dynamically spawns buttons for each alive enemy, with cancel support to return to the menu.
- Defined the **damage formula**: `max(1, attack - effective_defense + randi_range(-2, 2))`, which is simple, transparent, and always deals at least 1 damage.
- Added **Tween animations** for attacks (slide forward, pause, slide back) and **floating damage numbers** (parallel tweens for rising position and fading opacity).

### Module 16: The Crystal Cavern

- Designed a **dungeon layout** with connected rooms, corridors, a fork (dead end with treasure vs. path to boss), and a save crystal room before the boss.
- Built reusable **treasure chest** and **save crystal** interactable scenes using StaticBody2D with Area2D interaction zones, following the same body_entered/exited pattern from Module 10's NPCs.
- Created a **boss door** that checks for a key item before opening, introducing simple puzzle design.
- Placed **encounter zone** Area2D nodes to mark where random battles will trigger (wired in Module 17).
- Applied the same multi-layer TileMapLayer structure from Module 5 (Ground, Detail, Objects in YSortGroup, AbovePlayer) but with cave-themed tiles.

### Module 17: Enemies and AI

- Created **EnemyData** Resource with stats, an AI type enum (AGGRESSIVE, CAUTIOUS, BALANCED), a battle sprite, reward values (XP, gold), and a loot drop with probability.
- Built three **AI strategies** in a static AIController class: aggressive (targets lowest HP), cautious (defends below 30% HP), and balanced (70% attack, 30% defend).
- Implemented the **encounter system** with a step counter that tracks player movement distance, a randomized step threshold, and weighted encounter selection.
- Wired **encounter zones** to the encounter system using Area2D body_entered/exited signals, passing different encounter pools and rates per zone.
- Added a **flee mechanic** with speed-based probability (base 50%, modified by average party speed vs. enemy speed, clamped to 10-90%).

### Module 18: Victory, Rewards, and Leveling

- Implemented **XP distribution** that divides total enemy XP equally among alive party members.
- Defined the **XP curve** as `level * level * 10`, a quadratic formula where early levels come fast and later levels require progressively more XP.
- Added **stat growth** on level-up using base growth rates plus small random variance (`randi_range(0, 1)` or `(0, 2)`), making each level-up feel slightly different.
- Built the **victory flow**: calculate rewards from all enemies, distribute XP (with multi-level-up support), sync battle HP/MP back to CharacterData, grant gold and rolled item drops, then return to the overworld.
- Built the **defeat flow**: display game over message and return to Willowbrook (placeholder for proper Game Over screen in Module 25).

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|---------------|------------|
| Node-based state machine | Each state is a Node child with `enter()`/`process()`/`exit()`, managed by a state machine parent | Scales to complex state flows without monolithic `match` blocks | Module 14 |
| BattlerData | Runtime Resource wrapping CharacterData with battle-specific state (current HP, defense boost) | Separates persistent character data from temporary battle state | Module 14 |
| Turn queue | Array of alive BattlerData sorted by speed, processed front-to-back each round | Determines action order; speed stat becomes strategically meaningful | Module 14 |
| Command pattern | Dictionary `{action, battler, target, item}` representing a battle action | Decouples action selection (menu) from action execution (state) | Module 15 |
| Damage formula | `max(1, attack - effective_defense + variance)` | Predictable, transparent combat math players can reason about | Module 15 |
| Tween animation | Procedural animation using `tween_property()`, `tween_interval()`, and `set_parallel()` | Makes combat feel impactful without sprite animation frames | Module 15 |
| Dungeon design | Room-based layout with corridors, forks, dead ends, and a boss room | Controlled pacing: tension in corridors, relief in open rooms | Module 16 |
| Encounter zones | Area2D regions that activate the encounter system with specific enemy pools | Different areas of a dungeon can have different enemy types and rates | Module 17 |
| EnemyData | Resource defining enemy stats, battle sprite, AI type, rewards, and loot drops | Single source of truth for each enemy species, reusable across encounters and battle presentation | Module 17 |
| Weighted random selection | Cumulative weight algorithm for picking from a pool of options | Common encounters happen often; rare encounters feel special | Module 17 |
| Step counter | Tracks player movement distance against a randomized threshold | Random encounters triggered by exploration, not timers | Module 17 |
| XP curve | `level * level * 10`: quadratic growth formula | Early levels reward quickly; later levels extend gameplay | Module 18 |
| Post-battle sync | Writing battle HP/MP back to CharacterData after victory | HP/MP carry over between battles, creating resource management tension | Module 18 |

## Cheat Sheet

### Node-Based State Machine

The BattleState base class defines the interface every state must implement. Each state is a child Node of the BattleStateMachine, which auto-registers them by name.

```gdscript
# battle_state.gd: base class for all battle states
extends Node
class_name BattleState

var battle_manager: Node  # Set by BattleManager during _ready()

func enter(_context: Dictionary = {}) -> void:
    pass

func process(_delta: float) -> void:
    pass

func exit() -> void:
    pass
```

The machine manages transitions, calling `exit()` on the current state and `enter()` on the new one:

```gdscript
# battle_state_machine.gd
extends Node
class_name BattleStateMachine

signal state_changed(old_state: String, new_state: String)

var current_state: BattleState
var states: Dictionary = {}


func _ready() -> void:
    for child in get_children():
        if child is BattleState:
            states[child.name] = child


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

States transition by calling the BattleManager facade: `battle_manager.transition_to_state("StateName", context)`. The context dictionary passes data between states (active battler, chosen target, action type), while the root battle script keeps ownership of the private state machine node.

### Turn Order System

Each round, all alive combatants are sorted by speed (highest first) into a queue. The queue is processed one battler at a time until empty, then a new round begins.

```gdscript
# In BattleManager
func build_turn_queue() -> void:
    turn_queue.clear()
    var all_battlers: Array[BattlerData] = []
    for b in party:
        if b.is_alive():
            all_battlers.append(b)
    for b in enemies:
        if b.is_alive():
            all_battlers.append(b)
    all_battlers.sort_custom(func(a: BattlerData, b: BattlerData) -> bool:
        return a.current_speed > b.current_speed
    )
    turn_queue = all_battlers


func get_next_battler() -> BattlerData:
    if turn_queue.is_empty():
        return null
    return turn_queue.pop_front()
```

BattlerData wraps CharacterData with runtime state. It initializes from the character's base stats at battle start:

```gdscript
# battler_data.gd
extends Resource
class_name BattlerData

@export var character_data: CharacterData
@export var is_player_controlled: bool = true

var current_hp: int = 0
var current_mp: int = 0
var current_attack: int = 0
var current_defense: int = 0
var current_speed: int = 0
var defense_boost: int = 0
var enemy_data: EnemyData = null  # For reward calculation


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
```

### Battle Scene Architecture

The full scene tree wires the state machine, battler positions, and UI together:

```
Battle (Node2D, script: battle_manager.gd)
├── Background (ColorRect)
├── PartyPositions (Node2D)
│   ├── PartySlot0 (Marker2D, pos: 240, 60)
│   ├── PartySlot1 (Marker2D, pos: 240, 120)
│   └── PartySlot2 (Marker2D, pos: 240, 180)
├── EnemyPositions (Node2D)
│   ├── EnemySlot0 (Marker2D, pos: 80, 60)
│   ├── EnemySlot1 (Marker2D, pos: 80, 120)
│   └── EnemySlot2 (Marker2D, pos: 80, 180)
├── BattleUI (CanvasLayer, layer = 10)
│   ├── BattleMenu (instance of battle_menu.tscn)
│   └── TargetSelect (instance of target_select.tscn)
└── StateMachine (BattleStateMachine)
    ├── Intro (BattleState)
    ├── TurnStart (BattleState)
    ├── PlayerChoice (BattleState)
    ├── ActionExecute (BattleState)
    ├── CheckResult (BattleState)
    ├── Victory (BattleState)
    └── Defeat (BattleState)
```

BattleManager is the root script (NOT an autoload). It only exists while a battle is running. In `_ready()`, it passes `self` to every state as `battle_manager`, then waits for `initialize_battle()` to be called with party and enemy data.

The complete state flow:

```
Intro -> TurnStart
TurnStart -> PlayerChoice for player battlers
TurnStart -> ActionExecute for enemy battlers
PlayerChoice -> ActionExecute after the player chooses a command
ActionExecute -> CheckResult
CheckResult -> Victory if all enemies are defeated
CheckResult -> Defeat if all party members are defeated
CheckResult -> TurnStart for the next battler or next round
```

### The Command Pattern

Actions are represented as dictionaries. The PlayerChoice state builds the command; ActionExecute reads and runs it.

```gdscript
# Built in PlayerChoice when the player picks Attack and selects a target:
var command: Dictionary = {
    action = "attack",
    battler = active_battler,
    target = selected_enemy,
    item = null,
}

# Built when the player picks Defend (no target needed):
var command: Dictionary = {
    action = "defend",
    battler = active_battler,
}

# Built when an enemy acts (AI decides action and target):
var command: Dictionary = {
    action = "attack",
    battler = enemy_battler,
    target = chosen_party_member,
}
```

ActionExecute uses `match` on the action string to dispatch:

```gdscript
match action:
    "attack":
        await _execute_attack(battler, target)
    "defend":
        _execute_defend(battler)
    "item":
        _execute_item(battler, target, item)
    "enemy_turn":
        await _execute_enemy_turn(battler)
```

### Battle Menu UI

The menu emits an `action_chosen` signal. The PlayerChoice state connects to it on `enter()` and disconnects on `exit()` to avoid duplicate connections.

```gdscript
# battle_menu.gd
extends PanelContainer

signal action_chosen(action: String)

@onready var _attack_btn: Button = $MarginContainer/ActionList/AttackButton
@onready var _magic_btn: Button = $MarginContainer/ActionList/MagicButton
@onready var _defend_btn: Button = $MarginContainer/ActionList/DefendButton
@onready var _item_btn: Button = $MarginContainer/ActionList/ItemButton


func _ready() -> void:
    _attack_btn.pressed.connect(func() -> void: action_chosen.emit("attack"))
    _magic_btn.disabled = true
    _magic_btn.tooltip_text = "Magic is a future extension."
    _defend_btn.pressed.connect(func() -> void: action_chosen.emit("defend"))
    _item_btn.pressed.connect(func() -> void: action_chosen.emit("item"))


func show_menu() -> void:
    visible = true
    _attack_btn.grab_focus()


func hide_menu() -> void:
    visible = false
```

`grab_focus()` on the Attack button ensures keyboard/gamepad navigation works immediately when the menu appears. The VBoxContainer handles vertical navigation between buttons automatically.

### Damage Formula

Simple, transparent, and always deals at least 1 damage:

```gdscript
static func calculate_damage(attacker: BattlerData, target: BattlerData) -> int:
    var raw: int = attacker.current_attack - target.get_effective_defense()
    var variance: int = randi_range(-2, 2)
    return max(1, raw + variance)
```

The Defend action doubles defense for one turn by setting `defense_boost` equal to `current_defense`. The boost is reset to 0 at the start of the defender's next turn.

```gdscript
# Defend: double effective defense until next turn
func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense

# Reset at the start of each battler's turn (in turn processing):
battler.defense_boost = 0
```

### Tween Animations

Attack slide: the attacker moves toward the enemy, pauses, then returns. Sequential by default, each `tween_property()` call queues after the previous one finishes.

```gdscript
func _play_attack_animation(attacker: BattlerData) -> void:
    var sprite := _find_battler_sprite(attacker)
    if not sprite:
        return
    var direction := -1.0 if attacker.is_player_controlled else 1.0
    var original_pos: Vector2 = sprite.position

    var tween := create_tween()
    tween.tween_property(sprite, "position:x", original_pos.x + 30.0 * direction, 0.15)
    tween.tween_interval(0.1)
    tween.tween_property(sprite, "position:x", original_pos.x, 0.15)
    await tween.finished
```

Floating damage numbers: position and opacity animate simultaneously using `set_parallel(true)`, then `chain()` returns to sequential mode for cleanup.

```gdscript
func _spawn_damage_number(target: BattlerData, amount: int, is_heal: bool = false) -> void:
    var sprite_node := _find_battler_sprite(target)
    if not sprite_node:
        return

    var label := Label.new()
    label.text = str(amount)
    label.add_theme_color_override("font_color", Color.GREEN if is_heal else Color.WHITE)
    label.z_index = 100
    sprite_node.add_child(label)
    label.position = Vector2(0, -20)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", -50.0, 0.8)
    tween.tween_property(label, "modulate:a", 0.0, 0.8)
    tween.chain().tween_callback(label.queue_free)
```

Key Tween methods:
- `tween_property(node, property_path, final_value, duration)`: animates a property over time
- `tween_interval(duration)`: inserts a pause between tweens
- `set_parallel(true)`: subsequent tweens run simultaneously
- `chain()`: returns to sequential mode after parallel tweens
- `await tween.finished`: pauses the calling function until the tween completes

### Dungeon Design

Dungeons use the same multi-layer TileMapLayer structure as overworld scenes, but with different design principles:

```
CrystalCavern (Node2D)
├── Ground (TileMapLayer)         : stone floors
├── Detail (TileMapLayer)         : cracks, rubble, small crystals
├── YSortGroup (Node2D, y_sort_enabled)
│   ├── Objects (TileMapLayer)    : stalagmites, large formations
│   ├── Player (instance)
│   ├── TreasureChests
│   └── SaveCrystal
├── AbovePlayer (TileMapLayer)    : ceiling overhangs
├── Exits (Node2D)                : exit zones and spawn points
├── EncounterZones (Node2D)       : Area2D regions for random battles
└── EncounterSystem (Node)        : step counter logic
```

Design rules:
- **Fill with walls first, then carve rooms and corridors** (opposite of overworld, where you fill with grass and add obstacles)
- **Alternate tight corridors and open rooms** for pacing
- **Place visual landmarks at decision points** so the player can orient
- **Forks with rewards**: dead ends should contain treasure to reward exploration
- **Save crystal before the boss**: the classic JRPG courtesy

Treasure chests, save crystals, and boss doors all follow the same interactable pattern: StaticBody2D (blocks movement) with an Area2D child (detects the player), connected via `body_entered`/`body_exited` signals:

```gdscript
# Shared pattern across all interactables
@onready var _zone: Area2D = $InteractionZone
var _player_in_range: bool = false

func _ready() -> void:
    _zone.body_entered.connect(_on_body_entered)
    _zone.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
    if _player_in_range and event.is_action_pressed("interact"):
        _activate()
        get_viewport().set_input_as_handled()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
```

### Enemy AI Patterns

Three AI strategies are implemented as static methods in AIController. Each returns a command dictionary.

```gdscript
# ai_controller.gd
class_name AIController

static func choose_enemy_action(
    battler: BattlerData,
    enemy_data: EnemyData,
    party: Array[BattlerData],
    allies: Array[BattlerData],
) -> Dictionary:
    match enemy_data.ai_type:
        EnemyData.AIType.AGGRESSIVE:
            return _ai_aggressive(battler, party)
        EnemyData.AIType.CAUTIOUS:
            return _ai_cautious(battler, party)
        EnemyData.AIType.BALANCED:
            return _ai_balanced(battler, party)
        _:
            return _ai_balanced(battler, party)
```

**Aggressive:** always targets the weakest (lowest HP) party member:

```gdscript
static func _ai_aggressive(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    var weakest: BattlerData = targets[0]
    for t in targets:
        if t.current_hp < weakest.current_hp:
            weakest = t
    return {action = "attack", battler = battler, target = weakest}
```

**Cautious:** defends when HP drops below 30%, otherwise attacks randomly:

```gdscript
static func _ai_cautious(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    var hp_ratio: float = float(battler.current_hp) / float(battler.character_data.max_hp)
    if hp_ratio < 0.3:
        return {action = "defend", battler = battler, target = battler}
    var target: BattlerData = targets[randi() % targets.size()]
    return {action = "attack", battler = battler, target = target}
```

**Balanced:** 70% attack, 30% defend:

```gdscript
static func _ai_balanced(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    var target: BattlerData = targets[randi() % targets.size()]
    if randf() < 0.3:
        return {action = "defend", battler = battler, target = battler}
    return {action = "attack", battler = battler, target = target}
```

### EnemyData and Encounter Groups

EnemyData is a Resource that defines everything about an enemy species:

```gdscript
# enemy_data.gd
extends Resource
class_name EnemyData

enum AIType { AGGRESSIVE, CAUTIOUS, BALANCED }

@export var id: String = ""
@export var display_name: String = ""
@export var sprite: Texture2D
@export var ai_type: AIType = AIType.BALANCED

@export_group("Stats")
@export var max_hp: int = 30
@export var attack: int = 8
@export var defense: int = 3
@export var speed: int = 5

@export_group("Rewards")
@export var xp_reward: int = 10
@export var gold_reward: int = 5
@export var drop_item: ItemData
@export_range(0.0, 1.0) var drop_chance: float = 0.25
```

EncounterData groups enemies together with a weight for probability:

```gdscript
# encounter_data.gd
extends Resource
class_name EncounterData

@export var enemies: Array[EnemyData] = []
@export_range(0.0, 1.0) var weight: float = 1.0
```

Encounter zones are Area2D nodes that tell the encounter system which pool to use:

```gdscript
# encounter_zone.gd
extends Area2D

@export var encounters: Array[EncounterData] = []
@export var encounter_rate: float = 0.1

@onready var _encounter_system: Node = $"../../EncounterSystem"

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and _encounter_system:
        _encounter_system.enter_zone(encounters, encounter_rate)

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player") and _encounter_system:
        _encounter_system.exit_zone()
```

Weighted selection picks an encounter from the pool (higher weight means more common):

```gdscript
func _pick_weighted_encounter() -> EncounterData:
    var total_weight: float = 0.0
    for enc in _current_encounters:
        total_weight += enc.weight
    var roll: float = randf() * total_weight
    var cumulative: float = 0.0
    for enc in _current_encounters:
        cumulative += enc.weight
        if roll <= cumulative:
            return enc
    return _current_encounters[0]
```

### Experience and Leveling

The XP curve uses a simple quadratic formula. The `while` loop handles cases where a single battle awards enough XP for multiple level-ups.

```gdscript
# In character_data.gd
static func xp_for_level(level: int) -> int:
    return level * level * 10

func level_up() -> Dictionary:
    level += 1
    var gains: Dictionary = {
        hp = hp_growth + randi_range(0, 2),
        mp = mp_growth + randi_range(0, 1),
        attack = attack_growth + randi_range(0, 1),
        defense = defense_growth + randi_range(0, 1),
        speed = speed_growth,
    }
    max_hp += gains.hp
    max_mp += gains.mp
    attack += gains.attack
    defense += gains.defense
    speed += gains.speed
    return gains

func grant_xp(xp: int) -> Array[Dictionary]:
    current_xp += xp

    var level_ups: Array[Dictionary] = []
    var required: int = CharacterData.xp_for_level(level)
    while current_xp >= required:
        current_xp -= required
        var gains: Dictionary = level_up()
        level_ups.append({
            level = level,
            gains = gains,
        })
        required = CharacterData.xp_for_level(level)

    return level_ups
```

XP distribution in the victory state:

```gdscript
func _apply_xp(battler: BattlerData, xp: int) -> void:
    var char_data: CharacterData = battler.character_data
    for result in char_data.grant_xp(xp):
        print(char_data.display_name + " reached level " + str(result.level) + "!")
```

The XP curve at a glance:

| Level | XP Required | Total XP to Reach |
|-------|------------|-------------------|
| 1 to 2 | 10 | 10 |
| 2 to 3 | 40 | 50 |
| 3 to 4 | 90 | 140 |
| 4 to 5 | 160 | 300 |
| 5 to 6 | 250 | 550 |

### Battle-to-Overworld Transitions

SceneManager stores the previous scene and player position before entering battle. After victory, it restores both.

```gdscript
# In scene_manager.gd
var _previous_scene_path: String = ""
var _previous_player_position: Vector2 = Vector2.ZERO


func start_battle(encounter_data: Dictionary) -> void:
    if _is_transitioning:
        return
    _is_transitioning = true

    var player := get_tree().get_first_node_in_group("player")
    if player:
        _previous_player_position = player.global_position
    _previous_scene_path = get_tree().current_scene.scene_file_path

    transition_started.emit()
    _anim_player.play("fade_out")
    await _anim_player.animation_finished

    get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
    await get_tree().scene_changed

    var battle_scene := get_tree().current_scene
    if battle_scene.has_method("initialize_battle"):
        battle_scene.initialize_battle(
            encounter_data.get("party", []),
            encounter_data.get("enemies", []),
        )

    _anim_player.play("fade_in")
    await _anim_player.animation_finished
    _is_transitioning = false


func return_from_battle() -> void:
    if _previous_scene_path.is_empty():
        return
    change_scene(_previous_scene_path, "default")
    await transition_finished
    var player := get_tree().get_first_node_in_group("player")
    if player:
        player.global_position = _previous_player_position
```

After victory, HP/MP are synced from BattlerData back to CharacterData so damage carries over between fights:

```gdscript
# In victory_state.gd
for battler in battle_manager.party:
    if battler.character_data:
        battler.character_data.current_hp = battler.current_hp
        battler.character_data.current_mp = battler.current_mp
```

Resources loaded with `load()` are cached and shared by reference. When the victory state modifies `aiden.tres`'s CharacterData in memory, those changes persist across scenes without any manual save step.

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Accessing `battle_manager` in a state's `_ready()` | Null reference error at battle start | `battle_manager` is set by the parent's `_ready()`, which runs after children. Use `enter()` instead of `_ready()` for initialization that needs the manager. |
| Not disconnecting signals in PlayerChoice `exit()` | Duplicate signal connections cause actions to fire multiple times | Always disconnect `action_chosen`, `target_selected`, and `cancelled` in `exit()`. Check `is_connected()` first to be safe. |
| Forgetting `get_viewport().set_input_as_handled()` after processing input | Input bleeds through to other nodes (e.g., opening inventory during battle) | Call `set_input_as_handled()` after handling `interact`, `ui_cancel`, or any action in `_unhandled_input()`. |
| Setting `defense_boost` but never resetting it | Defend stacks permanently, making the character invincible | Reset `battler.defense_boost = 0` at the start of each battler's turn, before they act. |
| Not syncing HP/MP back to CharacterData after battle | Party returns to full HP after every fight, removing resource management | In the victory state, copy `battler.current_hp` and `battler.current_mp` back to `battler.character_data`. |
| Treasure chest opens again after re-entering the scene | Chest gives infinite items | The `is_opened` flag is per-instance and resets when the scene reloads. Module 22 (Save/Load) will persist chest state using the `chest_id` field. |
| Enemy turn crashes with "Invalid get index" | Enemy targets array is empty because all party members died this turn | Always check `targets.is_empty()` before indexing into the array in `_execute_enemy_turn()`. |
| Encounter zone fires immediately on scene load | Battle starts the instant the player spawns | Set the initial step threshold high enough (`randi_range(10, 25)`) in `enter_zone()` so the player gets a few steps of grace. |

## Official Godot Documentation

### Core Classes

- [Node](https://docs.godotengine.org/en/stable/classes/class_node.html): base class for scene tree nodes; the state machine pattern uses `get_children()` and polymorphism
- [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html): base class for BattlerData, EnemyData, EncounterData, CharacterData
- [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html): base class for BattlerSprite and the Battle scene root
- [Marker2D](https://docs.godotengine.org/en/stable/classes/class_marker2d.html): position markers for party and enemy slots

### Physics and Collision

- [StaticBody2D](https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html): used for treasure chests, save crystals, and boss doors
- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html): interaction zones, encounter regions, exit zones, boss trigger
- [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html): defines collision regions for StaticBody2D and Area2D
- [RectangleShape2D](https://docs.godotengine.org/en/stable/classes/class_rectangleshape2d.html): rectangular collision shapes for zones and chests
- [CircleShape2D](https://docs.godotengine.org/en/stable/classes/class_circleshape2d.html): circular interaction radius for save crystals

### UI

- [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html): wraps battle menu and target selection
- [VBoxContainer](https://docs.godotengine.org/en/stable/classes/class_vboxcontainer.html): vertical layout for action buttons and target lists
- [MarginContainer](https://docs.godotengine.org/en/stable/classes/class_margincontainer.html): adds padding inside panels
- [Button](https://docs.godotengine.org/en/stable/classes/class_button.html): menu buttons; `pressed` signal and `grab_focus()` for keyboard navigation
- [Label](https://docs.godotengine.org/en/stable/classes/class_label.html): floating damage numbers and interaction prompts
- [ColorRect](https://docs.godotengine.org/en/stable/classes/class_colorrect.html): battle background placeholder
- [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html): renders BattleUI above the battle scene

### Animation

- [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html): procedural animations for attack slides and damage numbers; `tween_property()`, `tween_interval()`, `set_parallel()`, `chain()`
- [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html): visual representation of battlers, chests, crystals

### Tilemaps

- [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html): each layer of the dungeon tilemap (Ground, Detail, Objects, AbovePlayer)
- [TileSet](https://docs.godotengine.org/en/stable/classes/class_tileset.html): the cave tileset resource with physics layers for wall collision

### Scene Management

- [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html): `change_scene_to_file()`, `get_first_node_in_group()`, `create_timer()`
- [SceneTree.create_timer()](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-create-timer): one-shot timers used with `await` for pacing in battle states

### Signals and Input

- [Signal](https://docs.godotengine.org/en/stable/classes/class_signal.html): `connect()`, `disconnect()`, `is_connected()`, `emit()` used throughout
- [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html): focus-based keyboard/gamepad navigation between buttons

### Math and Randomness

- [Random number generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html): `randi_range()`, `randf()`, weighted random selection
- [Array.sort_custom()](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-sort-custom): custom sorting with a callable for turn ordering
- [Array.filter()](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-filter): filtering alive battlers with `is_alive()`
- [Array.any()](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-any): checking if any battler in a group is alive
- [@GDScript.max()](https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-max): clamping damage to a minimum of 1
- [@GDScript.clampf()](https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-clampf): bounding flee probability to 10-90%

### Export Annotations

- [@export](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html): exposes variables to the Inspector
- [@export_group](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#export-group): groups exported variables in the Inspector (used in EnemyData)
- [@export_range](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#export-range): constrains numeric values (used for drop_chance 0.0-1.0)

## What's Next

Part V shifts from combat to progression and persistence. In **Module 20: The Quest System and Game Flags**, we build a game-wide boolean flag system for tracking world state and a quest system on top of it, so the game has forward momentum beyond just leveling up.


---

<!-- Source: 20_quest_system.md -->

# Module 20: The Quest System and Game Flags

## What We Have So Far

Combat with rewards and leveling, a dungeon, NPCs with dialogue. The game has systems, but nothing connecting the player's actions into a progression.

## What We're Building This Module

Two things: a **game flags** system for tracking boolean world state, and a **quest system** built on top of it. Together, they make the world react to what the player does: NPCs say different things, doors open, new areas unlock.

## Game Flags: The Boolean Backbone

Think about what happens in Final Fantasy VI when you first meet Shadow in the bar at South Figaro. The game remembers whether you talked to him, whether you recruited him, and whether he ran away in your last battle. Dozens of tiny yes-or-no questions like these are tracked behind the scenes. Without them, every NPC would repeat the same line forever and the world would feel frozen. Game flags are how a JRPG makes the world remember what you did.

Game flags are the simplest and most universal state tracking in JRPGs. A flag is a boolean: something either has or hasn't happened.

```
"lira_intro_seen" = true
"crystal_cavern_unlocked" = false
"boss_defeated" = false
"pendant_found" = false
```

Create `res://autoloads/game_manager.gd`:

```gdscript
extends Node
## Tracks global game state via boolean flags. Autoload as GameManager.

signal flag_changed(flag_name: String, value: bool)

var _flags: Dictionary = {}


func set_flag(flag_name: String, value: bool = true) -> void:
    var old_value: bool = _flags.get(flag_name, false)
    _flags[flag_name] = value
    if old_value != value:
        flag_changed.emit(flag_name, value)


func get_flag(flag_name: String) -> bool:
    return _flags.get(flag_name, false)


func has_flag(flag_name: String) -> bool:
    return _flags.get(flag_name, false)


func clear_flag(flag_name: String) -> void:
    set_flag(flag_name, false)


func make_world_flag(scene_key: String, object_id: String, state: String) -> String:
    return "world.%s.%s.%s" % [scene_key, object_id, state]


func get_all_flags() -> Dictionary:
    return _flags.duplicate()


func load_flags(data: Dictionary) -> void:
    _flags = data.duplicate()
```

Register as autoload `GameManager`.

Flags are used everywhere:
- NPCs check flags to choose dialogue
- Doors check flags to decide if they're locked
- Quest objectives check flags to track completion
- The save system saves and loads flags

## QuestData Resource

Dragon Quest has hundreds of quests, and each one tracks the same things: a description, a list of objectives, and a reward. If each quest were a unique script with custom logic, the codebase would be unmanageable. Defining quests as data (a Resource with fields for title, objectives, and rewards) means adding a new quest is filling out a form, not writing new code.

Save as `res://resources/quest_data.gd`:

```gdscript
extends Resource
class_name QuestData
## Defines a quest with objectives, rewards, and state.

enum QuestState { NOT_STARTED, ACTIVE, COMPLETE, TURNED_IN }

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export_group("Objectives")
@export var objectives: Array[String] = []         # Human-readable descriptions
@export var objective_flags: Array[String] = []     # Flag names that mark completion

@export_group("Rewards")
@export var xp_reward: int = 0
@export var gold_reward: int = 0
@export var reward_items: Array[ItemData] = []
@export var completion_flag: String = ""  # Flag set when quest is turned in
```

## QuestManager Autoload

Save as `res://autoloads/quest_manager.gd` and register as autoload `QuestManager` (Project -> Project Settings -> Autoload tab -> add the script path, name it `QuestManager`).

```gdscript
extends Node
## Tracks active quests and checks objectives. Autoload as QuestManager.

signal quest_started(quest: QuestData)
signal quest_completed(quest: QuestData)
signal quest_turned_in(quest: QuestData)

var _active_quests: Array[QuestData] = []
var _completed_quests: Array[QuestData] = []
var _turned_in_quests: Array[QuestData] = []


func _ready() -> void:
    GameManager.flag_changed.connect(_on_flag_changed)


func start_quest(quest: QuestData) -> void:
    if _is_quest_active(quest.id) or is_quest_complete(quest.id) or _is_quest_done(quest.id):
        return
    _active_quests.append(quest)
    quest_started.emit(quest)


func is_quest_active(quest_id: String) -> bool:
    return _is_quest_active(quest_id)


func is_quest_complete(quest_id: String) -> bool:
    for q in _completed_quests:
        if q.id == quest_id:
            return true
    return false


func get_quest_state(quest_id: String) -> QuestData.QuestState:
    if _is_quest_done(quest_id):
        return QuestData.QuestState.TURNED_IN
    if is_quest_complete(quest_id):
        return QuestData.QuestState.COMPLETE
    if is_quest_active(quest_id):
        return QuestData.QuestState.ACTIVE
    return QuestData.QuestState.NOT_STARTED


func turn_in_quest(quest: QuestData) -> bool:
    if not quest:
        return false
    return turn_in_quest_by_id(quest.id)


func turn_in_quest_by_id(quest_id: String) -> bool:
    var quest: QuestData = null
    for candidate in _completed_quests:
        if candidate.id == quest_id:
            quest = candidate
            break

    if not quest:
        return false

    _completed_quests.erase(quest)
    _turned_in_quests.append(quest)

    # Grant rewards
    if quest.gold_reward > 0:
        InventoryManager.add_gold(quest.gold_reward)
    for item in quest.reward_items:
        InventoryManager.add_item(item)
    if not quest.completion_flag.is_empty():
        GameManager.set_flag(quest.completion_flag)

    quest_turned_in.emit(quest)
    return true


func get_active_quests() -> Array[QuestData]:
    return _active_quests.duplicate()


func get_completed_quests() -> Array[QuestData]:
    return _completed_quests.duplicate()


func get_turned_in_quests() -> Array[QuestData]:
    return _turned_in_quests.duplicate()


func _on_flag_changed(flag_name: String, _value: bool) -> void:
    # Check if any active quest's objectives are now all met
    # Collect completed quests first; don't modify the array during iteration
    var newly_completed: Array[QuestData] = []
    for quest in _active_quests:
        if _all_objectives_met(quest):
            newly_completed.append(quest)
    for quest in newly_completed:
        _active_quests.erase(quest)
        _completed_quests.append(quest)
        quest_completed.emit(quest)


func _all_objectives_met(quest: QuestData) -> bool:
    for flag in quest.objective_flags:
        if not GameManager.has_flag(flag):
            return false
    return true


func _is_quest_active(quest_id: String) -> bool:
    return _active_quests.any(func(q: QuestData) -> bool: return q.id == quest_id)


func _is_quest_done(quest_id: String) -> bool:
    return _turned_in_quests.any(func(q: QuestData) -> bool: return q.id == quest_id)
```

Notice what `turn_in_quest()` does **not** do yet: it does not award quest XP. That is intentional. Module 20 happens before PartyManager exists, so this version stays self-contained and safe to paste into the project at this point in the series. In Module 21, once the party roster exists, we'll revisit `turn_in_quest()` and route quest XP through the same leveling helper battles already use.

## Crystal Saga Quests

### Creating Quest `.tres` Files

Create the `res://data/quests/` folder (right-click `res://data/` → New Folder → `quests`).

**Main Quest: "The Crystal Resonance"**

1. Right-click `res://data/quests/` → New Resource → select **QuestData**
2. Save as `crystal_resonance.tres`
3. In the Inspector, set these fields:
   - `id`: "crystal_resonance"
   - `title`: "The Crystal Resonance"
   - `description`: "Investigate the crystal disturbances in the cave."
   - **Objectives:** Click the array, add 4 entries:
     - "Talk to Elder Maren in Willowbrook"
     - "Explore Whisperwood"
     - "Find the Crystal Cavern"
     - "Defeat the Crystal Guardian"
   - **Objective Flags:** Click the array, add 4 matching entries:
     - "talked_to_elder"
     - "reached_whisperwood"
     - "entered_crystal_cavern"
     - "boss_defeated"
   - `xp_reward`: 200
   - `gold_reward`: 100

**Side Quest: "The Lost Pendant"**

1. Right-click `res://data/quests/` → New Resource → **QuestData**
2. Save as `lost_pendant.tres`
3. Set fields:
   - `id`: "lost_pendant"
   - `title`: "The Lost Pendant"
   - `description`: "Find Fynn's pendant in the Whisperwood."
   - **Objectives:** "Talk to Wandering Fynn", "Find the pendant in Whisperwood"
   - **Objective Flags:** "talked_to_fynn", "pendant_found"
   - `completion_flag`: "pendant_returned"
   - `xp_reward`: 50
   - `gold_reward`: 30
   - **Reward Items:** Click **Add Element** twice and drag `ether.tres` into both slots. In this tutorial, `reward_items` is a plain `Array[ItemData]`, so duplicate entries represent multiple copies.

## Setting Quest Flags from Gameplay

The quest objectives rely on flags being set when things happen. Here's where to add flag-setting calls:

**In `res://scenes/willowbrook/willowbrook.gd`** (the elder NPC interaction):
```gdscript
# When the player talks to Elder Maren, set the flag:
func _on_elder_interacted() -> void:
    GameManager.set_flag("talked_to_elder")
    # ... existing dialogue code ...
```

**In `res://scenes/whisperwood/whisperwood.gd`** (scene entry):
```gdscript
func _ready() -> void:
    GameManager.set_flag("reached_whisperwood")
    # ... existing setup code ...
```

**In `res://scenes/crystal_cavern/crystal_cavern.gd`** (scene entry):
```gdscript
func _ready() -> void:
    GameManager.set_flag("entered_crystal_cavern")
    # ... existing setup code ...
```

The `boss_defeated` flag is set in Module 25's ending trigger. The `talked_to_fynn` flag is set in the reactive dialogue below.

**Starting the main quest:** Add this to the elder's dialogue handler in `willowbrook.gd`:
```gdscript
if not QuestManager.is_quest_active("crystal_resonance"):
    var quest: QuestData = load("res://data/quests/crystal_resonance.tres")
    if quest:
        QuestManager.start_quest(quest)
```

### The Pendant Pickup

The side quest needs a pendant object in Whisperwood. Use the treasure chest pattern from Module 16 to create a pickup:

1. Create `res://data/items/pendant.tres` (ItemData, type: KEY_ITEM, display_name: "Silver Pendant")
2. Place a treasure chest instance in the Whisperwood scene near a memorable landmark
3. Set the chest's `item` export to `pendant.tres` in the Inspector
4. In `whisperwood.gd`, connect to the chest's `opened` signal to set the flag:

```gdscript
func _on_pendant_chest_opened() -> void:
    GameManager.set_flag("pendant_found")
```

For Fynn's turn-in, add this to the `pendant_found` dialogue path in `willowbrook.gd`. Finding the pendant completes the objective; returning it is the turn-in action:
```gdscript
# After the "You found it!" dialogue finishes:
if QuestManager.turn_in_quest_by_id("lost_pendant"):
    var pendant := load("res://data/items/pendant.tres") as ItemData
    if pendant:
        InventoryManager.remove_item(pendant)
```

## Reactive Dialogue

In Chrono Trigger, every NPC in every town updates their dialogue after each major story event. After you rescue Queen Leene, the castle guards stop asking for help and start thanking you. This is what makes the world feel alive; characters acknowledge what you have done. Without reactive dialogue, NPCs are just repeating billboards, and the player never feels like their actions matter.

NPCs should say different things based on quest state and flags. Update NPC dialogue to check flags.

Add the following to `res://scenes/willowbrook/willowbrook.gd`. Then update your existing `_on_npc_interacted()` handler to call this function instead of reading `npc.npc_data.dialogue` directly:

```gdscript
# In _on_npc_interacted(), replace:
#   _dialogue_box.start_dialogue(npc.npc_data.dialogue)
# with:
#   _dialogue_box.start_dialogue(_get_dialogue_for_npc(npc))

func _get_dialogue_for_npc(npc: CharacterBody2D) -> Array[DialogueLine]:
    match npc.npc_data.id:
        "traveler_fynn":
            return _get_fynn_dialogue()
        _:
            return npc.npc_data.dialogue


func _get_fynn_dialogue() -> Array[DialogueLine]:
    if GameManager.has_flag("pendant_returned"):
        return _make_lines("Fynn", ["Thank you again for finding my pendant!"])
    elif GameManager.has_flag("pendant_found"):
        var lines := _make_lines("Fynn", [
            "You found it! My pendant! Thank you so much!",
            "Please, take this as a reward.",
        ])
        if QuestManager.turn_in_quest_by_id("lost_pendant"):
            var pendant := load("res://data/items/pendant.tres") as ItemData
            if pendant:
                InventoryManager.remove_item(pendant)
        return lines
    elif GameManager.has_flag("talked_to_fynn"):
        return _make_lines("Fynn", ["Any luck finding my pendant in the Whisperwood?"])
    else:
        GameManager.set_flag("talked_to_fynn")
        var quest: QuestData = load("res://data/quests/lost_pendant.tres")
        if quest:
            QuestManager.start_quest(quest)
        return _make_lines("Fynn", [
            "I lost something precious in the Whisperwood...",
            "A pendant, silver with a blue stone.",
            "If you find it, I'd be forever grateful.",
        ])


func _make_lines(speaker: String, texts: Array[String]) -> Array[DialogueLine]:
    var lines: Array[DialogueLine] = []
    for text in texts:
        var line := DialogueLine.new()
        line.speaker_name = speaker
        line.text = text
        lines.append(line)
    return lines
```

## Quest Log UI

The moment a JRPG has more than one quest, players start forgetting what they were doing. Earthbound lets you call your dad to get a hint, but most RPGs solve this with a quest journal. Even a simple log with checkable objectives prevents the frustration of wandering aimlessly because you forgot which NPC to talk to next.

A simple quest log accessible from the pause menu. Create `res://ui/quest_log/quest_log.tscn`:

### Scene Tree

```
QuestLog (PanelContainer)
└── MarginContainer
    └── VBoxContainer
        ├── QuestList (VBoxContainer)
        └── DetailLabel (RichTextLabel, bbcode_enabled)
```

### Script

Save as `res://ui/quest_log/quest_log.gd`:

```gdscript
extends PanelContainer
## Displays quest objectives and current progress.

var _is_open: bool = false

@onready var _quest_list: VBoxContainer = $MarginContainer/VBoxContainer/QuestList
@onready var _detail_label: RichTextLabel = $MarginContainer/VBoxContainer/DetailLabel


func _ready() -> void:
    visible = false
    process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") and _is_open:
        close()
        get_viewport().set_input_as_handled()


func open_from_pause() -> void:
    _is_open = true
    visible = true
    get_tree().paused = true
    refresh()


func close() -> void:
    _is_open = false
    visible = false
    get_tree().paused = false


func refresh() -> void:
    for child in _quest_list.get_children():
        child.queue_free()

    await get_tree().process_frame

    var active := QuestManager.get_active_quests()
    for quest in active:
        var button := Button.new()
        button.text = quest.title
        button.pressed.connect(_show_detail.bind(quest))
        _quest_list.add_child(button)

    if _quest_list.get_child_count() > 0:
        await get_tree().process_frame
        _quest_list.get_child(0).grab_focus()


func _show_detail(quest: QuestData) -> void:
    var text := "[b]" + quest.title + "[/b]\n\n"
    text += quest.description + "\n\n[b]Objectives:[/b]\n"
    for i in quest.objectives.size():
        var done: bool = false
        if i < quest.objective_flags.size():
            done = GameManager.has_flag(quest.objective_flags[i])
        var marker: String = "[x]" if done else "[ ]"
        text += marker + " " + quest.objectives[i] + "\n"
    _detail_label.text = text
```

After creating the scene, instance `quest_log.tscn` into each gameplay scene you currently have (`Willowbrook`, `Whisperwood`, and `CrystalCavern`) as a direct child of the scene root, alongside your other UI nodes. Leave it hidden by default. Module 25's PauseMenu will open these scene-local quest logs through `open_from_pause()`, just like it opens the inventory through Module 12's public API.

This first quest log keeps the presentation simple: it only lists **active** quests. `QuestManager` still tracks completed and turned-in quests separately for reward handling, save/load, and future journal tabs, but we are not surfacing those lists in the UI yet.

**Autoload reference card:**

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| **GameManager** | **20** | **Game flags, world state tracking** |
| **QuestManager** | **20** | **Quest tracking, objective checking** |

> **See:** [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html). GameManager and QuestManager are both autoloads. This tutorial covers when and why to use the autoload pattern.

> **See:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). QuestData extends Resource. This guide covers custom Resources, `@export` properties, and `.tres` file creation.

## Engineering Contract

- **Global state:** GameManager owns flags; QuestManager owns quest lifecycle arrays.
- **Public surface:** `set_flag()`, `make_world_flag()`, `start_quest()`, `get_quest_state()`, and `turn_in_quest_by_id()`.
- **Invariant:** Quest completion and quest turn-in are separate states; rewards are granted only from the completed state.
- **Failure behavior:** Turning in an unknown, active, or already turned-in quest returns `false`.
- **Copy semantics:** Quest list getters return defensive copies of manager arrays; QuestData Resources remain shared definitions.

## Engine Gotcha

Custom autoloads are not the same thing as engine singletons. `GameManager` and `QuestManager` are project nodes under `/root`, while `Input` and `AudioServer` are engine-provided singletons.

## What We've Learned

- **Game flags** are boolean key-value pairs tracking world state (`flag_name → bool`).
- **`GameManager.flag_changed` signal** lets any system react when the world state changes.
- **QuestData** defines objectives as flag names; a quest completes when all its flags are set.
- **Reactive dialogue** checks flags to choose what an NPC says, creating the illusion of a living world.
- **Quest rewards** are granted on turn-in: gold, items, and a completion flag. The `xp_reward` field is defined now and gets wired into PartyManager in Module 21.
- The first quest log shows **active** quests with objectives and checkmarks based on current flag state.

## What You Should See

- Talking to Fynn starts the "Lost Pendant" quest
- The quest log shows active quests with checkable objectives
- Finding the pendant in Whisperwood marks the objective
- Returning to Fynn triggers different dialogue and grants rewards
- NPCs react to your progress throughout the game

## Next Module

In **Module 21: Party Management, Equipment, and Shops**, we'll recruit Lira the mage, add equipment that modifies stats, and build the shop system, the final progression systems before save/load.


---

<!-- Source: 21_party_and_equipment.md -->

# Module 21: Party Management, Equipment, and Shops

## What We Have So Far

Quests, game flags, reactive dialogue, a dungeon with a boss, a battle system with leveling. The hero has been fighting alone.

## What We're Building This Module

Three major systems: **party management** (recruiting Lira the mage), **equipment** (weapons and armor that modify stats), and **shops** (buying and selling). These are the final progression systems.

## PartyManager Autoload

In Pokemon, your party of six travels with you everywhere. They appear in battle, they need healing at the Pokemon Center, and the PC storage system swaps them in and out. All of that requires one central place that knows who is in your party right now. Without a PartyManager, every system that cares about the roster (battle, save/load, equipment, healing) would need its own copy of the party list, and they would inevitably get out of sync.

Create `res://autoloads/party_manager.gd`:

```gdscript
extends Node
## Manages the party roster. Autoload as PartyManager.

signal party_member_joined(character: CharacterData)
signal party_member_removed(character: CharacterData)

var members: Array[CharacterData] = []


func _ready() -> void:
    # Start with the hero
    var aiden: CharacterData = load("res://data/characters/aiden.tres")
    if aiden:
        add_member(aiden)


func add_member(character: CharacterData) -> void:
    if not members.has(character):
        members.append(character)
        party_member_joined.emit(character)


func remove_member(character: CharacterData) -> void:
    if members.has(character):
        members.erase(character)
        party_member_removed.emit(character)


func get_members() -> Array[CharacterData]:
    return members.duplicate()


func get_member_by_id(id: String) -> CharacterData:
    for member in members:
        if member.id == id:
            return member
    return null


func award_xp_to_party(xp_per_member: int) -> void:
    if xp_per_member <= 0:
        return

    for member in members:
        print(member.display_name + " gained " + str(xp_per_member) + " XP!")
        for result in member.grant_xp(xp_per_member):
            var gains: Dictionary = result.gains
            print(member.display_name + " reached level " + str(result.level) + "!")
            print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
                  ", DEF +" + str(gains.defense))
```

Register as autoload `PartyManager`.

### Finishing Quest XP Integration

In Module 20, `QuestData` already had an `xp_reward` field, but `QuestManager.turn_in_quest_by_id()` intentionally left it unused because PartyManager did not exist yet. Now that the roster is in place, reopen `res://autoloads/quest_manager.gd` and update the reward section inside `turn_in_quest_by_id()`:

```gdscript
func turn_in_quest_by_id(quest_id: String) -> bool:
    var quest: QuestData = null
    for candidate in _completed_quests:
        if candidate.id == quest_id:
            quest = candidate
            break

    if not quest:
        return false

    _completed_quests.erase(quest)
    _turned_in_quests.append(quest)

    if quest.xp_reward > 0:
        PartyManager.award_xp_to_party(quest.xp_reward)
    if quest.gold_reward > 0:
        InventoryManager.add_gold(quest.gold_reward)
    for item in quest.reward_items:
        InventoryManager.add_item(item)
    if not quest.completion_flag.is_empty():
        GameManager.set_flag(quest.completion_flag)

    quest_turned_in.emit(quest)
    return true
```

This keeps quest turn-ins on the same leveling path as battle rewards. `PartyManager` owns "who gets XP," while `CharacterData.grant_xp()` still owns the actual leveling math from Module 18.

## Recruiting Lira

Create Lira's character data: right-click `res://data/characters/` → **New Resource** → search `CharacterData` → **Create** → name it `lira.tres`. Set ALL of these fields in the Inspector:
- `id`: "lira"
- `display_name`: "Lira"
- `max_hp`: 80, `max_mp`: 40
- `attack`: 6, `defense`: 5, `speed`: 9
- `hp_growth`: 8, `mp_growth`: 8, `attack_growth`: 1, `defense_growth`: 1, `speed_growth`: 2

> **Important:** The `id` field must be `"lira"` exactly. `PartyManager.get_member_by_id("lira")` uses this to find her. All growth rate fields must be non-zero or she won't gain stats on level-up (see Module 18).

Lira is a mage: lower HP and attack, higher MP and speed.

### The Recruitment Scene

In Willowbrook, add a new NPC: Lira. She joins the party after a dialogue exchange, gated by a game flag:

```gdscript
func _get_lira_dialogue() -> Array[DialogueLine]:
    if GameManager.has_flag("lira_joined"):
        return _make_lines("Lira", ["Ready to go when you are!"])

    if GameManager.has_flag("lira_ready_to_join"):
        return _make_lines("Lira", [
            "I've been studying the crystal formations nearby.",
            "They resonate with a strange energy...",
            "If you're heading to the Crystal Cavern, I'd like to come along.",
            "My magic could be useful!",
        ])

    if GameManager.has_flag("lira_intro_seen"):
        GameManager.set_flag("lira_ready_to_join")
        return _make_lines("Lira", [
            "I've been studying the crystal formations nearby.",
            "They resonate with a strange energy...",
            "If you're heading to the Crystal Cavern, I'd like to come along.",
            "My magic could be useful!",
        ])

    # First meeting
    GameManager.set_flag("lira_intro_seen")
    return _make_lines("Lira", [
        "Oh, hello! I'm Lira, a scholar from the capital.",
        "I came to Willowbrook to study the ancient crystals.",
        "Talk to me again if you're interested in what I've found.",
    ])
```

After the second conversation, trigger recruitment. This code goes in `willowbrook.gd`, which should have `@onready` references for the UI nodes (from Module 11 and this module):

```gdscript
@onready var _dialogue_box: Control = $DialogueBox  # From Module 11
@onready var _shop_ui: CanvasLayer = $ShopUI         # Instance of shop_ui.tscn (add to scene)
```

Add the recruitment wiring to the existing interaction handler:

```gdscript
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    # ... existing dialogue logic ...

    # Check for Lira recruitment after the second conversation
    if npc.npc_data.id == "lira" and GameManager.has_flag("lira_ready_to_join") and not GameManager.has_flag("lira_joined"):
        _dialogue_box.dialogue_finished.connect(_recruit_lira, CONNECT_ONE_SHOT)


func _recruit_lira() -> void:
    GameManager.set_flag("lira_joined")
    var lira: CharacterData = load("res://data/characters/lira.tres")
    if lira:
        PartyManager.add_member(lira)
        print("Lira joined the party!")
```

Update the battle initialization to use PartyManager instead of a hardcoded hero. In each area scene script that triggers battles (e.g., `crystal_cavern.gd` from Module 17), find the code that creates `var hero := BattlerData.new()` and replace the hero creation + `start_battle` call with:

```gdscript
# Build party BattlerData from PartyManager
var party_battlers: Array[BattlerData] = []
for char_data in PartyManager.get_members():
    var battler := BattlerData.new()
    battler.character_data = char_data
    battler.is_player_controlled = true
    party_battlers.append(battler)

# Use the full party instead of just [hero]
SceneManager.start_battle({party = party_battlers, enemies = enemy_battlers})
```

Apply this same change to the boss trigger (`boss_trigger.gd`) and any other script that calls `SceneManager.start_battle()`.

## Equipment System

In Final Fantasy IV, Cecil starts as a Dark Knight with heavy armor and a cursed sword. When he becomes a Paladin, his equipment changes completely and so does how he plays. Equipment is the most tangible form of character progression: the player can see their attack number go up and feel the difference in battle. It also drives the core economic loop: fight enemies, earn gold, buy better gear, fight harder enemies.

### Extending CharacterData

Add equipment slots to `character_data.gd`:

```gdscript
# Add to CharacterData
var equipped_weapon: ItemData = null
var equipped_armor: ItemData = null
var equipped_accessory: ItemData = null
# current_xp/current_hp/current_mp were introduced in Module 9 and used heavily in Module 18


func get_effective_attack() -> int:
    var bonus: int = equipped_weapon.attack_bonus if equipped_weapon else 0
    return attack + bonus


func get_effective_defense() -> int:
    var bonus: int = equipped_armor.defense_bonus if equipped_armor else 0
    bonus += equipped_accessory.defense_bonus if equipped_accessory else 0
    return defense + bonus


func get_effective_speed() -> int:
    var bonus: int = 0
    if equipped_accessory:
        bonus += equipped_accessory.speed_bonus
    return speed + bonus


func equip(item: ItemData) -> ItemData:
    ## Equips an item, returning the previously equipped item (or null).
    var previous: ItemData = null
    match item.equip_slot:
        ItemData.EquipSlot.WEAPON:
            previous = equipped_weapon
            equipped_weapon = item
        ItemData.EquipSlot.ARMOR:
            previous = equipped_armor
            equipped_armor = item
        ItemData.EquipSlot.ACCESSORY:
            previous = equipped_accessory
            equipped_accessory = item
    return previous


func unequip(slot: ItemData.EquipSlot) -> ItemData:
    var item: ItemData = null
    match slot:
        ItemData.EquipSlot.WEAPON:
            item = equipped_weapon
            equipped_weapon = null
        ItemData.EquipSlot.ARMOR:
            item = equipped_armor
            equipped_armor = null
        ItemData.EquipSlot.ACCESSORY:
            item = equipped_accessory
            equipped_accessory = null
    return item
```

### Creating Equipment Items

We need equipment the player can actually wear. If you created `iron_sword.tres` and `leather_armor.tres` back in Module 9, open them now and verify the equipment-specific fields match the values below. If you don't have them yet, create them now (right-click `res://data/items/` → New Resource → ItemData):

**Iron Sword** (`res://data/items/iron_sword.tres`):
- `id`: "iron_sword", `display_name`: "Iron Sword", `item_type`: EQUIPMENT, `equip_slot`: WEAPON, `attack_bonus`: 5, `buy_price`: 50, `sell_price`: 25

**Leather Armor** (`res://data/items/leather_armor.tres`):
- `id`: "leather_armor", `display_name`: "Leather Armor", `item_type`: EQUIPMENT, `equip_slot`: ARMOR, `defense_bonus`: 4, `buy_price`: 40, `sell_price`: 20

### The Complete Equip Flow

When equipping an item, the old item must return to inventory:

```gdscript
# Example: equipping from inventory (add to your equipment UI handler)
func _equip_item_on_character(character: CharacterData, item: ItemData) -> void:
    if not InventoryManager.remove_item(item):
        return

    var previous: ItemData = character.equip(item)
    if previous:
        InventoryManager.add_item(previous)
```

This three-step pattern (remove new item from inventory, equip it, add the old item back) prevents item duplication. The `equip()` method returns the old item so you always have a reference to it. If `remove_item()` returns `false`, stop before changing equipment.

### The Modifier Pattern (Looking Ahead)

Our equipment system uses simple addition: `effective_attack = base_attack + weapon.attack_bonus`. This works for Crystal Saga, but real RPGs need something more flexible. Consider: a spell that doubles your Attack for 3 turns, a poison that halves Speed, or a ring that adds +10% to all stats. Flat bonuses can't express percentages, and they don't stack cleanly with temporary buffs.

The standard solution is a **modifier system** where each modifier has two components:

- **add**: a flat bonus (e.g., +5 Attack from a sword)
- **mult**: a percentage multiplier (e.g., +0.25 for a 25% buff, -0.50 for a 50% debuff)

The formula: `final = (base + sum_of_adds) * (1.0 + sum_of_mults)`

All flat bonuses are summed first, then all percentage multipliers are applied together. This order matters: it makes percentage buffs more powerful (they multiply the total, not just the base), which is a deliberate design choice.

Each modifier gets a **unique ID**. This solves the stacking problem: two different +5 ATK swords stack (different IDs), but casting the same buff spell twice doesn't (same ID overwrites the previous instance).

We won't build this system for Crystal Saga; the simple `get_effective_*()` approach is sufficient. But if you later add status effects (Module 26 roadmap), buff/debuff spells, or set bonuses, the modifier system is the right abstraction. It lets equipment, spells, status effects, and passive abilities all feed into the same stat calculation through one unified mechanism.

### Battle Integration

Update BattlerData to use effective stats:

```gdscript
func initialize_from_character() -> void:
    if not character_data:
        return
    # Use current_hp/current_mp if set (carries over between battles)
    # Fall back to max values for the first battle or after a full heal
    current_hp = character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp
    current_mp = character_data.current_mp if character_data.current_mp > 0 else character_data.max_mp
    current_attack = character_data.get_effective_attack()
    current_defense = character_data.get_effective_defense()
    current_speed = character_data.get_effective_speed()
```

> **Important:** This ensures HP/MP carries over between battles. Module 18's Victory state syncs `battler.current_hp` back to `character_data.current_hp` after each fight. Without this check, the party would heal to full after every battle.

Now equipping a better sword directly increases damage in battle.

### Equipment UI

Create `res://ui/equipment/equipment_panel.tscn`:

```
EquipmentPanel (PanelContainer)
└── VBox (VBoxContainer)
    ├── NameLabel (Label)
    ├── StatsLabel (RichTextLabel)
    └── Slots (VBoxContainer)
        ├── WeaponButton (Button: "Weapon: None")
        ├── ArmorButton (Button: "Armor: None")
        └── AccessoryButton (Button: "Accessory: None")
```

Save the script as `res://ui/equipment/equipment_panel.gd`:

```gdscript
extends PanelContainer
## Equipment management for a party member.

signal equipment_changed

var _character: CharacterData

@onready var _name_label: Label = $VBox/NameLabel
@onready var _stats_label: RichTextLabel = $VBox/StatsLabel
@onready var _weapon_button: Button = $VBox/Slots/WeaponButton
@onready var _armor_button: Button = $VBox/Slots/ArmorButton
@onready var _accessory_button: Button = $VBox/Slots/AccessoryButton


func show_character(character: CharacterData) -> void:
    _character = character
    _refresh()


func _refresh() -> void:
    _name_label.text = _character.display_name + " (Lv. " + str(_character.level) + ")"
    _stats_label.text = (
        "HP: " + str(_character.max_hp) +
        "  ATK: " + str(_character.get_effective_attack()) +
        "  DEF: " + str(_character.get_effective_defense()) +
        "  SPD: " + str(_character.get_effective_speed())
    )
    _weapon_button.text = "Weapon: " + (_character.equipped_weapon.display_name if _character.equipped_weapon else "(none)")
    _armor_button.text = "Armor: " + (_character.equipped_armor.display_name if _character.equipped_armor else "(none)")
    _accessory_button.text = "Accessory: " + (_character.equipped_accessory.display_name if _character.equipped_accessory else "(none)")
```

### Slot Selection and Item Swapping

When the player clicks a slot button, show equipable items from inventory and allow swapping. Connect the button signals and add the selection logic:

```gdscript
func _ready() -> void:
    _weapon_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.WEAPON))
    _armor_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.ARMOR))
    _accessory_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.ACCESSORY))


func _on_slot_pressed(slot: ItemData.EquipSlot) -> void:
    # Get equipable items for this slot from inventory
    var equipable: Array = []
    for entry in InventoryManager.get_all_items():
        var item: ItemData = entry.item
        if item.item_type == ItemData.ItemType.EQUIPMENT and item.equip_slot == slot:
            equipable.append(item)

    if equipable.is_empty():
        print("No equipment for this slot in inventory.")
        return

    # Simple approach: equip the first matching item.
    # A full UI would show a selection list with stat comparisons.
    var item: ItemData = equipable[0]
    if not InventoryManager.remove_item(item):
        print("Could not equip " + item.display_name + ": item is no longer in inventory.")
        return

    var previous: ItemData = _character.equip(item)
    if previous:
        InventoryManager.add_item(previous)

    _refresh()
    equipment_changed.emit()
```

> **Exercise:** For a more polished experience, replace the "equip first item" logic with a popup list showing all matching items, their stats, and the stat difference compared to the current equipment. The inventory grid pattern from Module 12 works well for this.

We are not creating an accessory item in this module, so the new Accessory button will usually show `(none)` for now. That is expected. The point is to keep the teaching UI aligned with the `CharacterData` slot model you just added.

### Equipment Comparison: The PredictStats Pattern

Every JRPG shop and equipment screen answers the same question: "would this item make me stronger or weaker?" Showing red/green arrows next to stats is standard UX. The pattern for computing this is called **PredictStats**: calculate what the character's stats *would be* if they equipped a candidate item, without actually equipping it.

```gdscript
func predict_equip(candidate: ItemData) -> Dictionary:
    ## Returns a stat diff: positive values = improvement, negative = worse.
    ## Does NOT modify the character.
    var current_atk := get_effective_attack()
    var current_def := get_effective_defense()
    var current_spd := get_effective_speed()

    # Temporarily swap
    var slot := candidate.equip_slot
    var old_item: ItemData = null
    match slot:
        ItemData.EquipSlot.WEAPON:
            old_item = equipped_weapon
            equipped_weapon = candidate
        ItemData.EquipSlot.ARMOR:
            old_item = equipped_armor
            equipped_armor = candidate
        ItemData.EquipSlot.ACCESSORY:
            old_item = equipped_accessory
            equipped_accessory = candidate

    var diff := {
        attack = get_effective_attack() - current_atk,
        defense = get_effective_defense() - current_def,
        speed = get_effective_speed() - current_spd,
    }

    # Restore original equipment
    match slot:
        ItemData.EquipSlot.WEAPON:
            equipped_weapon = old_item
        ItemData.EquipSlot.ARMOR:
            equipped_armor = old_item
        ItemData.EquipSlot.ACCESSORY:
            equipped_accessory = old_item

    return diff
```

Usage in a shop or equipment UI:

```gdscript
var diff := character.predict_equip(iron_sword)
# diff = { attack = 5, defense = 0, speed = -1 }
# Display: ATK +5 (green arrow), DEF no change, SPD -1 (red arrow)
```

The key insight is the **temporarily swap, measure, restore** pattern. It reuses your existing `get_effective_*()` methods rather than duplicating the calculation logic. This means if you later add modifier stacking or set bonuses, the prediction stays accurate automatically.

## The Shop System

Secret of Mana's weapon shops in each town are progression gates disguised as stores. The player earns gold from battles and spends it on the next tier of weapons, creating a satisfying loop where exploration and combat feed back into power growth. Shops give the player agency over their build (do you buy a better sword for your fighter or a magic robe for your mage first?) and they anchor towns as meaningful destinations.

### ShopData Resource

Save as `res://resources/shop_data.gd`:

```gdscript
extends Resource
class_name ShopData
## Defines what a shop sells.

@export var shop_name: String = ""
@export var items_for_sale: Array[ItemData] = []
```

Create `res://data/shops/willowbrook_shop.tres`:
- Items: Potion, Ether, Iron Sword, Leather Armor

### Shop UI

Create `res://ui/shop/shop_ui.tscn`:

```
ShopUI (CanvasLayer, layer = 15)
└── Panel (PanelContainer, centered)
    └── Margin (MarginContainer)
        └── VBox (VBoxContainer)
            ├── ItemList (VBoxContainer)
            └── GoldLabel (Label: "Gold: 0")
```

Save the script as `res://ui/shop/shop_ui.gd`:

```gdscript
extends CanvasLayer
## Shop interface for buying items.

signal shop_closed

var _shop_data: ShopData

@onready var _item_list: VBoxContainer = $Panel/Margin/VBox/ItemList
@onready var _gold_label: Label = $Panel/Margin/VBox/GoldLabel


func _ready() -> void:
    # Must process while paused so the shop can receive input
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false


func _unhandled_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        close_shop()
        get_viewport().set_input_as_handled()


func open_shop(shop_data: ShopData) -> void:
    _shop_data = shop_data
    visible = true
    get_tree().paused = true
    _refresh()


func close_shop() -> void:
    visible = false
    get_tree().paused = false
    shop_closed.emit()


func _refresh() -> void:
    for child in _item_list.get_children():
        child.queue_free()

    await get_tree().process_frame

    _gold_label.text = "Gold: " + str(InventoryManager.gold)

    for item in _shop_data.items_for_sale:
        var button := Button.new()
        button.text = item.display_name + " - " + str(item.buy_price) + "g"
        if InventoryManager.gold < item.buy_price:
            button.disabled = true
        button.pressed.connect(_buy_item.bind(item))
        _item_list.add_child(button)

    if _item_list.get_child_count() > 0:
        await get_tree().process_frame
        _item_list.get_child(0).grab_focus()


func _buy_item(item: ItemData) -> void:
    if InventoryManager.spend_gold(item.buy_price):
        InventoryManager.add_item(item)
        print("Bought " + item.display_name + "!")
        _refresh()
```

### Connecting the Shopkeeper

When the player interacts with the shopkeeper NPC, open the shop instead of regular dialogue:

```gdscript
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    if npc.npc_data.id == "shopkeeper":
        var shop_data: ShopData = load("res://data/shops/willowbrook_shop.tres")
        if shop_data:
            _shop_ui.open_shop(shop_data)
            return
    # ... normal dialogue handling ...
```

### The Innkeeper

The innkeeper is simpler, just a dialogue choice that costs gold and heals the party:

```gdscript
func _handle_inn(npc: CharacterBody2D) -> void:
    var lines := _make_lines("Old Brennan", [
        "Rest for the night? That'll be 10 gold.",
    ])
    # Add a choice to the last line
    lines[0].choices = ["Yes (10g)", "No thanks"]
    _dialogue_box.start_dialogue(lines)
    var choice: int = await _dialogue_box.choice_made

    if choice == 0:  # Yes
        if InventoryManager.spend_gold(10):
            for member in PartyManager.get_members():
                member.current_hp = member.max_hp
                member.current_mp = member.max_mp
            _dialogue_box.start_dialogue(_make_lines("Old Brennan", ["Rest well, traveler."]))
        else:
            _dialogue_box.start_dialogue(_make_lines("Old Brennan", ["Seems you're a bit short."]))
```

> **See:** [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html). PartyManager is a new autoload. This guide covers the autoload pattern.

> **See:** [GUI containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html). VBoxContainer and PanelContainer are used for the equipment and shop UIs.

> **See:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). ShopData and CharacterData equipment slots both use the Resource pattern.

> **Note:** Selling items is left as an exercise. The pattern mirrors buying: show the player's inventory, select an item, add gold equal to half `buy_price`, remove the item from inventory.

## Autoload Reference Card (Updated)

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| GameManager | 20 | Game flags, world state tracking |
| QuestManager | 20 | Quest tracking, objective checking |
| **PartyManager** | **21** | **Party roster, recruitment, stats** |

## Engineering Contract

- **Global state:** PartyManager owns the runtime party roster.
- **Public surface:** `add_member()`, `remove_member()`, `get_members()`, `get_member_by_id()`, equipment APIs, shop open/buy flows.
- **Invariant:** Equipping consumes the new item before mutating the character, then returns the old item to inventory.
- **Failure behavior:** Failed inventory removal aborts equip instead of granting free gear.
- **Copy semantics:** `get_members()` returns a defensive array copy; CharacterData members inside it are live runtime objects.

## Engine Gotcha

Pausing with `get_tree().paused = true` pauses most nodes. Shop and equipment UI that must keep responding while paused need `process_mode = Node.PROCESS_MODE_ALWAYS`.

## What We've Learned

- **PartyManager** autoload tracks the roster of party members.
- **PartyManager.award_xp_to_party()** lets quest rewards reuse the same level-up path battles already use.
- **Recruitment** is triggered by dialogue + game flags, and the NPC becomes a party member.
- **Equipment** modifies effective stats. `get_effective_attack()` = base + weapon bonus.
- **PredictStats pattern:** temporarily swap equipment, measure the difference, restore the original. This lets shop and equipment UIs show green/red stat comparison arrows without committing the change.
- **The modifier pattern** (looking ahead): equipment bonuses, spell buffs, and status effects can all feed into stats through a unified `add`/`mult` modifier system. Not needed for Crystal Saga's scope, but essential for larger RPGs.
- **Equip/unequip** removes the new item from inventory first, then equips it, then returns the old item. If removal fails, equipment does not change.
- **Shops** use a ShopData resource listing items with prices.
- **The inn** is a dialogue choice that costs gold and restores HP/MP.
- All these systems build on previous modules: Resources (Module 9), dialogue (Module 11), inventory (Module 12), flags (Module 20).

## What You Should See

- Talking to Lira once introduces her, and the second conversation recruits her into the party
- The equipment panel shows the selected character's stats plus weapon, armor, and accessory slots. The accessory slot will stay `(none)` until you add an accessory item later
- Equipping a sword increases ATK in the stats display and in battle
- The shopkeeper opens a buy menu with prices
- The innkeeper offers rest for 10 gold and heals the party
- Lira appears in battle as a second party member once she joins

## Next Module

All game systems are in place. In **Module 22: Save and Load**, we'll persist everything (position, inventory, quests, party, equipment, flags) to JSON files, with save crystals in the world and multiple save slots.


---

<!-- Source: 22_save_and_load.md -->

# Module 22: Save and Load

## What We Have So Far

Every game system is functional: exploration, dialogue, combat, inventory, quests, party, equipment, shops. But if the player closes the game, everything is lost.

## What We're Building This Module

A save system that writes all game state to JSON files, with three save slots, save crystals in the world, and a load flow.

## What Needs Saving?

Every autoload holds state that must persist:

| Autoload | Data to Save |
|----------|-------------|
| GameManager | All flags (Dictionary) |
| InventoryManager | Items array, gold |
| QuestManager | Active, completed, turned-in quest IDs |
| PartyManager | Member IDs, levels, XP, stats, equipment |
| SceneManager | Current scene path, player position |

## Why JSON?

We use JSON for saves because:
- **Human-readable:** you can open a save file in a text editor and debug it
- **No class coupling:** JSON doesn't care about your Resource class definitions
- **Universally understood:** every language and tool can read JSON
- **Simple API:** Godot's `JSON.stringify()` and `JSON.parse()` handle everything

The alternative (Godot's `ResourceSaver` with `.tres` files) provides type safety but couples your saves to your class hierarchy. If you rename a Resource class, old saves break. JSON is more resilient for a tutorial scope.

> **See:** [Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html), the official guide covering multiple save approaches.

## The `to_save_data()` / `from_save_data()` Pattern

Early Pokemon games infamously had save corruption bugs because the save and load code paths were not symmetric: the game would save data in one order and try to read it back in a different order. The `to_save_data()` / `from_save_data()` pattern prevents this by making each system responsible for its own round-trip. If one method writes three fields, the other reads those same three fields. The symmetry makes it almost impossible to accidentally lose data.

Each autoload gets two methods: one to export its state as a Dictionary, one to restore it.

### GameManager

```gdscript
func to_save_data() -> Dictionary:
    return _flags.duplicate()

func from_save_data(data: Dictionary) -> void:
    _flags = data.duplicate()
```

### InventoryManager

```gdscript
func to_save_data() -> Dictionary:
    var items_data: Array[Dictionary] = []
    for entry in _items:
        items_data.append({
            item_id = entry.item.id,
            item_path = entry.item.resource_path,
            count = entry.count,
        })
    return {gold = gold, items = items_data}

func from_save_data(data: Dictionary) -> void:
    gold = data.get("gold", 0)
    _items.clear()
    for entry in data.get("items", []):
        var item: ItemData = load(entry.item_path) as ItemData
        if item:
            _items.append({item = item, count = entry.count})
    inventory_changed.emit()
    gold_changed.emit(gold)
```

### PartyManager

```gdscript
func to_save_data() -> Dictionary:
    var members_data: Array[Dictionary] = []
    for member in members:
        members_data.append({
            id = member.id,
            path = member.resource_path,
            level = member.level,
            current_xp = member.current_xp,
            max_hp = member.max_hp,
            max_mp = member.max_mp,
            attack = member.attack,
            defense = member.defense,
            speed = member.speed,
            current_hp = member.current_hp,
            current_mp = member.current_mp,
            weapon_path = member.equipped_weapon.resource_path if member.equipped_weapon else "",
            armor_path = member.equipped_armor.resource_path if member.equipped_armor else "",
            accessory_path = member.equipped_accessory.resource_path if member.equipped_accessory else "",
        })
    return {members = members_data}

func from_save_data(data: Dictionary) -> void:
    members.clear()
    for entry in data.get("members", []):
        var character := ResourceLoader.load(
            entry.path, "", ResourceLoader.CACHE_MODE_IGNORE,
        ) as CharacterData
        if character:
            character.level = entry.get("level", 1)
            character.current_xp = entry.get("current_xp", 0)
            character.max_hp = entry.get("max_hp", character.max_hp)
            character.max_mp = entry.get("max_mp", character.max_mp)
            character.attack = entry.get("attack", character.attack)
            character.defense = entry.get("defense", character.defense)
            character.speed = entry.get("speed", character.speed)
            character.current_hp = entry.get("current_hp", character.max_hp)
            character.current_mp = entry.get("current_mp", character.max_mp)
            var weapon_path: String = entry.get("weapon_path", "")
            if weapon_path:
                character.equipped_weapon = load(weapon_path) as ItemData
            var armor_path: String = entry.get("armor_path", "")
            if armor_path:
                character.equipped_armor = load(armor_path) as ItemData
            var accessory_path: String = entry.get("accessory_path", "")
            if accessory_path:
                character.equipped_accessory = load(accessory_path) as ItemData
            members.append(character)
```

This is our first use of `ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)`. The third argument tells Godot to bypass the usual cached copy and read a fresh `CharacterData` resource from disk. That matters because party members are mutable runtime objects now: they level up, change equipment, and lose HP. Loading a fresh base definition and then applying the saved state on top keeps the save/load boundary clean.

### QuestManager

```gdscript
func to_save_data() -> Dictionary:
    return {
        active = _active_quests.map(func(q: QuestData) -> String: return q.resource_path),
        completed = _completed_quests.map(func(q: QuestData) -> String: return q.resource_path),
        turned_in = _turned_in_quests.map(func(q: QuestData) -> String: return q.resource_path),
    }

func from_save_data(data: Dictionary) -> void:
    _active_quests.clear()
    _completed_quests.clear()
    _turned_in_quests.clear()
    for path in data.get("active", []):
        var q: QuestData = load(path) as QuestData
        if q: _active_quests.append(q)
    for path in data.get("completed", []):
        var q: QuestData = load(path) as QuestData
        if q: _completed_quests.append(q)
    for path in data.get("turned_in", []):
        var q: QuestData = load(path) as QuestData
        if q: _turned_in_quests.append(q)
```

### Persistent World Objects

Module 16 introduced `chest_id` on treasure chests. Now we make that ID meaningful. Small one-shot world state can live in `GameManager` flags because flags are already saved and loaded.

Use stable scene keys and object IDs:

```gdscript
const SCENE_KEY := "crystal_cavern"


func _world_flag(object_id: String, state: String) -> String:
    return GameManager.make_world_flag(SCENE_KEY, object_id, state)
```

For a chest:

```gdscript
@export var chest_id: String = ""
@export var item: ItemData
@export var amount: int = 1

var _opened: bool = false


func _ready() -> void:
    if chest_id.is_empty():
        push_warning("TreasureChest needs a stable chest_id for save/load.")
    _opened = GameManager.has_flag(_world_flag(chest_id, "opened"))
    _refresh_sprite()


func open() -> void:
    if _opened:
        return

    _opened = true
    InventoryManager.add_item(item, amount)
    GameManager.set_flag(_world_flag(chest_id, "opened"))
    _refresh_sprite()
```

Use the same pattern for other one-shot objects:

| Object | Suggested flag |
|--------|----------------|
| Opened chest | `world.crystal_cavern.<chest_id>.opened` |
| Defeated boss trigger | `world.crystal_cavern.crystal_guardian.defeated` |
| Unlocked boss door | `world.crystal_cavern.boss_door.unlocked` |
| Removed pickup | `world.whisperwood.pendant_chest.opened` |

> **Engine Gotcha:** String IDs are part of your save format. Renaming a scene key or `chest_id` after players have saves makes the old save look like the object was never opened. For a small tutorial game, stable IDs are enough. Larger games usually add migration code.

## The SaveManager

Create `res://autoloads/save_manager.gd` and register it as an autoload (**Project → Project Settings → Autoload** → add `save_manager.gd` as `SaveManager`). Unlike the other autoloads, SaveManager has no visible nodes; it's pure logic. We make it an autoload because save/load needs a stable runtime owner that survives scene changes, coordinates other autoloads, and can restore the scene after `change_scene_to_file()` completes:

> **Note:** `await` is a GDScript coroutine feature. The reason SaveManager is an autoload is architectural: it owns persistent save-slot behavior and orchestrates scene changes from a node that is not freed when gameplay scenes are replaced.

```gdscript
extends Node
## Handles saving and loading game state to JSON files.
## Registered as autoload, accessible as SaveManager.

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 3


func save_game(slot: int) -> bool:
    # Creates the save directory (and any parent directories) if it doesn't
    # exist yet. Safe to call even if the directory already exists.
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)

    var save_data: Dictionary = {
        version = 1,
        timestamp = Time.get_datetime_string_from_system(),
        scene_path = "",
        player_position = {x = 0.0, y = 0.0},
        game_flags = {},
        inventory = {},
        party = {},
        quests = {},
    }

    # Gather state from autoloads
    save_data.game_flags = GameManager.to_save_data()
    save_data.inventory = InventoryManager.to_save_data()
    save_data.party = PartyManager.to_save_data()
    save_data.quests = QuestManager.to_save_data()

    # Scene and player position
    var tree := Engine.get_main_loop() as SceneTree
    if tree and tree.current_scene:
        save_data.scene_path = tree.current_scene.scene_file_path
    var player := tree.get_first_node_in_group("player") if tree else null
    if player:
        save_data.player_position = {
            x = player.global_position.x,
            y = player.global_position.y,
        }

    # Write to file
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    var file := FileAccess.open(path, FileAccess.WRITE)
    if not file:
        push_error("SaveManager: failed to open " + path + " for writing")
        return false

    var json_string := JSON.stringify(save_data, "\t")
    file.store_string(json_string)
    file.close()
    print("Game saved to slot " + str(slot))
    return true


func load_game(slot: int) -> bool:
    var path := SAVE_DIR + "save_" + str(slot) + ".json"

    if not FileAccess.file_exists(path):
        push_error("SaveManager: save file not found: " + path)
        return false

    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        push_error("SaveManager: failed to open " + path)
        return false

    var json_string := file.get_as_text()
    file.close()

    # Godot's JSON class works in two steps: json.parse() attempts to parse
    # the string (returns OK on success), then json.data holds the result as
    # a Variant. A valid JSON root can be an array, number, string, bool, null,
    # or object, so check that it is a Dictionary before using it as save data.
    var json := JSON.new()
    var error := json.parse(json_string)
    if error != OK:
        push_error("SaveManager: JSON parse error: " + json.get_error_message())
        return false

    var parsed: Variant = json.data
    if not parsed is Dictionary:
        push_error("SaveManager: save root must be a Dictionary.")
        return false

    var save_data: Dictionary = parsed

    # Restore state to autoloads
    GameManager.from_save_data(save_data.get("game_flags", {}))
    InventoryManager.from_save_data(save_data.get("inventory", {}))
    PartyManager.from_save_data(save_data.get("party", {}))
    QuestManager.from_save_data(save_data.get("quests", {}))

    # Load the saved scene
    var scene_path: String = save_data.get("scene_path", "")
    if scene_path:
        var tree := Engine.get_main_loop() as SceneTree
        tree.change_scene_to_file(scene_path)
        # change_scene_to_file() is deferred. Wait for the tree to update.
        await tree.scene_changed

        # Restore player position
        var pos_data: Dictionary = save_data.get("player_position", {})
        var player := tree.get_first_node_in_group("player")
        if player:
            player.global_position = Vector2(
                pos_data.get("x", 0.0),
                pos_data.get("y", 0.0),
            )

    print("Game loaded from slot " + str(slot))
    return true


func get_slot_info(slot: int) -> Dictionary:
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    if not FileAccess.file_exists(path):
        return {}

    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return {}

    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK:
        return {}
    file.close()

    var parsed: Variant = json.data
    if not parsed is Dictionary:
        return {}

    var data: Dictionary = parsed
    return {
        timestamp = data.get("timestamp", ""),
        scene_path = data.get("scene_path", ""),
    }


func slot_exists(slot: int) -> bool:
    return FileAccess.file_exists(SAVE_DIR + "save_" + str(slot) + ".json")
```

> **See:** [FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html), for reading and writing files.

> **See:** [Data paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html). `user://` is the platform-specific writable directory for save data.

> **See:** [JSON](https://docs.godotengine.org/en/stable/classes/class_json.html), for parsing and generating JSON.

## Wiring the Save Crystal

Module 16's save crystal only printed a message. Once SaveManager exists, update that placeholder to open the slot dialog below. A direct `SaveManager.save_game(1)` call is fine as a temporary smoke test while wiring the autoload, but it should not be the final tutorial flow.

### Save Slot Selection UI

Final Fantasy games have used three save slots since the original NES cartridge, and the reason hasn't changed: players want to save before a risky boss fight without losing their earlier progress, and families sharing a console need separate saves. Multiple slots also let the player experiment: save before a branching choice, try one path, reload, try the other.

Rather than hardcoding slot 1, build a simple selection dialog. Create `res://ui/save_slot_dialog/save_slot_dialog.tscn`:

```
SaveSlotDialog (PanelContainer)
└── VBox (VBoxContainer)
    ├── TitleLabel (Label: "Choose a Slot")
    ├── Slot1Button (Button)
    ├── Slot2Button (Button)
    ├── Slot3Button (Button)
    └── CancelButton (Button: "Cancel")
```

```gdscript
extends PanelContainer
## A 3-slot save/load selection dialog.

signal slot_selected(slot: int)

@onready var _buttons: Array[Button] = [
    $VBox/Slot1Button,
    $VBox/Slot2Button,
    $VBox/Slot3Button,
]
@onready var _cancel_btn: Button = $VBox/CancelButton


func _ready() -> void:
    for i in range(_buttons.size()):
        _buttons[i].pressed.connect(_on_slot_pressed.bind(i + 1))
    _cancel_btn.pressed.connect(func() -> void: slot_selected.emit(0))
    refresh()
    _buttons[0].grab_focus()


func _on_slot_pressed(slot: int) -> void:
    slot_selected.emit(slot)


func refresh() -> void:
    for i in range(_buttons.size()):
        var slot_num: int = i + 1
        var info: Dictionary = SaveManager.get_slot_info(slot_num)
        if info.is_empty():
            _buttons[i].text = "Slot " + str(slot_num) + ": Empty"
        else:
            var scene_label: String = info.get("scene_path", "").get_file().get_basename().capitalize()
            _buttons[i].text = "Slot " + str(slot_num) + ": " + scene_label
```

Wire this into the save crystal:

```gdscript
func _activate() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    get_tree().current_scene.add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.save_game(slot)
    print("Saved to slot " + str(slot) + "!")
```

And the title screen's Continue button:

```gdscript
func _on_continue() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.load_game(slot)
```

## Error Handling

JSON files can be corrupted (incomplete write, manual editing). Always validate:

```gdscript
if json.parse(json_string) != OK:
    push_error("Corrupt save file: " + json.get_error_message())
    return false

var parsed: Variant = json.data
if not parsed is Dictionary:
    push_error("Save data is not a Dictionary")
    return false

var save_data: Dictionary = parsed
if not save_data.has("version"):
    push_error("Save data missing version field")
    return false
```

**Autoload reference card** (updated):

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| GameManager | 20 | Game flags, world state tracking |
| QuestManager | 20 | Quest tracking, objective checking |
| PartyManager | 21 | Party roster, recruitment, stats |
| **SaveManager** | **22** | **Save/load game state to JSON** |

> **Note:** `load_game()` uses `tree.change_scene_to_file()` directly instead of `SceneManager.change_scene()`. This is intentional. The save system needs to bypass SceneManager's spawn point logic and instead restore the exact player position from the save file. If you want the fade effect, you could call `SceneManager._anim_player.play("fade_out")` before loading and `fade_in` after.

### On Save Schema Design

As your game grows, you'll add new things that need saving (new autoloads, new systems, new character fields). Each addition means updating `to_save_data()` and `from_save_data()` for the affected objects. This works, but it's worth knowing the alternative.

Some RPG architectures use a **declarative save schema**, a single data structure that describes *what* to save, separate from *how* to save it. Instead of each autoload knowing how to serialize itself, a central schema says "from PartyManager, save these fields; from InventoryManager, save these fields." The save system walks the schema, extracts the data, and writes it. Loading walks the same schema in reverse.

The advantage: adding a new saveable field means adding one line to the schema, not editing the autoload. The disadvantage: more upfront complexity.

Our approach (`to_save_data()` per autoload) is the right call for Crystal Saga's scope. Each autoload owns its own serialization, which is easy to understand and debug. But if you build a larger RPG with 15+ autoloads and hundreds of saveable fields, consider consolidating into a schema.

Another thing to plan for: **save migration**. When you add a new field (say, a `reputation` system), old save files won't have it. Your `from_save_data()` methods should always use `.get("key", default_value)` rather than direct dictionary access. This way, loading an old save that lacks the `reputation` key gracefully falls back to the default instead of crashing.

## Engineering Contract

- **Global state:** SaveManager orchestrates serialization; each autoload owns its own save fragment.
- **Public surface:** `save_game(slot)`, `load_game(slot)`, `slot_exists(slot)`, `get_slot_info(slot)`, and SaveSlotDialog's `slot_selected`.
- **Invariant:** Save and load schemas are symmetric, versioned, and validated before restore.
- **Failure behavior:** Missing/corrupt files, non-Dictionary JSON roots, and slot cancel return cleanly.
- **Copy semantics:** Save data is plain Dictionaries/Arrays; mutable Resources are restored from paths, with cache bypass where fresh runtime copies matter.

## Engine Gotcha

JSON parsing returns a Variant root. Even valid JSON might be an array or string, so check `parsed is Dictionary` before treating it as a save file.

## What We've Learned

- **JSON** is the save format: human-readable, no class coupling, simple API.
- **`to_save_data()` / `from_save_data()`** on each autoload exports/imports state as Dictionaries.
- **`user://`** is the writable save directory; `FileAccess` handles file I/O.
- **Save crystals** trigger the save flow; `load_game()` is designed to be reused by UI flows like the title screen's Continue button in Module 25.
- **Save slot cancellation** returns slot `0`, so callers can `return` cleanly instead of waiting forever on a separate cancel signal.
- **World-object state** such as opened chests and one-shot bosses can live in saved `GameManager` flags when each object has a stable scene key and object ID.
- Resources are referenced by **path** in saves (`resource_path`), not by value. For mutable party members, `ResourceLoader.CACHE_MODE_IGNORE` rebuilds a fresh runtime copy from the `.tres` definition before saved state is applied.
- Always validate JSON before using it. Corrupt saves shouldn't crash the game.
- Use `.get("key", default)` for future-proof save loading; old saves missing new fields won't crash.

## What You Should See

- Interacting with the save crystal writes a JSON file to `user://saves/`
- Loading restores the player's position, inventory, quests, party, flags, and one-shot world-object state stored in `GameManager`
- The game continues exactly where you left off

## Next Module

The game is fully playable and saveable. In **Module 24: Audio**, we'll add background music, sound effects, and a volume settings system, bringing sound to Crystal Saga.


---

<!-- Source: 23_part_v_review.md -->

# Module 23: Part V Review and Cheat Sheet

This module is your reference for everything covered in Part V: Progression and Persistence (Modules 20-22). Use it to review what you built, look up syntax you have forgotten, or sanity-check your implementation before moving on.

## Part V in Review

Part V connected Crystal Saga's isolated systems into a game with actual progression. Before these three modules, the player could explore, fight, and collect items, but nothing tied those actions together into a story arc, and nothing survived closing the game.

Module 20 introduced two foundational concepts: game flags and quests. Game flags gave every system in the project a shared language for tracking what has happened in the world, while the quest system built on top of those flags to create structured objectives with rewards. The trick was a reactive signal (`flag_changed`) that lets quest completion happen automatically when the world state changes, rather than through manual checking. This also made NPCs responsive: Fynn remembers whether you have spoken to him, whether you found his pendant, and whether you already returned it.

Module 21 added the remaining progression systems. PartyManager gave us a roster (and Lira, the first companion), the equipment system made gear meaningful by modifying effective stats, and the shop system let the player spend their hard-earned gold. It also completed the quest XP loop by routing turn-in rewards through the same leveling helper battles already use. Finally, Module 22 closed the loop by persisting every piece of game state to JSON files. The `to_save_data()` / `from_save_data()` pattern gave each autoload a clean serialization boundary, and the save slot UI gave players the classic three-slot experience. With save and load in place, Crystal Saga became a game you can actually put down and come back to.

### Module 20: The Quest System and Game Flags
- Built the **GameManager** autoload: a dictionary of boolean flags (`flag_name -> true/false`) with a `flag_changed` signal that lets any system react when the world state changes.
- Created the **QuestData** Resource class with objectives defined as flag names, so a quest completes automatically when all its objective flags are set.
- Built the **QuestManager** autoload to track active, completed, and turned-in quests, grant gold/items on turn-in, and emit signals for quest state transitions.
- Implemented **reactive NPC dialogue** where characters like Fynn say different things depending on flags and quest progress, creating the illusion of a living world.
- Added a **quest log UI** that lists active quests and shows per-objective checkmarks based on current flag state.

### Module 21: Party Management, Equipment, and Shops
- Built the **PartyManager** autoload to manage the party roster, with signals for join/leave events and a lookup-by-ID method.
- Implemented **Lira's recruitment** as a flag-gated dialogue sequence: first meeting sets `lira_intro_seen`, second conversation sets `lira_ready_to_join`, and dialogue completion triggers `add_member()` exactly once.
- Added **party-wide quest XP routing** via `PartyManager.award_xp_to_party()`, so quest rewards and battle rewards both flow through `CharacterData.grant_xp()`.
- Extended **CharacterData** with equipment slots (weapon, armor, accessory) and `get_effective_*()` methods that add equipment bonuses to base stats, wired directly into battle through BattlerData.
- Created the **ShopData** Resource and **shop UI**: a CanvasLayer that pauses the game, lists items with prices, validates gold, and handles purchases through InventoryManager.
- Added the **innkeeper pattern**: a dialogue choice that costs gold and restores HP/MP for the entire party via PartyManager.

### Module 22: Save and Load
- Identified **what needs saving** by auditing every autoload for mutable state: flags, inventory, party members (including levels, stats, and equipment), quest arrays, scene path, and player position.
- Implemented the **`to_save_data()` / `from_save_data()` pattern** on each autoload: export state as a plain Dictionary, import it back from one. Resources are referenced by file path, not serialized by value.
- Built the **SaveManager** autoload with `save_game(slot)` and `load_game(slot)`: writes JSON to `user://saves/`, reads it back, restores all autoload state, and changes to the saved scene with the correct player position.
- Created a **save slot selection UI** with three slots that display the saved location and wire into both save crystals and the title screen's Continue button.
- Added **error handling guidance** for corrupt or missing save files: JSON parse validation in the main flow, plus recommended Dictionary type checks and version verification.

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|----------------|------------|
| Game flag | A boolean key-value pair in GameManager (`"pendant_found" = true`) | Universal state tracking that every system can read and react to | Module 20 |
| `flag_changed` signal | Emitted by GameManager when any flag value changes | Enables reactive systems: quests auto-complete, NPCs update dialogue, doors unlock, without polling | Module 20 |
| QuestData | A Resource class defining a quest's objectives, descriptions, and rewards | Data-driven quest definitions that live in `.tres` files and can be created in the editor | Module 20 |
| Quest state machine | Manager-inferred lifecycle: NOT_STARTED -> ACTIVE -> COMPLETE -> TURNED_IN | Prevents invalid transitions like turning in a quest that was never completed | Module 20 |
| Objective flags | An array of flag names on QuestData that map 1:1 to objectives | Quests complete automatically when all objective flags are set, no manual checking needed | Module 20 |
| Reactive dialogue | NPC dialogue functions that branch on flag/quest state | Makes the world feel responsive to the player's actions without complex scripting | Module 20 |
| PartyManager | An autoload holding the array of CharacterData for current party members | Centralized roster that battle, UI, save, and equipment systems all reference | Module 21 |
| Equipment slots | `equipped_weapon`, `equipped_armor`, `equipped_accessory` vars on CharacterData | Gear modifies effective stats, creating meaningful progression from shops and loot | Module 21 |
| Effective stats | `get_effective_attack()` = base stat + equipment bonus | Separates permanent character growth from temporary equipment bonuses | Module 21 |
| ShopData | A Resource class listing items available for purchase | Data-driven shops: change inventory by editing a `.tres` file, no code changes | Module 21 |
| `to_save_data()` | A method on each autoload that exports its state as a Dictionary | Clean serialization boundary: each system owns its own save format | Module 22 |
| `from_save_data()` | A method on each autoload that restores state from a Dictionary | Symmetric with `to_save_data()`, making save/load a simple round-trip | Module 22 |
| `user://` path | Godot's platform-specific writable directory for user data | Save files go here because `res://` is read-only in exported builds | Module 22 |
| Save slot | A numbered JSON file (`save_1.json`, `save_2.json`, `save_3.json`) | The classic JRPG pattern: players maintain multiple save states | Module 22 |
| Resource path referencing | Saving `resource_path` strings instead of serializing entire Resources | Keeps save files small and resilient; the `.tres` file is the source of truth | Module 22 |

## Cheat Sheet

### Game Flags System

The GameManager autoload stores boolean flags that any system can set and check. The `flag_changed` signal makes the system reactive rather than poll-based.

```gdscript
# Setting flags
GameManager.set_flag("talked_to_elder")          # Sets to true
GameManager.set_flag("door_locked", false)        # Explicitly set to false
GameManager.clear_flag("temporary_buff")          # Same as set_flag(..., false)

# Checking flags
if GameManager.has_flag("pendant_found"):
    # Player found the pendant
    pass

var is_unlocked: bool = GameManager.get_flag("crystal_cavern_unlocked")

# Reacting to flag changes from anywhere
GameManager.flag_changed.connect(_on_flag_changed)

func _on_flag_changed(flag_name: String, value: bool) -> void:
    if flag_name == "boss_defeated" and value:
        # The boss was just defeated, update the world
        pass

# Bulk operations (used by save/load)
var all_flags: Dictionary = GameManager.get_all_flags()
GameManager.load_flags(saved_flags_dictionary)        # direct reset/helper
GameManager.from_save_data(saved_flags_dictionary)    # Module 22 save/load path

# Stable world-object flags saved through GameManager
var chest_flag := GameManager.make_world_flag("crystal_cavern", "potion_chest", "opened")
GameManager.set_flag(chest_flag)
```

Register GameManager as an autoload at **Project -> Project Settings -> Autoload -> add `res://autoloads/game_manager.gd` as `GameManager`**.

### Quest Architecture

Quests are data-driven: a [QuestData](https://docs.godotengine.org/en/stable/classes/class_resource.html) Resource defines what a quest is, and QuestManager tracks its lifecycle.

```gdscript
# QuestData Resource (res://resources/quest_data.gd)
extends Resource
class_name QuestData

enum QuestState { NOT_STARTED, ACTIVE, COMPLETE, TURNED_IN }

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export_group("Objectives")
@export var objectives: Array[String] = []         # Human-readable text
@export var objective_flags: Array[String] = []     # Flag names for completion

@export_group("Rewards")
@export var xp_reward: int = 0
@export var gold_reward: int = 0
@export var reward_items: Array[ItemData] = []   # Add the same item twice for two copies
@export var completion_flag: String = ""  # Flag set on turn-in
```

```gdscript
# Starting a quest
var quest: QuestData = load("res://data/quests/crystal_resonance.tres")
if quest:
    QuestManager.start_quest(quest)

# Checking quest state
if QuestManager.is_quest_active("lost_pendant"):
    pass
if QuestManager.is_quest_complete("lost_pendant"):
    pass
if QuestManager.get_quest_state("lost_pendant") == QuestData.QuestState.TURNED_IN:
    pass

# Turning in a quest (grants rewards automatically)
QuestManager.turn_in_quest_by_id("lost_pendant")

# Listing quests
var active: Array[QuestData] = QuestManager.get_active_quests()
var completed: Array[QuestData] = QuestManager.get_completed_quests()
var turned_in: Array[QuestData] = QuestManager.get_turned_in_quests()

# Quest signals
QuestManager.quest_started.connect(_on_quest_started)
QuestManager.quest_completed.connect(_on_quest_completed)
QuestManager.quest_turned_in.connect(_on_quest_turned_in)
```

Quest completion is automatic: QuestManager listens for `GameManager.flag_changed` and checks whether all `objective_flags` for each active quest are now set. When they are, it moves the quest to the completed list and emits `quest_completed`. Turn-in is a separate guarded transition: `turn_in_quest_by_id()` only grants rewards when the ID is currently in the completed list.

This first quest log stays focused on **active** quests. Completed and turned-in quests are still tracked separately in `QuestManager` for reward handling, save/load, and future UI expansion, but they are not shown in this starter journal.

### Quest Log UI

The quest log is a [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html) with a list of quest buttons and a detail label.

```
QuestLog (PanelContainer)
└── MarginContainer
    └── VBoxContainer
        ├── QuestList (VBoxContainer)       # Buttons, one per active quest
        └── DetailLabel (RichTextLabel)      # Quest description + objectives
```

```gdscript
func open_from_pause() -> void:
    _is_open = true
    visible = true
    get_tree().paused = true
    refresh()

# Refreshing the quest list
func refresh() -> void:
    for child in _quest_list.get_children():
        child.queue_free()
    await get_tree().process_frame

    for quest in QuestManager.get_active_quests():
        var button := Button.new()
        button.text = quest.title
        button.pressed.connect(_show_detail.bind(quest))
        _quest_list.add_child(button)

# Showing objectives with checkmarks
func _show_detail(quest: QuestData) -> void:
    var text := "[b]" + quest.title + "[/b]\n\n"
    text += quest.description + "\n\n[b]Objectives:[/b]\n"
    for i in quest.objectives.size():
        var done: bool = false
        if i < quest.objective_flags.size():
            done = GameManager.has_flag(quest.objective_flags[i])
        var marker: String = "[x]" if done else "[ ]"
        text += marker + " " + quest.objectives[i] + "\n"
    _detail_label.text = text
```

### Reactive NPC Dialogue

NPCs check flags and quest state to choose which dialogue lines to show. The pattern is a function that returns different `Array[DialogueLine]` based on the current world state, checking from most-progressed to least-progressed.

```gdscript
func _get_fynn_dialogue() -> Array[DialogueLine]:
    # Check most-progressed state first
    if GameManager.has_flag("pendant_returned"):
        return _make_lines("Fynn", ["Thank you again for finding my pendant!"])
    elif GameManager.has_flag("pendant_found"):
        var lines := _make_lines("Fynn", [
            "You found it! My pendant! Thank you so much!",
            "Please, take this as a reward.",
        ])
        if QuestManager.turn_in_quest_by_id("lost_pendant"):
            var pendant := load("res://data/items/pendant.tres") as ItemData
            if pendant:
                InventoryManager.remove_item(pendant)
        return lines
    elif GameManager.has_flag("talked_to_fynn"):
        return _make_lines("Fynn", ["Any luck finding my pendant in the Whisperwood?"])
    else:
        # First meeting: set the flag and start the quest
        GameManager.set_flag("talked_to_fynn")
        var quest: QuestData = load("res://data/quests/lost_pendant.tres")
        if quest:
            QuestManager.start_quest(quest)
        return _make_lines("Fynn", [
            "I lost something precious in the Whisperwood...",
            "A pendant, silver with a blue stone.",
            "If you find it, I'd be forever grateful.",
        ])

# Helper to create dialogue line arrays
func _make_lines(speaker: String, texts: Array[String]) -> Array[DialogueLine]:
    var lines: Array[DialogueLine] = []
    for text in texts:
        var line := DialogueLine.new()
        line.speaker_name = speaker
        line.text = text
        lines.append(line)
    return lines
```

The key pattern: check flags from **most progressed to least progressed** (post-quest, mid-quest, pre-quest, first meeting). The first branch that matches wins.

### PartyManager

The [PartyManager](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) autoload manages who is in the party. It starts with the hero and grows through recruitment events.

```gdscript
# Core API
PartyManager.add_member(character)          # CharacterData
PartyManager.remove_member(character)
var members: Array[CharacterData] = PartyManager.get_members()
var lira: CharacterData = PartyManager.get_member_by_id("lira")

# Signals
PartyManager.party_member_joined.connect(_on_member_joined)
PartyManager.party_member_removed.connect(_on_member_removed)
```

Recruitment is triggered by dialogue and gated by flags:

```gdscript
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    # ... dialogue logic ...
    # After Lira's second conversation:
    if npc.npc_data.id == "lira" and GameManager.has_flag("lira_ready_to_join") \
            and not GameManager.has_flag("lira_joined"):
        _dialogue_box.dialogue_finished.connect(_recruit_lira, CONNECT_ONE_SHOT)

func _recruit_lira() -> void:
    GameManager.set_flag("lira_joined")
    var lira: CharacterData = load("res://data/characters/lira.tres")
    if lira:
        PartyManager.add_member(lira)
```

Building party battler data for combat:

```gdscript
var party_battlers: Array[BattlerData] = []
for char_data in PartyManager.get_members():
    var battler := BattlerData.new()
    battler.character_data = char_data
    battler.is_player_controlled = true
    party_battlers.append(battler)
SceneManager.start_battle({party = party_battlers, enemies = enemy_battlers})
```

### Equipment System

Equipment is stored directly on [CharacterData](https://docs.godotengine.org/en/stable/classes/class_resource.html) and modifies effective stats.

```gdscript
# Equipment slots on CharacterData
var equipped_weapon: ItemData = null
var equipped_armor: ItemData = null
var equipped_accessory: ItemData = null

# Effective stat calculation
func get_effective_attack() -> int:
    var bonus: int = equipped_weapon.attack_bonus if equipped_weapon else 0
    return attack + bonus

func get_effective_defense() -> int:
    var bonus: int = equipped_armor.defense_bonus if equipped_armor else 0
    bonus += equipped_accessory.defense_bonus if equipped_accessory else 0
    return defense + bonus

func get_effective_speed() -> int:
    var bonus: int = 0
    if equipped_accessory:
        bonus += equipped_accessory.speed_bonus
    return speed + bonus
```

The equip/unequip flow always returns the previous item so you can put it back in inventory:

```gdscript
# Equip returns the item that was in that slot (or null)
func equip(item: ItemData) -> ItemData:
    var previous: ItemData = null
    match item.equip_slot:
        ItemData.EquipSlot.WEAPON:
            previous = equipped_weapon
            equipped_weapon = item
        ItemData.EquipSlot.ARMOR:
            previous = equipped_armor
            equipped_armor = item
        ItemData.EquipSlot.ACCESSORY:
            previous = equipped_accessory
            equipped_accessory = item
    return previous

# Full equip flow: remove new item first, equip, then return old item to inventory
func _equip_item_on_character(character: CharacterData, item: ItemData) -> void:
    if not InventoryManager.remove_item(item):
        return
    var previous: ItemData = character.equip(item)
    if previous:
        InventoryManager.add_item(previous)
```

Battle integration uses effective stats:

```gdscript
func initialize_from_character() -> void:
    if not character_data:
        return
    current_hp = character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp
    current_mp = character_data.current_mp if character_data.current_mp > 0 else character_data.max_mp
    current_attack = character_data.get_effective_attack()
    current_defense = character_data.get_effective_defense()
    current_speed = character_data.get_effective_speed()
```

### Shop System

Shops use a [ShopData](https://docs.godotengine.org/en/stable/classes/class_resource.html) Resource and a [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html)-based UI.

```gdscript
# ShopData Resource (res://resources/shop_data.gd)
extends Resource
class_name ShopData

@export var shop_name: String = ""
@export var items_for_sale: Array[ItemData] = []
```

Create `.tres` files in `res://data/shops/` via the editor: right-click, New Resource, select ShopData, and drag item resources into the `items_for_sale` array.

```gdscript
# Opening the shop from an NPC interaction
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    if npc.npc_data.id == "shopkeeper":
        var shop_data: ShopData = load("res://data/shops/willowbrook_shop.tres")
        if shop_data:
            _shop_ui.open_shop(shop_data)
            return
    # ... normal dialogue ...
```

```gdscript
# Shop UI core logic
func open_shop(shop_data: ShopData) -> void:
    _shop_data = shop_data
    visible = true
    get_tree().paused = true       # Pause the game behind the shop
    _refresh()

func close_shop() -> void:
    visible = false
    get_tree().paused = false
    shop_closed.emit()

func _buy_item(item: ItemData) -> void:
    if InventoryManager.spend_gold(item.buy_price):
        InventoryManager.add_item(item)
        _refresh()                  # Update gold display and button states
```

The shop UI sets `process_mode = Node.PROCESS_MODE_ALWAYS` so it can receive input while the game is paused. Buttons are disabled when the player cannot afford an item.

The innkeeper is a simpler variant that uses dialogue choices instead of a full shop UI:

```gdscript
func _handle_inn(npc: CharacterBody2D) -> void:
    var lines := _make_lines("Old Brennan", ["Rest for the night? That'll be 10 gold."])
    lines[0].choices = ["Yes (10g)", "No thanks"]
    _dialogue_box.start_dialogue(lines)
    var choice: int = await _dialogue_box.choice_made

    if choice == 0 and InventoryManager.spend_gold(10):
        for member in PartyManager.get_members():
            member.current_hp = member.max_hp
            member.current_mp = member.max_mp
```

### Save System Architecture

SaveManager gathers state from every autoload, serializes it as JSON, and writes it to disk. Loading reverses the process.

**What gets saved:**

| Autoload | Saved Data |
|----------|-----------|
| GameManager | All flags (Dictionary of String -> bool), including world-object flags such as opened chests and defeated one-shot bosses |
| InventoryManager | Items array (id, resource path, count) + gold |
| QuestManager | Active/completed/turned-in quest resource paths |
| PartyManager | Member paths, levels, XP, all stats, equipment paths |
| SceneManager | Current scene file path |
| (Player node) | Global position (x, y) |

**Save file structure (`user://saves/save_1.json`):**

```gdscript
{
    "version": 1,
    "timestamp": "2025-03-15T14:30:00",
    "scene_path": "res://scenes/willowbrook/willowbrook.tscn",
    "player_position": {"x": 128.0, "y": 256.0},
    "game_flags": {
        "talked_to_elder": true,
        "pendant_found": true,
        "world.crystal_cavern.potion_chest.opened": true
    },
    "inventory": {"gold": 150, "items": [{"item_id": "potion", "item_path": "res://data/items/potion.tres", "count": 3}]},
    "party": {"members": [{"id": "aiden", "path": "res://data/characters/aiden.tres", "level": 5, ...}]},
    "quests": {"active": ["res://data/quests/crystal_resonance.tres"], "completed": [], "turned_in": []}
}
```

**The save flow:**

```gdscript
# SaveManager.save_game(slot)
func save_game(slot: int) -> bool:
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)

    var save_data: Dictionary = {
        version = 1,
        timestamp = Time.get_datetime_string_from_system(),
        scene_path = "",
        player_position = {x = 0.0, y = 0.0},
        game_flags = {},
        inventory = {},
        party = {},
        quests = {},
    }

    # Gather state from each autoload
    save_data.game_flags = GameManager.to_save_data()
    save_data.inventory = InventoryManager.to_save_data()
    save_data.party = PartyManager.to_save_data()
    save_data.quests = QuestManager.to_save_data()

    # Scene and player position
    var tree := Engine.get_main_loop() as SceneTree
    if tree and tree.current_scene:
        save_data.scene_path = tree.current_scene.scene_file_path
    var player := tree.get_first_node_in_group("player") if tree else null
    if player:
        save_data.player_position = {
            x = player.global_position.x,
            y = player.global_position.y,
        }

    # Write JSON to file
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    var file := FileAccess.open(path, FileAccess.WRITE)
    if not file:
        push_error("SaveManager: failed to open " + path + " for writing")
        return false
    file.store_string(JSON.stringify(save_data, "\t"))
    file.close()
    return true
```

**The load flow:**

```gdscript
# SaveManager.load_game(slot)
func load_game(slot: int) -> bool:
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    if not FileAccess.file_exists(path):
        return false

    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return false

    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK:
        push_error("Corrupt save: " + json.get_error_message())
        return false
    file.close()

    var parsed: Variant = json.data
    if not parsed is Dictionary:
        return false

    var save_data: Dictionary = parsed

    # Restore each autoload's state
    GameManager.from_save_data(save_data.get("game_flags", {}))
    InventoryManager.from_save_data(save_data.get("inventory", {}))
    PartyManager.from_save_data(save_data.get("party", {}))
    QuestManager.from_save_data(save_data.get("quests", {}))

    # Change to the saved scene and restore player position
    var scene_path: String = save_data.get("scene_path", "")
    if scene_path:
        var tree := Engine.get_main_loop() as SceneTree
        tree.change_scene_to_file(scene_path)
        await tree.scene_changed
        var pos_data: Dictionary = save_data.get("player_position", {})
        var player := tree.get_first_node_in_group("player")
        if player:
            player.global_position = Vector2(pos_data.get("x", 0.0), pos_data.get("y", 0.0))
    return true
```

### The Saveable Pattern

Each autoload implements a symmetric pair of methods: `to_save_data()` exports state as a plain Dictionary, and `from_save_data()` restores it.

```gdscript
# GameManager: simplest case, flags are already a Dictionary
func to_save_data() -> Dictionary:
    return _flags.duplicate()

func from_save_data(data: Dictionary) -> void:
    _flags = data.duplicate()
```

```gdscript
# InventoryManager: items are serialized by resource path + count
func to_save_data() -> Dictionary:
    var items_data: Array[Dictionary] = []
    for entry in _items:
        items_data.append({
            item_id = entry.item.id,
            item_path = entry.item.resource_path,
            count = entry.count,
        })
    return {gold = gold, items = items_data}

func from_save_data(data: Dictionary) -> void:
    gold = data.get("gold", 0)
    _items.clear()
    for entry in data.get("items", []):
        var item: ItemData = load(entry.item_path) as ItemData
        if item:
            _items.append({item = item, count = entry.count})
    inventory_changed.emit()
    gold_changed.emit(gold)
```

```gdscript
# QuestManager: quests are serialized as resource path arrays
func to_save_data() -> Dictionary:
    return {
        active = _active_quests.map(func(q: QuestData) -> String: return q.resource_path),
        completed = _completed_quests.map(func(q: QuestData) -> String: return q.resource_path),
        turned_in = _turned_in_quests.map(func(q: QuestData) -> String: return q.resource_path),
    }

func from_save_data(data: Dictionary) -> void:
    _active_quests.clear()
    _completed_quests.clear()
    _turned_in_quests.clear()
    for path in data.get("active", []):
        var q: QuestData = load(path) as QuestData
        if q: _active_quests.append(q)
    # ... same for completed and turned_in
```

```gdscript
# PartyManager: members are serialized with all mutable stats + equipment paths
func to_save_data() -> Dictionary:
    var members_data: Array[Dictionary] = []
    for member in members:
        members_data.append({
            id = member.id,
            path = member.resource_path,
            level = member.level,
            current_xp = member.current_xp,
            max_hp = member.max_hp,
            max_mp = member.max_mp,
            attack = member.attack,
            defense = member.defense,
            speed = member.speed,
            current_hp = member.current_hp,
            current_mp = member.current_mp,
            weapon_path = member.equipped_weapon.resource_path if member.equipped_weapon else "",
            armor_path = member.equipped_armor.resource_path if member.equipped_armor else "",
            accessory_path = member.equipped_accessory.resource_path if member.equipped_accessory else "",
        })
    return {members = members_data}
```

The pattern principle: Resources are referenced by path, not serialized by value. `ResourceLoader.load(entry.path, "", ResourceLoader.CACHE_MODE_IGNORE) as CharacterData` reloads a fresh `.tres` base definition, then saved values (level, stats, equipment) are applied on top. This keeps save files small, preserves pristine New Game data, and means editing a `.tres` file updates the base values for all future loads.

### Save Slots

Three save slots stored at `user://saves/save_1.json` through `save_3.json`.

```gdscript
# Constants in SaveManager
const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 3

# Check if a slot has a save
func slot_exists(slot: int) -> bool:
    return FileAccess.file_exists(SAVE_DIR + "save_" + str(slot) + ".json")

# Get metadata for display
func get_slot_info(slot: int) -> Dictionary:
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return {}
    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK:
        return {}
    file.close()
    var parsed: Variant = json.data
    if not parsed is Dictionary:
        return {}
    var data: Dictionary = parsed
    return {
        timestamp = data.get("timestamp", ""),
        scene_path = data.get("scene_path", ""),
    }
```

The save slot dialog uses `await` to pause execution until the player picks a slot:

```gdscript
# In the save crystal
func _activate() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    get_tree().current_scene.add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.save_game(slot)

# On the title screen
func _on_continue() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.load_game(slot)
```

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Forgetting to register an autoload in Project Settings | `Identifier "GameManager" not declared in the current scope` error | Open **Project -> Project Settings -> Autoload** and add the script path with the correct name |
| Checking flags in the wrong order in reactive dialogue | NPC always says the first-meeting line, or skips to the end | Check from most-progressed state to least-progressed: `pendant_returned` before `pendant_found` before `talked_to_fynn` before the `else` |
| Not setting `process_mode = PROCESS_MODE_ALWAYS` on shop UI | Shop opens but buttons do not respond to input | The shop pauses the game with `get_tree().paused = true`, so the shop node itself must set `process_mode = Node.PROCESS_MODE_ALWAYS` in `_ready()` |
| Equipping an item without removing it from inventory first | Item duplicated: it appears both equipped and in the inventory | First require `InventoryManager.remove_item(item)` to return true, then equip, then return the previous item to inventory |
| Saving Resource objects directly to JSON instead of their paths | JSON contains nested object data that cannot be parsed back into typed Resources | Save `resource_path` strings. On load, call `load(path) as ResourceType` to get the actual Resource |
| Modifying `_active_quests` array while iterating over it | Quest completion skips entries or throws errors | Collect newly completed quests into a separate array first, then process them after the iteration (as QuestManager does with `newly_completed`) |
| Missing `await tree.scene_changed` after `change_scene_to_file()` | Player position restoration fails because the new scene has not loaded yet | `change_scene_to_file()` is deferred. `await tree.scene_changed` waits for the new scene to be fully loaded before restoring position |
| Not emitting signals after `from_save_data()` in InventoryManager | UI displays stale data after loading a save | Call `inventory_changed.emit()` and `gold_changed.emit(gold)` at the end of `from_save_data()` so listeners update |

## Official Godot Documentation

### Core Classes

- [Node](https://docs.godotengine.org/en/stable/classes/class_node.html): base class for all autoloads (GameManager, QuestManager, PartyManager, SaveManager)
- [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html): base class for QuestData, ShopData, CharacterData, ItemData
- [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html): `change_scene_to_file()`, `paused`, `get_first_node_in_group()`, `scene_changed` signal
- [Engine](https://docs.godotengine.org/en/stable/classes/class_engine.html): `get_main_loop()` used in SaveManager to access the SceneTree

### File I/O and Serialization

- [FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html): `open()`, `store_string()`, `get_as_text()`, `file_exists()`, `close()`
- [DirAccess](https://docs.godotengine.org/en/stable/classes/class_diraccess.html): `make_dir_recursive_absolute()` for creating save directories
- [JSON](https://docs.godotengine.org/en/stable/classes/class_json.html): `stringify()`, `parse()`, `get_error_message()`
- [Time](https://docs.godotengine.org/en/stable/classes/class_time.html): `get_datetime_string_from_system()` for save timestamps

### UI Classes

- [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html): used for quest log, equipment panel, save slot dialog
- [VBoxContainer](https://docs.godotengine.org/en/stable/classes/class_vboxcontainer.html): vertical layout for item lists, quest lists, slot buttons
- [MarginContainer](https://docs.godotengine.org/en/stable/classes/class_margincontainer.html): interior padding for panels
- [Button](https://docs.godotengine.org/en/stable/classes/class_button.html): quest selection, shop items, equipment slots, save slots
- [Label](https://docs.godotengine.org/en/stable/classes/class_label.html): gold display, character names, slot labels
- [RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html): quest detail view with BBCode formatting (`[b]`, `[/b]`)
- [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html): shop UI rendered above the game world
- [Control](https://docs.godotengine.org/en/stable/classes/class_control.html): base class for all UI nodes, `grab_focus()`, `visible`

### Signals and Input

- [Signal](https://docs.godotengine.org/en/stable/classes/class_signal.html): `connect()`, `emit()`, `CONNECT_ONE_SHOT`
- [InputEvent](https://docs.godotengine.org/en/stable/classes/class_inputevent.html): `is_action_pressed()` for shop cancel input handling

### Key Tutorials

- [Saving Games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html): the official guide to save system approaches
- [Data Paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html): explains `user://` and `res://` paths
- [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html): the autoload pattern used by all managers
- [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html): custom Resource classes, `@export`, `.tres` files
- [GUI Containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html): layout for shop, equipment, and quest UIs

### GDScript

- [GDScript Basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html): `match`, `Dictionary`, `Array`, typed arrays, lambdas
- [GDScript Exports](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html): `@export`, `@export_group`, `@export_multiline`
- [Awaiting Signals](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-for-signals-or-coroutines): `await` used in shop cancel, slot selection, scene loading

## What's Next

All the core systems are built and game state persists across sessions. In **Part VI: Polish and Integration**, we add music and sound effects, build the title screen with new game and continue flows, and tie everything together into a playable demo.


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

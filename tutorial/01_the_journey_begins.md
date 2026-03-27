# Module 1: The Journey Begins

## What We're Building

By the end of this module, you'll have Godot installed, a brand new project created, and a sprite displayed on screen. It's not much to look at yet, but it's the foundation for everything that follows.

More importantly, you'll understand **how Godot thinks about games**: as trees of small, reusable building blocks called nodes, grouped into scenes. This mental model is what matters most to learn early, because every system we build in this tutorial (movement, combat, dialogue, inventory) is just a different arrangement of nodes in a scene tree.

## What is Godot?

Godot is a free, open-source game engine for 2D and 3D games. It runs on Windows, macOS, and Linux, and can export games to all of those platforms plus mobile and web. It's been in development since 2001, was open-sourced in 2014, and has grown rapidly since.

For our purposes (building a 2D JRPG), Godot is an excellent choice for three reasons:

1. **First-class 2D support.** Unlike engines that bolt 2D onto a 3D core, Godot's 2D system is purpose-built. Pixel-perfect rendering, tile maps, sprite animation, and 2D physics all work out of the box without fighting 3D abstractions.

2. **GDScript.** Godot's built-in scripting language is designed specifically for game development. If you've written Python, you'll feel at home immediately. It's tightly integrated with the editor: autocompletion, documentation, and debugging all work without extra setup.

3. **Scene system.** Godot's scene-based architecture maps naturally to JRPG design. A town is a scene. A battle screen is a scene. An NPC is a scene. A dialogue box is a scene. You compose them like building blocks, and each one is self-contained and reusable.

> **See:** [Introduction to Godot](https://docs.godotengine.org/en/stable/getting_started/introduction/introduction_to_godot.html), the official overview of the engine's capabilities and design philosophy.

## Installing Godot

Go to [godotengine.org/download](https://godotengine.org/download) and download the latest **Godot 4.x** release. This tutorial is written for Godot 4.3 or later.

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

> **Note:** `res://` is Godot's shorthand for "the root of the project folder." Every file path in Godot starts with `res://`. We'll see another path prefix later, `user://`, which points to the user's save data folder.

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

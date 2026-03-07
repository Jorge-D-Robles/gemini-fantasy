# Appendix B: Editor vs Code Workflow

One of the biggest adjustments for software engineers coming to Godot is figuring out when to use the visual editor and when to write code. In web development, you write everything — markup, styles, logic. In Godot, some tasks are dramatically easier in the editor, some must be done in code, and some require both.

This appendix gives you an honest breakdown so you stop fighting the tool.

## Editor Only

These tasks are visual by nature. Doing them in code is possible but painful, error-prone, and harder to iterate on.

### TileSet Creation and Configuration

The TileSet editor lets you define tile sources (atlas textures), set tile sizes, and configure physics layers. You click to add an atlas, drag to define tile regions, and paint collision shapes onto individual tiles.

**Why editor:** Tile sheet layout is visual. You need to see the sprite sheet to know which 16x16 region corresponds to which tile. Code cannot replace this.

### Tile Painting on TileMapLayers

The editor's tile painting tools let you select tiles from a palette and paint them onto the map. You can paint individual tiles, use the rect tool for fills, and use the bucket tool for large areas.

**Why editor:** Level design is an inherently visual process. You need to see the tiles in context, adjust their placement, and iterate quickly. Painting in code means converting pixel coordinates to atlas coordinates blind.

**Caveat:** For procedural or data-driven maps, code is better. Many JRPG projects (including the one this guide builds) define map layouts as string arrays in code and use a MapBuilder utility to place tiles programmatically. This makes maps version-controllable, testable, and reproducible without editor state.

### Collision Shape Drawing

The editor lets you draw collision shapes directly on nodes — rectangles, circles, capsules, and polygons. You see the shape overlaid on the sprite, so you can make the collision shape match the visual exactly.

**Why editor:** Collision shapes are geometric, and getting them right requires visual feedback. A foot-level rectangle for the player, a small circle for an NPC — these are easier to position when you can see them.

### AnimatedSprite2D and SpriteFrames

The SpriteFrames editor lets you create animation sequences by dragging sprite sheet regions into frame slots. You set frame count, FPS, and loop behavior visually.

**Why editor:** Sprite animations are defined by which frames play in which order. You need to see the frames to verify the animation looks right.

### Audio Bus Layout

The Audio tab in the bottom panel lets you create audio buses (Master, BGM, SFX), add effects (reverb, compression, EQ), and set volume levels. The visual routing makes it clear which bus feeds into which.

**Why editor:** Audio routing is a graph. Seeing the bus layout visually is far more intuitive than defining it in code.

### UI Layout with Containers

Godot's Container nodes (VBoxContainer, HBoxContainer, MarginContainer, GridContainer) handle layout automatically. The editor lets you drag, resize, and nest containers to build complex UI layouts with immediate visual feedback.

**Why editor:** UI layout is visual. You need to see how elements flow, how margins affect spacing, and how containers resize. The editor's 2D canvas is a WYSIWYG layout tool — similar to using a design tool alongside your CSS.

### Scene Tree Composition

Adding nodes to scenes, setting their properties, arranging the hierarchy, naming nodes — this is the editor's core strength. The Scene dock shows the tree, the Inspector shows properties, and everything updates in real time.

**Why editor:** Scene composition is Godot's equivalent of writing HTML templates. The editor is purpose-built for this.

## Code Only

These tasks are logic by nature. The editor cannot express them, and you should not try to make it.

### All Game Logic

Damage formulas, turn order calculations, AI behavior, quest state tracking, inventory management — everything that computes, decides, or transforms data belongs in GDScript.

### Data and Resource Class Definitions

Custom Resource classes (`class_name MyResource extends Resource`) define your data schema. These are always `.gd` script files.

### State Machines

State transitions, entry/exit logic, condition checking — all code. The editor can help you set up the node hierarchy (StateMachine → State children), but the behavior is pure script.

### Save and Load

JSON serialization, file I/O, state gathering, state applying — all code. The SaveManager autoload has no visual component.

### Autoload Services

Global singletons that manage game-wide state. They have no visual representation. They are scripts, registered in Project Settings.

### AI Behavior

Enemy turn selection, target priority, ability usage rules — all code. The editor cannot express "if HP < 30%, use heal; otherwise, attack the party member with the lowest defense."

### Damage Calculations and Game Math

Static utility classes with pure functions. These are the most testable part of your codebase and have zero editor involvement.

## Hybrid: Editor + Code

These tasks require both visual setup and programmatic behavior.

### TileMaps

**Editor:** Set up the TileSet (atlas sources, tile size, physics layers). For hand-crafted levels, paint tiles directly.

**Code:** For procedural or data-driven maps, define map layouts as string arrays and use a builder utility to place tiles. Set up tile properties (collision enables/disables) programmatically. Generate terrain based on noise functions.

Most JRPG projects end up using code-driven maps because they are reproducible, version-controllable, and can be generated from data files. The editor's TileSet configuration is still needed for defining the atlas sources.

### UI

**Editor:** Build the layout hierarchy with Container nodes. Set anchors, margins, minimum sizes. Position elements visually.

**Code:** Populate content at runtime (item lists, stat values, dialogue text). Handle input and navigation. Connect signals. Show/hide panels based on game state. Animate transitions.

Think of the editor as your HTML/CSS and the script as your TypeScript component class. The editor defines structure and layout; the script defines behavior and content.

### Animations

**Editor:** Create animation sequences in the SpriteFrames editor or AnimationPlayer. Define keyframes, durations, easing curves.

**Code:** Trigger animations based on game state (`sprite.play("walk_down")`). Chain animations in sequences. Control animation speed and direction. React to animation completion signals.

### .tres Files

**Editor:** The Inspector lets you edit Resource properties with type-appropriate widgets — sliders for numbers, dropdowns for enums, color pickers for colors. This is useful for tweaking values visually.

**Code:** Create Resources programmatically when you need many similar instances (test factories, procedural generation). Load Resources with `load()` or `preload()`. Access and modify properties at runtime.

For game data like enemy stats or item definitions, either approach works. The editor is nice for small numbers of Resources; code generation is better for large batches.

## Editor Efficiency Tips

**Use Ctrl+Click in the FileSystem dock** to open scripts in the built-in editor or your external editor (configurable in Editor Settings > Text Editor > External).

**Drag scenes from the FileSystem dock** directly into the Scene tree to instantiate them. This is the fastest way to add prefab entities to a level.

**Use the Inspector's resource picker** to assign Resources to exported properties. Click the property, select "Load," and navigate to the `.tres` file. This is faster than typing the path in code.

**Ctrl+S saves the scene.** Save early and often. Unlike code files, scene files can accumulate unsaved state that is easy to lose.

**The Node dock** (next to the Inspector) shows all signals on the selected node. You can connect signals to scripts by double-clicking them. This generates the connection code in the target script automatically.

**Scene > Open Scene** (Ctrl+O) is your "Go to File." Use it constantly.

**Create node shortcut:** Ctrl+A opens the "Add Node" dialog with a search field. Type the node type you want and press Enter. This is much faster than browsing the full node hierarchy.

**Editor layouts** (View > Save Layout) let you save and restore different panel arrangements. Create separate layouts for scripting (large script editor) and level editing (large 2D viewport).

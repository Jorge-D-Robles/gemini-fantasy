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

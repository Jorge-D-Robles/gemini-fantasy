# Module 5: Bringing the Player to Life

## What We Have So Far

A tiled town (Willowbrook) with collision, a camera that follows the player, and physics-based movement. But the player is still the Godot icon, sliding around without animation.

## What We're Building This Module

A fully animated player character with four-directional walk cycles, a proper state machine to manage behavior, and Y-sorting for correct depth rendering. The player will feel like a real JRPG character moving through a living world.

## Sprite Sheets and Walk Cycles

JRPG characters are typically drawn as **sprite sheets** — a single image containing all animation frames arranged in a grid. A standard 4-direction character has frames like this:

```
Row 0: Walk Down  — frame 0, 1, 2, 3
Row 1: Walk Left  — frame 0, 1, 2, 3
Row 2: Walk Right — frame 0, 1, 2, 3
Row 3: Walk Up    — frame 0, 1, 2, 3
```

Each row is a direction, each column is a frame of the walk animation. Most JRPG characters use 3-4 frames per direction.

For this tutorial, we recommend downloading a free character sprite sheet:

1. Go to [kenney.nl/assets/tiny-town](https://kenney.nl/assets/tiny-town) (the same pack from Module 4).
2. In the extracted ZIP, look in the `Tilemap/` folder for character sprites, or use the `tilemap_packed.png` sheet which contains small character tiles.

Alternatively, search [opengameart.org](https://opengameart.org) for "JRPG character sprite sheet 16x16" — you'll find many free options. Look for a sheet with **4 rows** (one per direction: down, left, right, up) and **3-4 columns** (frames per walk cycle).

> **Note:** If your sprite sheet has a different layout (e.g., 3 frames instead of 4, or rows in a different order like down/up/left/right), that's fine — just adjust the frame selection when setting up animations below. The script we write works with any 4-direction animation names.

If you can't find a sheet, you can still follow along — but you'll need to set up AnimatedSprite2D with single-frame animations. Follow the setup steps below, using the Godot `icon.svg` as your image. Create each of the 8 animations (`idle_down`, `idle_up`, etc.) with the icon as the single frame. The walk animations won't visually animate, but the state machine code will work correctly, and you can swap in real art later.

Save your sprite sheet to `res://player/player_spritesheet.png`.

## Setting Up AnimatedSprite2D

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

In Module 4, we resized the collision shape from the original 64x64 to fit tile corridors. Now that we're using an actual character sprite instead of the Godot icon, fine-tune it: set the shape's **Size** to roughly `Vector2(12, 8)` and the **CollisionShape2D** node's **Position** (under Transform) to `Vector2(0, 4)` so it covers just the character's feet. We'll discuss why this "feet-only" collision matters later in this module.

### Creating a SpriteFrames Resource

AnimatedSprite2D uses a **SpriteFrames** resource to define animations.

1. Select the `Sprite` (AnimatedSprite2D) node.
2. In the Inspector, find **Sprite Frames** and click to create a **New SpriteFrames**.
3. The SpriteFrames panel opens at the bottom of the editor.

### Adding Animations from a Sprite Sheet

In the SpriteFrames panel:

1. You'll see a `default` animation. Rename it to `idle_down`.
2. Click the **Add frames from Sprite Sheet** button (it has a grid pattern icon — hover over the buttons near the top of the SpriteFrames panel to find it).
3. Select your sprite sheet image.
4. Set the grid size to match your sheet (e.g., 4 columns × 4 rows for a 4-direction, 4-frame sheet).
5. Click the frames for the "facing down idle" pose (usually just the first frame of the down row).
6. Click **Add Frames**.

Repeat for each animation:
- `idle_down` — the standing frame facing down
- `idle_up` — standing facing up
- `idle_left` — standing facing left
- `idle_right` — standing facing right
- `walk_down` — all frames of the down walk cycle
- `walk_up` — all frames of the up walk cycle
- `walk_left` — all frames of the left walk cycle
- `walk_right` — all frames of the right walk cycle

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

For each walk animation, set the **FPS** to 8-10 (the number field at the top of the SpriteFrames panel, next to the loop toggle — the circular arrow icon). Also enable looping for walk animations by clicking that loop toggle. Idle animations can stay at the default speed since they're typically a single frame (or 2-3 frames for a breathing animation).

> **Warning:** Animation names must match **exactly** what the script expects — the code constructs names like `"walk_down"` and `"idle_left"` dynamically. If you name an animation `Walk_Down` or `walkdown`, it won't be found. Use all lowercase with an underscore: `idle_down`, `walk_up`, etc.

> **See:** [2D sprite animation](https://docs.godotengine.org/en/stable/tutorials/2d/2d_sprite_animation.html) — covers both AnimatedSprite2D and AnimationPlayer approaches to 2D animation.

> **See:** [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html) — full API reference.

### The Alternative: Sprite2D + AnimationPlayer

There's another way to animate sprites in Godot — using a regular `Sprite2D` with an `AnimationPlayer` that keyframes the `frame` property or `region_rect`. This approach is more powerful (you can animate any property), but more complex to set up.

For character walk cycles, `AnimatedSprite2D` is simpler and perfectly adequate. We'll use `AnimationPlayer` later for UI animations and battle effects where we need to animate multiple properties simultaneously.

> **See:** [AnimationPlayer](https://docs.godotengine.org/en/stable/classes/class_animationplayer.html) — for when you need to animate arbitrary properties.

## The State Machine Pattern

Right now, our player script is simple — check input, set velocity, move. But as we add features, the logic gets tangled:

- Can the player move during dialogue? (No.)
- Can the player open the inventory while walking? (Yes, but movement should stop.)
- What happens when the player interacts with an NPC? (Face the NPC, stop moving, wait for dialogue to finish.)
- Can the player move during a cutscene? (No.)

Without structure, you end up with a mess of boolean flags: `is_talking`, `is_in_menu`, `can_move`, `is_cutscene_active`. Each new feature adds another flag, and the interactions between them become impossible to reason about.

The solution is a **state machine**: the player is always in exactly one state, and each state defines what the player can and can't do.

### Our Four States

```
IDLE       — standing still, can accept input
WALK       — moving, playing walk animation
INTERACT   — talking to NPC or object, movement disabled
DISABLED   — cutscene, battle transition, or menu, movement disabled
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

The key insight: **each state is a self-contained behavior.** The IDLE state checks for movement and interact input. The WALK state plays the walk animation and moves. The INTERACT state does nothing — it waits for a signal that dialogue is finished. The DISABLED state is completely inert.

### Implementation

Replace the entire contents of `res://player/player.gd` with this state machine version:

```gdscript
extends CharacterBody2D
## The player character with state-machine-driven movement and animation.

enum State { IDLE, WALK, INTERACT, DISABLED }

@export var speed: float = 200.0

var current_state: State = State.IDLE
var facing_direction: Vector2 = Vector2.DOWN  # Vector2(0, 1) — positive Y is downward in Godot

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
    # Waiting for interaction to complete — controlled externally.


func _state_disabled() -> void:
    velocity = Vector2.ZERO
    # Completely inert — cutscene, menu, or battle transition.


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

Let's break down the key design decisions:

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

The `_direction_to_string()` function converts a Vector2 direction into "up", "down", "left", or "right" by checking which axis has the larger magnitude. This handles diagonal input gracefully — if you press right and slightly down, you face right.

### Public Methods for External Control

`set_disabled()`, `start_interaction()`, and `end_interaction()` are **public methods** that other systems call to control the player's state. The dialogue system will call `start_interaction()` when a conversation begins and `end_interaction()` when it ends. The battle system will call `set_disabled(true)` during transitions.

This keeps the state machine's logic internal while providing a clean API for the rest of the game.

> **Spiral:** We'll revisit state machines in Module 11 when we build the battle system. The battle state machine is more complex (7+ states with intricate transitions), so we'll upgrade from this enum-based approach to a **node-based** state machine. The enum approach works great for the player's 4 simple states.

## Y-Sorting: Correct Depth Ordering

In a top-down 2D game, objects lower on the screen should appear in front of objects higher on the screen. This creates the illusion of depth — the player walks "behind" a tree when they're above it, and "in front of" a tree when they're below it.

Godot handles this with **Y-sort**. When enabled on a parent node, its children are drawn sorted by their Y position — lower Y values are drawn first (behind), higher Y values are drawn last (in front).

### Setting Up Y-Sort

In the Willowbrook scene:

> **Tip:** To reparent a node, drag it in the Scene dock and drop it onto the new parent node. The node moves in the tree hierarchy. You'll use this technique in the steps below.

1. Add a new **Node2D** as a child of `Willowbrook`. Rename it to `YSortGroup`.
2. In the Inspector, find **CanvasItem → Ordering → Y Sort Enabled** and turn it **on**.
3. Drag the `Objects` TileMapLayer onto `YSortGroup` to reparent it (it becomes a child of YSortGroup instead of Willowbrook).
4. Drag the `Player` instance onto `YSortGroup` the same way.
5. Select the `Objects` TileMapLayer. In the Inspector, find **CanvasItem → Ordering → Y Sort Enabled** and turn it **on** for this node too. This is essential — without it, the individual tiles within the layer won't sort against the player. The entire layer would render as a single block, causing the player to appear always in front of or behind all objects.

Now set the Y Sort Origin for the Objects layer so tiles sort by their bottom edge:
1. With `Objects` still selected, find **Y Sort Origin** in the Inspector and set it to `16` (the tile height in pixels). This makes tiles sort based on their bottom edge rather than their top-left corner, which looks correct for trees, rocks, and buildings.

The AbovePlayer layer should **not** be Y-sorted with the player — it should always draw on top. Keep it outside the Y-sorted group, or set its Z-index higher.

> **See:** [CanvasItem](https://docs.godotengine.org/en/stable/classes/class_canvasitem.html) — the `y_sort_enabled` property and how it affects rendering order.

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

- **Shorter** than the sprite — roughly the bottom third or half. This represents the player's "feet" area.
- **Offset downward** so it aligns with the feet, not the center of the sprite.

Our values (`Vector2(12, 8)` size, `Vector2(0, 4)` offset) give the player a small collision "footprint" that feels natural. The player's head and torso can overlap with objects above, but their feet are blocked by solid tiles.

> **JRPG Pattern:** Almost every JRPG uses "feet-only" collision. It's why you can walk close to a table and it looks like you're standing at the table, not being blocked a full character-width away.

## Grid-Based vs Free Movement

We've implemented **free movement** — the player moves smoothly in any direction at any time. This is what most modern JRPGs use (and what Crystal Saga will use).

The alternative is **grid-based movement**, where the player snaps from one tile to the next in discrete steps. This is what classic JRPGs (Final Fantasy I-VI, Dragon Quest I-V, Pokemon) use.

| Aspect | Free Movement | Grid-Based |
|--------|--------------|------------|
| Feel | Smooth, modern | Crisp, retro |
| Implementation | Simpler (what we've built) | More complex (tween between grid cells) |
| Collision | Per-pixel via physics | Per-tile via grid lookup |
| NPC interaction | Distance + facing direction | Adjacent tile check |
| Map alignment | Objects can be anywhere | Everything aligns to grid |

Grid-based movement is elegant for tile-heavy games but requires a different architecture (tweening between positions, checking the grid for obstacles before moving). We're using free movement because it's more flexible and natural-feeling for our scope.

## What We've Learned

- **Sprite sheets** contain all animation frames. **AnimatedSprite2D** plays frame-based animations from a **SpriteFrames** resource.
- A **state machine** organizes player behavior into discrete states (IDLE, WALK, INTERACT, DISABLED), preventing conflicting behavior.
- The **enum + match** pattern is a clean way to implement a simple state machine.
- **Public methods** (`set_disabled`, `start_interaction`) give other systems controlled access to the state machine.
- **Y-sorting** creates correct depth ordering — lower objects appear in front.
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

We have a living player in a real town — but there's nowhere to go. In **Module 6: Connecting Worlds**, we'll build a second area (Whisperwood Forest), create exit zones that trigger scene transitions, and build our first autoload — the SceneManager — that handles fade-to-black transitions between locations.

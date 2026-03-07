# Chapter 3: Player and Movement

Your player character is the most complex component you'll build in the entire game. It handles input, physics, animation, camera control, and interaction detection — all in a single scene. If you've built a rich UI component in Angular that manages internal state, responds to user actions, and renders different visual states, the Player scene follows exactly the same architecture. The difference is that your "DOM" is a 2D physics world.

This chapter builds the complete Player scene from scratch: a walking, animating, interacting character that moves through the world with a camera following behind.

## CharacterBody2D: Your Physics-Aware Component

Godot offers several body types for 2D physics:

| Body Type | Use Case |
|-----------|----------|
| `StaticBody2D` | Walls, obstacles — doesn't move |
| `RigidBody2D` | Physics-driven objects — gravity, bounce, forces |
| `CharacterBody2D` | Player/NPC movement — you control the motion directly |

`CharacterBody2D` is the right choice for a JRPG player because *you* decide exactly where the character moves each frame. There's no gravity simulation, no bouncing — just "I pressed right, so move right." The engine handles collision detection and response, but you supply the velocity.

Think of it like this: `RigidBody2D` is a physics simulation where you apply forces and the engine decides the outcome. `CharacterBody2D` is a physics-aware component where you set the velocity directly and the engine prevents you from walking through walls.

### The Critical Setting: motion_mode

`CharacterBody2D` has a property called `motion_mode` with two options:

- **`MOTION_MODE_GROUNDED`** (default): Designed for platformers. Distinguishes between floor, ceiling, and walls. Uses `floor_max_angle` to determine what counts as a "floor." Enables `is_on_floor()`, `is_on_ceiling()`.
- **`MOTION_MODE_FLOATING`**: Designed for top-down games. No floor/ceiling concept. All collisions are treated equally — a wall is a wall regardless of which direction it faces.

**For a top-down JRPG, you must use `MOTION_MODE_FLOATING`.** If you leave the default `MOTION_MODE_GROUNDED`, your character will behave oddly when colliding with objects — the engine will try to determine which surfaces are "floors" and which are "walls" in a world that has no concept of up and down.

You can set this in the Inspector when selecting your `CharacterBody2D` node, or in code:

```gdscript
# In the .tscn file, this appears as:
motion_mode = 1  # 1 = MOTION_MODE_FLOATING
```

For our project, we set this in the `.tscn` scene file rather than in code, since it's a permanent configuration — not something that changes at runtime.

## Building the Player Scene

The Player scene has a specific node hierarchy where each child serves a distinct purpose:

```
Player (CharacterBody2D)
├── CollisionShape2D        — physics hitbox (feet area only)
├── AnimatedSprite2D         — visual sprite with walk/idle animations
├── InteractionRay (RayCast2D) — detects interactable objects ahead
└── Camera2D                 — follows the player through the world
```

### Why This Hierarchy?

Each child node is a "concern" of the player component:

- **CollisionShape2D** tells the physics engine what shape the player occupies. We make this smaller than the sprite and position it at the character's feet — this way, the player can visually overlap with objects above them (trees, walls) while still colliding correctly at foot level.
- **AnimatedSprite2D** handles all visual rendering. It cycles through sprite frames for walking and idle poses in four directions.
- **RayCast2D** is a physics query that projects a line forward from the player. When the player presses "interact," we check if the ray is hitting anything. This is how the player "talks to" NPCs or "opens" chests.
- **Camera2D** follows the player automatically. As the player moves, the camera follows, keeping the player centered on screen.

### Creating the Scene File

Here's the complete `.tscn` scene file. In Godot, you'd typically build this in the editor by adding nodes, but understanding the file format helps you reason about what the editor is doing:

```
[gd_scene load_steps=3 format=3]

[ext_resource type="Script" path="res://entities/player/player.gd" id="1_player"]

[sub_resource type="RectangleShape2D" id="RectangleShape2D_body"]
size = Vector2(12, 16)

[node name="Player" type="CharacterBody2D"]
collision_layer = 1
collision_mask = 6
motion_mode = 1
script = ExtResource("1_player")

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, 4)
shape = SubResource("RectangleShape2D_body")

[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]
texture_filter = 0
offset = Vector2(0, -14)

[node name="InteractionRay" type="RayCast2D" parent="."]
target_position = Vector2(0, 24)
collision_mask = 6
collide_with_areas = true

[node name="Camera2D" type="Camera2D" parent="."]
position_smoothing_enabled = true
position_smoothing_speed = 8.0
```

Key details:

- **`collision_layer = 1`**: The player exists on physics layer 1. Other objects check layer 1 to detect the player.
- **`collision_mask = 6`**: Binary `110` — the player detects layers 2 and 3 (tilemap walls and interactables). The player does *not* collide with layer 1 (itself or other players).
- **`motion_mode = 1`**: `MOTION_MODE_FLOATING` for top-down movement.
- **CollisionShape2D `position = (0, 4)`**: Offset down 4 pixels so the collision box sits at the character's feet, not centered on the sprite.
- **AnimatedSprite2D `offset = (0, -14)`**: Shifted up so the sprite's feet align with the collision box. This also ensures Y-sort ordering works correctly — the engine sorts by the node's Y position (feet), not the sprite's visual center.
- **`texture_filter = 0`**: Nearest-neighbor filtering to keep pixel art crisp. Without this, Godot applies bilinear filtering that blurs your carefully crafted pixels.
- **Camera2D `position_smoothing_enabled = true`**: The camera follows the player with slight lag, creating a smooth, natural feel instead of rigid 1:1 tracking.

## The Player Script

Now for the script that brings this scene to life. We'll build it section by section.

### Script Structure and Properties

```gdscript
class_name Player
extends CharacterBody2D

## Player character for overworld exploration.
## Handles 4-directional movement, facing direction, and interaction.

signal interacted_with(target: Node)

enum Facing {
	DOWN,
	UP,
	LEFT,
	RIGHT,
}

const ANIM_FPS: float = 8.0
const RAY_LENGTH: float = 24.0
const DIRECTION_NAMES: Dictionary = {
	Facing.DOWN: "down",
	Facing.UP: "up",
	Facing.LEFT: "left",
	Facing.RIGHT: "right",
}

@export var move_speed: float = 80.0
@export var run_speed: float = 140.0

var facing: Facing = Facing.DOWN
var _can_move: bool = true
var _animations_ready: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_ray: RayCast2D = $InteractionRay
@onready var camera: Camera2D = $Camera2D
```

Let's unpack the decisions here:

**`class_name Player`** — This registers "Player" as a type in the Godot editor. You can type-check against it: `var p: Player = node as Player`. It's like `export class Player` in TypeScript.

**`enum Facing`** — GDScript enums are integer-backed, just like TypeScript `const enum`. `Facing.DOWN` is `0`, `Facing.UP` is `1`, and so on. We use this instead of strings because `match` on integers is faster and typo-proof.

**`@export var move_speed`** — The `@export` annotation exposes this variable in the Godot Inspector. It's like Angular's `@Input()` — a property that can be set from outside (the editor, in this case) while having a sensible default.

**`@onready var sprite`** — `@onready` defers initialization until `_ready()` fires. This is necessary because child nodes don't exist when the script is first loaded — they're only available after the scene tree is constructed. Think of it as resolving a dependency that's only available after component initialization.

**`_can_move: bool`** — The underscore prefix is a convention for private variables. GDScript has no access modifiers, but the underscore signals "internal only" to other developers.

### Initialization

```gdscript
func _ready() -> void:
	add_to_group("player")
	_update_ray_direction()
	_setup_animations()
```

**`add_to_group("player")`** is a critical pattern. Groups are like CSS classes for nodes — any node can be in any number of groups, and you can find nodes by group from anywhere:

```gdscript
# From any other script in the game:
var player := get_tree().get_first_node_in_group("player")
```

This is loose coupling at its finest. The NPC script doesn't need a direct reference to the player node, doesn't need the player injected, doesn't even need to know the Player class. It just asks the scene tree: "give me the node in the 'player' group." If you've used Angular's dependency injection to look up services, groups serve a similar purpose — but without the DI container overhead.

### 4-Directional Input

```gdscript
func _physics_process(_delta: float) -> void:
	if not _can_move:
		velocity = Vector2.ZERO
		_play_idle()
		return

	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)

	if input_dir != Vector2.ZERO:
		_update_facing(input_dir)
		var speed := run_speed if Input.is_action_pressed("run") else move_speed
		velocity = input_dir.normalized() * speed
		_play_walk()
	else:
		velocity = Vector2.ZERO
		_play_idle()

	move_and_slide()
```

This runs every physics frame (~60 times per second). Let's break down the key parts:

**`_physics_process` vs `_process`**: Godot has two update loops. `_process(delta)` runs every render frame (variable rate). `_physics_process(delta)` runs at a fixed rate tied to the physics engine (default 60 Hz). Always use `_physics_process` for movement — it ensures consistent physics behavior regardless of frame rate. It's the same reason game physics in Unity uses `FixedUpdate`.

**`Input.get_vector()`** returns a `Vector2` constructed from four input actions. If the player holds right and up simultaneously, it returns `Vector2(1, -1)` (in Godot, Y increases downward). It handles opposing inputs gracefully — pressing left and right simultaneously returns `Vector2.ZERO`.

The input actions (`"move_left"`, `"move_right"`, etc.) are mapped in Project Settings > Input Map. Chapter 2 set these up. They abstract away the physical keys — the same action can be triggered by WASD, arrow keys, or a gamepad stick.

**`.normalized()`** is essential for diagonal movement. Without it, moving diagonally would be ~41% faster than moving cardinally (because `Vector2(1, 1).length()` is `√2 ≈ 1.414`). Normalizing ensures the vector has length 1 regardless of direction. The character moves at the same speed in all eight directions.

**`move_and_slide()`** is where physics collision happens. You set `velocity` as a property on the `CharacterBody2D`, then call `move_and_slide()`. The engine:

1. Attempts to move the body by `velocity * delta` (delta is handled internally)
2. Detects any collisions along the way
3. "Slides" the body along surfaces it hits, rather than stopping dead
4. Updates the body's position

The "slide" behavior is what makes movement feel natural. When you walk into a wall at an angle, you don't stop — you slide along it. This happens automatically.

### Walk/Run Speed Toggle

```gdscript
var speed := run_speed if Input.is_action_pressed("run") else move_speed
```

This ternary checks if the "run" input action is held. `is_action_pressed()` returns `true` for the entire duration a key is held, unlike `is_action_just_pressed()` which returns `true` only on the frame the key goes down.

The `@export` annotations on `move_speed` and `run_speed` mean you can tune these values in the Inspector without touching code — drag a slider, see the result immediately during playtesting.

### Facing Direction

```gdscript
func _update_facing(direction: Vector2) -> void:
	if absf(direction.x) > absf(direction.y):
		if direction.x > 0.0:
			facing = Facing.RIGHT
		else:
			facing = Facing.LEFT
	else:
		if direction.y > 0.0:
			facing = Facing.DOWN
		else:
			facing = Facing.UP
	_update_ray_direction()
```

This converts the continuous input vector into one of four discrete directions. We compare the absolute values of X and Y to determine the dominant axis. This creates a diamond-shaped dead zone that feels natural — if you're holding mostly right with a little bit of up, you face right.

The facing direction drives two things:
1. Which animation plays (walk_right, idle_down, etc.)
2. Where the interaction raycast points

### Interaction via RayCast2D

The player interacts with NPCs and objects using a `RayCast2D` — a line projected forward from the player that detects physics bodies in its path:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if not _can_move:
		return
	if event.is_action_pressed("interact"):
		_try_interact()
		get_viewport().set_input_as_handled()


func _try_interact() -> void:
	interaction_ray.force_raycast_update()
	if not interaction_ray.is_colliding():
		return

	var collider := interaction_ray.get_collider()
	if collider and collider.has_method("interact"):
		collider.interact()
		interacted_with.emit(collider)
```

**`_unhandled_input`** processes input events that haven't been consumed by UI or other nodes. The Godot input pipeline flows: UI nodes first (`_gui_input`), then propagates to `_unhandled_input`. This means if a dialogue box is open and consuming input, the player won't try to interact with things behind it.

**`force_raycast_update()`** recalculates the raycast immediately. Normally, raycasts update during the physics step, but we want an instant result when the player presses the interact button.

**`has_method("interact")`** is duck typing — we don't check if the collider is a specific type. Any node with an `interact()` method works. This is like checking `if ('interact' in obj)` in TypeScript. It keeps the player completely decoupled from the objects it interacts with — NPCs, chests, doors, and save points all just need an `interact()` method.

**`get_viewport().set_input_as_handled()`** stops the event from propagating further. Without this, pressing interact might trigger other input handlers down the tree.

### Updating the Ray Direction

The raycast needs to point in the direction the player is facing:

```gdscript
func _update_ray_direction() -> void:
	if not interaction_ray:
		return
	match facing:
		Facing.DOWN:
			interaction_ray.target_position = Vector2(0, RAY_LENGTH)
		Facing.UP:
			interaction_ray.target_position = Vector2(0, -RAY_LENGTH)
		Facing.LEFT:
			interaction_ray.target_position = Vector2(-RAY_LENGTH, 0)
		Facing.RIGHT:
			interaction_ray.target_position = Vector2(RAY_LENGTH, 0)
```

`target_position` is relative to the RayCast2D's own position. `RAY_LENGTH = 24.0` means the ray extends 24 pixels (1.5 tiles at 16px/tile) in the facing direction. This determines the "reach" of player interaction — how close you need to be to talk to an NPC.

## Building SpriteFrames from Sprite Sheets

Pixel art characters in JRPGs are typically stored as sprite sheets — a single PNG image containing all animation frames arranged in a grid. The player's sprite sheet looks like this:

```
┌─────────────────────────┐
│  walk0  walk1  walk2    │  row 0: facing down
│  walk0  walk1  walk2    │  row 1: facing left
│  walk0  walk1  walk2    │  row 2: facing right
│  walk0  walk1  walk2    │  row 3: facing up
└─────────────────────────┘
```

Each frame is 26x36 pixels. 3 columns x 4 rows = 12 frames total. We need to slice this sheet into individual frames and organize them into named animations.

Godot's `AnimatedSprite2D` uses a `SpriteFrames` resource to define animations. You *can* create this in the editor, but for a JRPG with many characters sharing the same sheet layout, building it in code is more maintainable:

```gdscript
const SPRITE_PATH: String = "res://assets/sprites/characters/kael_overworld.png"

func _setup_animations() -> void:
	var texture: Texture2D = load(SPRITE_PATH) as Texture2D
	if texture == null:
		push_error("Player: failed to load sprite at '%s'" % SPRITE_PATH)
		return

	var frame_w: int = texture.get_width() / 3    # 26px
	var frame_h: int = texture.get_height() / 4   # 36px

	var frames := SpriteFrames.new()
	frames.remove_animation("default")  # SpriteFrames starts with a "default" animation

	var row_map: Dictionary = {
		"down": 0,
		"left": 1,
		"right": 2,
		"up": 3,
	}
	# Bounce cycle: left foot, center, right foot, center
	var walk_cycle: Array[int] = [0, 1, 2, 1]

	for dir_name: String in row_map:
		var row: int = row_map[dir_name]

		# Walk animation (looping)
		var walk_name := "walk_%s" % dir_name
		frames.add_animation(walk_name)
		frames.set_animation_speed(walk_name, ANIM_FPS)
		frames.set_animation_loop(walk_name, true)
		for col: int in walk_cycle:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2(
				col * frame_w,
				row * frame_h,
				frame_w,
				frame_h,
			)
			frames.add_frame(walk_name, atlas)

		# Idle animation (single frame — the middle/standing pose)
		var idle_name := "idle_%s" % dir_name
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 1.0)
		frames.set_animation_loop(idle_name, false)
		var idle_atlas := AtlasTexture.new()
		idle_atlas.atlas = texture
		idle_atlas.region = Rect2(
			frame_w,        # column 1 = center/standing pose
			row * frame_h,
			frame_w,
			frame_h,
		)
		frames.add_frame(idle_name, idle_atlas)

	sprite.sprite_frames = frames
	sprite.play("idle_down")
	_animations_ready = true
```

**`AtlasTexture`** is a view into a larger texture, defined by a `region` rectangle. Rather than loading 12 separate PNG files, we load one sheet and create atlas textures that reference specific rectangles within it. This is GPU-efficient — the GPU keeps one texture in memory and renders different regions.

**The walk cycle `[0, 1, 2, 1]`** creates a bounce pattern: left-foot, standing, right-foot, standing. This is standard for JRPGs and looks more natural than a linear 0-1-2 cycle.

**`_animations_ready` guard** — Animation methods check this flag before trying to play. If the sprite sheet fails to load (e.g., file not imported yet), we skip animation gracefully instead of crashing.

### Playing Animations

```gdscript
func _play_walk() -> void:
	if not _animations_ready:
		return
	var anim_name := "walk_%s" % DIRECTION_NAMES[facing]
	if sprite.animation != anim_name:
		sprite.play(anim_name)


func _play_idle() -> void:
	if not _animations_ready:
		return
	var anim_name := "idle_%s" % DIRECTION_NAMES[facing]
	if sprite.animation != anim_name:
		sprite.play(anim_name)
```

The `if sprite.animation != anim_name` check prevents restarting the current animation every frame. Without this guard, the walk animation would reset to frame 0 sixty times per second and never actually animate.

## Camera2D: Following the Player

Because `Camera2D` is a child of the Player node, it automatically follows the player's position. No additional code is needed for basic following behavior. The scene file configures two important properties:

```
position_smoothing_enabled = true
position_smoothing_speed = 8.0
```

**Position smoothing** makes the camera lag slightly behind the player, then catch up. This creates a polished, cinematic feel. Without it, the camera is rigidly locked to the player and every pixel of movement feels jarring.

`position_smoothing_speed` controls how quickly the camera catches up. Higher values = faster catch-up = less lag. A value of `8.0` provides subtle smoothing without feeling sluggish.

### Camera Limits

For maps that are larger than the screen, you'll eventually want to set camera limits so the camera doesn't show empty space beyond the map edges:

```gdscript
func set_camera_limits(map_width: int, map_height: int) -> void:
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = map_width
	camera.limit_bottom = map_height
```

The camera will follow the player as long as doing so doesn't violate these limits. When the player approaches a map edge, the camera stops scrolling but the player keeps moving. This prevents the classic "black void beyond the map" problem.

For small maps (smaller than the viewport), you may want to simply center the camera and not follow at all. The `limit` properties handle this automatically — if all four limits define an area smaller than the viewport, the camera stays centered on that area.

## Freezing the Player

During dialogue, battles, cutscenes, or menus, the player shouldn't be able to move. The game state system (covered in Chapter 5) handles this through a signal:

```gdscript
func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_state_changed)
	_can_move = GameManager.current_state == GameManager.GameState.OVERWORLD


func set_movement_enabled(enabled: bool) -> void:
	_can_move = enabled
	if not enabled:
		velocity = Vector2.ZERO


func _on_game_state_changed(
	_old_state: GameManager.GameState,
	new_state: GameManager.GameState,
) -> void:
	set_movement_enabled(new_state == GameManager.GameState.OVERWORLD)
```

When the game enters `DIALOGUE`, `BATTLE`, `MENU`, or `CUTSCENE` state, the player freezes. When it returns to `OVERWORLD`, movement resumes. The player listens for state changes via a signal from the `GameManager` autoload — we'll build this in Chapter 5.

This pattern is like an Angular component subscribing to a global state observable:

```typescript
// Angular equivalent (conceptual)
this.gameState$.subscribe(state => {
  this.canMove = state === GameState.OVERWORLD;
});
```

## Providing Public API

The Player exposes two public methods that other systems use:

```gdscript
func set_movement_enabled(enabled: bool) -> void:
	_can_move = enabled
	if not enabled:
		velocity = Vector2.ZERO


func get_facing_direction() -> Vector2:
	match facing:
		Facing.DOWN:
			return Vector2.DOWN
		Facing.UP:
			return Vector2.UP
		Facing.LEFT:
			return Vector2.LEFT
		Facing.RIGHT:
			return Vector2.RIGHT
	return Vector2.DOWN
```

And one signal:

```gdscript
signal interacted_with(target: Node)
```

That's the Player's entire public API. Everything else is internal. Other nodes find the player through the group system:

```gdscript
var player := get_tree().get_first_node_in_group("player") as Player
if player:
	player.set_movement_enabled(false)
```

## Common Mistakes

**Collision shape too large.** If your collision box covers the entire sprite, the player can't visually overlap with anything. Characters look like they're hovering above objects instead of walking behind them. Keep the collision shape small and positioned at the feet.

**Forgetting `MOTION_MODE_FLOATING`.** The default `MOTION_MODE_GROUNDED` causes bizarre sliding behavior in top-down games because the engine tries to apply platformer logic (floor detection, wall sliding at specific angles).

**Using `_process` instead of `_physics_process`.** Movement in `_process` runs at variable frame rates and can cause jitter or inconsistent collision detection. Always use `_physics_process` for anything involving the physics engine.

**Not normalizing diagonal movement.** Moving diagonally at `Vector2(1, 1) * speed` is 41% faster than cardinal movement. Always call `.normalized()` on the input direction before multiplying by speed.

**Not guarding animation restarts.** Calling `sprite.play("walk_down")` every frame resets the animation to frame 0. Check `sprite.animation != anim_name` before playing.

**Pixel art blurring.** Godot's default texture filter is bilinear. Set `texture_filter = 0` (Nearest) on the AnimatedSprite2D, or set it globally in Project Settings > Rendering > Textures > Canvas Textures > Default Texture Filter to "Nearest."

## How It All Connects

The Player scene is instantiated inside every overworld area scene as a child of the `Entities` node. Each area scene places the Player at a specific position (or a spawn point moves it — see Chapter 5).

```
AreaScene (Node2D)
└── Entities (Node2D, y_sort_enabled=true)
    ├── Player (CharacterBody2D)
    ├── NPC1 (StaticBody2D)
    └── NPC2 (StaticBody2D)
```

The `Entities` node has `y_sort_enabled = true`, which means its children are drawn in order of their Y position. A character with a higher Y value (further down the screen) is drawn on top of characters above them. This creates the illusion of depth — when the player walks behind an NPC, the NPC occludes the player. When the player walks in front, the player is drawn on top.

This is purely a rendering concern — it doesn't affect physics or gameplay logic. Y-sort is applied by the parent `Entities` node, not by each individual entity. This is an important Godot concept: `y_sort_enabled` is inherited from `CanvasItem` (the base class for all 2D visual nodes), and it applies to the node's *children*, not the node itself.

## What's Next

The Player needs a world to walk through. Chapter 4 builds that world using TileMapLayer nodes — multi-layered tile grids that form the ground, walls, objects, and canopy of your game environments. The player's collision system, the RayCast2D interaction, and the camera limits all integrate with the world you're about to build.

---
name: add-animation
description: Set up animations for a scene — AnimatedSprite2D frame animations, AnimationPlayer keyframe animations, or AnimationTree state machines. Use when adding walk cycles, attack animations, idle animations, or UI transitions.
argument-hint: <scene-path-or-name> <animation-type> [details...]
disable-model-invocation: true
---

# Add Animation to Scene

Set up animations for: **$ARGUMENTS**

## Step 1 — Research (MANDATORY — do not skip)

**You MUST complete ALL of these before writing any code:**

1. **Call the `godot-docs` skill** for the animation classes you will use:
   ```
   activate_skill("godot-docs") # Look up AnimatedSprite2D, AnimationPlayer, AnimationTree, and Tween. I need properties, methods, signals, and code examples for adding [ANIMATION_TYPE] animations. Include sprite animation and animation tree tutorials.
   ```
2. **Read the performance best practices** (animations can be expensive):
   ```
   Read("docsbest-practices/06-performance.md")
   ```

Choose the right approach:

| Approach | When to Use | Node |
|----------|------------|------|
| **AnimatedSprite2D** | Simple frame-based sprite animations (walk, idle, attack) | AnimatedSprite2D |
| **AnimationPlayer** | Complex property animations (UI transitions, camera, multiple nodes) | AnimationPlayer |
| **AnimationTree** | State machine with blendstransitions (character with many states) | AnimationTree |
| **Tween** | One-off procedural animations (damage flash, bounce, fade) | Code-only |

## Step 2 — AnimatedSprite2D Setup (Frame Animations)

For charactersentities with sprite sheet animations:

### Script Pattern

```gdscript
@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_anim.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	_update_animation()


## Select animation based on current state and direction.
func _update_animation() -> void:
	if velocity.length() > 0.0:
		_play_directional_animation("walk")
	else:
		_play_directional_animation("idle")


## Play a directional animation (e.g., walk_down, walk_up, etc.).
func _play_directional_animation(base_name: String) -> void:
	var direction_suffix := _get_direction_suffix()
	var anim_name := base_name + "_" + direction_suffix
	if _anim.sprite_frames and _anim.sprite_frames.has_animation(anim_name):
		_anim.play(anim_name)


## Get direction suffix from velocity vector.
func _get_direction_suffix() -> String:
	if abs(velocity.x) > abs(velocity.y):
		if velocity.x > 0.0:
			return "right"
		else:
			return "left"
	else:
		if velocity.y > 0.0:
			return "down"
		else:
			return "up"


func _on_animation_finished() -> void:
	pass # Handle one-shot animations (attack, damage, etc.)
```

### Standard JRPG Character Animations

For characters, create these SpriteFrames animations:
- `idle_down`, `idle_up`, `idle_left`, `idle_right`
- `walk_down`, `walk_up`, `walk_left`, `walk_right`
- `attack_down`, `attack_up`, `attack_left`, `attack_right` (optional)
- `damage` (optional, non-directional)
- `death` (optional, non-directional)

**Note:** SpriteFrames resources must be configured in the Godot editor — Gemini cannot assign individual sprite frames from sprite sheets programmatically. Report this to the user.

## Step 3 — AnimationPlayer Setup (Property Animations)

For complex animations affecting multiple properties:

### Script Pattern

```gdscript
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_animation_player.animation_finished.connect(_on_anim_finished)


## Play an animation by name.
func play_animation(anim_name: StringName) -> void:
	if _animation_player.has_animation(anim_name):
		_animation_player.play(anim_name)


func _on_anim_finished(anim_name: StringName) -> void:
	pass
```

**Note:** AnimationPlayer tracks must be configured in the Godot editor's animation panel. Report which animations the user needs to create.

## Step 4 — Tween Animations (Procedural)

For one-off code-driven animations:

### Common Patterns

```gdscript
## Flash white on damage.
func _flash_damage() -> void:
	var tween := create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate",
			Color.RED, 0.1)
	tween.tween_property($AnimatedSprite2D, "modulate",
			Color.WHITE, 0.1)


## Bounce effect (e.g., item pickup).
func _bounce() -> void:
	var tween := create_tween()
	var start_pos := position
	tween.tween_property(self, "position:y",
			start_pos.y - 10.0, 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y",
			start_pos.y, 0.15).set_ease(Tween.EASE_IN)


## Fade in UI element.
func _fade_in(duration: float = 0.3) -> void:
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)


## Fade out and free.
func _fade_out_and_free(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(queue_free)


## Screen shake.
func _screen_shake(intensity: float = 5.0,
		duration: float = 0.3) -> void:
	var camera := get_viewport().get_camera_2d()
	if not camera:
		return
	var tween := create_tween()
	for i in int(duration / 0.05):
		var offset := Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity),
		)
		tween.tween_property(camera, "offset", offset, 0.05)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.05)
```

## Step 5 — Report

After adding animations, report:
1. Animation approach chosen and why
2. Code addedmodified
3. **Editor tasks** — what the user must do in the Godot editor:
   - Assign sprite sheet frames to SpriteFrames resource
   - Create AnimationPlayer tracks
   - Configure AnimationTree state machine
4. Animation names defined (for reference by other scripts)
5. Signals connected
6. Suggested next steps

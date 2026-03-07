# Chapter 19 — Polish and Juice

Game developers use the word "juice" to describe the small, non-functional details that make a game feel alive — the screen shake on a heavy hit, the number that floats up when you deal damage, the way a menu slides in instead of appearing instantly. None of these change the underlying systems. The battle math is the same whether damage pops up as a floating number or appears only in the log. But the difference in how the game *feels* is enormous.

If you have ever compared a wireframe prototype to a polished production app, you know this already. Animations, transitions, and micro-interactions are the difference between "this works" and "this feels good." In Angular terms, this chapter is your `@angular/animations` module and your CSS transitions — the layer that makes existing functionality satisfying to use.

## What We Are Building

- **Companion followers** that trail behind the player on the overworld
- **Scene transition effects** — fade to black, slide, and iris wipe
- **Damage popups** that float upward and fade out
- **UI animations** — sliding menus, bobbing indicators, button hover effects
- **Screen shake** for impact moments
- **Screen flash** for hit effects
- **Area name popup** that appears when entering a new zone

## Companion Followers

In most JRPGs, your party members follow behind the player character in a line. This creates a visual sense of the party as a group and makes the world feel less lonely.

The technique is simple: record the player's position history and have each follower read from that history with a delay.

### Position History Buffer

```gdscript
# entities/player/player.gd (additions)

const FOLLOWER_RECORD_INTERVAL: int = 3  # record every 3 physics frames
const POSITION_BUFFER_SIZE: int = 120

var _position_history: Array[Vector2] = []
var _frame_counter: int = 0


func _physics_process(_delta: float) -> void:
	# ... existing movement code ...

	_frame_counter += 1
	if _frame_counter % FOLLOWER_RECORD_INTERVAL == 0:
		_position_history.push_front(global_position)
		if _position_history.size() > POSITION_BUFFER_SIZE:
			_position_history.resize(POSITION_BUFFER_SIZE)
```

Every 3 physics frames, we push the player's current position onto the front of a circular buffer. The buffer holds 120 entries — at 60 FPS with recording every 3 frames, that is 6 seconds of position history.

### Follower Node

Each companion reads from the buffer at a fixed offset:

```gdscript
# entities/follower/follower.gd
extends CharacterBody2D

@export var follow_delay: int = 15  # how many buffer entries behind the player
@export var follower_index: int = 0  # 0 = first follower, 1 = second, etc.

var _player: Node2D = null
var _sprite: AnimatedSprite2D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	_sprite = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	if not _player:
		return

	var buffer: Array[Vector2] = _player._position_history
	var index: int = follow_delay * (follower_index + 1)
	if index >= buffer.size():
		return

	var target_pos: Vector2 = buffer[index]
	var direction: Vector2 = target_pos - global_position

	# Snap to target if close enough
	if direction.length() < 1.0:
		global_position = target_pos
		_sprite.play("idle_down")
		return

	global_position = target_pos
	_update_facing(direction)


func _update_facing(direction: Vector2) -> void:
	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			_sprite.play("walk_right")
		else:
			_sprite.play("walk_left")
	else:
		if direction.y > 0:
			_sprite.play("walk_down")
		else:
			_sprite.play("walk_up")
```

The `follow_delay` controls how far behind each follower trails. The first companion uses a delay of 15 (reading position from 15 entries ago), the second uses 30, and so on. This creates the signature JRPG caterpillar party.

### Spawning Followers

When a scene loads, spawn followers for each active party member after the first:

```gdscript
func _spawn_followers() -> void:
	var party := PartyManager.get_active_party()
	for i in range(1, party.size()):
		var follower := preload("res://entities/follower/follower.tscn").instantiate()
		follower.follower_index = i - 1
		follower.follow_delay = 15
		follower.global_position = player.global_position
		add_child(follower)
```

**Why not smooth interpolation?** You could lerp followers toward the target position for smoother movement. But the buffer-snapping approach has an advantage: followers trace the exact path the player walked. They follow around corners, through doorways, and along curves naturally. Lerping would cut corners and potentially clip through walls.

## Scene Transitions

In Chapter 5, you built basic scene transitions with GameManager. Now we add visual variety.

### Fade to Black

The simplest transition: a full-screen ColorRect fades from transparent to black, the scene changes, then it fades back.

```gdscript
# systems/transition_effects.gd
extends RefCounted

## Fades a ColorRect to opaque black, calls the midpoint callback, then fades back.
static func fade_to_black(
	rect: ColorRect,
	tree: SceneTree,
	duration: float,
	midpoint_callback: Callable,
) -> void:
	rect.color = Color(0, 0, 0, 0)
	rect.visible = true

	var tween := tree.create_tween()
	tween.tween_property(rect, "color:a", 1.0, duration / 2.0)
	tween.tween_callback(midpoint_callback)
	tween.tween_property(rect, "color:a", 0.0, duration / 2.0)
	tween.tween_callback(func() -> void: rect.visible = false)
```

The `midpoint_callback` is where you swap the scene. The player sees: fade to black -> instant scene change (invisible behind the black) -> fade back in. The scene change is hidden behind the opaque fade.

### Slide Transition

A horizontal slide where the old scene slides out and the new scene slides in:

```gdscript
static func slide_transition(
	rect: ColorRect,
	tree: SceneTree,
	duration: float,
	midpoint_callback: Callable,
	direction: Vector2 = Vector2.LEFT,
) -> void:
	var viewport_size: Vector2 = tree.root.get_visible_rect().size
	rect.color = Color.BLACK
	rect.visible = true
	rect.position = -direction * viewport_size

	var tween := tree.create_tween()
	tween.tween_property(rect, "position", Vector2.ZERO, duration / 2.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(midpoint_callback)
	tween.tween_property(rect, "position", direction * viewport_size, duration / 2.0) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void: rect.visible = false)
```

### Iris Wipe

A circular reveal that opens from the center — classic JRPG. This requires a shader rather than a simple ColorRect, but the concept is the same:

```glsl
// shaders/iris_wipe.gdshader
shader_type canvas_item;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5);

void fragment() {
    float dist = distance(UV, center);
    float radius = progress * 1.5;  // 1.5 to ensure full coverage at corners
    if (dist > radius) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    }
}
```

Drive the shader's `progress` uniform with a Tween:

```gdscript
static func iris_wipe(
	rect: ColorRect,
	tree: SceneTree,
	duration: float,
	midpoint_callback: Callable,
) -> void:
	rect.visible = true
	var material := rect.material as ShaderMaterial
	material.set_shader_parameter("progress", 1.0)  # start fully open

	var tween := tree.create_tween()
	# Close the iris
	tween.tween_method(
		func(val: float) -> void:
			material.set_shader_parameter("progress", val),
		1.0, 0.0, duration / 2.0,
	)
	tween.tween_callback(midpoint_callback)
	# Open the iris
	tween.tween_method(
		func(val: float) -> void:
			material.set_shader_parameter("progress", val),
		0.0, 1.0, duration / 2.0,
	)
	tween.tween_callback(func() -> void: rect.visible = false)
```

### Easing Curves

All transitions use easing curves to feel natural. A linear fade looks mechanical. `TRANS_SINE` with `EASE_IN` starts slow and accelerates — which matches how our eyes perceive comfortable motion.

Common combinations:

| Effect | Trans | Ease | Feel |
|--------|-------|------|------|
| Fade in | `TRANS_SINE` | `EASE_IN` | Gentle start, accelerating |
| Fade out | `TRANS_SINE` | `EASE_OUT` | Fast start, gentle landing |
| Bounce | `TRANS_BOUNCE` | `EASE_OUT` | Bouncy arrival |
| Menu slide | `TRANS_BACK` | `EASE_OUT` | Overshoots then settles |
| Damage popup | `TRANS_QUAD` | `EASE_OUT` | Quick launch, slow drift |

## Damage Popups

When a character takes damage or receives healing, a number floats up from their position and fades out. This is pure feedback — the battle log already records the information, but the popup makes it visceral and immediate.

```gdscript
# ui/damage_popup.gd
extends RefCounted

const UITheme = preload("res://ui/ui_theme.gd")


static func spawn(
	parent: Node,
	position: Vector2,
	amount: int,
	is_heal: bool = false,
	is_critical: bool = false,
) -> void:
	var label := Label.new()

	# Format text
	if is_heal:
		label.text = "+%d" % amount
	else:
		label.text = "%d" % amount

	# Color by type
	if is_critical:
		label.add_theme_color_override("font_color", UITheme.POPUP_CRITICAL)
	elif is_heal:
		label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.45))
	else:
		label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.25))

	# Size — criticals are larger
	var font_size: int = 14 if is_critical else 10
	label.add_theme_font_size_override("font_size", font_size)

	# Shadow for readability
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))

	# Position with slight random offset to prevent stacking
	var offset := Vector2(randf_range(-8.0, 8.0), 0.0)
	label.position = position + offset
	label.z_index = 100

	parent.add_child(label)

	# Animate: float up and fade out
	var tween := parent.create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		label, "position:y", label.position.y - 30.0, 0.8,
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8) \
		.set_delay(0.3)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)
```

### Usage in Battle

```gdscript
# In the battle action resolution:
func _apply_damage(target: Battler, amount: int, is_critical: bool) -> void:
	target.current_hp -= amount
	DamagePopup.spawn(
		target, target.global_position + Vector2(0, -10),
		amount, false, is_critical,
	)

func _apply_healing(target: Battler, amount: int) -> void:
	target.current_hp = mini(target.current_hp + amount, target.max_hp)
	DamagePopup.spawn(
		target, target.global_position + Vector2(0, -10),
		amount, true, false,
	)
```

Key details:

- **Random X offset** prevents multiple popups from stacking directly on top of each other when several enemies are hit simultaneously.
- **Delayed fade** (`set_delay(0.3)`) lets the number be fully visible for a moment before starting to disappear. Without the delay, the number starts fading immediately and is hard to read.
- **`queue_free` in tween callback** automatically removes the label after the animation completes. No cleanup needed.
- **Critical hits** use a larger font and gold color to feel impactful.

## UI Animations

### Sliding Menus

Instead of menus appearing instantly, slide them in from off-screen:

```gdscript
func _animate_menu_open(panel: Control) -> void:
	var target_x: float = panel.position.x
	panel.position.x = -panel.size.x  # start off-screen left
	panel.visible = true

	var tween := create_tween()
	tween.tween_property(panel, "position:x", target_x, 0.25) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _animate_menu_close(panel: Control) -> void:
	var tween := create_tween()
	tween.tween_property(panel, "position:x", -panel.size.x, 0.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void: panel.visible = false)
```

`TRANS_BACK` with `EASE_OUT` creates a slight overshoot effect — the panel slides past its target, then settles back. This elastic motion makes the menu feel physical rather than robotic.

### Bobbing Indicators

NPC interaction prompts and quest markers bob gently to draw attention:

```gdscript
func _start_bob_animation(node: Control) -> void:
	var tween := create_tween()
	tween.set_loops()  # infinite loop
	tween.tween_property(node, "position:y", node.position.y - 4.0, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(node, "position:y", node.position.y + 4.0, 0.6) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
```

`set_loops()` with no argument means infinite repetition. The indicator drifts up 4 pixels, then down 4 pixels, forever. `EASE_IN_OUT` makes the motion smooth at both ends — no abrupt direction changes.

### Button Hover Scale

Make buttons feel responsive by scaling slightly on focus:

```gdscript
func _setup_button_hover(btn: Button) -> void:
	btn.focus_entered.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1)
	)
	btn.focus_exited.connect(func() -> void:
		var tween := create_tween()
		tween.tween_property(btn, "scale", Vector2.ONE, 0.1)
	)
```

The scale increase is subtle — 5% — but perceptible. It gives the player tactile feedback that their input was received.

**Important:** Set the button's `pivot_offset` to its center so it scales from the middle rather than from the top-left corner:

```gdscript
btn.pivot_offset = btn.size / 2.0
```

## Screen Shake

Screen shake communicates impact — a heavy hit, an explosion, a dramatic moment. The technique is simple: rapidly offset the Camera2D position by random amounts, decreasing over time.

```gdscript
# systems/screen_effects.gd
extends RefCounted


static func shake(
	camera: Camera2D,
	intensity: float = 4.0,
	duration: float = 0.3,
) -> void:
	var original_offset: Vector2 = camera.offset
	var tween := camera.create_tween()
	var steps: int = int(duration / 0.03)  # one shake step every 30ms

	for i in steps:
		var strength: float = intensity * (1.0 - float(i) / float(steps))
		var offset := Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength),
		)
		tween.tween_property(camera, "offset", original_offset + offset, 0.03)

	# Return to original position
	tween.tween_property(camera, "offset", original_offset, 0.03)
```

The shake intensity decreases linearly with each step — strong at first, settling to nothing. This feels like a natural vibration dissipating.

### Usage

```gdscript
# On a critical hit:
var camera := get_viewport().get_camera_2d()
if camera:
	ScreenEffects.shake(camera, 6.0, 0.4)

# On a boss stomp:
ScreenEffects.shake(camera, 10.0, 0.6)
```

Higher intensity and longer duration for bigger impacts. A normal hit might use `(3.0, 0.2)`. A boss attack might use `(10.0, 0.6)`.

## Screen Flash

A brief white or red flash adds impact to hit moments. It is a full-screen ColorRect that pulses its alpha:

```gdscript
static func flash(
	rect: ColorRect,
	color: Color = Color(1, 1, 1, 0.4),
	duration: float = 0.15,
) -> void:
	rect.color = color
	rect.visible = true

	var tween := rect.create_tween()
	tween.tween_property(rect, "color:a", 0.0, duration) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(func() -> void: rect.visible = false)
```

Use a white flash for generic hits and a red flash for critical or special attacks:

```gdscript
# Normal hit
ScreenEffects.flash(flash_rect, Color(1, 1, 1, 0.3), 0.1)

# Critical hit
ScreenEffects.flash(flash_rect, Color(1, 0.3, 0.3, 0.5), 0.2)
```

The flash ColorRect should be on a high CanvasLayer (40+) so it covers everything, including other UI.

## Area Name Popup

When the player enters a new zone, the area name appears at the top of the screen, holds briefly, then fades away. We built the foundation in Chapter 18's HUD section. Here is the full animated version:

```gdscript
func _show_area_name(area_name: String) -> void:
	_area_name_popup.text = area_name
	_area_name_popup.position.y = -30  # start above screen

	if _area_popup_tween and _area_popup_tween.is_valid():
		_area_popup_tween.kill()

	_area_popup_tween = create_tween()
	# Slide down into view
	_area_popup_tween.tween_property(
		_area_name_popup, "position:y", 40.0, 0.4,
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Fade in simultaneously
	_area_popup_tween.parallel().tween_property(
		_area_name_popup, "modulate:a", 1.0, 0.3,
	)
	# Hold for 2 seconds
	_area_popup_tween.tween_interval(2.0)
	# Fade out
	_area_popup_tween.tween_property(
		_area_name_popup, "modulate:a", 0.0, 0.5,
	)
```

Key refinement: we **kill any existing tween** before starting a new one. If the player transitions between zones rapidly, the old animation is cancelled cleanly instead of fighting with the new one.

The `parallel()` method on a specific tween step makes that step run at the same time as the previous one. Here, the fade-in runs alongside the slide-down for a combined entrance effect.

## Putting It All Together — The Juice Stack

Here is how all the polish effects layer during a single battle attack:

1. Player selects "Attack" -> **UI SFX** plays (click sound)
2. Target selected -> **target highlight** (modulate tint)
3. Attack animation plays -> **screen shake** (camera offset)
4. Damage is dealt -> **damage popup** floats up from target
5. If critical -> **screen flash** (white pulse) + **larger popup** in gold
6. Battle log updates -> **scrolling text** with colored BBCode
7. Party status updates -> **HP bar** smoothly tweens to new value
8. Turn ends -> **turn order display** updates

Each effect is independent. Screen shake does not know about damage popups. The battle log does not know about screen flash. They all respond to the same event (damage dealt) through signals or direct calls. The layered result is greater than the sum of its parts.

## The Tween Cheat Sheet

Since Tweens are the workhorse of all polish effects, here is a reference:

```gdscript
# Basic property animation
var tween := create_tween()
tween.tween_property(node, "position:x", 100.0, 0.5)

# Chain steps (sequential)
tween.tween_property(node, "modulate:a", 1.0, 0.3)
tween.tween_interval(1.0)  # wait 1 second
tween.tween_property(node, "modulate:a", 0.0, 0.3)

# Parallel steps (simultaneous)
tween.set_parallel(true)
tween.tween_property(node, "position:x", 100.0, 0.5)
tween.tween_property(node, "modulate:a", 0.0, 0.5)
tween.set_parallel(false)  # back to sequential

# Single parallel step
tween.tween_property(node, "position:x", 100.0, 0.5)
tween.parallel().tween_property(node, "modulate:a", 1.0, 0.3)

# Callbacks
tween.tween_callback(node.queue_free)
tween.tween_callback(func() -> void: node.visible = false)

# Easing
tween.tween_property(node, "position", target, 0.5) \
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# Looping
tween.set_loops(3)   # repeat 3 times
tween.set_loops()    # infinite

# Custom value animation
tween.tween_method(
	func(val: float) -> void: material.set_shader_parameter("progress", val),
	0.0, 1.0, 0.5,
)
```

### Killing and Replacing Tweens

Always kill existing tweens before starting new ones on the same property. Otherwise tweens fight each other:

```gdscript
var _current_tween: Tween = null

func _animate(node: Node) -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_current_tween = create_tween()
	_current_tween.tween_property(node, "position:y", 100.0, 0.5)
```

## How It Connects

- **AudioManager (Ch 17):** SFX plays alongside visual effects — a hit sound pairs with screen shake and damage popup
- **UI (Ch 18):** Menus now animate in/out instead of appearing instantly. HUD popups use the toast pattern with tweened fade
- **BattleManager (Ch 10-12):** Battle resolution triggers damage popups, screen shake, and flash effects through direct calls
- **GameManager (Ch 5):** Scene transitions use the improved fade/slide/iris effects
- **Player (Ch 3):** Position history buffer feeds the companion follower system

## Common Mistakes

**Tweening a property that another tween is already animating.** Two tweens animating the same property fight each other, causing jittering. Always kill the old tween before starting a new one.

**Making animations too long.** Polish should enhance, not delay. A 0.3-second fade is perceptible. A 2-second fade is tedious. Keep transition animations under 0.5 seconds. Hold durations (for area name popups) can be longer, but the actual motion should be quick.

**Over-shaking.** Screen shake is powerful — too much of it causes nausea and annoyance. Reserve strong shake (intensity > 8) for boss attacks and critical moments. Normal hits should use subtle shake (2-4) or none at all.

**Forgetting to clean up tweens in `_exit_tree`.** If a node is freed while a tween is still running, the tween tries to access a freed object and produces errors. Kill active tweens when the node exits the tree:

```gdscript
func _exit_tree() -> void:
	if _area_popup_tween and _area_popup_tween.is_valid():
		_area_popup_tween.kill()
```

**Making every single thing animate.** Not everything needs juice. Opening your inventory does not need a bounce effect. Damage numbers need to be readable before they are flashy. Start with the high-impact moments (battle hits, scene transitions, major UI events) and add more only if the game feels too static.

## What Is Next

The game looks good, sounds good, and feels good. But how do you know it *works* correctly? In the next chapter, we build a test suite using GUT (Godot Unit Testing) — writing automated tests for battle math, inventory logic, quest state, and save/load serialization. You already know how to write tests from your engineering background; we just need to translate that knowledge into Godot's testing framework.

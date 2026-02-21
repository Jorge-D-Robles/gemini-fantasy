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

const RAY_LENGTH: float = 24.0
const ANIM_FPS: float = 8.0
const SPRITE_PATH: String = "res://assets/sprites/characters/kael_overworld.png"
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


func _ready() -> void:
	add_to_group("player")
	GameManager.game_state_changed.connect(_on_game_state_changed)
	_can_move = GameManager.current_state == GameManager.GameState.OVERWORLD
	_update_ray_direction()
	_setup_animations()


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
	_update_interaction_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not _can_move:
		return
	if event.is_action_pressed("interact"):
		_try_interact()
		get_viewport().set_input_as_handled()


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


func set_movement_enabled(enabled: bool) -> void:
	_can_move = enabled
	if not enabled:
		velocity = Vector2.ZERO
		var hud := get_node_or_null("/root/UILayer/HUD")
		if hud:
			hud.hide_interaction_prompt()


func _setup_animations() -> void:
	var texture: Texture2D = load(SPRITE_PATH) as Texture2D
	if texture == null:
		push_error("Player: failed to load '%s' — reopen Godot editor to import" % SPRITE_PATH)
		return

	# kael_overworld.png is a single-character sprite sheet: 144x192 px.
	# Layout: 3 walk columns x 4 direction rows.
	# Frame size: 144/3 = 48 x 192/4 = 48 px.
	var frame_w: int = texture.get_width() / 3
	var frame_h: int = texture.get_height() / 4

	var frames := SpriteFrames.new()
	frames.remove_animation("default")

	# Row order within each character's area: down=0, left=1, right=2, up=3
	var row_map: Dictionary = {
		"down": 0,
		"left": 1,
		"right": 2,
		"up": 3,
	}
	var walk_cycle: Array[int] = [0, 1, 2, 1]

	for dir_name: String in row_map:
		var row: int = row_map[dir_name]

		# Walk animation (looping bounce cycle: 0, 1, 2, 1)
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

		# Idle animation (single frame — middle column, index 1)
		var idle_name := "idle_%s" % dir_name
		frames.add_animation(idle_name)
		frames.set_animation_speed(idle_name, 1.0)
		frames.set_animation_loop(idle_name, false)
		var idle_atlas := AtlasTexture.new()
		idle_atlas.atlas = texture
		idle_atlas.region = Rect2(
			frame_w,
			row * frame_h,
			frame_w,
			frame_h,
		)
		frames.add_frame(idle_name, idle_atlas)

	sprite.sprite_frames = frames
	sprite.play("idle_down")
	_animations_ready = true


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


func _try_interact() -> void:
	interaction_ray.force_raycast_update()
	if not interaction_ray.is_colliding():
		return

	var collider := interaction_ray.get_collider()
	if collider and collider.has_method("interact"):
		collider.interact()
		interacted_with.emit(collider)
		var bus := get_node_or_null("/root/EventBus")
		if bus:
			bus.emit_player_interacted(collider)


func _update_interaction_prompt() -> void:
	var hud := get_node_or_null("/root/UILayer/HUD")
	if not hud:
		return
	if interaction_ray.is_colliding():
		var collider := interaction_ray.get_collider()
		if collider and collider.has_method("interact"):
			hud.show_interaction_prompt(InteractionHint.compute_interaction_hint_text("interact"))
			return
	hud.hide_interaction_prompt()


func _on_game_state_changed(
	_old_state: GameManager.GameState,
	new_state: GameManager.GameState,
) -> void:
	set_movement_enabled(new_state == GameManager.GameState.OVERWORLD)

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
const WALK_CYCLE: Array[int] = [0, 1, 2, 1]
const IDLE_FRAMES: Dictionary = {
	Facing.DOWN: 1,
	Facing.UP: 10,
	Facing.LEFT: 4,
	Facing.RIGHT: 7,
}
const ROW_OFFSET: Dictionary = {
	Facing.DOWN: 0,
	Facing.UP: 9,
	Facing.LEFT: 3,
	Facing.RIGHT: 6,
}

@export var move_speed: float = 80.0
@export var run_speed: float = 140.0

var facing: Facing = Facing.DOWN
var _can_move: bool = true
var _anim_timer: float = 0.0
var _anim_step: int = 0

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_ray: RayCast2D = $InteractionRay
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	add_to_group("player")
	GameManager.game_state_changed.connect(_on_game_state_changed)
	_update_ray_direction()


func _physics_process(delta: float) -> void:
	if not _can_move:
		velocity = Vector2.ZERO
		_set_idle_frame()
		return

	var input_dir := Input.get_vector(
		"move_left", "move_right", "move_up", "move_down"
	)

	if input_dir != Vector2.ZERO:
		_update_facing(input_dir)
		var speed := run_speed if Input.is_action_pressed("run") else move_speed
		velocity = input_dir.normalized() * speed
		_advance_walk_animation(delta)
	else:
		velocity = Vector2.ZERO
		_set_idle_frame()

	move_and_slide()


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


func _advance_walk_animation(delta: float) -> void:
	_anim_timer += delta
	var frame_duration := 1.0 / ANIM_FPS
	if _anim_timer >= frame_duration:
		_anim_timer -= frame_duration
		_anim_step = (_anim_step + 1) % WALK_CYCLE.size()
	sprite.frame = ROW_OFFSET[facing] + WALK_CYCLE[_anim_step]


func _set_idle_frame() -> void:
	_anim_timer = 0.0
	_anim_step = 0
	sprite.frame = IDLE_FRAMES[facing]


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


func _on_game_state_changed(
	_old_state: GameManager.GameState,
	new_state: GameManager.GameState,
) -> void:
	set_movement_enabled(new_state == GameManager.GameState.OVERWORLD)

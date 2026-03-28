extends CharacterBody2D
## The player character with state-machine-driven movement and animation.

enum State { IDLE, WALK, INTERACT, DISABLED }

@export var speed: float = 200.0

var current_state: State = State.IDLE
var facing_direction: Vector2 = Vector2.DOWN

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


func _state_disabled() -> void:
	velocity = Vector2.ZERO


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
	if sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)


func _direction_to_string(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	else:
		return "down" if direction.y >= 0 else "up"


func set_disabled(disabled: bool) -> void:
	if disabled:
		_change_state(State.DISABLED)
	else:
		_change_state(State.IDLE)


func start_interaction() -> void:
	_change_state(State.INTERACT)


func end_interaction() -> void:
	_change_state(State.IDLE)

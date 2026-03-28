extends CharacterBody2D
## A non-player character that can be interacted with.

signal interacted(npc: CharacterBody2D)

@export var npc_data: NPCData

var _player_in_range: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _interaction_prompt: Label = $InteractionPrompt
@onready var _interaction_zone: Area2D = $InteractionZone


func _ready() -> void:
	_interaction_zone.body_entered.connect(_on_player_entered)
	_interaction_zone.body_exited.connect(_on_player_exited)
	_interaction_prompt.visible = false
	if npc_data:
		_apply_npc_data()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range:
		return
	if event.is_action_pressed("interact"):
		_face_player()
		get_viewport().set_input_as_handled()
		interacted.emit(self)


func _apply_npc_data() -> void:
	if npc_data.sprite_frames:
		_sprite.sprite_frames = npc_data.sprite_frames
	var dir_name := _direction_to_string(npc_data.facing_direction)
	var idle_anim := "idle_" + dir_name
	if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
		_sprite.play(idle_anim)


func _face_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var direction: Vector2 = (player.global_position - global_position).normalized()
	var dir_name := _direction_to_string(direction)
	var idle_anim := "idle_" + dir_name
	if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
		_sprite.play(idle_anim)


func _direction_to_string(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	else:
		return "down" if direction.y >= 0 else "up"


func _on_player_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_interaction_prompt.visible = true


func _on_player_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_interaction_prompt.visible = false

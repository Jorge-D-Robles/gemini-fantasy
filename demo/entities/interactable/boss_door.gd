extends StaticBody2D
## A locked door that opens when the player has the right item.

@export var required_item_id: String = ""
@export var unlock_message: String = "The door is locked."
@export var open_message: String = "The door opens!"

var is_unlocked: bool = false
var _player_in_range: bool = false

@onready var _interaction_zone: Area2D = $InteractionZone
@onready var _interaction_prompt: Label = $InteractionPrompt


func _ready() -> void:
	_interaction_zone.body_entered.connect(_on_body_entered)
	_interaction_zone.body_exited.connect(_on_body_exited)
	_interaction_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or is_unlocked:
		return
	if event.is_action_pressed("interact"):
		_try_open()
		get_viewport().set_input_as_handled()


func _try_open() -> void:
	if required_item_id.is_empty() or InventoryManager.has_item(required_item_id):
		is_unlocked = true
		print(open_message)
		queue_free()
	else:
		print(unlock_message)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_interaction_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_interaction_prompt.visible = false

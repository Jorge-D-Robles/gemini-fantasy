extends StaticBody2D
## A treasure chest that gives the player an item when opened.

signal opened

@export var item: ItemData
@export var item_count: int = 1
@export var chest_id: String = ""

var is_opened: bool = false
var _player_in_range: bool = false

@onready var _sprite: Sprite2D = $Sprite
@onready var _prompt: Label = $InteractionPrompt
@onready var _zone: Area2D = $InteractionZone


func _ready() -> void:
	_zone.body_entered.connect(_on_body_entered)
	_zone.body_exited.connect(_on_body_exited)
	_prompt.visible = false
	add_to_group("interactables")


func _unhandled_input(event: InputEvent) -> void:
	if not _player_in_range or is_opened:
		return
	if event.is_action_pressed("interact"):
		_open()
		get_viewport().set_input_as_handled()


func _open() -> void:
	is_opened = true
	_prompt.visible = false
	if item:
		InventoryManager.add_item(item, item_count)
		print("Found: " + item.display_name + " x" + str(item_count))
	opened.emit()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_opened:
		_player_in_range = true
		_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_prompt.visible = false

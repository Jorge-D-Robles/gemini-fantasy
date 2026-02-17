class_name Interactable
extends StaticBody2D

## Generic interactable object. Delegates behavior to an InteractionStrategy
## resource (sign, chest, save point, item pickup, door, etc.).

signal interacted

@export var strategy: InteractionStrategy
@export var one_time: bool = true

var has_been_used: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	add_to_group("interactables")
	if strategy == null:
		push_warning("Interactable '%s' has no strategy assigned." % name)


func interact() -> void:
	if one_time and has_been_used:
		return
	if strategy == null:
		return

	strategy.execute(self)
	interacted.emit()
	var bus := get_node_or_null("/root/EventBus")
	if bus:
		bus.emit_interactable_used(name)

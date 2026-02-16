class_name Interactable
extends StaticBody2D

## Generic interactable object. Supports chests, signs, save points,
## item pickups, and doors via the interactable_type export.

signal interacted

enum Type {
	CHEST,
	SIGN,
	SAVE_POINT,
	ITEM_PICKUP,
	DOOR,
}

@export var interactable_type: Type = Type.SIGN
@export var interaction_text: String = ""
@export var item_id: String = ""
@export var one_time: bool = true
@export var target_scene: String = ""
@export var spawn_point: String = ""

var has_been_used: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	add_to_group("interactables")


func interact() -> void:
	if one_time and has_been_used:
		return

	match interactable_type:
		Type.CHEST:
			_interact_chest()
		Type.SIGN:
			_interact_sign()
		Type.SAVE_POINT:
			_interact_save_point()
		Type.ITEM_PICKUP:
			_interact_item_pickup()
		Type.DOOR:
			_interact_door()

	interacted.emit()


func _interact_chest() -> void:
	has_been_used = true
	var lines: Array[Dictionary] = [{
		"speaker": "",
		"text": interaction_text if not interaction_text.is_empty() else "Obtained " + item_id + "!",
	}]
	DialogueManager.start_dialogue(lines)


func _interact_sign() -> void:
	if interaction_text.is_empty():
		return
	var lines: Array[Dictionary] = [{
		"speaker": "",
		"text": interaction_text,
	}]
	DialogueManager.start_dialogue(lines)


func _interact_save_point() -> void:
	var lines: Array[Dictionary] = [{
		"speaker": "",
		"text": "Progress saved.",
	}]
	DialogueManager.start_dialogue(lines)


func _interact_item_pickup() -> void:
	has_been_used = true
	var lines: Array[Dictionary] = [{
		"speaker": "",
		"text": interaction_text if not interaction_text.is_empty() else "Picked up " + item_id + "!",
	}]
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended
	queue_free()


func _interact_door() -> void:
	if target_scene.is_empty():
		return
	GameManager.change_scene(target_scene, GameManager.FADE_DURATION, spawn_point)

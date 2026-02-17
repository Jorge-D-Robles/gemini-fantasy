class_name NPC
extends StaticBody2D

## Base NPC scene. Supports dialogue via DialogueManager
## and optionally faces the player on interaction.

signal interaction_started
signal interaction_ended

@export var npc_name: String = ""
@export var dialogue_lines: Array[String] = []
@export var portrait_path: String = ""
@export var face_player: bool = true

var _is_talking: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	add_to_group("npcs")


func interact() -> void:
	if dialogue_lines.is_empty():
		return
	if _is_talking:
		return

	if face_player:
		_face_toward_player()

	_is_talking = true
	interaction_started.emit()
	var bus := get_node_or_null("/root/EventBus")
	if bus:
		bus.emit_npc_talked_to(npc_name)

	var lines: Array[DialogueLine] = []
	var portrait: Texture2D = null
	if not portrait_path.is_empty():
		portrait = load(portrait_path) as Texture2D
		if portrait == null:
			push_warning("NPC '%s': portrait failed to load '%s'" % [npc_name, portrait_path])

	for line_text in dialogue_lines:
		lines.append(DialogueLine.create(npc_name, line_text, portrait))

	DialogueManager.dialogue_ended.connect(_on_dialogue_ended, CONNECT_ONE_SHOT)
	DialogueManager.start_dialogue(lines)


func _face_toward_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dir: Vector2 = (player.global_position - global_position).normalized()
	if absf(dir.x) > absf(dir.y):
		sprite.flip_h = dir.x < 0.0
	# Vertical facing would require additional sprite frames;
	# horizontal flip is the common JRPG approach for a placeholder.


func _on_dialogue_ended() -> void:
	_is_talking = false
	interaction_ended.emit()
	var bus := get_node_or_null("/root/EventBus")
	if bus:
		bus.emit_npc_interaction_ended(npc_name)

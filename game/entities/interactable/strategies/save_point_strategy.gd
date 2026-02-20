class_name SavePointStrategy
extends InteractionStrategy

## Saves the game and displays a confirmation message.

@export var text: String = "Progress saved."
@export var fail_text: String = "Could not save."


func execute(owner: Node) -> void:
	var scene_path := _get_current_scene_path(owner)
	var player_pos := _get_player_position(owner)
	var equip_mgr: Node = owner.get_node_or_null(
		"/root/EquipmentManager"
	)
	var quest_mgr: Node = owner.get_node_or_null(
		"/root/QuestManager"
	)
	var echo_mgr: Node = owner.get_node_or_null(
		"/root/EchoManager"
	)
	var ok: bool = SaveManager.save_game(
		0,
		PartyManager, InventoryManager, EventFlags,
		scene_path, player_pos, equip_mgr, quest_mgr,
		GameManager.playtime_seconds, echo_mgr,
	)
	var msg: String = text if ok else fail_text
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", msg),
	]
	DialogueManager.start_dialogue(lines)


func _get_current_scene_path(owner: Node) -> String:
	var scene := owner.get_tree().current_scene
	if scene:
		return scene.scene_file_path
	return ""


func _get_player_position(owner: Node) -> Vector2:
	var players := owner.get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		return players[0].global_position
	return Vector2.ZERO

extends Node
## Handles saving and loading game state to JSON files. Autoload as SaveManager.

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 3


func save_game(slot: int) -> bool:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

	var save_data: Dictionary = {
		version = 1,
		timestamp = Time.get_datetime_string_from_system(),
		scene_path = "",
		player_position = {x = 0.0, y = 0.0},
		game_flags = {},
		inventory = {},
		party = {},
		quests = {},
	}

	save_data.game_flags = GameManager.to_save_data()
	save_data.inventory = InventoryManager.to_save_data()
	save_data.party = PartyManager.to_save_data()
	save_data.quests = QuestManager.to_save_data()

	var tree := Engine.get_main_loop() as SceneTree
	if tree and tree.current_scene:
		save_data.scene_path = tree.current_scene.scene_file_path
	var player := tree.get_first_node_in_group("player") if tree else null
	if player:
		save_data.player_position = {
			x = player.global_position.x,
			y = player.global_position.y,
		}

	var path := SAVE_DIR + "save_" + str(slot) + ".json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: failed to open " + path + " for writing")
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("Game saved to slot " + str(slot))
	return true


func load_game(slot: int) -> bool:
	var path := SAVE_DIR + "save_" + str(slot) + ".json"
	if not FileAccess.file_exists(path):
		push_error("SaveManager: save file not found: " + path)
		return false

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("SaveManager: failed to open " + path)
		return false

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_string) != OK:
		push_error("SaveManager: JSON parse error: " + json.get_error_message())
		return false

	var save_data: Dictionary = json.data

	GameManager.from_save_data(save_data.get("game_flags", {}))
	InventoryManager.from_save_data(save_data.get("inventory", {}))
	PartyManager.from_save_data(save_data.get("party", {}))
	QuestManager.from_save_data(save_data.get("quests", {}))

	var scene_path: String = save_data.get("scene_path", "")
	if scene_path:
		var tree := Engine.get_main_loop() as SceneTree
		tree.change_scene_to_file(scene_path)
		await tree.tree_changed

		var pos_data: Dictionary = save_data.get("player_position", {})
		var player := tree.get_first_node_in_group("player")
		if player:
			player.global_position = Vector2(
				pos_data.get("x", 0.0),
				pos_data.get("y", 0.0),
			)

	print("Game loaded from slot " + str(slot))
	return true


func get_slot_info(slot: int) -> Dictionary:
	var path := SAVE_DIR + "save_" + str(slot) + ".json"
	if not FileAccess.file_exists(path):
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}
	file.close()

	var data: Dictionary = json.data
	return {
		timestamp = data.get("timestamp", ""),
		scene_path = data.get("scene_path", ""),
	}


func slot_exists(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_DIR + "save_" + str(slot) + ".json")

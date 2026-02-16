extends Node

## Manages saving and loading game state to JSON files.
## Serializes party, inventory, event flags, and player position.

const SAVE_DIR: String = "user://saves/"
const SAVE_VERSION: int = 1

var _pending_position: Vector2 = Vector2.ZERO
var _has_pending_position: bool = false


func set_pending_position(pos: Vector2) -> void:
	_pending_position = pos
	_has_pending_position = true
	if not GameManager.scene_changed.is_connected(
		_on_scene_changed_restore_position,
	):
		GameManager.scene_changed.connect(
			_on_scene_changed_restore_position,
			CONNECT_ONE_SHOT,
		)


func get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_%d.json" % slot


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))


func save_game(
	slot: int,
	party: Node,
	inventory: Node,
	flags: Node,
	scene_path: String,
	player_position: Vector2,
) -> bool:
	var data := gather_save_data(
		party, inventory, flags,
		scene_path, player_position,
	)
	return _write_save_file(slot, data)


func load_save_data(slot: int) -> Dictionary:
	var path := get_save_path(slot)
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error(
			"SaveManager: cannot open '%s' — %s"
			% [path, error_string(FileAccess.get_open_error())]
		)
		return {}
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error(
			"SaveManager: JSON parse error in '%s' — %s"
			% [path, json.get_error_message()]
		)
		return {}
	return json.data as Dictionary


func apply_save_data(
	data: Dictionary,
	party: Node,
	inventory: Node,
	flags: Node,
) -> void:
	_apply_inventory(data.get("inventory", {}), inventory)
	_apply_flags(data.get("event_flags", {}), flags)
	_apply_character_state(data.get("character_state", {}), party)


func delete_save(slot: int) -> void:
	var path := get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func gather_save_data(
	party: Node,
	inventory: Node,
	flags: Node,
	scene_path: String,
	player_position: Vector2,
) -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"scene_path": scene_path,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y,
		},
		"party": _serialize_party(party),
		"character_state": _serialize_character_state(party),
		"event_flags": flags.get_all_flags(),
		"inventory": _serialize_inventory(inventory),
	}


func _serialize_party(party: Node) -> Dictionary:
	var active_ids: Array[String] = []
	var reserve_ids: Array[String] = []
	for member in party.active_party:
		var bd := member as BattlerData
		if bd:
			active_ids.append(String(bd.id))
	for member in party.reserve_party:
		var bd := member as BattlerData
		if bd:
			reserve_ids.append(String(bd.id))
	return {"active": active_ids, "reserve": reserve_ids}


func _serialize_character_state(party: Node) -> Dictionary:
	var state := {}
	for member in party.roster:
		var bd := member as BattlerData
		if not bd:
			continue
		var char_id := String(bd.id)
		var runtime: Dictionary = party.get_runtime_state(bd.id)
		var entry := {
			"current_hp": runtime.get("current_hp", bd.max_hp),
			"current_ee": runtime.get("current_ee", bd.max_ee),
		}
		var cd := member as CharacterData
		if cd:
			entry["level"] = cd.level
			entry["current_xp"] = cd.current_xp
		else:
			entry["level"] = 1
			entry["current_xp"] = 0
		state[char_id] = entry
	return state


func _serialize_inventory(inventory: Node) -> Dictionary:
	var items := {}
	for key: StringName in inventory.get_all_items():
		items[String(key)] = inventory.get_item_count(key)
	return {
		"gold": inventory.gold,
		"items": items,
	}


func _write_save_file(slot: int, data: Dictionary) -> bool:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var path := get_save_path(slot)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error(
			"SaveManager: cannot write '%s' — %s"
			% [path, error_string(FileAccess.get_open_error())]
		)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


func _apply_inventory(
	inv_data: Dictionary,
	inventory: Node,
) -> void:
	# Clear existing inventory
	for item_id: StringName in inventory.get_all_items():
		var count: int = inventory.get_item_count(item_id)
		inventory.remove_item(item_id, count)
	inventory.gold = inv_data.get("gold", 0)
	var items: Dictionary = inv_data.get("items", {})
	for item_id: String in items:
		inventory.add_item(StringName(item_id), int(items[item_id]))


func _apply_flags(
	flags_data: Dictionary,
	flags: Node,
) -> void:
	flags.load_flags(flags_data)


func _apply_character_state(
	state_data: Dictionary,
	party: Node,
) -> void:
	for char_id: String in state_data:
		var entry: Dictionary = state_data[char_id]
		var sn := StringName(char_id)
		var hp: int = int(entry.get("current_hp", 0))
		var ee: int = int(entry.get("current_ee", 0))
		party.set_hp(sn, hp)
		party.set_ee(sn, ee)
		# Restore level/xp if character is a CharacterData
		var level: int = int(entry.get("level", 1))
		var xp: int = int(entry.get("current_xp", 0))
		for member in party.roster:
			var cd := member as CharacterData
			if cd and cd.id == sn:
				cd.level = level
				cd.current_xp = xp
				break


func _on_scene_changed_restore_position(
	_scene_path: String,
) -> void:
	if not _has_pending_position:
		return
	_has_pending_position = false
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = _pending_position

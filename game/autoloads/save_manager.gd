extends Node

## Manages saving and loading game state to JSON files.
## Serializes party, inventory, event flags, and player position.
## Supports autosave on scene change (slot 0) and manual saves (slots 1-3).

signal autosave_completed(success: bool)

const SAVE_DIR: String = "user://saves/"
const SAVE_VERSION: int = 1
const AUTOSAVE_SLOT: int = 0
const MAX_MANUAL_SLOTS: int = 3
const TOTAL_SLOTS: int = 4

const _AUTOSAVE_EXCLUDED_SCENES: Array[String] = [
	"res://ui/title_screen/title_screen.tscn",
	"res://ui/demo_end_screen/demo_end_screen.tscn",
]

const _AREA_NAMES: Dictionary = {
	"res://scenes/roothollow/roothollow.tscn": "Roothollow",
	"res://scenes/verdant_forest/verdant_forest.tscn": "Verdant Forest",
	"res://scenes/overgrown_ruins/overgrown_ruins.tscn": "Overgrown Ruins",
	"res://scenes/overgrown_capital/overgrown_capital.tscn": "Overgrown Capital",
	"res://scenes/prismfall_approach/prismfall_approach.tscn": "Prismfall Approach",
}

var _pending_position: Vector2 = Vector2.ZERO
var _has_pending_position: bool = false


func _ready() -> void:
	GameManager.scene_changed.connect(_on_scene_changed_for_autosave)


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


func save_game(  # gdlint:ignore = function-arguments-number
	slot: int,
	party: Node,
	inventory: Node,
	flags: Node,
	scene_path: String,
	player_position: Vector2,
	equipment: Node = null,
	quests: Node = null,
	playtime: float = 0.0,
	echo_mgr: Node = null,
	rep_mgr: Node = null,
) -> bool:
	var data := gather_save_data(
		party, inventory, flags,
		scene_path, player_position, equipment, quests,
		playtime, echo_mgr, rep_mgr,
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
	equipment: Node = null,
	quests: Node = null,
	echo_mgr: Node = null,
	rep_mgr: Node = null,
) -> void:
	_apply_inventory(data.get("inventory", {}), inventory)
	_apply_flags(data.get("event_flags", {}), flags)
	_apply_character_state(data.get("character_state", {}), party)
	if equipment:
		equipment.deserialize(data.get("equipment", {}))
	if quests:
		quests.deserialize(data.get("quests", {}), [])
	if echo_mgr:
		echo_mgr.deserialize(data.get("echoes_save", {}))
	if rep_mgr:
		rep_mgr.deserialize(data.get("reputation", {}))


func delete_save(slot: int) -> void:
	var path := get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)


func gather_save_data(  # gdlint:ignore = function-arguments-number
	party: Node,
	inventory: Node,
	flags: Node,
	scene_path: String,
	player_position: Vector2,
	equipment: Node = null,
	quests: Node = null,
	playtime: float = 0.0,
	echo_mgr: Node = null,
	rep_mgr: Node = null,
) -> Dictionary:
	var data := {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"playtime_seconds": playtime,
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
	if equipment:
		data["equipment"] = equipment.serialize()
	if quests:
		data["quests"] = quests.serialize()
	if echo_mgr:
		data["echoes_save"] = echo_mgr.serialize()
	if rep_mgr:
		data["reputation"] = rep_mgr.serialize()
	return data


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


## Returns true if the given scene path should not trigger autosave.
func is_autosave_excluded(scene_path: String) -> bool:
	return scene_path in _AUTOSAVE_EXCLUDED_SCENES


## Returns a summary dictionary for a save slot.
## {empty, location, playtime_str, time_str, timestamp}
func get_slot_summary(slot: int) -> Dictionary:
	if not has_save(slot):
		return {
			"empty": true,
			"location": "",
			"playtime_str": "",
			"time_str": "",
			"timestamp": 0,
		}
	var data := load_save_data(slot)
	if data.is_empty():
		return {
			"empty": true,
			"location": "",
			"playtime_str": "",
			"time_str": "",
			"timestamp": 0,
		}
	var scene_path: String = data.get("scene_path", "")
	var location: String = _AREA_NAMES.get(scene_path, scene_path.get_file().get_basename())
	var playtime_seconds: float = float(data.get("playtime_seconds", 0.0))
	var playtime_str := _format_playtime(playtime_seconds)
	var timestamp: int = int(data.get("timestamp", 0))
	var time_str := _format_timestamp(timestamp)
	return {
		"empty": false,
		"location": location,
		"playtime_str": playtime_str,
		"time_str": time_str,
		"timestamp": timestamp,
	}


## Returns summaries for all save slots (0=autosave, 1-3=manual).
func get_all_slot_summaries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for i in TOTAL_SLOTS:
		result.append(get_slot_summary(i))
	return result


## Returns true if any save file exists across all slots.
func any_save_exists() -> bool:
	for i in TOTAL_SLOTS:
		if has_save(i):
			return true
	return false


## Triggers an autosave to slot 0 using current game state.
func autosave() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		push_warning("SaveManager: autosave skipped — no player node found")
		autosave_completed.emit(false)
		return
	var scene := get_tree().current_scene
	if not scene:
		push_warning("SaveManager: autosave skipped — no current scene")
		autosave_completed.emit(false)
		return
	var scene_path: String = scene.scene_file_path
	var player_pos: Vector2 = player.global_position
	var party: Node = get_node_or_null("/root/PartyManager")
	var inventory: Node = get_node_or_null("/root/InventoryManager")
	var flags: Node = get_node_or_null("/root/EventFlags")
	var equipment: Node = get_node_or_null("/root/EquipmentManager")
	var quests: Node = get_node_or_null("/root/QuestManager")
	var echo_mgr: Node = get_node_or_null("/root/EchoManager")
	var rep_mgr: Node = get_node_or_null("/root/ReputationManager")
	var gm: Node = get_node_or_null("/root/GameManager")
	var playtime: float = gm.playtime_seconds if gm else 0.0
	if not party or not inventory or not flags:
		push_warning("SaveManager: autosave skipped — missing core managers")
		autosave_completed.emit(false)
		return
	var ok := save_game(
		AUTOSAVE_SLOT, party, inventory, flags,
		scene_path, player_pos, equipment, quests,
		playtime, echo_mgr, rep_mgr,
	)
	autosave_completed.emit(ok)


func _on_scene_changed_for_autosave(scene_path: String) -> void:
	if is_autosave_excluded(scene_path):
		return
	call_deferred("autosave")


static func _format_playtime(playtime_seconds: float) -> String:
	if playtime_seconds < 60.0:
		return ""
	var total_minutes: int = int(playtime_seconds) / int(60)
	var hours: int = total_minutes / int(60)
	var minutes: int = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]


static func _format_timestamp(unix_time: int) -> String:
	if unix_time <= 0:
		return ""
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	const MONTHS: Array[String] = [
		"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
	]
	var month_idx: int = dt.get("month", 0)
	var month_str: String = MONTHS[month_idx] if month_idx in range(1, 13) else ""
	return "%02d %s, %02d:%02d" % [
		dt.get("day", 0),
		month_str,
		dt.get("hour", 0),
		dt.get("minute", 0),
	]


func _on_scene_changed_restore_position(
	_scene_path: String,
) -> void:
	if not _has_pending_position:
		return
	_has_pending_position = false
	var player := get_tree().get_first_node_in_group("player")
	if player:
		player.global_position = _pending_position

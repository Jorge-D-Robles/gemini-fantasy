extends Node

## Manages the player's party roster and active party members.

signal party_changed
signal character_added(data: Resource)
signal character_removed(data: Resource)
signal party_state_changed

const MAX_ACTIVE: int = 4
const MAX_RESERVE: int = 4

## All recruited party members (active + reserve).
var roster: Array[Resource] = []
## Currently active party (in battle formation).
var active_party: Array[Resource] = []
## Reserve party members (benched).
var reserve_party: Array[Resource] = []
## Runtime HP/EE state per character_id.
var _runtime_state: Dictionary = {}


func add_character(data: Resource) -> void:
	if data == null:
		push_warning("PartyManager: cannot add null character.")
		return
	if _find_in_roster(data) >= 0:
		push_warning("PartyManager: character already in roster.")
		return
	roster.append(data)
	_init_runtime_state(data)
	if active_party.size() < MAX_ACTIVE:
		active_party.append(data)
	else:
		reserve_party.append(data)
	character_added.emit(data)
	party_changed.emit()


func remove_character(data: Resource) -> void:
	if data == null:
		push_warning("PartyManager: cannot remove null character.")
		return
	var index := _find_in_roster(data)
	if index < 0:
		push_warning("PartyManager: character not in roster.")
		return
	roster.remove_at(index)
	_clear_runtime_state(data)

	var active_idx := _find_in_array(active_party, data)
	if active_idx >= 0:
		active_party.remove_at(active_idx)
		_promote_from_reserve()
	else:
		var reserve_idx := _find_in_array(reserve_party, data)
		if reserve_idx >= 0:
			reserve_party.remove_at(reserve_idx)

	character_removed.emit(data)
	party_changed.emit()


func get_active_party() -> Array[Resource]:
	return active_party.duplicate()


func get_roster() -> Array[Resource]:
	return roster.duplicate()


func swap_members(active_index: int, reserve_index: int) -> void:
	if active_index < 0 or active_index >= active_party.size():
		push_warning("PartyManager: invalid active index.")
		return
	if reserve_index < 0 or reserve_index >= reserve_party.size():
		push_warning("PartyManager: invalid reserve index.")
		return
	var temp := active_party[active_index]
	active_party[active_index] = reserve_party[reserve_index]
	reserve_party[reserve_index] = temp
	party_changed.emit()


func get_party_size() -> int:
	return active_party.size()


func is_in_party(data: Resource) -> bool:
	return _find_in_array(active_party, data) >= 0


func get_hp(character_id: StringName) -> int:
	if character_id in _runtime_state:
		return _runtime_state[character_id]["current_hp"]
	return 0


func set_hp(character_id: StringName, value: int) -> void:
	if character_id not in _runtime_state:
		return
	var bd := _find_data_by_id(character_id)
	var max_val: int = bd.max_hp if bd else value
	_runtime_state[character_id]["current_hp"] = clampi(value, 0, max_val)
	party_state_changed.emit()


func get_ee(character_id: StringName) -> int:
	if character_id in _runtime_state:
		return _runtime_state[character_id]["current_ee"]
	return 0


func set_ee(character_id: StringName, value: int) -> void:
	if character_id not in _runtime_state:
		return
	var bd := _find_data_by_id(character_id)
	var max_val: int = bd.max_ee if bd else value
	_runtime_state[character_id]["current_ee"] = clampi(value, 0, max_val)
	party_state_changed.emit()


func heal_all() -> void:
	for data in roster:
		var bd := data as BattlerData
		if bd and bd.id in _runtime_state:
			_runtime_state[bd.id]["current_hp"] = bd.max_hp
			_runtime_state[bd.id]["current_ee"] = bd.max_ee
	party_state_changed.emit()


func get_runtime_state(character_id: StringName) -> Dictionary:
	if character_id in _runtime_state:
		return _runtime_state[character_id].duplicate()
	return {}


func _init_runtime_state(data: Resource) -> void:
	var bd := data as BattlerData
	if not bd or bd.id == &"":
		return
	_runtime_state[bd.id] = {
		"current_hp": bd.max_hp,
		"current_ee": bd.max_ee,
	}


func _clear_runtime_state(data: Resource) -> void:
	var bd := data as BattlerData
	if bd and bd.id in _runtime_state:
		_runtime_state.erase(bd.id)


func _find_data_by_id(character_id: StringName) -> BattlerData:
	for data in roster:
		var bd := data as BattlerData
		if bd and bd.id == character_id:
			return bd
	return null


func _promote_from_reserve() -> void:
	if reserve_party.is_empty():
		return
	if active_party.size() >= MAX_ACTIVE:
		return
	var promoted: Resource = reserve_party.pop_front()
	active_party.append(promoted)


func _find_in_roster(data: Resource) -> int:
	return _find_in_array(roster, data)


func _find_in_array(arr: Array[Resource], data: Resource) -> int:
	for i in arr.size():
		if arr[i] == data:
			return i
	return -1

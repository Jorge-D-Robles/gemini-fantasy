extends Node

## Autoload tracking collected Echo Fragments.
## Handles deduplication, serialization, and notifies listeners
## when a new echo is discovered.

## Emitted when a new echo is collected (not on duplicates).
signal echo_collected(id: StringName)

const MAX_EQUIPPED: int = 6

var _collected: Dictionary = {}
var _equipped: Array[EchoData] = []
var _equipped_ids: Array[StringName] = []
var _battle_uses: Dictionary = {}  # StringName -> int remaining


## Marks [param id] as collected. Idempotent — no-ops on duplicates.
func collect_echo(id: StringName) -> void:
	if _collected.has(id):
		return
	_collected[id] = true
	echo_collected.emit(id)


## Returns true if [param id] has been collected.
func has_echo(id: StringName) -> bool:
	return _collected.has(id)


## Returns a sorted array of all collected echo IDs.
func get_collected_echoes() -> Array[StringName]:
	var result: Array[StringName] = []
	for key: StringName in _collected:
		result.append(key)
	result.sort()
	return result


## Returns the total number of collected echoes.
func get_echo_count() -> int:
	return _collected.size()


## Equips an echo for battle use. Returns false if slots full or duplicate.
func equip_echo(echo: EchoData) -> bool:
	if not echo:
		return false
	if _equipped.size() >= MAX_EQUIPPED:
		return false
	if echo.id in _equipped_ids:
		return false
	_equipped.append(echo)
	_equipped_ids.append(echo.id)
	return true


## Removes an echo from the equipped list.
func unequip_echo(echo: EchoData) -> void:
	if not echo:
		return
	var idx := _equipped_ids.find(echo.id)
	if idx >= 0:
		_equipped.remove_at(idx)
		_equipped_ids.remove_at(idx)


## Returns the currently equipped echoes.
func get_equipped_echoes() -> Array[EchoData]:
	return _equipped


## Returns IDs of equipped echoes (useful for serialization).
func get_equipped_echo_ids() -> Array[StringName]:
	return _equipped_ids


## Resets per-battle use counters for all equipped echoes.
## Call at battle start.
func reset_battle_uses() -> void:
	_battle_uses.clear()
	for echo: EchoData in _equipped:
		_battle_uses[echo.id] = echo.uses_per_battle


## Consumes one use of an echo. Returns false if no uses remain.
func consume_use(echo_id: StringName) -> bool:
	var remaining: int = _battle_uses.get(echo_id, 0)
	if remaining <= 0:
		return false
	_battle_uses[echo_id] = remaining - 1
	return true


## Returns remaining uses for an echo in the current battle.
func get_remaining_uses(echo_id: StringName) -> int:
	return _battle_uses.get(echo_id, 0)


## Returns equipped echoes that still have uses remaining.
func get_available_echoes() -> Array[EchoData]:
	var result: Array[EchoData] = []
	for echo: EchoData in _equipped:
		if _battle_uses.get(echo.id, 0) > 0:
			result.append(echo)
	return result


## Returns a serializable dictionary representing the collection.
func serialize() -> Dictionary:
	var list: Array[String] = []
	for key: StringName in _collected:
		list.append(String(key))
	var eq_list: Array[String] = []
	for eid: StringName in _equipped_ids:
		eq_list.append(String(eid))
	return {"echoes": list, "equipped": eq_list}


## Restores collected echoes from a previously serialized dictionary.
## Merges into any existing collection.
func deserialize(data: Dictionary) -> void:
	var raw: Array = data.get("echoes", [])
	for entry in raw:
		var sn := StringName(str(entry))
		if not _collected.has(sn):
			_collected[sn] = true
	var eq_raw: Array = data.get("equipped", [])
	_equipped_ids.clear()
	_equipped.clear()
	for entry in eq_raw:
		var sn := StringName(str(entry))
		_equipped_ids.append(sn)

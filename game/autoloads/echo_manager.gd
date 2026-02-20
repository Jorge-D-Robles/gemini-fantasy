extends Node

## Autoload tracking collected Echo Fragments.
## Handles deduplication, serialization, and notifies listeners
## when a new echo is discovered.

## Emitted when a new echo is collected (not on duplicates).
signal echo_collected(id: StringName)

var _collected: Dictionary = {}


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


## Returns a serializable dictionary representing the collection.
func serialize() -> Dictionary:
	var list: Array[String] = []
	for key: StringName in _collected:
		list.append(String(key))
	return {"echoes": list}


## Restores collected echoes from a previously serialized dictionary.
## Merges into any existing collection.
func deserialize(data: Dictionary) -> void:
	var raw: Array = data.get("echoes", [])
	for entry in raw:
		var sn := StringName(str(entry))
		if not _collected.has(sn):
			_collected[sn] = true


## Returns the count of echo IDs in [param collected] — pure static helper.
static func compute_echo_count(collected: Array[StringName]) -> int:
	return collected.size()

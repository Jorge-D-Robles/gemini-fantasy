extends Node

## NOTE: No class_name — autoloads are already global singletons.
## Manages the player's inventory of items and gold.

signal inventory_changed
signal gold_changed

var gold: int = 0
var _items: Dictionary = {}


func add_item(id: StringName, count: int = 1) -> void:
	if count <= 0:
		return
	if _items.has(id):
		_items[id] += count
	else:
		_items[id] = count
	inventory_changed.emit()


func remove_item(id: StringName, count: int = 1) -> bool:
	if count <= 0:
		return false
	if not _items.has(id) or _items[id] < count:
		return false
	_items[id] -= count
	if _items[id] <= 0:
		_items.erase(id)
	inventory_changed.emit()
	return true


func has_item(id: StringName) -> bool:
	return _items.has(id) and _items[id] > 0


func get_item_count(id: StringName) -> int:
	return _items.get(id, 0)


func get_all_items() -> Dictionary:
	return _items.duplicate()


func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	gold_changed.emit()


func remove_gold(amount: int) -> bool:
	if amount <= 0:
		return false
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit()
	return true


func get_item_data(id: StringName) -> ItemData:
	var path := "res://data/items/%s.tres" % id
	if not ResourceLoader.exists(path):
		push_warning("InventoryManager: item file not found '%s'" % path)
		return null
	var data := load(path) as ItemData
	return data


func get_usable_items() -> Array[ItemData]:
	var result: Array[ItemData] = []
	for id: StringName in _items:
		if _items[id] <= 0:
			continue
		var data := get_item_data(id)
		if data and data.usable_in_battle:
			result.append(data)
	return result

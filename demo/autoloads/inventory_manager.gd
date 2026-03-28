extends Node
## Manages the player's inventory. Autoload as InventoryManager.

signal item_added(item: ItemData, new_count: int)
signal item_removed(item: ItemData, new_count: int)
signal inventory_changed
signal gold_changed(new_amount: int)

var gold: int = 100
var _items: Array[Dictionary] = []


func add_item(item: ItemData, amount: int = 1) -> void:
	for entry in _items:
		if entry.item.id == item.id:
			entry.count += amount
			item_added.emit(item, entry.count)
			inventory_changed.emit()
			return
	_items.append({item = item, count = amount})
	item_added.emit(item, amount)
	inventory_changed.emit()


func remove_item(item: ItemData, amount: int = 1) -> bool:
	for i in _items.size():
		if _items[i].item.id == item.id:
			_items[i].count -= amount
			var remaining: int = _items[i].count
			if remaining <= 0:
				_items.remove_at(i)
				remaining = 0
			item_removed.emit(item, remaining)
			inventory_changed.emit()
			return true
	return false


func has_item(item_id: String, amount: int = 1) -> bool:
	for entry in _items:
		if entry.item.id == item_id and entry.count >= amount:
			return true
	return false


func get_item_count(item_id: String) -> int:
	for entry in _items:
		if entry.item.id == item_id:
			return entry.count
	return 0


func get_all_items() -> Array[Dictionary]:
	return _items


func get_consumables() -> Array[Dictionary]:
	return _items.filter(
		func(entry: Dictionary) -> bool:
			return entry.item.item_type == ItemData.ItemType.CONSUMABLE
	)


func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		return true
	return false


func to_save_data() -> Dictionary:
	var items_data: Array[Dictionary] = []
	for entry in _items:
		items_data.append({
			item_path = entry.item.resource_path,
			count = entry.count,
		})
	return {gold = gold, items = items_data}


func from_save_data(data: Dictionary) -> void:
	gold = data.get("gold", 0)
	_items.clear()
	for entry in data.get("items", []):
		var item: ItemData = load(entry.item_path) as ItemData
		if item:
			_items.append({item = item, count = entry.count})
	inventory_changed.emit()
	gold_changed.emit(gold)

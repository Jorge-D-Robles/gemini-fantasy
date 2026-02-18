class_name ShopData
extends Resource

## Defines a shop's inventory, name, and price modifiers.

@export_group("Identity")
@export var shop_id: StringName = &""
@export var shop_name: String = ""

@export_group("Inventory")
@export var item_paths: Array[String] = []

@export_group("Pricing")
@export var buy_price_modifier: float = 1.0
@export var sell_price_modifier: float = 0.5

var _cached_items: Array[Resource] = []
var _items_loaded: bool = false


func get_items() -> Array[Resource]:
	if _items_loaded:
		return _cached_items
	_cached_items.clear()
	for path in item_paths:
		if not ResourceLoader.exists(path):
			push_warning("ShopData: item not found '%s'" % path)
			continue
		var res: Resource = load(path)
		if res == null:
			push_warning("ShopData: failed to load '%s'" % path)
			continue
		_cached_items.append(res)
	_items_loaded = true
	return _cached_items


func get_buy_price(item: Resource) -> int:
	var base_price: int = 0
	if item is ItemData:
		base_price = item.buy_price
	elif item is EquipmentData:
		base_price = item.buy_price
	var price: int = int(base_price * buy_price_modifier)
	if base_price > 0 and price < 1:
		price = 1
	return price


func get_sell_price(item: Resource) -> int:
	var base_price: int = 0
	if item is ItemData:
		base_price = item.sell_price
	elif item is EquipmentData:
		base_price = item.sell_price
	return int(base_price * sell_price_modifier)


func has_item(item_id: StringName) -> bool:
	for item in get_items():
		if item.id == item_id:
			return true
	return false


func get_item_by_id(item_id: StringName) -> Resource:
	for item in get_items():
		if item.id == item_id:
			return item
	return null

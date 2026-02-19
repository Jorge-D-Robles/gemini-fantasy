extends Node

## NOTE: No class_name — autoloads are already global singletons.
## Manages shop interactions: buying and selling items/equipment.

signal item_purchased(item_id: StringName)
signal item_sold(item_id: StringName)
signal shop_opened(shop_data: Resource)
signal shop_closed

var current_shop: ShopData = null
var is_open: bool = false

## Injected in tests; falls back to autoload singleton at runtime.
var _inventory: Node = null


func _get_inventory() -> Node:
	if _inventory:
		return _inventory
	return get_node_or_null("/root/InventoryManager")


func open_shop(shop_data: ShopData) -> void:
	if shop_data == null:
		push_warning("ShopManager: cannot open null shop")
		return
	if is_open:
		close_shop()
	current_shop = shop_data
	is_open = true
	shop_opened.emit(shop_data)


func close_shop() -> void:
	if not is_open:
		return
	current_shop = null
	is_open = false
	shop_closed.emit()


func get_current_shop() -> ShopData:
	return current_shop


func get_shop_items() -> Array[Resource]:
	if not is_open or current_shop == null:
		return []
	return current_shop.get_items()


func get_buy_price(item: Resource) -> int:
	if current_shop == null:
		return 0
	return current_shop.get_buy_price(item)


func get_sell_price(item: Resource) -> int:
	if current_shop == null:
		return 0
	return current_shop.get_sell_price(item)


func buy_item(item_id: StringName) -> bool:
	if not is_open or current_shop == null:
		return false
	if not current_shop.has_item(item_id):
		return false
	var item: Resource = current_shop.get_item_by_id(item_id)
	if item == null:
		return false
	var price: int = current_shop.get_buy_price(item)
	var inv: Node = _get_inventory()
	if inv == null:
		push_error("ShopManager: InventoryManager not found")
		return false
	if not inv.remove_gold(price):
		return false
	inv.add_item(item_id)
	item_purchased.emit(item_id)
	return true


func sell_item(item_id: StringName) -> bool:
	if not is_open or current_shop == null:
		return false
	var inv: Node = _get_inventory()
	if inv == null:
		push_error("ShopManager: InventoryManager not found")
		return false
	if not inv.has_item(item_id):
		return false
	# Look up item data to calculate sell price
	var item: Resource = _find_item_data(item_id)
	if item == null:
		return false
	var price: int = current_shop.get_sell_price(item)
	if not inv.remove_item(item_id):
		return false
	if price > 0:
		inv.add_gold(price)
	item_sold.emit(item_id)
	return true


func _find_item_data(item_id: StringName) -> Resource:
	# Check shop inventory first
	var shop_item: Resource = current_shop.get_item_by_id(item_id)
	if shop_item:
		return shop_item
	# Try loading as item
	var item_path := "res://data/items/%s.tres" % item_id
	if ResourceLoader.exists(item_path):
		return load(item_path)
	# Try loading as equipment
	var equip_path := "res://data/equipment/%s.tres" % item_id
	if ResourceLoader.exists(equip_path):
		return load(equip_path)
	push_warning("ShopManager: cannot find data for '%s'" % item_id)
	return null

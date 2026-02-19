class_name ShopUIList
extends RefCounted

## Static utilities for shop item list entry computation.
## Uses Callable DI to avoid autoload dependencies.


static func compute_buy_entries(
	items: Array[Resource],
	gold: int,
	price_fn: Callable,
) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for item in items:
		var price: int = price_fn.call(item)
		var can_afford: bool = gold >= price
		var name_text: String = (
			item.display_name if "display_name" in item
			else "???"
		)
		var label: String = "%s  %dG" % [name_text, price]
		entries.append({
			"item": item,
			"price": price,
			"can_afford": can_afford,
			"label": label,
		})
	return entries


static func compute_sell_entries(
	all_items: Dictionary,
	item_resolver: Callable,
	sell_price_fn: Callable,
) -> Array[Dictionary]:
	## all_items: Dictionary[StringName, int]
	var entries: Array[Dictionary] = []
	for id: StringName in all_items:
		var count: int = all_items[id]
		if count <= 0:
			continue
		var data: Resource = item_resolver.call(id)
		if data == null:
			continue
		if data is ItemData and data.item_type == ItemData.ItemType.KEY_ITEM:
			continue
		var price: int = sell_price_fn.call(data)
		var name_text: String = (
			data.display_name if "display_name" in data
			else "???"
		)
		var label: String = "%s  +%dG" % [name_text, price]
		entries.append({
			"item": data,
			"price": price,
			"label": label,
			"count": count,
		})
	return entries

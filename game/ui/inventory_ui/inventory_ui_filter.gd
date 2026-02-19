class_name InventoryUIFilter
extends RefCounted

## Static utilities for inventory category filtering and item entry
## preparation. No instance state — all methods are static.
## Do not instantiate.

# Category values match InventoryUI.Category enum:
# ALL=0, CONSUMABLES=1, EQUIPMENT=2, KEY_ITEMS=3
const _CAT_ALL := 0
const _CAT_CONSUMABLES := 1
const _CAT_EQUIPMENT := 2
const _CAT_KEY_ITEMS := 3


## Returns true if entry matches the given category value.
## category: int matching InventoryUI.Category enum.
## ALL (0) and unknown values return true.
static func matches_category(
	entry: Dictionary, category: int,
) -> bool:
	match category:
		_CAT_ALL:
			return true
		_CAT_CONSUMABLES:
			if entry.get("is_equipment", false):
				return false
			var item: ItemData = entry.get("data")
			if not item:
				return false
			return (
				item.item_type
				== ItemData.ItemType.CONSUMABLE
			)
		_CAT_EQUIPMENT:
			return entry.get("is_equipment", false)
		_CAT_KEY_ITEMS:
			if entry.get("is_equipment", false):
				return false
			var item: ItemData = entry.get("data")
			if not item:
				return false
			return (
				item.item_type
				== ItemData.ItemType.KEY_ITEM
			)
		_:
			return true


## Builds filtered item entries from an inventory dictionary.
## item_resolver: func(id: StringName) -> Dictionary
##   Must return {data: Resource, is_equipment: bool} or {}.
##   Must NOT call ResourceLoader or load().
## Filters out zero-count entries, unresolvable items, and
## entries not matching the given category.
static func compute_item_entries(
	items: Dictionary,
	item_resolver: Callable,
	category: int,
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id: StringName in items:
		var count: int = items[id]
		if count <= 0:
			continue
		var resolved: Dictionary = item_resolver.call(id)
		if resolved.is_empty():
			continue
		var data: Resource = resolved.get("data")
		if not data:
			continue
		var is_equipment: bool = resolved.get(
			"is_equipment", false
		)
		var display_name := ""
		if is_equipment and data is EquipmentData:
			display_name = (data as EquipmentData).display_name
		elif data is ItemData:
			display_name = (data as ItemData).display_name
		var entry := {
			"id": id,
			"count": count,
			"data": data,
			"is_equipment": is_equipment,
			"display_name": display_name,
		}
		if not matches_category(entry, category):
			continue
		result.append(entry)
	return result

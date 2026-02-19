extends GutTest

## Tests for InventoryUIFilter static methods.
## Validates category filtering and item entry computation.

const FilterScript := preload(
	"res://ui/inventory_ui/inventory_ui_filter.gd"
)
const Helpers := preload("res://tests/helpers/test_helpers.gd")

# Category enum values matching InventoryUI.Category:
# ALL=0, CONSUMABLES=1, EQUIPMENT=2, KEY_ITEMS=3
const CAT_ALL := 0
const CAT_CONSUMABLES := 1
const CAT_EQUIPMENT := 2
const CAT_KEY_ITEMS := 3


func _make_item_entry(
	overrides: Dictionary = {},
) -> Dictionary:
	var item := Helpers.make_item(overrides)
	return {
		"id": item.id,
		"count": overrides.get("count", 1),
		"data": item,
		"is_equipment": false,
		"display_name": item.display_name,
	}


func _make_equip_entry(
	overrides: Dictionary = {},
) -> Dictionary:
	var equip := Helpers.make_equipment(overrides)
	return {
		"id": equip.id,
		"count": overrides.get("count", 1),
		"data": equip,
		"is_equipment": true,
		"display_name": equip.display_name,
	}


# -- matches_category --


func test_matches_category_all_matches_everything() -> void:
	var item_entry := _make_item_entry()
	var equip_entry := _make_equip_entry()
	assert_true(
		FilterScript.matches_category(item_entry, CAT_ALL),
		"ALL should match consumable items",
	)
	assert_true(
		FilterScript.matches_category(equip_entry, CAT_ALL),
		"ALL should match equipment",
	)


func test_matches_category_consumables_filters_equipment() -> void:
	var equip_entry := _make_equip_entry()
	assert_false(
		FilterScript.matches_category(
			equip_entry, CAT_CONSUMABLES
		),
		"CONSUMABLES should reject equipment",
	)


func test_matches_category_consumables_filters_key_items() -> void:
	var key_entry := _make_item_entry({
		"item_type": ItemData.ItemType.KEY_ITEM,
	})
	assert_false(
		FilterScript.matches_category(
			key_entry, CAT_CONSUMABLES
		),
		"CONSUMABLES should reject key items",
	)


func test_matches_category_equipment_only() -> void:
	var equip_entry := _make_equip_entry()
	var item_entry := _make_item_entry()
	assert_true(
		FilterScript.matches_category(
			equip_entry, CAT_EQUIPMENT
		),
		"EQUIPMENT should match equipment",
	)
	assert_false(
		FilterScript.matches_category(
			item_entry, CAT_EQUIPMENT
		),
		"EQUIPMENT should reject consumables",
	)


func test_matches_category_key_items_only() -> void:
	var key_entry := _make_item_entry({
		"item_type": ItemData.ItemType.KEY_ITEM,
	})
	var consumable_entry := _make_item_entry({
		"item_type": ItemData.ItemType.CONSUMABLE,
	})
	assert_true(
		FilterScript.matches_category(
			key_entry, CAT_KEY_ITEMS
		),
		"KEY_ITEMS should match key items",
	)
	assert_false(
		FilterScript.matches_category(
			consumable_entry, CAT_KEY_ITEMS
		),
		"KEY_ITEMS should reject consumables",
	)


# -- compute_item_entries --


func _mock_resolver(lookup: Dictionary) -> Callable:
	return func(id: StringName) -> Dictionary:
		return lookup.get(id, {})


func test_compute_item_entries_empty_inventory() -> void:
	var items: Dictionary = {}
	var resolver := _mock_resolver({})
	var result := FilterScript.compute_item_entries(
		items, resolver, CAT_ALL,
	)
	assert_eq(result.size(), 0, "Empty inventory -> empty list")


func test_compute_item_entries_filters_zero_count() -> void:
	var item := Helpers.make_item({"id": &"potion"})
	var resolver := _mock_resolver({
		&"potion": {"data": item, "is_equipment": false},
	})
	var items := {&"potion": 0}
	var result := FilterScript.compute_item_entries(
		items, resolver, CAT_ALL,
	)
	assert_eq(result.size(), 0, "Zero-count should be filtered")


func test_compute_item_entries_filters_by_category() -> void:
	var potion := Helpers.make_item({
		"id": &"potion",
		"item_type": ItemData.ItemType.CONSUMABLE,
	})
	var sword := Helpers.make_equipment({
		"id": &"sword",
	})
	var resolver := _mock_resolver({
		&"potion": {"data": potion, "is_equipment": false},
		&"sword": {"data": sword, "is_equipment": true},
	})
	var items := {&"potion": 3, &"sword": 1}
	var result := FilterScript.compute_item_entries(
		items, resolver, CAT_CONSUMABLES,
	)
	assert_eq(
		result.size(), 1,
		"Should only include consumables",
	)
	assert_eq(result[0]["id"], &"potion")


func test_compute_item_entries_returns_display_names() -> void:
	var item := Helpers.make_item({
		"id": &"hi_potion",
		"display_name": "Hi-Potion",
	})
	var resolver := _mock_resolver({
		&"hi_potion": {
			"data": item, "is_equipment": false,
		},
	})
	var items := {&"hi_potion": 2}
	var result := FilterScript.compute_item_entries(
		items, resolver, CAT_ALL,
	)
	assert_eq(result.size(), 1)
	assert_eq(result[0]["display_name"], "Hi-Potion")
	assert_eq(result[0]["count"], 2)


func test_compute_item_entries_skips_unresolvable() -> void:
	var resolver := _mock_resolver({})
	var items := {&"unknown_item": 1}
	var result := FilterScript.compute_item_entries(
		items, resolver, CAT_ALL,
	)
	assert_eq(
		result.size(), 0,
		"Unresolvable items should be skipped",
	)

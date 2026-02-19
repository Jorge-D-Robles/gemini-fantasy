extends GutTest

## Tests for ShopUIList static methods.
## Validates buy/sell entry computation with Callable DI.

const ListScript := preload(
	"res://ui/shop_ui/shop_ui_list.gd"
)
const Helpers := preload("res://tests/helpers/test_helpers.gd")


# -- compute_buy_entries --


func test_compute_buy_entries_basic() -> void:
	var sword := Helpers.make_equipment({
		"display_name": "Iron Sword",
	})
	var items: Array[Resource] = [sword]
	var price_fn := func(item: Resource) -> int: return 200
	var entries := ListScript.compute_buy_entries(
		items, 500, price_fn,
	)
	assert_eq(entries.size(), 1)
	assert_eq(entries[0]["item"], sword)
	assert_eq(entries[0]["price"], 200)
	assert_true(entries[0]["can_afford"])
	assert_true(
		entries[0]["label"].contains("Iron Sword"),
		"Label should contain item name",
	)
	assert_true(
		entries[0]["label"].contains("200"),
		"Label should contain price",
	)


func test_compute_buy_entries_affordability() -> void:
	var potion := Helpers.make_item({
		"display_name": "Potion",
	})
	var items: Array[Resource] = [potion]
	var price_fn := func(item: Resource) -> int: return 100
	var entries := ListScript.compute_buy_entries(
		items, 50, price_fn,
	)
	assert_eq(entries.size(), 1)
	assert_false(
		entries[0]["can_afford"],
		"Should not afford when gold < price",
	)


func test_compute_buy_entries_empty() -> void:
	var items: Array[Resource] = []
	var price_fn := func(item: Resource) -> int: return 0
	var entries := ListScript.compute_buy_entries(
		items, 100, price_fn,
	)
	assert_eq(entries.size(), 0, "Empty items -> empty entries")


func test_compute_buy_entries_zero_price() -> void:
	var item := Helpers.make_item({
		"display_name": "Free Sample",
	})
	var items: Array[Resource] = [item]
	var price_fn := func(item_r: Resource) -> int: return 0
	var entries := ListScript.compute_buy_entries(
		items, 0, price_fn,
	)
	assert_eq(entries.size(), 1)
	assert_true(
		entries[0]["can_afford"],
		"Zero price with zero gold should be affordable",
	)


# -- compute_sell_entries --


func _mock_resolver(lookup: Dictionary) -> Callable:
	return func(id: StringName) -> Resource:
		return lookup.get(id)


func _mock_price_fn(prices: Dictionary) -> Callable:
	return func(item: Resource) -> int:
		return prices.get(item.id, 0)


func test_compute_sell_entries_basic() -> void:
	var potion := Helpers.make_item({
		"id": &"potion",
		"display_name": "Potion",
		"item_type": ItemData.ItemType.CONSUMABLE,
	})
	var resolver := _mock_resolver({&"potion": potion})
	var price_fn := _mock_price_fn({&"potion": 25})
	var all_items := {&"potion": 3}
	var entries := ListScript.compute_sell_entries(
		all_items, resolver, price_fn,
	)
	assert_eq(entries.size(), 1)
	assert_eq(entries[0]["item"], potion)
	assert_eq(entries[0]["price"], 25)
	assert_eq(entries[0]["count"], 3)
	assert_true(
		entries[0]["label"].contains("Potion"),
		"Label should contain item name",
	)
	# Label should NOT contain count suffix
	assert_false(
		entries[0]["label"].contains("x3"),
		"Label should not include count suffix",
	)


func test_compute_sell_entries_filters_key_items() -> void:
	var key := Helpers.make_item({
		"id": &"old_map",
		"item_type": ItemData.ItemType.KEY_ITEM,
	})
	var resolver := _mock_resolver({&"old_map": key})
	var price_fn := _mock_price_fn({&"old_map": 0})
	var all_items := {&"old_map": 1}
	var entries := ListScript.compute_sell_entries(
		all_items, resolver, price_fn,
	)
	assert_eq(
		entries.size(), 0,
		"KEY_ITEM should be filtered out",
	)


func test_compute_sell_entries_skips_zero_count() -> void:
	var potion := Helpers.make_item({
		"id": &"potion",
		"item_type": ItemData.ItemType.CONSUMABLE,
	})
	var resolver := _mock_resolver({&"potion": potion})
	var price_fn := _mock_price_fn({&"potion": 10})
	var all_items := {&"potion": 0}
	var entries := ListScript.compute_sell_entries(
		all_items, resolver, price_fn,
	)
	assert_eq(
		entries.size(), 0,
		"Zero-count items should be skipped",
	)


func test_compute_sell_entries_unresolvable() -> void:
	var resolver := _mock_resolver({})
	var price_fn := func(item: Resource) -> int: return 0
	var all_items := {&"unknown": 1}
	var entries := ListScript.compute_sell_entries(
		all_items, resolver, price_fn,
	)
	assert_eq(
		entries.size(), 0,
		"Unresolvable items should be skipped",
	)

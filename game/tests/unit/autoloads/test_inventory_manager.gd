extends GutTest

## Tests for InventoryManager inventory and gold logic.
## Creates a fresh instance per test — never touches the global singleton.

var _inv: Node


func before_each() -> void:
	_inv = load("res://autoloads/inventory_manager.gd").new()
	add_child_autofree(_inv)


# --- add_item ---

func test_add_item_creates_entry() -> void:
	_inv.add_item(&"potion")
	assert_true(_inv.has_item(&"potion"))
	assert_eq(_inv.get_item_count(&"potion"), 1)


func test_add_item_stacks() -> void:
	_inv.add_item(&"potion", 3)
	_inv.add_item(&"potion", 2)
	assert_eq(_inv.get_item_count(&"potion"), 5)


func test_add_item_default_count_is_one() -> void:
	_inv.add_item(&"potion")
	assert_eq(_inv.get_item_count(&"potion"), 1)


func test_add_item_zero_count_ignored() -> void:
	_inv.add_item(&"potion", 0)
	assert_false(_inv.has_item(&"potion"))


func test_add_item_negative_count_ignored() -> void:
	_inv.add_item(&"potion", -5)
	assert_false(_inv.has_item(&"potion"))


func test_add_item_emits_inventory_changed() -> void:
	watch_signals(_inv)
	_inv.add_item(&"potion")
	assert_signal_emitted(_inv, "inventory_changed")


# --- remove_item ---

func test_remove_item_decrements() -> void:
	_inv.add_item(&"potion", 3)
	var result: bool = _inv.remove_item(&"potion", 1)
	assert_true(result)
	assert_eq(_inv.get_item_count(&"potion"), 2)


func test_remove_item_erases_at_zero() -> void:
	_inv.add_item(&"potion", 1)
	_inv.remove_item(&"potion", 1)
	assert_false(_inv.has_item(&"potion"))
	assert_eq(_inv.get_item_count(&"potion"), 0)


func test_remove_item_fails_when_insufficient() -> void:
	_inv.add_item(&"potion", 2)
	var result: bool = _inv.remove_item(&"potion", 5)
	assert_false(result)
	assert_eq(_inv.get_item_count(&"potion"), 2)


func test_remove_item_fails_when_absent() -> void:
	var result: bool = _inv.remove_item(&"potion", 1)
	assert_false(result)


func test_remove_item_zero_count_returns_false() -> void:
	_inv.add_item(&"potion", 1)
	var result: bool = _inv.remove_item(&"potion", 0)
	assert_false(result)


func test_remove_item_negative_count_returns_false() -> void:
	_inv.add_item(&"potion", 1)
	var result: bool = _inv.remove_item(&"potion", -1)
	assert_false(result)


func test_remove_item_emits_inventory_changed() -> void:
	_inv.add_item(&"potion", 1)
	watch_signals(_inv)
	_inv.remove_item(&"potion", 1)
	assert_signal_emitted(_inv, "inventory_changed")


func test_remove_item_no_signal_on_failure() -> void:
	watch_signals(_inv)
	_inv.remove_item(&"potion", 1)
	assert_signal_not_emitted(_inv, "inventory_changed")


# --- has_item / get_item_count ---

func test_has_item_false_for_missing() -> void:
	assert_false(_inv.has_item(&"potion"))


func test_get_item_count_zero_for_missing() -> void:
	assert_eq(_inv.get_item_count(&"potion"), 0)


# --- get_all_items ---

func test_get_all_items_returns_copy() -> void:
	_inv.add_item(&"potion", 2)
	_inv.add_item(&"ether", 1)
	var items: Dictionary = _inv.get_all_items()
	assert_eq(items.size(), 2)
	assert_eq(items[&"potion"], 2)
	assert_eq(items[&"ether"], 1)
	# Mutating the copy should not affect internal state
	items[&"potion"] = 99
	assert_eq(_inv.get_item_count(&"potion"), 2)


# --- gold ---

func test_gold_starts_at_zero() -> void:
	assert_eq(_inv.gold, 0)


func test_add_gold() -> void:
	_inv.add_gold(100)
	assert_eq(_inv.gold, 100)


func test_add_gold_stacks() -> void:
	_inv.add_gold(50)
	_inv.add_gold(30)
	assert_eq(_inv.gold, 80)


func test_add_gold_zero_ignored() -> void:
	watch_signals(_inv)
	_inv.add_gold(0)
	assert_eq(_inv.gold, 0)
	assert_signal_not_emitted(_inv, "gold_changed")


func test_add_gold_negative_ignored() -> void:
	watch_signals(_inv)
	_inv.add_gold(-10)
	assert_eq(_inv.gold, 0)
	assert_signal_not_emitted(_inv, "gold_changed")


func test_add_gold_emits_gold_changed() -> void:
	watch_signals(_inv)
	_inv.add_gold(100)
	assert_signal_emitted(_inv, "gold_changed")


func test_remove_gold_success() -> void:
	_inv.add_gold(100)
	var result: bool = _inv.remove_gold(40)
	assert_true(result)
	assert_eq(_inv.gold, 60)


func test_remove_gold_exact_amount() -> void:
	_inv.add_gold(50)
	var result: bool = _inv.remove_gold(50)
	assert_true(result)
	assert_eq(_inv.gold, 0)


func test_remove_gold_fails_when_insufficient() -> void:
	_inv.add_gold(30)
	var result: bool = _inv.remove_gold(50)
	assert_false(result)
	assert_eq(_inv.gold, 30)


func test_remove_gold_zero_returns_false() -> void:
	_inv.add_gold(100)
	var result: bool = _inv.remove_gold(0)
	assert_false(result)


func test_remove_gold_negative_returns_false() -> void:
	_inv.add_gold(100)
	var result: bool = _inv.remove_gold(-10)
	assert_false(result)


func test_remove_gold_emits_gold_changed() -> void:
	_inv.add_gold(100)
	watch_signals(_inv)
	_inv.remove_gold(40)
	assert_signal_emitted(_inv, "gold_changed")


func test_remove_gold_no_signal_on_failure() -> void:
	watch_signals(_inv)
	_inv.remove_gold(10)
	assert_signal_not_emitted(_inv, "gold_changed")


# --- get_item_data ---

func test_get_item_data_loads_potion() -> void:
	var data: ItemData = _inv.get_item_data(&"potion")
	assert_not_null(data)
	assert_eq(data.id, &"potion")
	assert_eq(data.display_name, "Potion")
	assert_eq(data.effect_type, ItemData.EffectType.HEAL_HP)
	assert_eq(data.effect_value, 50)


func test_get_item_data_returns_null_for_missing() -> void:
	var data: ItemData = _inv.get_item_data(&"nonexistent_item")
	assert_null(data)


# --- get_usable_items ---

func test_get_usable_items_returns_matching_data() -> void:
	_inv.add_item(&"potion", 2)
	_inv.add_item(&"ether", 1)
	var usable: Array = _inv.get_usable_items()
	assert_eq(usable.size(), 2)
	var ids: Array[StringName] = []
	for item in usable:
		ids.append(item.id)
	assert_has(ids, &"potion")
	assert_has(ids, &"ether")


func test_get_usable_items_empty_when_no_items() -> void:
	var usable: Array = _inv.get_usable_items()
	assert_eq(usable.size(), 0)


# --- multiple item types ---

func test_multiple_item_types_tracked() -> void:
	_inv.add_item(&"potion", 3)
	_inv.add_item(&"ether", 2)
	_inv.add_item(&"phoenix_down", 1)
	assert_eq(_inv.get_item_count(&"potion"), 3)
	assert_eq(_inv.get_item_count(&"ether"), 2)
	assert_eq(_inv.get_item_count(&"phoenix_down"), 1)
	assert_eq(_inv.get_all_items().size(), 3)

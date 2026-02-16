extends GutTest

## Tests for battle item action creation and inventory consumption.

const TestHelpers := preload("res://tests/helpers/test_helpers.gd")
const InventoryManagerScript := preload("res://autoloads/inventory_manager.gd")


func test_create_item_action_has_correct_type() -> void:
	var item := TestHelpers.make_item()
	var action := BattleAction.create_item(item, null)
	assert_eq(action.type, BattleAction.Type.ITEM)


func test_create_item_action_stores_item() -> void:
	var item := TestHelpers.make_item({"id": &"potion", "effect_value": 50})
	var action := BattleAction.create_item(item, null)
	assert_eq(action.item, item)
	assert_eq(action.item.id, &"potion")
	assert_eq(action.item.effect_value, 50)


func test_create_item_action_stores_target() -> void:
	var item := TestHelpers.make_item()
	var battler := TestHelpers.make_battler()
	add_child_autofree(battler)
	var action := BattleAction.create_item(item, battler)
	assert_eq(action.target, battler)


func test_create_item_action_null_target() -> void:
	var item := TestHelpers.make_item()
	var action := BattleAction.create_item(item, null)
	assert_null(action.target)


func test_inventory_consume_on_item_use() -> void:
	var inv: Node = InventoryManagerScript.new()
	add_child_autofree(inv)
	inv.add_item(&"potion", 3)
	var success: bool = inv.remove_item(&"potion", 1)
	assert_true(success)
	assert_eq(inv.get_item_count(&"potion"), 2)


func test_inventory_consume_last_item() -> void:
	var inv: Node = InventoryManagerScript.new()
	add_child_autofree(inv)
	inv.add_item(&"potion", 1)
	var success: bool = inv.remove_item(&"potion", 1)
	assert_true(success)
	assert_false(inv.has_item(&"potion"))


func test_usable_items_filters_battle_usable() -> void:
	var inv: Node = InventoryManagerScript.new()
	add_child_autofree(inv)
	inv.add_item(&"potion", 2)
	inv.add_item(&"ether", 1)
	var usable: Array = inv.get_usable_items()
	assert_gte(usable.size(), 1)
	for item in usable:
		assert_true(item.usable_in_battle)

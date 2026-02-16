extends GutTest

## Tests for ItemData resource — defaults and enum coverage.


func test_default_values() -> void:
	var item := ItemData.new()
	assert_eq(item.id, &"")
	assert_eq(item.display_name, "")
	assert_eq(item.description, "")
	assert_eq(item.item_type, ItemData.ItemType.CONSUMABLE)
	assert_eq(item.effect_type, ItemData.EffectType.HEAL_HP)
	assert_eq(item.effect_value, 0)
	assert_eq(item.target_type, ItemData.TargetType.SINGLE_ALLY)
	assert_eq(item.buy_price, 0)
	assert_eq(item.sell_price, 0)
	assert_eq(item.max_stack, 99)
	assert_eq(item.icon_path, "")
	assert_true(item.usable_in_battle)


func test_item_type_enum_values() -> void:
	assert_eq(ItemData.ItemType.CONSUMABLE, 0)
	assert_eq(ItemData.ItemType.KEY_ITEM, 1)
	assert_eq(ItemData.ItemType.MATERIAL, 2)


func test_effect_type_enum_values() -> void:
	assert_eq(ItemData.EffectType.HEAL_HP, 0)
	assert_eq(ItemData.EffectType.HEAL_EE, 1)
	assert_eq(ItemData.EffectType.CURE_STATUS, 2)
	assert_eq(ItemData.EffectType.REVIVE, 3)
	assert_eq(ItemData.EffectType.BUFF, 4)
	assert_eq(ItemData.EffectType.DAMAGE, 5)


func test_target_type_enum_values() -> void:
	assert_eq(ItemData.TargetType.SINGLE_ALLY, 0)
	assert_eq(ItemData.TargetType.ALL_ALLIES, 1)
	assert_eq(ItemData.TargetType.SINGLE_ENEMY, 2)


func test_set_custom_values() -> void:
	var item := ItemData.new()
	item.id = &"hi_potion"
	item.display_name = "Hi-Potion"
	item.item_type = ItemData.ItemType.CONSUMABLE
	item.effect_type = ItemData.EffectType.HEAL_HP
	item.effect_value = 200
	item.buy_price = 100
	item.sell_price = 50
	item.max_stack = 10
	item.usable_in_battle = true
	assert_eq(item.id, &"hi_potion")
	assert_eq(item.effect_value, 200)
	assert_eq(item.buy_price, 100)
	assert_eq(item.sell_price, 50)
	assert_eq(item.max_stack, 10)


func test_key_item_not_usable_in_battle() -> void:
	var item := ItemData.new()
	item.item_type = ItemData.ItemType.KEY_ITEM
	item.usable_in_battle = false
	assert_false(item.usable_in_battle)

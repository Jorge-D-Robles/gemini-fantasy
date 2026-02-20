extends GutTest

## Tests for ItemData resource — enum cross-check and field assignment.


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

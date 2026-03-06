extends GutTest

## Tests for Emberhearth Forge shop data resource.

var _shop: ShopData


func before_each() -> void:
	_shop = load("res://data/shops/emberhearth_forge.tres")


func test_shop_loads() -> void:
	assert_not_null(_shop, "Shop should load")


func test_shop_id() -> void:
	assert_eq(_shop.shop_id, &"emberhearth_forge")


func test_shop_name() -> void:
	assert_eq(_shop.shop_name, "Emberhearth Forge")


func test_shop_has_items() -> void:
	assert_gt(
		_shop.item_paths.size(), 0,
		"Shop should have items",
	)


func test_shop_has_steel_sword() -> void:
	assert_true(
		"res://data/equipment/steel_sword.tres" in _shop.item_paths,
		"Shop should sell steel sword",
	)


func test_shop_has_steel_mace() -> void:
	assert_true(
		"res://data/equipment/steel_mace.tres" in _shop.item_paths,
		"Shop should sell steel mace",
	)


func test_shop_has_chain_mail() -> void:
	assert_true(
		"res://data/equipment/chain_mail.tres" in _shop.item_paths,
		"Shop should sell chain mail",
	)


func test_shop_buy_price_modifier() -> void:
	assert_eq(
		_shop.buy_price_modifier, 1.0,
		"Buy price modifier should be 1.0",
	)


func test_shop_sell_price_modifier() -> void:
	assert_eq(
		_shop.sell_price_modifier, 0.5,
		"Sell price modifier should be 0.5",
	)

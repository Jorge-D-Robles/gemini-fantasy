extends GutTest

## Tests for Gearhaven Tech Emporium shop data.

const SHOP_PATH: String = "res://data/shops/gearhaven_tech.tres"
var _shop: Resource


func before_each() -> void:
	_shop = load(SHOP_PATH)


func test_shop_loads() -> void:
	assert_not_null(_shop, "Shop resource should load")


func test_shop_id() -> void:
	assert_eq(
		_shop.shop_id, &"gearhaven_tech",
		"Shop ID should match",
	)


func test_shop_name() -> void:
	assert_eq(
		_shop.shop_name, "Gearhaven Tech Emporium",
		"Shop name should match",
	)


func test_shop_has_items() -> void:
	assert_gt(
		_shop.item_paths.size(), 0,
		"Shop should have items",
	)


func test_shop_has_resonance_blade() -> void:
	assert_true(
		_shop.item_paths.has(
			"res://data/equipment/resonance_blade.tres",
		),
		"Shop should sell Resonance Blade",
	)


func test_shop_has_chrome_repeater() -> void:
	assert_true(
		_shop.item_paths.has(
			"res://data/equipment/chrome_repeater.tres",
		),
		"Shop should sell Chrome Repeater",
	)


func test_shop_has_arc_staff() -> void:
	assert_true(
		_shop.item_paths.has(
			"res://data/equipment/arc_staff.tres",
		),
		"Shop should sell Arc Staff",
	)


func test_shop_has_reinforced_coat() -> void:
	assert_true(
		_shop.item_paths.has(
			"res://data/equipment/reinforced_coat.tres",
		),
		"Shop should sell Reinforced Coat",
	)


func test_buy_price_modifier() -> void:
	assert_eq(
		_shop.buy_price_modifier, 1.0,
		"Buy price modifier should be 1.0",
	)


func test_sell_price_modifier() -> void:
	assert_eq(
		_shop.sell_price_modifier, 0.5,
		"Sell price modifier should be 0.5",
	)

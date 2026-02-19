extends GutTest

## Tests for ShopManager shop open/close, buy/sell logic.
## Creates fresh instances per test — never touches global singletons.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _shop: Node
var _inv: Node


func before_each() -> void:
	_inv = load("res://autoloads/inventory_manager.gd").new()
	add_child_autofree(_inv)
	_shop = load("res://autoloads/shop_manager.gd").new()
	_shop._inventory = _inv
	add_child_autofree(_shop)


func _make_shop_data(overrides: Dictionary = {}) -> Resource:
	var sd: Resource = load("res://resources/shop_data.gd").new()
	sd.shop_id = overrides.get("shop_id", &"test_shop")
	sd.shop_name = overrides.get("shop_name", "Test Shop")
	var raw_paths: Array = overrides.get("item_paths", [
		"res://data/items/potion.tres",
		"res://data/items/ether.tres",
	])
	var paths: Array[String] = []
	for p in raw_paths:
		paths.append(p)
	sd.item_paths = paths
	sd.buy_price_modifier = overrides.get("buy_price_modifier", 1.0)
	sd.sell_price_modifier = overrides.get("sell_price_modifier", 0.5)
	return sd


# --- open_shop / close_shop ---

func test_shop_starts_closed() -> void:
	assert_false(_shop.is_open)
	assert_null(_shop.get_current_shop())


func test_open_shop_sets_state() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	assert_true(_shop.is_open)
	assert_eq(_shop.get_current_shop(), sd)


func test_open_shop_emits_signal() -> void:
	var sd: Resource = _make_shop_data()
	watch_signals(_shop)
	_shop.open_shop(sd)
	assert_signal_emitted(_shop, "shop_opened")


func test_close_shop_clears_state() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	_shop.close_shop()
	assert_false(_shop.is_open)
	assert_null(_shop.get_current_shop())


func test_close_shop_emits_signal() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	watch_signals(_shop)
	_shop.close_shop()
	assert_signal_emitted(_shop, "shop_closed")


func test_close_shop_noop_when_not_open() -> void:
	watch_signals(_shop)
	_shop.close_shop()
	assert_signal_not_emitted(_shop, "shop_closed")


func test_open_shop_while_already_open_closes_first() -> void:
	var sd1: Resource = _make_shop_data({"shop_id": &"shop_a"})
	var sd2: Resource = _make_shop_data({"shop_id": &"shop_b"})
	_shop.open_shop(sd1)
	watch_signals(_shop)
	_shop.open_shop(sd2)
	assert_signal_emitted(_shop, "shop_closed")
	assert_signal_emitted(_shop, "shop_opened")
	assert_eq(_shop.get_current_shop(), sd2)


# --- get_shop_items ---

func test_get_shop_items_returns_loaded_resources() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	var items: Array = _shop.get_shop_items()
	assert_eq(items.size(), 2)
	assert_eq(items[0].id, &"potion")
	assert_eq(items[1].id, &"ether")


func test_get_shop_items_empty_when_closed() -> void:
	var items: Array = _shop.get_shop_items()
	assert_eq(items.size(), 0)


# --- get_buy_price / get_sell_price ---

func test_get_buy_price_default_modifier() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	var items: Array = _shop.get_shop_items()
	# Potion buy_price = 25, modifier = 1.0 -> 25
	var price: int = _shop.get_buy_price(items[0])
	assert_eq(price, 25)


func test_get_buy_price_with_modifier() -> void:
	var sd: Resource = _make_shop_data({"buy_price_modifier": 1.5})
	_shop.open_shop(sd)
	var items: Array = _shop.get_shop_items()
	# Potion buy_price = 25, modifier = 1.5 -> 37 (rounded down)
	var price: int = _shop.get_buy_price(items[0])
	assert_eq(price, 37)


func test_get_sell_price_default_modifier() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	var items: Array = _shop.get_shop_items()
	# Potion sell_price = 12, modifier = 0.5 -> 6
	var price: int = _shop.get_sell_price(items[0])
	assert_eq(price, 6)


func test_get_sell_price_with_modifier() -> void:
	var sd: Resource = _make_shop_data({"sell_price_modifier": 1.0})
	_shop.open_shop(sd)
	var items: Array = _shop.get_shop_items()
	# Potion sell_price = 12, modifier = 1.0 -> 12
	var price: int = _shop.get_sell_price(items[0])
	assert_eq(price, 12)


# --- buy_item ---

func test_buy_item_success() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	_inv.add_gold(100)
	var result: bool = _shop.buy_item(&"potion")
	assert_true(result)
	assert_eq(_inv.gold, 75)  # 100 - 25
	assert_eq(_inv.get_item_count(&"potion"), 1)


func test_buy_item_emits_signal() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	_inv.add_gold(100)
	watch_signals(_shop)
	_shop.buy_item(&"potion")
	assert_signal_emitted(_shop, "item_purchased")


func test_buy_item_fails_insufficient_gold() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	_inv.add_gold(10)  # Not enough for potion (25)
	var result: bool = _shop.buy_item(&"potion")
	assert_false(result)
	assert_eq(_inv.gold, 10)
	assert_eq(_inv.get_item_count(&"potion"), 0)


func test_buy_item_fails_when_shop_closed() -> void:
	_inv.add_gold(100)
	var result: bool = _shop.buy_item(&"potion")
	assert_false(result)
	assert_eq(_inv.gold, 100)


func test_buy_item_fails_for_item_not_in_shop() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	_inv.add_gold(1000)
	var result: bool = _shop.buy_item(&"phoenix_down")
	assert_false(result)


func test_buy_item_exact_gold() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	_inv.add_gold(25)  # Exact price of potion
	var result: bool = _shop.buy_item(&"potion")
	assert_true(result)
	assert_eq(_inv.gold, 0)
	assert_eq(_inv.get_item_count(&"potion"), 1)


func test_buy_equipment() -> void:
	var sd: Resource = _make_shop_data({
		"item_paths": ["res://data/equipment/iron_sword.tres"],
	})
	_shop.open_shop(sd)
	_inv.add_gold(500)
	var result: bool = _shop.buy_item(&"iron_sword")
	assert_true(result)
	assert_eq(_inv.gold, 380)  # 500 - 120
	assert_true(_inv.has_item(&"iron_sword"))


# --- sell_item ---

func test_sell_item_success() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	_inv.add_item(&"potion", 3)
	var result: bool = _shop.sell_item(&"potion")
	assert_true(result)
	# Potion sell_price = 12, modifier = 0.5 -> 6
	assert_eq(_inv.gold, 6)
	assert_eq(_inv.get_item_count(&"potion"), 2)


func test_sell_item_emits_signal() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	_inv.add_item(&"potion", 1)
	watch_signals(_shop)
	_shop.sell_item(&"potion")
	assert_signal_emitted(_shop, "item_sold")


func test_sell_item_fails_when_not_in_inventory() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	var result: bool = _shop.sell_item(&"potion")
	assert_false(result)
	assert_eq(_inv.gold, 0)


func test_sell_item_fails_when_shop_closed() -> void:
	_inv.add_item(&"potion", 1)
	var result: bool = _shop.sell_item(&"potion")
	assert_false(result)


func test_sell_last_item_removes_from_inventory() -> void:
	var sd: Resource = _make_shop_data()
	_shop.open_shop(sd)
	_inv.add_item(&"potion", 1)
	_shop.sell_item(&"potion")
	assert_false(_inv.has_item(&"potion"))


# --- price modifier edge cases ---

func test_buy_price_minimum_one() -> void:
	var sd: Resource = _make_shop_data({"buy_price_modifier": 0.01})
	_shop.open_shop(sd)
	var items: Array = _shop.get_shop_items()
	# Very low modifier should still result in at least 1
	var price: int = _shop.get_buy_price(items[0])
	assert_true(price >= 1)


func test_sell_price_can_be_zero() -> void:
	var sd: Resource = _make_shop_data({"sell_price_modifier": 0.0})
	_shop.open_shop(sd)
	var items: Array = _shop.get_shop_items()
	var price: int = _shop.get_sell_price(items[0])
	assert_eq(price, 0)

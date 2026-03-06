extends GutTest

## Tests for the Prismfall town shop data and new mid-tier equipment.

var _shop: ShopData


func before_each() -> void:
	_shop = load("res://data/shops/prismfall_arms.tres") as ShopData


func test_shop_loads() -> void:
	assert_not_null(_shop, "prismfall_arms.tres should load")


func test_shop_identity() -> void:
	assert_eq(_shop.shop_id, &"prismfall_arms")
	assert_ne(_shop.shop_name, "", "Shop should have a display name")


func test_shop_has_items() -> void:
	var items := _shop.get_items()
	assert_gte(items.size(), 8, "Shop should stock at least 8 items")


func test_shop_includes_steel_sword() -> void:
	assert_true(_shop.has_item(&"steel_sword"), "Should stock Steel Sword")


func test_shop_includes_steel_hammer() -> void:
	assert_true(_shop.has_item(&"steel_hammer"), "Should stock Steel Hammer")


func test_shop_includes_steel_mace() -> void:
	assert_true(_shop.has_item(&"steel_mace"), "Should stock Steel Mace")


func test_shop_includes_chain_mail() -> void:
	assert_true(_shop.has_item(&"chain_mail"), "Should stock Chain Mail")


func test_shop_includes_iron_helm() -> void:
	assert_true(_shop.has_item(&"iron_helm"), "Should stock Iron Helm")


func test_shop_includes_consumables() -> void:
	assert_true(_shop.has_item(&"hi_potion"), "Should stock Hi-Potion")
	assert_true(_shop.has_item(&"ether"), "Should stock Ether")
	assert_true(_shop.has_item(&"antidote"), "Should stock Antidote")


func test_shop_includes_phoenix_down() -> void:
	assert_true(_shop.has_item(&"phoenix_down"), "Should stock Phoenix Down")


func test_steel_hammer_loads() -> void:
	var eq: EquipmentData = load("res://data/equipment/steel_hammer.tres")
	assert_not_null(eq, "steel_hammer.tres should load")
	assert_eq(eq.id, &"steel_hammer")
	assert_eq(eq.slot_type, EquipmentData.SlotType.WEAPON)
	assert_eq(eq.weapon_type, EquipmentData.WeaponType.HAMMER)
	assert_gt(eq.attack_bonus, 0, "Should boost attack")
	assert_gt(eq.buy_price, 0, "Should have a buy price")


func test_steel_mace_loads() -> void:
	var eq: EquipmentData = load("res://data/equipment/steel_mace.tres")
	assert_not_null(eq, "steel_mace.tres should load")
	assert_eq(eq.id, &"steel_mace")
	assert_eq(eq.slot_type, EquipmentData.SlotType.WEAPON)
	assert_eq(eq.weapon_type, EquipmentData.WeaponType.MACE)
	assert_gt(eq.attack_bonus, 0, "Should boost attack")


func test_iron_helm_loads() -> void:
	var eq: EquipmentData = load("res://data/equipment/iron_helm.tres")
	assert_not_null(eq, "iron_helm.tres should load")
	assert_eq(eq.id, &"iron_helm")
	assert_eq(eq.slot_type, EquipmentData.SlotType.HELMET)
	assert_gt(eq.defense_bonus, 0, "Should boost defense")
	assert_gt(eq.buy_price, 0, "Should have a buy price")


func test_shop_buy_prices_reasonable() -> void:
	for item in _shop.get_items():
		var price := _shop.get_buy_price(item)
		assert_gt(price, 0, "%s should have a buy price > 0" % item.display_name)

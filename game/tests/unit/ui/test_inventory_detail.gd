extends GutTest

## Tests for InventoryUIDetail static methods.
## Validates equipment stat formatting and item detail computation.

const DetailScript := preload(
	"res://ui/inventory_ui/inventory_ui_detail.gd"
)
const Helpers := preload("res://tests/helpers/test_helpers.gd")


# -- compute_equipment_stats --


func test_compute_equipment_stats_all_bonuses() -> void:
	var equip := Helpers.make_equipment({
		"slot_type": EquipmentData.SlotType.WEAPON,
		"attack_bonus": 10,
		"magic_bonus": 5,
		"defense_bonus": 3,
		"resistance_bonus": 2,
		"speed_bonus": 1,
		"luck_bonus": 4,
		"max_hp_bonus": 20,
		"max_ee_bonus": 15,
		"sell_price": 100,
	})
	var stats := DetailScript.compute_equipment_stats(equip)
	assert_true(stats.size() >= 9, "All stats + sell")
	assert_true(
		stats.has("ATK: +10"), "Should include ATK",
	)
	assert_true(
		stats.has("MAG: +5"), "Should include MAG",
	)
	assert_true(
		stats.has("HP: +20"), "Should include HP",
	)
	assert_true(
		stats.has("EE: +15"), "Should include EE",
	)


func test_compute_equipment_stats_only_nonzero() -> void:
	var equip := Helpers.make_equipment({
		"attack_bonus": 5,
		"sell_price": 0,
	})
	var stats := DetailScript.compute_equipment_stats(equip)
	var has_def := false
	for s: String in stats:
		if s.begins_with("DEF:"):
			has_def = true
	assert_false(has_def, "Zero DEF should not appear")
	var has_sell := false
	for s: String in stats:
		if s.begins_with("Sell:"):
			has_sell = true
	assert_false(has_sell, "Zero sell should not appear")


func test_compute_equipment_stats_slot_name() -> void:
	var equip := Helpers.make_equipment({
		"slot_type": EquipmentData.SlotType.CHEST,
	})
	var stats := DetailScript.compute_equipment_stats(equip)
	assert_true(stats.size() >= 1, "Should have slot line")
	assert_eq(
		stats[0], "Slot: Chest",
		"Should show Chest slot name",
	)


func test_compute_equipment_stats_sell_price() -> void:
	var equip := Helpers.make_equipment({"sell_price": 50})
	var stats := DetailScript.compute_equipment_stats(equip)
	assert_true(
		stats.has("Sell: 50 gold"),
		"Should include sell price",
	)


func test_compute_equipment_stats_hp_ee_bonuses() -> void:
	var equip := Helpers.make_equipment({
		"max_hp_bonus": 25,
		"max_ee_bonus": 10,
	})
	var stats := DetailScript.compute_equipment_stats(equip)
	assert_true(stats.has("HP: +25"), "HP bonus shown")
	assert_true(stats.has("EE: +10"), "EE bonus shown")


# -- compute_item_detail --


func test_compute_item_detail_consumable() -> void:
	var item := Helpers.make_item({
		"display_name": "Potion",
		"item_type": ItemData.ItemType.CONSUMABLE,
	})
	item.description = "Restores 50 HP"
	var entry := {
		"id": &"potion",
		"count": 3,
		"data": item,
		"is_equipment": false,
		"display_name": "Potion",
	}
	var detail := DetailScript.compute_item_detail(entry)
	assert_eq(detail["name"], "Potion")
	assert_eq(detail["description"], "Restores 50 HP")
	assert_true(detail["show_use"], "Consumable is usable")
	assert_false(
		detail["show_equip"], "Consumable is not equippable",
	)


func test_compute_item_detail_equipment() -> void:
	var equip := Helpers.make_equipment({
		"display_name": "Iron Sword",
	})
	equip.description = "A sturdy blade"
	var entry := {
		"id": &"iron_sword",
		"count": 1,
		"data": equip,
		"is_equipment": true,
		"display_name": "Iron Sword",
	}
	var detail := DetailScript.compute_item_detail(entry)
	assert_eq(detail["name"], "Iron Sword")
	assert_eq(detail["description"], "A sturdy blade")
	assert_false(detail["show_use"], "Equipment not usable")
	assert_true(
		detail["show_equip"], "Equipment is equippable",
	)


func test_compute_item_detail_key_item() -> void:
	var item := Helpers.make_item({
		"display_name": "Old Map",
		"item_type": ItemData.ItemType.KEY_ITEM,
	})
	var entry := {
		"id": &"old_map",
		"count": 1,
		"data": item,
		"is_equipment": false,
		"display_name": "Old Map",
	}
	var detail := DetailScript.compute_item_detail(entry)
	assert_false(
		detail["show_use"], "Key items are not usable",
	)
	assert_false(
		detail["show_equip"], "Key items not equippable",
	)


func test_compute_item_detail_empty_entry() -> void:
	var detail := DetailScript.compute_item_detail({})
	assert_eq(detail["name"], "", "Empty entry -> empty name")
	assert_false(detail["show_use"])
	assert_false(detail["show_equip"])


func test_compute_item_detail_missing_data() -> void:
	var entry := {"id": &"broken", "is_equipment": false}
	var detail := DetailScript.compute_item_detail(entry)
	assert_eq(
		detail["name"], "",
		"Missing data -> empty name",
	)
	assert_false(detail["show_use"])
	assert_false(detail["show_equip"])

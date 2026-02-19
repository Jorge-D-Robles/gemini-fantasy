extends GutTest

## Tests for ShopUIDetail static methods.
## Validates equipment stat formatting, item effect text, and detail info.

const DetailScript := preload(
	"res://ui/shop_ui/shop_ui_detail.gd"
)
const Helpers := preload("res://tests/helpers/test_helpers.gd")


# -- compute_equip_stat_lines --


func test_compute_equip_stat_lines_all_bonuses() -> void:
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
	})
	var lines := DetailScript.compute_equip_stat_lines(equip)
	assert_true(lines.size() >= 9, "8 stats + slot")
	assert_true(lines.has("ATK: +10"), "Should include ATK")
	assert_true(lines.has("MAG: +5"), "Should include MAG")
	assert_true(lines.has("DEF: +3"), "Should include DEF")
	assert_true(lines.has("HP: +20"), "Should include HP")
	assert_true(lines.has("EE: +15"), "Should include EE")
	assert_true(
		lines.has("Slot: Weapon"),
		"Should include slot name",
	)


func test_compute_equip_stat_lines_only_nonzero() -> void:
	var equip := Helpers.make_equipment({
		"attack_bonus": 5,
	})
	var lines := DetailScript.compute_equip_stat_lines(equip)
	assert_true(lines.has("ATK: +5"), "ATK present")
	var has_def := false
	for s: String in lines:
		if s.begins_with("DEF:"):
			has_def = true
	assert_false(has_def, "Zero DEF should not appear")
	var has_mag := false
	for s: String in lines:
		if s.begins_with("MAG:"):
			has_mag = true
	assert_false(has_mag, "Zero MAG should not appear")


func test_compute_equip_stat_lines_slot_name() -> void:
	var equip := Helpers.make_equipment({
		"slot_type": EquipmentData.SlotType.CHEST,
	})
	var lines := DetailScript.compute_equip_stat_lines(equip)
	assert_true(
		lines.has("Slot: Chest"),
		"Should show Chest slot name",
	)
	# Slot should be last
	assert_eq(
		lines[lines.size() - 1], "Slot: Chest",
		"Slot name should be the last entry",
	)


# -- compute_item_effect_text --


func test_compute_item_effect_text_heal_hp() -> void:
	var item := Helpers.make_item({
		"effect_type": ItemData.EffectType.HEAL_HP,
		"effect_value": 50,
	})
	var text := DetailScript.compute_item_effect_text(item)
	assert_eq(text, "Restores 50 HP")


func test_compute_item_effect_text_heal_ee() -> void:
	var item := Helpers.make_item({
		"effect_type": ItemData.EffectType.HEAL_EE,
		"effect_value": 30,
	})
	var text := DetailScript.compute_item_effect_text(item)
	assert_eq(text, "Restores 30 EE")


func test_compute_item_effect_text_damage() -> void:
	var item := Helpers.make_item({
		"effect_type": ItemData.EffectType.DAMAGE,
		"effect_value": 40,
	})
	var text := DetailScript.compute_item_effect_text(item)
	assert_eq(text, "Deals 40 damage")


func test_compute_item_effect_text_cure_hollow() -> void:
	var item := Helpers.make_item({
		"effect_type": ItemData.EffectType.CURE_HOLLOW,
	})
	var text := DetailScript.compute_item_effect_text(item)
	assert_eq(text, "Cures Hollow status")


func test_compute_item_effect_text_cure_status() -> void:
	var item := Helpers.make_item({
		"effect_type": ItemData.EffectType.CURE_STATUS,
	})
	var text := DetailScript.compute_item_effect_text(item)
	assert_eq(text, "Cures status ailments")


func test_compute_item_effect_text_revive() -> void:
	var item := Helpers.make_item({
		"effect_type": ItemData.EffectType.REVIVE,
	})
	var text := DetailScript.compute_item_effect_text(item)
	assert_eq(text, "Revives fallen ally")


func test_compute_item_effect_text_buff() -> void:
	var item := Helpers.make_item({
		"effect_type": ItemData.EffectType.BUFF,
	})
	var text := DetailScript.compute_item_effect_text(item)
	assert_eq(text, "Grants a buff")


# -- compute_detail_info --


func test_compute_detail_info_buy_mode() -> void:
	var item := Helpers.make_item({
		"display_name": "Potion",
	})
	item.description = "Heals HP"
	var info := DetailScript.compute_detail_info(
		item, DetailScript.MODE_BUY, 100, 0,
	)
	assert_eq(info["name"], "Potion")
	assert_eq(info["description"], "Heals HP")
	assert_eq(info["price_text"], "Buy: 100 G")
	assert_true(info["is_buy"])
	assert_eq(info["action_text"], "Buy")


func test_compute_detail_info_sell_mode() -> void:
	var equip := Helpers.make_equipment({
		"display_name": "Iron Sword",
	})
	equip.description = "A sturdy blade"
	var info := DetailScript.compute_detail_info(
		equip, DetailScript.MODE_SELL, 0, 50,
	)
	assert_eq(info["name"], "Iron Sword")
	assert_eq(info["description"], "A sturdy blade")
	assert_eq(info["price_text"], "Sell: +50 G")
	assert_false(info["is_buy"])
	assert_eq(info["action_text"], "Sell")

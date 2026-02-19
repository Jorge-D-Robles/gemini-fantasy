class_name ShopUIDetail
extends RefCounted

## Static utilities for shop detail panel computation.
## Note: InventoryUIDetail.compute_equipment_stats() provides similar
## equip stat formatting but with slot-first ordering and sell price.
## This class uses stats-first/slot-last ordering without sell price,
## matching the shop UI layout.

const MODE_BUY := 0
const MODE_SELL := 1


static func compute_equip_stat_lines(
	equip: EquipmentData,
) -> Array[String]:
	var lines: Array[String] = []
	var stats: Array[Array] = [
		["ATK", equip.attack_bonus],
		["MAG", equip.magic_bonus],
		["DEF", equip.defense_bonus],
		["RES", equip.resistance_bonus],
		["SPD", equip.speed_bonus],
		["LCK", equip.luck_bonus],
		["HP", equip.max_hp_bonus],
		["EE", equip.max_ee_bonus],
	]
	for stat_pair in stats:
		var val: int = stat_pair[1]
		if val == 0:
			continue
		lines.append("%s: +%d" % [stat_pair[0], val])

	var slot_name: String = ""
	match equip.slot_type:
		EquipmentData.SlotType.WEAPON:
			slot_name = "Weapon"
		EquipmentData.SlotType.HELMET:
			slot_name = "Helmet"
		EquipmentData.SlotType.CHEST:
			slot_name = "Chest"
		EquipmentData.SlotType.ACCESSORY:
			slot_name = "Accessory"
	if not slot_name.is_empty():
		lines.append("Slot: %s" % slot_name)

	return lines


static func compute_item_effect_text(item: ItemData) -> String:
	match item.effect_type:
		ItemData.EffectType.HEAL_HP:
			return "Restores %d HP" % item.effect_value
		ItemData.EffectType.HEAL_EE:
			return "Restores %d EE" % item.effect_value
		ItemData.EffectType.CURE_STATUS:
			return "Cures status ailments"
		ItemData.EffectType.REVIVE:
			return "Revives fallen ally"
		ItemData.EffectType.BUFF:
			return "Grants a buff"
		ItemData.EffectType.DAMAGE:
			return "Deals %d damage" % item.effect_value
		ItemData.EffectType.CURE_HOLLOW:
			return "Cures Hollow status"
	return ""


static func compute_detail_info(
	item: Resource,
	mode: int,
	buy_price: int,
	sell_price: int,
) -> Dictionary:
	var name_text: String = ""
	var desc_text: String = ""
	if item and "display_name" in item:
		name_text = item.display_name
	elif item:
		name_text = "???"
	if item and "description" in item:
		desc_text = item.description

	var is_buy: bool = mode != MODE_SELL
	var price_text: String = ""
	var action_text: String = ""
	if is_buy:
		price_text = "Buy: %d G" % buy_price
		action_text = "Buy"
	else:
		price_text = "Sell: +%d G" % sell_price
		action_text = "Sell"

	return {
		"name": name_text,
		"description": desc_text,
		"price_text": price_text,
		"is_buy": is_buy,
		"action_text": action_text,
	}

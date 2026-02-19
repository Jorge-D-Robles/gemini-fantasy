class_name InventoryUIDetail
extends RefCounted

## Static utilities for inventory detail panel computation.
## No instance state — all methods are static. Do not instantiate.


## Returns formatted stat lines for an equipment piece.
## Uses EquipmentData.SlotType enum for slot name lookup.
## Includes max_hp_bonus and max_ee_bonus.
static func compute_equipment_stats(
	equip: EquipmentData,
) -> Array[String]:
	var lines: Array[String] = []
	match equip.slot_type:
		EquipmentData.SlotType.WEAPON:
			lines.append("Slot: Weapon")
		EquipmentData.SlotType.HELMET:
			lines.append("Slot: Helmet")
		EquipmentData.SlotType.CHEST:
			lines.append("Slot: Chest")
		EquipmentData.SlotType.ACCESSORY:
			lines.append("Slot: Accessory")
	if equip.max_hp_bonus != 0:
		lines.append("HP: +%d" % equip.max_hp_bonus)
	if equip.max_ee_bonus != 0:
		lines.append("EE: +%d" % equip.max_ee_bonus)
	if equip.attack_bonus != 0:
		lines.append("ATK: +%d" % equip.attack_bonus)
	if equip.magic_bonus != 0:
		lines.append("MAG: +%d" % equip.magic_bonus)
	if equip.defense_bonus != 0:
		lines.append("DEF: +%d" % equip.defense_bonus)
	if equip.resistance_bonus != 0:
		lines.append("RES: +%d" % equip.resistance_bonus)
	if equip.speed_bonus != 0:
		lines.append("SPD: +%d" % equip.speed_bonus)
	if equip.luck_bonus != 0:
		lines.append("LCK: +%d" % equip.luck_bonus)
	if equip.sell_price > 0:
		lines.append("Sell: %d gold" % equip.sell_price)
	return lines


## Returns detail display data for an inventory entry.
## Guards against empty or malformed entry dicts.
## Does NOT call compute_equipment_stats — caller handles
## equipment stats separately.
static func compute_item_detail(
	entry: Dictionary,
) -> Dictionary:
	var default := {
		"name": "",
		"description": "",
		"stats": [] as Array[String],
		"show_use": false,
		"show_equip": false,
	}
	if entry.is_empty():
		return default
	if not entry.has("data"):
		return default

	var data: Resource = entry.get("data")
	if not data:
		return default

	var is_equipment: bool = entry.get(
		"is_equipment", false
	)
	var name_str: String = entry.get("display_name", "")

	if is_equipment:
		var equip := data as EquipmentData
		if not equip:
			return default
		return {
			"name": name_str,
			"description": equip.description,
			"stats": [] as Array[String],
			"show_use": false,
			"show_equip": true,
		}

	var item := data as ItemData
	if not item:
		return default
	var stats: Array[String] = []
	if item.sell_price > 0:
		stats.append("Sell: %d gold" % item.sell_price)
	var is_consumable: bool = (
		item.item_type == ItemData.ItemType.CONSUMABLE
	)
	return {
		"name": name_str,
		"description": item.description,
		"stats": stats,
		"show_use": is_consumable,
		"show_equip": false,
	}

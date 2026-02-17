extends Node

## NOTE: No class_name — autoloads are already global singletons.
## Manages equipped items per character. Tracks weapon, helmet, chest,
## and two accessory slots for each party member.

signal equipment_changed(character_id: StringName, slot: String)

## Per-character equipment: { StringName -> { slot_key -> EquipmentData } }
var _equipment: Dictionary = {}


func equip(
	character_id: StringName,
	equipment: EquipmentData,
) -> EquipmentData:
	if equipment == null:
		return null
	var slot_key := _slot_type_to_key(equipment.slot_type)
	if slot_key == "accessory":
		return equip_accessory(character_id, equipment, 0)
	var slots := _get_or_create_slots(character_id)
	var old: EquipmentData = slots.get(slot_key)
	slots[slot_key] = equipment
	equipment_changed.emit(character_id, slot_key)
	return old


func unequip(
	character_id: StringName,
	slot_type: EquipmentData.SlotType,
) -> EquipmentData:
	var slot_key := _slot_type_to_key(slot_type)
	if slot_key == "accessory":
		return unequip_accessory(character_id, 0)
	var slots := _get_or_create_slots(character_id)
	var old: EquipmentData = slots.get(slot_key)
	slots[slot_key] = null
	if old:
		equipment_changed.emit(character_id, slot_key)
	return old


func equip_accessory(
	character_id: StringName,
	equipment: EquipmentData,
	index: int,
) -> EquipmentData:
	if equipment == null or index < 0 or index > 1:
		return null
	var slots := _get_or_create_slots(character_id)
	var key := "accessory_%d" % index
	var old: EquipmentData = slots.get(key)
	slots[key] = equipment
	equipment_changed.emit(character_id, key)
	return old


func unequip_accessory(
	character_id: StringName,
	index: int,
) -> EquipmentData:
	if index < 0 or index > 1:
		return null
	var slots := _get_or_create_slots(character_id)
	var key := "accessory_%d" % index
	var old: EquipmentData = slots.get(key)
	slots[key] = null
	if old:
		equipment_changed.emit(character_id, key)
	return old


func get_equipment(
	character_id: StringName,
	slot_type: EquipmentData.SlotType,
) -> EquipmentData:
	var slot_key := _slot_type_to_key(slot_type)
	if slot_key == "accessory":
		return get_accessory(character_id, 0)
	var slots := _get_or_create_slots(character_id)
	return slots.get(slot_key)


func get_accessory(
	character_id: StringName,
	index: int,
) -> EquipmentData:
	if index < 0 or index > 1:
		return null
	var slots := _get_or_create_slots(character_id)
	return slots.get("accessory_%d" % index)


func get_all_equipment(character_id: StringName) -> Dictionary:
	var slots := _get_or_create_slots(character_id)
	return {
		"weapon": slots.get("weapon"),
		"helmet": slots.get("helmet"),
		"chest": slots.get("chest"),
		"accessory_0": slots.get("accessory_0"),
		"accessory_1": slots.get("accessory_1"),
	}


func get_stat_bonuses(character_id: StringName) -> Dictionary:
	var bonuses := {
		"attack": 0,
		"magic": 0,
		"defense": 0,
		"resistance": 0,
		"speed": 0,
		"luck": 0,
		"max_hp": 0,
		"max_ee": 0,
	}
	var slots := _get_or_create_slots(character_id)
	for key: String in slots:
		var item: EquipmentData = slots[key]
		if item == null:
			continue
		bonuses["attack"] += item.attack_bonus
		bonuses["magic"] += item.magic_bonus
		bonuses["defense"] += item.defense_bonus
		bonuses["resistance"] += item.resistance_bonus
		bonuses["speed"] += item.speed_bonus
		bonuses["luck"] += item.luck_bonus
		bonuses["max_hp"] += item.max_hp_bonus
		bonuses["max_ee"] += item.max_ee_bonus
	return bonuses


func can_equip_weapon(
	character: CharacterData,
	equipment: EquipmentData,
) -> bool:
	if equipment == null or character == null:
		return false
	if equipment.slot_type != EquipmentData.SlotType.WEAPON:
		return true
	if character.allowed_weapon_types.is_empty():
		return true
	return equipment.weapon_type in character.allowed_weapon_types


func clear_equipment(
	character_id: StringName,
) -> Array[EquipmentData]:
	var removed: Array[EquipmentData] = []
	var slots := _get_or_create_slots(character_id)
	for key: String in slots:
		var item: EquipmentData = slots[key]
		if item:
			removed.append(item)
			slots[key] = null
	if not removed.is_empty():
		equipment_changed.emit(character_id, "all")
	return removed


func serialize() -> Dictionary:
	var data := {}
	for character_id: StringName in _equipment:
		var slots: Dictionary = _equipment[character_id]
		var entry := {}
		for key: String in ["weapon", "helmet", "chest",
				"accessory_0", "accessory_1"]:
			var item: EquipmentData = slots.get(key)
			entry[key] = String(item.id) if item else ""
		data[String(character_id)] = entry
	return data


func deserialize(data: Dictionary) -> void:
	_equipment.clear()
	for char_id_str: String in data:
		var char_id := StringName(char_id_str)
		var entry: Dictionary = data[char_id_str]
		var slots := _get_or_create_slots(char_id)
		for key: String in ["weapon", "helmet", "chest",
				"accessory_0", "accessory_1"]:
			var equip_id: String = entry.get(key, "")
			if equip_id.is_empty():
				continue
			var path := "res://data/equipment/%s.tres" % equip_id
			if not ResourceLoader.exists(path):
				push_warning(
					"EquipmentManager: equipment file not found "
					+ "'%s'" % path
				)
				continue
			var loaded := load(path) as EquipmentData
			if loaded:
				slots[key] = loaded


func _get_or_create_slots(character_id: StringName) -> Dictionary:
	if character_id not in _equipment:
		_equipment[character_id] = {
			"weapon": null,
			"helmet": null,
			"chest": null,
			"accessory_0": null,
			"accessory_1": null,
		}
	return _equipment[character_id]


func _slot_type_to_key(slot_type: EquipmentData.SlotType) -> String:
	match slot_type:
		EquipmentData.SlotType.WEAPON:
			return "weapon"
		EquipmentData.SlotType.HELMET:
			return "helmet"
		EquipmentData.SlotType.CHEST:
			return "chest"
		EquipmentData.SlotType.ACCESSORY:
			return "accessory"
		_:
			return "weapon"

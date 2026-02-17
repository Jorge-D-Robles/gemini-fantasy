extends GutTest

## Tests for EquipmentManager autoload.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _manager: Node
var _sword: EquipmentData
var _helmet: EquipmentData
var _chest: EquipmentData
var _ring: EquipmentData
var _necklace: EquipmentData


func before_each() -> void:
	_manager = load("res://autoloads/equipment_manager.gd").new()
	add_child_autofree(_manager)

	_sword = Helpers.make_equipment({
		"id": &"iron_sword",
		"display_name": "Iron Sword",
		"slot_type": EquipmentData.SlotType.WEAPON,
		"weapon_type": EquipmentData.WeaponType.SWORD,
		"attack_bonus": 10,
	})
	_helmet = Helpers.make_equipment({
		"id": &"iron_helmet",
		"display_name": "Iron Helmet",
		"slot_type": EquipmentData.SlotType.HELMET,
		"defense_bonus": 5,
		"resistance_bonus": 2,
	})
	_chest = Helpers.make_equipment({
		"id": &"iron_chest",
		"display_name": "Iron Chestplate",
		"slot_type": EquipmentData.SlotType.CHEST,
		"defense_bonus": 8,
		"max_hp_bonus": 20,
	})
	_ring = Helpers.make_equipment({
		"id": &"speed_ring",
		"display_name": "Speed Ring",
		"slot_type": EquipmentData.SlotType.ACCESSORY,
		"speed_bonus": 5,
	})
	_necklace = Helpers.make_equipment({
		"id": &"magic_necklace",
		"display_name": "Magic Necklace",
		"slot_type": EquipmentData.SlotType.ACCESSORY,
		"magic_bonus": 7,
	})


# --- Equip / Unequip ---


func test_equip_weapon() -> void:
	var old := _manager.equip(&"kael", _sword)
	assert_null(old)
	assert_eq(
		_manager.get_equipment(&"kael", EquipmentData.SlotType.WEAPON),
		_sword,
	)


func test_equip_replaces_existing() -> void:
	_manager.equip(&"kael", _sword)
	var better_sword := Helpers.make_equipment({
		"id": &"steel_sword",
		"slot_type": EquipmentData.SlotType.WEAPON,
		"weapon_type": EquipmentData.WeaponType.SWORD,
		"attack_bonus": 15,
	})
	var old := _manager.equip(&"kael", better_sword)
	assert_eq(old, _sword)
	assert_eq(
		_manager.get_equipment(&"kael", EquipmentData.SlotType.WEAPON),
		better_sword,
	)


func test_equip_all_slots() -> void:
	_manager.equip(&"kael", _sword)
	_manager.equip(&"kael", _helmet)
	_manager.equip(&"kael", _chest)
	_manager.equip_accessory(&"kael", _ring, 0)
	_manager.equip_accessory(&"kael", _necklace, 1)

	assert_eq(
		_manager.get_equipment(&"kael", EquipmentData.SlotType.WEAPON),
		_sword,
	)
	assert_eq(
		_manager.get_equipment(&"kael", EquipmentData.SlotType.HELMET),
		_helmet,
	)
	assert_eq(
		_manager.get_equipment(&"kael", EquipmentData.SlotType.CHEST),
		_chest,
	)
	assert_eq(_manager.get_accessory(&"kael", 0), _ring)
	assert_eq(_manager.get_accessory(&"kael", 1), _necklace)


func test_unequip_weapon() -> void:
	_manager.equip(&"kael", _sword)
	var removed := _manager.unequip(
		&"kael", EquipmentData.SlotType.WEAPON
	)
	assert_eq(removed, _sword)
	assert_null(
		_manager.get_equipment(&"kael", EquipmentData.SlotType.WEAPON)
	)


func test_unequip_empty_slot_returns_null() -> void:
	var removed := _manager.unequip(
		&"kael", EquipmentData.SlotType.WEAPON
	)
	assert_null(removed)


func test_unequip_accessory() -> void:
	_manager.equip_accessory(&"kael", _ring, 0)
	var removed := _manager.unequip_accessory(&"kael", 0)
	assert_eq(removed, _ring)
	assert_null(_manager.get_accessory(&"kael", 0))


func test_equip_accessory_replaces_existing() -> void:
	_manager.equip_accessory(&"kael", _ring, 0)
	var old := _manager.equip_accessory(&"kael", _necklace, 0)
	assert_eq(old, _ring)
	assert_eq(_manager.get_accessory(&"kael", 0), _necklace)


# --- Stat Bonuses ---


func test_stat_bonuses_empty() -> void:
	var bonuses := _manager.get_stat_bonuses(&"kael")
	assert_eq(bonuses["attack"], 0)
	assert_eq(bonuses["magic"], 0)
	assert_eq(bonuses["defense"], 0)
	assert_eq(bonuses["resistance"], 0)
	assert_eq(bonuses["speed"], 0)
	assert_eq(bonuses["luck"], 0)
	assert_eq(bonuses["max_hp"], 0)
	assert_eq(bonuses["max_ee"], 0)


func test_stat_bonuses_single_item() -> void:
	_manager.equip(&"kael", _sword)
	var bonuses := _manager.get_stat_bonuses(&"kael")
	assert_eq(bonuses["attack"], 10)
	assert_eq(bonuses["defense"], 0)


func test_stat_bonuses_all_slots_combined() -> void:
	_manager.equip(&"kael", _sword)
	_manager.equip(&"kael", _helmet)
	_manager.equip(&"kael", _chest)
	_manager.equip_accessory(&"kael", _ring, 0)
	_manager.equip_accessory(&"kael", _necklace, 1)

	var bonuses := _manager.get_stat_bonuses(&"kael")
	assert_eq(bonuses["attack"], 10)  # sword
	assert_eq(bonuses["magic"], 7)  # necklace
	assert_eq(bonuses["defense"], 13)  # helmet(5) + chest(8)
	assert_eq(bonuses["resistance"], 2)  # helmet
	assert_eq(bonuses["speed"], 5)  # ring
	assert_eq(bonuses["max_hp"], 20)  # chest


# --- Signals ---


func test_equipment_changed_signal_on_equip() -> void:
	watch_signals(_manager)
	_manager.equip(&"kael", _sword)
	assert_signal_emitted(_manager, "equipment_changed")


func test_equipment_changed_signal_on_unequip() -> void:
	_manager.equip(&"kael", _sword)
	watch_signals(_manager)
	_manager.unequip(&"kael", EquipmentData.SlotType.WEAPON)
	assert_signal_emitted(_manager, "equipment_changed")


# --- Multiple Characters ---


func test_separate_equipment_per_character() -> void:
	var staff := Helpers.make_equipment({
		"id": &"oak_staff",
		"slot_type": EquipmentData.SlotType.WEAPON,
		"weapon_type": EquipmentData.WeaponType.STAFF,
		"magic_bonus": 8,
	})
	_manager.equip(&"kael", _sword)
	_manager.equip(&"nyx", staff)

	assert_eq(
		_manager.get_equipment(&"kael", EquipmentData.SlotType.WEAPON),
		_sword,
	)
	assert_eq(
		_manager.get_equipment(&"nyx", EquipmentData.SlotType.WEAPON),
		staff,
	)


# --- Get All Equipment ---


func test_get_all_equipment() -> void:
	_manager.equip(&"kael", _sword)
	_manager.equip(&"kael", _helmet)
	var all_equip := _manager.get_all_equipment(&"kael")
	assert_eq(all_equip["weapon"], _sword)
	assert_eq(all_equip["helmet"], _helmet)
	assert_null(all_equip["chest"])
	assert_null(all_equip["accessory_0"])
	assert_null(all_equip["accessory_1"])


func test_get_all_equipment_empty_character() -> void:
	var all_equip := _manager.get_all_equipment(&"nobody")
	assert_null(all_equip["weapon"])
	assert_null(all_equip["helmet"])
	assert_null(all_equip["chest"])
	assert_null(all_equip["accessory_0"])
	assert_null(all_equip["accessory_1"])


# --- Clear Equipment ---


func test_clear_character_equipment() -> void:
	_manager.equip(&"kael", _sword)
	_manager.equip(&"kael", _helmet)
	_manager.equip_accessory(&"kael", _ring, 0)

	var removed := _manager.clear_equipment(&"kael")
	assert_eq(removed.size(), 3)
	assert_null(
		_manager.get_equipment(&"kael", EquipmentData.SlotType.WEAPON)
	)
	assert_null(
		_manager.get_equipment(&"kael", EquipmentData.SlotType.HELMET)
	)
	assert_null(_manager.get_accessory(&"kael", 0))


# --- Serialization ---


func test_serialize_equipment() -> void:
	_manager.equip(&"kael", _sword)
	_manager.equip(&"kael", _helmet)
	_manager.equip_accessory(&"kael", _ring, 0)

	var data := _manager.serialize()
	assert_has(data, "kael")
	var kael_data: Dictionary = data["kael"]
	assert_eq(kael_data["weapon"], "iron_sword")
	assert_eq(kael_data["helmet"], "iron_helmet")
	assert_eq(kael_data["chest"], "")
	assert_eq(kael_data["accessory_0"], "speed_ring")
	assert_eq(kael_data["accessory_1"], "")


func test_deserialize_equipment() -> void:
	var data := {
		"kael": {
			"weapon": "iron_sword",
			"helmet": "",
			"chest": "",
			"accessory_0": "",
			"accessory_1": "",
		},
	}
	# Deserialization requires .tres files to exist — tested
	# in integration tests. Here we test the structure is accepted.
	_manager.deserialize(data)
	# After deserialization with nonexistent .tres files,
	# slots remain null (graceful failure).
	# Full integration test would verify actual loading.

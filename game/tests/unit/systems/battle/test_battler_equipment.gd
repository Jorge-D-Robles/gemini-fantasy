extends GutTest

## Tests for Battler stat loading with equipment bonuses.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _equip_mgr: Node
var _battler: Battler


func before_each() -> void:
	_equip_mgr = load("res://autoloads/equipment_manager.gd").new()
	_equip_mgr.name = "EquipmentManager"
	add_child_autofree(_equip_mgr)

	_battler = Battler.new()
	add_child_autofree(_battler)


func test_stats_include_weapon_bonus() -> void:
	var sword := Helpers.make_equipment({
		"id": &"iron_sword",
		"slot_type": EquipmentData.SlotType.WEAPON,
		"attack_bonus": 10,
	})
	_equip_mgr.equip(&"test_char", sword)

	var char_data := CharacterData.new()
	char_data.id = &"test_char"
	char_data.attack = 20
	char_data.level = 1
	char_data.attack_growth = 0.0
	_battler.data = char_data
	_battler.initialize_from_data(_equip_mgr)

	assert_eq(_battler.attack, 30)  # 20 base + 10 weapon


func test_stats_include_all_equipment_bonuses() -> void:
	var sword := Helpers.make_equipment({
		"id": &"sword",
		"slot_type": EquipmentData.SlotType.WEAPON,
		"attack_bonus": 10,
	})
	var helmet := Helpers.make_equipment({
		"id": &"helmet",
		"slot_type": EquipmentData.SlotType.HELMET,
		"defense_bonus": 5,
		"resistance_bonus": 3,
	})
	var chest := Helpers.make_equipment({
		"id": &"chest",
		"slot_type": EquipmentData.SlotType.CHEST,
		"defense_bonus": 8,
		"max_hp_bonus": 20,
	})
	_equip_mgr.equip(&"test_char", sword)
	_equip_mgr.equip(&"test_char", helmet)
	_equip_mgr.equip(&"test_char", chest)

	var char_data := CharacterData.new()
	char_data.id = &"test_char"
	char_data.max_hp = 100
	char_data.attack = 20
	char_data.defense = 10
	char_data.resistance = 10
	char_data.level = 1
	char_data.hp_growth = 0.0
	char_data.attack_growth = 0.0
	char_data.defense_growth = 0.0
	char_data.resistance_growth = 0.0
	_battler.data = char_data
	_battler.initialize_from_data(_equip_mgr)

	assert_eq(_battler.attack, 30)  # 20 + 10
	assert_eq(_battler.defense, 23)  # 10 + 5 + 8
	assert_eq(_battler.resistance, 13)  # 10 + 3
	assert_eq(_battler.max_hp, 120)  # 100 + 20


func test_stats_without_equipment_manager() -> void:
	# When no equipment manager is passed, stats are base only
	var char_data := CharacterData.new()
	char_data.id = &"test_char"
	char_data.attack = 20
	char_data.level = 1
	char_data.attack_growth = 0.0
	_battler.data = char_data
	_battler.initialize_from_data()

	assert_eq(_battler.attack, 20)


func test_enemy_stats_ignore_equipment() -> void:
	# Enemies don't have equipment
	var enemy_data := Helpers.make_enemy_data({
		"id": &"goblin",
		"attack": 15,
	})
	_battler.data = enemy_data
	_battler.initialize_from_data(_equip_mgr)

	assert_eq(_battler.attack, 15)  # No equipment bonus


func test_accessory_bonuses() -> void:
	var ring := Helpers.make_equipment({
		"id": &"ring",
		"slot_type": EquipmentData.SlotType.ACCESSORY,
		"speed_bonus": 5,
		"luck_bonus": 3,
	})
	_equip_mgr.equip_accessory(&"test_char", ring, 0)

	var char_data := CharacterData.new()
	char_data.id = &"test_char"
	char_data.speed = 10
	char_data.luck = 10
	char_data.level = 1
	char_data.speed_growth = 0.0
	char_data.luck_growth = 0.0
	_battler.data = char_data
	_battler.initialize_from_data(_equip_mgr)

	assert_eq(_battler.speed, 15)  # 10 + 5
	assert_eq(_battler.luck, 13)  # 10 + 3

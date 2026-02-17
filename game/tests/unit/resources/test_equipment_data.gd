extends GutTest

## Tests for EquipmentData resource class.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _equipment: EquipmentData


func before_each() -> void:
	_equipment = Helpers.make_equipment()


func test_default_values() -> void:
	var e := EquipmentData.new()
	assert_eq(e.id, &"")
	assert_eq(e.display_name, "")
	assert_eq(e.slot_type, EquipmentData.SlotType.WEAPON)
	assert_eq(e.weapon_type, EquipmentData.WeaponType.NONE)
	assert_eq(e.attack_bonus, 0)
	assert_eq(e.magic_bonus, 0)
	assert_eq(e.defense_bonus, 0)
	assert_eq(e.resistance_bonus, 0)
	assert_eq(e.speed_bonus, 0)
	assert_eq(e.luck_bonus, 0)
	assert_eq(e.max_hp_bonus, 0)
	assert_eq(e.max_ee_bonus, 0)
	assert_eq(e.element, AbilityData.Element.NONE)
	assert_eq(e.buy_price, 0)
	assert_eq(e.sell_price, 0)


func test_factory_creates_weapon() -> void:
	assert_eq(_equipment.id, &"test_sword")
	assert_eq(_equipment.display_name, "Test Sword")
	assert_eq(_equipment.slot_type, EquipmentData.SlotType.WEAPON)
	assert_eq(_equipment.attack_bonus, 0)


func test_factory_with_overrides() -> void:
	var e := Helpers.make_equipment({
		"id": &"iron_helmet",
		"display_name": "Iron Helmet",
		"slot_type": EquipmentData.SlotType.HELMET,
		"defense_bonus": 8,
		"resistance_bonus": 3,
	})
	assert_eq(e.id, &"iron_helmet")
	assert_eq(e.slot_type, EquipmentData.SlotType.HELMET)
	assert_eq(e.defense_bonus, 8)
	assert_eq(e.resistance_bonus, 3)
	assert_eq(e.attack_bonus, 0)


func test_slot_type_enum_values() -> void:
	assert_eq(EquipmentData.SlotType.WEAPON, 0)
	assert_eq(EquipmentData.SlotType.HELMET, 1)
	assert_eq(EquipmentData.SlotType.CHEST, 2)
	assert_eq(EquipmentData.SlotType.ACCESSORY, 3)


func test_weapon_type_enum_has_all_types() -> void:
	# Design doc specifies these weapon types
	assert_ne(EquipmentData.WeaponType.NONE, -1)
	assert_ne(EquipmentData.WeaponType.SWORD, -1)
	assert_ne(EquipmentData.WeaponType.DAGGER, -1)
	assert_ne(EquipmentData.WeaponType.HAMMER, -1)
	assert_ne(EquipmentData.WeaponType.RIFLE, -1)
	assert_ne(EquipmentData.WeaponType.SHIELD, -1)
	assert_ne(EquipmentData.WeaponType.MACE, -1)
	assert_ne(EquipmentData.WeaponType.STAFF, -1)
	assert_ne(EquipmentData.WeaponType.ORB, -1)
	assert_ne(EquipmentData.WeaponType.BOOK, -1)
	assert_ne(EquipmentData.WeaponType.ROD, -1)
	assert_ne(EquipmentData.WeaponType.DUAL_BLADES, -1)
	assert_ne(EquipmentData.WeaponType.HANDGUN, -1)
	assert_ne(EquipmentData.WeaponType.CRYSTAL, -1)
	assert_ne(EquipmentData.WeaponType.GRIMOIRE, -1)
	assert_ne(EquipmentData.WeaponType.BELL, -1)
	assert_ne(EquipmentData.WeaponType.TOTEM, -1)


func test_element_uses_ability_data_enum() -> void:
	var e := Helpers.make_equipment({
		"element": AbilityData.Element.FIRE,
	})
	assert_eq(e.element, AbilityData.Element.FIRE)


func test_accessory_slot() -> void:
	var e := Helpers.make_equipment({
		"id": &"speed_ring",
		"slot_type": EquipmentData.SlotType.ACCESSORY,
		"speed_bonus": 5,
		"luck_bonus": 3,
	})
	assert_eq(e.slot_type, EquipmentData.SlotType.ACCESSORY)
	assert_eq(e.speed_bonus, 5)
	assert_eq(e.luck_bonus, 3)

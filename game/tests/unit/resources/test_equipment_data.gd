extends GutTest

## Tests for EquipmentData resource class.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _equipment: EquipmentData


func before_each() -> void:
	_equipment = Helpers.make_equipment()


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

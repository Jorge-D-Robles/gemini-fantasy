extends GutTest

## Tests for AbilityData resource — defaults and enum coverage.


func test_default_values() -> void:
	var a := AbilityData.new()
	assert_eq(a.id, &"")
	assert_eq(a.display_name, "")
	assert_eq(a.description, "")
	assert_eq(a.ee_cost, 0)
	assert_almost_eq(a.resonance_cost, 0.0, 0.001)
	assert_eq(a.damage_base, 0)
	assert_eq(a.damage_stat, AbilityData.DamageStat.ATTACK)
	assert_eq(a.target_type, AbilityData.TargetType.SINGLE_ENEMY)
	assert_eq(a.element, AbilityData.Element.NONE)
	assert_eq(a.status_effect, "")
	assert_almost_eq(a.status_chance, 0.0, 0.001)
	assert_eq(a.animation_name, "")


func test_damage_stat_enum_values() -> void:
	assert_eq(AbilityData.DamageStat.ATTACK, 0)
	assert_eq(AbilityData.DamageStat.MAGIC, 1)


func test_target_type_enum_values() -> void:
	assert_eq(AbilityData.TargetType.SINGLE_ENEMY, 0)
	assert_eq(AbilityData.TargetType.ALL_ENEMIES, 1)
	assert_eq(AbilityData.TargetType.SINGLE_ALLY, 2)
	assert_eq(AbilityData.TargetType.ALL_ALLIES, 3)
	assert_eq(AbilityData.TargetType.SELF, 4)


func test_element_enum_values() -> void:
	assert_eq(AbilityData.Element.NONE, 0)
	assert_eq(AbilityData.Element.FIRE, 1)
	assert_eq(AbilityData.Element.ICE, 2)
	assert_eq(AbilityData.Element.WATER, 3)
	assert_eq(AbilityData.Element.WIND, 4)
	assert_eq(AbilityData.Element.EARTH, 5)
	assert_eq(AbilityData.Element.LIGHT, 6)
	assert_eq(AbilityData.Element.DARK, 7)


func test_set_custom_values() -> void:
	var a := AbilityData.new()
	a.id = &"fireball"
	a.display_name = "Fireball"
	a.ee_cost = 15
	a.damage_base = 40
	a.damage_stat = AbilityData.DamageStat.MAGIC
	a.element = AbilityData.Element.FIRE
	a.target_type = AbilityData.TargetType.ALL_ENEMIES
	a.status_effect = "burn"
	a.status_chance = 0.3
	assert_eq(a.id, &"fireball")
	assert_eq(a.display_name, "Fireball")
	assert_eq(a.ee_cost, 15)
	assert_eq(a.damage_base, 40)
	assert_eq(a.damage_stat, AbilityData.DamageStat.MAGIC)
	assert_eq(a.element, AbilityData.Element.FIRE)
	assert_eq(a.target_type, AbilityData.TargetType.ALL_ENEMIES)
	assert_eq(a.status_effect, "burn")
	assert_almost_eq(a.status_chance, 0.3, 0.001)

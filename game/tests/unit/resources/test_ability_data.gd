extends GutTest

## Tests for AbilityData resource — custom value assignment.


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

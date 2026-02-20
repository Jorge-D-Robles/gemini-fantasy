extends GutTest

## Tests for EnemyData resource — inheritance, cross-enum parity, and field assignment.


func test_inherits_battler_data() -> void:
	var e := EnemyData.new()
	assert_true(e is BattlerData)
	assert_true(e is Resource)


func test_element_enum_matches_ability_data_element() -> void:
	# EnemyData.Element and AbilityData.Element are separate enums
	# but their integer values must match for weakness/resistance checks.
	assert_eq(EnemyData.Element.FIRE, AbilityData.Element.FIRE)
	assert_eq(EnemyData.Element.ICE, AbilityData.Element.ICE)
	assert_eq(EnemyData.Element.WATER, AbilityData.Element.WATER)
	assert_eq(EnemyData.Element.WIND, AbilityData.Element.WIND)
	assert_eq(EnemyData.Element.EARTH, AbilityData.Element.EARTH)
	assert_eq(EnemyData.Element.LIGHT, AbilityData.Element.LIGHT)
	assert_eq(EnemyData.Element.DARK, AbilityData.Element.DARK)


func test_set_weaknesses_and_resistances() -> void:
	var e := EnemyData.new()
	var weak: Array[EnemyData.Element] = [
		EnemyData.Element.FIRE,
		EnemyData.Element.LIGHT,
	]
	var resist: Array[EnemyData.Element] = [
		EnemyData.Element.DARK,
	]
	e.weaknesses = weak
	e.resistances = resist
	assert_eq(e.weaknesses.size(), 2)
	assert_eq(e.resistances.size(), 1)
	assert_has(e.weaknesses, EnemyData.Element.FIRE)
	assert_has(e.resistances, EnemyData.Element.DARK)


func test_loot_table_structure() -> void:
	var e := EnemyData.new()
	e.loot_table = [
		{"item_id": "potion", "drop_chance": 0.5},
		{"item_id": "rare_gem", "drop_chance": 0.05},
	]
	assert_eq(e.loot_table.size(), 2)
	assert_eq(e.loot_table[0]["item_id"], "potion")
	assert_almost_eq(
		float(e.loot_table[0]["drop_chance"]), 0.5, 0.001
	)
	assert_eq(e.loot_table[1]["item_id"], "rare_gem")

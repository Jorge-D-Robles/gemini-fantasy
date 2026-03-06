extends GutTest

## Tests for elemental weakness/resistance damage modifiers.

const BD = preload("res://systems/battle/battler_damage.gd")
const GB = preload("res://systems/game_balance.gd")


func test_neutral_element_returns_1() -> void:
	var mod := BD.compute_elemental_modifier(
		AbilityData.Element.FIRE, [], [],
	)
	assert_eq(mod, 1.0, "No weakness or resistance should return 1.0")


func test_weakness_returns_bonus() -> void:
	var weaknesses: Array[EnemyData.Element] = [EnemyData.Element.FIRE]
	var mod := BD.compute_elemental_modifier(
		AbilityData.Element.FIRE, weaknesses, [],
	)
	assert_eq(mod, GB.ELEMENTAL_WEAKNESS_MULT, "Weakness should return bonus multiplier")


func test_resistance_returns_reduction() -> void:
	var resistances: Array[EnemyData.Element] = [EnemyData.Element.ICE]
	var mod := BD.compute_elemental_modifier(
		AbilityData.Element.ICE, [], resistances,
	)
	assert_eq(mod, GB.ELEMENTAL_RESISTANCE_MULT, "Resistance should return reduced multiplier")


func test_none_element_always_neutral() -> void:
	var weaknesses: Array[EnemyData.Element] = [EnemyData.Element.FIRE]
	var mod := BD.compute_elemental_modifier(
		AbilityData.Element.NONE, weaknesses, [],
	)
	assert_eq(mod, 1.0, "NONE element should always be neutral")


func test_weakness_takes_priority_over_resistance() -> void:
	var weaknesses: Array[EnemyData.Element] = [EnemyData.Element.FIRE]
	var resistances: Array[EnemyData.Element] = [EnemyData.Element.FIRE]
	var mod := BD.compute_elemental_modifier(
		AbilityData.Element.FIRE, weaknesses, resistances,
	)
	assert_eq(mod, GB.ELEMENTAL_WEAKNESS_MULT, "Weakness should take priority when both present")


func test_unmatched_element_returns_neutral() -> void:
	var weaknesses: Array[EnemyData.Element] = [EnemyData.Element.FIRE]
	var resistances: Array[EnemyData.Element] = [EnemyData.Element.ICE]
	var mod := BD.compute_elemental_modifier(
		AbilityData.Element.WIND, weaknesses, resistances,
	)
	assert_eq(mod, 1.0, "Unmatched element should be neutral")


func test_multiple_weaknesses() -> void:
	var weaknesses: Array[EnemyData.Element] = [
		EnemyData.Element.FIRE,
		EnemyData.Element.WIND,
	]
	var mod_fire := BD.compute_elemental_modifier(
		AbilityData.Element.FIRE, weaknesses, [],
	)
	var mod_wind := BD.compute_elemental_modifier(
		AbilityData.Element.WIND, weaknesses, [],
	)
	assert_eq(mod_fire, GB.ELEMENTAL_WEAKNESS_MULT)
	assert_eq(mod_wind, GB.ELEMENTAL_WEAKNESS_MULT)


func test_element_enum_mapping() -> void:
	# AbilityData.Element and EnemyData.Element have matching values
	assert_eq(
		int(AbilityData.Element.FIRE), int(EnemyData.Element.FIRE),
		"FIRE should match between AbilityData and EnemyData enums",
	)
	assert_eq(
		int(AbilityData.Element.DARK), int(EnemyData.Element.DARK),
		"DARK should match between AbilityData and EnemyData enums",
	)

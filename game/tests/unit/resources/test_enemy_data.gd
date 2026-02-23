extends GutTest

## Tests for EnemyData resource — inheritance, cross-enum parity, and field assignment.


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



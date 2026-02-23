extends GutTest

## Tests for EchoData resource — cross-enum parity and custom value assignment.


func test_element_enum_matches_ability_data_element() -> void:
	# EchoData.Element must match AbilityData.Element int values.
	assert_eq(EchoData.Element.FIRE, AbilityData.Element.FIRE)
	assert_eq(EchoData.Element.ICE, AbilityData.Element.ICE)
	assert_eq(EchoData.Element.WATER, AbilityData.Element.WATER)
	assert_eq(EchoData.Element.WIND, AbilityData.Element.WIND)
	assert_eq(EchoData.Element.EARTH, AbilityData.Element.EARTH)
	assert_eq(EchoData.Element.LIGHT, AbilityData.Element.LIGHT)
	assert_eq(EchoData.Element.DARK, AbilityData.Element.DARK)



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


func test_set_custom_values() -> void:
	var e := EchoData.new()
	e.id = &"flame_echo"
	e.display_name = "Flame Echo"
	e.rarity = EchoData.Rarity.RARE
	e.echo_type = EchoData.EchoType.ATTACK
	e.effect_type = EchoData.EffectType.DAMAGE
	e.effect_value = 50
	e.element = EchoData.Element.FIRE
	e.target_type = EchoData.TargetType.ALL_ENEMIES
	e.uses_per_battle = 3
	assert_eq(e.id, &"flame_echo")
	assert_eq(e.rarity, EchoData.Rarity.RARE)
	assert_eq(e.effect_value, 50)
	assert_eq(e.uses_per_battle, 3)

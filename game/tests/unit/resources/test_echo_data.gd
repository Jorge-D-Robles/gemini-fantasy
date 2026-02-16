extends GutTest

## Tests for EchoData resource — defaults and enum coverage.


func test_default_values() -> void:
	var e := EchoData.new()
	assert_eq(e.id, &"")
	assert_eq(e.display_name, "")
	assert_eq(e.description, "")
	assert_eq(e.lore_text, "")
	assert_eq(e.rarity, EchoData.Rarity.COMMON)
	assert_eq(e.echo_type, EchoData.EchoType.ATTACK)
	assert_eq(e.effect_type, EchoData.EffectType.DAMAGE)
	assert_eq(e.effect_value, 0)
	assert_eq(e.element, EchoData.Element.NONE)
	assert_eq(e.target_type, EchoData.TargetType.SINGLE_ENEMY)
	assert_eq(e.uses_per_battle, 1)
	assert_eq(e.icon_path, "")


func test_rarity_enum_values() -> void:
	assert_eq(EchoData.Rarity.COMMON, 0)
	assert_eq(EchoData.Rarity.UNCOMMON, 1)
	assert_eq(EchoData.Rarity.RARE, 2)
	assert_eq(EchoData.Rarity.LEGENDARY, 3)
	assert_eq(EchoData.Rarity.UNIQUE, 4)


func test_echo_type_enum_values() -> void:
	assert_eq(EchoData.EchoType.ATTACK, 0)
	assert_eq(EchoData.EchoType.SUPPORT, 1)
	assert_eq(EchoData.EchoType.DEBUFF, 2)
	assert_eq(EchoData.EchoType.UNIQUE_ECHO, 3)


func test_effect_type_enum_values() -> void:
	assert_eq(EchoData.EffectType.DAMAGE, 0)
	assert_eq(EchoData.EffectType.HEAL, 1)
	assert_eq(EchoData.EffectType.BUFF, 2)
	assert_eq(EchoData.EffectType.DEBUFF, 3)
	assert_eq(EchoData.EffectType.SPECIAL, 4)


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

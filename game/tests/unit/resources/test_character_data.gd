extends GutTest

## Tests for CharacterData resource — inheritance and field assignment.


func test_inherits_battler_data() -> void:
	var c := CharacterData.new()
	assert_true(c is BattlerData)
	assert_true(c is Resource)


func test_set_custom_growth_rates() -> void:
	var c := CharacterData.new()
	c.hp_growth = 15.0
	c.attack_growth = 3.0
	c.magic_growth = 0.5
	assert_almost_eq(c.hp_growth, 15.0, 0.001)
	assert_almost_eq(c.attack_growth, 3.0, 0.001)
	assert_almost_eq(c.magic_growth, 0.5, 0.001)

extends GutTest

## Tests for CharacterData resource — inheritance and growth rates.


func test_inherits_battler_data() -> void:
	var c := CharacterData.new()
	assert_true(c is BattlerData)
	assert_true(c is Resource)


func test_default_growth_rates() -> void:
	var c := CharacterData.new()
	assert_almost_eq(c.hp_growth, 10.0, 0.001)
	assert_almost_eq(c.ee_growth, 5.0, 0.001)
	assert_almost_eq(c.attack_growth, 1.5, 0.001)
	assert_almost_eq(c.magic_growth, 1.5, 0.001)
	assert_almost_eq(c.defense_growth, 1.5, 0.001)
	assert_almost_eq(c.resistance_growth, 1.5, 0.001)
	assert_almost_eq(c.speed_growth, 1.0, 0.001)
	assert_almost_eq(c.luck_growth, 1.0, 0.001)


func test_default_visual_paths() -> void:
	var c := CharacterData.new()
	assert_eq(c.portrait_path, "")
	assert_eq(c.sprite_path, "")
	assert_eq(c.battle_sprite_path, "")


func test_inherits_base_stat_defaults() -> void:
	var c := CharacterData.new()
	assert_eq(c.max_hp, 100)
	assert_eq(c.max_ee, 50)
	assert_eq(c.attack, 10)
	assert_eq(c.magic, 10)
	assert_eq(c.defense, 10)
	assert_eq(c.resistance, 10)
	assert_eq(c.speed, 10)
	assert_eq(c.luck, 10)


func test_set_custom_growth_rates() -> void:
	var c := CharacterData.new()
	c.hp_growth = 15.0
	c.attack_growth = 3.0
	c.magic_growth = 0.5
	assert_almost_eq(c.hp_growth, 15.0, 0.001)
	assert_almost_eq(c.attack_growth, 3.0, 0.001)
	assert_almost_eq(c.magic_growth, 0.5, 0.001)

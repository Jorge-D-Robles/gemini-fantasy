extends GutTest

## Tests for BattlerData resource — base stats and defaults.


func test_default_values() -> void:
	var d := BattlerData.new()
	assert_eq(d.id, &"")
	assert_eq(d.display_name, "")
	assert_eq(d.description, "")
	assert_eq(d.max_hp, 100)
	assert_eq(d.max_ee, 50)
	assert_eq(d.attack, 10)
	assert_eq(d.magic, 10)
	assert_eq(d.defense, 10)
	assert_eq(d.resistance, 10)
	assert_eq(d.speed, 10)
	assert_eq(d.luck, 10)
	assert_eq(d.abilities.size(), 0)


func test_set_custom_stats() -> void:
	var d := BattlerData.new()
	d.id = &"warrior"
	d.display_name = "Warrior"
	d.max_hp = 200
	d.max_ee = 30
	d.attack = 25
	d.magic = 5
	d.defense = 20
	d.resistance = 8
	d.speed = 12
	d.luck = 7
	assert_eq(d.max_hp, 200)
	assert_eq(d.max_ee, 30)
	assert_eq(d.attack, 25)
	assert_eq(d.magic, 5)
	assert_eq(d.defense, 20)
	assert_eq(d.resistance, 8)
	assert_eq(d.speed, 12)
	assert_eq(d.luck, 7)


func test_abilities_accepts_ability_data() -> void:
	var d := BattlerData.new()
	var ability := AbilityData.new()
	ability.id = &"slash"
	var abilities: Array[Resource] = [ability]
	d.abilities = abilities
	assert_eq(d.abilities.size(), 1)
	assert_eq((d.abilities[0] as AbilityData).id, &"slash")

extends GutTest

## Tests for BattlerData resource — typed array assignment.


func test_abilities_accepts_ability_data() -> void:
	var d := BattlerData.new()
	var ability := AbilityData.new()
	ability.id = &"slash"
	var abilities: Array[Resource] = [ability]
	d.abilities = abilities
	assert_eq(d.abilities.size(), 1)
	assert_eq((d.abilities[0] as AbilityData).id, &"slash")

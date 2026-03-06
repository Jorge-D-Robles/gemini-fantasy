extends GutTest

## Tests for Iris and Garrick ability .tres files — validates key stats.

const _ABILITIES: Dictionary = {
	"overclock": preload("res://data/abilities/overclock.tres"),
	"shrapnel_shot": preload("res://data/abilities/shrapnel_shot.tres"),
	"prototype_deploy": preload("res://data/abilities/prototype_deploy.tres"),
	"resonance_disruptor": preload("res://data/abilities/resonance_disruptor.tres"),
	"railgun": preload("res://data/abilities/railgun.tres"),
	"shield_bash": preload("res://data/abilities/shield_bash.tres"),
	"martyrs_resolve": preload("res://data/abilities/martyrs_resolve.tres"),
	"crystal_purge": preload("res://data/abilities/crystal_purge.tres"),
	"unbreakable": preload("res://data/abilities/unbreakable.tres"),
	"last_stand": preload("res://data/abilities/last_stand.tres"),
}

const _EXPECTED_EE_COSTS: Dictionary = {
	"overclock": 30, "shrapnel_shot": 35, "prototype_deploy": 40,
	"resonance_disruptor": 50, "railgun": 70,
	"shield_bash": 22, "martyrs_resolve": 35, "crystal_purge": 40,
	"unbreakable": 50, "last_stand": 0,
}


func test_all_abilities_have_correct_ee_cost() -> void:
	for name: String in _EXPECTED_EE_COSTS:
		var ability: Resource = _ABILITIES[name]
		assert_eq(
			ability.ee_cost, _EXPECTED_EE_COSTS[name],
			"%s EE cost" % name,
		)


func test_all_abilities_have_display_name() -> void:
	for name: String in _ABILITIES:
		var ability: Resource = _ABILITIES[name]
		assert_false(
			ability.display_name.is_empty(),
			"%s must have a display_name" % name,
		)


func test_railgun_is_extreme_damage() -> void:
	assert_gt(_ABILITIES["railgun"].damage_base, 200, "Railgun must be >200 damage")


func test_shield_bash_has_stun() -> void:
	assert_eq(_ABILITIES["shield_bash"].status_effect, "stun")

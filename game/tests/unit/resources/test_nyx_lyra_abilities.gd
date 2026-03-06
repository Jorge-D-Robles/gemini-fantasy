extends GutTest

## Tests for Nyx and Lyra ability .tres files — validates key stats.

const _ABILITIES: Dictionary = {
	"void_bolt": preload("res://data/abilities/void_bolt.tres"),
	"phase_shift": preload("res://data/abilities/phase_shift.tres"),
	"reality_break": preload("res://data/abilities/reality_break.tres"),
	"shadow_bind": preload("res://data/abilities/shadow_bind.tres"),
	"fragment_vision": preload("res://data/abilities/fragment_vision.tres"),
}

const _EXPECTED_EE_COSTS: Dictionary = {
	"void_bolt": 20, "phase_shift": 30, "reality_break": 35,
	"shadow_bind": 40, "fragment_vision": 25,
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


func test_void_bolt_is_dark_element() -> void:
	assert_eq(_ABILITIES["void_bolt"].element, 7, "Void Bolt element must be DARK (7)")

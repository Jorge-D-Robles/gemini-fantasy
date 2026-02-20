extends GutTest

## Tests for AfterCapitalCamp event script — conditional trigger logic only.

var _event: Node


func before_each() -> void:
	_event = load("res://events/after_capital_camp.gd").new()
	add_child_autofree(_event)


func test_compute_can_trigger_false_when_gate_flag_absent() -> void:
	var flags: Dictionary = {}
	assert_false(
		AfterCapitalCamp.compute_can_trigger(flags),
		"Must be false when lyra_fragment_2_collected is not set",
	)


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
		"after_capital_camp_seen": true,
	}
	assert_false(
		AfterCapitalCamp.compute_can_trigger(flags),
		"Must be false when after_capital_camp_seen is already set",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
	}
	assert_true(
		AfterCapitalCamp.compute_can_trigger(flags),
		"Must be true when gate set and event not yet seen",
	)


func test_compute_after_capital_lines_returns_array() -> void:
	var lines: Array[DialogueLine] = AfterCapitalCamp.compute_after_capital_lines()
	assert_gt(lines.size(), 0, "Should return dialogue lines")

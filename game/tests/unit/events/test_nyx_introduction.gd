extends GutTest

## Tests for NyxIntroduction event script — conditional trigger logic only.

var _event: Node


func before_each() -> void:
	_event = load("res://events/nyx_introduction.gd").new()
	add_child_autofree(_event)


func test_compute_can_trigger_false_without_garrick_recruited() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
	}
	assert_false(
		NyxIntroduction.compute_can_trigger(flags),
		"Must be false when garrick_recruited is not set",
	)


func test_compute_can_trigger_false_without_lyra_fragment() -> void:
	var flags: Dictionary = {
		"garrick_recruited": true,
	}
	assert_false(
		NyxIntroduction.compute_can_trigger(flags),
		"Must be false when lyra_fragment_2_collected is not set",
	)


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags: Dictionary = {
		"garrick_recruited": true,
		"lyra_fragment_2_collected": true,
		"nyx_introduction_seen": true,
	}
	assert_false(
		NyxIntroduction.compute_can_trigger(flags),
		"Must be false when nyx_introduction_seen is already set",
	)


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags: Dictionary = {
		"garrick_recruited": true,
		"lyra_fragment_2_collected": true,
	}
	assert_true(
		NyxIntroduction.compute_can_trigger(flags),
		"Must be true when both gate flags set and event not yet seen",
	)


func test_nyx_intro_lines_returns_array() -> void:
	var lines: Array[DialogueLine] = NyxIntroduction.compute_nyx_intro_lines()
	assert_gt(lines.size(), 0, "Should return dialogue lines")

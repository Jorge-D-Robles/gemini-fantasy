extends GutTest

## Tests for LeavingCapital — Chapter 5 Scene 6 post-dungeon dialogue.
## Conditional trigger logic and structural contract only.

const LeavingCapitalScript = preload("res://events/leaving_capital.gd")


func test_compute_can_trigger_false_when_gate_flag_absent() -> void:
	var flags: Dictionary = {}
	assert_false(LeavingCapitalScript.compute_can_trigger(flags))


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
		"leaving_capital_seen": true,
	}
	assert_false(LeavingCapitalScript.compute_can_trigger(flags))


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags: Dictionary = {"lyra_fragment_2_collected": true}
	assert_true(LeavingCapitalScript.compute_can_trigger(flags))


func test_no_line_has_choices() -> void:
	var lines: Array = LeavingCapitalScript.compute_leaving_capital_lines()
	for line: DialogueLine in lines:
		assert_false(line.has_choices())

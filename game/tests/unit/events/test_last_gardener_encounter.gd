extends GutTest

## Tests for LastGardenerEncounter — optional three-choice boss event.
## Conditional trigger logic, choice mapping, and structural invariants only.

const LastGardenerEncounterScript = preload("res://events/last_gardener_encounter.gd")


func test_compute_can_trigger_false_when_gate_flag_absent() -> void:
	var flags: Dictionary = {}
	assert_false(LastGardenerEncounterScript.compute_can_trigger(flags))


func test_compute_can_trigger_false_when_already_seen() -> void:
	var flags: Dictionary = {
		"lyra_fragment_2_collected": true,
		"gardener_encountered": true,
	}
	assert_false(LastGardenerEncounterScript.compute_can_trigger(flags))


func test_compute_can_trigger_true_when_eligible() -> void:
	var flags: Dictionary = {"lyra_fragment_2_collected": true}
	assert_true(LastGardenerEncounterScript.compute_can_trigger(flags))


func test_approach_last_line_has_three_choices() -> void:
	var lines: Array = LastGardenerEncounterScript.compute_approach_lines()
	var last: DialogueLine = lines[lines.size() - 1]
	assert_true(last.has_choices())
	assert_eq(last.choices.size(), 3)


func test_peaceful_outcome_lines_not_empty() -> void:
	var lines: Array = LastGardenerEncounterScript.compute_peaceful_outcome_lines()
	assert_gt(lines.size(), 0)


func test_quest_outcome_lines_not_empty() -> void:
	var lines: Array = LastGardenerEncounterScript.compute_quest_outcome_lines()
	assert_gt(lines.size(), 0)


func test_defeated_outcome_lines_not_empty() -> void:
	var lines: Array = LastGardenerEncounterScript.compute_defeated_outcome_lines()
	assert_gt(lines.size(), 0)


func test_compute_choice_result_peaceful_for_0() -> void:
	assert_eq(LastGardenerEncounterScript.compute_choice_result(0), "peaceful")


func test_compute_choice_result_quest_for_1() -> void:
	assert_eq(LastGardenerEncounterScript.compute_choice_result(1), "quest")


func test_compute_choice_result_fight_for_2() -> void:
	assert_eq(LastGardenerEncounterScript.compute_choice_result(2), "fight")


func test_compute_choice_result_defaults_to_peaceful_for_unknown() -> void:
	assert_eq(LastGardenerEncounterScript.compute_choice_result(99), "peaceful")

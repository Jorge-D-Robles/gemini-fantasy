extends GutTest

## Tests for AfterCapitalCamp event script.
## T-0193: Chapter 5 post-dungeon campfire dialogue — "After the Capital".
## Verifies flag constants, gating logic, dialogue structure, and signal contract.
## Source: docs/story/act1/05-into-the-capital.md (Camp Scene)

var _event: Node


func before_each() -> void:
	_event = load("res://events/after_capital_camp.gd").new()
	add_child_autofree(_event)


func test_flag_name_is_after_capital_camp_seen() -> void:
	assert_eq(_event.FLAG_NAME, "after_capital_camp_seen")


func test_gate_flag_is_lyra_fragment_2_collected() -> void:
	assert_eq(_event.GATE_FLAG, "lyra_fragment_2_collected")


func test_has_sequence_completed_signal() -> void:
	assert_true(_event.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_event.has_method("trigger"))


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


func test_compute_after_capital_lines_count() -> void:
	var lines: Array[DialogueLine] = AfterCapitalCamp.compute_after_capital_lines()
	assert_eq(lines.size(), 15, "Should have 15 dialogue lines matching story script")


func test_first_speaker_is_iris() -> void:
	var lines: Array[DialogueLine] = AfterCapitalCamp.compute_after_capital_lines()
	assert_eq(lines[0].speaker, "Iris", "Iris opens with 'Garrick.'")


func test_first_line_text_is_garrick_name() -> void:
	var lines: Array[DialogueLine] = AfterCapitalCamp.compute_after_capital_lines()
	assert_eq(lines[0].text, "Garrick.", "Opening line should be 'Garrick.'")


func test_kael_neither_of_you_line_present() -> void:
	var lines: Array[DialogueLine] = AfterCapitalCamp.compute_after_capital_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Kael" and "Neither of you" in line.text:
			found = true
			break
	assert_true(found, "Kael must say 'Neither of you is that person anymore.'")


func test_garrick_mentions_crystal_ash() -> void:
	var lines: Array[DialogueLine] = AfterCapitalCamp.compute_after_capital_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and "crystal ash" in line.text:
			found = true
			break
	assert_true(found, "Garrick should mention 'crystal ash' (villages purged)")


func test_iris_mentions_sensors() -> void:
	var lines: Array[DialogueLine] = AfterCapitalCamp.compute_after_capital_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Iris" and "sensors" in line.text:
			found = true
			break
	assert_true(found, "Iris should mention building sensors for Gearhaven")


func test_last_line_garrick_adequate() -> void:
	var lines: Array[DialogueLine] = AfterCapitalCamp.compute_after_capital_lines()
	var last: DialogueLine = lines[lines.size() - 1]
	assert_eq(last.speaker, "Garrick", "Scene closes on Garrick")
	assert_string_contains(last.text, "adequate", "Closing beat: 'It's adequate. Not the same thing.'")

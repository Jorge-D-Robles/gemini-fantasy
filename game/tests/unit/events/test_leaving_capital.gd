extends GutTest

## Unit tests for LeavingCapital — Chapter 5 Scene 6 post-dungeon dialogue.
## Fires at the Capital exit gate before transitioning to Verdant Forest.

const LeavingCapitalScript = preload("res://events/leaving_capital.gd")


func test_flag_name_is_leaving_capital_seen() -> void:
	assert_eq(LeavingCapitalScript.FLAG_NAME, "leaving_capital_seen")


func test_gate_flag_is_lyra_fragment_2_collected() -> void:
	assert_eq(LeavingCapitalScript.GATE_FLAG, "lyra_fragment_2_collected")


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


func test_leaving_capital_lines_count_is_nine() -> void:
	var lines: Array = LeavingCapitalScript.compute_leaving_capital_lines()
	assert_eq(lines.size(), 9)


func test_first_speaker_is_garrick() -> void:
	var lines: Array = LeavingCapitalScript.compute_leaving_capital_lines()
	assert_eq(lines[0].speaker, "Garrick")


func test_first_line_mentions_two_million_people() -> void:
	var lines: Array = LeavingCapitalScript.compute_leaving_capital_lines()
	assert_true("million" in lines[0].text)


func test_iris_mentions_choice_not_mistake() -> void:
	var lines: Array = LeavingCapitalScript.compute_leaving_capital_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Iris" and "choice" in line.text.to_lower():
			found = true
			break
	assert_true(found)


func test_kael_references_lyra_sorry() -> void:
	var lines: Array = LeavingCapitalScript.compute_leaving_capital_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		var text_lower: String = line.text.to_lower()
		if line.speaker == "Kael" and ("sorry" in text_lower or "memory" in text_lower):
			found = true
			break
	assert_true(found)


func test_last_line_kael_says_go_home() -> void:
	var lines: Array = LeavingCapitalScript.compute_leaving_capital_lines()
	var last: DialogueLine = lines[lines.size() - 1]
	assert_eq(last.speaker, "Kael")
	assert_true("home" in last.text.to_lower())


func test_no_line_has_choices() -> void:
	var lines: Array = LeavingCapitalScript.compute_leaving_capital_lines()
	for line: DialogueLine in lines:
		assert_false(line.has_choices())

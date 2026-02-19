extends GutTest

## Tests for GarrickMeetsLyra event script.
## Verifies structure, constants, dialogue content, and signal contract.
## Scene 5 of Chapter 4: Garrick confronts a Conscious Echo for the
## first time — the emotional peak of the chapter.

var _event: Node


func before_each() -> void:
	_event = load("res://events/garrick_meets_lyra.gd").new()
	add_child_autofree(_event)


func test_flag_name_is_garrick_met_lyra() -> void:
	assert_eq(_event.FLAG_NAME, "garrick_met_lyra")


func test_has_sequence_completed_signal() -> void:
	assert_true(_event.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_event.has_method("trigger"))


func test_build_dialogue_returns_array() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_gt(lines.size(), 0, "Should have dialogue lines")


func test_build_dialogue_line_count() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_eq(
		lines.size(), 14,
		"Should have 14 dialogue lines",
	)


func test_first_speaker_is_lyra() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_eq(
		lines[0].speaker, "Lyra",
		"Lyra opens the scene (theological problem)",
	)


func test_contains_garrick_speaker() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick":
			found = true
			break
	assert_true(found, "Dialogue should include Garrick")


func test_lyra_mentions_theological() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Lyra" and "theological" in line.text:
			found = true
			break
	assert_true(
		found,
		"Lyra should mention 'theological' (her opener)",
	)


func test_garrick_asks_about_pain() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and "pain" in line.text:
			found = true
			break
	assert_true(
		found,
		"Garrick should ask about pain (pivotal question)",
	)


func test_dialogue_contains_absence() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if "absence" in line.text:
			found = true
			break
	assert_true(
		found,
		"Dialogue should contain 'absence' (connecting moment)",
	)


func test_garrick_last_line_contains_empty() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var garrick_last: String = ""
	for line: DialogueLine in lines:
		if line.speaker == "Garrick":
			garrick_last = line.text
	assert_string_contains(
		garrick_last, "empty",
		"Garrick's last line should commit (mentions 'empty')",
	)


func test_contains_kael_speaker() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Kael":
			found = true
			break
	assert_true(found, "Dialogue should include Kael")

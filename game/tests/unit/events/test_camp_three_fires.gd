extends GutTest

## Tests for CampThreeFires event script.
## Verifies structure, constants, dialogue content, and signal contract.
## Camp Scene: "Three Around a Fire" from docs/story/act1/04-old-iron.md.

var _event: Node


func before_each() -> void:
	_event = load("res://events/camp_three_fires.gd").new()
	add_child_autofree(_event)


func test_flag_name_is_camp_scene_three_fires() -> void:
	assert_eq(_event.FLAG_NAME, "camp_scene_three_fires")


func test_has_sequence_completed_signal() -> void:
	assert_true(_event.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_event.has_method("trigger"))


func test_build_dialogue_returns_array() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_gt(lines.size(), 0, "Should have dialogue lines")


func test_build_dialogue_line_count() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_eq(lines.size(), 15, "Should have 15 dialogue lines")


func test_first_speaker_is_kael() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_eq(lines[0].speaker, "Kael", "Kael opens with 'You cook.'")


func test_kael_opens_with_cook() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_string_contains(lines[0].text, "cook")


func test_contains_garrick_speaker() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick":
			found = true
			break
	assert_true(found, "Dialogue should include Garrick")


func test_garrick_mentions_stew() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and "stew" in line.text:
			found = true
			break
	assert_true(found, "Garrick should mention stew")


func test_kael_mentions_overgrown_capital() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Kael" and "Overgrown Capital" in line.text:
			found = true
			break
	assert_true(found, "Kael should mention the Overgrown Capital (planning the run)")


func test_contains_iris_speaker() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Iris":
			found = true
			break
	assert_true(found, "Dialogue should include Iris")


func test_iris_accepts_garrick() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Iris" and "stay" in line.text:
			found = true
			break
	assert_true(found, "Iris should say '...Okay. You can stay.'")

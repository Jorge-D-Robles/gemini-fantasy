extends GutTest

## Tests for GarrickNightScene event script.
## Verifies structure, constants, dialogue content, and signal contract.
## Night scene: Garrick reflects on meeting Lyra — quiet moment at Roothollow
## before departure to the Overgrown Capital.
## Source: docs/story/act1/04-old-iron.md (NPC Dialogue: Garrick Camp Conversation).

var _event: Node


func before_each() -> void:
	_event = load("res://events/garrick_night_scene.gd").new()
	add_child_autofree(_event)


func test_flag_name_is_garrick_night_scene() -> void:
	assert_eq(_event.FLAG_NAME, "garrick_night_scene")


func test_has_sequence_completed_signal() -> void:
	assert_true(_event.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_event.has_method("trigger"))


func test_build_dialogue_returns_array() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_gt(lines.size(), 0, "Should have dialogue lines")


func test_build_dialogue_line_count() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_eq(lines.size(), 10, "Should have 10 dialogue lines")


func test_first_speaker_is_kael() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_eq(lines[0].speaker, "Kael", "Kael opens the night scene")


func test_kael_opens_with_cant_sleep() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	assert_string_contains(lines[0].text, "sleep")


func test_contains_garrick_speaker() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick":
			found = true
			break
	assert_true(found, "Dialogue should include Garrick")


func test_garrick_mentions_shield() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and "shield" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Garrick should mention the shield")


func test_garrick_mentions_scars() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and "scar" in line.text.to_lower():
			found = true
			break
	assert_true(found, "Garrick should mention scars")


func test_garrick_mentions_someone() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and "someone" in line.text:
			found = true
			break
	assert_true(found, "Garrick should reference 'someone' (foreshadowing his daughter)")


func test_garrick_mentions_iris_anger() -> void:
	var lines: Array[DialogueLine] = _event._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and "angry" in line.text:
			found = true
			break
	assert_true(found, "Garrick should say Iris is angry")

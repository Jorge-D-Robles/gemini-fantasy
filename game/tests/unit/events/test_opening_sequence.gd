extends GutTest

## Tests for OpeningSequence event script.
## Verifies structure, constants, dialogue content, and signal contract.

var _sequence: Node


func before_each() -> void:
	_sequence = load("res://events/opening_sequence.gd").new()
	add_child_autofree(_sequence)


func test_flag_name_is_opening_lyra_discovered() -> void:
	assert_eq(_sequence.FLAG_NAME, "opening_lyra_discovered")


func test_lyra_data_path_constant() -> void:
	assert_eq(
		_sequence.LYRA_DATA_PATH,
		"res://data/characters/lyra.tres",
	)


func test_has_sequence_completed_signal() -> void:
	assert_true(_sequence.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_sequence.has_method("trigger"))


func test_build_dialogue_returns_array() -> void:
	var lines: Array[DialogueLine] = _sequence._build_dialogue()
	assert_gt(lines.size(), 0, "Should have dialogue lines")


func test_build_dialogue_has_expected_line_count() -> void:
	var lines: Array[DialogueLine] = _sequence._build_dialogue()
	assert_eq(lines.size(), 23, "Should have 23 dialogue lines")


func test_build_dialogue_first_speaker_is_kael() -> void:
	var lines: Array[DialogueLine] = _sequence._build_dialogue()
	assert_eq(
		lines[0].speaker, "Kael",
		"First line should be Kael",
	)


func test_build_dialogue_contains_lyra_speaker() -> void:
	var lines: Array[DialogueLine] = _sequence._build_dialogue()
	var has_lyra: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Lyra":
			has_lyra = true
			break
	assert_true(has_lyra, "Dialogue should include Lyra")


func test_build_dialogue_last_speaker_is_kael() -> void:
	var lines: Array[DialogueLine] = _sequence._build_dialogue()
	assert_eq(
		lines[-1].speaker, "Kael",
		"Last line should be Kael",
	)


func test_build_dialogue_lyra_introduces_herself() -> void:
	var lines: Array[DialogueLine] = _sequence._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Lyra" and "Lyra" in line.text:
			found = true
			break
	assert_true(found, "Lyra should introduce herself by name")

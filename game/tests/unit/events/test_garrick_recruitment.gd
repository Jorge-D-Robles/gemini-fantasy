extends GutTest

## Tests for GarrickRecruitment event script.
## Verifies structure, constants, dialogue content, and signal contract.

var _recruitment: Node


func before_each() -> void:
	_recruitment = load("res://events/garrick_recruitment.gd").new()
	add_child_autofree(_recruitment)


func test_flag_name_is_garrick_recruited() -> void:
	assert_eq(_recruitment.FLAG_NAME, "garrick_recruited")


func test_garrick_data_path_constant() -> void:
	assert_eq(
		_recruitment.GARRICK_DATA_PATH,
		"res://data/characters/garrick.tres",
	)


func test_has_sequence_completed_signal() -> void:
	assert_true(_recruitment.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_recruitment.has_method("trigger"))


func test_build_dialogue_returns_array() -> void:
	var lines: Array[DialogueLine] = _recruitment._build_dialogue()
	assert_gt(lines.size(), 0, "Should have dialogue lines")


func test_build_dialogue_line_count() -> void:
	var lines: Array[DialogueLine] = _recruitment._build_dialogue()
	assert_eq(lines.size(), 17, "Should have 17 dialogue lines")


func test_build_dialogue_first_speaker_is_garrick() -> void:
	var lines: Array[DialogueLine] = _recruitment._build_dialogue()
	assert_eq(
		lines[0].speaker, "Garrick",
		"First line should be Garrick (at the shrine)",
	)


func test_build_dialogue_contains_iris_speaker() -> void:
	var lines: Array[DialogueLine] = _recruitment._build_dialogue()
	var has_iris: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Iris":
			has_iris = true
			break
	assert_true(has_iris, "Dialogue should include Iris")


func test_build_dialogue_last_speaker_is_garrick() -> void:
	var lines: Array[DialogueLine] = _recruitment._build_dialogue()
	assert_eq(
		lines[-1].speaker, "Garrick",
		"Last line should be Garrick",
	)


func test_build_dialogue_garrick_mentions_shepherd() -> void:
	var lines: Array[DialogueLine] = _recruitment._build_dialogue()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Garrick" and "Shepherd" in line.text:
			found = true
			break
	assert_true(
		found,
		"Garrick should mention Shepherds in his lines",
	)


# -- personal quest auto-accept helper --


func test_garrick_quest_path_constant() -> void:
	assert_eq(
		_recruitment.GARRICK_QUEST_PATH,
		"res://data/quests/garrick_three_burns.tres",
		"GARRICK_QUEST_PATH should point to the personal quest .tres",
	)


func test_compute_should_auto_accept_true_when_recruited() -> void:
	var flags := {"garrick_recruited": true}
	assert_true(
		_recruitment.compute_should_auto_accept_garrick_quest(flags),
		"Should auto-accept when garrick_recruited flag is set",
	)


func test_compute_should_auto_accept_false_when_not_recruited() -> void:
	assert_false(
		_recruitment.compute_should_auto_accept_garrick_quest({}),
		"Should not auto-accept when garrick_recruited flag is missing",
	)

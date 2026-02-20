extends GutTest

## Tests for IrisRecruitment event script.
## Verifies structure, constants, dialogue content, and signal contract.

var _recruitment: Node


func before_each() -> void:
	_recruitment = load("res://events/iris_recruitment.gd").new()
	add_child_autofree(_recruitment)


func test_flag_name_is_iris_recruited() -> void:
	assert_eq(_recruitment.FLAG_NAME, "iris_recruited")


func test_iris_data_path_constant() -> void:
	assert_eq(
		_recruitment.IRIS_DATA_PATH,
		"res://data/characters/iris.tres",
	)


func test_ash_stalker_path_constant() -> void:
	assert_eq(
		_recruitment.ASH_STALKER_PATH,
		"res://data/enemies/ash_stalker.tres",
	)


func test_has_sequence_completed_signal() -> void:
	assert_true(_recruitment.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_recruitment.has_method("trigger"))


func test_pre_battle_dialogue_returns_array() -> void:
	var lines: Array[DialogueLine] = _recruitment._build_pre_battle_dialogue()
	assert_gt(lines.size(), 0, "Should have pre-battle dialogue lines")


func test_pre_battle_dialogue_line_count() -> void:
	var lines: Array[DialogueLine] = _recruitment._build_pre_battle_dialogue()
	assert_eq(lines.size(), 7, "Should have 7 pre-battle dialogue lines")


func test_pre_battle_dialogue_first_speaker_is_iris() -> void:
	var lines: Array[DialogueLine] = _recruitment._build_pre_battle_dialogue()
	assert_eq(
		lines[0].speaker, "Iris",
		"First pre-battle line should be Iris (mid-fight)",
	)


func test_post_battle_lines_returns_array() -> void:
	var lines: Array[DialogueLine] = IrisRecruitment._build_post_battle_lines()
	assert_gt(lines.size(), 0, "Should have post-battle dialogue lines")


func test_post_battle_lines_count() -> void:
	var lines: Array[DialogueLine] = IrisRecruitment._build_post_battle_lines()
	assert_eq(lines.size(), 12, "Should have 12 post-battle dialogue lines")


func test_post_battle_dialogue_iris_identity() -> void:
	var lines: Array[DialogueLine] = IrisRecruitment._build_post_battle_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if line.speaker == "Iris" and "Initiative" in line.text:
			found = true
			break
	assert_true(found, "Post-battle should mention Initiative in Iris's lines")


func test_post_battle_dialogue_mentions_lyra() -> void:
	var lines: Array[DialogueLine] = IrisRecruitment._build_post_battle_lines()
	var found: bool = false
	for line: DialogueLine in lines:
		if "Lyra" in line.text:
			found = true
			break
	assert_true(found, "Post-battle should mention Lyra")


# -- personal quest auto-accept helper --


func test_iris_quest_path_constant() -> void:
	assert_eq(
		_recruitment.IRIS_QUEST_PATH,
		"res://data/quests/iris_engineers_oath.tres",
		"IRIS_QUEST_PATH should point to the personal quest .tres",
	)


func test_compute_should_auto_accept_true_when_recruited() -> void:
	var flags := {"iris_recruited": true}
	assert_true(
		IrisRecruitment.compute_should_auto_accept_iris_quest(flags),
		"Should auto-accept when iris_recruited flag is set",
	)


func test_compute_should_auto_accept_false_when_not_recruited() -> void:
	assert_false(
		IrisRecruitment.compute_should_auto_accept_iris_quest({}),
		"Should not auto-accept when iris_recruited flag is missing",
	)

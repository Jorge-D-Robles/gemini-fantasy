extends GutTest

## Tests for Garrick's "Three Burns" quest .tres data.

var _quest: QuestData


func before_each() -> void:
	_quest = load(
		"res://data/quests/garrick_three_burns.tres"
	)


func test_quest_loads() -> void:
	assert_not_null(_quest, "Quest resource should load")


func test_quest_id() -> void:
	assert_eq(
		_quest.id, &"garrick_three_burns",
		"ID should match",
	)


func test_quest_title() -> void:
	assert_eq(
		_quest.title, "Three Burns",
		"Title should match",
	)


func test_quest_type_is_character() -> void:
	assert_eq(
		_quest.quest_type, QuestData.QuestType.CHARACTER,
		"Should be CHARACTER quest type",
	)


func test_quest_has_three_objectives() -> void:
	assert_eq(
		_quest.objectives.size(), 3,
		"Should have 3 objectives (one per stage)",
	)


func test_quest_reward_exp() -> void:
	assert_gt(
		_quest.reward_exp, 0,
		"Should have XP reward",
	)


func test_quest_description_mentions_mara() -> void:
	assert_true(
		"Mara" in _quest.description,
		"Description should mention Mara",
	)

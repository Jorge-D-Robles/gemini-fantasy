extends GutTest

## Tests for Kael's "Fragments of Self" quest .tres data.

var _quest: QuestData


func before_each() -> void:
	_quest = load(
		"res://data/quests/kael_fragments_of_self.tres"
	)


func test_quest_loads() -> void:
	assert_not_null(_quest, "Quest resource should load")


func test_quest_id() -> void:
	assert_eq(
		_quest.id, &"kael_fragments_of_self",
		"ID should match",
	)


func test_quest_title() -> void:
	assert_eq(
		_quest.title, "Fragments of Self",
		"Title should match",
	)


func test_quest_type_is_character() -> void:
	assert_eq(
		_quest.quest_type, QuestData.QuestType.CHARACTER,
		"Should be CHARACTER quest type",
	)


func test_quest_has_five_objectives() -> void:
	assert_eq(
		_quest.objectives.size(), 5,
		"Should have 5 objectives (one per stage)",
	)


func test_quest_reward_exp() -> void:
	assert_gt(
		_quest.reward_exp, 0,
		"Should have XP reward",
	)


func test_quest_description_not_empty() -> void:
	assert_gt(
		_quest.description.length(), 0,
		"Description should not be empty",
	)

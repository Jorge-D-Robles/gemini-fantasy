extends GutTest

## Tests for Ash's "The Drawing" quest data resource.

var _quest: QuestData


func before_each() -> void:
	_quest = load("res://data/quests/ash_the_drawing.tres")


func test_quest_loads() -> void:
	assert_not_null(_quest, "Quest should load")


func test_quest_id() -> void:
	assert_eq(_quest.id, &"ash_the_drawing")


func test_quest_title() -> void:
	assert_eq(_quest.title, "The Drawing")


func test_quest_type_is_character() -> void:
	assert_eq(
		_quest.quest_type, 2,
		"Quest type should be CHARACTER (2)",
	)


func test_quest_has_four_objectives() -> void:
	assert_eq(
		_quest.objectives.size(), 4,
		"Should have 4 objectives for 4 stages",
	)


func test_quest_reward_exp() -> void:
	assert_eq(_quest.reward_exp, 500)


func test_quest_description_mentions_chrysalis() -> void:
	assert_true(
		"Chrysalis" in _quest.description,
		"Description should mention Chrysalis",
	)

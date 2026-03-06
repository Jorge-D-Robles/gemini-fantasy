extends GutTest

## Tests for Sienna's "Book of Names" quest data resource.

var _quest: QuestData


func before_each() -> void:
	_quest = load(
		"res://data/quests/sienna_book_of_names.tres"
	)


func test_quest_loads() -> void:
	assert_not_null(_quest, "Quest should load")


func test_quest_id() -> void:
	assert_eq(_quest.id, &"sienna_book_of_names")


func test_quest_title() -> void:
	assert_eq(_quest.title, "The Book of Names")


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


func test_quest_description_mentions_battery() -> void:
	assert_true(
		"battery" in _quest.description,
		"Description should mention Resonance battery",
	)

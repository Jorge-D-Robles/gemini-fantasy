extends GutTest

## Tests for Cipher's "Ghost in the Machine" quest data resource.

var _quest: QuestData


func before_each() -> void:
	_quest = load(
		"res://data/quests/cipher_ghost_in_machine.tres"
	)


func test_quest_loads() -> void:
	assert_not_null(_quest, "Quest should load")


func test_quest_id() -> void:
	assert_eq(_quest.id, &"cipher_ghost_in_machine")


func test_quest_title() -> void:
	assert_eq(_quest.title, "Ghost in the Machine")


func test_quest_type_is_character() -> void:
	assert_eq(
		_quest.quest_type, 2,
		"Quest type should be CHARACTER (2)",
	)


func test_quest_has_five_objectives() -> void:
	assert_eq(
		_quest.objectives.size(), 5,
		"Should have 5 objectives for 5 stages",
	)


func test_quest_reward_exp() -> void:
	assert_eq(_quest.reward_exp, 500)


func test_quest_description_mentions_protocol() -> void:
	assert_true(
		"Protocol" in _quest.description,
		"Description should mention the Protocol",
	)

extends GutTest

## Tests for T-0293: Roothollow tutorial quest data files.


func test_herb_gathering_loads() -> void:
	var q: QuestData = load("res://data/quests/herb_gathering.tres")
	assert_not_null(q, "herb_gathering.tres should load")
	assert_eq(q.id, &"herb_gathering")
	assert_eq(q.quest_type, QuestData.QuestType.SIDE)


func test_herb_gathering_has_objectives() -> void:
	var q: QuestData = load("res://data/quests/herb_gathering.tres")
	assert_gte(
		q.objectives.size(), 2,
		"Should have at least 2 objectives",
	)


func test_lost_pendant_loads() -> void:
	var q: QuestData = load("res://data/quests/lost_pendant.tres")
	assert_not_null(q, "lost_pendant.tres should load")
	assert_eq(q.id, &"lost_pendant")
	assert_eq(q.quest_type, QuestData.QuestType.SIDE)


func test_lost_pendant_has_objectives() -> void:
	var q: QuestData = load("res://data/quests/lost_pendant.tres")
	assert_gte(
		q.objectives.size(), 2,
		"Should have at least 2 objectives",
	)


func test_lost_pendant_rewards() -> void:
	var q: QuestData = load("res://data/quests/lost_pendant.tres")
	assert_gt(q.reward_gold, 0, "Should reward gold")
	assert_gt(q.reward_exp, 0, "Should reward exp")


func test_elders_request_loads() -> void:
	var q: QuestData = load("res://data/quests/elders_request.tres")
	assert_not_null(q, "elders_request.tres should load")
	assert_eq(q.id, &"elders_request")
	assert_eq(q.quest_type, QuestData.QuestType.SIDE)


func test_elders_request_has_objectives() -> void:
	var q: QuestData = load("res://data/quests/elders_request.tres")
	assert_gte(
		q.objectives.size(), 2,
		"Should have at least 2 objectives",
	)


func test_elders_request_rewards() -> void:
	var q: QuestData = load("res://data/quests/elders_request.tres")
	assert_gt(q.reward_gold, 0, "Should reward gold")
	assert_gt(q.reward_exp, 0, "Should reward exp")

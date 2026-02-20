extends GutTest

## Tests for the quest log compute_quest_list() static function.
## Follows the same pattern as test_objective_tracker.gd.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const QuestLogScript = preload("res://ui/quest_log/quest_log.gd")

var _qm: Node


func before_each() -> void:
	_qm = load("res://autoloads/quest_manager.gd").new()
	add_child_autofree(_qm)


func test_compute_empty_when_no_quests() -> void:
	var result: Array[Dictionary] = QuestLogScript.compute_quest_list(
		_qm, false
	)
	assert_eq(result.size(), 0)


func test_compute_active_quest_listed() -> void:
	var quest := Helpers.make_quest({
		"id": &"herb",
		"title": "Herb Gathering",
		"description": "Collect herbs for the healer.",
		"quest_type": QuestData.QuestType.SIDE,
	})
	_qm.accept_quest(quest)
	var result: Array[Dictionary] = QuestLogScript.compute_quest_list(
		_qm, false
	)
	assert_eq(result.size(), 1)
	assert_eq(result[0]["id"], &"herb")
	assert_eq(result[0]["title"], "Herb Gathering")
	assert_eq(result[0]["description"], "Collect herbs for the healer.")
	assert_eq(result[0]["quest_type"], QuestData.QuestType.SIDE)


func test_compute_includes_objectives() -> void:
	var quest := Helpers.make_quest({
		"id": &"herb",
		"objectives": ["Collect 3 herbs", "Return to Maren"],
	})
	_qm.accept_quest(quest)
	_qm.complete_objective(&"herb", 0)
	var result: Array[Dictionary] = QuestLogScript.compute_quest_list(
		_qm, false
	)
	assert_eq(result.size(), 1)
	var objectives: Array = result[0]["objectives"]
	assert_eq(objectives.size(), 2)
	assert_eq(objectives[0]["text"], "Collect 3 herbs")
	assert_true(objectives[0]["completed"])
	assert_eq(objectives[1]["text"], "Return to Maren")
	assert_false(objectives[1]["completed"])


func test_compute_includes_rewards() -> void:
	var quest := Helpers.make_quest({
		"id": &"bounty",
		"reward_gold": 200,
		"reward_exp": 100,
		"reward_item_ids": [&"potion", &"ether"],
	})
	_qm.accept_quest(quest)
	var result: Array[Dictionary] = QuestLogScript.compute_quest_list(
		_qm, false
	)
	assert_eq(result.size(), 1)
	var rewards: Dictionary = result[0]["rewards"]
	assert_eq(rewards["gold"], 200)
	assert_eq(rewards["exp"], 100)
	assert_eq(rewards["items"].size(), 2)
	# Items are resolved to display names, not raw IDs
	assert_has(rewards["items"], "Potion")
	assert_has(rewards["items"], "Ether")


func test_compute_item_display_name_known_item() -> void:
	var name: String = QuestLogScript.compute_item_display_name(&"potion")
	assert_eq(name, "Potion", "Known item resolves to display name")


func test_compute_item_display_name_unknown_item_falls_back_to_id() -> void:
	var name: String = QuestLogScript.compute_item_display_name(
		&"nonexistent_item_xyz"
	)
	assert_false(name.is_empty(), "Unknown item returns non-empty fallback")
	assert_true(
		name.contains("nonexistent_item_xyz"),
		"Fallback includes the item ID",
	)


func test_compute_item_display_name_ether() -> void:
	var name: String = QuestLogScript.compute_item_display_name(&"ether")
	assert_eq(name, "Ether", "Ether item resolves to display name")


func test_compute_completed_tab_shows_completed() -> void:
	var quest := Helpers.make_quest({
		"id": &"herb",
		"title": "Herb Gathering",
		"objectives": ["Collect herbs"],
	})
	_qm.accept_quest(quest)
	_qm.complete_objective(&"herb", 0)
	# Quest auto-completes when all objectives done
	var result: Array[Dictionary] = QuestLogScript.compute_quest_list(
		_qm, true
	)
	assert_eq(result.size(), 1)
	assert_eq(result[0]["id"], &"herb")


func test_compute_active_tab_excludes_completed() -> void:
	var quest := Helpers.make_quest({
		"id": &"herb",
		"objectives": ["Collect herbs"],
	})
	_qm.accept_quest(quest)
	_qm.complete_objective(&"herb", 0)
	# Quest auto-completes — should not appear in active tab
	var result: Array[Dictionary] = QuestLogScript.compute_quest_list(
		_qm, false
	)
	assert_eq(result.size(), 0)


func test_compute_multiple_quests_ordered() -> void:
	var quest_a := Helpers.make_quest({
		"id": &"herb",
		"title": "Herb Gathering",
	})
	var quest_b := Helpers.make_quest({
		"id": &"escort",
		"title": "Escort Mission",
	})
	_qm.accept_quest(quest_a)
	_qm.accept_quest(quest_b)
	var result: Array[Dictionary] = QuestLogScript.compute_quest_list(
		_qm, false
	)
	assert_eq(result.size(), 2)
	assert_eq(result[0]["id"], &"herb")
	assert_eq(result[1]["id"], &"escort")


func test_compute_skips_missing_quest_data() -> void:
	var quest := Helpers.make_quest({
		"id": &"herb",
		"title": "Herb Gathering",
	})
	_qm.accept_quest(quest)
	# Inject a ghost quest with state but no data
	_qm._states[&"ghost"] = _qm.State.ACTIVE
	var result: Array[Dictionary] = QuestLogScript.compute_quest_list(
		_qm, false
	)
	# Should only have the valid quest, ghost skipped
	assert_eq(result.size(), 1)
	assert_eq(result[0]["id"], &"herb")

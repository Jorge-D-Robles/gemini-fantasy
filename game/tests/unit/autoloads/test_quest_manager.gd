extends GutTest

## Tests for QuestManager autoload and QuestData Resource.

const QuestDataScript := preload("res://resources/quest_data.gd")
const QuestManagerScript := preload("res://autoloads/quest_manager.gd")

var _mgr: Node


func before_each() -> void:
	_mgr = QuestManagerScript.new()
	add_child_autofree(_mgr)


func _make_quest(overrides: Dictionary = {}) -> Resource:
	var q := QuestDataScript.new()
	q.id = overrides.get("id", &"test_quest")
	q.title = overrides.get("title", "Test Quest")
	q.description = overrides.get("description", "A test quest.")
	var raw_obj: Array = overrides.get(
		"objectives", ["Do thing A", "Do thing B"]
	)
	var obj: Array[String] = []
	for s in raw_obj:
		obj.append(s)
	q.objectives = obj
	q.reward_gold = overrides.get("reward_gold", 100)
	q.reward_exp = overrides.get("reward_exp", 50)
	var raw_items: Array = overrides.get("reward_item_ids", [])
	var items: Array[StringName] = []
	for item in raw_items:
		items.append(item)
	q.reward_item_ids = items
	q.quest_type = overrides.get("quest_type", 0)
	var raw_prereqs: Array = overrides.get("prerequisites", [])
	var prereqs: Array[String] = []
	for p in raw_prereqs:
		prereqs.append(p)
	q.prerequisites = prereqs
	return q


# --- QuestData Resource Tests ---


func test_quest_data_default_values() -> void:
	var q := QuestDataScript.new()
	assert_eq(q.id, &"")
	assert_eq(q.title, "")
	assert_eq(q.description, "")
	assert_eq(q.objectives.size(), 0)
	assert_eq(q.reward_gold, 0)
	assert_eq(q.reward_exp, 0)
	assert_eq(q.reward_item_ids.size(), 0)
	assert_eq(q.quest_type, 0)
	assert_eq(q.prerequisites.size(), 0)


func test_quest_data_custom_values() -> void:
	var q := _make_quest({
		"id": &"find_artifact",
		"title": "Find the Artifact",
		"objectives": ["Enter ruins", "Find artifact"] as Array[String],
		"reward_gold": 500,
		"reward_exp": 200,
	})
	assert_eq(q.id, &"find_artifact")
	assert_eq(q.title, "Find the Artifact")
	assert_eq(q.objectives.size(), 2)
	assert_eq(q.objectives[0], "Enter ruins")
	assert_eq(q.reward_gold, 500)
	assert_eq(q.reward_exp, 200)


# --- Accept Quest Tests ---


func test_accept_quest() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	assert_true(_mgr.is_quest_active(&"test_quest"))


func test_accept_quest_emits_signal() -> void:
	var q := _make_quest()
	watch_signals(_mgr)
	_mgr.accept_quest(q)
	assert_signal_emitted(_mgr, "quest_accepted")


func test_accept_duplicate_quest_ignored() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	_mgr.accept_quest(q)
	assert_eq(_mgr.get_active_quests().size(), 1)


func test_accept_completed_quest_ignored() -> void:
	var q := _make_quest({
		"objectives": ["Do one thing"] as Array[String],
	})
	_mgr.accept_quest(q)
	_mgr.complete_objective(&"test_quest", 0)
	assert_true(_mgr.is_quest_completed(&"test_quest"))
	_mgr.accept_quest(q)
	assert_eq(_mgr.get_active_quests().size(), 0)


# --- Objective Tracking Tests ---


func test_initial_objectives_all_incomplete() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	var status: Array = _mgr.get_objective_status(&"test_quest")
	assert_eq(status.size(), 2)
	assert_false(status[0])
	assert_false(status[1])


func test_complete_single_objective() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	_mgr.complete_objective(&"test_quest", 0)
	var status: Array = _mgr.get_objective_status(&"test_quest")
	assert_true(status[0])
	assert_false(status[1])


func test_complete_objective_emits_signal() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	watch_signals(_mgr)
	_mgr.complete_objective(&"test_quest", 0)
	assert_signal_emitted(_mgr, "quest_progressed")


func test_complete_all_objectives_completes_quest() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	_mgr.complete_objective(&"test_quest", 0)
	_mgr.complete_objective(&"test_quest", 1)
	assert_true(_mgr.is_quest_completed(&"test_quest"))
	assert_false(_mgr.is_quest_active(&"test_quest"))


func test_complete_all_objectives_emits_completed() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	watch_signals(_mgr)
	_mgr.complete_objective(&"test_quest", 0)
	_mgr.complete_objective(&"test_quest", 1)
	assert_signal_emitted(_mgr, "quest_completed")


func test_complete_invalid_objective_index_ignored() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	_mgr.complete_objective(&"test_quest", 99)
	var status: Array = _mgr.get_objective_status(&"test_quest")
	assert_false(status[0])
	assert_false(status[1])


func test_complete_objective_on_unknown_quest_ignored() -> void:
	_mgr.complete_objective(&"nonexistent", 0)
	assert_eq(_mgr.get_active_quests().size(), 0)


func test_complete_already_done_objective_noop() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	watch_signals(_mgr)
	_mgr.complete_objective(&"test_quest", 0)
	_mgr.complete_objective(&"test_quest", 0)
	assert_signal_emit_count(_mgr, "quest_progressed", 1)


# --- Query Tests ---


func test_get_active_quests() -> void:
	var q1 := _make_quest({"id": &"quest_a", "title": "Quest A"})
	var q2 := _make_quest({"id": &"quest_b", "title": "Quest B"})
	_mgr.accept_quest(q1)
	_mgr.accept_quest(q2)
	assert_eq(_mgr.get_active_quests().size(), 2)


func test_get_completed_quests() -> void:
	var q := _make_quest({
		"objectives": ["Do one thing"] as Array[String],
	})
	_mgr.accept_quest(q)
	_mgr.complete_objective(&"test_quest", 0)
	assert_eq(_mgr.get_completed_quests().size(), 1)
	assert_eq(_mgr.get_active_quests().size(), 0)


func test_is_quest_active_false_for_unknown() -> void:
	assert_false(_mgr.is_quest_active(&"nonexistent"))


func test_is_quest_completed_false_for_unknown() -> void:
	assert_false(_mgr.is_quest_completed(&"nonexistent"))


func test_get_quest_data_returns_stored_data() -> void:
	var q := _make_quest({"title": "My Quest"})
	_mgr.accept_quest(q)
	var data: Resource = _mgr.get_quest_data(&"test_quest")
	assert_not_null(data)
	assert_eq(data.title, "My Quest")


func test_get_quest_data_returns_null_for_unknown() -> void:
	assert_null(_mgr.get_quest_data(&"nonexistent"))


# --- Fail Quest Tests ---


func test_fail_quest() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	_mgr.fail_quest(&"test_quest")
	assert_false(_mgr.is_quest_active(&"test_quest"))
	assert_true(_mgr.is_quest_failed(&"test_quest"))


func test_fail_quest_emits_signal() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	watch_signals(_mgr)
	_mgr.fail_quest(&"test_quest")
	assert_signal_emitted(_mgr, "quest_failed")


func test_fail_unknown_quest_ignored() -> void:
	watch_signals(_mgr)
	_mgr.fail_quest(&"nonexistent")
	assert_signal_not_emitted(_mgr, "quest_failed")


# --- Serialization Tests ---


func test_serialize_empty() -> void:
	var data: Dictionary = _mgr.serialize()
	assert_eq(data.get("active", {}).size(), 0)
	assert_eq(data.get("completed", []).size(), 0)
	assert_eq(data.get("failed", []).size(), 0)


func test_serialize_active_quest() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	_mgr.complete_objective(&"test_quest", 0)
	var data: Dictionary = _mgr.serialize()
	assert_true(data["active"].has("test_quest"))
	var quest_state: Dictionary = data["active"]["test_quest"]
	assert_true(quest_state["objectives"][0])
	assert_false(quest_state["objectives"][1])


func test_serialize_completed_quest() -> void:
	var q := _make_quest({
		"objectives": ["Do thing"] as Array[String],
	})
	_mgr.accept_quest(q)
	_mgr.complete_objective(&"test_quest", 0)
	var data: Dictionary = _mgr.serialize()
	assert_true(data["completed"].has("test_quest"))


func test_deserialize_restores_active_quest() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	_mgr.complete_objective(&"test_quest", 0)
	var data: Dictionary = _mgr.serialize()

	# Create fresh manager and restore
	var mgr2: Node = QuestManagerScript.new()
	add_child_autofree(mgr2)
	mgr2.deserialize(data, [q])

	assert_true(mgr2.is_quest_active(&"test_quest"))
	var status: Array = mgr2.get_objective_status(&"test_quest")
	assert_true(status[0])
	assert_false(status[1])


func test_deserialize_restores_completed_quest() -> void:
	var q := _make_quest({
		"objectives": ["Do thing"] as Array[String],
	})
	_mgr.accept_quest(q)
	_mgr.complete_objective(&"test_quest", 0)
	var data: Dictionary = _mgr.serialize()

	var mgr2: Node = QuestManagerScript.new()
	add_child_autofree(mgr2)
	mgr2.deserialize(data, [q])

	assert_true(mgr2.is_quest_completed(&"test_quest"))


func test_deserialize_restores_failed_quest() -> void:
	var q := _make_quest()
	_mgr.accept_quest(q)
	_mgr.fail_quest(&"test_quest")
	var data: Dictionary = _mgr.serialize()

	var mgr2: Node = QuestManagerScript.new()
	add_child_autofree(mgr2)
	mgr2.deserialize(data, [q])

	assert_true(mgr2.is_quest_failed(&"test_quest"))


# --- Prerequisites Tests ---


func test_can_accept_with_no_prerequisites() -> void:
	var q := _make_quest()
	assert_true(_mgr.can_accept_quest(q))


func test_cannot_accept_with_unmet_prerequisites() -> void:
	var q := _make_quest({
		"prerequisites": ["flag_a", "flag_b"] as Array[String],
	})
	assert_false(_mgr.can_accept_quest(q))


func test_can_accept_with_met_prerequisites() -> void:
	var q := _make_quest({
		"prerequisites": ["flag_a"] as Array[String],
	})
	_mgr.set_flag_checker(func(flag: String) -> bool: return true)
	assert_true(_mgr.can_accept_quest(q))

extends GutTest

## Tests for the objective tracker display logic in hud.gd.
## Uses compute_tracker_state() static method for pure logic testing.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const HudScript = preload("res://ui/hud/hud.gd")

var _qm: Node


func before_each() -> void:
	_qm = load("res://autoloads/quest_manager.gd").new()
	add_child_autofree(_qm)


func test_tracker_hidden_when_no_active_quests() -> void:
	var state: Dictionary = HudScript.compute_tracker_state(_qm)
	assert_false(state["visible"])


func test_tracker_shows_first_active_quest_title() -> void:
	var quest := Helpers.make_quest({
		"id": &"herb",
		"title": "Herb Gathering",
	})
	_qm.accept_quest(quest)
	var state: Dictionary = HudScript.compute_tracker_state(_qm)
	assert_true(state["visible"])
	assert_eq(state["title"], "Herb Gathering")


func test_tracker_shows_first_incomplete_objective() -> void:
	var quest := Helpers.make_quest({
		"id": &"herb",
		"title": "Herb Gathering",
		"objectives": ["Collect 3 herbs", "Return to Maren"],
	})
	_qm.accept_quest(quest)
	var state: Dictionary = HudScript.compute_tracker_state(_qm)
	assert_eq(state["objective"], "- Collect 3 herbs")


func test_tracker_updates_on_quest_progress() -> void:
	var quest := Helpers.make_quest({
		"id": &"herb",
		"title": "Herb Gathering",
		"objectives": ["Collect 3 herbs", "Return to Maren"],
	})
	_qm.accept_quest(quest)
	_qm.complete_objective(&"herb", 0)
	var state: Dictionary = HudScript.compute_tracker_state(_qm)
	assert_eq(state["objective"], "- Return to Maren")


func test_tracker_hides_after_all_quests_completed() -> void:
	var quest := Helpers.make_quest({
		"id": &"herb",
		"objectives": ["Collect herbs"],
	})
	_qm.accept_quest(quest)
	_qm.complete_objective(&"herb", 0)
	# Quest auto-completes when all objectives done — no active quests remain
	var state: Dictionary = HudScript.compute_tracker_state(_qm)
	assert_false(state["visible"])


func test_tracker_shows_second_quest_when_first_completes() -> void:
	var quest_a := Helpers.make_quest({
		"id": &"herb",
		"title": "Herb Gathering",
		"objectives": ["Collect herbs"],
	})
	var quest_b := Helpers.make_quest({
		"id": &"escort",
		"title": "Escort Mission",
		"objectives": ["Meet at gate", "Reach destination"],
	})
	_qm.accept_quest(quest_a)
	_qm.accept_quest(quest_b)
	_qm.complete_objective(&"herb", 0)
	# quest_a auto-completed, quest_b still active
	var state: Dictionary = HudScript.compute_tracker_state(_qm)
	assert_true(state["visible"])
	assert_eq(state["title"], "Escort Mission")
	assert_eq(state["objective"], "- Meet at gate")


func test_tracker_handles_null_quest_data() -> void:
	# Manually insert a state without quest data to simulate edge case
	_qm._states[&"ghost"] = _qm.State.ACTIVE
	var state: Dictionary = HudScript.compute_tracker_state(_qm)
	# ghost has no quest data, so tracker should skip it
	assert_false(state["visible"])

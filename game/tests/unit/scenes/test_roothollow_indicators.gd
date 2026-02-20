extends GutTest

## Tests for compute_npc_indicator_type — the static helper that maps
## NPC IDs to NPC.IndicatorType based on live quest state.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _rh: GDScript
var _qm: Node


func before_each() -> void:
	_rh = load("res://scenes/roothollow/roothollow_quests.gd")
	_qm = load("res://autoloads/quest_manager.gd").new()
	add_child_autofree(_qm)


# -- Unknown NPC --

func test_unknown_npc_returns_chat() -> void:
	var result: NPC.IndicatorType = _rh.compute_npc_indicator_type(
		&"unknown_npc", _qm
	)
	assert_eq(result, NPC.IndicatorType.CHAT)


# -- Thessa (elder_wisdom quest) --

func test_thessa_no_quest_returns_quest() -> void:
	var result: NPC.IndicatorType = _rh.compute_npc_indicator_type(
		&"thessa", _qm
	)
	assert_eq(result, NPC.IndicatorType.QUEST)


func test_thessa_active_returns_quest_active() -> void:
	var quest := Helpers.make_quest({
		"id": &"elder_wisdom",
		"objectives": ["Visit the shrine"],
	})
	_qm.accept_quest(quest)
	var result: NPC.IndicatorType = _rh.compute_npc_indicator_type(
		&"thessa", _qm
	)
	assert_eq(result, NPC.IndicatorType.QUEST_ACTIVE)


func test_thessa_completed_returns_chat() -> void:
	var quest := Helpers.make_quest({
		"id": &"elder_wisdom",
		"objectives": ["Visit the shrine"],
	})
	_qm.accept_quest(quest)
	_qm.complete_objective(&"elder_wisdom", 0)
	var result: NPC.IndicatorType = _rh.compute_npc_indicator_type(
		&"thessa", _qm
	)
	assert_eq(result, NPC.IndicatorType.CHAT)


# -- Wren (scouts_report quest) --

func test_wren_no_quest_returns_quest() -> void:
	var result: NPC.IndicatorType = _rh.compute_npc_indicator_type(
		&"wren", _qm
	)
	assert_eq(result, NPC.IndicatorType.QUEST)


func test_wren_active_returns_quest_active() -> void:
	var quest := Helpers.make_quest({
		"id": &"scouts_report",
		"objectives": ["Scout the ruins"],
	})
	_qm.accept_quest(quest)
	var result: NPC.IndicatorType = _rh.compute_npc_indicator_type(
		&"wren", _qm
	)
	assert_eq(result, NPC.IndicatorType.QUEST_ACTIVE)


func test_wren_completed_returns_chat() -> void:
	var quest := Helpers.make_quest({
		"id": &"scouts_report",
		"objectives": ["Scout the ruins"],
	})
	_qm.accept_quest(quest)
	_qm.complete_objective(&"scouts_report", 0)
	var result: NPC.IndicatorType = _rh.compute_npc_indicator_type(
		&"wren", _qm
	)
	assert_eq(result, NPC.IndicatorType.CHAT)

extends GutTest

## Tests for BattleManager battle-start guards.
## Verifies that battles cannot start during dialogue, cutscenes, or transitions.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _bm: Node


func before_each() -> void:
	_bm = load("res://autoloads/battle_manager.gd").new()
	add_child_autofree(_bm)


func after_each() -> void:
	# Clean up any dialogue state left behind by tests
	if DialogueManager.is_active():
		# Advance past all remaining lines to trigger _end_dialogue
		for i in 20:
			if not DialogueManager.is_active():
				break
			DialogueManager.advance()
	# Ensure GameManager is back to OVERWORLD
	while GameManager.current_state != GameManager.GameState.OVERWORLD:
		GameManager.pop_state()


func _make_enemy_group() -> Array[Resource]:
	return [Helpers.make_enemy_data()] as Array[Resource]


# -- Basic state --

func test_is_in_battle_initially_false() -> void:
	assert_false(_bm.is_in_battle())


# -- Dialogue blocking --

func test_start_battle_blocked_when_dialogue_active() -> void:
	var lines: Array[DialogueLine] = [DialogueLine.create("", "Test")]
	DialogueManager.start_dialogue(lines)
	assert_true(DialogueManager.is_active(), "Precondition: dialogue active")

	_bm.start_battle(_make_enemy_group())
	assert_false(
		_bm.is_in_battle(),
		"Battle must not start while dialogue is active",
	)


# -- State blocking --

func test_start_battle_blocked_during_cutscene() -> void:
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	_bm.start_battle(_make_enemy_group())
	assert_false(
		_bm.is_in_battle(),
		"Battle must not start during CUTSCENE state",
	)


func test_start_battle_blocked_during_menu() -> void:
	GameManager.push_state(GameManager.GameState.MENU)

	_bm.start_battle(_make_enemy_group())
	assert_false(
		_bm.is_in_battle(),
		"Battle must not start during MENU state",
	)


# -- Transition blocking --

func test_start_battle_blocked_during_scene_transition() -> void:
	# Simulate an active scene transition
	GameManager._is_transitioning = true

	_bm.start_battle(_make_enemy_group())
	assert_false(
		_bm.is_in_battle(),
		"Battle must not start during scene transition",
	)

	# Clean up
	GameManager._is_transitioning = false


# -- Double battle guard (existing behavior) --

func test_start_battle_blocked_when_already_in_battle() -> void:
	_bm._is_in_battle = true
	_bm.start_battle(_make_enemy_group())
	# Should not crash or double-fire — already in battle
	assert_true(_bm.is_in_battle())

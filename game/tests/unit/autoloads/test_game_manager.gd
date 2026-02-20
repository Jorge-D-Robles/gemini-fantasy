extends GutTest

## Tests for GameManager state stack logic.
## Creates a fresh instance per test — never touches the global singleton.

var _gm: Node


func before_each() -> void:
	_gm = load("res://autoloads/game_manager.gd").new()
	add_child_autofree(_gm)


func test_initial_state_is_overworld() -> void:
	assert_eq(_gm.current_state, _gm.GameState.OVERWORLD)


func test_push_state_updates_current() -> void:
	_gm.push_state(_gm.GameState.BATTLE)
	assert_eq(_gm.current_state, _gm.GameState.BATTLE)


func test_pop_state_restores_previous() -> void:
	_gm.push_state(_gm.GameState.BATTLE)
	_gm.pop_state()
	assert_eq(_gm.current_state, _gm.GameState.OVERWORLD)


func test_pop_empty_stack_stays_current() -> void:
	_gm.pop_state()
	assert_eq(_gm.current_state, _gm.GameState.OVERWORLD)


func test_nested_push_pop() -> void:
	_gm.push_state(_gm.GameState.DIALOGUE)
	_gm.push_state(_gm.GameState.MENU)
	assert_eq(_gm.current_state, _gm.GameState.MENU)
	_gm.pop_state()
	assert_eq(_gm.current_state, _gm.GameState.DIALOGUE)
	_gm.pop_state()
	assert_eq(_gm.current_state, _gm.GameState.OVERWORLD)


func test_push_emits_game_state_changed() -> void:
	watch_signals(_gm)
	_gm.push_state(_gm.GameState.BATTLE)
	assert_signal_emitted_with_parameters(
		_gm, "game_state_changed",
		[_gm.GameState.OVERWORLD, _gm.GameState.BATTLE],
	)


func test_pop_emits_game_state_changed() -> void:
	_gm.push_state(_gm.GameState.CUTSCENE)
	watch_signals(_gm)
	_gm.pop_state()
	assert_signal_emitted_with_parameters(
		_gm, "game_state_changed",
		[_gm.GameState.CUTSCENE, _gm.GameState.OVERWORLD],
	)


func test_is_transitioning_default_false() -> void:
	assert_false(_gm.is_transitioning())


## --- playtime accumulation (T-0130) ---

func test_playtime_starts_at_zero() -> void:
	assert_almost_eq(_gm.playtime_seconds, 0.0, 0.0001, "Playtime starts at 0.0")


func test_compute_should_tick_in_overworld() -> void:
	assert_true(
		_gm.compute_should_tick_playtime(_gm.GameState.OVERWORLD),
		"Overworld state should tick playtime",
	)


func test_compute_should_tick_in_menu() -> void:
	assert_true(
		_gm.compute_should_tick_playtime(_gm.GameState.MENU),
		"Menu state should tick playtime",
	)


func test_compute_should_not_tick_in_battle() -> void:
	assert_false(
		_gm.compute_should_tick_playtime(_gm.GameState.BATTLE),
		"Battle state should not tick playtime",
	)


func test_compute_should_not_tick_in_dialogue() -> void:
	assert_false(
		_gm.compute_should_tick_playtime(_gm.GameState.DIALOGUE),
		"Dialogue state should not tick playtime",
	)


func test_compute_should_not_tick_in_cutscene() -> void:
	assert_false(
		_gm.compute_should_tick_playtime(_gm.GameState.CUTSCENE),
		"Cutscene state should not tick playtime",
	)

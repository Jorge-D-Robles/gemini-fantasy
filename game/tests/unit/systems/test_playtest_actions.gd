extends GutTest

## Unit tests for PlaytestActions — action validation and type registry.

const PlaytestActions := preload("res://tools/playtest_actions.gd")


# --- get_all_action_types ---

func test_action_types_includes_wait() -> void:
	assert_true("wait" in PlaytestActions.get_all_action_types())


func test_action_types_includes_screenshot() -> void:
	assert_true("screenshot" in PlaytestActions.get_all_action_types())


func test_action_types_includes_move() -> void:
	assert_true("move" in PlaytestActions.get_all_action_types())


func test_action_types_includes_interact() -> void:
	assert_true("interact" in PlaytestActions.get_all_action_types())


func test_action_types_includes_cancel() -> void:
	assert_true("cancel" in PlaytestActions.get_all_action_types())


func test_action_types_includes_menu() -> void:
	assert_true("menu" in PlaytestActions.get_all_action_types())


func test_action_types_includes_advance_dialogue() -> void:
	assert_true("advance_dialogue" in PlaytestActions.get_all_action_types())


func test_action_types_includes_wait_dialogue() -> void:
	assert_true("wait_dialogue" in PlaytestActions.get_all_action_types())


func test_action_types_includes_select_choice() -> void:
	assert_true("select_choice" in PlaytestActions.get_all_action_types())


func test_action_types_includes_trigger_battle() -> void:
	assert_true("trigger_battle" in PlaytestActions.get_all_action_types())


func test_action_types_includes_wait_battle() -> void:
	assert_true("wait_battle" in PlaytestActions.get_all_action_types())


func test_action_types_includes_wait_state() -> void:
	assert_true("wait_state" in PlaytestActions.get_all_action_types())


func test_action_types_includes_set_flag() -> void:
	assert_true("set_flag" in PlaytestActions.get_all_action_types())


func test_action_types_includes_log() -> void:
	assert_true("log" in PlaytestActions.get_all_action_types())


# --- validate_action ---

func test_validate_wait_with_seconds_is_valid() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "wait", "seconds": 1.0}
	)
	assert_eq(errors, [])


func test_validate_wait_without_seconds_is_valid_uses_default() -> void:
	var errors := PlaytestActions.validate_action({"type": "wait"})
	assert_eq(errors, [])


func test_validate_screenshot_with_label_is_valid() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "screenshot", "label": "my_label"}
	)
	assert_eq(errors, [])


func test_validate_screenshot_without_label_is_valid_uses_default() -> void:
	var errors := PlaytestActions.validate_action({"type": "screenshot"})
	assert_eq(errors, [])


func test_validate_move_with_direction_is_valid() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "move", "direction": "right", "seconds": 1.0}
	)
	assert_eq(errors, [])


func test_validate_move_with_invalid_direction_returns_error() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "move", "direction": "diagonal", "seconds": 1.0}
	)
	assert_true(errors.size() > 0)


func test_validate_select_choice_with_index_is_valid() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "select_choice", "index": 0}
	)
	assert_eq(errors, [])


func test_validate_select_choice_without_index_returns_error() -> void:
	var errors := PlaytestActions.validate_action({"type": "select_choice"})
	assert_true(errors.size() > 0)


func test_validate_trigger_battle_with_enemies_is_valid() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "trigger_battle", "enemies": ["memory_bloom"]}
	)
	assert_eq(errors, [])


func test_validate_trigger_battle_without_enemies_returns_error() -> void:
	var errors := PlaytestActions.validate_action({"type": "trigger_battle"})
	assert_true(errors.size() > 0)


func test_validate_trigger_battle_with_empty_enemies_returns_error() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "trigger_battle", "enemies": []}
	)
	assert_true(errors.size() > 0)


func test_validate_set_flag_with_flag_is_valid() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "set_flag", "flag": "my_flag"}
	)
	assert_eq(errors, [])


func test_validate_set_flag_without_flag_returns_error() -> void:
	var errors := PlaytestActions.validate_action({"type": "set_flag"})
	assert_true(errors.size() > 0)


func test_validate_log_with_message_is_valid() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "log", "message": "test message"}
	)
	assert_eq(errors, [])


func test_validate_wait_state_with_state_is_valid() -> void:
	var errors := PlaytestActions.validate_action(
		{"type": "wait_state", "state": "OVERWORLD"}
	)
	assert_eq(errors, [])


func test_validate_wait_state_without_state_returns_error() -> void:
	var errors := PlaytestActions.validate_action({"type": "wait_state"})
	assert_true(errors.size() > 0)


func test_validate_unknown_type_returns_error() -> void:
	var errors := PlaytestActions.validate_action({"type": "unknown_xyz"})
	assert_true(errors.size() > 0)


func test_validate_missing_type_returns_error() -> void:
	var errors := PlaytestActions.validate_action({})
	assert_true(errors.size() > 0)


# --- get_action_input_name ---

func test_interact_maps_to_interact_action() -> void:
	assert_eq(PlaytestActions.get_action_input_name("interact"), "interact")


func test_cancel_maps_to_cancel_action() -> void:
	assert_eq(PlaytestActions.get_action_input_name("cancel"), "cancel")


func test_menu_maps_to_menu_action() -> void:
	assert_eq(PlaytestActions.get_action_input_name("menu"), "menu")


func test_advance_dialogue_maps_to_interact() -> void:
	assert_eq(
		PlaytestActions.get_action_input_name("advance_dialogue"), "interact"
	)


# --- auto_play_battle ---

func test_action_types_includes_auto_play_battle() -> void:
	assert_true("auto_play_battle" in PlaytestActions.get_all_action_types())


func test_auto_play_battle_valid_minimal() -> void:
	var errors := PlaytestActions.validate_action({"type": "auto_play_battle"})
	assert_eq(errors, [])


func test_auto_play_battle_valid_with_enemies() -> void:
	var errors := PlaytestActions.validate_action({
		"type": "auto_play_battle",
		"enemies": ["memory_bloom"],
	})
	assert_eq(errors, [])


func test_auto_play_battle_empty_enemies_rejected() -> void:
	var errors := PlaytestActions.validate_action({
		"type": "auto_play_battle",
		"enemies": [],
	})
	assert_true(errors.size() > 0)

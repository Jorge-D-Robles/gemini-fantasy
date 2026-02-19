extends GutTest

## Unit tests for PlaytestConfig — JSON config parsing and CLI arg parsing.

const PlaytestConfig := preload("res://tools/playtest_config.gd")


# --- parse_json ---

func test_parse_json_returns_dict_with_scene() -> void:
	var json := '{"scene":"res://scenes/roothollow/roothollow.tscn"}'
	var result := PlaytestConfig.parse_json(json)
	assert_eq(result.get("scene"), "res://scenes/roothollow/roothollow.tscn")


func test_parse_json_invalid_json_returns_empty_dict() -> void:
	var result := PlaytestConfig.parse_json("{bad json")
	assert_eq(result, {})


func test_parse_json_returns_empty_dict_on_empty_string() -> void:
	var result := PlaytestConfig.parse_json("")
	assert_eq(result, {})


func test_parse_json_preserves_nested_state() -> void:
	var json := '{"scene":"res://s.tscn","state":{"gold":500,"flags":["f1","f2"]}}'
	var result := PlaytestConfig.parse_json(json)
	var state: Dictionary = result.get("state", {})
	assert_eq(state.get("gold"), 500)
	assert_eq(state.get("flags"), ["f1", "f2"])


func test_parse_json_preserves_actions_array() -> void:
	var json := '{"scene":"res://s.tscn","actions":[{"type":"wait","seconds":1.0}]}'
	var result := PlaytestConfig.parse_json(json)
	var actions: Array = result.get("actions", [])
	assert_eq(actions.size(), 1)
	assert_eq(actions[0].get("type"), "wait")


# --- parse_cli_args ---

func test_parse_cli_args_scene_arg() -> void:
	var args := PackedStringArray(["--scene=res://scenes/roothollow/roothollow.tscn"])
	var result := PlaytestConfig.parse_cli_args(args)
	assert_eq(result.get("scene"), "res://scenes/roothollow/roothollow.tscn")


func test_parse_cli_args_config_arg_returns_path() -> void:
	var args := PackedStringArray(["--config=/tmp/my_config.json"])
	var result := PlaytestConfig.parse_cli_args(args)
	assert_eq(result.get("config_path"), "/tmp/my_config.json")


func test_parse_cli_args_party_splits_by_comma() -> void:
	var args := PackedStringArray(["--party=kael,lyra,iris"])
	var result := PlaytestConfig.parse_cli_args(args)
	var state: Dictionary = result.get("state", {})
	assert_eq(state.get("party"), ["kael", "lyra", "iris"])


func test_parse_cli_args_flags_splits_by_comma() -> void:
	var args := PackedStringArray(["--flags=opening_lyra_discovered,iris_recruited"])
	var result := PlaytestConfig.parse_cli_args(args)
	var state: Dictionary = result.get("state", {})
	assert_eq(state.get("flags"), ["opening_lyra_discovered", "iris_recruited"])


func test_parse_cli_args_gold_converts_to_int() -> void:
	var args := PackedStringArray(["--gold=1500"])
	var result := PlaytestConfig.parse_cli_args(args)
	var state: Dictionary = result.get("state", {})
	assert_eq(state.get("gold"), 1500)


func test_parse_cli_args_output_path() -> void:
	var args := PackedStringArray(["--output=/tmp/playtest/"])
	var result := PlaytestConfig.parse_cli_args(args)
	var options: Dictionary = result.get("options", {})
	assert_eq(options.get("output_dir"), "/tmp/playtest/")


func test_parse_cli_args_screenshot_after_as_wait_and_screenshot_actions() -> void:
	var args := PackedStringArray(
		["--scene=res://s.tscn", "--screenshot-after=2"]
	)
	var result := PlaytestConfig.parse_cli_args(args)
	var actions: Array = result.get("actions", [])
	assert_true(actions.size() >= 1)
	var last_action: Dictionary = actions[actions.size() - 1]
	assert_eq(last_action.get("type"), "screenshot")


# --- merge_defaults ---

func test_merge_defaults_adds_timeout_seconds() -> void:
	var config := {"scene": "res://s.tscn"}
	var merged := PlaytestConfig.merge_defaults(config)
	assert_true(merged.has("options"))
	var options: Dictionary = merged["options"]
	assert_eq(options.get("timeout_seconds"), 60.0)


func test_merge_defaults_adds_output_dir() -> void:
	var config := {"scene": "res://s.tscn"}
	var merged := PlaytestConfig.merge_defaults(config)
	var options: Dictionary = merged["options"]
	assert_eq(options.get("output_dir"), "/tmp/playtest/")


func test_merge_defaults_preserves_user_options() -> void:
	var config := {
		"scene": "res://s.tscn",
		"options": {"timeout_seconds": 120.0, "output_dir": "/custom/"},
	}
	var merged := PlaytestConfig.merge_defaults(config)
	var options: Dictionary = merged["options"]
	assert_eq(options.get("timeout_seconds"), 120.0)
	assert_eq(options.get("output_dir"), "/custom/")


func test_merge_defaults_disable_bgm_default_true() -> void:
	var config := {"scene": "res://s.tscn"}
	var merged := PlaytestConfig.merge_defaults(config)
	var options: Dictionary = merged["options"]
	assert_true(options.get("disable_bgm", false))


# --- validate ---

func test_validate_returns_error_when_scene_missing() -> void:
	var config := {}
	var errors := PlaytestConfig.validate(config)
	assert_true(errors.size() > 0)
	assert_true(errors[0].contains("scene"))


func test_validate_returns_empty_for_valid_config() -> void:
	var config := {"scene": "res://scenes/roothollow/roothollow.tscn"}
	var errors := PlaytestConfig.validate(config)
	assert_eq(errors, [])


func test_validate_returns_error_when_scene_not_string() -> void:
	var config := {"scene": 42}
	var errors := PlaytestConfig.validate(config)
	assert_true(errors.size() > 0)

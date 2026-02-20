extends GutTest

## Tests for DebugCommands static helpers.
## Validates command parsing and result structure without live autoloads.

const DC := preload("res://ui/debug_console/debug_commands.gd")


# -- compute_debug_command_result --


func test_empty_input_returns_not_ok() -> void:
	var result := DC.compute_debug_command_result("")
	assert_false(result["ok"], "Empty command should return ok=false")


func test_whitespace_input_returns_not_ok() -> void:
	var result := DC.compute_debug_command_result("   ")
	assert_false(result["ok"], "Whitespace-only input should return ok=false")


func test_unknown_command_returns_not_ok() -> void:
	var result := DC.compute_debug_command_result("xyzzy 123")
	assert_false(result["ok"], "Unknown command should return ok=false")
	assert_true(
		(result["message"] as String).length() > 0,
		"Unknown command should return a non-empty message",
	)


func test_heal_all_returns_ok() -> void:
	var result := DC.compute_debug_command_result("heal_all")
	assert_true(result["ok"], "heal_all should return ok=true")


func test_heal_all_case_insensitive() -> void:
	var result := DC.compute_debug_command_result("HEAL_ALL")
	assert_true(result["ok"], "heal_all should be case-insensitive")


func test_set_level_with_valid_arg_returns_ok() -> void:
	var result := DC.compute_debug_command_result("set_level 5")
	assert_true(result["ok"], "set_level with valid number should return ok=true")


func test_set_level_without_arg_returns_not_ok() -> void:
	var result := DC.compute_debug_command_result("set_level")
	assert_false(result["ok"], "set_level without arg should return ok=false")


func test_set_level_with_nonnumeric_arg_returns_not_ok() -> void:
	var result := DC.compute_debug_command_result("set_level abc")
	assert_false(
		result["ok"],
		"set_level with non-numeric arg should return ok=false",
	)


func test_add_item_with_id_returns_ok() -> void:
	var result := DC.compute_debug_command_result("add_item health_potion")
	assert_true(result["ok"], "add_item with item ID should return ok=true")


func test_add_item_without_arg_returns_not_ok() -> void:
	var result := DC.compute_debug_command_result("add_item")
	assert_false(result["ok"], "add_item without arg should return ok=false")


func test_add_item_with_qty_returns_ok() -> void:
	var result := DC.compute_debug_command_result("add_item health_potion 3")
	assert_true(result["ok"], "add_item with item ID and qty should return ok=true")


func test_teleport_with_scene_name_returns_ok() -> void:
	var result := DC.compute_debug_command_result("teleport roothollow")
	assert_true(result["ok"], "teleport with known scene name should return ok=true")


func test_teleport_without_arg_returns_not_ok() -> void:
	var result := DC.compute_debug_command_result("teleport")
	assert_false(result["ok"], "teleport without arg should return ok=false")


func test_teleport_unknown_scene_returns_not_ok() -> void:
	var result := DC.compute_debug_command_result("teleport nonexistent_zone_xyz")
	assert_false(
		result["ok"],
		"teleport with unknown scene name should return ok=false",
	)


func test_set_flag_with_name_returns_ok() -> void:
	var result := DC.compute_debug_command_result("set_flag garrick_recruited")
	assert_true(result["ok"], "set_flag with flag name should return ok=true")


func test_set_flag_without_arg_returns_not_ok() -> void:
	var result := DC.compute_debug_command_result("set_flag")
	assert_false(result["ok"], "set_flag without arg should return ok=false")


func test_result_has_command_field() -> void:
	var result := DC.compute_debug_command_result("heal_all")
	assert_true(result.has("command"), "Result must have 'command' field")
	assert_eq(result["command"], "heal_all")


func test_result_has_args_field() -> void:
	var result := DC.compute_debug_command_result("set_level 3")
	assert_true(result.has("args"), "Result must have 'args' field")
	assert_eq((result["args"] as Array).size(), 1)

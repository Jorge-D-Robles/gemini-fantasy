extends GutTest

## Tests for T-0138: battle log formatting via BattleUILog.compute_log_entry().

const BattleUILog = preload("res://ui/battle_ui/battle_ui_log.gd")
const UITheme = preload("res://ui/ui_theme.gd")


func test_compute_log_entry_contains_text() -> void:
	var result := BattleUILog.compute_log_entry("Kael attacks!", UITheme.LogType.INFO)
	assert_true(
		result.contains("Kael attacks!"),
		"Log entry should contain the original text",
	)


func test_compute_log_entry_wraps_in_bbcode_color_tags() -> void:
	var result := BattleUILog.compute_log_entry("test", UITheme.LogType.INFO)
	assert_true(result.begins_with("[color="), "Entry should start with [color= tag")
	assert_true(result.contains("[/color]"), "Entry should contain closing [/color] tag")


func test_compute_log_entry_ends_with_newline() -> void:
	var result := BattleUILog.compute_log_entry("test", UITheme.LogType.INFO)
	assert_true(result.ends_with("\n"), "Log entry should end with newline for accumulation")


func test_compute_log_entry_default_type_is_info() -> void:
	var default_result := BattleUILog.compute_log_entry("msg")
	var explicit_info := BattleUILog.compute_log_entry("msg", UITheme.LogType.INFO)
	assert_eq(default_result, explicit_info, "Default log type should be INFO")


func test_compute_log_entry_damage_color_differs_from_info() -> void:
	var info_entry := BattleUILog.compute_log_entry("x", UITheme.LogType.INFO)
	var damage_entry := BattleUILog.compute_log_entry("x", UITheme.LogType.DAMAGE)
	assert_ne(info_entry, damage_entry, "DAMAGE log type should use a different color than INFO")


func test_compute_log_entry_info_color_matches_theme_hex() -> void:
	var result := BattleUILog.compute_log_entry("x", UITheme.LogType.INFO)
	var expected_hex := UITheme.LOG_INFO.to_html(false)
	assert_true(
		result.contains(expected_hex),
		"INFO entry should contain the UITheme.LOG_INFO hex color",
	)


func test_compute_log_entry_damage_color_matches_theme_hex() -> void:
	var result := BattleUILog.compute_log_entry("x", UITheme.LogType.DAMAGE)
	var expected_hex := UITheme.LOG_DAMAGE.to_html(false)
	assert_true(
		result.contains(expected_hex),
		"DAMAGE entry should contain the UITheme.LOG_DAMAGE hex color",
	)

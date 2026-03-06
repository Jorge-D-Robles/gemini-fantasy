extends GutTest

## Tests for color-coded battle log messages.

const UITheme = preload("res://ui/ui_theme.gd")


func test_get_log_color_returns_correct_color_for_each_type() -> void:
	var cases: Array[Array] = [
		[UITheme.LogType.INFO, UITheme.LOG_INFO],
		[UITheme.LogType.DAMAGE, UITheme.LOG_DAMAGE],
		[UITheme.LogType.HEAL, UITheme.LOG_HEAL],
		[UITheme.LogType.STATUS, UITheme.LOG_STATUS],
		[UITheme.LogType.SYSTEM, UITheme.LOG_SYSTEM],
		[UITheme.LogType.VICTORY, UITheme.LOG_VICTORY],
		[UITheme.LogType.DEFEAT, UITheme.LOG_DEFEAT],
	]
	for entry: Array in cases:
		var color := UITheme.get_log_color(entry[0])
		assert_eq(color, entry[1], "get_log_color(%d)" % entry[0])


func test_get_log_color_invalid_returns_default() -> void:
	var color := UITheme.get_log_color(999)
	assert_eq(color, UITheme.LOG_INFO)


func test_log_type_values_are_unique() -> void:
	var values: Array[int] = [
		UITheme.LogType.INFO, UITheme.LogType.DAMAGE, UITheme.LogType.HEAL,
		UITheme.LogType.STATUS, UITheme.LogType.SYSTEM,
		UITheme.LogType.VICTORY, UITheme.LogType.DEFEAT,
	]
	var seen: Dictionary = {}
	for v in values:
		assert_false(seen.has(v), "Duplicate LogType value: %d" % v)
		seen[v] = true


func test_all_log_colors_have_full_opacity() -> void:
	var colors: Array[Color] = [
		UITheme.LOG_INFO, UITheme.LOG_DAMAGE, UITheme.LOG_HEAL,
		UITheme.LOG_STATUS, UITheme.LOG_SYSTEM,
		UITheme.LOG_VICTORY, UITheme.LOG_DEFEAT,
	]
	for c in colors:
		assert_eq(c.a, 1.0, "Color %s should have alpha 1.0" % str(c))

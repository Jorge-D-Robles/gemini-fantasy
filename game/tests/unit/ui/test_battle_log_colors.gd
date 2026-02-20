extends GutTest

## Tests for color-coded battle log messages (T-0052).

const UITheme = preload("res://ui/ui_theme.gd")


# ---- LogType enum tests ----

func test_log_type_values_are_unique() -> void:
	var values: Array[int] = [
		UITheme.LogType.INFO,
		UITheme.LogType.DAMAGE,
		UITheme.LogType.HEAL,
		UITheme.LogType.STATUS,
		UITheme.LogType.SYSTEM,
		UITheme.LogType.VICTORY,
		UITheme.LogType.DEFEAT,
	]
	var seen: Dictionary = {}
	for v in values:
		assert_false(seen.has(v), "Duplicate LogType value: %d" % v)
		seen[v] = true


# ---- LOG_COLORS dict tests ----

func test_log_colors_has_entry_for_each_type() -> void:
	assert_eq(UITheme.LOG_COLORS.size(), 7)


func test_log_colors_values_are_colors() -> void:
	for key in UITheme.LOG_COLORS:
		var val = UITheme.LOG_COLORS[key]
		assert_true(val is Color, "LOG_COLORS[%d] should be Color" % key)


# ---- get_log_color() tests ----

func test_get_log_color_info() -> void:
	var color := UITheme.get_log_color(UITheme.LogType.INFO)
	assert_eq(color, UITheme.LOG_INFO)


func test_get_log_color_damage() -> void:
	var color := UITheme.get_log_color(UITheme.LogType.DAMAGE)
	assert_eq(color, UITheme.LOG_DAMAGE)


func test_get_log_color_heal() -> void:
	var color := UITheme.get_log_color(UITheme.LogType.HEAL)
	assert_eq(color, UITheme.LOG_HEAL)


func test_get_log_color_status() -> void:
	var color := UITheme.get_log_color(UITheme.LogType.STATUS)
	assert_eq(color, UITheme.LOG_STATUS)


func test_get_log_color_system() -> void:
	var color := UITheme.get_log_color(UITheme.LogType.SYSTEM)
	assert_eq(color, UITheme.LOG_SYSTEM)


func test_get_log_color_victory() -> void:
	var color := UITheme.get_log_color(UITheme.LogType.VICTORY)
	assert_eq(color, UITheme.LOG_VICTORY)


func test_get_log_color_defeat() -> void:
	var color := UITheme.get_log_color(UITheme.LogType.DEFEAT)
	assert_eq(color, UITheme.LOG_DEFEAT)


func test_get_log_color_invalid_returns_default() -> void:
	var color := UITheme.get_log_color(999)
	assert_eq(color, UITheme.LOG_INFO)


# ---- Color constant validation tests ----

func test_log_damage_color_is_distinct_from_info() -> void:
	assert_ne(UITheme.LOG_DAMAGE, UITheme.LOG_INFO)


func test_all_log_colors_have_full_opacity() -> void:
	var colors: Array[Color] = [
		UITheme.LOG_INFO,
		UITheme.LOG_DAMAGE,
		UITheme.LOG_HEAL,
		UITheme.LOG_STATUS,
		UITheme.LOG_SYSTEM,
		UITheme.LOG_VICTORY,
		UITheme.LOG_DEFEAT,
	]
	for c in colors:
		assert_eq(c.a, 1.0, "Color %s should have alpha 1.0" % str(c))

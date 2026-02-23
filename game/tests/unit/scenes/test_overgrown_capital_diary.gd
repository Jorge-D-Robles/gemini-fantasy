extends GutTest

## Tests for Survivor's Diary collectible in Overgrown Capital (T-0218).

var _scene: GDScript
var _map: GDScript


func before_each() -> void:
	_scene = load("res://scenes/overgrown_capital/overgrown_capital.gd")
	_map = load("res://scenes/overgrown_capital/overgrown_capital_map.gd")


func test_diary_position_returns_vector2() -> void:
	var pos: Vector2 = _scene.compute_diary_position()
	assert_true(pos is Vector2, "diary position must be a Vector2")


func test_diary_position_within_map_bounds() -> void:
	var pos: Vector2 = _scene.compute_diary_position()
	assert_gt(pos.x, 0.0, "diary x must be > 0")
	assert_lt(pos.x, 640.0, "diary x must be < 640 (map width)")
	assert_gt(pos.y, 0.0, "diary y must be > 0")
	assert_lt(pos.y, 448.0, "diary y must be < 448 (map height)")


func test_diary_position_in_residential_quarter() -> void:
	# Residential Quarter is rows 13-18 (y = 208-288), west cols 2-19 (x = 32-304).
	var pos: Vector2 = _scene.compute_diary_position()
	assert_gte(pos.y, 208.0, "diary must be in residential quarter (row 13+)")
	assert_lte(pos.y, 288.0, "diary must be in residential quarter (row 18-)")
	assert_lt(pos.x, 304.0, "diary must be in residential west (col < 19)")


func test_diary_position_not_in_wall() -> void:
	var pos: Vector2 = _scene.compute_diary_position()
	var col: int = int(pos.x) / 16
	var row: int = int(pos.y) / 16
	var wall_map: Array[String] = _map.WALL_MAP
	assert_lt(row, wall_map.size(), "row must be within WALL_MAP")
	var row_str: String = wall_map[row]
	assert_lt(col, row_str.length(), "col must be within row string")
	var ch: String = row_str[col]
	assert_ne(ch, "W", "diary tile must not be a wall")
	assert_ne(ch, "G", "diary tile must not be a wall border")


func test_diary_lines_returns_non_empty_array() -> void:
	var lines: Array[String] = _scene.compute_diary_lines()
	assert_gte(lines.size(), 8, "diary needs at least 4 speaker/text pairs (8 entries)")


func test_diary_lines_has_even_count() -> void:
	var lines: Array[String] = _scene.compute_diary_lines()
	assert_eq(lines.size() % 2, 0, "diary lines must have even count (speaker/text pairs)")


func test_diary_text_entries_all_non_empty() -> void:
	var lines: Array[String] = _scene.compute_diary_lines()
	# Text entries are at odd indices (speaker at even, text at odd).
	var i := 1
	while i < lines.size():
		assert_gt(lines[i].length(), 0, "diary text at index %d must not be empty" % i)
		i += 2


func test_capital_declares_diary_flag() -> void:
	var source: String = FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd",
	)
	assert_true(
		source.contains("survivors_diary_read"),
		"scene script must reference survivors_diary_read flag",
	)

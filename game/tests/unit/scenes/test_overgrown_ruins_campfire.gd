extends GutTest

## Tests for Overgrown Ruins campfire placement (T-0188).

var _scene: GDScript
var _map: GDScript


func before_each() -> void:
	_scene = load("res://scenes/overgrown_ruins/overgrown_ruins.gd")
	_map = load("res://scenes/overgrown_ruins/overgrown_ruins_map.gd")


func test_campfire_position_returns_vector2() -> void:
	var pos: Vector2 = _scene.compute_ruins_campfire_position()
	assert_true(pos is Vector2, "campfire position must be a Vector2")


func test_campfire_position_within_map_bounds() -> void:
	var pos: Vector2 = _scene.compute_ruins_campfire_position()
	assert_gt(pos.x, 0.0, "campfire x must be > 0")
	assert_lt(pos.x, 640.0, "campfire x must be < 640 (map width)")
	assert_gt(pos.y, 0.0, "campfire y must be > 0")
	assert_lt(pos.y, 384.0, "campfire y must be < 384 (map height)")


func test_campfire_position_not_in_wall() -> void:
	var pos: Vector2 = _scene.compute_ruins_campfire_position()
	var col: int = int(pos.x) / 16
	var row: int = int(pos.y) / 16
	var wall_map: Array[String] = _map.WALL_MAP
	assert_lt(row, wall_map.size(), "row must be within WALL_MAP")
	var row_str: String = wall_map[row]
	assert_lt(col, row_str.length(), "col must be within row string")
	var ch: String = row_str[col]
	assert_ne(ch, "W", "campfire tile must not be a wall")
	assert_ne(ch, "G", "campfire tile must not be a wall border")

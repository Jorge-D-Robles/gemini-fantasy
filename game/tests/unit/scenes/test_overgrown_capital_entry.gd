extends GutTest

## Tests for OvergrownCapital static position helpers.
## These helpers are testability shims analogous to compute_campfire_position()
## in verdant_forest.gd — they mirror actual node positions for unit testing.

var _scene: GDScript


func before_each() -> void:
	_scene = load("res://scenes/overgrown_capital/overgrown_capital.gd")


func test_spawn_position_returns_vector2() -> void:
	var pos: Vector2 = _scene.compute_spawn_from_ruins_position()
	assert_true(pos is Vector2, "spawn position must be a Vector2")


func test_spawn_x_within_map_bounds() -> void:
	var pos: Vector2 = _scene.compute_spawn_from_ruins_position()
	assert_gt(pos.x, 0.0, "spawn x must be > 0")
	assert_lt(pos.x, 640.0, "spawn x must be < 640 (map width)")


func test_spawn_y_within_map_bounds() -> void:
	var pos: Vector2 = _scene.compute_spawn_from_ruins_position()
	assert_gt(pos.y, 0.0, "spawn y must be > 0")
	# Row 27 boundary wall is at y=432. Spawn must be above it.
	assert_lt(pos.y, 432.0, "spawn y must be below boundary wall (y=432)")


func test_market_save_point_within_map_bounds() -> void:
	var pos: Vector2 = _scene.compute_market_save_point_position()
	assert_gt(pos.x, 0.0, "save x must be > 0")
	assert_lt(pos.x, 640.0, "save x must be < 640 (map width)")
	assert_gt(pos.y, 0.0, "save y must be > 0")
	assert_lt(pos.y, 448.0, "save y must be < 448 (map height)")


func test_spawn_differs_from_save_point() -> void:
	var spawn: Vector2 = _scene.compute_spawn_from_ruins_position()
	var save_pt: Vector2 = _scene.compute_market_save_point_position()
	var dist: float = spawn.distance_to(save_pt)
	assert_gte(dist, 16.0, "spawn and save point must be at least 16px apart")

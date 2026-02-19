extends GutTest

## Tests for MapBuilder.create_boundary_walls() — invisible collision at map edges.

var _parent: Node2D


func before_each() -> void:
	_parent = Node2D.new()
	add_child_autofree(_parent)
	MapBuilder.create_boundary_walls(_parent, 640, 384)


func _get_boundaries() -> Node:
	return _parent.get_node_or_null("Boundaries")


func _get_wall(wall_name: String) -> StaticBody2D:
	var bounds: Node = _get_boundaries()
	if not bounds:
		return null
	return bounds.get_node_or_null(wall_name) as StaticBody2D


func test_creates_boundaries_node() -> void:
	assert_not_null(_get_boundaries(), "Should create Boundaries child")


func test_creates_four_walls() -> void:
	var bounds: Node = _get_boundaries()
	assert_eq(bounds.get_child_count(), 4, "Should have 4 wall children")


func test_wall_names() -> void:
	assert_not_null(_get_wall("TopWall"), "TopWall should exist")
	assert_not_null(_get_wall("BottomWall"), "BottomWall should exist")
	assert_not_null(_get_wall("LeftWall"), "LeftWall should exist")
	assert_not_null(_get_wall("RightWall"), "RightWall should exist")


func test_walls_are_static_bodies() -> void:
	for name_str: String in ["TopWall", "BottomWall", "LeftWall", "RightWall"]:
		var wall: Node = _get_boundaries().get_node(name_str)
		assert_true(
			wall is StaticBody2D,
			"%s should be StaticBody2D" % name_str,
		)


func test_walls_have_collision_shapes() -> void:
	for name_str: String in ["TopWall", "BottomWall", "LeftWall", "RightWall"]:
		var wall: StaticBody2D = _get_wall(name_str)
		var shape_node: CollisionShape2D = wall.get_child(0) as CollisionShape2D
		assert_not_null(shape_node, "%s should have CollisionShape2D" % name_str)
		assert_true(
			shape_node.shape is RectangleShape2D,
			"%s shape should be RectangleShape2D" % name_str,
		)


func test_wall_collision_layer() -> void:
	# collision_layer = 2 means Godot physics layer 2 (bitmask 0b10)
	# Player collision_mask = 6 (layers 2+3) detects this
	for name_str: String in ["TopWall", "BottomWall", "LeftWall", "RightWall"]:
		var wall: StaticBody2D = _get_wall(name_str)
		assert_eq(
			wall.collision_layer, 2,
			"%s collision_layer should be 2 (layer 2)" % name_str,
		)


func test_wall_collision_mask_is_zero() -> void:
	for name_str: String in ["TopWall", "BottomWall", "LeftWall", "RightWall"]:
		var wall: StaticBody2D = _get_wall(name_str)
		assert_eq(
			wall.collision_mask, 0,
			"%s collision_mask should be 0" % name_str,
		)


func test_top_wall_position() -> void:
	var wall: StaticBody2D = _get_wall("TopWall")
	assert_eq(wall.position.x, 320.0, "TopWall x = map_width / 2")
	assert_eq(wall.position.y, -16.0, "TopWall y = -16")


func test_bottom_wall_position() -> void:
	var wall: StaticBody2D = _get_wall("BottomWall")
	assert_eq(wall.position.x, 320.0, "BottomWall x = map_width / 2")
	assert_eq(wall.position.y, 400.0, "BottomWall y = map_height + 16")


func test_left_wall_position() -> void:
	var wall: StaticBody2D = _get_wall("LeftWall")
	assert_eq(wall.position.x, -16.0, "LeftWall x = -16")
	assert_eq(wall.position.y, 192.0, "LeftWall y = map_height / 2")


func test_right_wall_position() -> void:
	var wall: StaticBody2D = _get_wall("RightWall")
	assert_eq(wall.position.x, 656.0, "RightWall x = map_width + 16")
	assert_eq(wall.position.y, 192.0, "RightWall y = map_height / 2")


func test_horizontal_wall_shape_size() -> void:
	var wall: StaticBody2D = _get_wall("TopWall")
	var shape: RectangleShape2D = wall.get_child(0).shape
	assert_eq(shape.size.x, 672.0, "Horizontal wall width = map_width + 32")
	assert_eq(shape.size.y, 32.0, "Horizontal wall height = 32")


func test_vertical_wall_shape_size() -> void:
	var wall: StaticBody2D = _get_wall("LeftWall")
	var shape: RectangleShape2D = wall.get_child(0).shape
	assert_eq(shape.size.x, 32.0, "Vertical wall width = 32")
	assert_eq(shape.size.y, 416.0, "Vertical wall height = map_height + 32")

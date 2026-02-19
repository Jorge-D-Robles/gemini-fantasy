extends GutTest

## Tests for ZoneMarker — animated chevron arrow at zone exit triggers.


func test_create_returns_node2d() -> void:
	var marker := ZoneMarker.new()
	assert_not_null(marker)
	assert_is(marker, Node2D)
	marker.free()


func test_default_direction_is_right() -> void:
	var marker := ZoneMarker.new()
	assert_eq(marker.direction, ZoneMarker.Direction.RIGHT)
	marker.free()


func test_default_color_is_gold() -> void:
	var marker := ZoneMarker.new()
	assert_eq(marker.marker_color, ZoneMarker.DEFAULT_COLOR)
	marker.free()


func test_custom_direction() -> void:
	var marker := ZoneMarker.new()
	marker.direction = ZoneMarker.Direction.LEFT
	assert_eq(marker.direction, ZoneMarker.Direction.LEFT)
	marker.free()


func test_custom_color() -> void:
	var marker := ZoneMarker.new()
	var custom := Color(1.0, 0.0, 0.0, 1.0)
	marker.marker_color = custom
	assert_eq(marker.marker_color, custom)
	marker.free()


func test_z_index_is_one_after_ready() -> void:
	var marker := ZoneMarker.new()
	add_child_autofree(marker)
	assert_eq(marker.z_index, 1)


func test_tweens_start_on_ready() -> void:
	var marker := ZoneMarker.new()
	add_child_autofree(marker)
	assert_not_null(marker._alpha_tween)
	assert_not_null(marker._bob_tween)
	assert_true(marker._alpha_tween.is_running())
	assert_true(marker._bob_tween.is_running())


func test_tweens_killed_on_exit_tree() -> void:
	var marker := ZoneMarker.new()
	add_child(marker)
	var alpha_tween: Tween = marker._alpha_tween
	var bob_tween: Tween = marker._bob_tween
	remove_child(marker)
	assert_false(alpha_tween.is_running())
	assert_false(bob_tween.is_running())
	marker.free()


func test_destination_label_created_when_set() -> void:
	var marker := ZoneMarker.new()
	marker.destination_name = "Verdant Forest"
	add_child_autofree(marker)
	var label: Label = marker._destination_label
	assert_not_null(label)
	assert_string_contains(label.text, "Verdant Forest")


func test_no_label_when_destination_empty() -> void:
	var marker := ZoneMarker.new()
	add_child_autofree(marker)
	assert_null(marker._destination_label)


func test_direction_enum_values() -> void:
	assert_eq(ZoneMarker.Direction.LEFT, 0)
	assert_eq(ZoneMarker.Direction.RIGHT, 1)
	assert_eq(ZoneMarker.Direction.UP, 2)
	assert_eq(ZoneMarker.Direction.DOWN, 3)

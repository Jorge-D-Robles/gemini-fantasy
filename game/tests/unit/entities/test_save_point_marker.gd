extends GutTest

## Tests for T-0097: SavePointMarker persistent visual indicator for save points.
## Verifies constants, z_index, and glyph child creation on _ready().

const MarkerScript = preload("res://entities/interactable/save_point_marker.gd")


# -- Constants (no scene tree required) --


func test_glyph_text_constant_is_star() -> void:
	assert_eq(
		MarkerScript.GLYPH_TEXT,
		"★",
		"GLYPH_TEXT must be a star character",
	)


func test_pulse_half_period_is_positive() -> void:
	assert_true(
		MarkerScript.PULSE_HALF_PERIOD > 0.0,
		"PULSE_HALF_PERIOD must be a positive duration",
	)


func test_glyph_offset_y_is_negative() -> void:
	assert_true(
		MarkerScript.GLYPH_OFFSET_Y < 0.0,
		"GLYPH_OFFSET_Y must be negative so the marker appears above the interactable",
	)


# -- Scene-tree tests (add_child_autofree so _ready() runs) --


func test_z_index_is_at_least_one() -> void:
	var inst := MarkerScript.new()
	add_child_autofree(inst)
	assert_true(inst.z_index >= 1, "z_index must be above ground layers")


func test_glyph_child_created_on_ready() -> void:
	var inst := MarkerScript.new()
	add_child_autofree(inst)
	assert_not_null(inst._glyph, "_glyph Label must be created in _ready()")


func test_glyph_is_label() -> void:
	var inst := MarkerScript.new()
	add_child_autofree(inst)
	assert_true(inst._glyph is Label, "_glyph must be a Label node")


func test_glyph_text_is_star() -> void:
	var inst := MarkerScript.new()
	add_child_autofree(inst)
	assert_eq(inst._glyph.text, "★", "Glyph label text must be ★")

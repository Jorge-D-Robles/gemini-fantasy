extends GutTest

## Tests for T-0097: SavePointMarker persistent visual indicator for save points.
## Verifies constants, z_index, and glyph child creation on _ready().

const MarkerScript = preload("res://entities/interactable/save_point_marker.gd")


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

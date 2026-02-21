extends GutTest

## Tests for T-0243: HUD _create_popup_label helper.
## Verifies the helper applies shared label properties to all popup labels.

const HUD := preload("res://ui/hud/hud.gd")


func _make_hud() -> CanvasLayer:
	# Create without add_child to avoid _ready() — @onready vars need the
	# full .tscn tree which unit tests don't have.
	var hud := HUD.new()
	autofree(hud)
	return hud


func test_create_popup_label_returns_label() -> void:
	var hud := _make_hud()
	var label: Label = hud._create_popup_label(12, Color.WHITE, Vector2(0, 0))
	assert_not_null(label, "Should return a non-null Label")
	assert_true(label is Label, "Returned object should be a Label")


func test_create_popup_label_sets_font_size() -> void:
	var hud := _make_hud()
	var label: Label = hud._create_popup_label(20, Color.WHITE, Vector2(0, 0))
	assert_eq(
		label.get_theme_font_size("font_size"),
		20,
		"Font size should match the parameter",
	)


func test_create_popup_label_sets_position() -> void:
	var hud := _make_hud()
	var label: Label = hud._create_popup_label(10, Color.WHITE, Vector2(-150, 40))
	assert_eq(
		label.position,
		Vector2(-150, 40),
		"Position should match the parameter",
	)


func test_create_popup_label_sets_shadow_offsets() -> void:
	var hud := _make_hud()
	var label: Label = hud._create_popup_label(10, Color.RED, Vector2(0, 0))
	assert_eq(
		label.get_theme_constant("shadow_offset_x"),
		1,
		"shadow_offset_x should be 1",
	)
	assert_eq(
		label.get_theme_constant("shadow_offset_y"),
		1,
		"shadow_offset_y should be 1",
	)


func test_create_popup_label_is_added_as_child() -> void:
	var hud := _make_hud()
	var label: Label = hud._create_popup_label(10, Color.WHITE, Vector2(0, 0))
	assert_eq(label.get_parent(), hud, "Label should be a direct child of HUD")

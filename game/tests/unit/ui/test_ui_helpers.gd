extends GutTest

## Tests for UIHelpers — shared UI utility functions.

const UIHelpers = preload("res://ui/ui_helpers.gd")
const UITheme = preload("res://ui/ui_theme.gd")


# ---- clear_children ----

func test_clear_children_removes_all() -> void:
	var parent := Node.new()
	add_child_autofree(parent)
	for i in 3:
		parent.add_child(Label.new())
	assert_eq(parent.get_child_count(), 3, "Precondition: 3 children")
	UIHelpers.clear_children(parent)
	# Children are queue_freed, so they're removed next frame.
	# But remove_child is called immediately.
	assert_eq(parent.get_child_count(), 0, "All children removed")


func test_clear_children_on_empty_parent() -> void:
	var parent := Node.new()
	add_child_autofree(parent)
	UIHelpers.clear_children(parent)
	assert_eq(parent.get_child_count(), 0, "No crash on empty parent")


# ---- setup_focus_wrap ----

func test_focus_wrap_vertical_two_buttons() -> void:
	var container := Control.new()
	add_child_autofree(container)
	var btn_a := Button.new()
	var btn_b := Button.new()
	container.add_child(btn_a)
	container.add_child(btn_b)
	var buttons: Array[Control] = [btn_a, btn_b]
	UIHelpers.setup_focus_wrap(buttons)
	assert_eq(btn_a.focus_neighbor_top, btn_b.get_path())
	assert_eq(btn_a.focus_neighbor_bottom, btn_b.get_path())
	assert_eq(btn_b.focus_neighbor_top, btn_a.get_path())
	assert_eq(btn_b.focus_neighbor_bottom, btn_a.get_path())


func test_focus_wrap_vertical_three_buttons() -> void:
	var container := Control.new()
	add_child_autofree(container)
	var btns: Array[Control] = []
	for i in 3:
		var b := Button.new()
		container.add_child(b)
		btns.append(b)
	UIHelpers.setup_focus_wrap(btns)
	# Middle button points to neighbors
	assert_eq(btns[1].focus_neighbor_top, btns[0].get_path())
	assert_eq(btns[1].focus_neighbor_bottom, btns[2].get_path())
	# Wrap: first top -> last, last bottom -> first
	assert_eq(btns[0].focus_neighbor_top, btns[2].get_path())
	assert_eq(btns[2].focus_neighbor_bottom, btns[0].get_path())


func test_focus_wrap_single_button_no_crash() -> void:
	var container := Control.new()
	add_child_autofree(container)
	var btn := Button.new()
	container.add_child(btn)
	UIHelpers.setup_focus_wrap([btn])
	pass_test("No crash with single button")


func test_focus_wrap_empty_array_no_crash() -> void:
	UIHelpers.setup_focus_wrap([])
	pass_test("No crash with empty array")


func test_focus_wrap_horizontal() -> void:
	var container := Control.new()
	add_child_autofree(container)
	var btn_a := Button.new()
	var btn_b := Button.new()
	container.add_child(btn_a)
	container.add_child(btn_b)
	var buttons: Array[Control] = [btn_a, btn_b]
	UIHelpers.setup_focus_wrap(buttons, true)
	assert_eq(btn_a.focus_neighbor_left, btn_b.get_path())
	assert_eq(btn_a.focus_neighbor_right, btn_b.get_path())
	assert_eq(btn_b.focus_neighbor_left, btn_a.get_path())
	assert_eq(btn_b.focus_neighbor_right, btn_a.get_path())


# ---- create_panel_style ----

func test_create_panel_style_returns_stylebox() -> void:
	var style := UIHelpers.create_panel_style()
	assert_not_null(style)
	assert_true(style is StyleBoxFlat)


func test_create_panel_style_default_colors() -> void:
	var style := UIHelpers.create_panel_style()
	assert_eq(style.bg_color, UITheme.PANEL_BG)
	assert_eq(style.border_color, UITheme.PANEL_BORDER)


func test_create_panel_style_custom_colors() -> void:
	var bg := Color.RED
	var border := Color.BLUE
	var style := UIHelpers.create_panel_style(bg, border)
	assert_eq(style.bg_color, bg)
	assert_eq(style.border_color, border)


func test_create_panel_style_has_border() -> void:
	var style := UIHelpers.create_panel_style()
	assert_gt(style.border_width_top, 0, "Should have border width")


func test_create_panel_style_has_corner_radius() -> void:
	var style := UIHelpers.create_panel_style()
	assert_gt(style.corner_radius_top_left, 0, "Should have corner radius")


# ---- UITheme color constants ----

func test_theme_has_panel_bg() -> void:
	assert_not_null(UITheme.PANEL_BG)
	assert_true(UITheme.PANEL_BG is Color)


func test_theme_has_panel_border() -> void:
	assert_not_null(UITheme.PANEL_BORDER)
	assert_true(UITheme.PANEL_BORDER is Color)


func test_theme_has_text_primary() -> void:
	assert_not_null(UITheme.TEXT_PRIMARY)
	assert_true(UITheme.TEXT_PRIMARY is Color)


func test_theme_has_text_secondary() -> void:
	assert_not_null(UITheme.TEXT_SECONDARY)
	assert_true(UITheme.TEXT_SECONDARY is Color)


func test_theme_has_accent_gold() -> void:
	assert_not_null(UITheme.ACCENT_GOLD)
	assert_true(UITheme.ACCENT_GOLD is Color)


func test_theme_has_hp_bar_color() -> void:
	assert_not_null(UITheme.HP_BAR_COLOR)
	assert_true(UITheme.HP_BAR_COLOR is Color)


func test_theme_has_ee_bar_color() -> void:
	assert_not_null(UITheme.EE_BAR_COLOR)
	assert_true(UITheme.EE_BAR_COLOR is Color)

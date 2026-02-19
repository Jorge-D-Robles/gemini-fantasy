extends GutTest

## Tests for the DamagePopup reusable floating damage number component.

const UITheme = preload("res://ui/ui_theme.gd")

var _popup: DamagePopup


func before_each() -> void:
	_popup = DamagePopup.new()
	add_child_autofree(_popup)


func test_popup_type_enum_values() -> void:
	assert_eq(DamagePopup.PopupType.DAMAGE, 0)
	assert_eq(DamagePopup.PopupType.HEAL, 1)
	assert_eq(DamagePopup.PopupType.CRITICAL, 2)


func test_label_created_in_ready() -> void:
	var label: Label = _popup._label
	assert_not_null(label, "Label child should be created in _ready")


func test_setup_damage_sets_red_color() -> void:
	_popup.setup(42, DamagePopup.PopupType.DAMAGE)
	var color: Color = _popup._label.get_theme_color("font_color")
	assert_eq(color, UITheme.LOG_DAMAGE)


func test_setup_damage_text_is_amount() -> void:
	_popup.setup(150, DamagePopup.PopupType.DAMAGE)
	assert_eq(_popup._label.text, "150")


func test_setup_heal_sets_green_color_and_plus_prefix() -> void:
	_popup.setup(25, DamagePopup.PopupType.HEAL)
	var color: Color = _popup._label.get_theme_color("font_color")
	assert_eq(color, UITheme.LOG_HEAL)
	assert_eq(_popup._label.text, "+25")


func test_setup_critical_sets_gold_color_and_exclamation() -> void:
	_popup.setup(99, DamagePopup.PopupType.CRITICAL)
	var color: Color = _popup._label.get_theme_color("font_color")
	assert_eq(color, UITheme.POPUP_CRITICAL)
	assert_eq(_popup._label.text, "99!")


func test_setup_critical_uses_larger_font() -> void:
	_popup.setup(50, DamagePopup.PopupType.CRITICAL)
	var size: int = _popup._label.get_theme_font_size("font_size")
	assert_eq(size, DamagePopup.CRITICAL_FONT_SIZE)


func test_initial_position_y_offset() -> void:
	_popup.setup(10, DamagePopup.PopupType.DAMAGE)
	assert_eq(_popup.position.y, -20.0)


func test_x_offset_within_range() -> void:
	_popup.setup(10, DamagePopup.PopupType.DAMAGE)
	assert_true(
		_popup.position.x >= -8.0 and _popup.position.x <= 8.0,
		"X offset should be within [-8, 8], got %f" % _popup.position.x,
	)


func test_popup_constants() -> void:
	assert_eq(DamagePopup.POPUP_DURATION, 0.8)
	assert_eq(DamagePopup.FLOAT_DISTANCE, 30.0)
	assert_eq(DamagePopup.FADE_DELAY, 0.3)


func test_base_font_size() -> void:
	_popup.setup(10, DamagePopup.PopupType.DAMAGE)
	var size: int = _popup._label.get_theme_font_size("font_size")
	assert_eq(size, DamagePopup.BASE_FONT_SIZE)

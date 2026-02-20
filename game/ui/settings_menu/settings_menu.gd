extends Control

## Settings menu with volume sliders for Master, BGM, and SFX buses.
## Script-only Control (no .tscn). Opened from title screen or pause menu.

signal settings_menu_closed

const UIHelpers = preload("res://ui/ui_helpers.gd")
const UITheme = preload("res://ui/ui_theme.gd")
const SD = preload("res://ui/settings_menu/settings_data.gd")

var _master_slider: HSlider
var _bgm_slider: HSlider
var _sfx_slider: HSlider
var _master_value_label: Label
var _bgm_value_label: Label
var _sfx_value_label: Label
var _close_button: Button
var _master_reset_btn: Button
var _bgm_reset_btn: Button
var _sfx_reset_btn: Button


func _ready() -> void:
	_build_ui()
	_load_current_values()
	_setup_focus()
	_master_slider.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_MENU_OPEN))
	visible = true
	_load_current_values()
	_master_slider.grab_focus()


func close() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	_save_current_values()
	visible = false
	settings_menu_closed.emit()


func _load_current_values() -> void:
	var s := SD.load_settings()
	_master_slider.value = s["master_volume"]
	_bgm_slider.value = s["bgm_volume"]
	_sfx_slider.value = s["sfx_volume"]
	_master_value_label.text = str(s["master_volume"])
	_bgm_value_label.text = str(s["bgm_volume"])
	_sfx_value_label.text = str(s["sfx_volume"])


func _save_current_values() -> void:
	SD.save_settings(
		int(_master_slider.value),
		int(_bgm_slider.value),
		int(_sfx_slider.value),
	)


func _on_master_changed(value: float) -> void:
	var pct := int(value)
	_master_value_label.text = str(pct)
	SD.apply_volume("Master", pct)


func _on_bgm_changed(value: float) -> void:
	var pct := int(value)
	_bgm_value_label.text = str(pct)
	SD.apply_volume("BGM", pct)


func _on_sfx_changed(value: float) -> void:
	var pct := int(value)
	_sfx_value_label.text = str(pct)
	SD.apply_volume("SFX", pct)


func _build_ui() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = UITheme.DIM_COLOR
	dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 380)
	panel.add_theme_stylebox_override(
		"panel", UIHelpers.create_panel_style()
	)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Settings"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override(
		"font_color", UITheme.TEXT_GOLD
	)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var volume_section := VBoxContainer.new()
	volume_section.add_theme_constant_override("separation", 6)
	vbox.add_child(volume_section)

	var master_row := _create_slider_row("Master", "master")
	_master_slider = master_row["slider"]
	_master_value_label = master_row["value_label"]
	_master_reset_btn = master_row["reset_btn"]
	_master_slider.value_changed.connect(_on_master_changed)
	_master_reset_btn.pressed.connect(_on_master_reset)
	volume_section.add_child(master_row["container"])

	var bgm_row := _create_slider_row("Music", "bgm")
	_bgm_slider = bgm_row["slider"]
	_bgm_value_label = bgm_row["value_label"]
	_bgm_reset_btn = bgm_row["reset_btn"]
	_bgm_slider.value_changed.connect(_on_bgm_changed)
	_bgm_reset_btn.pressed.connect(_on_bgm_reset)
	volume_section.add_child(bgm_row["container"])

	var sfx_row := _create_slider_row("Sound", "sfx")
	_sfx_slider = sfx_row["slider"]
	_sfx_value_label = sfx_row["value_label"]
	_sfx_reset_btn = sfx_row["reset_btn"]
	_sfx_slider.value_changed.connect(_on_sfx_changed)
	_sfx_reset_btn.pressed.connect(_on_sfx_reset)
	volume_section.add_child(sfx_row["container"])

	var hint := Label.new()
	hint.text = "← → keys: adjust slider  |  ↑ ↓: switch slider"
	hint.add_theme_font_size_override("font_size", 8)
	hint.add_theme_color_override(
		"font_color", UITheme.TEXT_SECONDARY
	)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

	vbox.add_child(HSeparator.new())

	var controls_title := Label.new()
	controls_title.text = "Controls"
	controls_title.add_theme_font_size_override("font_size", 13)
	controls_title.add_theme_color_override(
		"font_color", UITheme.TEXT_GOLD
	)
	controls_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(controls_title)

	var bindings := SD.compute_control_bindings()
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 2)
	vbox.add_child(grid)

	for entry: Dictionary in bindings:
		var action_label := Label.new()
		action_label.text = entry["label"] as String
		action_label.add_theme_font_size_override("font_size", 9)
		action_label.add_theme_color_override(
			"font_color", UITheme.TEXT_SECONDARY
		)
		action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(action_label)

		var key_label := Label.new()
		key_label.text = entry["key"] as String
		key_label.add_theme_font_size_override("font_size", 9)
		key_label.add_theme_color_override(
			"font_color", UITheme.TEXT_PRIMARY
		)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		grid.add_child(key_label)

	vbox.add_child(HSeparator.new())

	_close_button = Button.new()
	_close_button.text = "Close"
	_close_button.add_theme_font_size_override("font_size", 12)
	_close_button.pressed.connect(close)
	_apply_button_style(_close_button)
	vbox.add_child(_close_button)


func _create_slider_row(
	label_text: String, slider_id: String
) -> Dictionary:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 1)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 52
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override(
		"font_color", UITheme.TEXT_PRIMARY
	)
	hbox.add_child(label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = 100.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size.x = 120
	slider.focus_mode = Control.FOCUS_ALL
	hbox.add_child(slider)

	var value_label := Label.new()
	value_label.text = "100"
	value_label.custom_minimum_size.x = 28
	value_label.add_theme_font_size_override("font_size", 10)
	value_label.add_theme_color_override(
		"font_color", UITheme.TEXT_SECONDARY
	)
	value_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_RIGHT
	)
	hbox.add_child(value_label)

	var reset_btn := Button.new()
	reset_btn.text = "↺"
	reset_btn.custom_minimum_size = Vector2(22, 0)
	reset_btn.add_theme_font_size_override("font_size", 10)
	reset_btn.focus_mode = Control.FOCUS_NONE
	reset_btn.tooltip_text = "Reset to default"
	hbox.add_child(reset_btn)

	var tooltip := Label.new()
	tooltip.text = SD.compute_slider_tooltip(slider_id)
	tooltip.add_theme_font_size_override("font_size", 8)
	tooltip.add_theme_color_override(
		"font_color", UITheme.TEXT_SECONDARY
	)
	vbox.add_child(tooltip)

	return {
		"container": vbox,
		"slider": slider,
		"value_label": value_label,
		"reset_btn": reset_btn,
	}


func _setup_focus() -> void:
	UIHelpers.setup_focus_wrap([
		_master_slider,
		_bgm_slider,
		_sfx_slider,
		_close_button,
	])


func _on_master_reset() -> void:
	_master_slider.value = SD.DEFAULT_VOLUME
	SD.apply_volume("Master", SD.DEFAULT_VOLUME)


func _on_bgm_reset() -> void:
	_bgm_slider.value = SD.DEFAULT_VOLUME
	SD.apply_volume("BGM", SD.DEFAULT_VOLUME)


func _on_sfx_reset() -> void:
	_sfx_slider.value = SD.DEFAULT_VOLUME
	SD.apply_volume("SFX", SD.DEFAULT_VOLUME)


func _apply_button_style(btn: Button) -> void:
	var normal := UIHelpers.create_panel_style(
		UITheme.PANEL_BG, UITheme.PANEL_BORDER, 1, 2
	)
	var hover := UIHelpers.create_panel_style(
		UITheme.PANEL_HOVER, UITheme.ACCENT_GOLD, 1, 2
	)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override(
		"focus", hover.duplicate() as StyleBoxFlat
	)
	btn.add_theme_stylebox_override(
		"pressed", hover.duplicate() as StyleBoxFlat
	)
	btn.add_theme_color_override(
		"font_color", UITheme.TEXT_PRIMARY
	)
	btn.add_theme_color_override(
		"font_hover_color", UITheme.TEXT_GOLD
	)
	btn.add_theme_color_override(
		"font_focus_color", UITheme.TEXT_GOLD
	)

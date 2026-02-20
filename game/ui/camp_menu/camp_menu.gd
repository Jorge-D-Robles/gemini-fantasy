extends Control

## Camp menu UI for campfire rest points.
## Script-only Control — no .tscn required.
## Opened via CampStrategy when player interacts with a campfire.

signal rest_chosen
signal camp_menu_closed

const UIHelpers = preload("res://ui/ui_helpers.gd")
const UITheme = preload("res://ui/ui_theme.gd")
const CampMenuData = preload("res://ui/camp_menu/camp_menu_data.gd")

var _rest_button: Button
var _leave_button: Button
var _status_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	visible = true
	GameManager.push_state(GameManager.GameState.MENU)
	if _rest_button:
		_rest_button.grab_focus()


func close() -> void:
	visible = false
	GameManager.pop_state()
	camp_menu_closed.emit()


func _on_rest_pressed() -> void:
	var party := PartyManager.get_active_party()
	var entries: Array[Dictionary] = []
	for member in party:
		if not member:
			continue
		var member_id: StringName = member.id if "id" in member else &""
		if member_id == &"":
			continue
		var state := PartyManager.get_runtime_state(member_id)
		if not state.is_empty():
			entries.append({
				"current_hp": state.get("current_hp", 0),
				"max_hp": member.max_hp if "max_hp" in member else 1,
				"current_ee": state.get("current_ee", 0),
				"max_ee": member.max_ee if "max_ee" in member else 0,
			})

	var healing_needed := CampMenuData.compute_healing_needed(entries)
	PartyManager.heal_all()
	rest_chosen.emit()

	if _status_label:
		_status_label.text = CampMenuData.compute_rest_message(healing_needed)

	if _rest_button:
		_rest_button.disabled = true
	if _leave_button:
		_leave_button.grab_focus()


func _on_leave_pressed() -> void:
	close()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = UITheme.DIM_COLOR
	dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(PRESET_CENTER)
	panel.custom_minimum_size = Vector2(240, 180)
	panel.add_theme_stylebox_override("panel", UIHelpers.create_panel_style())
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	var title := Label.new()
	title.text = "Campfire"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	_status_label = Label.new()
	_status_label.text = "Make camp and rest here."
	_status_label.add_theme_font_size_override("font_size", 10)
	_status_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_status_label)

	vbox.add_child(HSeparator.new())

	_rest_button = _create_button("Rest")
	_rest_button.pressed.connect(_on_rest_pressed)
	vbox.add_child(_rest_button)

	_leave_button = _create_button("Leave Camp")
	_leave_button.pressed.connect(_on_leave_pressed)
	vbox.add_child(_leave_button)

	UIHelpers.setup_focus_wrap([_rest_button, _leave_button])


func _create_button(label_text: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.add_theme_font_size_override("font_size", 13)
	var normal_style := UIHelpers.create_panel_style()
	var hover_style := UIHelpers.create_panel_style(
		UITheme.PANEL_HOVER, UITheme.ACCENT_GOLD, 1,
	)
	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("focus", hover_style)
	btn.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	btn.add_theme_color_override("font_hover_color", UITheme.TEXT_GOLD)
	btn.add_theme_color_override("font_focus_color", UITheme.TEXT_GOLD)
	return btn

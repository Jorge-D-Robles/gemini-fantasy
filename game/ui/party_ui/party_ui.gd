extends Control

## Party management sub-screen opened from the pause menu.
## Shows active party (left) and reserve members (right).
## Selecting an active member then a reserve member executes a swap.
## Script-only — no .tscn file. Layout built programmatically in open().

signal party_ui_closed

const UIHelpers = preload("res://ui/ui_helpers.gd")
const UITheme = preload("res://ui/ui_theme.gd")
const PartyUIData = preload("res://ui/party_ui/party_ui_data.gd")

const _FONT_TITLE: int = 18
const _FONT_HEADING: int = 12
const _FONT_MEMBER: int = 10
const _FONT_HINT: int = 9
const _FONT_BACK: int = 12

var _pm: Node = null
var _em: Node = null
var _selected_active_index: int = -1
var _active_buttons: Array[Button] = []
var _reserve_buttons: Array[Button] = []
var _back_button: Button = null
var _detail_panel: PanelContainer = null
var _detail_content: VBoxContainer = null
var _status_label: Label = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_pm = get_node_or_null("/root/PartyManager")
	_em = get_node_or_null("/root/EquipmentManager")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	_build_ui()
	visible = true
	AudioManager.play_sfx(load(SfxLibrary.UI_MENU_OPEN))
	if not _active_buttons.is_empty():
		_active_buttons[0].grab_focus()
	elif _back_button != null:
		_back_button.grab_focus()


func close() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	visible = false
	party_ui_closed.emit()


func _build_ui() -> void:
	UIHelpers.clear_children(self)
	_active_buttons.clear()
	_reserve_buttons.clear()
	_selected_active_index = -1
	_back_button = null

	# Dim overlay
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.03, 0.1, 0.92)
	bg.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	add_child(bg)

	# Centered panel
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(PRESET_CENTER)
	panel.custom_minimum_size = Vector2(500, 340)
	panel.offset_left = -250.0
	panel.offset_right = 250.0
	panel.offset_top = -170.0
	panel.offset_bottom = 170.0
	panel.add_theme_stylebox_override("panel", UIHelpers.create_panel_style())
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 8)
	margin.add_child(root_vbox)

	# Title
	var title := Label.new()
	title.text = "Party"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", _FONT_TITLE)
	title.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	root_vbox.add_child(title)

	# Hint
	var hint := Label.new()
	hint.text = "Select active member, then reserve member to swap."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", _FONT_HINT)
	hint.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	root_vbox.add_child(hint)

	var sep := HSeparator.new()
	root_vbox.add_child(sep)

	# Transient error feedback label (hidden until an invalid swap is attempted)
	_status_label = Label.new()
	_status_label.add_theme_font_size_override("font_size", _FONT_HINT)
	_status_label.add_theme_color_override(
		"font_color", UITheme.TEXT_NEGATIVE,
	)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.visible = false
	root_vbox.add_child(_status_label)

	# Two-column layout
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 16)
	root_vbox.add_child(columns)

	var active_col := _build_column_header("Active Party", columns)
	var reserve_col := _build_column_header("Reserve", columns)

	# Gather data
	var active_list: Array[Resource] = \
		_pm.get_active_party() if _pm != null else []
	var reserve_list: Array[Resource] = []
	if _pm != null:
		for m: Resource in _pm.get_roster():
			if not _pm.is_in_party(m):
				reserve_list.append(m)

	var sections: Dictionary = PartyUIData.compute_panel_sections(
		active_list, reserve_list, _pm
	)

	# Active column buttons
	for i: int in sections["active"].size():
		var entry: Dictionary = sections["active"][i]
		var btn := _create_member_button(entry)
		btn.pressed.connect(_on_active_pressed.bind(i))
		active_col.add_child(btn)
		_active_buttons.append(btn)

	if active_list.is_empty():
		var empty := Label.new()
		empty.text = "No active members"
		empty.add_theme_font_size_override("font_size", _FONT_MEMBER)
		empty.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
		active_col.add_child(empty)

	# Reserve column buttons
	if sections["has_reserve"]:
		for i: int in sections["reserve"].size():
			var entry: Dictionary = sections["reserve"][i]
			var btn := _create_member_button(entry)
			btn.pressed.connect(_on_reserve_pressed.bind(i))
			reserve_col.add_child(btn)
			_reserve_buttons.append(btn)
	else:
		var empty := Label.new()
		empty.text = "None"
		empty.add_theme_font_size_override("font_size", _FONT_MEMBER)
		empty.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
		reserve_col.add_child(empty)

	# Detail panel (shown when any member is clicked)
	var detail_sep := HSeparator.new()
	root_vbox.add_child(detail_sep)

	_detail_panel = PanelContainer.new()
	_detail_panel.add_theme_stylebox_override(
		"panel", UIHelpers.create_panel_style(UITheme.PANEL_INNER_BG)
	)
	_detail_panel.visible = false
	root_vbox.add_child(_detail_panel)

	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 8)
	detail_margin.add_theme_constant_override("margin_top", 4)
	detail_margin.add_theme_constant_override("margin_right", 8)
	detail_margin.add_theme_constant_override("margin_bottom", 4)
	_detail_panel.add_child(detail_margin)

	_detail_content = VBoxContainer.new()
	_detail_content.add_theme_constant_override("separation", 2)
	detail_margin.add_child(_detail_content)

	# Back button
	var back_row := HBoxContainer.new()
	back_row.alignment = BoxContainer.ALIGNMENT_CENTER
	root_vbox.add_child(back_row)

	_back_button = Button.new()
	_back_button.text = "Back"
	_back_button.add_theme_font_size_override("font_size", _FONT_BACK)
	_back_button.pressed.connect(close)
	back_row.add_child(_back_button)

	_setup_focus()


func _build_column_header(heading: String, parent: Control) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", 4)
	parent.add_child(col)

	var lbl := Label.new()
	lbl.text = heading
	lbl.add_theme_font_size_override("font_size", _FONT_HEADING)
	lbl.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	col.add_child(lbl)

	return col


func _create_member_button(entry: Dictionary) -> Button:
	var btn := Button.new()
	var hp_str: String = "%d/%d" % [entry["current_hp"], entry["max_hp"]]
	var stats_str: String = "ATK:%d MAG:%d DEF:%d SPD:%d" % [
		entry["attack"], entry["magic"], entry["defense"], entry["speed"]
	]
	btn.text = "%s  Lv.%d\nHP %s\n%s" % [
		entry["name"], entry["level"], hp_str, stats_str
	]
	btn.add_theme_font_size_override("font_size", _FONT_MEMBER)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return btn


func _on_active_pressed(index: int) -> void:
	_selected_active_index = index
	_refresh_button_highlights()
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
	if _pm == null:
		return
	var active_list: Array[Resource] = _pm.get_active_party()
	if index < active_list.size():
		_show_member_detail(active_list[index])


func _on_reserve_pressed(reserve_index: int) -> void:
	# Show detail for the reserve member regardless of swap selection.
	if _pm != null:
		var reserve_list: Array[Resource] = []
		for m: Resource in _pm.get_roster():
			if not _pm.is_in_party(m):
				reserve_list.append(m)
		if reserve_index < reserve_list.size():
			_show_member_detail(reserve_list[reserve_index])
	# Only swap if an active member is already selected.
	if _selected_active_index < 0 or _pm == null:
		AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
		return
	if not PartyUIData.compute_swap_valid(
		_selected_active_index,
		reserve_index,
		_active_buttons.size(),
		_reserve_buttons.size(),
	):
		_show_swap_error(
			PartyUIData.compute_swap_feedback_text(
				_selected_active_index,
				_active_buttons.size(),
				_reserve_buttons.size(),
			)
		)
		return
	_pm.swap_members(_selected_active_index, reserve_index)
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
	_build_ui()
	if not _active_buttons.is_empty():
		_active_buttons[0].grab_focus()


func _show_swap_error(msg: String) -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	# Flash the selected active button red for 0.3 s total.
	if _selected_active_index >= 0 and (
		_selected_active_index < _active_buttons.size()
	):
		var btn := _active_buttons[_selected_active_index]
		var tween := create_tween()
		tween.tween_property(btn, "modulate", Color(1.0, 0.3, 0.3), 0.05)
		# Return to the selection-highlight color (yellow) rather than white.
		tween.tween_property(btn, "modulate", Color(1.0, 1.0, 0.5), 0.25)
	# Show transient status label, then fade it out.
	if _status_label == null:
		return
	_status_label.modulate.a = 1.0
	_status_label.text = msg
	_status_label.visible = true
	var label_tween := create_tween()
	label_tween.tween_interval(1.2)
	label_tween.tween_property(_status_label, "modulate:a", 0.0, 0.3)
	label_tween.tween_callback(
		func() -> void:
			if is_instance_valid(_status_label):
				_status_label.visible = false
				_status_label.modulate.a = 1.0
	)


func _show_member_detail(member: Resource) -> void:
	if _detail_panel == null or _detail_content == null:
		return
	UIHelpers.clear_children(_detail_content)
	_detail_panel.visible = true

	var id: StringName = member.id if "id" in member else &""
	var equip_slots: Dictionary = PartyUIData.compute_equipment_slots(id, _em)

	# Header row: name + level
	var header := Label.new()
	var lvl: int = member.level if "level" in member else 1
	header.text = "%s  — Lv.%d" % [
		member.display_name if "display_name" in member else "???", lvl
	]
	header.add_theme_font_size_override("font_size", _FONT_MEMBER + 1)
	header.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	_detail_content.add_child(header)

	# Stats row
	var cur_hp: int = member.max_hp if "max_hp" in member else 0
	var max_hp: int = cur_hp
	if _pm != null and id != &"":
		cur_hp = _pm.get_hp(id) if _pm.has_method("get_hp") else max_hp
	var stats_lbl := Label.new()
	stats_lbl.text = (
		"HP %d/%d  ATK:%d  MAG:%d  DEF:%d  RES:%d  SPD:%d" % [
			cur_hp,
			max_hp,
			member.attack if "attack" in member else 0,
			member.magic if "magic" in member else 0,
			member.defense if "defense" in member else 0,
			member.resistance if "resistance" in member else 0,
			member.speed if "speed" in member else 0,
		]
	)
	stats_lbl.add_theme_font_size_override("font_size", _FONT_HINT)
	stats_lbl.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	_detail_content.add_child(stats_lbl)

	# Equipment row
	var equip_lbl := Label.new()
	equip_lbl.text = (
		"WPN:%s  HLM:%s  CHT:%s  ACC:%s/%s" % [
			equip_slots["weapon"],
			equip_slots["helmet"],
			equip_slots["chest"],
			equip_slots["accessory_0"],
			equip_slots["accessory_1"],
		]
	)
	equip_lbl.add_theme_font_size_override("font_size", _FONT_HINT)
	equip_lbl.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	_detail_content.add_child(equip_lbl)


func _refresh_button_highlights() -> void:
	for i: int in _active_buttons.size():
		if i == _selected_active_index:
			_active_buttons[i].modulate = Color(1.0, 1.0, 0.5)
		else:
			_active_buttons[i].modulate = Color(1.0, 1.0, 1.0)


func _setup_focus() -> void:
	# Vertical wrap within each column independently.
	if _active_buttons.size() > 1:
		UIHelpers.setup_focus_wrap(_active_buttons)
	if _reserve_buttons.size() > 1:
		UIHelpers.setup_focus_wrap(_reserve_buttons)

	# Cross-column horizontal navigation: left/right arrows switch columns.
	for i: int in _active_buttons.size():
		var ri: int = PartyUIData.compute_cross_column_focus_index(
			i, _active_buttons.size(), _reserve_buttons.size()
		)
		if ri >= 0:
			_active_buttons[i].focus_neighbor_right = _reserve_buttons[ri].get_path()
	for i: int in _reserve_buttons.size():
		var ai: int = PartyUIData.compute_cross_column_focus_index(
			i, _reserve_buttons.size(), _active_buttons.size()
		)
		if ai >= 0:
			_reserve_buttons[i].focus_neighbor_left = _active_buttons[ai].get_path()

	# Back button connects downward from the bottom of each column.
	if _back_button != null:
		if not _active_buttons.is_empty():
			_active_buttons[-1].focus_neighbor_bottom = _back_button.get_path()
		if not _reserve_buttons.is_empty():
			_reserve_buttons[-1].focus_neighbor_bottom = _back_button.get_path()
		if not _active_buttons.is_empty():
			_back_button.focus_neighbor_top = _active_buttons[-1].get_path()
		elif not _reserve_buttons.is_empty():
			_back_button.focus_neighbor_top = _reserve_buttons[-1].get_path()

	# Ensure at least the first button has focus.
	if not _active_buttons.is_empty():
		return  # grab_focus() already called by open()
	if not _reserve_buttons.is_empty():
		return
	if _back_button != null:
		return

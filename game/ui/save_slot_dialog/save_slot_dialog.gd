extends Control

## Reusable save slot picker dialog. Used by pause menu (save mode)
## and title screen (load mode). Script-only — no .tscn required.

signal slot_selected(slot: int)
signal dialog_closed

enum Mode { SAVE, LOAD }

const UITheme = preload("res://ui/ui_theme.gd")
const UIHelpers = preload("res://ui/ui_helpers.gd")

var _mode: Mode = Mode.SAVE
var _include_autosave: bool = false
var _panel: PanelContainer
var _slot_buttons: Array[Button] = []


func open(mode: Mode, include_autosave: bool = false) -> void:
	_mode = mode
	_include_autosave = include_autosave
	_build_ui()
	visible = true
	if not _slot_buttons.is_empty():
		_slot_buttons[0].grab_focus()


func close() -> void:
	visible = false
	dialog_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("cancel"):
		AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
		close()
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	UIHelpers.clear_children(self)
	_slot_buttons.clear()

	# Full-screen semi-transparent backdrop
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.5)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	# Center panel
	_panel = PanelContainer.new()
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.custom_minimum_size = Vector2(200, 0)
	_panel.position = Vector2(-100, -80)
	var style := StyleBoxFlat.new()
	style.bg_color = UITheme.PANEL_BG
	style.border_color = UITheme.PANEL_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "Save Game" if _mode == Mode.SAVE else "Load Game"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Slot buttons
	var summaries: Array[Dictionary] = SaveManager.get_all_slot_summaries()
	var entries: Array[Dictionary] = compute_slot_entries(
		summaries, _include_autosave,
	)

	for entry in entries:
		var btn := _create_slot_button(entry)
		vbox.add_child(btn)
		_slot_buttons.append(btn)

	# Cancel hint
	var hint := Label.new()
	hint.text = "Press Cancel to go back"
	hint.add_theme_font_size_override("font_size", 8)
	hint.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

	if not _slot_buttons.is_empty():
		UIHelpers.setup_focus_wrap(_slot_buttons)


func _create_slot_button(entry: Dictionary) -> Button:
	var btn := Button.new()
	var slot_num: int = entry["slot"]
	var label: String = entry["label"]
	if entry["empty"]:
		btn.text = "%s — Empty" % label
	else:
		var parts: Array[String] = [label]
		if not entry["location"].is_empty():
			parts.append(entry["location"])
		if not entry["playtime"].is_empty():
			parts.append(entry["playtime"])
		btn.text = " — ".join(parts)

	# Disable empty slots in load mode
	if _mode == Mode.LOAD and entry["empty"]:
		btn.disabled = true

	btn.add_theme_font_size_override("font_size", 10)

	# Apply button styling
	var normal := StyleBoxFlat.new()
	normal.bg_color = UITheme.PANEL_BG
	normal.border_color = UITheme.PANEL_BORDER
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	normal.set_content_margin_all(4)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = UITheme.PANEL_HOVER
	hover.border_color = UITheme.ACCENT_GOLD
	hover.set_border_width_all(1)
	hover.set_corner_radius_all(3)
	hover.set_content_margin_all(4)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("focus", hover)

	btn.pressed.connect(_on_slot_pressed.bind(slot_num))
	return btn


func _on_slot_pressed(slot: int) -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
	slot_selected.emit(slot)


## Returns display data for each slot. Pure static helper for testability.
## summaries: Array of 4 dictionaries from SaveManager.get_all_slot_summaries()
## include_autosave: if true, include slot 0 (load mode); if false, slots 1-3 only
static func compute_slot_entries(
	summaries: Array[Dictionary],
	include_autosave: bool,
) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var start_slot: int = 0 if include_autosave else 1
	for i in range(start_slot, summaries.size()):
		var s: Dictionary = summaries[i]
		var label: String = "Autosave" if i == 0 else "Slot %d" % i
		entries.append({
			"slot": i,
			"label": label,
			"empty": s.get("empty", true),
			"location": s.get("location", ""),
			"playtime": s.get("playtime_str", ""),
			"time": s.get("time_str", ""),
		})
	return entries

extends Control

## Fast travel destination picker. Script-only — no .tscn required.
## Opens from the pause menu. Shows unlocked Resonance Beacons as
## selectable buttons. Selecting a destination emits destination_selected;
## the pause menu handles closing itself and triggering the scene change.

signal destination_selected(scene_path: String, spawn_point: String)
signal fast_travel_closed

const UITheme = preload("res://ui/ui_theme.gd")
const UIHelpers = preload("res://ui/ui_helpers.gd")
const SP = preload("res://systems/scene_paths.gd")
const EFR = preload("res://events/event_flag_registry.gd")

const BEACONS: Array[Dictionary] = [
	{
		"id": "roothollow",
		"name": "Roothollow",
		"scene": SP.ROOTHOLLOW,
		"spawn": "spawn_from_forest",
		"flag": EFR.FAST_TRAVEL_ROOTHOLLOW,
	},
	{
		"id": "verdant_forest",
		"name": "Verdant Forest",
		"scene": SP.VERDANT_FOREST,
		"spawn": "spawn_from_town",
		"flag": EFR.FAST_TRAVEL_VERDANT_FOREST,
	},
	{
		"id": "overgrown_ruins",
		"name": "Overgrown Ruins",
		"scene": SP.OVERGROWN_RUINS,
		"spawn": "spawn_from_forest",
		"flag": EFR.FAST_TRAVEL_OVERGROWN_RUINS,
	},
	{
		"id": "prismfall_approach",
		"name": "Prismfall Approach",
		"scene": SP.PRISMFALL_APPROACH,
		"spawn": "spawn_from_forest",
		"flag": EFR.FAST_TRAVEL_PRISMFALL_APPROACH,
	},
]

var _beacon_buttons: Array[Button] = []


func open() -> void:
	_build_ui()
	visible = true
	if not _beacon_buttons.is_empty():
		_beacon_buttons[0].grab_focus()


func close() -> void:
	visible = false
	fast_travel_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("cancel"):
		AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
		close()
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	UIHelpers.clear_children(self)
	_beacon_buttons.clear()

	# Full-screen backdrop
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.0, 0.0, 0.5)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	# Center panel
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(220, 0)
	panel.position = Vector2(-110, -80)
	var style := StyleBoxFlat.new()
	style.bg_color = UITheme.PANEL_BG
	style.border_color = UITheme.PANEL_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.set_content_margin_all(8)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "Fast Travel"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# Beacon entries
	var scene := get_tree().current_scene
	var current_path: String = scene.scene_file_path if scene else ""
	var flags: Dictionary = EventFlags.get_all_flags()
	var entries: Array[Dictionary] = compute_beacon_entries(
		flags, current_path,
	)

	if entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No beacons discovered."
		empty_label.add_theme_font_size_override("font_size", 10)
		empty_label.add_theme_color_override(
			"font_color", UITheme.TEXT_SECONDARY,
		)
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(empty_label)
	else:
		for entry in entries:
			var btn := _create_beacon_button(entry)
			vbox.add_child(btn)
			_beacon_buttons.append(btn)

	# Cancel hint
	var hint := Label.new()
	hint.text = "Press Cancel to go back"
	hint.add_theme_font_size_override("font_size", 8)
	hint.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)

	if not _beacon_buttons.is_empty():
		UIHelpers.setup_focus_wrap(_beacon_buttons)


func _create_beacon_button(entry: Dictionary) -> Button:
	var btn := Button.new()
	btn.text = entry["name"]
	btn.add_theme_font_size_override("font_size", 11)

	if entry["is_current"]:
		btn.disabled = true
		btn.text += " (here)"

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

	var scene_path: String = entry["scene"]
	var spawn: String = entry["spawn"]
	btn.pressed.connect(
		_on_beacon_pressed.bind(scene_path, spawn),
	)
	return btn


func _on_beacon_pressed(
	scene_path: String, spawn_point: String,
) -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
	destination_selected.emit(scene_path, spawn_point)


## Returns display data for unlocked beacons. Pure static helper.
## Beacons whose flag is not in flags are excluded.
## The beacon for current_scene is included but marked is_current=true.
static func compute_beacon_entries(
	flags: Dictionary, current_scene: String,
) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for beacon in BEACONS:
		var flag: String = beacon["flag"]
		if not flags.get(flag, false):
			continue
		entries.append({
			"id": beacon["id"],
			"name": beacon["name"],
			"scene": beacon["scene"],
			"spawn": beacon["spawn"],
			"is_current": beacon["scene"] == current_scene,
		})
	return entries

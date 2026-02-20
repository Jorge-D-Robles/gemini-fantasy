class_name EchoJournal
extends Control

## Echo Collection Journal UI — accessible from the pause menu.
## Shows collected Echo Fragments with rarity badge, type, lore, and Kael's notes.
## Script-only (no .tscn) — layout built programmatically.

signal echo_journal_closed

const UITheme = preload("res://ui/ui_theme.gd")
const UIHelpers = preload("res://ui/ui_helpers.gd")

const ECHO_DATA_DIR: String = "res://data/echoes/"
const ECHO_TOTAL: int = 42

const RARITY_NAMES: Dictionary = {
	0: "Common",
	1: "Uncommon",
	2: "Rare",
	3: "Legendary",
	4: "Unique",
}

const RARITY_COLORS: Dictionary = {
	0: Color(0.7, 0.7, 0.7),
	1: Color(0.4, 0.9, 0.4),
	2: Color(0.4, 0.6, 1.0),
	3: Color(0.9, 0.6, 0.1),
	4: Color(0.9, 0.3, 0.9),
}

const ECHO_TYPE_NAMES: Dictionary = {
	0: "Attack",
	1: "Support",
	2: "Debuff",
	3: "Unique",
}

const _PANEL_WIDTH: int = 520
const _PANEL_HEIGHT: int = 300
const _LIST_WIDTH: int = 160
const _FONT_SIZE_TITLE: int = 16
const _FONT_SIZE_BUTTON: int = 11
const _FONT_SIZE_DETAIL: int = 10
const _FONT_SIZE_SMALL: int = 9

var _selected_echo_id: StringName = &""

var _main_panel: PanelContainer
var _echo_list: VBoxContainer
var _echo_list_scroll: ScrollContainer
var _detail_vbox: VBoxContainer
var _echo_name_label: Label
var _rarity_label: Label
var _type_label: Label
var _lore_label: Label
var _notes_label: Label
var _empty_label: Label
var _content_hbox: HBoxContainer
var _count_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	_build_layout()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cancel"):
		close()
		get_viewport().set_input_as_handled()


func open() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_MENU_OPEN))
	visible = true
	_selected_echo_id = &""
	_refresh()


func close() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	visible = false
	echo_journal_closed.emit()


## Returns an Array[Dictionary] of collected echo entries from echo_mgr.
## Each entry: {id, display_name, rarity, echo_type, lore_text, kael_notes}
## echo_catalog is Array[Resource] of EchoData — if empty, loaded from disk.
static func compute_echo_list(
	echo_mgr: Node,
	echo_catalog: Array,
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var collected: Array[StringName] = echo_mgr.get_collected_echoes()
	for id: StringName in collected:
		var data: Resource = _find_echo_data(id, echo_catalog)
		if data == null:
			result.append({
				"id": id,
				"display_name": String(id),
				"rarity": 0,
				"echo_type": 0,
				"lore_text": "",
				"kael_notes": "",
			})
		else:
			result.append({
				"id": id,
				"display_name": data.get("display_name") if "display_name" in data else String(id),
				"rarity": int(data.get("rarity")) if "rarity" in data else 0,
				"echo_type": int(data.get("echo_type")) if "echo_type" in data else 0,
				"lore_text": data.get("lore_text") if "lore_text" in data else "",
				"kael_notes": data.get("description") if "description" in data else "",
			})
	return result


## Returns detail Dictionary for a single echo id. Returns {} if id not found.
static func compute_echo_detail(
	echo_id: StringName,
	echo_catalog: Array,
) -> Dictionary:
	if echo_id == &"":
		return {}
	var data: Resource = _find_echo_data(echo_id, echo_catalog)
	if data == null:
		return {}
	return {
		"id": echo_id,
		"display_name": data.get("display_name") if "display_name" in data else String(echo_id),
		"rarity": int(data.get("rarity")) if "rarity" in data else 0,
		"echo_type": int(data.get("echo_type")) if "echo_type" in data else 0,
		"lore_text": data.get("lore_text") if "lore_text" in data else "",
		"kael_notes": data.get("description") if "description" in data else "",
	}


## Returns "Echoes: X / total" collection count label text.
static func compute_echo_count_label(count: int, total: int) -> String:
	return "Echoes: %d / %d" % [count, total]


static func _find_echo_data(
	echo_id: StringName,
	catalog: Array,
) -> Resource:
	for item: Resource in catalog:
		if "id" in item and item.id == echo_id:
			return item
	var path := ECHO_DATA_DIR + "%s.tres" % echo_id
	if ResourceLoader.exists(path):
		return load(path) as Resource
	return null


func _build_layout() -> void:
	_main_panel = PanelContainer.new()
	_main_panel.set_anchors_and_offsets_preset(PRESET_CENTER)
	_main_panel.custom_minimum_size = Vector2(_PANEL_WIDTH, _PANEL_HEIGHT)
	_main_panel.offset_left = -_PANEL_WIDTH / 2.0
	_main_panel.offset_right = _PANEL_WIDTH / 2.0
	_main_panel.offset_top = -_PANEL_HEIGHT / 2.0
	_main_panel.offset_bottom = _PANEL_HEIGHT / 2.0
	_main_panel.add_theme_stylebox_override(
		"panel", UIHelpers.create_panel_style()
	)
	add_child(_main_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	_main_panel.add_child(margin)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 6)
	margin.add_child(root_vbox)

	# Title row with count label
	var title_hbox := HBoxContainer.new()
	root_vbox.add_child(title_hbox)

	var title_label := Label.new()
	title_label.text = "Echo Journal"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", _FONT_SIZE_TITLE)
	title_label.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_hbox.add_child(title_label)

	_count_label = Label.new()
	_count_label.add_theme_font_size_override("font_size", _FONT_SIZE_SMALL)
	_count_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_hbox.add_child(_count_label)

	var sep := HSeparator.new()
	root_vbox.add_child(sep)

	# Content area
	_content_hbox = HBoxContainer.new()
	_content_hbox.add_theme_constant_override("separation", 8)
	_content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(_content_hbox)

	# Echo list (left side)
	_echo_list_scroll = ScrollContainer.new()
	_echo_list_scroll.custom_minimum_size = Vector2(_LIST_WIDTH, 0)
	_echo_list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_hbox.add_child(_echo_list_scroll)

	_echo_list = VBoxContainer.new()
	_echo_list.add_theme_constant_override("separation", 2)
	_echo_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_echo_list_scroll.add_child(_echo_list)

	# Detail panel (right side)
	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_panel.add_theme_stylebox_override(
		"panel",
		UIHelpers.create_panel_style(UITheme.PANEL_INNER_BG),
	)
	_content_hbox.add_child(detail_panel)

	var detail_scroll := ScrollContainer.new()
	detail_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_panel.add_child(detail_scroll)

	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 8)
	detail_margin.add_theme_constant_override("margin_top", 6)
	detail_margin.add_theme_constant_override("margin_right", 8)
	detail_margin.add_theme_constant_override("margin_bottom", 6)
	detail_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_scroll.add_child(detail_margin)

	_detail_vbox = VBoxContainer.new()
	_detail_vbox.add_theme_constant_override("separation", 4)
	_detail_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_margin.add_child(_detail_vbox)

	_echo_name_label = Label.new()
	_echo_name_label.add_theme_font_size_override("font_size", _FONT_SIZE_TITLE - 2)
	_echo_name_label.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	_detail_vbox.add_child(_echo_name_label)

	var badge_hbox := HBoxContainer.new()
	badge_hbox.add_theme_constant_override("separation", 6)
	_detail_vbox.add_child(badge_hbox)

	_rarity_label = Label.new()
	_rarity_label.add_theme_font_size_override("font_size", _FONT_SIZE_SMALL)
	badge_hbox.add_child(_rarity_label)

	_type_label = Label.new()
	_type_label.add_theme_font_size_override("font_size", _FONT_SIZE_SMALL)
	_type_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	badge_hbox.add_child(_type_label)

	var detail_sep := HSeparator.new()
	_detail_vbox.add_child(detail_sep)

	_lore_label = Label.new()
	_lore_label.add_theme_font_size_override("font_size", _FONT_SIZE_DETAIL)
	_lore_label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	_lore_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_vbox.add_child(_lore_label)

	var notes_sep := HSeparator.new()
	_detail_vbox.add_child(notes_sep)

	var notes_header := Label.new()
	notes_header.text = "Kael's Notes"
	notes_header.add_theme_font_size_override("font_size", _FONT_SIZE_SMALL)
	notes_header.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	_detail_vbox.add_child(notes_header)

	_notes_label = Label.new()
	_notes_label.add_theme_font_size_override("font_size", _FONT_SIZE_DETAIL)
	_notes_label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	_notes_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_vbox.add_child(_notes_label)

	# Empty state label
	_empty_label = Label.new()
	_empty_label.add_theme_font_size_override("font_size", _FONT_SIZE_DETAIL)
	_empty_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_empty_label.text = "No echoes collected yet"
	_empty_label.visible = false
	root_vbox.add_child(_empty_label)

	_detail_vbox.visible = false


func _refresh() -> void:
	UIHelpers.clear_children(_echo_list)
	_detail_vbox.visible = false

	var em: Node = get_node_or_null("/root/EchoManager")
	if em == null:
		_content_hbox.visible = false
		_empty_label.visible = true
		_count_label.text = compute_echo_count_label(0, ECHO_TOTAL)
		return

	var count: int = em.get_echo_count()
	_count_label.text = compute_echo_count_label(count, ECHO_TOTAL)

	var echoes: Array[Dictionary] = compute_echo_list(em, [])

	if echoes.is_empty():
		_content_hbox.visible = false
		_empty_label.visible = true
		return

	_content_hbox.visible = true
	_empty_label.visible = false

	var first_button: Button = null
	for entry: Dictionary in echoes:
		var btn := Button.new()
		btn.text = entry["display_name"]
		btn.add_theme_font_size_override("font_size", _FONT_SIZE_BUTTON)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_echo_selected.bind(entry))
		_echo_list.add_child(btn)
		if first_button == null:
			first_button = btn

	var buttons: Array = []
	for child in _echo_list.get_children():
		buttons.append(child)
	if buttons.size() > 0:
		UIHelpers.setup_focus_wrap(buttons)

	if first_button != null:
		first_button.grab_focus()
		_on_echo_selected(echoes[0])


func _on_echo_selected(entry: Dictionary) -> void:
	_selected_echo_id = entry["id"]
	_detail_vbox.visible = true

	_echo_name_label.text = entry["display_name"]

	var rarity_idx: int = entry["rarity"]
	_rarity_label.text = RARITY_NAMES.get(rarity_idx, "Common")
	_rarity_label.add_theme_color_override(
		"font_color",
		RARITY_COLORS.get(rarity_idx, Color.WHITE),
	)

	var type_idx: int = entry["echo_type"]
	_type_label.text = "[ %s ]" % ECHO_TYPE_NAMES.get(type_idx, "Attack")

	_lore_label.text = entry["lore_text"] if not entry["lore_text"].is_empty() \
		else "(No lore recorded)"
	_notes_label.text = entry["kael_notes"] if not entry["kael_notes"].is_empty() \
		else "(No notes)"

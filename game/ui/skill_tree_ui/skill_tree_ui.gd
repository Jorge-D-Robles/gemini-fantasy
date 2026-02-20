class_name SkillTreeUI
extends Control

## Skill Tree UI — accessible from the pause menu.
## Shows skill tree nodes per character with unlock/locked/available state.
## Script-only (no .tscn) — layout built programmatically.

signal skill_tree_ui_closed

const UITheme = preload("res://ui/ui_theme.gd")
const UIHelpers = preload("res://ui/ui_helpers.gd")
const STM = preload("res://systems/progression/skill_tree_manager.gd")

const _PANEL_WIDTH: int = 560
const _PANEL_HEIGHT: int = 340
const _CHAR_LIST_WIDTH: int = 100
const _FONT_SIZE_TITLE: int = 16
const _FONT_SIZE_BUTTON: int = 11
const _FONT_SIZE_NODE: int = 10
const _FONT_SIZE_SMALL: int = 9

const _STATE_COLORS: Dictionary = {
	"unlocked": Color(0.4, 0.9, 0.4),
	"available": Color(0.9, 0.85, 0.45),
	"locked": Color(0.5, 0.5, 0.6),
}

var _selected_char_id: StringName = &""
var _selected_node_id: StringName = &""

var _main_panel: PanelContainer
var _sp_label: Label
var _char_list: VBoxContainer
var _node_list: VBoxContainer
var _node_list_scroll: ScrollContainer
var _detail_vbox: VBoxContainer
var _node_name_label: Label
var _node_desc_label: Label
var _node_cost_label: Label
var _node_state_label: Label
var _unlock_button: Button
var _content_hbox: HBoxContainer


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
	_selected_node_id = &""
	_refresh_char_list()


func close() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	visible = false
	skill_tree_ui_closed.emit()


## Returns Array[Dictionary] of all skill tree node entries for char_data.
## Each entry: {id, display_name, description, ap_cost, state, path_name, required_node_ids}
## state is "unlocked", "available", or "locked".
static func compute_skill_tree_entries(char_data: Resource) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not "skill_trees" in char_data:
		return result
	for tree: Resource in char_data.skill_trees:
		var path_name: String = tree.get("display_name") if "display_name" in tree else ""
		if not "nodes" in tree:
			continue
		for raw_node: Resource in tree.nodes:
			result.append({
				"id": raw_node.get("id") if "id" in raw_node else &"",
				"display_name": raw_node.get("display_name") if "display_name" in raw_node else "",
				"description": raw_node.get("description") if "description" in raw_node else "",
				"ap_cost": int(raw_node.get("ap_cost")) if "ap_cost" in raw_node else 0,
				"state": compute_node_state(raw_node, char_data),
				"path_name": path_name,
				"required_node_ids": (
					raw_node.get("required_node_ids") if "required_node_ids" in raw_node
					else []
				),
			})
	return result


## Returns the unlock state of a skill tree node for the given character.
## Returns "unlocked" if already unlocked, "available" if requirements are met,
## or "locked" if prerequisites are missing or SP is insufficient.
static func compute_node_state(node: Resource, char_data: Resource) -> String:
	if not "id" in node:
		return "locked"
	if not "unlocked_skill_ids" in char_data:
		return "locked"
	var unlocked: Array[StringName] = char_data.unlocked_skill_ids
	if node.id in unlocked:
		return "unlocked"
	var sp: int = int(char_data.get("skill_points")) if "skill_points" in char_data else 0
	var stnd := node as SkillTreeNodeData
	if stnd == null:
		return "locked"
	if STM.compute_can_unlock(stnd, unlocked, sp):
		return "available"
	return "locked"


## Returns formatted skill-point display label text.
static func compute_sp_label(sp: int) -> String:
	return "SP: %d" % sp


func _build_layout() -> void:
	_main_panel = PanelContainer.new()
	_main_panel.set_anchors_and_offsets_preset(PRESET_CENTER)
	_main_panel.custom_minimum_size = Vector2(_PANEL_WIDTH, _PANEL_HEIGHT)
	_main_panel.offset_left = -_PANEL_WIDTH / 2.0
	_main_panel.offset_right = _PANEL_WIDTH / 2.0
	_main_panel.offset_top = -_PANEL_HEIGHT / 2.0
	_main_panel.offset_bottom = _PANEL_HEIGHT / 2.0
	_main_panel.add_theme_stylebox_override("panel", UIHelpers.create_panel_style())
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

	# Title row
	var title_hbox := HBoxContainer.new()
	root_vbox.add_child(title_hbox)

	var title_label := Label.new()
	title_label.text = "Skill Tree"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.add_theme_font_size_override("font_size", _FONT_SIZE_TITLE)
	title_label.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_hbox.add_child(title_label)

	_sp_label = Label.new()
	_sp_label.add_theme_font_size_override("font_size", _FONT_SIZE_SMALL)
	_sp_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	_sp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_hbox.add_child(_sp_label)

	root_vbox.add_child(HSeparator.new())

	# Content row
	_content_hbox = HBoxContainer.new()
	_content_hbox.add_theme_constant_override("separation", 8)
	_content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(_content_hbox)

	# Left: character list
	var char_scroll := ScrollContainer.new()
	char_scroll.custom_minimum_size = Vector2(_CHAR_LIST_WIDTH, 0)
	char_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_hbox.add_child(char_scroll)

	_char_list = VBoxContainer.new()
	_char_list.add_theme_constant_override("separation", 2)
	_char_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	char_scroll.add_child(_char_list)

	# Right: node list + detail
	var right_vbox := VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 6)
	_content_hbox.add_child(right_vbox)

	# Node list scroll
	_node_list_scroll = ScrollContainer.new()
	_node_list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_node_list_scroll.custom_minimum_size = Vector2(0, 140)
	right_vbox.add_child(_node_list_scroll)

	_node_list = VBoxContainer.new()
	_node_list.add_theme_constant_override("separation", 2)
	_node_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_node_list_scroll.add_child(_node_list)

	# Detail panel
	var detail_panel := PanelContainer.new()
	detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_panel.add_theme_stylebox_override(
		"panel",
		UIHelpers.create_panel_style(UITheme.PANEL_INNER_BG),
	)
	right_vbox.add_child(detail_panel)

	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 8)
	detail_margin.add_theme_constant_override("margin_top", 4)
	detail_margin.add_theme_constant_override("margin_right", 8)
	detail_margin.add_theme_constant_override("margin_bottom", 4)
	detail_panel.add_child(detail_margin)

	_detail_vbox = VBoxContainer.new()
	_detail_vbox.add_theme_constant_override("separation", 3)
	_detail_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	detail_margin.add_child(_detail_vbox)

	_node_name_label = Label.new()
	_node_name_label.add_theme_font_size_override("font_size", _FONT_SIZE_NODE + 1)
	_node_name_label.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	_detail_vbox.add_child(_node_name_label)

	var badges := HBoxContainer.new()
	badges.add_theme_constant_override("separation", 8)
	_detail_vbox.add_child(badges)

	_node_cost_label = Label.new()
	_node_cost_label.add_theme_font_size_override("font_size", _FONT_SIZE_SMALL)
	badges.add_child(_node_cost_label)

	_node_state_label = Label.new()
	_node_state_label.add_theme_font_size_override("font_size", _FONT_SIZE_SMALL)
	badges.add_child(_node_state_label)

	_node_desc_label = Label.new()
	_node_desc_label.add_theme_font_size_override("font_size", _FONT_SIZE_NODE)
	_node_desc_label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	_node_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_vbox.add_child(_node_desc_label)

	_unlock_button = Button.new()
	_unlock_button.text = "Unlock Node"
	_unlock_button.add_theme_font_size_override("font_size", _FONT_SIZE_BUTTON)
	_unlock_button.visible = false
	_unlock_button.pressed.connect(_on_unlock_pressed)
	_detail_vbox.add_child(_unlock_button)

	_detail_vbox.visible = false


func _refresh_char_list() -> void:
	UIHelpers.clear_children(_char_list)
	_detail_vbox.visible = false
	_sp_label.text = ""

	var pm: Node = get_node_or_null("/root/PartyManager")
	if pm == null:
		return

	var roster: Array[Resource] = pm.get_roster()
	if roster.is_empty():
		return

	# Select first character if none selected
	if _selected_char_id == &"":
		var first: Resource = roster[0]
		if "id" in first:
			_selected_char_id = first.id

	var first_button: Button = null
	for member: Resource in roster:
		if not "id" in member:
			continue
		var btn := Button.new()
		btn.text = member.display_name if "display_name" in member else String(member.id)
		btn.add_theme_font_size_override("font_size", _FONT_SIZE_BUTTON)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_char_selected.bind(member))
		_char_list.add_child(btn)
		if first_button == null:
			first_button = btn

	var buttons: Array = []
	for child: Node in _char_list.get_children():
		buttons.append(child)
	if buttons.size() > 0:
		UIHelpers.setup_focus_wrap(buttons)

	if first_button != null:
		first_button.grab_focus()
		_on_char_selected(roster[0])


func _on_char_selected(char_data: Resource) -> void:
	if not "id" in char_data:
		return
	_selected_char_id = char_data.id
	_selected_node_id = &""

	var sp: int = int(char_data.get("skill_points")) if "skill_points" in char_data else 0
	_sp_label.text = compute_sp_label(sp)

	_refresh_node_list(char_data)


func _refresh_node_list(char_data: Resource) -> void:
	UIHelpers.clear_children(_node_list)
	_detail_vbox.visible = false

	var entries: Array[Dictionary] = compute_skill_tree_entries(char_data)
	if entries.is_empty():
		var empty := Label.new()
		empty.text = "No skill tree data"
		empty.add_theme_font_size_override("font_size", _FONT_SIZE_NODE)
		empty.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
		_node_list.add_child(empty)
		return

	var current_path: String = ""
	for entry: Dictionary in entries:
		if entry["path_name"] != current_path:
			current_path = entry["path_name"]
			var header := Label.new()
			header.text = "— %s —" % current_path
			header.add_theme_font_size_override("font_size", _FONT_SIZE_SMALL)
			header.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
			_node_list.add_child(header)

		var state: String = entry["state"]
		var btn := Button.new()
		btn.text = "%s  %dSP" % [entry["display_name"], entry["ap_cost"]]
		btn.add_theme_font_size_override("font_size", _FONT_SIZE_NODE)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_color_override(
			"font_color",
			_STATE_COLORS.get(state, Color.WHITE),
		)
		btn.pressed.connect(_on_node_selected.bind(entry, char_data))
		_node_list.add_child(btn)

	var buttons: Array = []
	for child: Node in _node_list.get_children():
		if child is Button:
			buttons.append(child)
	if buttons.size() > 0:
		UIHelpers.setup_focus_wrap(buttons)


func _on_node_selected(entry: Dictionary, char_data: Resource) -> void:
	_selected_node_id = entry["id"]
	_detail_vbox.visible = true

	_node_name_label.text = entry["display_name"]
	_node_desc_label.text = entry["description"] if not entry["description"].is_empty() \
		else "(No description)"

	var sp: int = int(char_data.get("skill_points")) if "skill_points" in char_data else 0
	_node_cost_label.text = "Cost: %dSP" % entry["ap_cost"]
	_node_cost_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)

	var state: String = entry["state"]
	_node_state_label.text = "[%s]" % state.to_upper()
	_node_state_label.add_theme_color_override(
		"font_color",
		_STATE_COLORS.get(state, Color.WHITE),
	)

	_unlock_button.visible = (state == "available")

	if not entry["required_node_ids"].is_empty():
		var req_ids: Array = entry["required_node_ids"]
		var req_strs: PackedStringArray = []
		for req_id: Variant in req_ids:
			req_strs.append(String(req_id))
		_node_desc_label.text += "\n(Requires: %s)" % ", ".join(req_strs)

	# Store char_data ref for unlock
	_unlock_button.set_meta("char_data", char_data)
	_unlock_button.set_meta("node_entry", entry)


func _on_unlock_pressed() -> void:
	if _selected_node_id == &"":
		return
	var char_data: Resource = _unlock_button.get_meta("char_data", null)
	if char_data == null:
		return

	var node_entry: Dictionary = _unlock_button.get_meta("node_entry", {})
	if node_entry.is_empty():
		return

	# Find the actual SkillTreeNodeData by id
	var stnd: SkillTreeNodeData = _find_node_data(char_data, _selected_node_id)
	if stnd == null:
		return

	var unlocked: Array[StringName] = char_data.unlocked_skill_ids
	var sp: int = int(char_data.get("skill_points")) if "skill_points" in char_data else 0
	var result: Dictionary = STM.compute_unlock_result(stnd, unlocked, sp)

	if result["success"]:
		char_data.skill_points = result["remaining_sp"]
		char_data.unlocked_skill_ids = result["unlocked_ids"]
		AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
		_selected_node_id = &""
		_on_char_selected(char_data)
	else:
		AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))


func _find_node_data(char_data: Resource, node_id: StringName) -> SkillTreeNodeData:
	if not "skill_trees" in char_data:
		return null
	for tree: Resource in char_data.skill_trees:
		if not "nodes" in tree:
			continue
		for raw_node: Resource in tree.nodes:
			var stnd := raw_node as SkillTreeNodeData
			if stnd != null and stnd.id == node_id:
				return stnd
	return null

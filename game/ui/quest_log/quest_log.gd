extends Control

## Quest log UI screen accessible from the pause menu.
## Shows active/completed quests with objectives, descriptions, and rewards.
## Script-only (no .tscn) — layout built programmatically.

signal quest_log_closed

const UITheme = preload("res://ui/ui_theme.gd")
const UIHelpers = preload("res://ui/ui_helpers.gd")

const QUEST_TYPE_NAMES: Dictionary = {
	QuestData.QuestType.MAIN: "Main Quest",
	QuestData.QuestType.SIDE: "Side Quest",
	QuestData.QuestType.CHARACTER: "Character",
	QuestData.QuestType.BOUNTY: "Bounty",
	QuestData.QuestType.COLLECTION: "Collection",
}

const _PANEL_WIDTH: int = 520
const _PANEL_HEIGHT: int = 300
const _LIST_WIDTH: int = 160
const _FONT_SIZE_TITLE: int = 16
const _FONT_SIZE_BUTTON: int = 11
const _FONT_SIZE_DETAIL: int = 10
const _FONT_SIZE_SMALL: int = 9

var _showing_completed: bool = false
var _selected_quest_id: StringName = &""

var _main_panel: PanelContainer
var _active_tab: Button
var _completed_tab: Button
var _quest_list: VBoxContainer
var _quest_list_scroll: ScrollContainer
var _detail_vbox: VBoxContainer
var _quest_name_label: Label
var _quest_type_label: Label
var _description_label: Label
var _objectives_list: VBoxContainer
var _rewards_label: Label
var _empty_label: Label
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
	visible = true
	_showing_completed = false
	_selected_quest_id = &""
	_refresh()
	_active_tab.grab_focus()


func close() -> void:
	visible = false
	quest_log_closed.emit()


static func compute_quest_list(
	qm: Node,
	show_completed: bool,
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var quest_ids: Array[StringName]
	if show_completed:
		quest_ids = qm.get_completed_quests()
	else:
		quest_ids = qm.get_active_quests()

	for qid: StringName in quest_ids:
		var quest_data: Resource = qm.get_quest_data(qid)
		if quest_data == null:
			continue

		var objectives: Array[Dictionary] = []
		var obj_status: Array = qm.get_objective_status(qid)
		for i in quest_data.objectives.size():
			var completed: bool = false
			if i < obj_status.size():
				completed = bool(obj_status[i])
			objectives.append({
				"text": quest_data.objectives[i],
				"completed": completed,
			})

		var items: Array[StringName] = []
		for item_id: StringName in quest_data.reward_item_ids:
			items.append(item_id)

		result.append({
			"id": qid,
			"title": quest_data.title,
			"quest_type": quest_data.quest_type,
			"description": quest_data.description,
			"objectives": objectives,
			"rewards": {
				"gold": quest_data.reward_gold,
				"exp": quest_data.reward_exp,
				"items": items,
			},
		})

	return result


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

	# Title
	var title_label := Label.new()
	title_label.text = "Quest Log"
	title_label.add_theme_font_size_override("font_size", _FONT_SIZE_TITLE)
	title_label.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root_vbox.add_child(title_label)

	# Tab buttons
	var tab_hbox := HBoxContainer.new()
	tab_hbox.add_theme_constant_override("separation", 8)
	tab_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	root_vbox.add_child(tab_hbox)

	_active_tab = Button.new()
	_active_tab.text = "Active"
	_active_tab.add_theme_font_size_override("font_size", _FONT_SIZE_BUTTON)
	_active_tab.pressed.connect(_on_active_tab_pressed)
	tab_hbox.add_child(_active_tab)

	_completed_tab = Button.new()
	_completed_tab.text = "Completed"
	_completed_tab.add_theme_font_size_override(
		"font_size", _FONT_SIZE_BUTTON
	)
	_completed_tab.pressed.connect(_on_completed_tab_pressed)
	tab_hbox.add_child(_completed_tab)

	UIHelpers.setup_focus_wrap([_active_tab, _completed_tab], true)

	var sep := HSeparator.new()
	root_vbox.add_child(sep)

	# Content area
	_content_hbox = HBoxContainer.new()
	_content_hbox.add_theme_constant_override("separation", 8)
	_content_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(_content_hbox)

	# Quest list (left side)
	_quest_list_scroll = ScrollContainer.new()
	_quest_list_scroll.custom_minimum_size = Vector2(_LIST_WIDTH, 0)
	_quest_list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_hbox.add_child(_quest_list_scroll)

	_quest_list = VBoxContainer.new()
	_quest_list.add_theme_constant_override("separation", 2)
	_quest_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quest_list_scroll.add_child(_quest_list)

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

	_quest_name_label = Label.new()
	_quest_name_label.add_theme_font_size_override(
		"font_size", _FONT_SIZE_TITLE - 2
	)
	_quest_name_label.add_theme_color_override(
		"font_color", UITheme.TEXT_GOLD
	)
	_detail_vbox.add_child(_quest_name_label)

	_quest_type_label = Label.new()
	_quest_type_label.add_theme_font_size_override(
		"font_size", _FONT_SIZE_SMALL
	)
	_quest_type_label.add_theme_color_override(
		"font_color", UITheme.TEXT_SECONDARY
	)
	_detail_vbox.add_child(_quest_type_label)

	var detail_sep := HSeparator.new()
	_detail_vbox.add_child(detail_sep)

	_description_label = Label.new()
	_description_label.add_theme_font_size_override(
		"font_size", _FONT_SIZE_DETAIL
	)
	_description_label.add_theme_color_override(
		"font_color", UITheme.TEXT_PRIMARY
	)
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_vbox.add_child(_description_label)

	_objectives_list = VBoxContainer.new()
	_objectives_list.add_theme_constant_override("separation", 2)
	_detail_vbox.add_child(_objectives_list)

	var rewards_sep := HSeparator.new()
	_detail_vbox.add_child(rewards_sep)

	_rewards_label = Label.new()
	_rewards_label.add_theme_font_size_override(
		"font_size", _FONT_SIZE_SMALL
	)
	_rewards_label.add_theme_color_override(
		"font_color", UITheme.TEXT_GOLD
	)
	_rewards_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_detail_vbox.add_child(_rewards_label)

	# Empty state label
	_empty_label = Label.new()
	_empty_label.add_theme_font_size_override(
		"font_size", _FONT_SIZE_DETAIL
	)
	_empty_label.add_theme_color_override(
		"font_color", UITheme.TEXT_SECONDARY
	)
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_empty_label.visible = false
	root_vbox.add_child(_empty_label)

	# Hide detail initially
	_detail_vbox.visible = false


func _refresh() -> void:
	UIHelpers.clear_children(_quest_list)
	_detail_vbox.visible = false

	var quests: Array[Dictionary] = compute_quest_list(
		QuestManager, _showing_completed
	)

	if quests.is_empty():
		_content_hbox.visible = false
		_empty_label.visible = true
		if _showing_completed:
			_empty_label.text = "No completed quests"
		else:
			_empty_label.text = "No active quests"
		return

	_content_hbox.visible = true
	_empty_label.visible = false

	var first_button: Button = null
	for quest: Dictionary in quests:
		var btn := Button.new()
		btn.text = quest["title"]
		btn.add_theme_font_size_override(
			"font_size", _FONT_SIZE_BUTTON
		)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if _showing_completed:
			btn.add_theme_color_override(
				"font_color", UITheme.TEXT_DISABLED
			)
		btn.pressed.connect(
			_on_quest_selected.bind(quest)
		)
		_quest_list.add_child(btn)
		if first_button == null:
			first_button = btn

	# Wire focus wrapping for quest list buttons
	var buttons: Array = []
	for child in _quest_list.get_children():
		buttons.append(child)
	if buttons.size() > 0:
		UIHelpers.setup_focus_wrap(buttons)

	# Wire cross-panel focus: tab buttons <-> quest list
	_wire_cross_panel_focus(first_button)

	# Auto-select first quest
	if first_button != null:
		first_button.grab_focus()
		_on_quest_selected(quests[0])


func _wire_cross_panel_focus(first_quest_btn: Button) -> void:
	if first_quest_btn == null:
		return
	# Tab buttons go down to quest list
	_active_tab.focus_neighbor_bottom = first_quest_btn.get_path()
	_completed_tab.focus_neighbor_bottom = first_quest_btn.get_path()
	# Quest list goes up to tabs
	first_quest_btn.focus_neighbor_top = _active_tab.get_path()


func _on_quest_selected(quest: Dictionary) -> void:
	_selected_quest_id = quest["id"]
	_detail_vbox.visible = true

	_quest_name_label.text = quest["title"]
	var qt: int = quest["quest_type"]
	_quest_type_label.text = QUEST_TYPE_NAMES.get(qt, "Quest")

	_description_label.text = quest["description"]

	# Objectives
	UIHelpers.clear_children(_objectives_list)
	var objectives: Array = quest["objectives"]
	for obj: Dictionary in objectives:
		var obj_label := Label.new()
		obj_label.add_theme_font_size_override(
			"font_size", _FONT_SIZE_SMALL
		)
		if obj["completed"]:
			obj_label.text = "[x] %s" % obj["text"]
			obj_label.add_theme_color_override(
				"font_color", UITheme.TEXT_DISABLED
			)
		else:
			obj_label.text = "[ ] %s" % obj["text"]
			obj_label.add_theme_color_override(
				"font_color", UITheme.TEXT_PRIMARY
			)
		_objectives_list.add_child(obj_label)

	# Rewards
	var rewards: Dictionary = quest["rewards"]
	var reward_parts: Array[String] = []
	if rewards["gold"] > 0:
		reward_parts.append("%d Gold" % rewards["gold"])
	if rewards["exp"] > 0:
		reward_parts.append("%d EXP" % rewards["exp"])
	if rewards["items"].size() > 0:
		reward_parts.append(
			"%d Item(s)" % rewards["items"].size()
		)
	if reward_parts.is_empty():
		_rewards_label.text = "No rewards"
	else:
		_rewards_label.text = "Rewards: " + ", ".join(reward_parts)


func _on_active_tab_pressed() -> void:
	_showing_completed = false
	_selected_quest_id = &""
	_refresh()


func _on_completed_tab_pressed() -> void:
	_showing_completed = true
	_selected_quest_id = &""
	_refresh()

extends CanvasLayer

## Overworld HUD showing location, gold, party status, interaction prompts,
## active quest objective tracker, and area name popup on zone transitions.

const SP = preload("res://systems/scene_paths.gd")
const UITheme = preload("res://ui/ui_theme.gd")
const TH = preload("res://ui/hud/tutorial_hints.gd")
const FragmentTracker = preload("res://ui/hud/hud_fragment_tracker.gd")
const HudCompass = preload("res://ui/hud/hud_compass.gd")

const AREA_NAMES: Dictionary = {
	SP.ROOTHOLLOW: "Roothollow",
	SP.VERDANT_FOREST: "Verdant Forest",
	SP.OVERGROWN_RUINS: "Overgrown Ruins",
}

const TOAST_SLIDE_DURATION: float = 0.3
const TOAST_HOLD_DURATION: float = 2.0
const TOAST_FADE_DURATION: float = 0.5

@export var location_name: String = "" :
	set(value):
		location_name = value
		if is_node_ready():
			_location_label.text = value

var _gold: int = 0
var _current_scene_path: String = ""
var _compass_label: Label = null
var _fragment_tracker_label: Label = null
var _echo_badge_label: Label = null
var _area_name_popup: Label = null
var _area_popup_tween: Tween = null
var _tutorial_popup: Label = null
var _tutorial_tween: Tween = null
var _tutorial_visible: bool = false
var _quest_toast_label: Label = null
var _quest_toast_tween: Tween = null
var _quest_toast_queue: Array[String] = []
var _toast_processing: bool = false

@onready var _location_label: Label = %LocationLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _party_status: VBoxContainer = %PartyStatus
@onready var _interaction_prompt: Label = %InteractionPrompt
@onready var _objective_tracker: PanelContainer = %ObjectiveTracker
@onready var _quest_title: Label = %QuestTitle
@onready var _objective_label: Label = %ObjectiveLabel


func _ready() -> void:
	visible = false
	_interaction_prompt.visible = false
	_objective_tracker.visible = false
	_location_label.text = location_name
	_update_gold_display()
	update_party_display()
	_setup_area_name_popup()
	_setup_tutorial_popup()
	_setup_quest_toast()
	_setup_fragment_tracker()
	_setup_compass()
	_setup_echo_badge()
	# Connect EchoManager for live badge updates
	var em: Node = get_node_or_null("/root/EchoManager")
	if em:
		em.echo_collected.connect(_on_echo_collected)

	PartyManager.party_changed.connect(_on_party_changed)
	PartyManager.party_state_changed.connect(_on_party_state_changed)
	GameManager.game_state_changed.connect(_on_game_state_changed)
	GameManager.scene_changed.connect(_on_scene_changed)
	# Sync gold from InventoryManager if available
	var inv: Node = get_node_or_null("/root/InventoryManager")
	if inv:
		_gold = inv.gold
		_update_gold_display()
		inv.gold_changed.connect(_on_gold_changed)
	# Connect QuestManager signals for objective tracker + toast notifications
	var qm: Node = get_node_or_null("/root/QuestManager")
	if qm:
		qm.quest_accepted.connect(_on_quest_accepted)
		qm.quest_progressed.connect(_on_quest_progressed)
		qm.quest_completed.connect(_on_quest_completed_event)
		qm.quest_failed.connect(_on_quest_changed)
		update_objective_tracker()


func _exit_tree() -> void:
	if _area_popup_tween and _area_popup_tween.is_valid():
		_area_popup_tween.kill()
	if _tutorial_tween and _tutorial_tween.is_valid():
		_tutorial_tween.kill()
	if _quest_toast_tween and _quest_toast_tween.is_valid():
		_quest_toast_tween.kill()


func _unhandled_input(event: InputEvent) -> void:
	if not _tutorial_visible:
		return
	if event.is_action_pressed("interact"):
		_dismiss_tutorial_hint()
		get_viewport().set_input_as_handled()


func show_tutorial_hint(hint_id: String) -> void:
	if GameManager.current_state != GameManager.GameState.OVERWORLD:
		return
	var flags := EventFlags.get_all_flags()
	if not TH.should_show(hint_id, flags):
		return
	EventFlags.set_flag(TH.get_flag_name(hint_id))
	var text := TH.get_hint_text(hint_id)
	if text.is_empty():
		return
	_show_tutorial_popup(text)


func show_interaction_prompt(text: String) -> void:
	_interaction_prompt.text = text
	_interaction_prompt.visible = true


func hide_interaction_prompt() -> void:
	_interaction_prompt.visible = false


func update_party_display() -> void:
	for child in _party_status.get_children():
		child.queue_free()

	var party := PartyManager.get_active_party()
	for member in party:
		var row := _create_member_row(member)
		_party_status.add_child(row)


func set_gold(amount: int) -> void:
	_gold = amount
	_update_gold_display()


func update_objective_tracker() -> void:
	var qm: Node = get_node_or_null("/root/QuestManager")
	if not qm:
		_objective_tracker.visible = false
		return
	var state := compute_tracker_state(qm)
	_objective_tracker.visible = state["visible"]
	if state["visible"]:
		_quest_title.text = state["title"]
		_objective_label.text = state["objective"]


## Returns tracker display state from quest manager data.
## Shows first active quest (insertion order = acceptance order).
static func compute_tracker_state(qm: Node) -> Dictionary:
	var active: Array = qm.get_active_quests()
	if active.is_empty():
		return {"visible": false, "title": "", "objective": ""}
	var quest_id: StringName = active[0]
	var quest: Resource = qm.get_quest_data(quest_id)
	if not quest:
		return {"visible": false, "title": "", "objective": ""}
	var title: String = quest.title
	var objective := ""
	var obj_status: Array = qm.get_objective_status(quest_id)
	for i in obj_status.size():
		if not obj_status[i]:
			objective = "- %s" % quest.objectives[i]
			break
	return {"visible": true, "title": title, "objective": objective}


## Maps a scene path to its human-readable area display name.
## Returns "" for non-overworld scenes (title, battle, unknown).
static func compute_area_display_name(scene_path: String) -> String:
	return AREA_NAMES.get(scene_path, "")


## Returns the toast text for a quest event.
## event: "accepted" or "completed"
static func compute_toast_text(event: String, quest_name: String) -> String:
	match event:
		"accepted":
			return "New Quest: %s" % quest_name
		"completed":
			return "Quest Complete: %s" % quest_name
		_:
			return quest_name


func show_quest_toast(text: String) -> void:
	_quest_toast_queue.append(text)
	if not _toast_processing:
		_process_quest_toasts()


func _process_quest_toasts() -> void:
	_toast_processing = true
	while not _quest_toast_queue.is_empty():
		var text: String = _quest_toast_queue.pop_front()
		if _quest_toast_label:
			_quest_toast_label.text = text
		if _quest_toast_tween and _quest_toast_tween.is_valid():
			_quest_toast_tween.kill()
		_quest_toast_tween = create_tween()
		_quest_toast_tween.tween_property(
			_quest_toast_label, "modulate:a", 1.0, TOAST_SLIDE_DURATION,
		)
		_quest_toast_tween.tween_interval(TOAST_HOLD_DURATION)
		_quest_toast_tween.tween_property(
			_quest_toast_label, "modulate:a", 0.0, TOAST_FADE_DURATION,
		)
		await _quest_toast_tween.finished
	_toast_processing = false


func _update_gold_display() -> void:
	_gold_label.text = "Gold: %d" % _gold


func _create_member_row(member: Resource) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var data := member as BattlerData

	var name_label := Label.new()
	name_label.text = data.display_name if data else "???"
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.custom_minimum_size.x = 48
	row.add_child(name_label)

	var max_val: int = data.max_hp if data else 100
	var current_val: int = max_val
	if data and data.id != &"":
		var state := PartyManager.get_runtime_state(data.id)
		if not state.is_empty():
			current_val = state["current_hp"]

	var hp_bar := ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(50, 8)
	hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hp_bar.show_percentage = false
	hp_bar.max_value = max_val
	hp_bar.value = current_val
	hp_bar.add_theme_color_override(
		"font_color", Color(0.2, 0.8, 0.2)
	)
	row.add_child(hp_bar)

	var hp_label := Label.new()
	hp_label.text = "%d/%d" % [current_val, max_val]
	hp_label.add_theme_font_size_override("font_size", 8)
	row.add_child(hp_label)

	return row


func _on_party_changed() -> void:
	update_party_display()


func _on_party_state_changed() -> void:
	update_party_display()
	# Re-sync gold from InventoryManager
	var inv: Node = get_node_or_null("/root/InventoryManager")
	if inv:
		set_gold(inv.gold)


func _on_gold_changed() -> void:
	var inv: Node = get_node_or_null("/root/InventoryManager")
	if inv:
		set_gold(inv.gold)


func _on_quest_changed(_quest_id: StringName) -> void:
	update_objective_tracker()


func _on_quest_accepted(quest_id: StringName) -> void:
	update_objective_tracker()
	var qm := get_node_or_null("/root/QuestManager")
	if not qm:
		return
	var quest: Resource = qm.get_quest_data(quest_id)
	var quest_name: String = quest.title if quest and quest.get("title") != null else String(quest_id)
	show_quest_toast(compute_toast_text("accepted", quest_name))


func _on_quest_completed_event(quest_id: StringName) -> void:
	update_objective_tracker()
	var qm := get_node_or_null("/root/QuestManager")
	if not qm:
		return
	var quest: Resource = qm.get_quest_data(quest_id)
	var quest_name: String = quest.title if quest and quest.get("title") != null else String(quest_id)
	show_quest_toast(compute_toast_text("completed", quest_name))


func _on_quest_progressed(
	_quest_id: StringName,
	_objective_index: int,
) -> void:
	update_objective_tracker()


func _on_scene_changed(scene_path: String) -> void:
	_current_scene_path = scene_path
	if "title_screen" in scene_path:
		visible = false
	else:
		visible = true
		var area := compute_area_display_name(scene_path)
		if not area.is_empty():
			_show_area_name(area)
	update_compass(scene_path)
	update_fragment_tracker()


func _on_game_state_changed(
	_old_state: GameManager.GameState,
	new_state: GameManager.GameState,
) -> void:
	match new_state:
		GameManager.GameState.OVERWORLD:
			visible = true
			update_fragment_tracker()
		GameManager.GameState.BATTLE, GameManager.GameState.CUTSCENE:
			_dismiss_tutorial_hint()
			visible = false
		_:
			pass


func _create_popup_label(
	font_size: int,
	color: Color,
	position: Vector2,
) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.position = position
	add_child(label)
	return label


func _setup_area_name_popup() -> void:
	_area_name_popup = _create_popup_label(20, UITheme.TEXT_PRIMARY, Vector2(-150, 40))
	_area_name_popup.name = "AreaNamePopup"
	_area_name_popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_area_name_popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_area_name_popup.anchors_preset = Control.PRESET_CENTER_TOP
	_area_name_popup.custom_minimum_size = Vector2(300, 40)
	_area_name_popup.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_area_name_popup.modulate.a = 0.0


func _show_area_name(area_name: String) -> void:
	if not _area_name_popup:
		return
	_area_name_popup.text = area_name
	if _area_popup_tween and _area_popup_tween.is_valid():
		_area_popup_tween.kill()
	_area_popup_tween = create_tween()
	_area_popup_tween.tween_property(
		_area_name_popup, "modulate:a", 1.0, 0.3,
	)
	_area_popup_tween.tween_interval(2.0)
	_area_popup_tween.tween_property(
		_area_name_popup, "modulate:a", 0.0, 0.5,
	)


func _setup_quest_toast() -> void:
	_quest_toast_label = _create_popup_label(10, UITheme.TEXT_GOLD, Vector2(-150, -90))
	_quest_toast_label.name = "QuestToastLabel"
	_quest_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_quest_toast_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_quest_toast_label.anchors_preset = Control.PRESET_CENTER_BOTTOM
	_quest_toast_label.custom_minimum_size = Vector2(300, 24)
	_quest_toast_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_quest_toast_label.modulate.a = 0.0


func _setup_tutorial_popup() -> void:
	_tutorial_popup = _create_popup_label(10, UITheme.TEXT_PRIMARY, Vector2(-150, -60))
	_tutorial_popup.name = "TutorialPopup"
	_tutorial_popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_tutorial_popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_tutorial_popup.anchors_preset = Control.PRESET_CENTER_BOTTOM
	_tutorial_popup.custom_minimum_size = Vector2(300, 24)
	_tutorial_popup.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_tutorial_popup.modulate.a = 0.0


func _show_tutorial_popup(text: String) -> void:
	if not _tutorial_popup:
		return
	_tutorial_popup.text = text
	if _tutorial_tween and _tutorial_tween.is_valid():
		_tutorial_tween.kill()
	_tutorial_visible = true
	_tutorial_tween = create_tween()
	_tutorial_tween.tween_property(
		_tutorial_popup, "modulate:a", 1.0, 0.3,
	)
	_tutorial_tween.tween_interval(4.2)
	_tutorial_tween.tween_property(
		_tutorial_popup, "modulate:a", 0.0, 0.5,
	)
	_tutorial_tween.tween_callback(_on_tutorial_dismissed)


func _dismiss_tutorial_hint() -> void:
	if not _tutorial_visible:
		return
	_tutorial_visible = false
	if _tutorial_tween and _tutorial_tween.is_valid():
		_tutorial_tween.kill()
	if _tutorial_popup:
		_tutorial_popup.modulate.a = 0.0


func _on_tutorial_dismissed() -> void:
	_tutorial_visible = false


func _setup_fragment_tracker() -> void:
	_fragment_tracker_label = _create_popup_label(9, Color(0.5, 0.85, 1.0), Vector2(-80, 54))
	_fragment_tracker_label.name = "FragmentTrackerLabel"
	_fragment_tracker_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_fragment_tracker_label.anchors_preset = Control.PRESET_TOP_RIGHT
	_fragment_tracker_label.custom_minimum_size = Vector2(72, 16)
	_fragment_tracker_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_fragment_tracker_label.visible = false


func update_compass(scene_path: String) -> void:
	if not _compass_label:
		return
	var visible_flag: bool = HudCompass.compute_compass_visible(scene_path)
	_compass_label.visible = visible_flag
	if visible_flag:
		_compass_label.text = HudCompass.compute_compass_text(scene_path)


func update_fragment_tracker() -> void:
	if not _fragment_tracker_label:
		return
	var flags: Dictionary = EventFlags.get_all_flags()
	var state: Dictionary = FragmentTracker.compute_tracker_display(
		flags, _current_scene_path,
	)
	_fragment_tracker_label.visible = state["visible"]
	if state["visible"]:
		_fragment_tracker_label.text = state["label"]


func _setup_compass() -> void:
	_compass_label = _create_popup_label(9, UITheme.TEXT_SECONDARY, Vector2(8.0, -24.0))
	_compass_label.name = "ZoneCompass"
	_compass_label.anchors_preset = Control.PRESET_BOTTOM_LEFT
	_compass_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	_compass_label.visible = false


func _setup_echo_badge() -> void:
	_echo_badge_label = _create_popup_label(9, UITheme.TEXT_GOLD, Vector2(-80.0, -24.0))
	_echo_badge_label.name = "EchoBadge"
	_echo_badge_label.anchors_preset = Control.PRESET_BOTTOM_RIGHT
	_echo_badge_label.custom_minimum_size = Vector2(72.0, 16.0)
	_echo_badge_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_echo_badge_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	_echo_badge_label.visible = false


## Updates the echo count badge from EchoManager state.
func update_echo_badge() -> void:
	if not _echo_badge_label:
		return
	var em: Node = get_node_or_null("/root/EchoManager")
	if not em:
		_echo_badge_label.visible = false
		return
	var count: int = em.get_echo_count()
	_echo_badge_label.visible = count > 0
	if count > 0:
		_echo_badge_label.text = "\u25c6 %d" % count


## Returns the display text for the echo badge — pure static helper.
static func compute_echo_badge_text(count: int) -> String:
	if count <= 0:
		return ""
	return "\u25c6 %d" % count


func _on_echo_collected(_id: StringName) -> void:
	update_echo_badge()

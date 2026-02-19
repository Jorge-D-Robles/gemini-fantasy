extends CanvasLayer

## Pause menu with party, items, quests, and status panels.
## Pauses scene tree while open. Items button opens inventory UI.
## Quests button opens quest log UI.

signal menu_opened
signal menu_closed

const UIHelpers = preload("res://ui/ui_helpers.gd")
const INVENTORY_UI_SCENE := preload(
	"res://ui/inventory_ui/inventory_ui.tscn"
)
const QuestLogScript = preload("res://ui/quest_log/quest_log.gd")

var _is_open: bool = false
var _inventory_ui: Control = null
var _quest_log: Control = null

@onready var _dim_overlay: ColorRect = %DimOverlay
@onready var _menu_panel: PanelContainer = %MenuPanel
@onready var _party_button: Button = %PartyButton
@onready var _items_button: Button = %ItemsButton
@onready var _quests_button: Button = %QuestsButton
@onready var _status_button: Button = %StatusButton
@onready var _quit_button: Button = %QuitButton
@onready var _party_panel: VBoxContainer = %PartyPanel
@onready var _item_panel: VBoxContainer = %ItemPanel
@onready var _status_panel: VBoxContainer = %StatusPanel
@onready var _pause_label: Label = %PauseLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_connect_buttons()
	_setup_focus_navigation()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if _is_open:
			close()
			get_viewport().set_input_as_handled()
		elif _can_open():
			open()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cancel") and _is_open:
		close()
		get_viewport().set_input_as_handled()


func _can_open() -> bool:
	if GameManager.current_state != GameManager.GameState.OVERWORLD:
		return false
	if GameManager.is_transitioning():
		return false
	var scene := get_tree().current_scene
	if scene and "title_screen" in scene.scene_file_path:
		return false
	return true


func open() -> void:
	if _is_open:
		return
	_is_open = true
	visible = true
	GameManager.push_state(GameManager.GameState.MENU)
	get_tree().paused = true
	_refresh_party_panel()
	_show_panel("party")
	_party_button.grab_focus()
	menu_opened.emit()


func close() -> void:
	if not _is_open:
		return
	if _inventory_ui != null:
		_inventory_ui.queue_free()
		_inventory_ui = null
	if _quest_log != null:
		_quest_log.queue_free()
		_quest_log = null
	_is_open = false
	visible = false
	get_tree().paused = false
	GameManager.pop_state()
	menu_closed.emit()


func _connect_buttons() -> void:
	_party_button.pressed.connect(_show_panel.bind("party"))
	_items_button.pressed.connect(_open_inventory)
	_quests_button.pressed.connect(_open_quest_log)
	_status_button.pressed.connect(_show_panel.bind("status"))
	_quit_button.pressed.connect(_on_quit_pressed)


func _setup_focus_navigation() -> void:
	UIHelpers.setup_focus_wrap([
		_party_button,
		_items_button,
		_quests_button,
		_status_button,
		_quit_button,
	])


func _show_panel(panel_name: String) -> void:
	_party_panel.visible = panel_name == "party"
	_item_panel.visible = panel_name == "items"
	_status_panel.visible = panel_name == "status"


func _refresh_party_panel() -> void:
	UIHelpers.clear_children(_party_panel)
	var party := PartyManager.get_active_party()

	if party.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No party members"
		empty_label.add_theme_font_size_override("font_size", 10)
		_party_panel.add_child(empty_label)
		return

	for member in party:
		var member_box := _create_member_info(member)
		_party_panel.add_child(member_box)


func _open_inventory() -> void:
	if _inventory_ui != null:
		return
	_menu_panel.visible = false
	_pause_label.visible = false
	_inventory_ui = INVENTORY_UI_SCENE.instantiate()
	_inventory_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_inventory_ui)
	_inventory_ui.inventory_closed.connect(
		_on_inventory_closed
	)
	_inventory_ui.open()


func _on_inventory_closed() -> void:
	if _inventory_ui != null:
		_inventory_ui.queue_free()
		_inventory_ui = null
	_menu_panel.visible = true
	_pause_label.visible = true
	_items_button.grab_focus()


func _open_quest_log() -> void:
	if _quest_log != null:
		return
	_menu_panel.visible = false
	_pause_label.visible = false
	_quest_log = QuestLogScript.new()
	_quest_log.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_quest_log)
	_quest_log.quest_log_closed.connect(
		_on_quest_log_closed
	)
	_quest_log.open()


func _on_quest_log_closed() -> void:
	if _quest_log != null:
		_quest_log.queue_free()
		_quest_log = null
	_menu_panel.visible = true
	_pause_label.visible = true
	_quests_button.grab_focus()


func _create_member_info(member: Resource) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 2)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)

	var name_label := Label.new()
	var display: String = member.display_name if "display_name" in member else "???"
	name_label.text = display
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override(
		"font_color", Color(0.9, 0.85, 0.7)
	)
	header.add_child(name_label)

	var stats_row := HBoxContainer.new()
	stats_row.add_theme_constant_override("separation", 8)
	box.add_child(stats_row)

	var hp_val: int = member.max_hp if "max_hp" in member else 0
	var ee_val: int = member.max_ee if "max_ee" in member else 0
	_add_stat_label(stats_row, "HP: %d/%d" % [hp_val, hp_val])
	_add_stat_label(stats_row, "EE: %d/%d" % [ee_val, ee_val])

	var stats_row2 := HBoxContainer.new()
	stats_row2.add_theme_constant_override("separation", 8)
	box.add_child(stats_row2)

	var atk: int = member.attack if "attack" in member else 0
	var mag: int = member.magic if "magic" in member else 0
	var def: int = member.defense if "defense" in member else 0
	var res: int = member.resistance if "resistance" in member else 0
	var spd: int = member.speed if "speed" in member else 0
	_add_stat_label(stats_row2, "ATK:%d" % atk)
	_add_stat_label(stats_row2, "MAG:%d" % mag)
	_add_stat_label(stats_row2, "DEF:%d" % def)
	_add_stat_label(stats_row2, "RES:%d" % res)
	_add_stat_label(stats_row2, "SPD:%d" % spd)

	var separator := HSeparator.new()
	box.add_child(separator)

	return box


func _add_stat_label(parent: Node, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 9)
	parent.add_child(label)


func _on_quit_pressed() -> void:
	close()
	GameManager.change_scene(
		"res://ui/title_screen/title_screen.tscn"
	)

extends Control

## Title screen with animated title, menu buttons, and BGM.

signal new_game_pressed
signal continue_pressed
signal settings_pressed

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var menu_container: VBoxContainer = %MenuContainer
@onready var version_label: Label = %VersionLabel


func _ready() -> void:
	_connect_buttons()
	_setup_focus_navigation()
	_check_save_data()
	_animate_intro()
	new_game_button.grab_focus()


func _connect_buttons() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)


func _setup_focus_navigation() -> void:
	var buttons: Array[Button] = [
		new_game_button,
		continue_button,
		settings_button,
	]
	for i in buttons.size():
		if i > 0:
			buttons[i].focus_neighbor_top = buttons[i - 1].get_path()
		if i < buttons.size() - 1:
			buttons[i].focus_neighbor_bottom = buttons[i + 1].get_path()
	buttons[0].focus_neighbor_top = buttons[-1].get_path()
	buttons[-1].focus_neighbor_bottom = buttons[0].get_path()


func _check_save_data() -> void:
	continue_button.disabled = not SaveManager.has_save(0)


func _animate_intro() -> void:
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	menu_container.modulate.a = 0.0
	version_label.modulate.a = 0.0

	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.5)
	tween.tween_property(menu_container, "modulate:a", 1.0, 0.5)
	tween.tween_property(version_label, "modulate:a", 1.0, 0.3)
	tween.tween_callback(new_game_button.grab_focus)


func _on_new_game_pressed() -> void:
	new_game_pressed.emit()
	GameManager.change_scene(
		"res://scenes/overgrown_ruins/overgrown_ruins.tscn"
	)


func _on_continue_pressed() -> void:
	continue_pressed.emit()
	var data: Dictionary = SaveManager.load_save_data(0)
	if data.is_empty():
		return
	var equip_mgr: Node = get_node_or_null(
		"/root/EquipmentManager"
	)
	var quest_mgr: Node = get_node_or_null(
		"/root/QuestManager"
	)
	SaveManager.apply_save_data(
		data, PartyManager, InventoryManager, EventFlags,
		equip_mgr, quest_mgr,
	)
	var pos_data: Dictionary = data.get("player_position", {})
	var pos := Vector2(
		pos_data.get("x", 0.0),
		pos_data.get("y", 0.0),
	)
	SaveManager.set_pending_position(pos)
	var scene_path: String = data.get("scene_path", "")
	if scene_path.is_empty():
		return
	GameManager.change_scene(scene_path)


func _on_settings_pressed() -> void:
	settings_pressed.emit()

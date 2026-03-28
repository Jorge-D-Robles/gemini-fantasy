extends CanvasLayer
## The in-game pause menu.

var _is_open: bool = false

@onready var _background: ColorRect = $Background
@onready var _resume_btn: Button = $Background/Panel/VBox/ResumeButton
@onready var _quit_btn: Button = $Background/Panel/VBox/QuitButton


func _ready() -> void:
	_background.visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_resume_btn.pressed.connect(close)
	_quit_btn.pressed.connect(_quit_to_title)
	$Background/Panel/VBox/InventoryButton.pressed.connect(_open_inventory)
	$Background/Panel/VBox/QuestLogButton.pressed.connect(_open_quest_log)
	$Background/Panel/VBox/SettingsButton.pressed.connect(_open_settings)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _is_open:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()


func open() -> void:
	_is_open = true
	_background.visible = true
	get_tree().paused = true
	_resume_btn.grab_focus()


func close() -> void:
	_is_open = false
	_background.visible = false
	get_tree().paused = false


func _open_inventory() -> void:
	var inv := get_tree().get_first_node_in_group("inventory_screens")
	if inv:
		inv.visible = true


func _open_quest_log() -> void:
	var log_panel := get_tree().get_first_node_in_group("quest_logs")
	if log_panel:
		log_panel.visible = true
		log_panel.refresh()


func _open_settings() -> void:
	var settings_scene := preload("res://ui/settings/settings_panel.tscn")
	var panel: PanelContainer = settings_scene.instantiate()
	add_child(panel)


func _quit_to_title() -> void:
	close()
	SceneManager.change_scene("res://ui/title_screen/title_screen.tscn")

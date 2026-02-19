extends Control

## Title screen with animated title, menu buttons, and BGM.

signal new_game_pressed
signal continue_pressed
signal settings_pressed

const UIHelpers = preload("res://ui/ui_helpers.gd")
const SP = preload("res://systems/scene_paths.gd")
const SettingsMenuScript = preload(
	"res://ui/settings_menu/settings_menu.gd"
)
const TITLE_BGM_PATH: String = "res://assets/music/Main Character.ogg"

var _settings_menu: Control = null

@onready var title_label: Label = %TitleLabel
@onready var subtitle_label: Label = %SubtitleLabel
@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var menu_container: VBoxContainer = %MenuContainer
@onready var version_label: Label = %VersionLabel


func _ready() -> void:
	_start_title_music()
	_connect_buttons()
	_setup_focus_navigation()
	_check_save_data()
	_animate_intro()
	new_game_button.grab_focus()


func _start_title_music() -> void:
	var bgm := load(TITLE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 0.0)
	else:
		push_warning("Title BGM not found: " + TITLE_BGM_PATH)


func _connect_buttons() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)


func _setup_focus_navigation() -> void:
	UIHelpers.setup_focus_wrap([
		new_game_button, continue_button, settings_button,
	])


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
	GameManager.change_scene(SP.OVERGROWN_RUINS)


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
	if _settings_menu != null:
		return
	_settings_menu = SettingsMenuScript.new()
	add_child(_settings_menu)
	_settings_menu.settings_menu_closed.connect(
		_on_settings_closed
	)


func _on_settings_closed() -> void:
	if _settings_menu != null:
		_settings_menu.queue_free()
		_settings_menu = null
	settings_button.grab_focus()

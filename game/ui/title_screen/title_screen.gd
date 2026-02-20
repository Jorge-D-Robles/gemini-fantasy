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
const UITheme = preload("res://ui/ui_theme.gd")
const TITLE_BGM_PATH: String = "res://assets/music/Welcoming Heart Piano.ogg"

const AREA_NAMES: Dictionary = {
	SP.ROOTHOLLOW: "Roothollow",
	SP.VERDANT_FOREST: "Verdant Forest",
	SP.OVERGROWN_RUINS: "Overgrown Ruins",
}

var _settings_menu: Control = null
var _save_label: Label = null

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
	var has_save: bool = SaveManager.has_save(0)
	continue_button.disabled = not has_save
	if has_save:
		var data: Dictionary = SaveManager.load_save_data(0)
		var summary: Dictionary = compute_save_summary(data)
		_show_save_label(summary)


func _show_save_label(summary: Dictionary) -> void:
	if _save_label != null:
		return
	var parts: Array[String] = []
	if not summary["location"].is_empty():
		parts.append(summary["location"])
	if not summary.get("playtime_str", "").is_empty():
		parts.append(summary["playtime_str"])
	if not summary["time_str"].is_empty():
		parts.append(summary["time_str"])
	if parts.is_empty():
		return
	_save_label = Label.new()
	_save_label.text = " — ".join(parts)
	_save_label.add_theme_font_size_override("font_size", 9)
	_save_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	_save_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_container.add_child(_save_label)
	menu_container.move_child(_save_label, continue_button.get_index() + 1)


## Returns {location: String, time_str: String, playtime_str: String}.
## Returns empty strings if the data is absent or the fields are missing.
static func compute_save_summary(save_data: Dictionary) -> Dictionary:
	if save_data.is_empty():
		return {"location": "", "time_str": "", "playtime_str": ""}
	var scene_path: String = save_data.get("scene_path", "")
	var location: String = AREA_NAMES.get(scene_path, "")
	var timestamp: int = int(save_data.get("timestamp", 0))
	var time_str: String = _format_save_timestamp(timestamp)
	var playtime_seconds: float = float(save_data.get("playtime_seconds", 0.0))
	var playtime_str: String = compute_playtime_str(playtime_seconds)
	return {"location": location, "time_str": time_str, "playtime_str": playtime_str}


## Formats playtime_seconds as "HH:MM". Returns "" for < 60 seconds.
static func compute_playtime_str(playtime_seconds: float) -> String:
	if playtime_seconds < 60.0:
		return ""
	var total_minutes: int = int(playtime_seconds) / 60
	var hours: int = total_minutes / 60
	var minutes: int = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]


static func _format_save_timestamp(unix_time: int) -> String:
	if unix_time <= 0:
		return ""
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time)
	const MONTHS: Array[String] = [
		"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
	]
	var month_idx: int = dt.get("month", 0)
	var month_str: String = MONTHS[month_idx] if month_idx in range(1, 13) else ""
	return "%02d %s, %02d:%02d" % [
		dt.get("day", 0),
		month_str,
		dt.get("hour", 0),
		dt.get("minute", 0),
	]


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
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
	new_game_pressed.emit()
	GameManager.change_scene(SP.OVERGROWN_RUINS)


func _on_continue_pressed() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
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
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
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

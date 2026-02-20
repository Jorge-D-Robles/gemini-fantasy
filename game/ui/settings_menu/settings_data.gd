class_name SettingsData
extends RefCounted

## Static utilities for audio settings persistence and volume math.
## Controls bus-level volume via AudioServer — independent of
## AudioManager's per-player volume tweens (crossfade, etc.).
##
## JSON schema (contract for T-0122/T-0128):
## {"version":1, "master_volume":N, "bgm_volume":N, "sfx_volume":N}

const SETTINGS_PATH := "user://settings.json"
const SETTINGS_VERSION := 1
const SILENT_DB := -80.0
const DEFAULT_VOLUME := 100

## Ordered list of game actions shown in the Controls section.
const CONTROL_ACTIONS: Array[String] = [
	"interact",
	"cancel",
	"menu",
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"run",
]

## Human-readable labels for each action name.
const ACTION_LABELS: Dictionary = {
	"interact": "Interact",
	"cancel": "Cancel",
	"menu": "Menu",
	"move_up": "Move Up",
	"move_down": "Move Down",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"run": "Run",
}


## Converts a 0-100 percent to decibels.
## 0% maps to SILENT_DB floor (not -INF). Values clamped to 0-100.
static func percent_to_db(percent: int) -> float:
	var clamped := clampi(percent, 0, 100)
	if clamped == 0:
		return SILENT_DB
	return linear_to_db(clamped / 100.0)


## Converts decibels back to a 0-100 percent integer.
static func db_to_percent(db: float) -> int:
	if db <= SILENT_DB:
		return 0
	return clampi(int(round(db_to_linear(db) * 100.0)), 0, 100)


## Sets an AudioServer bus volume from a 0-100 percent.
## Uses bus-level volume (NOT AudioManager.set_bgm_volume).
static func apply_volume(bus_name: String, percent: int) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		push_warning(
			"SettingsData: bus '%s' not found" % bus_name
		)
		return
	AudioServer.set_bus_volume_db(idx, percent_to_db(percent))


## Reads the current bus volume as a 0-100 percent.
static func get_bus_percent(bus_name: String) -> int:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return 100
	return db_to_percent(AudioServer.get_bus_volume_db(idx))


## Saves volume settings to the given path. Values clamped to 0-100.
static func save_settings_to(
	path: String, master: int, bgm: int, sfx: int,
) -> void:
	var data := {
		"version": SETTINGS_VERSION,
		"master_volume": clampi(master, 0, 100),
		"bgm_volume": clampi(bgm, 0, 100),
		"sfx_volume": clampi(sfx, 0, 100),
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))


## Loads volume settings from the given path.
## Returns defaults (all 100) if file missing or corrupt.
static func load_settings_from(path: String) -> Dictionary:
	var defaults := {
		"master_volume": 100,
		"bgm_volume": 100,
		"sfx_volume": 100,
	}
	if not FileAccess.file_exists(path):
		return defaults
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return defaults
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return defaults
	var data: Variant = json.data
	if data is not Dictionary:
		return defaults
	return {
		"master_volume": clampi(
			int(data.get("master_volume", 100)), 0, 100
		),
		"bgm_volume": clampi(
			int(data.get("bgm_volume", 100)), 0, 100
		),
		"sfx_volume": clampi(
			int(data.get("sfx_volume", 100)), 0, 100
		),
	}


## Convenience: save to the default path.
static func save_settings(
	master: int, bgm: int, sfx: int,
) -> void:
	save_settings_to(SETTINGS_PATH, master, bgm, sfx)


## Convenience: load from the default path.
static func load_settings() -> Dictionary:
	return load_settings_from(SETTINGS_PATH)


## Returns a human-readable description of what each slider controls.
## Returns "" for unrecognised slider IDs.
static func compute_slider_tooltip(slider_id: String) -> String:
	match slider_id:
		"master":
			return "Overall game volume — adjusts all audio simultaneously."
		"bgm":
			return "Background music volume — does not affect sound effects."
		"sfx":
			return "Sound effects volume — does not affect background music."
		_:
			return ""


## Loads saved settings and applies them to AudioServer buses.
## Call from AudioManager._ready() at startup.
static func apply_saved_settings() -> void:
	var s := load_settings()
	apply_volume("Master", s["master_volume"])
	apply_volume("BGM", s["bgm_volume"])
	apply_volume("SFX", s["sfx_volume"])


## Returns the display label for an action name.
## Unknown actions are title-cased from their snake_case name.
static func compute_action_label(action: String) -> String:
	if ACTION_LABELS.has(action):
		return ACTION_LABELS[action]
	return action.replace("_", " ").capitalize()


## Returns the primary keyboard key label for an action.
## Returns "—" if the action is unknown or has no keyboard binding.
static func compute_action_key_label(action: String) -> String:
	if not InputMap.has_action(action):
		return "—"
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	for event: InputEvent in events:
		if not event is InputEventKey:
			continue
		var key_event := event as InputEventKey
		if key_event.keycode != KEY_NONE:
			return OS.get_keycode_string(key_event.keycode)
		if key_event.physical_keycode != KEY_NONE:
			return OS.get_keycode_string(key_event.physical_keycode)
	return "—"


## Returns an ordered array of {label, key} dictionaries for display.
## Each entry represents one game action and its primary keyboard binding.
static func compute_control_bindings() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for action: String in CONTROL_ACTIONS:
		result.append({
			"label": compute_action_label(action),
			"key": compute_action_key_label(action),
		})
	return result

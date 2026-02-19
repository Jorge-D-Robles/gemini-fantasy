class_name PlaytestCapture
extends RefCounted

## Static utility for screenshot capture, log collection, and JSON report building.
## Not instantiated — use static methods directly.

const LABEL_PLACEHOLDER: String = "capture"


## Returns a zero-padded filename for a screenshot.
## Example: format_screenshot_filename(1, "initial_spawn") → "001_initial_spawn.png"
static func format_screenshot_filename(index: int, label: String) -> String:
	var safe_label := label if not label.is_empty() else LABEL_PLACEHOLDER
	return "%03d_%s.png" % [index, safe_label]


## Captures the current viewport as a PNG to output_dir/filename.
## Returns true on success.
static func capture(
	viewport: Viewport, output_dir: String, filename: String
) -> bool:
	if viewport == null:
		push_warning("PlaytestCapture: viewport is null")
		return false
	var image := viewport.get_texture().get_image()
	if image == null:
		push_warning("PlaytestCapture: viewport image is null")
		return false
	var path := output_dir.path_join(filename)
	var err := image.save_png(path)
	if err != OK:
		push_warning("PlaytestCapture: failed to save PNG to '%s'" % path)
		return false
	return true


## Builds the structured JSON report Dictionary.
## Parameters:
##   success        — whether the run completed without fatal errors
##   duration       — total runtime in seconds
##   scene_path     — the target scene res:// path
##   screenshots    — Array of {index, label, file} dicts
##   errors         — Array of error message strings
##   actions_done   — number of actions executed
##   actions_total  — total actions in config
##   final_state    — Dictionary of final game state snapshot
static func build_report(
	success: bool,
	duration: float,
	scene_path: String,
	screenshots: Array,
	errors: Array,
	actions_done: int,
	actions_total: int,
	final_state: Dictionary,
) -> Dictionary:
	return {
		"success": success,
		"duration_seconds": duration,
		"scene": scene_path,
		"screenshots": screenshots,
		"errors": errors,
		"warnings": [],
		"actions_completed": actions_done,
		"actions_total": actions_total,
		"final_state": final_state,
	}


## Collects a snapshot of the current game state for the report's final_state field.
## game_manager and party_manager may be null (returns safe defaults).
static func collect_final_state(
	game_manager: Node,
	party_manager: Node,
) -> Dictionary:
	var state: Dictionary = {
		"game_state": "UNKNOWN",
		"party_count": 0,
		"party_hp": {},
		"flags": [],
		"gold": 0,
		"player_position": {"x": 0.0, "y": 0.0},
	}

	if game_manager != null and game_manager.has_method("get") and \
			"current_state" in game_manager:
		state["game_state"] = str(game_manager.current_state)

	if party_manager != null and party_manager.has_method("get_active_party"):
		var party: Array = party_manager.get_active_party()
		state["party_count"] = party.size()

	return state


## Writes a Dictionary as a JSON file to the given path.
## Returns true on success.
static func write_json_report(path: String, report: Dictionary) -> bool:
	var json_string := JSON.stringify(report, "\t")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("PlaytestCapture: cannot open '%s' for writing" % path)
		return false
	file.store_string(json_string)
	file.close()
	return true


## Ensures the output directory exists (creates it if needed).
static func ensure_output_dir(dir_path: String) -> bool:
	if DirAccess.dir_exists_absolute(dir_path):
		return true
	var err := DirAccess.make_dir_recursive_absolute(dir_path)
	if err != OK:
		push_warning("PlaytestCapture: failed to create dir '%s'" % dir_path)
		return false
	return true

class_name PlaytestConfig
extends RefCounted

## Static utility for parsing and validating playtest runner configuration.
## Supports both JSON config files and inline CLI arguments.
## Not instantiated — use static methods directly.

const DEFAULT_TIMEOUT: float = 60.0
const DEFAULT_OUTPUT_DIR: String = "/tmp/playtest/"
const DEFAULT_VIEWPORT_WIDTH: int = 640
const DEFAULT_VIEWPORT_HEIGHT: int = 360


## Parses a JSON string into a config Dictionary.
## Returns {} on parse error.
static func parse_json(json_string: String) -> Dictionary:
	if json_string.is_empty():
		return {}
	var parsed := JSON.new()
	var err := parsed.parse(json_string)
	if err != OK:
		push_warning("PlaytestConfig: JSON parse error — " + parsed.get_error_message())
		return {}
	var result: Variant = parsed.get_data()
	if not result is Dictionary:
		push_warning("PlaytestConfig: JSON root must be an object.")
		return {}
	return result


## Parses CLI user args (OS.get_cmdline_user_args()) into a partial config Dictionary.
## Recognizes: --config=, --scene=, --party=, --flags=, --gold=, --output=,
##             --screenshot-after=, --spawn-point=
## Returns a partial config that callers merge with merge_defaults().
static func parse_cli_args(args: PackedStringArray) -> Dictionary:
	var result: Dictionary = {}
	var state: Dictionary = {}
	var options: Dictionary = {}
	var actions: Array = []

	for arg: String in args:
		if arg.begins_with("--config="):
			result["config_path"] = arg.trim_prefix("--config=")
		elif arg.begins_with("--scene="):
			result["scene"] = arg.trim_prefix("--scene=")
		elif arg.begins_with("--spawn-point="):
			result["spawn_point"] = arg.trim_prefix("--spawn-point=")
		elif arg.begins_with("--party="):
			var raw := arg.trim_prefix("--party=")
			state["party"] = Array(raw.split(","))
		elif arg.begins_with("--flags="):
			var raw := arg.trim_prefix("--flags=")
			state["flags"] = Array(raw.split(","))
		elif arg.begins_with("--gold="):
			state["gold"] = arg.trim_prefix("--gold=").to_int()
		elif arg.begins_with("--output="):
			options["output_dir"] = arg.trim_prefix("--output=")
		elif arg.begins_with("--screenshot-after="):
			var secs := arg.trim_prefix("--screenshot-after=").to_float()
			actions.append({"type": "wait", "seconds": secs})
			actions.append({"type": "screenshot", "label": "auto"})

	if not state.is_empty():
		result["state"] = state
	if not options.is_empty():
		result["options"] = options
	if not actions.is_empty():
		result["actions"] = actions

	return result


## Fills in default values for any missing options fields.
## Preserves all user-supplied values.
static func merge_defaults(config: Dictionary) -> Dictionary:
	var merged := config.duplicate(true)

	var options: Dictionary = merged.get("options", {})
	if not options.has("timeout_seconds"):
		options["timeout_seconds"] = DEFAULT_TIMEOUT
	if not options.has("output_dir"):
		options["output_dir"] = DEFAULT_OUTPUT_DIR
	if not options.has("viewport_width"):
		options["viewport_width"] = DEFAULT_VIEWPORT_WIDTH
	if not options.has("viewport_height"):
		options["viewport_height"] = DEFAULT_VIEWPORT_HEIGHT
	if not options.has("capture_on_error"):
		options["capture_on_error"] = true
	if not options.has("capture_interval_seconds"):
		options["capture_interval_seconds"] = 0.0
	if not options.has("disable_encounters"):
		options["disable_encounters"] = false
	if not options.has("disable_bgm"):
		options["disable_bgm"] = true
	merged["options"] = options

	if not merged.has("actions"):
		merged["actions"] = []
	if not merged.has("state"):
		merged["state"] = {}

	return merged


## Validates a config Dictionary.
## Returns an Array of error strings (empty = valid).
static func validate(config: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	if not config.has("scene"):
		errors.append("scene is required")
		return errors
	if not config["scene"] is String:
		errors.append("scene must be a string")
	return errors

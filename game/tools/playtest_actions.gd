class_name PlaytestActions
extends RefCounted

## Static registry and validator for playtest runner action types.
## Not instantiated — use static methods directly.

const VALID_DIRECTIONS: Array[String] = ["up", "down", "left", "right"]

const VALID_GAME_STATES: Array[String] = [
	"OVERWORLD",
	"BATTLE",
	"DIALOGUE",
	"MENU",
	"CUTSCENE",
]


## Returns the complete list of supported action type strings.
static func get_all_action_types() -> Array[String]:
	return [
		"wait",
		"screenshot",
		"move",
		"interact",
		"cancel",
		"menu",
		"advance_dialogue",
		"wait_dialogue",
		"select_choice",
		"trigger_battle",
		"wait_battle",
		"auto_play_battle",
		"wait_state",
		"set_flag",
		"log",
	]


## Validates a single action Dictionary.
## Returns an Array of error strings (empty = valid).
static func validate_action(action: Dictionary) -> Array[String]:
	var errors: Array[String] = []

	if not action.has("type"):
		errors.append("action missing 'type' field")
		return errors

	var action_type: String = action.get("type", "")
	if action_type not in get_all_action_types():
		errors.append("unknown action type '%s'" % action_type)
		return errors

	match action_type:
		"move":
			var direction: String = action.get("direction", "")
			if direction not in VALID_DIRECTIONS:
				errors.append(
					"move: direction '%s' must be one of %s"
					% [direction, str(VALID_DIRECTIONS)]
				)
		"select_choice":
			if not action.has("index"):
				errors.append("select_choice: 'index' field is required")
		"trigger_battle":
			if not action.has("enemies"):
				errors.append("trigger_battle: 'enemies' field is required")
			elif not (action["enemies"] is Array) or \
					(action["enemies"] as Array).is_empty():
				errors.append("trigger_battle: 'enemies' must be a non-empty array")
		"auto_play_battle":
			if action.has("enemies"):
				if not (action["enemies"] is Array) or \
						(action["enemies"] as Array).is_empty():
					errors.append(
						"auto_play_battle: 'enemies' must be a non-empty array if provided"
					)
		"set_flag":
			if not action.has("flag") or (action.get("flag", "") as String).is_empty():
				errors.append("set_flag: 'flag' field is required")
		"wait_state":
			if not action.has("state"):
				errors.append("wait_state: 'state' field is required")

	return errors


## Returns the input action name to press for button-type actions.
static func get_action_input_name(action_type: String) -> String:
	match action_type:
		"interact", "advance_dialogue":
			return "interact"
		"cancel":
			return "cancel"
		"menu":
			return "menu"
	return action_type

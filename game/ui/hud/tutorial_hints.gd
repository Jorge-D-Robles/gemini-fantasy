class_name TutorialHints
extends RefCounted

## Static utility for tutorial hint logic.
## Pure functions: determine which hint to show, get text, get flag name.

const FLAG_PREFIX: String = "tutorial_"

const HINTS: Dictionary = {
	"interact": "Press [Z] to talk to NPCs",
	"menu": "Press [Esc] to open the menu",
	"zone_travel": "Walk into the glowing marker to travel",
}


## Returns true if the hint should be shown (valid ID and flag not set).
static func should_show(hint_id: String, flags: Dictionary) -> bool:
	if not HINTS.has(hint_id):
		return false
	return not flags.get(FLAG_PREFIX + hint_id, false)


## Returns hint text for a known ID, or empty string for unknown.
static func get_hint_text(hint_id: String) -> String:
	return HINTS.get(hint_id, "")


## Returns the EventFlags flag name for a hint ID.
static func get_flag_name(hint_id: String) -> String:
	return FLAG_PREFIX + hint_id

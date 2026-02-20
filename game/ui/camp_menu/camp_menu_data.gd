class_name CampMenuData
extends RefCounted

## Static helpers for the camp menu UI.
## Pure logic — no scene or autoload dependencies.


## Returns the ordered list of camp menu option labels.
static func compute_menu_options() -> Array[String]:
	return ["Rest", "Leave Camp"]


## Returns the message shown after attempting to rest.
## healing_needed: true if any party member had depleted HP or EE.
static func compute_rest_message(healing_needed: bool) -> String:
	if healing_needed:
		return "The party rested and recovered fully."
	return "The party is already fully rested."


## Returns true if any entry has current_hp < max_hp or current_ee < max_ee.
## entries: Array of {current_hp, max_hp, current_ee, max_ee} Dictionaries.
static func compute_healing_needed(entries: Array[Dictionary]) -> bool:
	for entry: Dictionary in entries:
		if entry.get("current_hp", 0) < entry.get("max_hp", 0):
			return true
		if entry.get("current_ee", 0) < entry.get("max_ee", 0):
			return true
	return false

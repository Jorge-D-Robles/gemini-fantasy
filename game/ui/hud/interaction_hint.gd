class_name InteractionHint
extends RefCounted

## Static helper for the HUD interaction prompt widget.
## Computes the formatted key-label string shown when an interactable is nearby.
## All functions are static: pure logic, no scene dependency.


## Returns the formatted interaction hint text for the given input action.
## Format: "[KEY] Interact" where KEY is the first bound keyboard key.
## Falls back to "[ ] Interact" if the action is unknown or has no binding.
static func compute_interaction_hint_text(action_name: String) -> String:
	if action_name.is_empty() or not InputMap.has_action(action_name):
		return "[ ] Interact"
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	if events.is_empty():
		return "[ ] Interact"
	var key_label := _extract_key_label(events[0])
	if key_label.is_empty():
		return "[ ] Interact"
	return "[%s] Interact" % key_label


static func _extract_key_label(event: InputEvent) -> String:
	if not event is InputEventKey:
		return ""
	var key_event := event as InputEventKey
	if key_event.keycode != KEY_NONE:
		return OS.get_keycode_string(key_event.keycode)
	if key_event.physical_keycode != KEY_NONE:
		return OS.get_keycode_string(key_event.physical_keycode)
	return ""

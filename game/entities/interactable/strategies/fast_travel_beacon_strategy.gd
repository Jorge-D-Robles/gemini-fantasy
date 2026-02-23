class_name FastTravelBeaconStrategy
extends InteractionStrategy

## Unlocks a fast travel beacon and shows a confirmation message.
## Attach to an Interactable with one_time = false so the beacon
## can be re-interacted (the unlock only fires once).

@export var beacon_flag: String = ""
@export var beacon_name: String = ""


func execute(_owner: Node) -> void:
	var already: bool = EventFlags.has_flag(beacon_flag)
	if not already and not beacon_flag.is_empty():
		EventFlags.set_flag(beacon_flag)
	var msg: String = compute_unlock_text(beacon_name, already)
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", msg),
	]
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended


## Returns beacon activation text. Pure static helper for testability.
static func compute_unlock_text(
	name: String, already_unlocked: bool,
) -> String:
	if already_unlocked:
		return "Resonance Beacon: %s." % name
	return "Resonance Beacon: %s activated!" % name

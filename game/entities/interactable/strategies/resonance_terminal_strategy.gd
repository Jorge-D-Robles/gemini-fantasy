class_name ResonanceTerminalStrategy
extends InteractionStrategy

## Resonance terminal puzzle in the Overgrown Capital Research Quarter.
## Requires two Resonance Crystals (Market + Entertainment) to activate.
## On activation: removes both crystals, sets flag, shows dialogue.

const MARKET_CRYSTAL_ID: StringName = &"resonance_crystal_market"
const ENTERTAINMENT_CRYSTAL_ID: StringName = &"resonance_crystal_entertainment"
const FLAG_NAME: String = "research_terminal_activated"


## Returns true when both crystals are present in the items dictionary.
## items: Dictionary with StringName keys and int values (from InventoryManager).
static func compute_terminal_can_activate(items: Dictionary) -> bool:
	var has_market: bool = items.get(MARKET_CRYSTAL_ID, 0) > 0
	var has_entertainment: bool = items.get(ENTERTAINMENT_CRYSTAL_ID, 0) > 0
	return has_market and has_entertainment


## Activation dialogue — Kael inserts the crystals, terminal powers up.
static func compute_terminal_activation_lines() -> Array[String]:
	return [
		"Kael",
		"Two slots. Two frequencies. Let's see if this works.",
		"Iris",
		("The terminal is responding. Resonance frequencies locked —"
			+ " the path to the Palace District is unlocked."),
	]


## Message when the player is missing one or both crystals.
static func compute_terminal_missing_lines() -> Array[String]:
	return [
		"Iris",
		("This terminal requires two Resonance frequency crystals to activate."
			+ " One attuned to the Market District, one to the Entertainment District."),
	]


## Message when the terminal has already been activated.
static func compute_terminal_already_active_lines() -> Array[String]:
	return [
		"Kael",
		"The terminal is already active. The path ahead is open.",
	]


func execute(owner: Node) -> void:
	if EventFlags.has_flag(FLAG_NAME):
		_show_dialogue(compute_terminal_already_active_lines())
		await DialogueManager.dialogue_ended
		return

	var items: Dictionary = InventoryManager.get_all_items()
	if not compute_terminal_can_activate(items):
		_show_dialogue(compute_terminal_missing_lines())
		await DialogueManager.dialogue_ended
		return

	# Remove both crystals and activate
	InventoryManager.remove_item(MARKET_CRYSTAL_ID, 1)
	InventoryManager.remove_item(ENTERTAINMENT_CRYSTAL_ID, 1)
	EventFlags.set_flag(FLAG_NAME)

	if "has_been_used" in owner:
		owner.has_been_used = true

	_show_dialogue(compute_terminal_activation_lines())
	await DialogueManager.dialogue_ended


func _show_dialogue(raw_lines: Array[String]) -> void:
	var lines: Array[DialogueLine] = []
	var i := 0
	while i + 1 < raw_lines.size():
		lines.append(DialogueLine.create(raw_lines[i], raw_lines[i + 1]))
		i += 2
	if not lines.is_empty():
		DialogueManager.start_dialogue(lines)

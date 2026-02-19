class_name OpeningSequence
extends Node

## Opening story event: Kael discovers Lyra in the Overgrown Ruins.
## Triggered when the player enters the LyraDiscoveryZone.
## After the dialogue, Lyra joins the party.

signal sequence_completed

const FLAG_NAME: String = "opening_lyra_discovered"
const LYRA_DATA_PATH: String = "res://data/characters/lyra.tres"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var lines: Array[DialogueLine] = [
		DialogueLine.create("Kael", "What is this...? An Echo Fragment? But it feels... different."),
		DialogueLine.create("Lyra", "Please... can you hear me? I've been trapped here... so long..."),
		DialogueLine.create("Kael", "You're... conscious? I've never seen an Echo like you before."),
		DialogueLine.create("Lyra", "My name is Lyra. I was a researcher before the Severance. My memories fractured, but I held on."),
		DialogueLine.create("Lyra", "Something terrible is happening to the echoes. They're being drained... consumed."),
		DialogueLine.create("Kael", "I'll help you. Let's get out of these ruins first."),
	]

	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	# Add Lyra to the party
	var lyra_data := load(LYRA_DATA_PATH) as Resource
	if lyra_data:
		PartyManager.add_character(lyra_data)

	GameManager.pop_state()
	sequence_completed.emit()

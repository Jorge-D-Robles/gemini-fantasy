class_name OpeningSequence
extends Node

## Opening story event: Kael discovers Lyra in the Overgrown Ruins.
## Triggered when the player enters the LyraDiscoveryZone.
## Dialogue matches Chapter 1, Scene 5 ("The Anomaly") of the story
## script (docs/story/act1/01-the-collector.md). After the dialogue,
## Lyra joins the party.

signal sequence_completed

const FLAG_NAME: String = "opening_lyra_discovered"
const LYRA_DATA_PATH: String = "res://data/characters/lyra.tres"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var lines: Array[DialogueLine] = _build_dialogue()

	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	# Add Lyra to the party
	var lyra_data := load(LYRA_DATA_PATH) as Resource
	if lyra_data:
		PartyManager.add_character(lyra_data)

	GameManager.pop_state()
	sequence_completed.emit()


func _build_dialogue() -> Array[DialogueLine]:
	return [
		# Kael approaches — something unusual
		DialogueLine.create(
			"Kael",
			"This isn't a memory loop. Memory loops are simple"
			+ " -- one emotion, one moment, repeating."
		),
		DialogueLine.create(
			"Kael",
			"This sounds like... a conversation."
		),

		# Discovery of the fragment
		DialogueLine.create(
			"Kael",
			"What is this? The chromatic shifts are all wrong."
			+ " Blue to violet to white and back, like it's..."
			+ " breathing."
		),
		DialogueLine.create(
			"Kael",
			"The emotional register is layered. Contentment and"
			+ " anxiety and curiosity all at once. Echoes don't"
			+ " do that."
		),

		# Attempt to collect — fragment resists
		DialogueLine.create(
			"Kael",
			"Okay. Easy does it."
		),
		DialogueLine.create(
			"Kael",
			"...! It flared. It pushed back. That's -- Echoes"
			+ " don't resist collection."
		),

		# Lyra speaks — the moment that changes everything
		DialogueLine.create(
			"Lyra",
			"...can you hear me?"
		),
		DialogueLine.create(
			"Kael",
			"..."
		),
		DialogueLine.create(
			"Kael",
			"What did you just say?"
		),
		DialogueLine.create(
			"Lyra",
			"You can hear me. Oh-- I wasn't sure anyone"
			+ " would. It's been so long."
		),

		# Kael's shock and analysis
		DialogueLine.create(
			"Kael",
			"That's not possible. Echoes are recordings."
			+ " They don't have present tense."
		),
		DialogueLine.create(
			"Kael",
			"But you did. Didn't you?"
		),

		# Kael touches the fragment — sensory flash
		DialogueLine.create(
			"Kael",
			"When I touched it, I felt something. Old paper."
			+ " A lab coat. A city that doesn't exist anymore."
			+ " A heartbeat. Not mine."
		),

		# Lyra reveals herself
		DialogueLine.create(
			"Lyra",
			"My name is Lyra. I was a researcher, before the"
			+ " Severance. My memories fractured when the world"
			+ " broke, but I held on."
		),
		DialogueLine.create(
			"Lyra",
			"Most of what I was scattered. But the core --"
			+ " the part that thinks, that remembers being a"
			+ " person -- I kept that."
		),

		# The warning
		DialogueLine.create(
			"Lyra",
			"Something terrible is happening. The other echoes"
			+ " -- the fragments -- they're being drained."
			+ " Consumed. Someone is harvesting them."
		),
		DialogueLine.create(
			"Kael",
			"Harvesting echoes? For what?"
		),
		DialogueLine.create(
			"Lyra",
			"I don't know yet. But it's getting worse. I can"
			+ " feel them disappearing. Voices going quiet, one"
			+ " by one."
		),

		# Kael's resolve
		DialogueLine.create(
			"Kael",
			"I've spent years collecting memories that other"
			+ " hunters would purge. Hundreds of echoes."
			+ " Someone's past deserves to be remembered."
		),
		DialogueLine.create(
			"Kael",
			"If someone's destroying them... I can't just"
			+ " walk away from that."
		),
		DialogueLine.create(
			"Lyra",
			"You'd help me? You don't even know what I am."
		),
		DialogueLine.create(
			"Kael",
			"You're a person who's been alone for a very long"
			+ " time. That's enough for now."
		),
		DialogueLine.create(
			"Kael",
			"Come on. Let's get out of these ruins. I know"
			+ " someone who might understand what you are."
		),
	]

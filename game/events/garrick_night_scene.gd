class_name GarrickNightScene
extends Node

## Night scene at Roothollow before departure to the Overgrown Capital.
## Garrick reflects on meeting Lyra — the shield, what she is, and quiet
## observations about Kael and Iris. Triggers from Roothollow inn after
## garrick_met_lyra flag. Implements the optional camp snippets from
## docs/story/act1/04-old-iron.md.
## Emotional beat: A deserter ex-Shepherd processes what a thinking Echo means
## for forty years of belief, and quietly places his trust in his new party.

signal sequence_completed

const FLAG_NAME: String = "garrick_night_scene"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var lines: Array[DialogueLine] = _build_dialogue()

	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()


func _build_dialogue() -> Array[DialogueLine]:
	return [
		# Kael finds Garrick awake late
		DialogueLine.create(
			"Kael",
			"Can't sleep?",
		),
		DialogueLine.create(
			"Garrick",
			"Four hours is enough. Old habit.",
		),
		DialogueLine.create(
			"Kael",
			"You've been quiet since we met Lyra.",
		),
		# Garrick processing what a Conscious Echo means
		DialogueLine.create(
			"Garrick",
			"Forty years being told Echoes are just residue."
			+ " Not souls. Just recordings of the dead."
			+ " Then she asks me if I'm carrying guilt."
			+ " And I am.",
		),
		# The shield — his past made physical
		DialogueLine.create(
			"Garrick",
			"I've carried this shield for thirty-six years."
			+ " Pre-Severance alloy -- they don't make metal"
			+ " like this anymore. I scratched the Shepherd"
			+ " crest off when I left the order.",
		),
		DialogueLine.create(
			"Garrick",
			"But the metal remembers the shape, if you look"
			+ " close enough. Scars don't really go away."
			+ " You just learn to live with what they used to be.",
		),
		DialogueLine.create(
			"Kael",
			"That's a heavy thing to carry.",
		),
		# Garrick's quiet observations about the party
		DialogueLine.create(
			"Garrick",
			"You remind me of someone."
			+ " Too kind for the world you live in."
			+ " Don't let anyone tell you that's a weakness.",
		),
		DialogueLine.create(
			"Garrick",
			"And Iris -- she's angry. Good."
			+ " Anger with direction is a powerful thing."
			+ " Keep her pointed at something that deserves it.",
		),
		# The scene's quiet close
		DialogueLine.create(
			"Garrick",
			"Get some rest. Dawn comes early.",
		),
	]

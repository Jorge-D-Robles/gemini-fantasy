class_name GarrickMeetsLyra
extends Node

## Garrick meets Lyra for the first time in the Overgrown Ruins.
## Triggered when the player revisits the preserved room after Garrick
## has joined the party. Compresses Chapter 4, Scene 5 ("Meeting Lyra")
## from docs/story/act1/04-old-iron.md.
## Emotional peak: a man who spent decades destroying Echoes asks the
## first Conscious Echo he meets if she is in pain.

signal sequence_completed

const FLAG_NAME: String = "garrick_met_lyra"


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
		# Lyra materializes and immediately reads Garrick
		DialogueLine.create(
			"Lyra",
			"You're looking at me like I'm a theological"
			+ " problem.",
		),
		DialogueLine.create(
			"Garrick",
			"...You are.",
		),
		DialogueLine.create(
			"Lyra",
			"I'm also a physicist. We're more interesting.",
		),

		# Garrick's confession — forty years of Shepherd teaching
		DialogueLine.create(
			"Garrick",
			"I was a Shepherd, ma'am. For forty years. We"
			+ " were taught that Echoes are recordings."
			+ " Residue. Not souls. You're... not what I"
			+ " was taught.",
		),
		DialogueLine.create(
			"Lyra",
			"You're the first ex-Shepherd I've spoken to."
			+ " In three hundred years.",
		),

		# Garrick cuts to the practical
		DialogueLine.create(
			"Garrick",
			"What do you need from us?",
		),
		DialogueLine.create(
			"Lyra",
			"My fragments. Scattered in the Overgrown"
			+ " Capital, maybe beyond. Each one contains"
			+ " memories, knowledge, pieces of who I am."
			+ " Including something I sealed away about"
			+ " the Severance.",
		),

		# Garrick sees the full picture
		DialogueLine.create(
			"Garrick",
			"And the Initiative wants to use you. The"
			+ " Shepherds would want to destroy you. To"
			+ " them, a thinking Echo is the worst kind"
			+ " of blasphemy.",
		),
		DialogueLine.create(
			"Lyra",
			"And what do you want?",
		),

		# The pivotal question
		DialogueLine.create(
			"Garrick",
			"To know if you're in pain.",
		),

		# Lyra's answer — the connecting moment
		DialogueLine.create(
			"Lyra",
			"...Yes. Sometimes. The fragmentation is like"
			+ " trying to think through gaps. Whole rooms"
			+ " in your mind are dark, and you know"
			+ " something should be there. It's not"
			+ " physical pain. It's... absence.",
		),
		DialogueLine.create(
			"Garrick",
			"...Absence. Yes. I know something about"
			+ " that.",
		),

		# Kael bridges the moment
		DialogueLine.create(
			"Kael",
			"We'll get her fragments back. All of them.",
		),

		# Garrick's commitment
		DialogueLine.create(
			"Garrick",
			"Then we get your pieces back. Nobody should"
			+ " live with that kind of empty if there's a"
			+ " way to fill it.",
		),
	]

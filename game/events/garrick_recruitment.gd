class_name GarrickRecruitment
extends Node

## Garrick recruitment event in Roothollow.
## Triggered when the player talks to Garrick NPC after certain conditions.
## Dialogue adapts Chapter 4, Scene 4 ("The Proposition") with compressed
## Scene 2 elements from docs/story/act1/04-old-iron.md.
## After the dialogue, Garrick joins the party.

signal sequence_completed

const FLAG_NAME: String = "garrick_recruited"
const GARRICK_DATA_PATH: String = "res://data/characters/garrick.tres"
const GARRICK_QUEST_PATH: String = "res://data/quests/garrick_three_burns.tres"
const GARRICK_BGM_PATH: String = "res://assets/music/Weight of the Shield.ogg"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	AudioManager.push_bgm()
	var garrick_bgm := load(GARRICK_BGM_PATH) as AudioStream
	if garrick_bgm:
		AudioManager.play_bgm(garrick_bgm, 1.0)
	else:
		push_warning("Garrick BGM not found: " + GARRICK_BGM_PATH)

	var lines: Array[DialogueLine] = _build_dialogue()

	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	# Garrick joins party
	var garrick_data := load(GARRICK_DATA_PATH) as Resource
	if garrick_data:
		PartyManager.add_character(garrick_data)

	# Auto-accept personal quest breadcrumb
	if compute_should_auto_accept_garrick_quest(EventFlags.get_all_flags()):
		var quest := load(GARRICK_QUEST_PATH) as Resource
		if quest:
			QuestManager.accept_quest(quest)

	AudioManager.pop_bgm(1.5)
	GameManager.pop_state()
	sequence_completed.emit()


## Returns true if the personal quest breadcrumb should be auto-accepted.
## Called after recruitment so garrick_recruited flag is already set.
static func compute_should_auto_accept_garrick_quest(flags: Dictionary) -> bool:
	return flags.get("garrick_recruited", false)


# Iris is assumed to be in party at this point (iris_recruited flag
# prerequisite in the story flow — Chapter 3 before Chapter 4).
func _build_dialogue() -> Array[DialogueLine]:
	return [
		# Garrick at the shrine — slow, deliberate
		DialogueLine.create(
			"Garrick",
			"Your shrine. Your village?",
		),
		DialogueLine.create(
			"Kael",
			"More or less. I'm Kael. The villagers said"
			+ " someone was using the spring.",
		),

		# Iris spots the scratched shield emblem
		DialogueLine.create(
			"Iris",
			"That shield. The scratched-out emblem."
			+ " That's a Shepherds of Silence crest"
			+ " underneath.",
		),
		DialogueLine.create(
			"Kael",
			"He scratched it out, Iris.",
		),

		# Garrick's identity — former Shield-Bearer
		DialogueLine.create(
			"Garrick",
			"Garrick Thorne. Shield-Bearer for the"
			+ " Shepherds of Silence. I left. A long"
			+ " time ago.",
		),
		DialogueLine.create(
			"Garrick",
			"Came here looking for a purification spring."
			+ " Crystal corruption. Slow, from years of"
			+ " handling contaminated Resonance materials."
			+ " The springs used to slow the progression.",
		),

		# Confession — what he did
		DialogueLine.create(
			"Garrick",
			"...Burned villages. Destroyed crystal caches."
			+ " Told myself it was for the greater good.",
		),
		DialogueLine.create(
			"Garrick",
			"I stopped believing that eleven years ago."
			+ " A child's laughter, trapped in a crystal."
			+ " Not dangerous. Just... happy. And my"
			+ " commanding officer ordered me to destroy it.",
		),
		DialogueLine.create(
			"Garrick",
			"I destroyed it. Walked out the next day."
			+ " Scratched the crest off my shield. Kept"
			+ " walking.",
		),

		# Kael tells Garrick about Lyra
		DialogueLine.create(
			"Kael",
			"Garrick. We found something in the ruins."
			+ " A conscious Echo. A real one -- a woman"
			+ " named Lyra who was a scientist before the"
			+ " Severance.",
		),
		DialogueLine.create(
			"Garrick",
			"...A conscious Echo.",
		),
		DialogueLine.create(
			"Kael",
			"Her fragments are scattered in the Overgrown"
			+ " Capital. We need to get them before the"
			+ " Initiative does.",
		),

		# Garrick's decision
		DialogueLine.create(
			"Garrick",
			"I spent forty years destroying things."
			+ " Crystals. Villages. My own faith. Maybe"
			+ " it's time I protected something instead.",
		),

		# Conditions
		DialogueLine.create(
			"Garrick",
			"I'll come. But I protect the group. I put"
			+ " myself between you and whatever comes."
			+ " That's not negotiable.",
		),
		DialogueLine.create(
			"Kael",
			"Done.",
		),
		DialogueLine.create(
			"Iris",
			"...Done.",
		),

		# Closing beat — honey cakes callback
		DialogueLine.create(
			"Garrick",
			"Then let's move. Daylight's burning."
			+ " ...Tell Petra the honey cakes are good.",
		),
	]

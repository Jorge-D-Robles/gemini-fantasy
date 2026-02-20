class_name NyxIntroduction
extends Node

## Chapter 6 Nyx introduction — "Born from Nothing."
## Fires once on entering Verdant Forest after the party has visited the
## Overgrown Capital and collected Lyra's Fragment 2. Compresses Scenes 1-3
## from docs/story/act1/06-born-from-nothing.md:
##   Scene 1: The Border — Resonance spike, something watches, a giggle.
##   Scene 2: First Contact — Nyx appears, introduces themselves, reads Garrick.
##   Scene 3: Condensed debate — Kael invites Nyx; wanting is okay.
## Sets nyx_introduction_seen and nyx_met flags.

signal sequence_completed

const FLAG_NAME: String = "nyx_introduction_seen"
const NYX_MET_FLAG: String = "nyx_met"
const NYX_BGM_PATH: String = "res://assets/music/What Am I, Nyx_.ogg"
const NYX_CHARACTER_PATH: String = "res://data/characters/nyx.tres"


## Returns true when the event is eligible to fire:
##   - garrick_recruited flag is set
##   - lyra_fragment_2_collected flag is set
##   - nyx_introduction_seen flag is NOT set
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("garrick_recruited", false):
		return false
	if not flags.get("lyra_fragment_2_collected", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Returns the ~23-line introduction dialogue compressed from Scenes 1-3.
static func compute_nyx_intro_lines() -> Array[DialogueLine]:
	return [
		# Scene 1: The Border
		DialogueLine.create(
			"Iris",
			"Resonance levels are spiking. We're near"
			+ " the Hollows border.",
		),
		DialogueLine.create(
			"Garrick",
			"I can feel it. The crystals in my arms"
			+ " are responding. Pulsing.",
		),
		DialogueLine.create(
			"Garrick",
			"Something's watching us.",
		),
		DialogueLine.create(
			"Kael",
			"Did you—",
		),
		DialogueLine.create(
			"Iris",
			"A sound inside my skull. Yes.",
		),
		DialogueLine.create(
			"Garrick",
			"...Yes.",
		),

		# Scene 2: First Contact — Nyx steps out
		DialogueLine.create(
			"Nyx",
			"Oh! You're loud. All three of you."
			+ " So much noise inside.",
		),
		DialogueLine.create(
			"Garrick",
			"...What are you?",
		),
		DialogueLine.create(
			"Nyx",
			"I don't know. Is that an important question?"
			+ " You all seem to know what you are.",
		),
		DialogueLine.create(
			"Nyx",
			"You're the loudest. Inside you there's"
			+ " a sound like all the sounds. Every sound"
			+ " that ever was, very far away.",
		),
		DialogueLine.create(
			"Kael",
			"What do you mean?",
		),
		DialogueLine.create(
			"Nyx",
			"You're shaped like the other two."
			+ " But inside you're shaped like"
			+ " that." ,
		),
		DialogueLine.create(
			"Nyx",
			"The place that doesn't have edges."
			+ " Where everything is all the other things"
			+ " at the same time. I walked out and"
			+ " the trees were here. I thought:"
			+ " this is new. I want to see more.",
		),
		DialogueLine.create(
			"Nyx",
			"Your sadness surprises me. It's so big."
			+ " Why do you carry it all at once instead"
			+ " of putting some down?",
		),
		DialogueLine.create(
			"Garrick",
			"...Some things you can't put down.",
		),
		DialogueLine.create(
			"Nyx",
			"Why not? In the other place, nothing weighs"
			+ " anything. You can let go of anything."
			+ " You just... open your hands.",
		),
		DialogueLine.create(
			"Nyx",
			"I'm sorry. Did I hurt you?",
		),
		DialogueLine.create(
			"Garrick",
			"No. No, you didn't hurt me. You just saw"
			+ " something I try to keep hidden."
			+ " That's different from hurting.",
		),

		# Scene 3: Condensed — joining the party
		DialogueLine.create(
			"Kael",
			"Nyx. Do you want to come with us?",
		),
		DialogueLine.create(
			"Nyx",
			"Yes! You're going places and seeing things."
			+ " I want to see things.",
		),
		DialogueLine.create(
			"Nyx",
			"But... is that okay? To want things?"
			+ " It feels strange. Like a new organ.",
		),
		DialogueLine.create(
			"Kael",
			"Wanting things is... human.",
		),
		DialogueLine.create(
			"Nyx",
			"But I'm not human.",
		),
		DialogueLine.create(
			"Kael",
			"Neither am I. Not entirely."
			+ " And wanting things is still okay.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	EventFlags.set_flag(NYX_MET_FLAG)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	AudioManager.push_bgm()
	var nyx_bgm := load(NYX_BGM_PATH) as AudioStream
	if nyx_bgm:
		AudioManager.play_bgm(nyx_bgm, 1.0)
	else:
		push_warning("Nyx BGM not found: " + NYX_BGM_PATH)

	var lines: Array[DialogueLine] = compute_nyx_intro_lines()
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	var nyx_data := load(NYX_CHARACTER_PATH) as CharacterData
	if nyx_data:
		PartyManager.add_character(nyx_data)
	else:
		push_warning("NyxIntroduction: could not load " + NYX_CHARACTER_PATH)

	AudioManager.pop_bgm(1.5)
	GameManager.pop_state()
	sequence_completed.emit()

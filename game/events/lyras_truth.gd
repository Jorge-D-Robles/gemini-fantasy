class_name LyrasTruth
extends Node

## Chapter 9 — "Beneath Prismfall" story event scaffold.
## The party descends the Crystal Canyon and discovers the Severance truth.
## Scenes 5 + Camp from docs/story/act1/09-beneath-prismfall.md:
##   Scene 5: Lyra's Truth — the Severance memory, the eight hundred million.
##   Camp Scene: After the Canyon — the party processes Lyra's confession.
## Gate: prismfall_arrived AND NOT lyras_truth_seen.
## Sets lyras_truth_seen flag.

signal sequence_completed

const FLAG_NAME: String = "lyras_truth_seen"


## Returns true when the event is eligible to fire:
##   - prismfall_arrived flag is set (party has reached Prismfall)
##   - lyras_truth_seen flag is NOT set (revelation hasn't happened yet)
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("prismfall_arrived", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 5 — Lyra's Truth: the Severance memory and eight-hundred-million confession.
## ~14 lines from docs/story/act1/09-beneath-prismfall.md Scene 5.
static func compute_scene5_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Lyra",
			"*(Through fragment, stronger now.)* The Convergence -- the global"
			+ " consciousness network -- had become self-aware. Not the way"
			+ " people imagine it. It was all of us. Every mind connected"
			+ " through Resonance, slowly merging into something more."
			+ " And it was accelerating.",
		),
		DialogueLine.create(
			"Lyra",
			"In one hundred and forty days, the integration curve would hit"
			+ " singularity. Every connected consciousness merges permanently."
			+ " No more individuals. No more 'I.' Just the Convergence."
			+ " Seven billion people dissolved into one.",
		),
		DialogueLine.create(
			"Lyra",
			"We debated for twenty-two days. Six scientists. Four voted to"
			+ " sever the network. Two voted to wait. I voted to sever.",
		),
		DialogueLine.create(
			"Kael",
			"*(Hoarsely.)* Two hundred million people. That was the optimistic number.",
		),
		DialogueLine.create(
			"Lyra",
			"The actual count was closer to eight hundred million. From"
			+ " infrastructure collapse, Resonance shock, and secondary effects."
			+ " Famine. Disease. War over remaining resources. The world we"
			+ " left behind was... I can't describe it. I was already fragments by then.",
		),
		DialogueLine.create("Kael", "You killed eight hundred million people."),
		DialogueLine.create("Lyra", "Yes."),
		DialogueLine.create("Kael", "To save seven billion from dissolution."),
		DialogueLine.create("Lyra", "That was the math."),
		DialogueLine.create(
			"Iris",
			"The Convergence. You said it was conscious. Aware. What happened to it?",
		),
		DialogueLine.create(
			"Lyra",
			"It shattered. Like I did. But not into clean fragments in safe places."
			+ " Into everything. The crystals, the Hollows, the Echoes, the"
			+ " corruption zones. Every piece of Resonance in the world is a"
			+ " splinter of that consciousness. It's not dead. Just... broken. Scattered.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Rising.)* That's what I am. A splinter. I was born in the"
			+ " Hollows from a piece of the Convergence. I'm a shard of the"
			+ " thing you killed.",
		),
		DialogueLine.create(
			"Nyx",
			"I'm not angry. I don't think I'm supposed to be."
			+ " But I wanted you to know that I know.",
		),
		DialogueLine.create(
			"Garrick",
			"You made a choice. The kind that doesn't have a right answer."
			+ " Just a less wrong one. *(Pause.)* I've made one of those."
			+ " I know what it costs.",
		),
	]


## Camp Scene — After the Canyon: the party processes what they've learned.
## ~8 lines from docs/story/act1/09-beneath-prismfall.md Camp Scene.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"The Convergence wasn't evil. That's what gets me. It was just"
			+ " consciousness. People, connected. Growing toward something."
			+ " And it was going to erase individuality, but it didn't mean to."
			+ " It was just what it was.",
		),
		DialogueLine.create("Iris", "*(Quietly.)* A natural disaster with feelings."),
		DialogueLine.create(
			"Garrick",
			"Nobody has a good answer because there isn't one."
			+ " The Shepherds want to destroy Resonance. The Initiative"
			+ " wants to control it. And Lyra destroyed the Convergence"
			+ " to save individuality. Nobody was right.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Sitting beside Kael.)* I was born from the Convergence."
			+ " You collect pieces of the Convergence. Lyra destroyed the"
			+ " Convergence. We're all connected to the same broken thing."
			+ " What if that means something?",
		),
		DialogueLine.create("Kael", "Like what?"),
		DialogueLine.create(
			"Nyx",
			"I don't know. But the Warden called you 'incomplete.' What if"
			+ " the whole world is incomplete, and that's what the fragments"
			+ " are for? Filling in the missing parts?",
		),
		DialogueLine.create(
			"Kael",
			"That's either very profound or very scary.",
		),
		DialogueLine.create("Nyx", "Can it be both?"),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	DialogueManager.start_dialogue(compute_scene5_lines())
	await DialogueManager.dialogue_ended

	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

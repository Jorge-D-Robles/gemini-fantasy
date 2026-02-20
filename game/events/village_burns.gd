class_name VillageBurns
extends Node

## Chapter 7 — "A Village Burns" story event scaffold.
## The party returns to Roothollow and finds the Shepherds of Silence
## conducting a regional purge. Scenes 1-2 from
## docs/story/act1/07-a-village-burns.md:
##   Scene 1: Coming Home — the party sees smoke and runs.
##   Scene 2: The Battle — pre-fight + Shepherd Commander Sera confrontation.
## Gate: lyra_fragment_2_collected AND nyx_met AND NOT village_burns_seen.
## Sets village_burns_seen and roothollow_burned flags.

signal sequence_completed

const FLAG_NAME: String = "village_burns_seen"
const ROOTHOLLOW_FLAG: String = "roothollow_burned"


## Returns true when the event is eligible to fire:
##   - lyra_fragment_2_collected flag is set
##   - nyx_met flag is set
##   - village_burns_seen flag is NOT set
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("lyra_fragment_2_collected", false):
		return false
	if not flags.get("nyx_met", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 1 — Coming Home: the party approaches Roothollow and sees it burning.
## ~10 lines compressed from docs/story/act1/07-a-village-burns.md Scene 1.
static func compute_scene1_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"*(Stopping mid-stride.)* That's not the sun.",
		),
		DialogueLine.create(
			"Garrick",
			"*(Already moving.)* Fire. Large. Northeast.",
		),
		DialogueLine.create(
			"Iris",
			"That's the direction of--",
		),
		DialogueLine.create(
			"Kael",
			"*(Running.)* Roothollow.",
		),
		DialogueLine.create(
			"Kael",
			"*(Voice breaking.)* No. No, no, no--",
		),
		DialogueLine.create(
			"Garrick",
			"*(Firm.)* Focus. How many Shepherds?",
		),
		DialogueLine.create(
			"Kael",
			"Eight-- ten. Maybe twelve. Spread across the mid-level."
			+ " The canopy level isn't burning yet.",
		),
		DialogueLine.create(
			"Iris",
			"Standard Shepherd purge pattern. Destroy crystal"
			+ " infrastructure first, then move to residences."
			+ " They're not trying to kill people -- they're destroying"
			+ " the village's ability to function.",
		),
		DialogueLine.create(
			"Garrick",
			"That's how it starts. \"We're only destroying the crystals.\""
			+ " Then someone resists, and it becomes something worse.",
		),
		DialogueLine.create(
			"Garrick",
			"I know this. I've done this. From the other side."
			+ " Not again.",
		),
	]


## Scene 2 — The Battle: Shepherd Commander Sera confrontation mid-fight.
## ~12 lines from docs/story/act1/07-a-village-burns.md Scene 2.
static func compute_scene2_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Shepherd Commander (Sera)",
			"...Garrick Thorne.",
		),
		DialogueLine.create(
			"Garrick",
			"Sera.",
		),
		DialogueLine.create(
			"Sera",
			"Shield-Bearer. Twelve years gone. We searched for you.",
		),
		DialogueLine.create(
			"Garrick",
			"I wasn't hiding.",
		),
		DialogueLine.create(
			"Sera",
			"No. You were wandering. Like a man without purpose."
			+ " *(She stares at Nyx.)* And now you fight"
			+ " for crystal-addled villagers alongside an Initiative deserter"
			+ " and a... what *is* that?",
		),
		DialogueLine.create(
			"Nyx",
			"I'm Nyx. Is that your purpose? Burning people's homes?",
		),
		DialogueLine.create(
			"Sera",
			"Abomination. *(To Garrick.)* You've fallen further than I thought,\n"
			+ " old friend.",
		),
		DialogueLine.create(
			"Garrick",
			"You've risen higher. Commander now."
			+ " *(Beat.)* How many villages, Sera?",
		),
		DialogueLine.create(
			"Sera",
			"Enough to save the souls inside them.",
		),
		DialogueLine.create(
			"Garrick",
			"Did you save Willowmere?",
		),
		DialogueLine.create(
			"Sera",
			"*(Goes still.)*",
		),
		DialogueLine.create(
			"Garrick",
			"That's what I thought.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	EventFlags.set_flag(ROOTHOLLOW_FLAG)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	DialogueManager.start_dialogue(compute_scene1_lines())
	await DialogueManager.dialogue_ended

	DialogueManager.start_dialogue(compute_scene2_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

class_name VillageBurns
extends Node

## Chapter 7 — "A Village Burns" full event.
## The party returns to Roothollow and finds the Shepherds of Silence
## conducting a regional purge.
##   Scene 1: Coming Home — the party sees smoke and runs.
##   Scene 2: The Battle — Shepherd Commander Sera confrontation.
##   Scene 3: Aftermath — Elder Morin, consequences, decision to leave.
##   Scene 4: Leaving Home — goodbyes to Roothollow NPCs.
##   Camp: Night After — Kael/Iris emotional scene.
## Gate: lyra_fragment_2_collected AND nyx_met AND NOT village_burns_seen.
## Sets village_burns_seen, roothollow_burned, and roothollow_battle_choice flags.

signal sequence_completed

const FLAG_NAME: String = "village_burns_seen"
const ROOTHOLLOW_FLAG: String = "roothollow_burned"
const BATTLE_CHOICE_FLAG: String = "roothollow_battle_choice"

enum BattleChoice {
	SAVE_VILLAGERS,
	ATTACK_SHEPHERDS,
	SPLIT_PARTY,
}


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
static func compute_scene1_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"That's not the sun.",
		),
		DialogueLine.create(
			"Garrick",
			"Fire. Large. Northeast.",
		),
		DialogueLine.create(
			"Iris",
			"That's the direction of--",
		),
		DialogueLine.create(
			"Kael",
			"Roothollow.",
		),
		DialogueLine.create(
			"Kael",
			"No. No, no, no--",
		),
		DialogueLine.create(
			"Garrick",
			"Focus. How many Shepherds?",
		),
		DialogueLine.create(
			"Kael",
			"Eight-- ten. Maybe twelve. Spread across"
			+ " the mid-level. The canopy level isn't"
			+ " burning yet.",
		),
		DialogueLine.create(
			"Iris",
			"Standard Shepherd purge pattern. Destroy"
			+ " crystal infrastructure first, then move"
			+ " to residences.",
		),
		DialogueLine.create(
			"Garrick",
			"That's how it starts. Then someone resists,"
			+ " and it becomes something worse.",
		),
		DialogueLine.create(
			"Garrick",
			"I know this. I've done this. From the"
			+ " other side. Not again.",
		),
	]


## Scene 2 — Shepherd Commander Sera confrontation.
static func compute_scene2_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Sera",
			"...Garrick Thorne.",
		),
		DialogueLine.create(
			"Garrick",
			"Sera.",
		),
		DialogueLine.create(
			"Sera",
			"Shield-Bearer. Twelve years gone."
			+ " We searched for you.",
		),
		DialogueLine.create(
			"Garrick",
			"I wasn't hiding.",
		),
		DialogueLine.create(
			"Sera",
			"No. You were wandering. Like a man"
			+ " without purpose. And now you fight"
			+ " alongside an Initiative deserter"
			+ " and a... what is that?",
		),
		DialogueLine.create(
			"Nyx",
			"I'm Nyx. Is that your purpose? Burning"
			+ " people's homes?",
		),
		DialogueLine.create(
			"Sera",
			"Abomination. You've fallen further than"
			+ " I thought, old friend.",
		),
		DialogueLine.create(
			"Garrick",
			"You've risen higher. Commander now."
			+ " How many villages, Sera?",
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
			"Garrick",
			"That's what I thought.",
		),
	]


## Scene 3 — Aftermath: Elder Morin reveals the regional purge.
## All paths converge here regardless of battle choice.
static func compute_aftermath_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Morin",
			"Sixteen villages in the Verdant Tangle"
			+ " in the last three months. Roothollow"
			+ " is the seventeenth.",
		),
		DialogueLine.create(
			"Kael",
			"This wasn't about us? About Lyra?",
		),
		DialogueLine.create(
			"Morin",
			"No. This is a regional purge. The"
			+ " Shepherds have decided the Verdant Tangle"
			+ " is too crystal-dependent.",
		),
		DialogueLine.create(
			"Garrick",
			"Standard doctrine. Purge the region,"
			+ " force the population to abandon crystal"
			+ " technology, then move on.",
		),
		DialogueLine.create(
			"Morin",
			"The question is why now. The Shepherds"
			+ " have been restrained for years. Something"
			+ " has changed their calculus.",
		),
		DialogueLine.create(
			"Iris",
			"The Initiative's accelerated operations."
			+ " The survey teams, the push for crystal"
			+ " deposits. The Shepherds see it as"
			+ " a provocation.",
		),
		DialogueLine.create(
			"Morin",
			"Two factions. Both escalating. And the"
			+ " people in between get burned.",
		),
		DialogueLine.create(
			"Kael",
			"We can't stay here. The Initiative is"
			+ " coming from the east and the Shepherds"
			+ " are burning from the north. If we stay,"
			+ " we bring both down on whatever's left.",
		),
		DialogueLine.create(
			"Morin",
			"You're not responsible for this, Kael.",
		),
		DialogueLine.create(
			"Kael",
			"Maybe not. But Lyra's next fragment is"
			+ " south. The tracker points to the"
			+ " Crystalline Steppes. If we move, we draw"
			+ " attention away from here.",
		),
		DialogueLine.create(
			"Morin",
			"You're growing up, Kael. I don't entirely"
			+ " like it.",
		),
		DialogueLine.create(
			"Kael",
			"Yeah. Me neither.",
		),
	]


## Scene 4 — Leaving Home: goodbyes to Roothollow NPCs.
static func compute_leaving_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Maeve",
			"Supplies. What I could save from the"
			+ " shop. Don't argue.",
		),
		DialogueLine.create(
			"Kael",
			"Maeve, you need these--",
		),
		DialogueLine.create(
			"Maeve",
			"I need you to come back alive more than"
			+ " I need a sack of healing crystals."
			+ " Take them.",
		),
		DialogueLine.create(
			"Old Wick",
			"I saw you fight. Shield wall against"
			+ " the purifier staff. Textbook. You're"
			+ " not bad for a Shepherd.",
		),
		DialogueLine.create(
			"Garrick",
			"Former Shepherd.",
		),
		DialogueLine.create(
			"Old Wick",
			"I know what I said.",
		),
		DialogueLine.create(
			"Yara",
			"You're leaving.",
		),
		DialogueLine.create(
			"Kael",
			"For a while. I have to go find something"
			+ " important. A person made of memories."
			+ " She needs help.",
		),
		DialogueLine.create(
			"Yara",
			"You're pretty.",
		),
		DialogueLine.create(
			"Nyx",
			"Thank you. You smell like honey.",
		),
		DialogueLine.create(
			"Yara",
			"That's the cakes. I like your new friend.",
		),
		DialogueLine.create(
			"Kael",
			"I'll fix this. Somehow. I'll fix all"
			+ " of it.",
		),
	]


## Camp scene — Night After Roothollow: Kael/Iris emotional aftermath.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"It's not your fault.",
		),
		DialogueLine.create(
			"Kael",
			"I know.",
		),
		DialogueLine.create(
			"Iris",
			"Do you?",
		),
		DialogueLine.create(
			"Kael",
			"When I was a kid, I used to have"
			+ " nightmares about the village being gone."
			+ " I'd wake up and run to the window,"
			+ " and the trees would be there, and"
			+ " the lights would be on.",
		),
		DialogueLine.create(
			"Kael",
			"Tonight I looked out and the lights"
			+ " were off.",
		),
		DialogueLine.create(
			"Iris",
			"The lights will come back on. Maeve is"
			+ " already organizing repairs.",
		),
		DialogueLine.create(
			"Kael",
			"But the Echoes, Iris. My collection."
			+ " Seven years. Hundreds of lives I was"
			+ " keeping safe. And now they're just..."
			+ " smoke.",
		),
		DialogueLine.create(
			"Kael",
			"They trusted me. Those memories. I told"
			+ " them I'd keep them safe, and I didn't.",
		),
		DialogueLine.create(
			"Iris",
			"They were important. And losing them"
			+ " hurts. And that's real.",
		),
		DialogueLine.create(
			"Kael",
			"Lyra's out there in pieces. Nyx is brand"
			+ " new. The Shepherds are burning everything."
			+ " And I'm sitting here mourning a jar"
			+ " labeled \"Two Kids Arguing About a Frog.\"",
		),
		DialogueLine.create(
			"Iris",
			"You're allowed to mourn small things and"
			+ " fight big ones at the same time. That's"
			+ " not weakness. That's being a person.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	EventFlags.set_flag(ROOTHOLLOW_FLAG)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 1: Coming Home
	DialogueManager.start_dialogue(compute_scene1_lines())
	await DialogueManager.dialogue_ended

	# Scene 2: Sera Confrontation
	DialogueManager.start_dialogue(compute_scene2_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: Aftermath — Elder Morin
	DialogueManager.start_dialogue(compute_aftermath_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: Leaving Home
	DialogueManager.start_dialogue(compute_leaving_lines())
	await DialogueManager.dialogue_ended

	# Camp Scene: Night After
	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

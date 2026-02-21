class_name CrystalCityArrival
extends Node

## Chapter 8 — "The Crystal City" story event scaffold.
## The party arrives at Prismfall and Lyra confesses she deliberately fragmented.
## Scenes 1 + 3 from docs/story/act1/08-the-crystal-city.md:
##   Scene 1: First Sight — canyon overlook arrival.
##   Scene 3: The Archives — Lyra's partial truth about the Severance.
## Gate: village_burns_seen AND NOT prismfall_arrived.
## Sets prismfall_arrived flag.

signal sequence_completed

const FLAG_NAME: String = "prismfall_arrived"


## Returns true when the event is eligible to fire:
##   - village_burns_seen flag is set (Roothollow has burned)
##   - prismfall_arrived flag is NOT set (first visit to Prismfall)
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("village_burns_seen", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 1 — First Sight: the party crests the last hill and sees Prismfall.
## ~11 lines from docs/story/act1/08-the-crystal-city.md Scene 1.
static func compute_scene1_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create("Kael", "Oh."),
		DialogueLine.create(
			"Iris",
			"Population estimate eight thousand, plus transient traders."
			+ " Mixed architecture. Two main roads in, elevated position"
			+ " on the canyon rim. Defensible.",
		),
		DialogueLine.create("Kael", "I was going for 'beautiful,' but sure."),
		DialogueLine.create("Garrick", "It's both."),
		DialogueLine.create(
			"Nyx",
			"*(In everyone's heads.)* The canyon is singing. Very quietly."
			+ " All the crystals are humming together, but each one hums"
			+ " a little different. Like an orchestra -- but alive.",
		),
		DialogueLine.create("Kael", "You hear the crystals?"),
		DialogueLine.create("Nyx", "Don't you?"),
		DialogueLine.create(
			"Iris",
			"*(Checking the fragment tracker.)* Signal is strong."
			+ " Down. In the canyon itself. Lyra's fragment is somewhere"
			+ " in those crystal formations.",
		),
		DialogueLine.create(
			"Garrick",
			"Then we rest first. Eat. Resupply. The canyon isn't going anywhere.",
		),
		DialogueLine.create("Kael", "Since when are you the patient one?"),
		DialogueLine.create(
			"Garrick",
			"Since I watched you try to run a three-day march on two hours of"
			+ " sleep and no food. You're no good to Lyra as a corpse.",
		),
	]


## Scene 3 — The Archives: Lyra's partial confession about deliberate fragmentation.
## ~12 lines from docs/story/act1/08-the-crystal-city.md Scene 3.
static func compute_scene3_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"*(Quietly, holding the fragment.)* Lyra. We're in Prismfall."
			+ " The tracker points into the Crystal Canyon. Can you tell"
			+ " us anything about what's down there?",
		),
		DialogueLine.create(
			"Lyra",
			"The Crystal Canyon. Yes. I know it. Before the Severance it was"
			+ " a natural Resonance formation -- one of the largest in the"
			+ " world. The crystals there are older than human civilization.",
		),
		DialogueLine.create(
			"Iris",
			"This data tablet references something called the 'Crystalline Warden.'"
			+ " A guardian entity in the deep canyon. Pre-Severance researchers"
			+ " documented it as a crystalline golem, possibly millions of years old.",
		),
		DialogueLine.create(
			"Lyra",
			"The Warden, yes. I remember it. It responds to intention."
			+ " Approach the deep formations with respect, and it may allow passage.",
		),
		DialogueLine.create("Kael", "May."),
		DialogueLine.create(
			"Lyra",
			"It's old, Kael. Older than humanity. Its definition of 'respect'"
			+ " might not match ours.",
		),
		DialogueLine.create(
			"Kael",
			"Lyra. I need to ask you something. In the memories I've seen --"
			+ " the lab, the countdown -- you knew what was going to happen."
			+ " You had a plan. Your fragments are scattered in very specific places."
			+ " That doesn't sound random.",
		),
		DialogueLine.create("Lyra", "It's not random."),
		DialogueLine.create(
			"Kael",
			"Then you fragmented yourself on purpose.",
		),
		DialogueLine.create(
			"Lyra",
			"...Partially. I knew the Severance was coming because I was one"
			+ " of the people who triggered it. I couldn't prevent the"
			+ " fragmentation. But I could influence where the pieces landed."
			+ " I had Resonance anchoring points prepared.",
		),
		DialogueLine.create(
			"Kael",
			"What information, Lyra? What are you really carrying?",
		),
		DialogueLine.create(
			"Lyra",
			"The truth about what the Convergence really was. And the truth"
			+ " about what the Severance really did. The fragment in the canyon"
			+ " contains my core memories from the Severance event itself."
			+ " When you find it, I'll be able to remember everything."
			+ " And then I'll tell you. Everything.",
		),
		DialogueLine.create("Kael", "Why not now?"),
		DialogueLine.create(
			"Lyra",
			"Because what I'll remember will change how you see me."
			+ " And I'd rather you had time to decide whether to trust me first."
			+ " I'm sorry for the half-truths. I've been hiding pieces of"
			+ " myself in careful places for so long I forgot how to be whole.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	DialogueManager.start_dialogue(compute_scene1_lines())
	await DialogueManager.dialogue_ended

	DialogueManager.start_dialogue(compute_scene3_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

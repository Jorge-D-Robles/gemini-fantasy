class_name CrystalCityArrival
extends Node

## Chapter 8 — "The Crystal City" full event.
## The party arrives at Prismfall and Lyra confesses she deliberately fragmented.
##   Scene 1: First Sight — canyon overlook arrival.
##   Scene 3: The Archives — Lyra's partial truth about the Severance.
##   Scene 4: Evening dinner — Garrick's daughter, Initiative agent Lorne.
##   Camp: Inn — Iris/Kael discuss Lyra's half-truths.
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
static func compute_scene1_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create("Kael", "Oh."),
		DialogueLine.create(
			"Iris",
			"Population estimate eight thousand, plus"
			+ " transient traders. Mixed architecture."
			+ " Elevated position on the canyon rim."
			+ " Defensible.",
		),
		DialogueLine.create(
			"Kael",
			"I was going for \"beautiful,\" but sure.",
		),
		DialogueLine.create("Garrick", "It's both."),
		DialogueLine.create(
			"Nyx",
			"The canyon is singing. Very quietly."
			+ " All the crystals are humming together,"
			+ " but each one hums a little different."
			+ " Like an orchestra, but alive.",
		),
		DialogueLine.create("Kael", "You hear the crystals?"),
		DialogueLine.create("Nyx", "Don't you?"),
		DialogueLine.create(
			"Iris",
			"Signal is strong. Down. In the canyon"
			+ " itself. Lyra's fragment is somewhere"
			+ " in those crystal formations.",
		),
		DialogueLine.create(
			"Garrick",
			"Then we rest first. Eat. Resupply."
			+ " The canyon isn't going anywhere.",
		),
		DialogueLine.create(
			"Kael",
			"Since when are you the patient one?",
		),
		DialogueLine.create(
			"Garrick",
			"Since I watched you try to run a"
			+ " three-day march on two hours of sleep."
			+ " You're no good to Lyra as a corpse.",
		),
	]


## Scene 3 — The Archives: Lyra's partial confession.
static func compute_scene3_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Lyra. We're in Prismfall. The tracker"
			+ " points into the Crystal Canyon. Can you"
			+ " tell us anything about what's down there?",
		),
		DialogueLine.create(
			"Lyra",
			"The Crystal Canyon. Before the Severance"
			+ " it was a natural Resonance formation."
			+ " The crystals there are older than human"
			+ " civilization.",
		),
		DialogueLine.create(
			"Iris",
			"This data tablet references something"
			+ " called the \"Crystalline Warden.\" A"
			+ " guardian entity, possibly millions of"
			+ " years old.",
		),
		DialogueLine.create(
			"Lyra",
			"The Warden, yes. It responds to"
			+ " intention. Approach with respect, and"
			+ " it may allow passage.",
		),
		DialogueLine.create("Kael", "May."),
		DialogueLine.create(
			"Lyra",
			"It's old, Kael. Older than humanity."
			+ " Its definition of \"respect\" might not"
			+ " match ours.",
		),
		DialogueLine.create(
			"Kael",
			"Lyra. In the memories I've seen — the"
			+ " lab, the countdown — you knew what was"
			+ " going to happen. Your fragments are in"
			+ " very specific places. That doesn't sound"
			+ " random.",
		),
		DialogueLine.create("Lyra", "It's not random."),
		DialogueLine.create(
			"Kael",
			"Then you fragmented yourself on purpose.",
		),
		DialogueLine.create(
			"Lyra",
			"Partially. I knew the Severance was coming"
			+ " because I was one of the people who"
			+ " triggered it. I couldn't prevent the"
			+ " fragmentation, but I could influence"
			+ " where the pieces landed. I had Resonance"
			+ " anchoring points prepared.",
		),
		DialogueLine.create(
			"Kael",
			"What information are you carrying, Lyra?",
		),
		DialogueLine.create(
			"Lyra",
			"The truth about the Convergence and the"
			+ " Severance. The fragment in the canyon"
			+ " contains my core memories. When you"
			+ " find it, I'll remember everything."
			+ " And then I'll tell you. Everything.",
		),
		DialogueLine.create("Kael", "Why not now?"),
		DialogueLine.create(
			"Lyra",
			"Because what I'll remember will change"
			+ " how you see me. I'm sorry for the"
			+ " half-truths. I've been hiding pieces"
			+ " of myself for so long I forgot how"
			+ " to be whole.",
		),
	]


## Scene 4 — Evening dinner: Garrick's daughter, Nyx and tea,
## Initiative agent Lorne encounter.
static func compute_evening_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"Eat. All of you. You look like ghosts.",
		),
		DialogueLine.create("Iris", "Complimentary."),
		DialogueLine.create(
			"Nyx",
			"The water is making rainbows! The cup"
			+ " is making rainbows!",
		),
		DialogueLine.create(
			"Iris",
			"It's the crystal salt dissolved in the"
			+ " tea. Basic optics.",
		),
		DialogueLine.create(
			"Nyx",
			"Basic? This is the most beautiful thing"
			+ " I've seen today.",
		),
		DialogueLine.create(
			"Iris",
			"You said that about the market awnings."
			+ " And the stray cat. And that one"
			+ " specific rock.",
		),
		DialogueLine.create(
			"Nyx",
			"Everything is the most beautiful thing."
			+ " Every new thing replaces the last one.",
		),
		DialogueLine.create(
			"Kael",
			"That's actually kind of wonderful.",
		),
		DialogueLine.create(
			"Kael",
			"Garrick. This is really good.",
		),
		DialogueLine.create(
			"Garrick",
			"Crystal-seasoned steak. Steppes recipe."
			+ " Mara taught me.",
		),
		DialogueLine.create("Iris", "Who's Mara?"),
		DialogueLine.create(
			"Garrick",
			"My daughter. She loved to cook. Better"
			+ " than me. She died. A long time ago."
			+ " I don't want to talk about how.",
		),
		DialogueLine.create("Kael", "You don't have to."),
		DialogueLine.create(
			"Garrick",
			"She would have loved this view. She"
			+ " always loved beautiful things.",
		),
		# Initiative Agent Lorne
		DialogueLine.create(
			"Lorne",
			"Good evening. Travelers? I'm Lorne,"
			+ " Crystaline Exports. Couldn't help"
			+ " noticing your equipment — that's"
			+ " quite the prosthetic. Initiative"
			+ " engineering?",
		),
		DialogueLine.create("Iris", "Not for sale."),
		DialogueLine.create(
			"Lorne",
			"Of course. And you — an Echo hunter?"
			+ " The canyon is full of uncatalogued"
			+ " fragments. We pay above market rate.",
		),
		DialogueLine.create(
			"Kael",
			"Thanks, but we're just passing through.",
		),
		DialogueLine.create(
			"Iris",
			"Initiative. Crystaline Exports is a"
			+ " front company. Davi warned us.",
		),
		DialogueLine.create(
			"Nyx",
			"He was lying. His outside words were"
			+ " blue and friendly but his inside"
			+ " words were gray and sharp.",
		),
		DialogueLine.create(
			"Kael",
			"We move fast tomorrow. Canyon at dawn."
			+ " Get the fragment, get out before they"
			+ " figure out what we're after.",
		),
	]


## Camp scene — Inn room: Iris/Kael discuss Lyra's half-truths.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"You're bothered by what Lyra said.",
		),
		DialogueLine.create(
			"Kael",
			"She fragmented herself on purpose."
			+ " She planned where to scatter her own"
			+ " consciousness. Brilliant? Insane? Both?",
		),
		DialogueLine.create(
			"Iris",
			"Sounds like the kind of thing a scientist"
			+ " does when they're out of options and"
			+ " have too much time to plan.",
		),
		DialogueLine.create(
			"Kael",
			"She caused the Severance. She broke the"
			+ " world. Billions of people lost everything."
			+ " And she did it on purpose.",
		),
		DialogueLine.create(
			"Kael",
			"But she also might have saved everyone"
			+ " from something worse.",
		),
		DialogueLine.create(
			"Iris",
			"That's the kind of math nobody should"
			+ " have to do.",
		),
		DialogueLine.create(
			"Kael",
			"Is that what the Initiative does?"
			+ " The same math?",
		),
		DialogueLine.create(
			"Iris",
			"The Initiative does the math and pretends"
			+ " the numbers add up. Lyra did the math"
			+ " and hid for three hundred years because"
			+ " she knew they didn't.",
		),
		DialogueLine.create(
			"Iris",
			"That's the difference. Guilt. She feels"
			+ " it. Vex doesn't.",
		),
		DialogueLine.create(
			"Kael",
			"Feeling guilty doesn't make the dead"
			+ " less dead.",
		),
		DialogueLine.create(
			"Iris",
			"No. But it makes the living more careful.",
		),
		DialogueLine.create("Kael", "Tomorrow."),
		DialogueLine.create("Iris", "Tomorrow."),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 1: First Sight
	DialogueManager.start_dialogue(compute_scene1_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: Archives — Lyra's confession
	DialogueManager.start_dialogue(compute_scene3_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: Evening dinner
	DialogueManager.start_dialogue(compute_evening_lines())
	await DialogueManager.dialogue_ended

	# Camp: Iris/Kael discuss Lyra
	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

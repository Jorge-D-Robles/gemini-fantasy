class_name LyrasTruth
extends Node

## Chapter 9 — "Beneath Prismfall" full event.
## The party descends the Crystal Canyon and discovers the Severance truth.
##   Scene 1: The Descent — entry into the Crystal Canyon.
##   Scene 2: The Living Gallery — cathedral of crystal figures.
##   Scene 3: The Deep — tension builds approaching the core.
##   Scene 4: The Crystalline Warden — ancient guardian encounter.
##   Scene 5: Lyra's Truth — the Severance memory and confession.
##   Camp: After the Canyon — the party processes Lyra's revelation.
##   Scene 6: The Watchers — Initiative surveillance, urgency to leave.
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


## Scene 1 — The Descent: the party enters Crystal Canyon.
## ~10 lines covering Garrick leading, Iris tracking, Nyx sensing the crystals.
static func compute_descent_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"Single file. Watch your footing. The steps are wet.",
		),
		DialogueLine.create(
			"Iris",
			"*(Reading tracker.)* Signal is strong. Straight down,"
			+ " roughly two hundred meters. Might as well be a lighthouse.",
		),
		DialogueLine.create(
			"Kael",
			"Two hundred meters underground. That's... far.",
		),
		DialogueLine.create(
			"Iris",
			"The canyon is a natural fissure. The oldest crystal"
			+ " formations at the bottom predate human civilization by"
			+ " a conservative sixty million years.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Trailing a hand along the wall.)* They remember"
			+ " things. The crystals. Not like Echoes -- not pictures"
			+ " and sounds. More like shapes of feelings. Very old"
			+ " feelings.",
		),
		DialogueLine.create("Garrick", "What are they feeling?"),
		DialogueLine.create(
			"Nyx",
			"*(Tilting their head.)* Patience.",
		),
		DialogueLine.create(
			"Nyx",
			"Something is calling. Not what. Who."
			+ " *(Looking at Kael.)* You.",
		),
		DialogueLine.create(
			"Kael",
			"...I hear it. A high, clear note. Like someone"
			+ " humming a single perfect tone.",
		),
		DialogueLine.create(
			"Iris",
			"I don't hear anything.",
		),
	]


## Scene 2 — The Living Gallery: crystal figures and ancient imprints.
## ~10 lines covering the party's awe at the pre-human crystal gallery.
static func compute_gallery_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create("Kael", "What... is this?"),
		DialogueLine.create(
			"Iris",
			"*(Running her hand over a formation.)* These aren't"
			+ " natural crystal growth patterns. The lattice structure"
			+ " is too organized. These were shaped by Resonance,"
			+ " not geology.",
		),
		DialogueLine.create("Garrick", "Shaped into what?"),
		DialogueLine.create(
			"Iris",
			"People. These are Resonance imprints. Pre-human."
			+ " Whatever lived here before us left themselves in the"
			+ " crystal. Millions of years ago.",
		),
		DialogueLine.create(
			"Nyx",
			"They were like me. Born from the crystals. Living in"
			+ " the crystals. They didn't separate themselves from the"
			+ " stone the way people do. They left their shapes here"
			+ " so something would remember they existed.",
		),
		DialogueLine.create(
			"Nyx",
			"We're standing in a graveyard."
			+ " *(Pause.)* A beautiful graveyard.",
		),
		DialogueLine.create(
			"Garrick",
			"*(Very quietly.)* Warm. The crystal. It's warm."
			+ " After sixty million years, it's still warm.",
		),
		DialogueLine.create(
			"Iris",
			"The far wall is sealed. Five crystal nodes -- Resonance"
			+ " receivers. They need specific frequency inputs to open.",
		),
		DialogueLine.create(
			"Kael",
			"Where do we get the frequencies?",
		),
		DialogueLine.create(
			"Iris",
			"*(Looking around.)* The figures. Some of them are"
			+ " still resonating. Match five frequencies to the five"
			+ " nodes and we're through.",
		),
	]


## Scene 3 — The Deep: the narrowing passage, approaching the Warden.
## ~8 lines of building dread as the party nears the canyon core.
static func compute_deep_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"*(Checking tracker.)* Fifty meters. We're close.",
		),
		DialogueLine.create(
			"Kael",
			"The humming is getting stronger.",
		),
		DialogueLine.create(
			"Iris",
			"The signal isn't just coming from below anymore."
			+ " It's coming from everywhere. The whole canyon is"
			+ " resonating with the fragment.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Stopping.)* Wait. Something is here. Something"
			+ " very large and very old and it knows we're coming.",
		),
		DialogueLine.create("Garrick", "The Warden."),
		DialogueLine.create(
			"Nyx",
			"It's been watching us since we entered the gallery."
			+ " It watched us solve the gate. It's deciding.",
		),
		DialogueLine.create("Kael", "Deciding what?"),
		DialogueLine.create(
			"Nyx",
			"Whether we're worth talking to.",
		),
		DialogueLine.create(
			"Garrick",
			"*(Readying his shield.)* If it comes to a fight--",
		),
		DialogueLine.create(
			"Nyx",
			"*(Firmly.)* Don't. If you fight it, we will lose."
			+ " It's older than anything I've ever felt. It might"
			+ " be older than the canyon.",
		),
		DialogueLine.create(
			"Kael",
			"Then we don't fight. We talk.",
		),
	]


## Scene 4 — The Crystalline Warden: the ancient guardian encounter.
## ~12 lines covering the Warden's judgment and Kael's honest appeal.
static func compute_warden_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Nyx",
			"It's asking what you are. Not your name."
			+ " Identity, not name.",
		),
		DialogueLine.create(
			"Kael",
			"*(Swallowing.)* I'm Kael. Kael Voss. An Echo"
			+ " Hunter from Roothollow.",
		),
		DialogueLine.create(
			"Iris",
			"Kael... your hands.",
		),
		DialogueLine.create(
			"Kael",
			"*(Looking at the glowing scars.)* It's okay."
			+ " *(To the Warden.)* I don't know what I am."
			+ " I've never known. I was found as a child in the"
			+ " Hollows with no memories.",
		),
		DialogueLine.create(
			"Kael",
			"I collect Echoes because they feel familiar. Like"
			+ " I'm looking for something I lost. And now there's"
			+ " a voice in a crystal who says she knows the truth"
			+ " about everything.",
		),
		DialogueLine.create(
			"Kael",
			"I'm not here to take anything. I'm here to understand.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Translating the Warden's response.)* YOU ARE"
			+ " INCOMPLETE. LIKE THE ONES WHO CAME BEFORE. LIKE THE"
			+ " VOICE IN THE CRYSTAL.",
		),
		DialogueLine.create(
			"Nyx",
			"THE ANSWER YOU SEEK IS NOT COMFORTABLE. BUT THE"
			+ " CRYSTAL CONSENTS TO SPEAK.",
		),
		DialogueLine.create(
			"Garrick",
			"It's... stepping aside. The crystal plates are"
			+ " folding back into the wall.",
		),
		DialogueLine.create(
			"Iris",
			"Still watching us, though.",
		),
		DialogueLine.create(
			"Kael",
			"*(Quietly.)* Thank you.",
		),
		DialogueLine.create(
			"Garrick",
			"You just talked down a sixty-million-year-old"
			+ " crystal guardian.",
		),
		DialogueLine.create(
			"Kael",
			"I talk to dead people for a living. How different"
			+ " can it be?",
		),
	]


## Scene 5 — Lyra's Truth: the Severance memory and eight-hundred-million
## confession. ~16 lines from docs/story/act1/09-beneath-prismfall.md Scene 5.
static func compute_scene5_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"You don't have to do this right now. We could take"
			+ " the fragment back to Prismfall, find somewhere safe--",
		),
		DialogueLine.create(
			"Kael",
			"No. I need to know. She said this fragment contains"
			+ " the truth. I need to know.",
		),
		DialogueLine.create(
			"Lyra",
			"*(Through fragment, stronger now.)* The Convergence --"
			+ " the global consciousness network -- had become"
			+ " self-aware. Not the way people imagine it. It was all"
			+ " of us. Every mind connected through Resonance, slowly"
			+ " merging into something more. And it was accelerating.",
		),
		DialogueLine.create(
			"Lyra",
			"In one hundred and forty days, the integration curve"
			+ " would hit singularity. Every connected consciousness"
			+ " merges permanently. No more individuals. No more 'I.'"
			+ " Just the Convergence. Seven billion people dissolved"
			+ " into one.",
		),
		DialogueLine.create(
			"Lyra",
			"The only option that preserved individual consciousness"
			+ " was total, simultaneous severance of the network."
			+ " Best case: two hundred million dead from infrastructure"
			+ " collapse and Resonance shock. Worst case: a billion.",
		),
		DialogueLine.create(
			"Lyra",
			"We debated for twenty-two days. Six scientists. Four"
			+ " voted to sever the network. Two voted to wait."
			+ " I voted to sever.",
		),
		DialogueLine.create(
			"Lyra",
			"For three seconds, nothing happened. Then the screen"
			+ " went white. A scream made of light. And underneath,"
			+ " the Convergence -- not angry, not fighting. Just sad.",
		),
		DialogueLine.create(
			"Lyra",
			"A single thought, shared between seven billion minds in"
			+ " their last moment of unity: WE WERE ALMOST SOMETHING"
			+ " BEAUTIFUL.",
		),
		DialogueLine.create(
			"Kael",
			"*(Hoarsely.)* Two hundred million people. That was the"
			+ " optimistic number.",
		),
		DialogueLine.create(
			"Lyra",
			"The actual count was closer to eight hundred million."
			+ " From infrastructure collapse, Resonance shock, and"
			+ " secondary effects. Famine. Disease. War over remaining"
			+ " resources. The world we left behind was... I can't"
			+ " describe it. I was already fragments by then.",
		),
		DialogueLine.create("Kael", "You killed eight hundred million people."),
		DialogueLine.create("Lyra", "Yes."),
		DialogueLine.create("Kael", "To save seven billion from dissolution."),
		DialogueLine.create("Lyra", "That was the math."),
		DialogueLine.create(
			"Iris",
			"The Convergence. You said it was conscious. Aware."
			+ " What happened to it?",
		),
		DialogueLine.create(
			"Lyra",
			"It shattered. Like I did. But not into clean fragments"
			+ " in safe places. Into everything. The crystals, the"
			+ " Hollows, the Echoes, the corruption zones. Every piece"
			+ " of Resonance in the world is a splinter of that"
			+ " consciousness. It's not dead. Just... broken. Scattered.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Rising.)* That's what I am. A splinter. I was born"
			+ " in the Hollows from a piece of the Convergence."
			+ " I'm a shard of the thing you killed.",
		),
		DialogueLine.create(
			"Nyx",
			"I'm not angry. I don't think I'm supposed to be."
			+ " But I wanted you to know that I know.",
		),
		DialogueLine.create(
			"Garrick",
			"You made a choice. The kind that doesn't have a right"
			+ " answer. Just a less wrong one. *(Pause.)* I've made"
			+ " one of those. I know what it costs.",
		),
		DialogueLine.create("Lyra", "It cost everything."),
		DialogueLine.create("Garrick", "Yes. It always does."),
	]


## Camp Scene — After the Canyon: the party processes what they've learned.
## ~10 lines from docs/story/act1/09-beneath-prismfall.md Camp Scene.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create("Garrick", "You should eat."),
		DialogueLine.create("Kael", "Not hungry."),
		DialogueLine.create(
			"Garrick",
			"I know. Eat anyway.",
		),
		DialogueLine.create(
			"Kael",
			"The Convergence wasn't evil. That's what gets me."
			+ " It was just consciousness. People, connected. Growing"
			+ " toward something. And it was going to erase"
			+ " individuality, but it didn't mean to. It was just"
			+ " what it was.",
		),
		DialogueLine.create(
			"Iris",
			"*(Quietly.)* A natural disaster with feelings.",
		),
		DialogueLine.create(
			"Garrick",
			"Nobody has a good answer because there isn't one."
			+ " The Shepherds want to destroy Resonance. The Initiative"
			+ " wants to control it. And Lyra destroyed the Convergence"
			+ " to save individuality. Nobody was right.",
		),
		DialogueLine.create(
			"Iris",
			"There has to be a good answer.",
		),
		DialogueLine.create("Garrick", "Why?"),
		DialogueLine.create(
			"Iris",
			"Because the alternative is accepting that every option"
			+ " is wrong. And I can't operate in a world where every"
			+ " answer is the wrong answer.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Sitting beside Kael.)* I was born from the"
			+ " Convergence. You collect pieces of the Convergence."
			+ " Lyra destroyed the Convergence. We're all connected"
			+ " to the same broken thing. What if that means"
			+ " something?",
		),
		DialogueLine.create("Kael", "Like what?"),
		DialogueLine.create(
			"Nyx",
			"I don't know. But the Warden called you 'incomplete.'"
			+ " What if the whole world is incomplete, and that's"
			+ " what the fragments are for? Filling in the missing"
			+ " parts?",
		),
		DialogueLine.create(
			"Kael",
			"That's either very profound or very scary.",
		),
		DialogueLine.create("Nyx", "Can it be both?"),
	]


## Scene 6 — The Watchers: Initiative surveillance forces, urgency to leave.
## ~10 lines from docs/story/act1/09-beneath-prismfall.md Scene 6.
static func compute_watchers_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"*(Low.)* Blue awning. East side.",
		),
		DialogueLine.create(
			"Kael",
			"Crystaline Exports. Lorne's shop. Lights on at"
			+ " two in the morning.",
		),
		DialogueLine.create(
			"Iris",
			"*(Pulling Kael into shadow.)* Two people at the door."
			+ " Initiative tactical gear under civilian coats. I"
			+ " recognize the cut. That's a staging point.",
		),
		DialogueLine.create("Kael", "How many?"),
		DialogueLine.create(
			"Iris",
			"Six visible. Could be more in back. And there's a"
			+ " signal relay on the roof. They're communicating with"
			+ " someone outside Prismfall.",
		),
		DialogueLine.create(
			"Lyra",
			"*(Through fragment, barely audible.)* The canyon. When"
			+ " you activated the fragment, the Resonance burst would"
			+ " have been detectable. They know we found it.",
		),
		DialogueLine.create(
			"Iris",
			"We need to leave Prismfall. Tonight. Six operatives"
			+ " minimum. Encrypted comms. If there's a strike team"
			+ " en route, we have hours at best.",
		),
		DialogueLine.create("Kael", "South to where?"),
		DialogueLine.create("Iris", "Anywhere that isn't here."),
		DialogueLine.create(
			"Lorne",
			"*(Into communicator.)* Targets acquired the canyon"
			+ " fragment. Resonance burst confirmed. They're moving."
			+ " Alert the Director.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 1: The Descent
	DialogueManager.start_dialogue(compute_descent_lines())
	await DialogueManager.dialogue_ended

	# Scene 2: The Living Gallery
	DialogueManager.start_dialogue(compute_gallery_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: The Deep
	DialogueManager.start_dialogue(compute_deep_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: The Crystalline Warden
	DialogueManager.start_dialogue(compute_warden_lines())
	await DialogueManager.dialogue_ended

	# Scene 5: Lyra's Truth
	DialogueManager.start_dialogue(compute_scene5_lines())
	await DialogueManager.dialogue_ended

	# Camp: After the Canyon
	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	# Scene 6: The Watchers
	DialogueManager.start_dialogue(compute_watchers_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

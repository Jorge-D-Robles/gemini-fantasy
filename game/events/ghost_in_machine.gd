class_name GhostInMachine
extends Node

## Cipher's "Ghost in the Machine" character quest — full 5-stage chain.
## Cipher discovers the Anchor Control Protocol, watches it used on
## prisoners, is hijacked by Vex, enters their own mindscape to purge
## the Protocol code, and returns to destroy the device.
##   Stage 1: Breadcrumbs — safehouse, Cipher finds the Protocol.
##   Stage 2: The Kennel — infiltrate Initiative facility.
##   Stage 3: Hijacked — Vex takes remote control of Cipher.
##   Stage 4: The Room Inside the Room — mindscape, purge 3 nodes.
##   Stage 5: Unshackled — confront Vex, destroy the device.
## Each stage sets ghost_stage_N flag.

signal sequence_completed

const FLAG_PREFIX: String = "ghost_stage_"


## Triggers stage N at runtime: guards replay, sets flag, plays dialogue.
func trigger_stage(stage: int) -> void:
	var flag := FLAG_PREFIX + str(stage)
	if EventFlags.has_flag(flag):
		return
	if stage > 1:
		var prev := FLAG_PREFIX + str(stage - 1)
		if not EventFlags.has_flag(prev):
			return

	EventFlags.set_flag(flag)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var lines := _lines_for_stage(stage)
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()


func _lines_for_stage(stage: int) -> Array[DialogueLine]:
	match stage:
		1:
			return compute_breadcrumbs_lines()
		2:
			return compute_kennel_lines()
		3:
			return compute_hijacked_lines()
		4:
			return compute_room_lines()
		5:
			return compute_unshackled_lines()
		_:
			return []


## Returns true if stage N can fire given current flags.
static func compute_can_trigger_stage(
	stage: int, flags: Dictionary,
) -> bool:
	var flag := FLAG_PREFIX + str(stage)
	if flags.get(flag, false):
		return false
	if stage > 1:
		var prev := FLAG_PREFIX + str(stage - 1)
		if not flags.get(prev, false):
			return false
	return true


## Stage 1 — Breadcrumbs: Cipher finds the Anchor Control Protocol.
static func compute_breadcrumbs_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Seven. Seven seconds since you walked in."
			+ " Iris breathes louder than she thinks."
			+ " Prosthetic servo hums at 400 hertz.",
		),
		DialogueLine.create(
			"Iris",
			"And you really should eat something."
			+ " Garrick's sandwich is developing its"
			+ " own personality.",
		),
		DialogueLine.create(
			"Cipher",
			"I found something. In the Initiative's"
			+ " network. Something I wasn't supposed to"
			+ " find, which is how I know it's real.",
		),
		DialogueLine.create(
			"Cipher",
			"Twelve million credits funneled through"
			+ " equipment maintenance into a facility"
			+ " that doesn't exist on any map. Power"
			+ " consumption: reactor-level.",
		),
		DialogueLine.create(
			"Iris",
			"Where's it going?",
		),
		DialogueLine.create(
			"Cipher",
			"A building on the coast. And the department"
			+ " header on the personnel file says Anchor"
			+ " Research Division. They've been studying"
			+ " Anchors for at least two years.",
		),
		DialogueLine.create(
			"Cipher",
			"The project is called the Anchor Control"
			+ " Protocol. Control. Not study. Not"
			+ " understand. Control.",
		),
		DialogueLine.create(
			"Kael",
			"What if they wanted you to find this?"
			+ " Hidden data, no name, a building that"
			+ " doesn't exist. It could be a trap.",
		),
		DialogueLine.create(
			"Cipher",
			"That crossed my mind about forty times."
			+ " But that's the problem with paranoia."
			+ " At some point you can't tell the"
			+ " difference between a real threat and"
			+ " the sound of your own brain screaming.",
		),
		DialogueLine.create(
			"Cipher",
			"If they can control an Anchor-- make them"
			+ " do whatever the operator wants-- then"
			+ " running doesn't matter. Sixteen years"
			+ " of keeping myself free and they can"
			+ " just reach in and take the wheel.",
		),
		DialogueLine.create(
			"Cipher",
			"I need people watching my back. Going"
			+ " alone is how I've always done it. And"
			+ " right now I'm thinking maybe that's"
			+ " not enough.",
		),
		DialogueLine.create(
			"Kael",
			"We'll go with you.",
		),
		DialogueLine.create(
			"Cipher",
			"And Kael? If they use it on me. If they"
			+ " turn me into a thing that fights you."
			+ " Don't hold back. Just put me on the"
			+ " ground as fast as you can. Crystal clear?",
		),
		DialogueLine.create(
			"Kael",
			"Crystal clear.",
		),
	]


## Stage 2 — The Kennel: infiltrate the Initiative facility.
static func compute_kennel_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Two guards, rotating every forty minutes."
			+ " Electronic lock, biometric. Four cameras"
			+ " on the east wall. One Resonance dampener"
			+ " field covering the front approach.",
		),
		DialogueLine.create(
			"Cipher",
			"The dampener is the problem. We walk"
			+ " through that field and my abilities go"
			+ " dead. Iris, your prosthetic will lose"
			+ " half its motor function.",
		),
		DialogueLine.create(
			"Iris",
			"Can you kill it remotely?",
		),
		DialogueLine.create(
			"Cipher",
			"If I could kill it remotely I wouldn't be"
			+ " lying in wet gravel right now. We go in"
			+ " through the drainage pipes.",
		),
		DialogueLine.create(
			"Kael",
			"Through the pipes. Great.",
		),
		DialogueLine.create(
			"Cipher",
			"What, you wanted a red carpet?",
		),
		DialogueLine.create(
			"Cipher",
			"She's an Anchor. Low-grade. They've got a"
			+ " port installed at her brain stem. Some"
			+ " kind of receiver.",
		),
		DialogueLine.create(
			"Iris",
			"Subject 4-A. Inducted fourteen months ago."
			+ " Current status: responsive to Protocol"
			+ " input.",
		),
		DialogueLine.create(
			"Cipher",
			"She's breathing. She's alive. But there's"
			+ " nobody behind the eyes. Her body is"
			+ " running but the person is--",
		),
		DialogueLine.create(
			"Cipher",
			"The Anchor Control Protocol. A transmitter"
			+ " paired to the receiver in the subject's"
			+ " brain stem. Motor functions, speech,"
			+ " even emotional state. They can make you"
			+ " smile while you're screaming inside.",
		),
		DialogueLine.create(
			"Technician",
			"Subject 4-A, Protocol test seventeen."
			+ " Emotional override. Set baseline to"
			+ " joy. Seventy percent.",
		),
		DialogueLine.create(
			"Cipher",
			"Four hours. She sat in there for four"
			+ " hours, smiling, while they-- while"
			+ " she was--",
		),
		DialogueLine.create(
			"Cipher",
			"I'm downloading everything. The schematics,"
			+ " the trial data, the personnel files."
			+ " Then we get out.",
		),
	]


## Stage 3 — Hijacked: Vex takes remote control of Cipher.
static func compute_hijacked_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Perimeter clear. No Initiative signatures"
			+ " within two kilometers. We're good.",
		),
		DialogueLine.create(
			"Kael",
			"You're staring.",
		),
		DialogueLine.create(
			"Cipher",
			"I'm doing threat assessment. I'm assessing"
			+ " the threat level of the beetle. It could"
			+ " be an Initiative spy.",
		),
		DialogueLine.create(
			"Cipher",
			"It's a nice camp. I've slept in a lot of"
			+ " bad places. Server rooms. Drainage pipes."
			+ " This is something I forgot existed.",
		),
		DialogueLine.create(
			"Kael",
			"You could get used to it.",
		),
		DialogueLine.create(
			"Cipher",
			"Don't say that. Getting used to things"
			+ " is how you--",
		),
		DialogueLine.create(
			"Kael",
			"Cipher?",
		),
		DialogueLine.create(
			"Cipher/Vex",
			"Good evening. I apologize for the"
			+ " interruption. Director Vex Thornwright,"
			+ " speaking through your friend. They can"
			+ " hear everything. They just can't do"
			+ " anything about it.",
		),
		DialogueLine.create(
			"Cipher/Vex",
			"The Anchor Control Protocol doesn't"
			+ " require a surgical port. The current"
			+ " version uses the Resonance network"
			+ " itself. Cipher has been absorbing the"
			+ " signal for three days.",
		),
		DialogueLine.create(
			"Nyx",
			"You're in there. I can feel you in there."
			+ " You're screaming.",
		),
		DialogueLine.create(
			"Cipher/Vex",
			"I'm going to have your friend attack you."
			+ " Not to kill. This is not a threat. This"
			+ " is a proof of concept.",
		),
		DialogueLine.create(
			"Garrick",
			"We're not going to hurt you, Cipher. We"
			+ " know you're in there. Keep fighting.",
		),
		DialogueLine.create(
			"Cipher",
			"Get-- out-- of my-- HEAD--",
		),
		DialogueLine.create(
			"Cipher",
			"SEVEN PEOPLE. SEVEN EXITS. AND YOU'RE NOT"
			+ " IN ANY OF THEM.",
		),
		DialogueLine.create(
			"Iris",
			"You're back.",
		),
		DialogueLine.create(
			"Cipher",
			"I could feel it. All of it. My hands"
			+ " hitting Kael. My legs moving. And I"
			+ " couldn't stop any of it. I was right"
			+ " there and I couldn't stop any of it.",
		),
	]


## Stage 4 — The Room Inside the Room: mindscape, purge 3 nodes.
static func compute_room_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Welcome to my head. Mind the architecture."
			+ " I was going for organized chaos but I"
			+ " think it landed closer to anxiety attack"
			+ " rendered in three dimensions.",
		),
		DialogueLine.create(
			"Kael",
			"This is how you see yourself? A city?",
		),
		DialogueLine.create(
			"Cipher",
			"I'm a systems person. I think in networks."
			+ " Right now about fifteen percent of my"
			+ " paths have been rerouted through"
			+ " Initiative code I can't remove by myself.",
		),
		DialogueLine.create(
			"Cipher",
			"Three nodes. Three chunks of code buried"
			+ " in the parts of me I don't look at."
			+ " The locked rooms. The memories I filed"
			+ " under never open.",
		),
		DialogueLine.create(
			"Cipher",
			"I was sixteen. I touched a terminal at"
			+ " school and the entire network opened up."
			+ " It was the most natural thing I'd ever"
			+ " done.",
		),
		DialogueLine.create(
			"Scientist",
			"Resonance signature confirmed. Mark this"
			+ " one as Priority Alpha. Induction team,"
			+ " move in.",
		),
		DialogueLine.create(
			"Cipher",
			"The Protocol grafted onto this memory"
			+ " because it's where the fear started."
			+ " The fear that being an Anchor means"
			+ " I'm public property.",
		),
		DialogueLine.create(
			"Kael",
			"You're not property.",
		),
		DialogueLine.create(
			"Cipher",
			"Tell that to the woman in Cell 4.",
		),
		DialogueLine.create(
			"Cipher",
			"I was twenty-two. I'd been living in the"
			+ " Undercity for six years. No friends."
			+ " I hadn't touched another person in"
			+ " eleven months.",
		),
		DialogueLine.create(
			"Cipher",
			"I wasn't going to jump. I was just tired."
			+ " Tired of being a thing that runs. I stood"
			+ " on the bridge for two hours and thought:"
			+ " what if I just stopped?",
		),
		DialogueLine.create(
			"Cipher",
			"I never told anyone about the bridge. Not"
			+ " Ratchet. Not anyone. Now you know.",
		),
		DialogueLine.create(
			"Kael",
			"Thank you for telling me.",
		),
		DialogueLine.create(
			"Cipher",
			"Don't make it a thing.",
		),
		DialogueLine.create(
			"Reflection",
			"You were never free. You were just far"
			+ " enough away from the leash that you"
			+ " forgot it was there.",
		),
		DialogueLine.create(
			"Cipher",
			"It's clean. My head is mine again. Just"
			+ " mine. Nobody else's.",
		),
		DialogueLine.create(
			"Kael",
			"How does it feel?",
		),
		DialogueLine.create(
			"Cipher",
			"Quiet.",
		),
		DialogueLine.create(
			"Cipher",
			"Seven. All seven.",
		),
		DialogueLine.create(
			"Garrick",
			"All seven.",
		),
	]


## Stage 5 — Unshackled: confront Vex, destroy the device.
static func compute_unshackled_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Two searchlights, four-second rotation."
			+ " Twenty-four guards. Dampener field active"
			+ " but I know the frequency now. I can work"
			+ " around it.",
		),
		DialogueLine.create(
			"Cipher",
			"Last time I came here I saw what they did"
			+ " to people like me and I froze. Couldn't"
			+ " think. Just ran.",
		),
		DialogueLine.create(
			"Cipher",
			"I'm done running from this one.",
		),
		DialogueLine.create(
			"Iris",
			"Then let's go break their toy.",
		),
		DialogueLine.create(
			"Vex",
			"I assumed you'd come for it. Cipher is"
			+ " nothing if not predictable in their"
			+ " unpredictability.",
		),
		DialogueLine.create(
			"Cipher",
			"Two exits. Twelve cameras. One pompous"
			+ " hollow in a nice suit. Call it a fair"
			+ " fight.",
		),
		DialogueLine.create(
			"Vex",
			"I could activate the Protocol right now."
			+ " One command. You'd be mine again.",
		),
		DialogueLine.create(
			"Cipher",
			"Try it. Your code isn't in my head anymore,"
			+ " Vex. I burned it out. Root and branch.",
		),
		DialogueLine.create(
			"Cipher",
			"I had help. That's the part you never"
			+ " factor in. Your whole operation runs"
			+ " on isolated variables. You can't model"
			+ " what happens when people actually give"
			+ " a damn about each other.",
		),
		DialogueLine.create(
			"Vex",
			"Sentiment is a vulnerability, not a"
			+ " strategy.",
		),
		DialogueLine.create(
			"Cipher",
			"Then why do you keep losing?",
		),
		DialogueLine.create(
			"Vex",
			"If you destroy it, I'll build another."
			+ " There is no move on this board that"
			+ " doesn't benefit me eventually.",
		),
		DialogueLine.create(
			"Cipher",
			"The thing that hijacked my body and made"
			+ " me attack the only people I trust."
			+ " It's right here. And we're going to"
			+ " destroy every piece of it.",
		),
		DialogueLine.create(
			"Cipher",
			"You know what I've been thinking about?"
			+ " The sandwich. Garrick's sandwich that"
			+ " I didn't eat because I was too busy"
			+ " being paranoid that kindness was a trap.",
		),
		DialogueLine.create(
			"Cipher",
			"Turns out the thing keeping me safe was"
			+ " the seven people who fought my own body"
			+ " to get me back. Who walked through my"
			+ " worst memories so I didn't have to go"
			+ " alone.",
		),
		DialogueLine.create(
			"Cipher",
			"I'm not good at this part. The emotional"
			+ " vulnerability portion of the program."
			+ " But. Thank you. For coming for me."
			+ " All of you.",
		),
	]

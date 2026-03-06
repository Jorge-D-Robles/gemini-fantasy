class_name Rogue
extends Node

## Chapter 11 — "Rogue" full event.
## Act II opening: party regroups after escape, goes rogue.
##   Scene 1: What We Carried Out — camp silence, Kael breaks, Nyx asks.
##   Scene 2: What We're Running From — dawn argument, fragile resolve.
##   Scene 3: The Waystation — abandoned supply cache, Echo fragment.
##   Scene 4: The Border — Ironcoast checkpoint, first glimpse of Gearhaven.
##   Camp: What Nobody Asked — Iris on Dane, Nyx offers to hold Lyra.
##   Scene 5: Ghost Protocol — smuggler Zen, harbor entry.
##   Scene 6: The Weight of Names — planning the Undercity descent.
## Gate: kael_anchor_revealed AND NOT rogue_decided.
## Sets rogue_decided flag.

signal sequence_completed

const FLAG_NAME: String = "rogue_decided"


## Returns true when the event is eligible to fire:
##   - kael_anchor_revealed flag is set (Act I climax happened)
##   - rogue_decided flag is NOT set (not yet decided)
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("kael_anchor_revealed", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 1 — What We Carried Out: camp silence, Kael breaks down.
static func compute_silence_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Nyx",
			"Is it supposed to smell like that?",
		),
		DialogueLine.create(
			"Nyx",
			"The smoke. It smells different here than at"
			+ " the other camps. More like... the word is"
			+ " wet? But for smell.",
		),
		DialogueLine.create(
			"Garrick",
			"Damp. The wood's damp.",
		),
		DialogueLine.create(
			"Nyx",
			"Damp. That's not a good word. It doesn't"
			+ " feel like it sounds.",
		),
		DialogueLine.create(
			"Iris",
			"The servo coupler's cracked. I need a"
			+ " workshop, or at minimum a soldering pick,"
			+ " or this arm is going to be decorative in"
			+ " about six hours.",
		),
		DialogueLine.create(
			"Garrick",
			"Prismfall's a day south. Maybe two if we"
			+ " stick to back trails.",
		),
		DialogueLine.create(
			"Iris",
			"And if the Initiative has people there?",
		),
		DialogueLine.create(
			"Garrick",
			"They will.",
		),
		DialogueLine.create(
			"Kael",
			"They knew.",
		),
		DialogueLine.create(
			"Kael",
			"Vex knew what I was before I did. Before any"
			+ " of us did. He had files, Iris. Medical"
			+ " charts. Growth projections. Like I was"
			+ " a crop report.",
		),
		DialogueLine.create(
			"Kael",
			"A Resonance Anchor. I don't even know what"
			+ " that means. Not really. He said I can"
			+ " stabilize the Convergence. Or destabilize"
			+ " it. That I'm one of three people who can"
			+ " touch the thing that nearly destroyed"
			+ " everything and just -- what? Steer it?",
		),
		DialogueLine.create(
			"Kael",
			"I collect dead people's memories for a"
			+ " living. I can barely steer a conversation.",
		),
		DialogueLine.create(
			"Lyra",
			"Kael. You need to rest. Your Resonance"
			+ " signature is erratic, and if you don't--",
		),
		DialogueLine.create(
			"Kael",
			"My Resonance signature. Right. Because I'm"
			+ " not a person, I'm a signature.",
		),
		DialogueLine.create(
			"Garrick",
			"You're a person.",
		),
		DialogueLine.create(
			"Garrick",
			"Had a sergeant once. Good man. Found out his"
			+ " grandmother had been Shepherd. Spent two"
			+ " weeks wondering if his whole life was a"
			+ " lie.",
		),
		DialogueLine.create(
			"Garrick",
			"Told him: You're what you do. Every day."
			+ " Not what someone made you from.",
		),
		DialogueLine.create(
			"Kael",
			"And did that help?",
		),
		DialogueLine.create(
			"Garrick",
			"Not even a little.",
		),
		DialogueLine.create(
			"Garrick",
			"But it was true anyway.",
		),
		DialogueLine.create(
			"Nyx",
			"Kael. If you're a Resonance Anchor, and I'm"
			+ " a being born from the Hollows, does that"
			+ " make us the same kind of not-human? Or"
			+ " different kinds?",
		),
		DialogueLine.create(
			"Iris",
			"Nyx. Read the room.",
		),
		DialogueLine.create(
			"Nyx",
			"I can't read rooms. Rooms don't have text.",
		),
		DialogueLine.create(
			"Kael",
			"No. It's a fair question.",
		),
		DialogueLine.create(
			"Kael",
			"I don't know, Nyx. I honestly don't know"
			+ " what I am. But I think... maybe that makes"
			+ " us the same kind of confused?",
		),
		DialogueLine.create(
			"Nyx",
			"I like that. Being confused together is"
			+ " better than being confused alone. I think"
			+ " that's what friends means.",
		),
	]


## Scene 2 — What We're Running From: dawn argument, fragile resolve.
static func compute_dawn_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"We need to move before full light. Initiative"
			+ " will have tracker teams out by now. Standard"
			+ " protocol after a containment breach is a"
			+ " forty-kilometer sweep grid within"
			+ " twenty-four hours.",
		),
		DialogueLine.create(
			"Garrick",
			"You know their protocols.",
		),
		DialogueLine.create(
			"Iris",
			"I wrote half of them.",
		),
		DialogueLine.create(
			"Kael",
			"Where do we even go? We can't go back to"
			+ " Roothollow -- they'll be watching it."
			+ " Can't go to Prismfall without running into"
			+ " faction agents.",
		),
		DialogueLine.create(
			"Lyra",
			"We need to find the other Anchors. That much"
			+ " is clear. If the Initiative wants them --"
			+ " if the Shepherds want them dead -- then"
			+ " those people are in danger.",
		),
		DialogueLine.create(
			"Iris",
			"We don't know who they are. We don't know"
			+ " where they are. We're talking about"
			+ " searching an entire continent while two"
			+ " armies hunt us.",
		),
		DialogueLine.create(
			"Lyra",
			"I have fragments. Impressions. When Kael's"
			+ " Anchor signature manifested in the facility,"
			+ " I felt echoes of the others. One west. One"
			+ " north.",
		),
		DialogueLine.create(
			"Garrick",
			"West is Ironcoast. North is Cindral.",
		),
		DialogueLine.create(
			"Lyra",
			"There's something else. The Initiative didn't"
			+ " just know about the Anchors. They've been"
			+ " building something. A device designed to"
			+ " contain or harness the Convergence directly.",
		),
		DialogueLine.create(
			"Iris",
			"A weapon?",
		),
		DialogueLine.create(
			"Lyra",
			"Worse. A cage. A way to trap the Convergence"
			+ " and force it into a controlled state."
			+ " Indefinitely. Using the Anchors as power"
			+ " sources.",
		),
		DialogueLine.create(
			"Kael",
			"So Vex didn't want to work with me. He"
			+ " wanted to use me as a battery.",
		),
		DialogueLine.create(
			"Kael",
			"Then we find them first.",
		),
		DialogueLine.create(
			"Kael",
			"I spent my whole life thinking I was just"
			+ " some kid who couldn't remember their past."
			+ " Turns out I might be something else"
			+ " entirely. The only thing I can control"
			+ " right now is what I do next. So what I do"
			+ " next is make sure nobody else gets turned"
			+ " into a battery.",
		),
		DialogueLine.create(
			"Garrick",
			"Good enough.",
		),
		DialogueLine.create(
			"Iris",
			"It's a terrible plan. I'm in.",
		),
		DialogueLine.create(
			"Nyx",
			"Where Kael goes, I go. That's how this"
			+ " works, right? That's what the party"
			+ " dynamic is?",
		),
		DialogueLine.create(
			"Kael",
			"Yeah, Nyx. That's how it works.",
		),
		DialogueLine.create(
			"Lyra",
			"West first. The Anchor in Ironcoast territory"
			+ " will be in the most immediate danger -- the"
			+ " Initiative's power base is there.",
		),
		DialogueLine.create(
			"Iris",
			"Gearhaven it is.",
		),
	]


## Scene 3 — The Waystation: abandoned cache, Echo fragment.
static func compute_waystation_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"Clear. Supply crates. Some opened, some not."
			+ " And--",
		),
		DialogueLine.create(
			"Iris",
			"*(Holding up a soldering pick.)* Well."
			+ " Someone was thinking of me.",
		),
		DialogueLine.create(
			"Garrick",
			"Or someone was doing maintenance on"
			+ " Initiative equipment and left in a rush.",
		),
		DialogueLine.create(
			"Iris",
			"Let me have this, Garrick.",
		),
		DialogueLine.create(
			"Kael",
			"This isn't old. This stuff was placed here"
			+ " weeks ago. Maybe a month?",
		),
		DialogueLine.create(
			"Lyra",
			"A supply cache for agents. Standard"
			+ " Initiative protocol. They must have had"
			+ " people moving through this corridor"
			+ " regularly.",
		),
		DialogueLine.create(
			"Iris",
			"Until they didn't. Something pulled them"
			+ " back. Fast.",
		),
		DialogueLine.create(
			"Nyx",
			"Someone small was here. And they drew what"
			+ " they wanted.",
		),
		DialogueLine.create(
			"Garrick",
			"We should resupply and move on.",
		),
		DialogueLine.create(
			"Kael",
			"They were doing it even then. The Initiative."
			+ " Hollowing people.",
		),
		DialogueLine.create(
			"Iris",
			"Lab Seven is a designation I know. It's"
			+ " Sienna Vex's old project. Resonance battery"
			+ " research. Turn people into living power"
			+ " cells.",
		),
		DialogueLine.create(
			"Kael",
			"And Sienna's still in there. Still working"
			+ " for them.",
		),
		DialogueLine.create(
			"Iris",
			"She's the Director's sister. Where else"
			+ " would she be?",
		),
	]


## Scene 4 — The Border: Ironcoast checkpoint, first glimpse.
static func compute_border_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"This is checkpoint seven-seven. I've been"
			+ " through here a dozen times.",
		),
		DialogueLine.create(
			"Kael",
			"It's empty.",
		),
		DialogueLine.create(
			"Iris",
			"It shouldn't be. This checkpoint had a"
			+ " twelve-person rotation. Sensors, ID"
			+ " scanners, the works.",
		),
		DialogueLine.create(
			"Garrick",
			"Crystal fire. Purification charges."
			+ " Shepherd-issue.",
		),
		DialogueLine.create(
			"Iris",
			"Shepherds hit an Initiative checkpoint this"
			+ " deep into Federation territory?",
		),
		DialogueLine.create(
			"Garrick",
			"Things are moving faster than we thought.",
		),
		DialogueLine.create(
			"Kael",
			"I've never seen anything that big.",
		),
		DialogueLine.create(
			"Lyra",
			"Gearhaven. Fifty thousand people. The beating"
			+ " mechanical heart of the Ironcoast"
			+ " Federation. It was a fishing village before"
			+ " the Severance. Just boats and nets and a"
			+ " market on Sundays.",
		),
		DialogueLine.create(
			"Nyx",
			"It's like someone built a forest out of"
			+ " metal and forgot to stop.",
		),
		DialogueLine.create(
			"Iris",
			"Home sweet home.",
		),
		DialogueLine.create(
			"Garrick",
			"We'll need to be careful. Iris is a known"
			+ " deserter. Kael's face is probably on"
			+ " Initiative networks by now.",
		),
		DialogueLine.create(
			"Iris",
			"I know a way in through the Harbor district."
			+ " It'll cost us, but the smugglers there"
			+ " don't ask questions.",
		),
	]


## Camp — What Nobody Asked: Iris on Dane, Nyx offers to hold Lyra.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"When's the last time you were home?",
		),
		DialogueLine.create(
			"Iris",
			"Gearhaven isn't home. It's where I grew up."
			+ " There's a difference.",
		),
		DialogueLine.create(
			"Iris",
			"My brother's still down there somewhere."
			+ " Dane. Still wearing the uniform. Still"
			+ " saluting people who'd sell him for parts"
			+ " if the quarterly numbers dipped.",
		),
		DialogueLine.create(
			"Iris",
			"He sent me a message after I deserted. One"
			+ " word. \"Why.\"",
		),
		DialogueLine.create(
			"Garrick",
			"Did you answer?",
		),
		DialogueLine.create(
			"Iris",
			"What was I supposed to say? Because your"
			+ " bosses are monsters and you're too loyal"
			+ " to see it? Because I watched Subject"
			+ " Fourteen stop screaming on a Tuesday and"
			+ " it was the silence that broke me?",
		),
		DialogueLine.create(
			"Iris",
			"No. I didn't answer.",
		),
		DialogueLine.create(
			"Kael",
			"We'll find a way to--",
		),
		DialogueLine.create(
			"Iris",
			"Don't. Don't promise me things about my"
			+ " brother. I've been handling this since"
			+ " before you knew what an Anchor was.",
		),
		DialogueLine.create(
			"Iris",
			"Sorry. That was unfair. You didn't ask for"
			+ " any of this.",
		),
		DialogueLine.create(
			"Kael",
			"Neither did you.",
		),
		DialogueLine.create(
			"Nyx",
			"Lyra. Can I ask you something?",
		),
		DialogueLine.create(
			"Lyra",
			"Always, little one.",
		),
		DialogueLine.create(
			"Nyx",
			"Are you scared?",
		),
		DialogueLine.create(
			"Lyra",
			"I suppose I am. Finding Kael's Anchor"
			+ " signature was clarifying. But it also made"
			+ " my own fragmentation worse. The more I"
			+ " connect to the network, the more I risk"
			+ " losing the pieces I've gathered.",
		),
		DialogueLine.create(
			"Nyx",
			"So getting better makes you worse?",
		),
		DialogueLine.create(
			"Lyra",
			"In a manner of speaking.",
		),
		DialogueLine.create(
			"Nyx",
			"That seems poorly designed.",
		),
		DialogueLine.create(
			"Nyx",
			"If you start to break apart again... I could"
			+ " hold your pieces. In my memory. Is that..."
			+ " would that be weird?",
		),
		DialogueLine.create(
			"Lyra",
			"No, Nyx. That wouldn't be weird. That would"
			+ " be very kind.",
		),
	]


## Scene 5 — Ghost Protocol: smuggler Zen, harbor entry.
static func compute_harbor_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Zen",
			"Iris Mantle. As I live and moderately"
			+ " prosper.",
		),
		DialogueLine.create(
			"Iris",
			"Zen.",
		),
		DialogueLine.create(
			"Zen",
			"You look terrible. Last I heard, Initiative"
			+ " had a bounty on you that'd buy a nice"
			+ " apartment in the High Rise.",
		),
		DialogueLine.create(
			"Zen",
			"Friends of yours? Old guy looks like he"
			+ " could bench-press my boat.",
		),
		DialogueLine.create(
			"Garrick",
			"She's not wrong.",
		),
		DialogueLine.create(
			"Zen",
			"Five hundred credits gets you past the"
			+ " harbor checkpoints. Another two hundred"
			+ " gets you a safehouse for the night.",
		),
		DialogueLine.create(
			"Iris",
			"Three hundred total and I fix the port"
			+ " stabilizer on your boat.",
		),
		DialogueLine.create(
			"Zen",
			"Four hundred. And you fix the stabilizer"
			+ " AND the radar array.",
		),
		DialogueLine.create(
			"Iris",
			"Done.",
		),
		DialogueLine.create(
			"Zen",
			"So. Iris Mantle walks back into Gearhaven"
			+ " with a circus troupe. Must be something"
			+ " big.",
		),
		DialogueLine.create(
			"Zen",
			"There's been talk in the Undercity. Someone"
			+ " who's been hitting Initiative servers for"
			+ " months. Data theft, system disruptions."
			+ " Initiative's furious.",
		),
		DialogueLine.create(
			"Zen",
			"Word is this hacker doesn't use any tools."
			+ " Just touches a server and it talks to them.",
		),
		DialogueLine.create(
			"Kael",
			"Resonance interfacing.",
		),
		DialogueLine.create(
			"Zen",
			"The Undercity. Beneath the factory district."
			+ " If your hacker is anywhere, they're down"
			+ " there.",
		),
		DialogueLine.create(
			"Zen",
			"Last time I helped someone the Initiative"
			+ " wanted, I lost this. Next time, they'll"
			+ " take something I need. So whatever you're"
			+ " doing... do it fast.",
		),
	]


## Scene 6 — The Weight of Names: planning the Undercity descent.
static func compute_planning_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"Zen pointed us at three Undercity locations."
			+ " This bar, this abandoned server farm, and"
			+ " this maintenance junction.",
		),
		DialogueLine.create(
			"Garrick",
			"We don't split up.",
		),
		DialogueLine.create(
			"Iris",
			"I was going to say that.",
		),
		DialogueLine.create(
			"Kael",
			"Which one do we hit first?",
		),
		DialogueLine.create(
			"Iris",
			"The bar. The Broken Clock. Undercity"
			+ " watering hole. If this hacker is local,"
			+ " someone there will know something.",
		),
		DialogueLine.create(
			"Nyx",
			"I have never had a drink. What do they"
			+ " taste like?",
		),
		DialogueLine.create(
			"Iris",
			"You're not having a drink. You're keeping"
			+ " your hood up and not talking.",
		),
		DialogueLine.create(
			"Kael",
			"She's not wrong about the danger, Nyx. But"
			+ " we're not ashamed of you. We just need to"
			+ " be careful.",
		),
		DialogueLine.create(
			"Nyx",
			"Okay. I will be a careful shadow.",
		),
		DialogueLine.create(
			"Lyra",
			"I should stay behind as well. My form is too"
			+ " recognizable. Any Resonance-sensitive"
			+ " individual would register my presence"
			+ " immediately.",
		),
		DialogueLine.create(
			"Kael",
			"Are you going to be okay alone?",
		),
		DialogueLine.create(
			"Lyra",
			"I've been alone for three hundred years,"
			+ " Kael. A few hours won't hurt.",
		),
		DialogueLine.create(
			"Kael",
			"We'll come back.",
		),
		DialogueLine.create(
			"Lyra",
			"I know you will. That's not something I've"
			+ " had reason to say in a very long time.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 1: What We Carried Out — camp silence, Kael breaks
	DialogueManager.start_dialogue(compute_silence_lines())
	await DialogueManager.dialogue_ended

	# Scene 2: What We're Running From — dawn argument
	DialogueManager.start_dialogue(compute_dawn_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: The Waystation — supply cache, Echo
	DialogueManager.start_dialogue(compute_waystation_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: The Border — Ironcoast checkpoint
	DialogueManager.start_dialogue(compute_border_lines())
	await DialogueManager.dialogue_ended

	# Camp: What Nobody Asked — Iris on Dane, Nyx/Lyra
	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	# Scene 5: Ghost Protocol — smuggler Zen
	DialogueManager.start_dialogue(compute_harbor_lines())
	await DialogueManager.dialogue_ended

	# Scene 6: The Weight of Names — planning
	DialogueManager.start_dialogue(compute_planning_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

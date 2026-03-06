class_name WeightOfChoice
extends Node

## Chapter 16 — "The Weight of Choice" full event.
## Post-siege breathing chapter. Character moments and departure.
##   Scene 1: Recovery — morning routines in post-siege Emberhearth.
##   Scene 2: Iris's Silence — Iris learns Dane hunts them.
##   Scene 3: The Book of Names — Sienna and Garrick share guilt.
##   Scene 4: What Nyx Learned — Nyx and Ash process the first kill.
##   Scene 5: Cipher Can't Sleep — Lyra reaches Cipher.
##   Scene 6: Departure — farewell from Emberhearth, Hollows journey begins.
## Gate: siege_survived AND NOT weight_chosen.
## Sets weight_chosen flag.

signal sequence_completed

const FLAG_NAME: String = "weight_chosen"


static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("siege_survived", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 1 — Recovery: morning routines in post-siege Emberhearth.
static func compute_recovery_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"The gate mechanism is fixed. Again. It wasn't"
			+ " broken again. I fixed it again anyway.",
		),
		DialogueLine.create(
			"Kael",
			"How many times is that?",
		),
		DialogueLine.create(
			"Iris",
			"Three. It's a good gate. It deserves a good"
			+ " lock. The reconstruction is coming along --"
			+ " the Forge Quarter was up within a day.",
		),
		DialogueLine.create(
			"Garrick",
			"The militia is improving. Half of them had"
			+ " never held a weapon before the siege. Now"
			+ " they hold them like they understand what"
			+ " they mean.",
		),
		DialogueLine.create(
			"Cipher",
			"I've rebuilt the communication network and"
			+ " improved throughput by roughly four hundred"
			+ " percent. Nobody asked me to. I did it"
			+ " because stopping means thinking.",
		),
		DialogueLine.create(
			"Sienna",
			"Forty-three crystal-disruption cases treated."
			+ " Twelve severe. All stable. The reconstruction"
			+ " of the medical ward is functional, if not"
			+ " elegant.",
		),
		DialogueLine.create(
			"Kael",
			"Everyone's rebuilding. Nobody's celebrating.",
		),
		DialogueLine.create(
			"Garrick",
			"War doesn't make heroes. It makes people who"
			+ " need a very long nap.",
		),
	]


## Scene 2 — Iris's Silence: Iris learns Dane hunts them.
static func compute_iris_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"You've been up here since dawn.",
		),
		DialogueLine.create(
			"Iris",
			"Best view in the city. Minus the bloodstains.",
		),
		DialogueLine.create(
			"Iris",
			"I got a message. Cipher intercepted it from"
			+ " Initiative communications. It's about Dane.",
		),
		DialogueLine.create(
			"Kael",
			"Your brother.",
		),
		DialogueLine.create(
			"Iris",
			"He's been promoted. Special Operations"
			+ " Commander. My old unit. He's leading the"
			+ " team that's hunting us.",
		),
		DialogueLine.create(
			"Iris",
			"I keep trying to picture him -- the kid who"
			+ " used to make model airships out of scrap"
			+ " metal. Who cried when our dog died. Who told"
			+ " me I was the bravest person he knew when I"
			+ " got this arm.",
		),
		DialogueLine.create(
			"Kael",
			"He doesn't have to be your enemy, Iris.",
		),
		DialogueLine.create(
			"Iris",
			"He already is. He chose to stay. I chose to"
			+ " leave. Someday he's going to be standing on"
			+ " the other side of a fight and one of us is"
			+ " going to have to make a decision that breaks"
			+ " the other one.",
		),
		DialogueLine.create(
			"Iris",
			"I used to think desertion was the hardest"
			+ " thing I'd ever do. Turns out it was just"
			+ " the first hard thing in a line of hard"
			+ " things that doesn't end.",
		),
		DialogueLine.create(
			"Kael",
			"What do you need?",
		),
		DialogueLine.create(
			"Iris",
			"I need you to promise me something. If it"
			+ " comes to it -- if Dane is there and I can't"
			+ " -- promise me you won't let me throw away"
			+ " everything for him. Don't let me sacrifice"
			+ " the mission for my brother.",
		),
	]


## Scene 3 — The Book of Names: Sienna and Garrick share guilt.
static func compute_names_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"You should sleep.",
		),
		DialogueLine.create(
			"Sienna",
			"I'm cataloguing.",
		),
		DialogueLine.create(
			"Garrick",
			"You're punishing yourself.",
		),
		DialogueLine.create(
			"Sienna",
			"This book has two hundred and seven names."
			+ " Every patient I treated in Station Theta."
			+ " Every person whose Resonance battery"
			+ " integration I supervised. Every individual"
			+ " who passed through my laboratory and left"
			+ " as something less than they arrived.",
		),
		DialogueLine.create(
			"Sienna",
			"I know each name. Their ages, their former"
			+ " occupations, their baseline Resonance"
			+ " compatibility. I know everything about them"
			+ " except the things that matter -- who they"
			+ " loved, what they laughed at.",
		),
		DialogueLine.create(
			"Garrick",
			"You're trying to make them real again.",
		),
		DialogueLine.create(
			"Sienna",
			"They were always real. I was the one who"
			+ " wasn't.",
		),
		DialogueLine.create(
			"Garrick",
			"I have a number too. Forty-three. That's how"
			+ " many people died in the village I purged."
			+ " I went back to the village records, found"
			+ " every family. Wrote them down. Carried the"
			+ " list for twenty years.",
		),
		DialogueLine.create(
			"Sienna",
			"Did it help?",
		),
		DialogueLine.create(
			"Garrick",
			"Not even a little. But I'd do it again. The"
			+ " names deserve to be remembered by the person"
			+ " who took them. That's not penance. That's"
			+ " just accounting.",
		),
		DialogueLine.create(
			"Sienna",
			"How do you live with it? Practically. How do"
			+ " you get up in the morning and function while"
			+ " carrying forty-three names?",
		),
		DialogueLine.create(
			"Garrick",
			"You carry them until you can put them down."
			+ " You can only put them down by being someone"
			+ " who wouldn't make the same choice today.",
		),
		DialogueLine.create(
			"Sienna",
			"This tea is terrible.",
		),
		DialogueLine.create(
			"Garrick",
			"Cindral brew. Tastes like volcanic runoff.",
		),
		DialogueLine.create(
			"Sienna",
			"...Thank you, Garrick.",
		),
		DialogueLine.create(
			"Garrick",
			"Don't thank me. Drink the tea.",
		),
	]


## Scene 4 — What Nyx Learned: Nyx and Ash process the first kill.
static func compute_nyx_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Nyx",
			"I took a person apart. During the fight. A"
			+ " soldier came through the wall and I reached"
			+ " out with my power and they just came apart.",
		),
		DialogueLine.create(
			"Nyx",
			"Everyone says it was self-defense. But none of"
			+ " them saw it from where I was. I was inside"
			+ " the soldier's mind for a fraction of a"
			+ " second before they--",
		),
		DialogueLine.create(
			"Nyx",
			"They were thinking about soup. The soldier. In"
			+ " the last moment. Not about the battle or the"
			+ " Anchors. They were thinking about the soup"
			+ " their mother used to make on cold nights.",
		),
		DialogueLine.create(
			"Nyx",
			"I keep thinking about that soup. About someone"
			+ " who will never make it for them again and"
			+ " doesn't know why.",
		),
		DialogueLine.create(
			"Nyx",
			"You're very wise for someone who can't talk.",
		),
	]


## Scene 5 — Cipher Can't Sleep: Lyra reaches Cipher.
static func compute_cipher_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Lyra",
			"You haven't slept.",
		),
		DialogueLine.create(
			"Cipher",
			"Didn't ask for a wellness check.",
		),
		DialogueLine.create(
			"Lyra",
			"Your Resonance output is erratic. Your tattoo"
			+ " channels are burning at twenty percent above"
			+ " safe levels. If you don't rest, you'll burn"
			+ " out.",
		),
		DialogueLine.create(
			"Cipher",
			"I can't stop monitoring. The Initiative is"
			+ " regrouping. There are at least six encrypted"
			+ " signals bouncing around this region and the"
			+ " last time I stopped paying attention, twelve"
			+ " people with guns showed up at my home.",
		),
		DialogueLine.create(
			"Lyra",
			"The server farm wasn't your home. It was your"
			+ " bunker.",
		),
		DialogueLine.create(
			"Lyra",
			"I spent three hundred years fragmented."
			+ " Scattered across the world in pieces too"
			+ " small to think. I understand what it means"
			+ " to survive without living. And I recognize"
			+ " it when I see it.",
		),
		DialogueLine.create(
			"Cipher",
			"If I stop watching, someone might--",
		),
		DialogueLine.create(
			"Lyra",
			"Someone might. And you'll deal with it when"
			+ " they do. With six other people standing next"
			+ " to you. That's different from before. That's"
			+ " the whole point.",
		),
		DialogueLine.create(
			"Cipher",
			"I hate that you're right.",
		),
		DialogueLine.create(
			"Lyra",
			"I'm three hundred years old and composed of"
			+ " crystallized regret. Being right is the only"
			+ " perk.",
		),
		DialogueLine.create(
			"Cipher",
			"Fine. I'll try. But if something pings, I'm"
			+ " back on.",
		),
		DialogueLine.create(
			"Lyra",
			"Good night, Cipher.",
		),
		DialogueLine.create(
			"Cipher",
			"...Good night.",
		),
	]


## Scene 6 — Departure: farewell from Emberhearth.
static func compute_departure_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kamara",
			"You're taking our child into the heart of the"
			+ " world's wound.",
		),
		DialogueLine.create(
			"Garrick",
			"I know.",
		),
		DialogueLine.create(
			"Kamara",
			"If harm comes to them--",
		),
		DialogueLine.create(
			"Garrick",
			"It won't. I'd die first.",
		),
		DialogueLine.create(
			"Kamara",
			"Don't die, Three-Burns. Dying is easy."
			+ " Bringing them home -- that's the hard part.",
		),
		DialogueLine.create(
			"Kamara",
			"The fire goes with you. Remember what it"
			+ " means: the things that matter don't stop"
			+ " burning just because someone wants them out.",
		),
		DialogueLine.create(
			"Cipher",
			"I've set up a dead-drop communication relay."
			+ " Anything happens to the city, send a pulse"
			+ " on the sixty-four kilohertz channel.",
		),
		DialogueLine.create(
			"Kamara",
			"We don't need outsider technology to--",
		),
		DialogueLine.create(
			"Cipher",
			"It's backup. That's all. Backup is just care"
			+ " with extra steps.",
		),
		DialogueLine.create(
			"Sienna",
			"The crystal-disruption cases -- I've left"
			+ " detailed recovery protocols with your"
			+ " healers. The most critical cases should be"
			+ " monitored for resonance rebound--",
		),
		DialogueLine.create(
			"Kamara",
			"You wanted to make sure because you care."
			+ " That's enough. You don't need to dress it"
			+ " in clinical language.",
		),
		DialogueLine.create(
			"Sienna",
			"...Thank you. For letting us help.",
		),
		DialogueLine.create(
			"Kamara",
			"That's the first honest sentence you've said"
			+ " since you arrived. Keep practicing.",
		),
		DialogueLine.create(
			"Nyx",
			"Elder. The fire is beautiful. I've been"
			+ " thinking about it since I arrived and I"
			+ " wanted you to know that.",
		),
		DialogueLine.create(
			"Kamara",
			"Thank you, little star. May the ash be gentle"
			+ " on your path.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 1: Recovery — morning routines
	DialogueManager.start_dialogue(compute_recovery_lines())
	await DialogueManager.dialogue_ended

	# Scene 2: Iris's Silence — Dane revelation
	DialogueManager.start_dialogue(compute_iris_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: The Book of Names — Sienna and Garrick
	DialogueManager.start_dialogue(compute_names_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: What Nyx Learned — processing the kill
	DialogueManager.start_dialogue(compute_nyx_lines())
	await DialogueManager.dialogue_ended

	# Scene 5: Cipher Can't Sleep — Lyra reaches out
	DialogueManager.start_dialogue(compute_cipher_lines())
	await DialogueManager.dialogue_ended

	# Scene 6: Departure — farewell from Emberhearth
	DialogueManager.start_dialogue(compute_departure_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

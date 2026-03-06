class_name SiegeOfEmberhearth
extends Node

## Chapter 15 — "The Siege of Emberhearth" full event.
## Shepherd army besieges Emberhearth. Largest set-piece battle in the game.
## Inquisitor Markus Hale (Garrick's former student) leads the assault.
##   Scene 1: Dawn — pre-battle on the wall, Iris explains tactics.
##   Scene 2: Parley — Kael and Garrick negotiate with Hale.
##   Scene 3: The Siege — multi-front battle begins.
##   Scene 4: The Turn — Hale's second parley, turning point.
##   Scene 5: After — walking the damage, Nyx's first kill.
##   Camp: What the Shepherds Said — the uncomfortable truth.
## Gate: ash_found AND NOT siege_survived.
## Sets siege_survived flag.

signal sequence_completed

const FLAG_NAME: String = "siege_survived"


static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("ash_found", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 1 — Dawn: pre-battle on the wall.
static func compute_dawn_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"Cannon range is roughly eight hundred meters."
			+ " They'll set up at five hundred for accuracy."
			+ " First volley targets the gate -- standard"
			+ " Shepherd siege doctrine. Second volley goes"
			+ " wide -- disruption field, kills the power"
			+ " grid.",
		),
		DialogueLine.create(
			"Kael",
			"How long can we hold the wall?",
		),
		DialogueLine.create(
			"Iris",
			"With what we have? An hour. Maybe two if the"
			+ " militia holds and the barricades do their"
			+ " job. The wall isn't the problem -- it's the"
			+ " disruption field. Once they knock out our"
			+ " Resonance systems, we lose medical, lighting,"
			+ " water purification, and half our combat"
			+ " abilities.",
		),
		DialogueLine.create(
			"Garrick",
			"There are five hundred Shepherds out there."
			+ " Most of them are young. Most of them believe"
			+ " they're doing the right thing. Most of them"
			+ " have never killed anyone.",
		),
		DialogueLine.create(
			"Iris",
			"Is that supposed to make me feel better about"
			+ " fighting them?",
		),
		DialogueLine.create(
			"Garrick",
			"It's supposed to make you remember they're"
			+ " people when the fighting starts. Because"
			+ " once it starts, remembering gets hard.",
		),
		DialogueLine.create(
			"Kael",
			"They want to talk?",
		),
		DialogueLine.create(
			"Garrick",
			"It's protocol. Before any Shepherd operation,"
			+ " the Inquisitor offers the target a chance to"
			+ " surrender. It's considered merciful.",
		),
		DialogueLine.create(
			"Iris",
			"Merciful.",
		),
		DialogueLine.create(
			"Garrick",
			"That's what we told ourselves.",
		),
	]


## Scene 2 — Parley: Kael and Garrick negotiate with Hale.
static func compute_parley_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Hale",
			"Master Thorne. I was told you might be here."
			+ " I hoped the reports were wrong.",
		),
		DialogueLine.create(
			"Garrick",
			"They weren't.",
		),
		DialogueLine.create(
			"Hale",
			"You look well. Older. Less righteous.",
		),
		DialogueLine.create(
			"Garrick",
			"One out of two isn't bad.",
		),
		DialogueLine.create(
			"Hale",
			"I'll be direct. Prophet Null has declared the"
			+ " entity known as Ash to be a critical threat"
			+ " to human survival. A Resonance Anchor -- one"
			+ " of three nexus points that could enable the"
			+ " Convergence to reform.",
		),
		DialogueLine.create(
			"Garrick",
			"I know that's one possibility. I also know"
			+ " it's not the only one.",
		),
		DialogueLine.create(
			"Hale",
			"The Shepherds have debated this extensively."
			+ " The consensus is clear: the Anchors represent"
			+ " an existential threat. The compassionate"
			+ " choice is to neutralize them before the"
			+ " Convergence can use them.",
		),
		DialogueLine.create(
			"Hale",
			"You're Kael Voss. The first Anchor. I want"
			+ " you to know -- I don't consider you a"
			+ " monster. I consider you a tragedy.",
		),
		DialogueLine.create(
			"Kael",
			"There is another way. We just haven't found"
			+ " it yet.",
		),
		DialogueLine.create(
			"Hale",
			"And how many people die while you search? The"
			+ " Convergence is reforming. Every day it gets"
			+ " stronger. Every day more people go Hollow."
			+ " The rate is accelerating.",
		),
		DialogueLine.create(
			"Hale",
			"I came here to ask you to surrender the child."
			+ " Not to die -- to be placed under Shepherd"
			+ " protection. No one has to die today.",
		),
		DialogueLine.create(
			"Garrick",
			"You mean contained the way the Shepherds"
			+ " contained the heretics in Thorngate? Markus,"
			+ " I was there. I led that operation.",
		),
		DialogueLine.create(
			"Garrick",
			"The Prophet of Silence, the leader of the"
			+ " anti-crystal crusade, is becoming what she"
			+ " hates most. Whatever she told you about safe"
			+ " containment -- ask her how she contains"
			+ " herself.",
		),
		DialogueLine.create(
			"Garrick",
			"You're a good man, Markus. I didn't teach you"
			+ " to be a good man -- you were already one"
			+ " when I found you. But good people following"
			+ " frightened leaders do the worst things in"
			+ " history. I should know. I did them.",
		),
		DialogueLine.create(
			"Hale",
			"I'm giving you until noon. Surrender the"
			+ " Anchor and the city is spared. After noon"
			+ " I'll do what I came to do. Not because I"
			+ " want to. Because the alternative is worse.",
		),
		DialogueLine.create(
			"Kael",
			"Hale. The Anchors aren't just weapons. Ash is"
			+ " an eight-year-old kid who draws pictures and"
			+ " can't talk and is scared of loud noises."
			+ " They didn't ask for any of this.",
		),
		DialogueLine.create(
			"Hale",
			"Neither did I.",
		),
	]


## Scene 3 — The Siege: multi-front battle begins.
static func compute_siege_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"The purification cannons just fired. Southern"
			+ " gate is hit -- stone cracked, defenders down."
			+ " Second volley incoming -- disruption wave.",
		),
		DialogueLine.create(
			"Iris",
			"Resonance systems are down. All of them."
			+ " Medical, lighting, water. We're fighting"
			+ " analog now.",
		),
		DialogueLine.create(
			"Garrick",
			"Boy. Put the spear down.",
		),
		DialogueLine.create(
			"Shepherd Soldier",
			"I have orders--",
		),
		DialogueLine.create(
			"Garrick",
			"You have a choice. Right now, in this moment,"
			+ " you have a choice. Take it.",
		),
		DialogueLine.create(
			"Cipher",
			"I can reactivate the old surveillance grid on"
			+ " the eastern side. Give me thirty seconds and"
			+ " I'll know exactly where every one of them--",
		),
		DialogueLine.create(
			"Cipher",
			"Okay, ten seconds. Working fast here.",
		),
		DialogueLine.create(
			"Sienna",
			"The disruption charges have a seventeen-second"
			+ " recharge cycle between detonations. That's"
			+ " our window.",
		),
		DialogueLine.create(
			"Nyx",
			"You don't have to hold everyone. Let me help.",
		),
		DialogueLine.create(
			"Nyx",
			"I know. But you're not alone. That's what Kael"
			+ " keeps telling me and I'm starting to believe"
			+ " it.",
		),
		DialogueLine.create(
			"Iris",
			"They're pulling back to regroup. We've got"
			+ " maybe three minutes.",
		),
		DialogueLine.create(
			"Garrick",
			"The Elites will be next. They won't hesitate"
			+ " like the infantry.",
		),
	]


## Scene 4 — The Turn: Hale's second parley, turning point.
static func compute_turn_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Hale",
			"Your people fight well. I've lost forty"
			+ " soldiers. Forty good people. And for what?"
			+ " You're not going to surrender the child.",
		),
		DialogueLine.create(
			"Garrick",
			"No.",
		),
		DialogueLine.create(
			"Hale",
			"Then what are we doing, Master Thorne? How"
			+ " many more people die today? On both sides?",
		),
		DialogueLine.create(
			"Garrick",
			"Markus. I taught you the Shepherd way. Fire"
			+ " purifies. Silence liberates. The crystal is"
			+ " the enemy of the human soul. And I believed"
			+ " every word of it, right up until the moment"
			+ " I realized that the worst things I'd ever"
			+ " done were the things I'd done in the name"
			+ " of belief.",
		),
		DialogueLine.create(
			"Hale",
			"This isn't about belief. It's about survival.",
		),
		DialogueLine.create(
			"Garrick",
			"It's always about survival. That's what we"
			+ " tell ourselves when we do monstrous things."
			+ " We had no choice. But there's always a"
			+ " choice. The choice might be terrible. But it"
			+ " exists.",
		),
		DialogueLine.create(
			"Hale",
			"You're asking me to disobey a direct order"
			+ " from Prophet Null. To stand down while an"
			+ " Anchor grows more powerful every day.",
		),
		DialogueLine.create(
			"Kael",
			"I'm asking you to give us time. We're looking"
			+ " for a third way. Not the Initiative's cage,"
			+ " not the Shepherds' destruction. Something"
			+ " that doesn't require anyone to die.",
		),
		DialogueLine.create(
			"Hale",
			"And if you fail?",
		),
		DialogueLine.create(
			"Kael",
			"Then you can come back. You know where we are."
			+ " But today -- right now -- you can choose not"
			+ " to be the person who kills a city to reach"
			+ " a child.",
		),
	]


## Scene 5 — After: walking the damage, Nyx's first kill.
static func compute_after_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Nyx? You okay?",
		),
		DialogueLine.create(
			"Nyx",
			"I killed someone today. On the eastern"
			+ " approach. A soldier came through the tunnel"
			+ " and I -- I didn't mean to. My power just"
			+ " went. And they stopped moving.",
		),
		DialogueLine.create(
			"Nyx",
			"Garrick says killing in defense of others is"
			+ " different from killing in hatred. Iris says"
			+ " killing is killing and you carry it either"
			+ " way. Sienna says the biological response to"
			+ " lethal force varies by individual. None of"
			+ " them are wrong and none of them are enough.",
		),
		DialogueLine.create(
			"Kael",
			"No. They're not.",
		),
		DialogueLine.create(
			"Nyx",
			"How do you carry something that doesn't have"
			+ " a good answer?",
		),
		DialogueLine.create(
			"Kael",
			"You just do. And you try to make sure next"
			+ " time, if there's another way, you find it.",
		),
		DialogueLine.create(
			"Nyx",
			"That's what Garrick says.",
		),
		DialogueLine.create(
			"Kael",
			"Garrick's usually right. Even when it doesn't"
			+ " help.",
		),
	]


## Camp — What the Shepherds Said: the uncomfortable truth.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"Hale wasn't wrong.",
		),
		DialogueLine.create(
			"Iris",
			"About the Convergence. About the risk. The"
			+ " ambient Resonance levels are rising. People"
			+ " are going Hollow at accelerating rates. If"
			+ " the Convergence reforms unchecked -- he's"
			+ " right. It could dissolve individual"
			+ " consciousness.",
		),
		DialogueLine.create(
			"Iris",
			"I'm not saying the siege was justified. I'm"
			+ " saying the fear behind it is real. We just"
			+ " fought off five hundred people and I killed"
			+ " some of them and I need that to have been"
			+ " for something more than just we disagree"
			+ " about methodology.",
		),
		DialogueLine.create(
			"Sienna",
			"The Hollowing acceleration is real. At current"
			+ " rates, mass Hollowing begins in fourteen to"
			+ " eighteen months. The people most at risk are"
			+ " those in high-Resonance environments."
			+ " Gearhaven. Prismfall. Any settlement near"
			+ " crystal deposits.",
		),
		DialogueLine.create(
			"Garrick",
			"So both sides are right that there's a"
			+ " problem. They're wrong about the solution.",
		),
		DialogueLine.create(
			"Kael",
			"Then we need to find the right one. Before"
			+ " someone else finds the wrong one first.",
		),
		DialogueLine.create(
			"Cipher",
			"That's incredibly vague and unhelpful.",
		),
		DialogueLine.create(
			"Kael",
			"I know. But it's honest. I don't have a plan."
			+ " I have a direction. We go into the Hollows."
			+ " We find the Convergence. And instead of"
			+ " trying to cage it or kill it, we talk to"
			+ " it.",
		),
		DialogueLine.create(
			"Sienna",
			"You want to negotiate with a collective"
			+ " consciousness that may or may not be"
			+ " sentient in any recognizable sense.",
		),
		DialogueLine.create(
			"Kael",
			"Yes.",
		),
		DialogueLine.create(
			"Cipher",
			"The Hollows. I've been avoiding the Hollows"
			+ " my whole life. Every Anchor instinct I have"
			+ " screams to stay away from the center.",
		),
		DialogueLine.create(
			"Kael",
			"We'll go together. All of us.",
		),
		DialogueLine.create(
			"Iris",
			"Famous last words.",
		),
		DialogueLine.create(
			"Kael",
			"Probably. But they're our famous last words,"
			+ " and that counts for something.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 1: Dawn — pre-battle on the wall
	DialogueManager.start_dialogue(compute_dawn_lines())
	await DialogueManager.dialogue_ended

	# Scene 2: Parley — negotiation with Hale
	DialogueManager.start_dialogue(compute_parley_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: The Siege — multi-front battle
	DialogueManager.start_dialogue(compute_siege_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: The Turn — Hale's second parley
	DialogueManager.start_dialogue(compute_turn_lines())
	await DialogueManager.dialogue_ended

	# Scene 5: After — walking the damage
	DialogueManager.start_dialogue(compute_after_lines())
	await DialogueManager.dialogue_ended

	# Camp: What the Shepherds Said
	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

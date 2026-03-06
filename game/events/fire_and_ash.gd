class_name FireAndAsh
extends Node

## Chapter 14 — "Fire and Ash" full event.
## Party reaches Emberhearth, finds Ash (the third Anchor),
## Garrick confronts his past, Shepherd army arrives.
##   Scene 1: Homecoming — Garrick's return to the Wastes.
##   Scene 2: Through the Gates — Emberhearth arrival.
##   Scene 3: The Ash Walkers' Fire — Garrick faces Elder Kamara.
##   Scene 4: Ash — meeting the child.
##   Scene 5: The Warning — Shepherd army incoming.
##   Scene 6: Two Days — preparation montage.
##   Scene 7: The Horizon — the army arrives.
##   Camp: What Fire Means — Kael and Ash at the fire.
## Gate: sienna_defected AND NOT ash_found.
## Sets ash_found flag.

signal sequence_completed

const FLAG_NAME: String = "ash_found"
const ASH_DATA_PATH: String = "res://data/characters/ash.tres"


static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("sienna_defected", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 1 — Homecoming: Garrick's return to the Wastes.
static func compute_homecoming_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"The ambient temperature is thirty-eight"
			+ " degrees. The Resonance background radiation"
			+ " is elevated by roughly forty percent. How"
			+ " do people live here?",
		),
		DialogueLine.create(
			"Garrick",
			"Carefully.",
		),
		DialogueLine.create(
			"Garrick",
			"Twenty years since I was last in the Wastes."
			+ " I did my first Shepherd purge here. I was"
			+ " nineteen and convinced I was saving the"
			+ " world.",
		),
		DialogueLine.create(
			"Kael",
			"What happened?",
		),
		DialogueLine.create(
			"Garrick",
			"I burned a shrine. The Ash Walkers' central"
			+ " fire. I put it out with purification crystal"
			+ " and told them they were free from the"
			+ " corruption of Resonance.",
		),
		DialogueLine.create(
			"Garrick",
			"They rebuilt it the next day. I came back and"
			+ " burned it again. They rebuilt it again.",
		),
		DialogueLine.create(
			"Garrick",
			"And an old woman -- the clan elder -- she"
			+ " just looked at me. Didn't say a word."
			+ " Looked at me like I was a child throwing"
			+ " a tantrum. And I realized that's exactly"
			+ " what I was.",
		),
		DialogueLine.create(
			"Iris",
			"Did you burn it a third time?",
		),
		DialogueLine.create(
			"Garrick",
			"Yes. I was nineteen and the Shepherd creed"
			+ " said crystal worship was sin. But I"
			+ " couldn't look at her again. I sent a"
			+ " subordinate.",
		),
		DialogueLine.create(
			"Garrick",
			"I'm going to walk into that city and see"
			+ " people who remember what I did. They won't"
			+ " have forgotten. Ash Walkers don't forget.",
		),
		DialogueLine.create(
			"Kael",
			"Will they help us?",
		),
		DialogueLine.create(
			"Garrick",
			"They'll hear us out. But help? That depends"
			+ " on whether I can face what I owe them.",
		),
	]


## Scene 2 — Through the Gates: Emberhearth arrival.
static func compute_gates_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Gate Guard",
			"Thorne.",
		),
		DialogueLine.create(
			"Garrick",
			"Hello, Ember.",
		),
		DialogueLine.create(
			"Gate Guard",
			"You've got nerve coming back to the caldera."
			+ " You know what they call you in the Rim?"
			+ " Three-Burns Thorne. The Shepherd who"
			+ " couldn't take a hint.",
		),
		DialogueLine.create(
			"Gate Guard",
			"You're not wearing the white anymore."
			+ " Shield's defaced. That real, or costume?",
		),
		DialogueLine.create(
			"Garrick",
			"It's real.",
		),
		DialogueLine.create(
			"Gate Guard",
			"The elders will want to see you. Don't touch"
			+ " the sacred fires, don't disrespect the ash"
			+ " grounds, and don't bring anything weird"
			+ " into the Deep without clearance.",
		),
		DialogueLine.create(
			"Nyx",
			"*(Whispering to Kael.)* Am I weird?",
		),
		DialogueLine.create(
			"Kael",
			"*(Whispering back.)* A little.",
		),
		DialogueLine.create(
			"Sienna",
			"The thermal energy output from the caldera"
			+ " vent is sufficient to power a city five"
			+ " times this size. And they use it for"
			+ " cooking and heating.",
		),
		DialogueLine.create(
			"Iris",
			"Maybe they've got their priorities straight.",
		),
		DialogueLine.create(
			"Cipher",
			"Initiative has people here. I'm picking up"
			+ " three encrypted communication nodes."
			+ " Someone's watching.",
		),
		DialogueLine.create(
			"Kael",
			"We knew they'd be here. We need to find the"
			+ " Anchor before they do.",
		),
	]


## Scene 3 — The Ash Walkers' Fire: Garrick faces Kamara.
static func compute_elders_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kamara",
			"Three-Burns. You got old.",
		),
		DialogueLine.create(
			"Garrick",
			"So did you.",
		),
		DialogueLine.create(
			"Kamara",
			"I earned my years. You owe yours.",
		),
		DialogueLine.create(
			"Garrick",
			"I do. I owe a debt to this fire and to this"
			+ " clan that I can never repay.",
		),
		DialogueLine.create(
			"Kamara",
			"The fire forgives. The ash remembers. That"
			+ " is the Walker way. You are forgiven,"
			+ " Three-Burns. You are not forgotten.",
		),
		DialogueLine.create(
			"Garrick",
			"Thank you, Elder.",
		),
		DialogueLine.create(
			"Kamara",
			"Don't thank me. I didn't do it for you."
			+ " Carrying grudges makes the walk harder,"
			+ " and this old woman's knees aren't what"
			+ " they were.",
		),
		DialogueLine.create(
			"Kamara",
			"And this one. Your hands burn, don't they?"
			+ " You're not an Echo Hunter. You're something"
			+ " the fire hasn't named yet.",
		),
		DialogueLine.create(
			"Kael",
			"We're looking for someone. A child.",
		),
		DialogueLine.create(
			"Kamara",
			"I know who you're looking for. Come."
			+ " Both of you.",
		),
	]


## Scene 4 — Ash: meeting the child.
static func compute_meeting_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kamara",
			"Ash came to us two years ago. Found"
			+ " wandering the Scorched Road. No parents."
			+ " No memory. Couldn't speak -- not wouldn't,"
			+ " couldn't. Something in them doesn't"
			+ " translate into words.",
		),
		DialogueLine.create(
			"Kamara",
			"But they speak in other ways. You'll feel"
			+ " it. Everyone does. Some find it beautiful."
			+ " Some find it terrifying. I find it both.",
		),
		DialogueLine.create(
			"Kael",
			"I'm Kael. I'm like you, I think. I don't"
			+ " really understand what I am either.",
		),
		DialogueLine.create(
			"Kael",
			"*(To Kamara.)* They knew we were coming."
			+ " They drew us -- two figures connected by"
			+ " fire.",
		),
		DialogueLine.create(
			"Kamara",
			"Ash always knows. They don't understand time"
			+ " the way we do. Past, present, future --"
			+ " it's all one feeling to them.",
		),
		DialogueLine.create(
			"Garrick",
			"Excuse me.",
		),
		DialogueLine.create(
			"Kamara",
			"The fire forgives, but it doesn't lie. That"
			+ " child knows what's in your old Shepherd's"
			+ " heart. And what they found there was good."
			+ " Tell him that, when he's ready to hear it.",
		),
	]


## Scene 5 — The Warning: Shepherd army incoming.
static func compute_warning_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"We have a problem. Several problems. Ranked"
			+ " by severity.",
		),
		DialogueLine.create(
			"Iris",
			"Go.",
		),
		DialogueLine.create(
			"Cipher",
			"Problem one: Initiative operatives have"
			+ " identified Ash. Extraction team arriving in"
			+ " three days.",
		),
		DialogueLine.create(
			"Cipher",
			"Problem two. Shepherd army. Coming from the"
			+ " south. Five hundred armed. Crystal"
			+ " purification weapons, siege equipment."
			+ " Led by an Inquisitor named Markus Hale.",
		),
		DialogueLine.create(
			"Garrick",
			"I trained him. Twenty years ago. He was my"
			+ " protege. Fast learner. Absolute believer.",
		),
		DialogueLine.create(
			"Cipher",
			"Your protege has a kill order. Direct from"
			+ " Prophet Null. Eliminate Asset Ember at all"
			+ " costs. The third Anchor must not reach the"
			+ " heretics.",
		),
		DialogueLine.create(
			"Sienna",
			"Five hundred soldiers against a city of"
			+ " fifteen thousand. The caldera walls provide"
			+ " natural defense, but if they have"
			+ " purification cannons--",
		),
		DialogueLine.create(
			"Iris",
			"They won't need to breach the walls."
			+ " Purification cannons fire"
			+ " crystal-disruptive charges at range."
			+ " Everything in Emberhearth that uses"
			+ " Resonance shuts down. They don't need to"
			+ " storm the city. They just need to kill it"
			+ " slowly.",
		),
		DialogueLine.create(
			"Kael",
			"How long do we have?",
		),
		DialogueLine.create(
			"Garrick",
			"The Wastes don't break weather for anyone."
			+ " Two days.",
		),
	]


## Scene 6 — Two Days: preparation vignettes.
static func compute_preparation_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"The purification charges disrupt"
			+ " crystal-based systems. So we go analog."
			+ " Barricades -- physical. Weapons -- steel,"
			+ " volcanic glass. If the lights go out, you"
			+ " fight in the dark.",
		),
		DialogueLine.create(
			"Cipher",
			"Crystal relay on the southern rim, signal"
			+ " bouncer on the eastern approach, data tap"
			+ " on the Initiative node. Two-day deadline."
			+ " Should have given me a real challenge.",
		),
		DialogueLine.create(
			"Sienna",
			"The purification charges will cause acute"
			+ " Resonance disruption in anyone with crystal"
			+ " integration. That's approximately forty"
			+ " percent of the population.",
		),
		DialogueLine.create(
			"Sienna",
			"What I mean is -- a lot of people are going"
			+ " to feel very sick very quickly, and we need"
			+ " to be ready to help them.",
		),
		DialogueLine.create(
			"Garrick",
			"I owe you more than that. But it's a start.",
		),
		DialogueLine.create(
			"Kael",
			"Yeah, yeah. Not everyone's an artist.",
		),
	]


## Scene 7 — The Horizon: the army arrives.
static func compute_horizon_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"I count flags. White and gray. Shepherd"
			+ " colors. Fifteen unit pennants.",
		),
		DialogueLine.create(
			"Garrick",
			"Five hundred. Like Cipher said.",
		),
		DialogueLine.create(
			"Iris",
			"Siege equipment. Two purification cannons on"
			+ " wagon mounts. And a figure out front, on a"
			+ " ridge. Just standing there.",
		),
		DialogueLine.create(
			"Garrick",
			"Markus.",
		),
		DialogueLine.create(
			"Kael",
			"What do we do?",
		),
		DialogueLine.create(
			"Garrick",
			"We fight. Or we run. Those are the two"
			+ " things you can do when someone comes for"
			+ " what you're protecting.",
		),
		DialogueLine.create(
			"Garrick",
			"Which one are we?",
		),
		DialogueLine.create(
			"Kael",
			"We're the kind that stays.",
		),
	]


## Camp — What Fire Means: Kael and Ash at the fire.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"There are people coming who want to hurt"
			+ " you. Not because you've done anything"
			+ " wrong. Because of what you are. Because"
			+ " they're scared of what you might become.",
		),
		DialogueLine.create(
			"Kael",
			"I know. I know that feeling. I found out"
			+ " recently that I'm something people want to"
			+ " use or destroy, and I didn't choose it"
			+ " either.",
		),
		DialogueLine.create(
			"Kael",
			"We're going to protect you. All of us."
			+ " Whatever it takes.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 1: Homecoming — Garrick's return
	DialogueManager.start_dialogue(compute_homecoming_lines())
	await DialogueManager.dialogue_ended

	# Scene 2: Through the Gates — Emberhearth arrival
	DialogueManager.start_dialogue(compute_gates_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: The Ash Walkers' Fire — Kamara
	DialogueManager.start_dialogue(compute_elders_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: Ash — meeting the child
	DialogueManager.start_dialogue(compute_meeting_lines())
	await DialogueManager.dialogue_ended

	# Ash joins the party
	var ash_data := load(ASH_DATA_PATH) as CharacterData
	if ash_data:
		PartyManager.add_character(ash_data)
	else:
		push_warning(
			"FireAndAsh: could not load " + ASH_DATA_PATH
		)

	# Scene 5: The Warning — Shepherd army
	DialogueManager.start_dialogue(compute_warning_lines())
	await DialogueManager.dialogue_ended

	# Scene 6: Two Days — preparation
	DialogueManager.start_dialogue(compute_preparation_lines())
	await DialogueManager.dialogue_ended

	# Scene 7: The Horizon — army arrives
	DialogueManager.start_dialogue(compute_horizon_lines())
	await DialogueManager.dialogue_ended

	# Camp: What Fire Means — Kael and Ash
	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

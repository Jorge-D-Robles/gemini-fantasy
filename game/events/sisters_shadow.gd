class_name SistersShadow
extends Node

## Chapter 13 — "Sister's Shadow" full event.
## Party infiltrates Station Theta, witnesses Resonance battery
## horrors. Dr. Sienna Vex defects from the Initiative.
##   Scene 1: The Signal — Cipher detects distress broadcast.
##   Scene 2: Station Theta — approach and infiltration.
##   Scene 3: What They Built Here — admin wing, subject files.
##   Scene 4: The Containment Wing — the horror of the batteries.
##   Scene 5: Sienna — meeting Dr. Vex, her confession.
##   Scene 6: The Escape — fleeing the failing facility.
##   Scene 7: Outside — Sienna joins, Cage data handed over.
##   Camp: The Space Between Sisters — Iris/Garrick, Nyx/Sienna.
## Gate: cipher_recruited AND NOT sienna_defected.
## Sets sienna_defected flag.

signal sequence_completed

const FLAG_NAME: String = "sienna_defected"


static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get("cipher_recruited", false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Scene 1 — The Signal: Cipher detects distress broadcast.
static func compute_signal_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"That's wrong.",
		),
		DialogueLine.create(
			"Iris",
			"What's wrong?",
		),
		DialogueLine.create(
			"Cipher",
			"There's a signal. Encrypted Initiative"
			+ " frequency. Two kilometers northeast,"
			+ " inside the mountain.",
		),
		DialogueLine.create(
			"Cipher",
			"Someone inside is broadcasting on an"
			+ " emergency frequency. But the signal's being"
			+ " jammed from inside the facility.",
		),
		DialogueLine.create(
			"Iris",
			"A facility in the mountains jamming its own"
			+ " emergency broadcasts. That's a black site.",
		),
		DialogueLine.create(
			"Garrick",
			"Shepherd intelligence used to track these."
			+ " Initiative runs at least a dozen classified"
			+ " research stations outside Federation"
			+ " territory.",
		),
		DialogueLine.create(
			"Cipher",
			"The signal is repeating. Sienna Vex."
			+ " Requesting extraction. Protocol Nine.",
		),
		DialogueLine.create(
			"Iris",
			"Sienna Vex. The Director's sister.",
		),
		DialogueLine.create(
			"Kael",
			"What's Protocol Nine?",
		),
		DialogueLine.create(
			"Iris",
			"Defection. The Initiative code for I want"
			+ " out and I'll trade intelligence for"
			+ " protection.",
		),
		DialogueLine.create(
			"Lyra",
			"If Sienna is trying to defect, she could"
			+ " have information about the Resonance Cage"
			+ " that Cipher's surveillance couldn't access."
			+ " Internal design documents. Weakness"
			+ " analysis.",
		),
		DialogueLine.create(
			"Cipher",
			"She's also the person who invented Resonance"
			+ " battery technology. The technique that"
			+ " turns people into living power cells."
			+ " Her name is on the papers.",
		),
	]


## Scene 2 — Station Theta: approach and infiltration.
static func compute_approach_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Two guards external. Camera system is on"
			+ " backup power. The main reactor is"
			+ " fluctuating. Something's happening inside.",
		),
		DialogueLine.create(
			"Iris",
			"Staffing for a station this size should be"
			+ " thirty to forty personnel. I'm only seeing"
			+ " two guards. No patrol pattern.",
		),
		DialogueLine.create(
			"Garrick",
			"They look tired.",
		),
		DialogueLine.create(
			"Iris",
			"They look scared.",
		),
		DialogueLine.create(
			"Kael",
			"Can you get us in without a fight?",
		),
		DialogueLine.create(
			"Cipher",
			"Camera loop -- thirty seconds. The door lock"
			+ " is electronic. Give me physical contact and"
			+ " I'll have it open in four seconds.",
		),
		DialogueLine.create(
			"Garrick",
			"Easy. I'm not armed. I'm a traveler. My"
			+ " party's caravan broke down on the pass."
			+ " We need water and directions.",
		),
	]


## Scene 3 — What They Built Here: admin wing, subject files.
static func compute_admin_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Station Theta. Classified as Resonance"
			+ " Applications Research. Actual purpose --"
			+ " Resonance battery prototyping.",
		),
		DialogueLine.create(
			"Cipher",
			"There are personnel files here. The test"
			+ " subjects. They have names. Ages. A teacher."
			+ " A dock worker. A fourteen-year-old"
			+ " apprentice blacksmith.",
		),
		DialogueLine.create(
			"Iris",
			"I know what the files look like, Cipher.",
		),
		DialogueLine.create(
			"Kael",
			"Where's Sienna?",
		),
		DialogueLine.create(
			"Cipher",
			"The signal originates from the laboratory"
			+ " wing. But the containment wing is between"
			+ " us and her. That's where they keep the"
			+ " subjects.",
		),
		DialogueLine.create(
			"Nyx",
			"I can feel them. The people in the walls."
			+ " They're not dead. They're not alive."
			+ " They're playing. Like a song stuck on one"
			+ " note.",
		),
		DialogueLine.create(
			"Nyx",
			"It's the worst sound I've ever heard.",
		),
	]


## Scene 4 — The Containment Wing: the horror of the batteries.
static func compute_containment_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Can they hear us?",
		),
		DialogueLine.create(
			"Cipher",
			"Partial consciousness. The crystal matrix is"
			+ " using their Resonance output as fuel while"
			+ " keeping them semi-conscious. Just aware"
			+ " enough to generate emotional energy.",
		),
		DialogueLine.create(
			"Iris",
			"To resist.",
		),
		DialogueLine.create(
			"Iris",
			"Subject seventeen. When I was in the"
			+ " Initiative, my unit transported subjects to"
			+ " facilities like this. They told us it was"
			+ " voluntary. Crystal therapy. I believed it"
			+ " for three years.",
		),
		DialogueLine.create(
			"Iris",
			"I believed it until I walked past a loading"
			+ " dock and saw them in restraints. Screaming."
			+ " I left that night.",
		),
		DialogueLine.create(
			"Iris",
			"I've told myself for two years that leaving"
			+ " was enough. Standing in this hallway, it"
			+ " will never be enough.",
		),
		DialogueLine.create(
			"Iris",
			"Don't. I'm fine. Let's find Sienna and get"
			+ " these people out.",
		),
		DialogueLine.create(
			"Cipher",
			"Pulling them out without a controlled"
			+ " extraction process could kill them.",
		),
		DialogueLine.create(
			"Kael",
			"Sienna would know. She designed this. If"
			+ " anyone can reverse it--",
		),
		DialogueLine.create(
			"Iris",
			"If she will reverse it. She built this,"
			+ " Kael. This was her life's work.",
		),
	]


## Scene 5 — Sienna: meeting Dr. Vex, her confession.
static func compute_sienna_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Sienna",
			"Stop. Identify yourselves.",
		),
		DialogueLine.create(
			"Iris",
			"Former Sergeant Iris Mantle, Initiative"
			+ " Special Operations. Retired.",
		),
		DialogueLine.create(
			"Sienna",
			"Retired isn't the word on your file.",
		),
		DialogueLine.create(
			"Iris",
			"My file can go to hell. We picked up your"
			+ " signal. Protocol Nine.",
		),
		DialogueLine.create(
			"Sienna",
			"That signal has been broadcasting for"
			+ " forty-six hours. I was beginning to think"
			+ " nobody was listening.",
		),
		DialogueLine.create(
			"Kael",
			"We're here. Can you put the gun down?",
		),
		DialogueLine.create(
			"Sienna",
			"That depends. Are you with my brother?",
		),
		DialogueLine.create(
			"Kael",
			"No.",
		),
		DialogueLine.create(
			"Sienna",
			"Resonance stigmata. You're one of the"
			+ " Anchors Vex has been hunting.",
		),
		DialogueLine.create(
			"Kael",
			"My name is Kael. And yes.",
		),
		DialogueLine.create(
			"Sienna",
			"I've spent twelve years building technology"
			+ " to harvest people like you. I've written"
			+ " the specifications for the Cage. I've"
			+ " personally overseen the conversion of"
			+ " thirty-seven individuals into Resonance"
			+ " batteries.",
		),
		DialogueLine.create(
			"Sienna",
			"I am not a good person who got caught up in"
			+ " something bad. I am a bad person who did"
			+ " bad things because I believed the science"
			+ " justified the suffering.",
		),
		DialogueLine.create(
			"Iris",
			"You called them subjects.",
		),
		DialogueLine.create(
			"Sienna",
			"I've been calling them subjects for twelve"
			+ " years. It takes time to stop. I'm working"
			+ " on it.",
		),
		DialogueLine.create(
			"Kael",
			"What changed? Why now?",
		),
		DialogueLine.create(
			"Sienna",
			"Three days ago, my brother sent a directive."
			+ " The current battery subjects are to be"
			+ " disposed of. Replaced with higher-yield"
			+ " assets. Disposed of. Like equipment.",
		),
		DialogueLine.create(
			"Sienna",
			"I've justified a great deal. But disposing"
			+ " of human beings because their power output"
			+ " isn't sufficient? My brother doesn't see"
			+ " them as people anymore. And I realized that"
			+ " for twelve years, neither did I.",
		),
		DialogueLine.create(
			"Iris",
			"So when I say you don't get my forgiveness"
			+ " -- understand it's because I haven't"
			+ " figured out how to forgive myself either.",
		),
		DialogueLine.create(
			"Sienna",
			"I'm not asking for forgiveness. I'm asking"
			+ " for the chance to undo what I can.",
		),
		DialogueLine.create(
			"Garrick",
			"Can you free the people in containment?",
		),
		DialogueLine.create(
			"Sienna",
			"I was working on an extraction protocol."
			+ " It hasn't been tested. The extraction would"
			+ " need precise Resonance frequencies. One"
			+ " mistake and the patient dies.",
		),
		DialogueLine.create(
			"Kael",
			"How long per person?",
		),
		DialogueLine.create(
			"Sienna",
			"Hours. Maybe a full day for the worst cases.",
		),
	]


## Scene 6 — The Escape: fleeing the failing facility.
static func compute_escape_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"Left! The right corridor is flooded with"
			+ " raw Resonance. We'd be Hollow in thirty"
			+ " seconds.",
		),
		DialogueLine.create(
			"Iris",
			"Contact!",
		),
		DialogueLine.create(
			"Sienna",
			"The reactor is destabilizing. We have"
			+ " minutes, not hours.",
		),
		DialogueLine.create(
			"Garrick",
			"Then we stop talking and start running.",
		),
	]


## Scene 7 — Outside: Sienna joins, Cage data handed over.
static func compute_outside_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Sienna",
			"Thank you.",
		),
		DialogueLine.create(
			"Kael",
			"Are you okay?",
		),
		DialogueLine.create(
			"Sienna",
			"No. I am definitively not okay. I've been"
			+ " not okay for approximately twelve years,"
			+ " and the only thing that's changed is I've"
			+ " stopped pretending otherwise.",
		),
		DialogueLine.create(
			"Lyra",
			"Dr. Vex.",
		),
		DialogueLine.create(
			"Sienna",
			"You're the Conscious Echo. The theoretical"
			+ " models say you shouldn't exist.",
		),
		DialogueLine.create(
			"Lyra",
			"So I've been told. Repeatedly.",
		),
		DialogueLine.create(
			"Sienna",
			"Your Resonance signature is remarkably"
			+ " coherent for a three-hundred-year-old"
			+ " fragment.",
		),
		DialogueLine.create(
			"Lyra",
			"You have your brother's analytical mind.",
		),
		DialogueLine.create(
			"Sienna",
			"Don't compare me to him.",
		),
		DialogueLine.create(
			"Lyra",
			"That's not redemption. But it's a start.",
		),
		DialogueLine.create(
			"Cipher",
			"Dr. Vex. I need everything you have on the"
			+ " Resonance Cage. Design specs, power"
			+ " requirements, vulnerabilities.",
		),
		DialogueLine.create(
			"Sienna",
			"Complete Cage schematics. Materials"
			+ " inventory. Anchor integration protocols."
			+ " And the extraction protocol for battery"
			+ " subjects.",
		),
		DialogueLine.create(
			"Sienna",
			"This is everything I know about how to build"
			+ " a Cage. Which means it's also everything"
			+ " you need to know about how to break one.",
		),
		DialogueLine.create(
			"Cipher",
			"You've been reading your encrypted files"
			+ " for eight months? The data breaches, the"
			+ " corruptions -- that was all you?",
		),
		DialogueLine.create(
			"Sienna",
			"You've cost the Initiative approximately"
			+ " four hundred million credits in damages.",
		),
		DialogueLine.create(
			"Cipher",
			"Only four hundred? I was aiming for half"
			+ " a billion.",
		),
	]


## Camp — The Space Between Sisters: Iris/Garrick, Nyx/Sienna.
static func compute_camp_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"You're angry.",
		),
		DialogueLine.create(
			"Iris",
			"I'm not angry.",
		),
		DialogueLine.create(
			"Garrick",
			"You're sharpening a knife that doesn't need"
			+ " sharpening.",
		),
		DialogueLine.create(
			"Iris",
			"She built the batteries, Garrick. She put"
			+ " people in crystal coffins and watched them"
			+ " disappear. People like the ones I"
			+ " transported.",
		),
		DialogueLine.create(
			"Garrick",
			"I burned a village once. Thought it was"
			+ " corrupted. Led forty Shepherds through the"
			+ " gates at dawn and burned everything that"
			+ " had crystal in it.",
		),
		DialogueLine.create(
			"Garrick",
			"My daughter was there. Helping at the"
			+ " clinic. I didn't know.",
		),
		DialogueLine.create(
			"Garrick",
			"I'm not saying Sienna deserves forgiveness."
			+ " I'm saying if this group only accepts people"
			+ " who've never done monstrous things, it's"
			+ " going to get very small.",
		),
		DialogueLine.create(
			"Nyx",
			"Dr. Vex.",
		),
		DialogueLine.create(
			"Sienna",
			"I didn't hear you approach.",
		),
		DialogueLine.create(
			"Nyx",
			"I'm told I'm quiet. Can I sit with you?",
		),
		DialogueLine.create(
			"Nyx",
			"Your hands shake.",
		),
		DialogueLine.create(
			"Sienna",
			"Chronic Resonance exposure. Occupational"
			+ " hazard of twelve years with crystal"
			+ " systems.",
		),
		DialogueLine.create(
			"Nyx",
			"Can I see?",
		),
		DialogueLine.create(
			"Sienna",
			"What did you--",
		),
		DialogueLine.create(
			"Nyx",
			"I don't know. Something in you is trying"
			+ " very hard to be still. I just helped it"
			+ " find the quiet place.",
		),
		DialogueLine.create(
			"Sienna",
			"That shouldn't be possible without a"
			+ " calibrated Resonance stabilizer.",
		),
		DialogueLine.create(
			"Nyx",
			"I don't know what that is. I just felt what"
			+ " you needed.",
		),
		DialogueLine.create(
			"Sienna",
			"You're remarkable. I hope you know that.",
		),
		DialogueLine.create(
			"Nyx",
			"I know that I like sitting by fires with"
			+ " people. Does that count?",
		),
		DialogueLine.create(
			"Sienna",
			"Yes. I think it does.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Scene 1: The Signal — Cipher detects broadcast
	DialogueManager.start_dialogue(compute_signal_lines())
	await DialogueManager.dialogue_ended

	# Scene 2: Station Theta — approach
	DialogueManager.start_dialogue(compute_approach_lines())
	await DialogueManager.dialogue_ended

	# Scene 3: What They Built Here — admin wing
	DialogueManager.start_dialogue(compute_admin_lines())
	await DialogueManager.dialogue_ended

	# Scene 4: The Containment Wing — horror
	DialogueManager.start_dialogue(compute_containment_lines())
	await DialogueManager.dialogue_ended

	# Scene 5: Sienna — meeting, confession
	DialogueManager.start_dialogue(compute_sienna_lines())
	await DialogueManager.dialogue_ended

	# Scene 6: The Escape — fleeing
	DialogueManager.start_dialogue(compute_escape_lines())
	await DialogueManager.dialogue_ended

	# Scene 7: Outside — Sienna joins
	DialogueManager.start_dialogue(compute_outside_lines())
	await DialogueManager.dialogue_ended

	# Camp: The Space Between Sisters
	DialogueManager.start_dialogue(compute_camp_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

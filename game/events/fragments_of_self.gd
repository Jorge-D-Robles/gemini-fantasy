class_name FragmentsOfSelf
extends Node

## Kael's "Fragments of Self" character quest — full 5-stage chain.
## A deeply personal journey through fabricated memories toward self-acceptance.
##   Stage 1: The Locket — childhood memory in Roothollow cottage.
##   Stage 2: The Scientist — pre-Severance lab memory.
##   Stage 3: The Chorus — all false memories at once, Nyx present.
##   Stage 4: What Remains — fireside talk with Garrick.
##   Stage 5: Gallery of Selves — final trial, The Fragment speaks.
## Each stage sets fragments_stage_N flag.

signal sequence_completed

const FLAG_PREFIX: String = "fragments_stage_"


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
			return compute_locket_lines()
		2:
			return compute_scientist_lines()
		3:
			return compute_chorus_lines()
		4:
			return compute_remains_lines()
		5:
			return compute_gallery_lines()
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


## Stage 1 — The Locket: Kael finds a memory crystal in their cottage.
static func compute_locket_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"This drawer hasn't been opened in years."
			+ " Elder Morin's things... a broken compass,"
			+ " dried herbs, and--",
		),
		DialogueLine.create(
			"Kael",
			"A locket. I've never seen this before. It's"
			+ " warm. Not ambient warm. Resonance warm.",
		),
		DialogueLine.create(
			"Kael",
			"There's a crystal fragment inside. Old."
			+ " Very old. It's pulsing when I touch it.",
		),
		DialogueLine.create(
			"Woman",
			"Kael, love, breakfast is almost ready. Show"
			+ " your father what you drew.",
		),
		DialogueLine.create(
			"Kael",
			"That was-- a kitchen. Morning light. A"
			+ " mother at a stove. A father reading. A"
			+ " child drawing on slate. The child had my"
			+ " eyes.",
		),
		DialogueLine.create(
			"Kael",
			"I don't have parents. I've never had"
			+ " parents. Elder Morin found me near the"
			+ " Hollows. That's the story. That's what"
			+ " happened.",
		),
		DialogueLine.create(
			"Kael",
			"So what the hell was that? The memory felt"
			+ " real. Warm. Complete. It smelled like"
			+ " honey.",
		),
		DialogueLine.create(
			"Kael",
			"The locket's crystal dimmed but it isn't"
			+ " dead. There's more in here. I need to"
			+ " understand what I just saw.",
		),
	]


## Stage 2 — The Scientist: Kael as a pre-Severance researcher.
static func compute_scientist_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Another crystal fragment. Larger than the"
			+ " locket's. It responds to my touch-- the"
			+ " locket is vibrating in sympathy.",
		),
		DialogueLine.create(
			"Colleague",
			"Kael! The convergence readings are spiking"
			+ " again. Lyra wants you in Lab Three.",
		),
		DialogueLine.create(
			"Kael",
			"That was me. Older. A scientist. Working"
			+ " at the Nexus before the Severance. The"
			+ " badge said Dr. K. Voss. Level 7"
			+ " clearance.",
		),
		DialogueLine.create(
			"Kael",
			"That's three hundred years ago. That can't"
			+ " be a memory of mine.",
		),
		DialogueLine.create(
			"Iris",
			"Two memories. Two completely different"
			+ " lives. Either you're collecting someone"
			+ " else's past, or--",
		),
		DialogueLine.create(
			"Kael",
			"Or what?",
		),
		DialogueLine.create(
			"Iris",
			"Or these aren't memories at all.",
		),
		DialogueLine.create(
			"Kael",
			"The crystal cracked when the Echo released"
			+ " me. But the lab was real. I could feel"
			+ " the glass under my palm. No scars on my"
			+ " hands. Clean. Human.",
		),
		DialogueLine.create(
			"Kael",
			"A happy childhood with parents I never"
			+ " had. A career at a facility that"
			+ " collapsed three centuries ago. Both feel"
			+ " equally real. Both can't be true.",
		),
	]


## Stage 3 — The Chorus: all memories at once, Nyx required.
static func compute_chorus_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Nyx",
			"It's singing. The crystal is singing and"
			+ " it sounds like you. Like the loud thing"
			+ " inside you.",
		),
		DialogueLine.create(
			"Kael",
			"I need to touch it. I know I need to"
			+ " touch it and I don't know how I know"
			+ " that.",
		),
		DialogueLine.create(
			"Nyx",
			"Because you're part of it. The singing and"
			+ " the loud thing and the crystal-- they're"
			+ " all the same song. I can hear it.",
		),
		DialogueLine.create(
			"Kael",
			"They're not real. None of them are real."
			+ " Not the parents, not the scientist, not"
			+ " any of it. They're costume changes.",
		),
		DialogueLine.create(
			"Kael",
			"A thing that was dying tried to figure out"
			+ " how to be a person and it kept trying"
			+ " different versions and none of them"
			+ " stuck.",
		),
		DialogueLine.create(
			"Kael",
			"And then it just... sent me out. Into the"
			+ " world. With a blank space where a"
			+ " childhood should be. And it hoped that"
			+ " would be enough.",
		),
		DialogueLine.create(
			"Nyx",
			"Was it?",
		),
		DialogueLine.create(
			"Kael",
			"I don't know. I built a whole life on that"
			+ " blank space. Friends. A home. A journal"
			+ " full of sketches. Is that enough? Is a"
			+ " life enough even if the foundation is a"
			+ " lie?",
		),
		DialogueLine.create(
			"Nyx",
			"I don't have a foundation at all. I walked"
			+ " out of the Hollows with nothing. No"
			+ " memories. No story. Just me and the want"
			+ " to see butterflies.",
		),
		DialogueLine.create(
			"Nyx",
			"And you told me that was okay. You said"
			+ " present tense was the best tense there"
			+ " is. Did you mean that?",
		),
		DialogueLine.create(
			"Kael",
			"...Yeah. I meant it.",
		),
		DialogueLine.create(
			"Nyx",
			"Then it applies to you too. You're present"
			+ " tense, Kael. Whatever past the"
			+ " Convergence tried to give you-- you're"
			+ " here now. Holding my hand in a crystal"
			+ " cave. That's real.",
		),
	]


## Stage 4 — What Remains: Garrick fireside, Kael processes.
static func compute_remains_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Can I ask you something personal?",
		),
		DialogueLine.create(
			"Garrick",
			"You're going to anyway.",
		),
		DialogueLine.create(
			"Kael",
			"When you left the Shepherds. When"
			+ " everything you believed turned out to be"
			+ " not what you thought. How did you keep"
			+ " going?",
		),
		DialogueLine.create(
			"Garrick",
			"Badly. For a long time. I drank. Walked"
			+ " the Wastes looking for something to kill"
			+ " me. Picked fights with things twice my"
			+ " size. Nothing worked.",
		),
		DialogueLine.create(
			"Garrick",
			"Then I found a village that needed a wall"
			+ " built. So I built them a wall. Brick by"
			+ " brick. Took six months.",
		),
		DialogueLine.create(
			"Garrick",
			"Somewhere around month four, I realized I"
			+ " hadn't thought about the Shepherds in"
			+ " three days. You can't carry a grudge and"
			+ " a brick at the same time. Not enough"
			+ " hands.",
		),
		DialogueLine.create(
			"Garrick",
			"You're not asking about me, Kael. You're"
			+ " asking whether a person without a real"
			+ " past can build a real future.",
		),
		DialogueLine.create(
			"Kael",
			"Am I that obvious?",
		),
		DialogueLine.create(
			"Garrick",
			"You're always obvious. It's one of your"
			+ " better qualities.",
		),
		DialogueLine.create(
			"Kael",
			"I keep thinking about the cottage. The one"
			+ " that burned. My books. My sketches. All"
			+ " that stuff was real. But the person who"
			+ " lived in it might not have been a"
			+ " person. Not the way everyone else is.",
		),
		DialogueLine.create(
			"Garrick",
			"You lived in a cottage. You filled it with"
			+ " things that mattered. You sketched the"
			+ " face of someone you loved. If that's not"
			+ " a person, I don't know what the word"
			+ " means.",
		),
		DialogueLine.create(
			"Garrick",
			"A thing made of collective consciousness"
			+ " looked at the whole world and chose to"
			+ " fill a cottage with sketches and bad"
			+ " jokes. That choice-- to be small and"
			+ " particular-- is the most human thing"
			+ " I've ever heard of.",
		),
		DialogueLine.create(
			"Kael",
			"You should write greeting cards, old man.",
		),
		DialogueLine.create(
			"Garrick",
			"You should go to sleep. Big day tomorrow."
			+ " World-saving.",
		),
		DialogueLine.create(
			"Kael",
			"Garrick? Thanks. For the wall story.",
		),
		DialogueLine.create(
			"Garrick",
			"Anytime. Brick by brick.",
		),
	]


## Stage 5 — Gallery of Selves: The Fragment speaks, final trial.
static func compute_gallery_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"The Fragment",
			"I don't know if you can hear me. I don't"
			+ " know if 'me' is the right word.",
		),
		DialogueLine.create(
			"The Fragment",
			"I was part of something that was"
			+ " everything, and then I wasn't, and then"
			+ " I was walking through trees and the sky"
			+ " was above me and I thought-- I want to"
			+ " stay.",
		),
		DialogueLine.create(
			"The Fragment",
			"I wanted to stay so badly that I built a"
			+ " place to stay in. A story. A cottage. A"
			+ " name.",
		),
		DialogueLine.create(
			"The Fragment",
			"I took 'Kael' from a sound I heard in the"
			+ " Hollows-- the echo of a child laughing."
			+ " It was the most beautiful thing I'd ever"
			+ " heard.",
		),
		DialogueLine.create(
			"The Fragment",
			"I took 'Voss' from a village where people"
			+ " put lanterns out for strangers. I built"
			+ " a past from pieces of everyone I'd ever"
			+ " been.",
		),
		DialogueLine.create(
			"The Fragment",
			"It wasn't enough. I know that now. A story"
			+ " isn't a self. But I didn't know how to"
			+ " be a self without one.",
		),
		DialogueLine.create(
			"Kael",
			"You gave me everything you had. A name. A"
			+ " home. A reason to keep walking. Even if"
			+ " none of it was real-- you tried.",
		),
		DialogueLine.create(
			"Kael",
			"And somewhere between the trying and the"
			+ " failing, I became someone. Not the child"
			+ " with parents. Not the scientist. Just"
			+ " Kael. The one who sketches too much and"
			+ " talks to crystals.",
		),
		DialogueLine.create(
			"The Fragment",
			"Is that enough?",
		),
		DialogueLine.create(
			"Kael",
			"It's everything.",
		),
	]

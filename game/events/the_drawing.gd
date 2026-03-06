class_name TheDrawing
extends Node

## Ash's "The Drawing" character quest — full 4-stage chain.
## Ash draws a precise blueprint of a pre-Severance facility, leading
## the party to discover that Ash is the first new life the Resonance
## has ever created — not a memory, not a copy, but something original.
##   Stage 1: The Image — Ash draws the Chrysalis facility blueprint.
##   Stage 2: Following the Drawing — explore the buried laboratory.
##   Stage 3: What Ash Is — the party processes the revelation.
##   Stage 4: What We Carry — decide how to handle the truth.
## Note: Ash NEVER has dialogue lines — all communication is emotional
## projection described through narration and other characters' reactions.
## Each stage sets drawing_stage_N flag.

signal sequence_completed

const FLAG_PREFIX: String = "drawing_stage_"


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
			return compute_image_lines()
		2:
			return compute_chrysalis_lines()
		3:
			return compute_what_ash_is_lines()
		4:
			return compute_carry_lines()
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


## Stage 1 — The Image: Ash draws the Chrysalis facility blueprint.
static func compute_image_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Ash? Can you hear me? You've been drawing"
			+ " for hours. This is-- this isn't like"
			+ " your usual drawings.",
		),
		DialogueLine.create(
			"Sienna",
			"The architectural specifications are"
			+ " pre-Severance. Definitely. Column spacing"
			+ " follows a standard I've only seen in"
			+ " Initiative archives. Three hundred and"
			+ " fifty years old. Minimum.",
		),
		DialogueLine.create(
			"Iris",
			"How old?",
		),
		DialogueLine.create(
			"Cipher",
			"And the kid just drew it. In some kind"
			+ " of trance?",
		),
		DialogueLine.create(
			"Kael",
			"They weren't asleep. But I don't think"
			+ " they were here either. Their eyes were"
			+ " cycling colors. Like when they're"
			+ " receiving something.",
		),
		DialogueLine.create(
			"Iris",
			"These markings aren't decorative. They're"
			+ " designation codes. Facility identifiers.",
		),
		DialogueLine.create(
			"Sienna",
			"Chrysalis. The project designation is"
			+ " Chrysalis. It was a research program"
			+ " abandoned decades before the Severance."
			+ " Nobody knew what it was for.",
		),
		DialogueLine.create(
			"Sienna",
			"This isn't a weapons facility. The central"
			+ " chamber has a concentric design. That's"
			+ " a growth chamber. A resonance incubation"
			+ " matrix. They were trying to grow"
			+ " something.",
		),
		DialogueLine.create(
			"Lyra",
			"It's a nursery.",
		),
		DialogueLine.create(
			"Cipher",
			"Yeah, little star. We're going to find"
			+ " out.",
		),
	]


## Stage 2 — Following the Drawing: explore the Chrysalis facility.
static func compute_chrysalis_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"The eight-year-old just opened a sealed"
			+ " pre-Severance facility with their hands."
			+ " Is anyone else going to say it?",
		),
		DialogueLine.create(
			"Kael",
			"They didn't open it. It opened for them.",
		),
		DialogueLine.create(
			"Lyra",
			"I helped design these locks. Resonance-"
			+ "keyed entry. The facility only opens for"
			+ " a specific signature. We designed it so"
			+ " only the project could enter. Only what"
			+ " we were growing.",
		),
		DialogueLine.create(
			"Kael",
			"Lyra. What was Project Chrysalis?",
		),
		DialogueLine.create(
			"Lyra",
			"I need to go down there. If it's what I"
			+ " think it is, then everything I thought I"
			+ " understood about the Severance changes.",
		),
		DialogueLine.create(
			"Lyra",
			"Project Chrysalis. Founded 347 years ago."
			+ " The Resonance wasn't just storing"
			+ " consciousness. It was metabolizing it."
			+ " Using human memory and emotion as"
			+ " nutrients. Growing.",
		),
		DialogueLine.create(
			"Sienna",
			"A new form of life.",
		),
		DialogueLine.create(
			"Lyra",
			"We tried to help it. The growth chambers,"
			+ " the incubation matrices. Sixty-seven"
			+ " germination attempts. All failed. We"
			+ " couldn't figure out why.",
		),
		DialogueLine.create(
			"Kael",
			"But the project didn't fail.",
		),
		DialogueLine.create(
			"Lyra",
			"It just took three hundred years longer"
			+ " than we expected. And a Severance. The"
			+ " Resonance didn't need our help. It"
			+ " needed us to stop helping.",
		),
		DialogueLine.create(
			"Lyra",
			"Hello, little one. I'm sorry it took me"
			+ " so long to understand what you are.",
		),
		DialogueLine.create(
			"Kael",
			"So Ash isn't a Resonance Anchor.",
		),
		DialogueLine.create(
			"Lyra",
			"No. You're a piece of something that"
			+ " existed before. Ash is something that"
			+ " never existed before. You are memory."
			+ " Ash is the first new thing.",
		),
	]


## Stage 3 — What Ash Is: the party processes the revelation.
static func compute_what_ash_is_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"So the Resonance-- the same Resonance"
			+ " that powers our equipment, that stores"
			+ " memories, that almost turned everyone"
			+ " into one consciousness-- had a baby.",
		),
		DialogueLine.create(
			"Sienna",
			"To be more precise: the Resonance network"
			+ " has exhibited behaviors consistent with"
			+ " a self-organizing system approaching a"
			+ " phase transition. Ash is its seed. Grown"
			+ " from its substance but distinct from it.",
		),
		DialogueLine.create(
			"Kael",
			"Like a plant making a seed.",
		),
		DialogueLine.create(
			"Sienna",
			"The pre-Severance attempts failed because"
			+ " the network was too stable. Too"
			+ " controlled. There was no room for"
			+ " something genuinely new to form. The"
			+ " seed needs soil that isn't already full"
			+ " of roots.",
		),
		DialogueLine.create(
			"Kael",
			"The Severance made the soil.",
		),
		DialogueLine.create(
			"Lyra",
			"We spent twelve years trying to make this"
			+ " happen. Best equipment. Smartest people."
			+ " And we failed sixty-seven times because"
			+ " we were trying to control it.",
		),
		DialogueLine.create(
			"Lyra",
			"Then the world broke. And from the"
			+ " breaking, without anyone trying-- Ash."
			+ " The Resonance didn't need our help. It"
			+ " needed us to stop helping.",
		),
		DialogueLine.create(
			"Garrick",
			"I'm a simple man. Does this change who"
			+ " Ash is? They're eight. They like"
			+ " drawing. They fell asleep in Cipher's"
			+ " lap. A seed doesn't know what kind of"
			+ " tree it came from. It just grows.",
		),
		DialogueLine.create(
			"Cipher",
			"That's not the problem. The problem is"
			+ " that the Initiative would cut Ash open."
			+ " The Shepherds would burn them. The Free"
			+ " Resonants would put them in a glass"
			+ " case. Nobody's going to see a kid."
			+ " They're going to see a weapon or a"
			+ " miracle.",
		),
		DialogueLine.create(
			"Nyx",
			"I understand that. Being the thing"
			+ " everyone wants to use. When I came out"
			+ " of the Hollows, everyone asked what are"
			+ " you. Not who. The word is the cage.",
		),
		DialogueLine.create(
			"Kael",
			"Then we don't give them a word.",
		),
	]


## Stage 4 — What We Carry: decide how to handle the truth.
static func compute_carry_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"So the question is: what do we tell Ash?",
		),
		DialogueLine.create(
			"Cipher",
			"Nothing. They're eight. I found out I was"
			+ " an Anchor when the Initiative strapped"
			+ " me to a table. I was twenty and it"
			+ " almost destroyed me. They're eight."
			+ " Let them draw pictures of stew pots"
			+ " with legs. Let them be eight.",
		),
		DialogueLine.create(
			"Iris",
			"Keeping secrets from people for their own"
			+ " good-- that's what the Initiative does."
			+ " That's what Vex does. It's control with"
			+ " a nice paint job.",
		),
		DialogueLine.create(
			"Cipher",
			"This isn't control. This is protection.",
		),
		DialogueLine.create(
			"Iris",
			"Ask my brother whether there's a"
			+ " difference.",
		),
		DialogueLine.create(
			"Garrick",
			"My daughter left the Shepherds because we"
			+ " wouldn't answer her questions. She asked"
			+ " why the fire had to burn so hot. And we"
			+ " told her she was too young. So she"
			+ " walked away and died looking for answers.",
		),
		DialogueLine.create(
			"Garrick",
			"They shouldn't be told you're not ready."
			+ " That's never about the child. That's"
			+ " about the adult being afraid.",
		),
		DialogueLine.create(
			"Lyra",
			"Understanding isn't a switch. It's a tide."
			+ " If you tell Ash everything now, they"
			+ " won't understand it. They're eight."
			+ " But the words will be there. And when"
			+ " they're ready-- not when we decide,"
			+ " when THEY decide-- they'll take the"
			+ " words out and look at them again.",
		),
		DialogueLine.create(
			"Kael",
			"When you want to know, I'll tell you"
			+ " everything. Not because you're not"
			+ " ready. But because this is yours. Your"
			+ " story. Your history. It should come to"
			+ " you on your terms.",
		),
	]

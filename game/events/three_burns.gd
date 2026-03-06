class_name ThreeBurns
extends Node

## Garrick's "Three Burns" character quest — full 3-stage chain.
## Garrick confronts the three Shepherd purges he commanded,
## especially the third that killed his daughter Mara.
##   Stage 1: The Name on the Wall — memorial wall in Emberhearth.
##   Stage 2: Following Smoke — Ashpyre ruins, three memory fragments.
##   Stage 3: The Echo of Mara — face-to-face with Mara's Echo.
## Each stage sets three_burns_stage_N flag.

signal sequence_completed

const FLAG_PREFIX: String = "three_burns_stage_"


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
			return compute_wall_lines()
		2:
			return compute_smoke_lines()
		3:
			return compute_echo_lines()
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


## Stage 1 — The Name on the Wall: Garrick at the memorial.
static func compute_wall_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Garrick. You've been standing here for"
			+ " twenty minutes.",
		),
		DialogueLine.create(
			"Garrick",
			"My daughter. She was sixteen.",
		),
		DialogueLine.create(
			"Garrick",
			"I haven't spoken her name out loud in"
			+ " fourteen years. Mara. I said it in my"
			+ " head every morning. Every night. But"
			+ " never out loud.",
		),
		DialogueLine.create(
			"Kael",
			"What happened?",
		),
		DialogueLine.create(
			"Garrick",
			"She left the Shepherd compound at fourteen"
			+ " because the doctrine said Resonance-"
			+ "touched people weren't worthy of care."
			+ " She told the Council to go to hell. She"
			+ " got that from her mother.",
		),
		DialogueLine.create(
			"Garrick",
			"She came to the Wastes. Found an Ash"
			+ " Walker village. Became their healer. She"
			+ " was good at it. She was good at"
			+ " everything she cared about.",
		),
		DialogueLine.create(
			"Garrick",
			"Two years later, the Council ordered a"
			+ " purge. Three villages. I led it. They"
			+ " called me Three Burns after. Three"
			+ " villages. Three fires.",
		),
		DialogueLine.create(
			"Garrick",
			"The third village was hers. I didn't know."
			+ " The reports listed it as a corrupted"
			+ " settlement. They didn't list names. They"
			+ " never listed names.",
		),
		DialogueLine.create(
			"Elder",
			"Three-Burns. Fragments of your daughter's"
			+ " Echo have been sighted in the ruins of"
			+ " Ashpyre. Find her. You owe her that"
			+ " much.",
		),
	]


## Stage 2 — Following Smoke: Ashpyre ruins, three fragments.
static func compute_smoke_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Mara",
			"Hold still. This is going to sting, but"
			+ " only for a second.",
		),
		DialogueLine.create(
			"Boy",
			"Your dad was a Shepherd, right? My mom"
			+ " says Shepherds hate crystal healing.",
		),
		DialogueLine.create(
			"Mara",
			"My dad was a lot of things. He was wrong"
			+ " about some of them.",
		),
		DialogueLine.create(
			"Garrick",
			"She was writing to me. She was trying"
			+ " to--",
		),
		DialogueLine.create(
			"Mara",
			"How many?",
		),
		DialogueLine.create(
			"Elder",
			"Three companies. Shepherd armor. They're"
			+ " burning the eastern approach.",
		),
		DialogueLine.create(
			"Mara",
			"We need to move the patients. If the"
			+ " Shepherds use purification bombs, the"
			+ " crystal backlash will--",
		),
		DialogueLine.create(
			"Mara",
			"Dad?",
		),
		DialogueLine.create(
			"Mara",
			"Please. He's just an old man. He's not"
			+ " corrupted. He just has crystal dust in"
			+ " his lungs from the mines.",
		),
		DialogueLine.create(
			"Mara",
			"My name is Mara Thorne. My father is"
			+ " Commander Thorne. If you let me speak to"
			+ " him--",
		),
		DialogueLine.create(
			"Garrick's Echo",
			"No survivors in the contamination zone!"
			+ " Standard purification protocol!",
		),
		DialogueLine.create(
			"Garrick",
			"She said my name. She tried to use my name"
			+ " to save them. And I was the one who gave"
			+ " the order that killed her.",
		),
		DialogueLine.create(
			"Kael",
			"Garrick. We can stop. We don't have to--",
		),
		DialogueLine.create(
			"Garrick",
			"We do. I have to see it. All of it. She"
			+ " saw it. The least I can do is look.",
		),
		DialogueLine.create(
			"Garrick",
			"The compass is still pulling. She's not"
			+ " all here. Whatever's left of her is"
			+ " further in the Wastes.",
		),
	]


## Stage 3 — The Echo of Mara: Garrick meets his daughter.
static func compute_echo_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Mara",
			"...You're old.",
		),
		DialogueLine.create(
			"Garrick",
			"You're not.",
		),
		DialogueLine.create(
			"Mara",
			"No. I'm not anything, really. I'm the"
			+ " part that didn't burn. The part the"
			+ " crystal caught before it was gone.",
		),
		DialogueLine.create(
			"Garrick",
			"Fourteen years.",
		),
		DialogueLine.create(
			"Mara",
			"Is that all? It felt longer. I listened to"
			+ " the pulse and thought about things."
			+ " Mostly I thought about you.",
		),
		DialogueLine.create(
			"Mara",
			"I know what you're going to say. You've"
			+ " been practicing it for fourteen years. I"
			+ " could feel your guilt through the"
			+ " crystal. It's the loudest thing in the"
			+ " Wastes.",
		),
		DialogueLine.create(
			"Garrick",
			"It's not armor. It's a sentence.",
		),
		DialogueLine.create(
			"Mara",
			"You didn't know I was there. You didn't"
			+ " see me. That's a horror. But it's not"
			+ " the crime you've turned it into.",
		),
		DialogueLine.create(
			"Garrick",
			"I burned three villages.",
		),
		DialogueLine.create(
			"Mara",
			"You did. And that is the crime. Not the"
			+ " accident of killing me-- the choice of"
			+ " burning people. Every patient I treated."
			+ " The elder. The boy with the scraped"
			+ " knee.",
		),
		DialogueLine.create(
			"Mara",
			"I forgive you for killing me. You didn't"
			+ " know. But the forgiveness you actually"
			+ " need-- for the villages, for the years"
			+ " of not questioning-- that's not mine to"
			+ " give. That's yours.",
		),
		DialogueLine.create(
			"Garrick",
			"I don't know how.",
		),
		DialogueLine.create(
			"Mara",
			"I know. That's why you're still carrying"
			+ " the shield with the scratched emblem"
			+ " instead of throwing it away. You've"
			+ " turned guilt into a second religion."
			+ " And it's just as blind as the first one.",
		),
		DialogueLine.create(
			"Garrick",
			"Your mother used to say I was the"
			+ " stubbornest man in the Wastes.",
		),
		DialogueLine.create(
			"Mara",
			"She was right about that.",
		),
		DialogueLine.create(
			"Garrick",
			"I kept the shield because I was afraid"
			+ " that without it, I'd forget what I did."
			+ " That I'd forgive myself and then I"
			+ " wouldn't have a reason to be different.",
		),
		DialogueLine.create(
			"Mara",
			"And how's that working?",
		),
		DialogueLine.create(
			"Garrick",
			"Terribly.",
		),
		DialogueLine.create(
			"Mara",
			"Dad. You cook for people who are scared."
			+ " You build walls for strangers. You sit"
			+ " up at night so a shadow child can sleep."
			+ " That's not guilt. That's who you are"
			+ " when you stop punishing yourself long"
			+ " enough to actually be someone.",
		),
	]

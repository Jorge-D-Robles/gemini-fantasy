class_name BookOfNames
extends Node

## Sienna's "Book of Names" character quest — full 4-stage chain.
## Sienna carries a notebook with the names of every person she
## converted into a Resonance battery. The quest follows her attempts
## to find and free the survivors.
##   Stage 1: The Ledger — Sienna reveals the 53-name notebook.
##   Stage 2: Subject 14 — find Marcus Theel in Greywell.
##   Stage 3: The Reversal Protocol — attempt to free battery subjects.
##   Stage 4: The Reckoning — Sienna and Iris confront guilt, decide
##            what to do with the research.
## Each stage sets book_of_names_stage_N flag.

signal sequence_completed

const FLAG_PREFIX: String = "book_of_names_stage_"


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
			return compute_ledger_lines()
		2:
			return compute_subject_lines()
		3:
			return compute_reversal_lines()
		4:
			return compute_reckoning_lines()
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


## Stage 1 — The Ledger: Sienna reveals the 53-name notebook.
static func compute_ledger_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"Sienna? It's past midnight.",
		),
		DialogueLine.create(
			"Sienna",
			"I'm documenting. Patient records. Today's"
			+ " intake. Nothing that requires--",
		),
		DialogueLine.create(
			"Kael",
			"You treated six people today. You've been"
			+ " writing for four hours.",
		),
		DialogueLine.create(
			"Sienna",
			"When I was at the Initiative, I kept"
			+ " records. Official ones. Subject numbers,"
			+ " conversion metrics. Clean data. The kind"
			+ " you put in reports.",
		),
		DialogueLine.create(
			"Sienna",
			"This isn't the official record.",
		),
		DialogueLine.create(
			"Sienna",
			"Fifty-three names. Every person I converted"
			+ " into a Resonance battery. Every single"
			+ " one. Name, age, occupation, date of"
			+ " conversion.",
		),
		DialogueLine.create(
			"Sienna",
			"The first fifty-three pages are the people"
			+ " I destroyed. Everything after is the"
			+ " people I've treated since I left. I write"
			+ " every name. Because there was a period"
			+ " when I used numbers instead, and that's"
			+ " how you stop seeing faces.",
		),
		DialogueLine.create(
			"Sienna",
			"Marcus Theel wanted to teach children"
			+ " about pre-Severance history. Rina Vosh"
			+ " had a sister she sent money to every"
			+ " month. Tomas Gren was seventeen and told"
			+ " me a joke while I was prepping the"
			+ " conversion chamber.",
		),
		DialogueLine.create(
			"Sienna",
			"He told me a joke and I laughed and then"
			+ " I turned him into a battery.",
		),
		DialogueLine.create(
			"Iris",
			"Fifty-three.",
		),
		DialogueLine.create(
			"Sienna",
			"Fifty-three.",
		),
		DialogueLine.create(
			"Iris",
			"I transported twelve of those people. My"
			+ " unit. Before I knew what the program was.",
		),
		DialogueLine.create(
			"Iris",
			"Pel Dorin. I remember him. He was calm."
			+ " He asked me if the facility had good"
			+ " food.",
		),
		DialogueLine.create(
			"Iris",
			"You have a list. Do you have a plan?",
		),
		DialogueLine.create(
			"Sienna",
			"A reversal protocol. The process is in"
			+ " principle thermodynamically reversible."
			+ " It might work. It might kill them. I"
			+ " don't know which.",
		),
		DialogueLine.create(
			"Kael",
			"How many of the fifty-three are still"
			+ " alive?",
		),
		DialogueLine.create(
			"Sienna",
			"At least nineteen are still in stasis at"
			+ " various Initiative sites. Alive."
			+ " Conscious. Waiting.",
		),
		DialogueLine.create(
			"Sienna",
			"I need to find them.",
		),
	]


## Stage 2 — Subject 14: find Marcus Theel in Greywell.
static func compute_subject_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Calloway",
			"We're not buying anything.",
		),
		DialogueLine.create(
			"Sienna",
			"My name is Dr. Sienna Vex. I'm looking"
			+ " for someone who may have been brought"
			+ " here from an Initiative facility. His"
			+ " name is Marcus Theel.",
		),
		DialogueLine.create(
			"Calloway",
			"His name is Marcus. That part's right."
			+ " He's not any age anymore. He's not"
			+ " anything you'd call a person.",
		),
		DialogueLine.create(
			"Calloway",
			"Come in. See what you made.",
		),
		DialogueLine.create(
			"Calloway",
			"I'm his sister. The Initiative dumped him"
			+ " on my doorstep two years ago. They said"
			+ " he was unrecoverable. The crystal grows"
			+ " a little every month.",
		),
		DialogueLine.create(
			"Sienna",
			"I know what he is. I know because I'm"
			+ " the person who did this to him.",
		),
		DialogueLine.create(
			"Sienna",
			"Subject 14. Marcus Theel. Age 34."
			+ " Elementary school teacher. Notes:"
			+ " cooperative, expressed concern for his"
			+ " class. I wrote that. As if his compliance"
			+ " was a data point worth recording.",
		),
		DialogueLine.create(
			"Iris",
			"Easy.",
		),
		DialogueLine.create(
			"Sienna",
			"I came here because I'm trying to undo"
			+ " it.",
		),
		DialogueLine.create(
			"Calloway",
			"You can't undo crystal. You can't undo"
			+ " six years of sitting in a chair while"
			+ " your body turns into a lamp.",
		),
		DialogueLine.create(
			"Sienna",
			"I believe I can reverse the"
			+ " crystallization. Extract him from the"
			+ " matrix. Give him his body back.",
		),
		DialogueLine.create(
			"Iris",
			"And what happens when it fails?",
		),
		DialogueLine.create(
			"Sienna",
			"The subject dies. Immediately.",
		),
		DialogueLine.create(
			"Sienna",
			"I designed the protocol to maintain"
			+ " consciousness because the data suggested"
			+ " higher Resonance yield from conscious"
			+ " subjects. I made a choice to keep you"
			+ " aware. I need you to know that I know"
			+ " what that choice cost you.",
		),
		DialogueLine.create(
			"Calloway",
			"He says... fix it.",
		),
		DialogueLine.create(
			"Sienna",
			"I'll try.",
		),
	]


## Stage 3 — The Reversal Protocol: attempt to free battery subjects.
static func compute_reversal_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Cipher",
			"The Initiative's filing system lists this"
			+ " as Annex 7-Beta. Status: decommissioned."
			+ " Which is obviously a lie.",
		),
		DialogueLine.create(
			"Iris",
			"Automated maintenance. The subjects"
			+ " generate enough Resonance to power their"
			+ " own containment. It's a closed loop.",
		),
		DialogueLine.create(
			"Sienna",
			"Six subjects. Five active, one deceased."
			+ " Crystal integration ranges from"
			+ " fifty-two percent to ninety-one percent."
			+ " The deceased subject reached total"
			+ " integration. Consciousness collapse.",
		),
		DialogueLine.create(
			"Kael",
			"That means...",
		),
		DialogueLine.create(
			"Sienna",
			"Their mind dissolved into the crystal."
			+ " They stopped being a person. It's the"
			+ " terminal stage. It's what happens when"
			+ " nobody reverses the process.",
		),
		DialogueLine.create(
			"Sienna",
			"I can attempt the reversal protocol. The"
			+ " facility's power will sustain for"
			+ " approximately seventy-two hours. After"
			+ " that the pods lose containment and the"
			+ " subjects die regardless.",
		),
		DialogueLine.create(
			"Cipher",
			"What are the odds?",
		),
		DialogueLine.create(
			"Sienna",
			"Fifty to sixty percent integration has a"
			+ " reasonable chance. Above seventy the"
			+ " model breaks down. Above eighty... the"
			+ " reversal would almost certainly kill"
			+ " them.",
		),
		DialogueLine.create(
			"Iris",
			"What are the other options?",
		),
		DialogueLine.create(
			"Sienna",
			"Mercy protocol. I collapse the matrices"
			+ " painlessly. No more awareness, no more"
			+ " suffering. Or I stabilize the"
			+ " containment. Keep them alive in stasis"
			+ " while I perfect the protocol. Weeks,"
			+ " maybe months. They remain conscious.",
		),
		DialogueLine.create(
			"Sienna",
			"I can't make this decision alone. I"
			+ " forfeited the right to make decisions"
			+ " about these people when I made the"
			+ " first one.",
		),
	]


## Stage 4 — The Reckoning: Sienna and Iris confront their guilt.
static func compute_reckoning_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"You don't sleep.",
		),
		DialogueLine.create(
			"Sienna",
			"I sleep. Intermittently. Three to four"
			+ " hours in fragmented cycles. It's"
			+ " sufficient for baseline cognitive"
			+ " function.",
		),
		DialogueLine.create(
			"Iris",
			"That's not sleeping. That's maintenance.",
		),
		DialogueLine.create(
			"Iris",
			"I came over here because I've been trying"
			+ " to have this conversation for six weeks"
			+ " and I keep finding reasons not to.",
		),
		DialogueLine.create(
			"Iris",
			"When I left the Initiative, I didn't save"
			+ " anyone. I walked past those transport"
			+ " doors and I kept walking. I told myself"
			+ " I'd come back. I never came back.",
		),
		DialogueLine.create(
			"Iris",
			"This arm. Same Resonance channeling"
			+ " technology as the conversion chambers."
			+ " Same patent. I wear the murder weapon"
			+ " every day.",
		),
		DialogueLine.create(
			"Iris",
			"We're not the same, you and me. What you"
			+ " did is worse. I need you to know that."
			+ " You were the architect. I was the truck"
			+ " driver. There's a difference.",
		),
		DialogueLine.create(
			"Sienna",
			"There is.",
		),
		DialogueLine.create(
			"Iris",
			"But the guilt is the same shape. I know"
			+ " what it feels like to lie awake and do"
			+ " the arithmetic. How many people. How"
			+ " many years. And the arithmetic never"
			+ " finishes.",
		),
		DialogueLine.create(
			"Iris",
			"I'm not forgiving you. I'm not there yet."
			+ " But I'm telling you that I see you."
			+ " Sitting here with your two notebooks and"
			+ " your shaking hands, trying to turn a"
			+ " list of atrocities into a ledger that"
			+ " balances. That's the most human thing"
			+ " I've watched anyone do.",
		),
		DialogueLine.create(
			"Sienna",
			"There's something I need to decide. This"
			+ " notebook contains the complete Resonance"
			+ " battery conversion and reversal"
			+ " protocols. Everything. If my brother got"
			+ " this he could build a hundred Cages.",
		),
		DialogueLine.create(
			"Sienna",
			"I need you to know that the ledger is not"
			+ " for balancing. It is for remembering."
			+ " Every name. Every face. That is not"
			+ " redemption. It is responsibility.",
		),
	]

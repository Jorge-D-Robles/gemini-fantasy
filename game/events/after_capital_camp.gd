class_name AfterCapitalCamp
extends Node

## Camp Scene: "After the Capital" — Iris and Garrick acknowledge shared guilt
## from their past roles; Kael's "Neither of you is that person anymore" beat.
## Fires once on entering Verdant Forest after lyra_fragment_2_collected is set.
## Source: docs/story/act1/05-into-the-capital.md (Camp Scene)

signal sequence_completed

const FLAG_NAME: String = "after_capital_camp_seen"
const GATE_FLAG: String = "lyra_fragment_2_collected"


## Returns true when the event is eligible to fire:
##   - lyra_fragment_2_collected flag is set
##   - after_capital_camp_seen flag is NOT set
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get(GATE_FLAG, false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Returns the 15-line camp dialogue compressed from the story script.
static func compute_after_capital_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Iris",
			"Garrick.",
		),
		DialogueLine.create(
			"Garrick",
			"Hmm.",
		),
		DialogueLine.create(
			"Iris",
			"When the Gardener said it knew Lyra. That she brought"
				+ " it tea. You went still.",
		),
		DialogueLine.create(
			"Garrick",
			"I go still a lot.",
		),
		DialogueLine.create(
			"Iris",
			"More still than usual. What were you thinking?",
		),
		DialogueLine.create(
			"Garrick",
			"I was thinking about the villages I purged. Whether any"
				+ " of them had a gardener. Whether, somewhere in a"
				+ " pile of crystal ash, there's an Echo of someone"
				+ " who tended flowers and brought people tea and just"
				+ " wanted to grow things.",
		),
		DialogueLine.create(
			"Garrick",
			"Probably. Almost certainly.",
		),
		DialogueLine.create(
			"Iris",
			"I helped build the sensors that would have found that"
				+ " gardener and shipped it to a lab in Gearhaven. So.",
		),
		DialogueLine.create(
			"Garrick",
			"So.",
		),
		DialogueLine.create(
			"Kael",
			"Neither of you is that person anymore.",
		),
		DialogueLine.create(
			"Iris",
			"That doesn't erase what we did.",
		),
		DialogueLine.create(
			"Kael",
			"No. But it means you get to choose what you do next.",
		),
		DialogueLine.create(
			"Garrick",
			"...The stew needs more salt.",
		),
		DialogueLine.create(
			"Iris",
			"I thought it was fine.",
		),
		DialogueLine.create(
			"Garrick",
			"It's adequate. Not the same thing.",
		),
	]


func _build_dialogue() -> Array[DialogueLine]:
	return compute_after_capital_lines()


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var lines: Array[DialogueLine] = _build_dialogue()

	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

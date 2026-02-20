class_name LeavingCapital
extends Node

## Chapter 5 Scene 6 — Leaving the Capital.
## The party processes the dungeon emotionally at the exit gate:
## Garrick on the two million lost, Iris on the Initiative's choice,
## Kael connecting Lyra's memory to the Severance.
## Fires once at the ExitToRuins zone after lyra_fragment_2_collected is set,
## before the scene transition to Verdant Forest.
## Source: docs/story/act1/05-into-the-capital.md (Scene 6)

signal sequence_completed

const FLAG_NAME: String = "leaving_capital_seen"
const GATE_FLAG: String = "lyra_fragment_2_collected"


## Returns true when the scene is eligible to fire:
##   - lyra_fragment_2_collected flag is set
##   - leaving_capital_seen flag is NOT set
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get(GATE_FLAG, false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Returns the 9-line dialogue compressing Chapter 5 Scene 6.
## Garrick on loss, Iris on the Initiative's failure / choice distinction,
## Kael connecting Lyra's "I'm sorry" to the deliberate Severance.
static func compute_leaving_capital_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Garrick",
			"That city was two million people.",
		),
		DialogueLine.create(
			"Iris",
			"Was.",
		),
		DialogueLine.create(
			"Garrick",
			"The Shepherds talk about the Severance like it was justice."
				+ " Divine punishment for human arrogance.",
		),
		DialogueLine.create(
			"Garrick",
			"But walking through those rooms, those apartments..."
				+ " those were just people. Living their lives."
				+ " Eating dinner. Going to work."
				+ " And one day the sky fell and they all became... that.",
		),
		DialogueLine.create(
			"Garrick",
			"There's no justice in that. There's just loss.",
		),
		DialogueLine.create(
			"Iris",
			"The Initiative calls it a technical failure."
				+ " \"If we'd had better safety protocols, the network would have stabilized.\""
				+ " But Lyra's memory showed otherwise."
				+ " It wasn't a failure. It was a choice.",
		),
		DialogueLine.create(
			"Kael",
			"Someone chose the Severance over the Convergence."
				+ " Chose to break everything rather than let everyone become one mind.",
		),
		DialogueLine.create(
			"Kael",
			"And Lyra was part of that choice."
				+ " \"I'm sorry,\" she said. In the memory. Right before the end.",
		),
		DialogueLine.create(
			"Kael",
			"Let's go home. We need to give her this fragment"
				+ " and hear what she remembers.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	DialogueManager.start_dialogue(compute_leaving_capital_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

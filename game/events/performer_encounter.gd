class_name PerformerEncounter
extends Node

## The Performer mini-boss encounter in the Entertainment District.
## An Echo of a singer replaying a tragic final show in the crystal theater.
## Pre-battle dialogue → forced battle → post-battle dialogue on victory.
## Source: docs/game-design/05-dungeon-designs.md (Entertainment District)

signal sequence_completed

const FLAG_NAME: String = "performer_encountered"
const GATE_FLAG: String = "node_market_north_cleared"
const PERFORMER_PATH: String = "res://data/enemies/the_performer.tres"


## Returns true when the encounter is eligible to fire:
##   - Market → Entertainment purification node is cleared
##   - performer_encountered flag is NOT set
static func compute_can_trigger(flags: Dictionary) -> bool:
	if not flags.get(GATE_FLAG, false):
		return false
	if flags.get(FLAG_NAME, false):
		return false
	return true


## Returns the 4-line pre-battle approach dialogue.
static func compute_pre_battle_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"The Performer",
			"Ah — an audience. At last. I've been waiting."
				+ " The curtain never fell, you see. The show simply... continued.",
		),
		DialogueLine.create(
			"Kael",
			"It's an Echo. But this one knows we're here.",
		),
		DialogueLine.create(
			"Garrick",
			"Look at the stage lights. They're focusing on us."
				+ " It thinks we're part of the performance.",
		),
		DialogueLine.create(
			"The Performer",
			"Every good show needs a finale."
				+ " And every finale needs someone to remember it."
				+ " Shall we begin?",
		),
	]


## Returns the 2-line post-battle dialogue after the player wins.
static func compute_post_battle_lines() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"The Performer",
			"The lights are dimming. Finally. I was so tired of the encore.",
		),
		DialogueLine.create(
			"Kael",
			"Three hundred years of performing for an empty theater."
				+ " At least someone was here for the last bow.",
		),
	]


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	DialogueManager.start_dialogue(compute_pre_battle_lines())
	await DialogueManager.dialogue_ended

	GameManager.pop_state()

	var performer := load(PERFORMER_PATH) as Resource
	if not performer:
		push_error("PerformerEncounter: failed to load the_performer.tres.")
		sequence_completed.emit()
		return

	BattleManager.battle_ended.connect(
		_on_performer_battle_ended,
		CONNECT_ONE_SHOT,
	)
	BattleManager.start_battle([performer] as Array[Resource], false)
	# Emit before battle scene loads so the caller can free this node.
	# The static callback handles post-battle dialogue independently.
	sequence_completed.emit()


static func _on_performer_battle_ended(victory: bool) -> void:
	if not victory:
		return
	_complete_performer_encounter()


static func _complete_performer_encounter() -> void:
	GameManager.push_state(GameManager.GameState.CUTSCENE)
	DialogueManager.start_dialogue(
		PerformerEncounter.compute_post_battle_lines()
	)
	await DialogueManager.dialogue_ended
	GameManager.pop_state()

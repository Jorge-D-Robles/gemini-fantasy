class_name BossEncounter
extends Node

## Boss encounter: The Last Gardener in the Overgrown Ruins.
## A scripted one-time boss fight at the deepest part of the ruins.
## After victory, sets the "boss_defeated" flag and awards bonus rewards.

signal sequence_completed

const FLAG_NAME: String = "boss_defeated"
const LAST_GARDENER_PATH: String = "res://data/enemies/last_gardener.tres"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var pre_battle_lines: Array[DialogueLine] = [
		DialogueLine.create(
			"Lyra",
			"Wait... I sense something. A powerful Echo, twisted beyond recognition."
		),
		DialogueLine.create(
			"Kael",
			"That shape... it was human once, wasn't it?"
		),
		DialogueLine.create(
			"Lyra",
			"The city's last caretaker. The gardens consumed him when the Severance hit."
		),
		DialogueLine.create(
			"Kael",
			"It's blocking our path. We have no choice — ready yourselves!"
		),
	]

	DialogueManager.start_dialogue(pre_battle_lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()

	# Start forced boss battle — no escape allowed
	var last_gardener := load(LAST_GARDENER_PATH) as Resource
	if last_gardener:
		var enemy_group: Array[Resource] = [last_gardener]
		BattleManager.battle_ended.connect(
			_on_boss_battle_ended, CONNECT_ONE_SHOT,
		)
		BattleManager.start_battle(enemy_group, false)
	else:
		push_error("BossEncounter: failed to load Last Gardener data.")
		_complete_boss_encounter()


static func _on_boss_battle_ended(victory: bool) -> void:
	if not victory:
		# On defeat, don't set the flag — player can retry next visit
		return
	_complete_boss_encounter()


static func _complete_boss_encounter() -> void:
	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Award bonus gold on top of battle rewards
	InventoryManager.add_gold(200)

	var post_battle_lines: Array[DialogueLine] = [
		DialogueLine.create(
			"Lyra",
			"It's over... the Echo has been released. I can feel its pain fading."
		),
		DialogueLine.create(
			"Kael",
			"So that's what happens when an Echo is corrupted for too long."
		),
		DialogueLine.create(
			"Lyra",
			"We need to find out who — or what — is causing this. Before it's too late."
		),
	]

	DialogueManager.start_dialogue(post_battle_lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()

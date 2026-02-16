class_name IrisRecruitment
extends Node

## Iris recruitment event in the Verdant Forest.
## Triggers a cutscene, a forced battle, then Iris joins the party.

signal sequence_completed

const FLAG_NAME: String = "iris_recruited"
const IRIS_DATA_PATH: String = "res://data/characters/iris.tres"
const ASH_STALKER_PATH: String = "res://data/enemies/ash_stalker.tres"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var pre_battle_lines: Array[Dictionary] = [
		{
			"speaker": "Iris",
			"text": "Hah! These things just keep coming!",
		},
		{
			"speaker": "Kael",
			"text": "Need a hand?",
		},
		{
			"speaker": "Iris",
			"text": "I won't turn it down! Watch the flanks!",
		},
	]

	DialogueManager.start_dialogue(pre_battle_lines)
	await DialogueManager.dialogue_ended

	# Add Iris to party before battle so she participates
	var iris_data := load(IRIS_DATA_PATH) as Resource
	if iris_data:
		PartyManager.add_character(iris_data)

	GameManager.pop_state()

	# Start forced battle with 2 Ash Stalkers
	var ash_stalker := load(ASH_STALKER_PATH) as Resource
	if ash_stalker:
		var enemy_group: Array[Resource] = [ash_stalker, ash_stalker]
		BattleManager.start_battle(enemy_group, false)
		await BattleManager.battle_ended

	# Post-battle dialogue
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var post_battle_lines: Array[Dictionary] = [
		{
			"speaker": "Iris",
			"text": "Not bad! Name's Iris. I'm an engineer from the eastern settlements.",
		},
		{
			"speaker": "Kael",
			"text": "Kael. I found something strange in the ruins... a conscious Echo.",
		},
		{
			"speaker": "Iris",
			"text": "A conscious Echo? That shouldn't be possible. I need to see this.",
		},
		{
			"speaker": "Iris",
			"text": "Mind if I tag along? I've got some theories about the Echo interference.",
		},
	]

	DialogueManager.start_dialogue(post_battle_lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	sequence_completed.emit()

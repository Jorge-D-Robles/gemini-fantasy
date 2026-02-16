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

	var pre_battle_lines: Array[DialogueLine] = [
		DialogueLine.create("Iris", "Hah! These things just keep coming!"),
		DialogueLine.create("Kael", "Need a hand?"),
		DialogueLine.create("Iris", "I won't turn it down! Watch the flanks!"),
	]

	DialogueManager.start_dialogue(pre_battle_lines)
	await DialogueManager.dialogue_ended

	# Add Iris to party before battle so she participates
	var iris_data := load(IRIS_DATA_PATH) as Resource
	if iris_data:
		PartyManager.add_character(iris_data)

	GameManager.pop_state()

	# Start forced battle with 2 Ash Stalkers.
	# Register a ONE_SHOT callback on BattleManager.battle_ended so that
	# post-battle dialogue runs even though this node is freed during the
	# scene change. The callback is a static-like lambda that only
	# references autoloads (which survive scene changes).
	var ash_stalker := load(ASH_STALKER_PATH) as Resource
	if ash_stalker:
		var enemy_group: Array[Resource] = [ash_stalker, ash_stalker]
		BattleManager.battle_ended.connect(
			_on_iris_battle_ended, CONNECT_ONE_SHOT,
		)
		BattleManager.start_battle(enemy_group, false)
	else:
		# If enemy data failed to load, skip battle and finish
		_play_post_battle_dialogue()


static func _on_iris_battle_ended(victory: bool) -> void:
	if not victory:
		# On defeat, clear the flag so the event can re-trigger
		EventFlags.clear_flag(FLAG_NAME)
		return
	_play_post_battle_dialogue()


static func _play_post_battle_dialogue() -> void:
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var post_battle_lines: Array[DialogueLine] = [
		DialogueLine.create("Iris", "Not bad! Name's Iris. I'm an engineer from the eastern settlements."),
		DialogueLine.create("Kael", "Kael. I found something strange in the ruins... a conscious Echo."),
		DialogueLine.create("Iris", "A conscious Echo? That shouldn't be possible. I need to see this."),
		DialogueLine.create("Iris", "Mind if I tag along? I've got some theories about the Echo interference."),
	]

	DialogueManager.start_dialogue(post_battle_lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()

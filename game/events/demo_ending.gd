class_name DemoEnding
extends Node

## Brief closing dialogue after GarrickMeetsLyra, then transition to
## the demo end screen. Does NOT emit sequence_completed — the scene
## changes instead.

signal sequence_completed  # Declared for pattern consistency; not emitted (scene changes instead)

const FLAG_NAME: String = "demo_complete"
const SP = preload("res://systems/scene_paths.gd")


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var lines: Array[DialogueLine] = _build_dialogue()
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	GameManager.pop_state()
	AudioManager.stop_bgm()
	GameManager.change_scene(SP.DEMO_END_SCREEN)


func _build_dialogue() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Kael",
			"There's still so much we don't understand. But our path leads deeper — I can feel it.",
		),
		DialogueLine.create(
			"Lyra",
			"The fragments... they resonate more strongly now. Whatever awaits us, we face it together.",
		),
		DialogueLine.create(
			"Garrick",
			"I've walked a long road to get here."
			+ " I'm not turning back — not when there's"
			+ " still something worth protecting.",
		),
		DialogueLine.create(
			"Kael",
			"Then let's keep moving. The journey is just beginning.",
		),
	]

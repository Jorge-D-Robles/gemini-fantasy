class_name GarrickRecruitment
extends Node

## Garrick recruitment event in Roothollow.
## Triggered when the player talks to Garrick NPC after certain conditions.

signal sequence_completed

const FLAG_NAME: String = "garrick_recruited"
const GARRICK_DATA_PATH: String = "res://data/characters/garrick.tres"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	var lines: Array[Dictionary] = [
		{
			"speaker": "Garrick",
			"text": "Another traveler? These roads grow more dangerous by the day.",
		},
		{
			"speaker": "Kael",
			"text": "We found something in the ruins. A conscious Echo Fragment.",
		},
		{
			"speaker": "Garrick",
			"text": "...Impossible. I've guarded these lands for twenty years and never...",
		},
		{
			"speaker": "Garrick",
			"text": "If what you say is true, the Council needs to know. And you'll need protection.",
		},
		{
			"speaker": "Kael",
			"text": "You're offering to help?",
		},
		{
			"speaker": "Garrick",
			"text": "I'm offering to keep you alive. The path ahead won't be kind.",
		},
	]

	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	# Garrick joins party
	var garrick_data := load(GARRICK_DATA_PATH) as Resource
	if garrick_data:
		PartyManager.add_character(garrick_data)

	GameManager.pop_state()
	sequence_completed.emit()

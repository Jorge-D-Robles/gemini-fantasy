class_name HackingPuzzleData
extends Resource

## Defines a hackable terminal's puzzle parameters.
## Cipher uses Resonance to interface with technology.

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Puzzle")
@export var difficulty: Difficulty = Difficulty.EASY
@export var sequence_length: int = 3
@export var max_attempts: int = 3
@export var time_limit: float = 0.0

@export_group("Rewards")
@export var flag_on_solve: String = ""
@export var reward_text: String = ""

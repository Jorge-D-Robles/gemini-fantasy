class_name HackingSystem
extends RefCounted

## Core logic for Cipher's hacking puzzles.
## Sequence-matching mechanic: player must guess the correct
## symbol sequence. Feedback shows correct positions and
## correct values in wrong positions (similar to Mastermind).


## Generates a random sequence of the given length using
## symbol indices in range [0, symbol_count).
static func generate_sequence(
	length: int, symbol_count: int,
) -> Array[int]:
	var seq: Array[int] = []
	for i in length:
		seq.append(randi() % symbol_count)
	return seq


## Checks an attempt against the solution.
## Returns a Dictionary with:
##   success: bool — true if attempt matches solution exactly
##   correct_positions: int — symbols in the correct position
##   correct_values: int — correct symbols in wrong positions
static func check_attempt(
	solution: Array, attempt: Array,
) -> Dictionary:
	var correct_pos := 0
	var correct_val := 0
	var sol_remaining: Array[int] = []
	var att_remaining: Array[int] = []

	for i in solution.size():
		if i < attempt.size() and attempt[i] == solution[i]:
			correct_pos += 1
		else:
			if i < solution.size():
				sol_remaining.append(solution[i])
			if i < attempt.size():
				att_remaining.append(attempt[i])

	for val in att_remaining:
		var idx := sol_remaining.find(val)
		if idx >= 0:
			correct_val += 1
			sol_remaining.remove_at(idx)

	return {
		"success": correct_pos == solution.size(),
		"correct_positions": correct_pos,
		"correct_values": correct_val,
	}


## Returns true if Cipher is available to hack.
static func compute_can_hack(flags: Dictionary) -> bool:
	return flags.get("cipher_recruited", false)


## Returns the number of distinct symbols for a difficulty.
static func compute_symbol_count(
	difficulty: HackingPuzzleData.Difficulty,
) -> int:
	match difficulty:
		HackingPuzzleData.Difficulty.EASY:
			return 4
		HackingPuzzleData.Difficulty.MEDIUM:
			return 5
		HackingPuzzleData.Difficulty.HARD:
			return 6
		_:
			return 4

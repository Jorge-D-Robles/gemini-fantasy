# gdlint:ignore = max-public-methods
extends GutTest

## Tests for the hacking puzzle system:
## HackingPuzzleData resource and HackingSystem logic.

const Helpers := preload("res://tests/helpers/test_helpers.gd")


# --- HackingPuzzleData defaults ---


func test_puzzle_data_default_id() -> void:
	var d := HackingPuzzleData.new()
	assert_eq(d.id, &"", "Default id should be empty")


func test_puzzle_data_default_difficulty() -> void:
	var d := HackingPuzzleData.new()
	assert_eq(
		d.difficulty,
		HackingPuzzleData.Difficulty.EASY,
		"Default difficulty should be EASY",
	)


func test_puzzle_data_default_sequence_length() -> void:
	var d := HackingPuzzleData.new()
	assert_eq(
		d.sequence_length, 3,
		"Default sequence length should be 3",
	)


func test_puzzle_data_default_max_attempts() -> void:
	var d := HackingPuzzleData.new()
	assert_eq(
		d.max_attempts, 3,
		"Default max attempts should be 3",
	)


func test_puzzle_data_default_time_limit() -> void:
	var d := HackingPuzzleData.new()
	assert_eq(
		d.time_limit, 0.0,
		"Default time limit should be 0 (no limit)",
	)


# --- Difficulty presets ---


func test_easy_sequence_length() -> void:
	var d := HackingPuzzleData.new()
	d.difficulty = HackingPuzzleData.Difficulty.EASY
	d.sequence_length = 3
	assert_eq(d.sequence_length, 3)


func test_hard_can_have_longer_sequence() -> void:
	var d := HackingPuzzleData.new()
	d.difficulty = HackingPuzzleData.Difficulty.HARD
	d.sequence_length = 6
	assert_eq(d.sequence_length, 6)


# --- HackingSystem.generate_sequence ---


func test_generate_sequence_correct_length() -> void:
	var seq := HackingSystem.generate_sequence(4, 4)
	assert_eq(seq.size(), 4, "Generated sequence should match length")


func test_generate_sequence_values_in_range() -> void:
	var seq := HackingSystem.generate_sequence(5, 4)
	for val in seq:
		assert_true(
			val >= 0 and val < 4,
			"Value %d should be in range [0, 4)" % val,
		)


func test_generate_sequence_minimum_length() -> void:
	var seq := HackingSystem.generate_sequence(1, 2)
	assert_eq(seq.size(), 1)


# --- HackingSystem.check_attempt ---


func test_check_attempt_correct() -> void:
	var solution := [0, 1, 2, 3]
	var attempt := [0, 1, 2, 3]
	var result := HackingSystem.check_attempt(
		solution, attempt,
	)
	assert_true(result.success, "Exact match should succeed")
	assert_eq(result.correct_positions, 4)
	assert_eq(result.correct_values, 0)


func test_check_attempt_wrong() -> void:
	var solution := [0, 1, 2, 3]
	var attempt := [3, 3, 3, 3]
	var result := HackingSystem.check_attempt(
		solution, attempt,
	)
	assert_false(result.success, "Wrong attempt should fail")


func test_check_attempt_partial_position() -> void:
	var solution := [0, 1, 2]
	var attempt := [0, 2, 1]
	var result := HackingSystem.check_attempt(
		solution, attempt,
	)
	assert_false(result.success)
	assert_eq(
		result.correct_positions, 1,
		"First position matches",
	)
	assert_eq(
		result.correct_values, 2,
		"Two values correct but wrong position",
	)


func test_check_attempt_all_wrong() -> void:
	var solution := [0, 1, 2]
	var attempt := [3, 3, 3]
	var result := HackingSystem.check_attempt(
		solution, attempt,
	)
	assert_eq(result.correct_positions, 0)
	assert_eq(result.correct_values, 0)


# --- HackingSystem.compute_can_hack ---


func test_can_hack_requires_cipher() -> void:
	assert_false(
		HackingSystem.compute_can_hack({}),
		"Cannot hack without Cipher in party",
	)


func test_can_hack_with_cipher() -> void:
	assert_true(
		HackingSystem.compute_can_hack(
			{"cipher_recruited": true}
		),
		"Can hack with Cipher recruited",
	)


# --- HackingSystem.compute_symbol_count ---


func test_symbol_count_easy() -> void:
	assert_eq(
		HackingSystem.compute_symbol_count(
			HackingPuzzleData.Difficulty.EASY
		),
		4,
		"Easy uses 4 symbols",
	)


func test_symbol_count_medium() -> void:
	assert_eq(
		HackingSystem.compute_symbol_count(
			HackingPuzzleData.Difficulty.MEDIUM
		),
		5,
		"Medium uses 5 symbols",
	)


func test_symbol_count_hard() -> void:
	assert_eq(
		HackingSystem.compute_symbol_count(
			HackingPuzzleData.Difficulty.HARD
		),
		6,
		"Hard uses 6 symbols",
	)

extends GutTest

## Tests for AudioManager BGM push/pop stack (T-0117).
## Verifies that push_bgm saves and pop_bgm restores BGM state.

const AMScript := preload("res://autoloads/audio_manager.gd")

var _am: Node


func before_each() -> void:
	_am = AMScript.new()
	add_child_autofree(_am)


# -- stack state --


func test_has_stacked_bgm_false_initially() -> void:
	assert_false(
		_am.has_stacked_bgm(),
		"Stack should be empty initially",
	)


func test_has_stacked_bgm_true_after_push() -> void:
	_am.push_bgm()
	assert_true(
		_am.has_stacked_bgm(),
		"Stack should have entry after push",
	)


func test_has_stacked_bgm_false_after_push_pop() -> void:
	_am.push_bgm()
	_am.pop_bgm(0.0)
	assert_false(
		_am.has_stacked_bgm(),
		"Stack should be empty after pop",
	)


func test_pop_bgm_empty_stack_no_crash() -> void:
	# Should not crash when popping empty stack
	_am.pop_bgm(0.0)
	assert_false(_am.has_stacked_bgm())


func test_multiple_push_pop_works() -> void:
	_am.push_bgm()
	_am.push_bgm()
	assert_true(_am.has_stacked_bgm())
	_am.pop_bgm(0.0)
	assert_true(
		_am.has_stacked_bgm(),
		"Should still have one entry",
	)
	_am.pop_bgm(0.0)
	assert_false(
		_am.has_stacked_bgm(),
		"Should be empty after two pops",
	)


# -- get_current_bgm_path still works --


func test_get_current_bgm_path_empty_on_fresh_manager() -> void:
	assert_eq(_am.get_current_bgm_path(), "")


# -- BGM restore fade duration --


func test_compute_bgm_restore_fade_duration_is_half_default() -> void:
	assert_eq(
		_am.compute_bgm_restore_fade_duration(),
		_am.DEFAULT_FADE_TIME / 2.0,
		"Restore fade should be half the default fade time",
	)


func test_compute_bgm_restore_fade_duration_is_less_than_default() -> void:
	assert_lt(
		_am.compute_bgm_restore_fade_duration(),
		_am.DEFAULT_FADE_TIME,
		"Restore fade should be shorter than default crossfade",
	)

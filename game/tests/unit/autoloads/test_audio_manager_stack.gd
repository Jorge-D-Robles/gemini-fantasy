extends GutTest

## Tests for AudioManager BGM push/pop stack (T-0117).
## Verifies that push_bgm saves and pop_bgm restores BGM state.

const AMScript := preload("res://autoloads/audio_manager.gd")

var _am: Node


func before_each() -> void:
	_am = AMScript.new()
	add_child_autofree(_am)


# -- push_bgm / pop_bgm existence --


func test_push_bgm_method_exists() -> void:
	assert_true(
		_am.has_method("push_bgm"),
		"AudioManager should have push_bgm()",
	)


func test_pop_bgm_method_exists() -> void:
	assert_true(
		_am.has_method("pop_bgm"),
		"AudioManager should have pop_bgm()",
	)


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

extends GutTest

## Tests for EventFlags autoload logic.
## Creates a fresh instance per test — never touches the global singleton.

var _flags: Node


func before_each() -> void:
	_flags = load("res://events/event_flags.gd").new()
	add_child_autofree(_flags)


func test_set_and_has_flag() -> void:
	assert_false(_flags.has_flag("quest_started"))
	_flags.set_flag("quest_started")
	assert_true(_flags.has_flag("quest_started"))


func test_clear_flag() -> void:
	_flags.set_flag("boss_defeated")
	_flags.clear_flag("boss_defeated")
	assert_false(_flags.has_flag("boss_defeated"))


func test_clear_nonexistent_flag_no_error() -> void:
	_flags.clear_flag("never_set")
	assert_false(_flags.has_flag("never_set"))


func test_get_all_flags_returns_copy() -> void:
	_flags.set_flag("a")
	_flags.set_flag("b")
	var all_flags: Dictionary = _flags.get_all_flags()
	assert_eq(all_flags.size(), 2)
	assert_true(all_flags.has("a"))
	assert_true(all_flags.has("b"))
	# Verify it is a copy — mutating it should not affect internal state
	all_flags["c"] = true
	assert_false(_flags.has_flag("c"))


func test_load_flags_replaces_state() -> void:
	_flags.set_flag("old_flag")
	_flags.load_flags({"saved_flag": true, "other": true})
	assert_false(_flags.has_flag("old_flag"))
	assert_true(_flags.has_flag("saved_flag"))
	assert_true(_flags.has_flag("other"))


func test_load_flags_is_independent_copy() -> void:
	var source := {"x": true}
	_flags.load_flags(source)
	source["y"] = true
	assert_false(_flags.has_flag("y"))

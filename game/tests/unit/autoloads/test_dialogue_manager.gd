extends GutTest

## Tests for DialogueManager state logic.
## Creates a fresh instance per test — never touches the global singleton.
## NOTE: start_dialogue/end call GameManager autoload directly; these tests
## accept that coupling and verify internal state management.

var _dm: Node


func before_each() -> void:
	_dm = load("res://autoloads/dialogue_manager.gd").new()
	add_child_autofree(_dm)


func test_initial_state_inactive() -> void:
	assert_false(_dm.is_active())


func test_advance_while_inactive_does_nothing() -> void:
	watch_signals(_dm)
	_dm.advance()
	assert_signal_not_emitted(_dm, "line_displayed")


func test_skip_while_inactive_does_nothing() -> void:
	watch_signals(_dm)
	_dm.skip()
	assert_signal_not_emitted(_dm, "line_finished")


func test_select_choice_while_not_waiting_does_nothing() -> void:
	watch_signals(_dm)
	_dm.select_choice(0)
	assert_signal_not_emitted(_dm, "choice_selected")


func test_start_dialogue_emits_started_and_first_line() -> void:
	var lines: Array[DialogueLine] = [
		DialogueLine.create("NPC", "Hello there."),
	]
	watch_signals(_dm)
	_dm.start_dialogue(lines)
	assert_true(_dm.is_active())
	assert_signal_emitted(_dm, "dialogue_started")
	assert_signal_emitted(_dm, "line_displayed")


func test_start_dialogue_while_active_rejected() -> void:
	var lines: Array[DialogueLine] = [
		DialogueLine.create("NPC", "Hello."),
		DialogueLine.create("NPC", "More text."),
	]
	_dm.start_dialogue(lines)
	watch_signals(_dm)
	_dm.start_dialogue(lines)
	# Second call should be rejected — no second dialogue_started
	assert_signal_not_emitted(_dm, "dialogue_started")


func test_advance_past_last_line_ends_dialogue() -> void:
	var lines: Array[DialogueLine] = [
		DialogueLine.create("NPC", "Only line."),
	]
	_dm.start_dialogue(lines)
	watch_signals(_dm)
	_dm.advance()
	assert_false(_dm.is_active())
	assert_signal_emitted(_dm, "dialogue_ended")


func test_multiple_lines_advance() -> void:
	var lines: Array[DialogueLine] = [
		DialogueLine.create("A", "First."),
		DialogueLine.create("B", "Second."),
		DialogueLine.create("C", "Third."),
	]
	_dm.start_dialogue(lines)  # displays line 0
	_dm.advance()              # displays line 1
	_dm.advance()              # displays line 2
	assert_true(_dm.is_active())
	_dm.advance()              # past end -> ends
	assert_false(_dm.is_active())


func test_choice_blocks_advance() -> void:
	var lines: Array[DialogueLine] = [
		DialogueLine.create("NPC", "Pick one.", null, ["Yes", "No"] as Array[String]),
		DialogueLine.create("NPC", "After choice."),
	]
	_dm.start_dialogue(lines)  # displays choice line
	watch_signals(_dm)
	# Advance should be blocked because we're waiting for choice
	_dm.advance()
	assert_signal_not_emitted(_dm, "line_displayed")


func test_select_choice_emits_and_advances() -> void:
	var lines: Array[DialogueLine] = [
		DialogueLine.create("NPC", "Pick one.", null, ["Yes", "No"] as Array[String]),
		DialogueLine.create("NPC", "After choice."),
	]
	_dm.start_dialogue(lines)  # displays choice line
	watch_signals(_dm)
	_dm.select_choice(1)
	assert_signal_emitted_with_parameters(_dm, "choice_selected", [1])
	assert_signal_emitted(_dm, "line_displayed")


func test_select_choice_invalid_index_rejected() -> void:
	var lines: Array[DialogueLine] = [
		DialogueLine.create("NPC", "Pick.", null, ["A", "B"] as Array[String]),
	]
	_dm.start_dialogue(lines)
	watch_signals(_dm)
	_dm.select_choice(5)  # out of bounds
	assert_signal_not_emitted(_dm, "choice_selected")
	# Should still be waiting for choice
	_dm.select_choice(-1)
	assert_signal_not_emitted(_dm, "choice_selected")

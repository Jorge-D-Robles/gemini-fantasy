extends GutTest

## Tests for StateMachine and State base classes.

var _machine: StateMachine
var _state_a: State
var _state_b: State
var _state_c: State


func before_each() -> void:
	_machine = StateMachine.new()
	_state_a = State.new()
	_state_a.name = "StateA"
	_state_b = State.new()
	_state_b.name = "StateB"
	_state_c = State.new()
	_state_c.name = "StateC"
	_machine.add_child(_state_a)
	_machine.add_child(_state_b)
	_machine.add_child(_state_c)


func _add_machine_to_tree() -> void:
	add_child_autofree(_machine)


func test_initial_state_entered_on_ready() -> void:
	_machine.initial_state = _state_a
	_add_machine_to_tree()
	assert_eq(_machine.current_state, _state_a)


func test_children_have_state_machine_ref() -> void:
	_machine.initial_state = _state_a
	_add_machine_to_tree()
	assert_eq(_state_a.state_machine, _machine)
	assert_eq(_state_b.state_machine, _machine)
	assert_eq(_state_c.state_machine, _machine)


func test_no_initial_state_leaves_current_null() -> void:
	_add_machine_to_tree()
	assert_null(_machine.current_state)


func test_transition_to_valid_state() -> void:
	_machine.initial_state = _state_a
	_add_machine_to_tree()
	_machine.transition_to(&"StateB")
	assert_eq(_machine.current_state, _state_b)


func test_transition_to_invalid_state_stays() -> void:
	_machine.initial_state = _state_a
	_add_machine_to_tree()
	_machine.transition_to(&"NonExistent")
	assert_eq(_machine.current_state, _state_a)
	assert_push_error("NonExistent")


func test_transition_to_same_state_is_noop() -> void:
	_machine.initial_state = _state_a
	_add_machine_to_tree()
	watch_signals(_machine)
	_machine.transition_to(&"StateA")
	assert_eq(_machine.current_state, _state_a)
	assert_signal_not_emitted(_machine, "state_changed")


func test_state_changed_signal_emitted() -> void:
	_machine.initial_state = _state_a
	_add_machine_to_tree()
	watch_signals(_machine)
	_machine.transition_to(&"StateB")
	assert_signal_emitted(_machine, "state_changed")


func test_state_changed_signal_params() -> void:
	_machine.initial_state = _state_a
	_add_machine_to_tree()
	watch_signals(_machine)
	_machine.transition_to(&"StateB")
	var params: Array = get_signal_parameters(_machine, "state_changed")
	assert_eq(params[0], _state_a)
	assert_eq(params[1], _state_b)


func test_chained_transitions() -> void:
	_machine.initial_state = _state_a
	_add_machine_to_tree()
	_machine.transition_to(&"StateB")
	_machine.transition_to(&"StateC")
	assert_eq(_machine.current_state, _state_c)


func test_get_current_state() -> void:
	_machine.initial_state = _state_b
	_add_machine_to_tree()
	assert_eq(_machine.get_current_state(), _state_b)


func test_get_current_state_null_without_initial() -> void:
	_add_machine_to_tree()
	assert_null(_machine.get_current_state())


func test_transition_from_null_state() -> void:
	_add_machine_to_tree()
	watch_signals(_machine)
	_machine.transition_to(&"StateA")
	assert_eq(_machine.current_state, _state_a)
	assert_signal_emitted(_machine, "state_changed")
	var params: Array = get_signal_parameters(_machine, "state_changed")
	assert_null(params[0])
	assert_eq(params[1], _state_a)

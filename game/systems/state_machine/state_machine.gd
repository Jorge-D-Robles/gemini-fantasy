class_name StateMachine
extends Node

## Generic node-based state machine. Each state is a child node extending State.

signal state_changed(old_state: State, new_state: State)

@export var initial_state: State

var current_state: State


func _ready() -> void:
	for child in get_children():
		if child is State:
			child.state_machine = self
	if initial_state:
		_enter_state(initial_state)


func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func transition_to(state_name: StringName) -> void:
	var new_state: State = get_node_or_null(NodePath(state_name))
	if not new_state:
		push_error("StateMachine: state '%s' not found." % state_name)
		return
	if new_state == current_state:
		return
	var old_state := current_state
	if current_state:
		current_state.exit()
	_enter_state(new_state)
	state_changed.emit(old_state, new_state)


func get_current_state() -> State:
	return current_state


func _enter_state(new_state: State) -> void:
	current_state = new_state
	current_state.enter()

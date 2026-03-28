extends Node
class_name BattleStateMachine
## Manages battle state transitions.

signal state_changed(old_state: String, new_state: String)

var current_state: BattleState
var states: Dictionary = {}


func _ready() -> void:
	for child in get_children():
		if child is BattleState:
			states[child.name] = child
	if states.is_empty():
		push_error("BattleStateMachine: no states registered.")


func start(initial_state: String, context: Dictionary = {}) -> void:
	current_state = states.get(initial_state)
	if current_state:
		current_state.enter(context)


func transition_to(new_state_name: String, context: Dictionary = {}) -> void:
	var new_state: BattleState = states.get(new_state_name)
	if not new_state:
		push_error("BattleStateMachine: no state named " + new_state_name)
		return

	var old_name := current_state.name if current_state else ""
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(context)
	state_changed.emit(old_name, new_state_name)


func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)

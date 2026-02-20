class_name PurificationNodeStrategy
extends InteractionStrategy

## Interaction strategy for Purification Nodes in the Overgrown Capital.
## Activating a node clears a crystal-blocked dungeon path — one-time, persistent.
## The node_cleared signal fires synchronously so the scene can remove crystal
## walls before showing the activation dialogue.

signal node_cleared(node_id: String)

@export var node_id: String = ""
@export var activation_lines: Array[String] = []


static func compute_flag_name(p_node_id: String) -> String:
	## Returns the EventFlags key for this node: "node_<id>_cleared".
	return "node_" + p_node_id + "_cleared"


static func compute_node_active_state(flags: Dictionary, p_node_id: String) -> bool:
	## Returns true when the node has NOT been cleared (path still blocked).
	## Returns false when the flag is set (path already cleared).
	return not flags.has(compute_flag_name(p_node_id))


func execute(owner: Node) -> void:
	if owner.has_been_used:
		return
	if EventFlags.has_flag(compute_flag_name(node_id)):
		return
	# Emit first so scene removes crystal wall synchronously before dialogue.
	node_cleared.emit(node_id)
	EventFlags.set_flag(compute_flag_name(node_id))
	owner.has_been_used = true
	if activation_lines.is_empty():
		return
	var lines: Array[DialogueLine] = _build_activation_lines()
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended


func _build_activation_lines() -> Array[DialogueLine]:
	if activation_lines.size() % 2 != 0:
		push_warning(
			"PurificationNodeStrategy '%s': activation_lines has odd count; last entry ignored."
			% node_id
		)
	var result: Array[DialogueLine] = []
	var i := 0
	while i + 1 < activation_lines.size():
		result.append(DialogueLine.create(activation_lines[i], activation_lines[i + 1]))
		i += 2
	return result

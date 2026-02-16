extends State

## Initial battle state. Brief intro delay then starts turn queue.

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	# Brief delay before battle begins
	await get_tree().create_timer(0.5).timeout
	state_machine.transition_to("TurnQueueState")

class_name BattleStateMachine
extends StateMachine

## Extends the generic state machine with battle-specific context.
## Child states can access battle_scene for party, enemies, turn queue, etc.

var battle_scene: Node = null


func setup(scene: Node) -> void:
	battle_scene = scene
	for child in get_children():
		if child is State and child.has_method("set_battle_scene"):
			child.set_battle_scene(scene)

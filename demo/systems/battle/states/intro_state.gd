extends BattleState
## Brief intro animation before combat begins.


func enter(_context: Dictionary = {}) -> void:
	await get_tree().create_timer(0.5).timeout
	battle_manager._state_machine.transition_to("TurnStart")

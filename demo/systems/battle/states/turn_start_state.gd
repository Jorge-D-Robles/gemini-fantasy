extends BattleState
## Builds the turn queue and starts processing turns.


func enter(_context: Dictionary = {}) -> void:
	battle_manager.build_turn_queue()
	_process_next_turn()


func _process_next_turn() -> void:
	var battler := battle_manager.get_next_battler()
	if battler == null:
		battle_manager._state_machine.transition_to("TurnStart")
		return

	battle_manager.current_battler = battler
	battler.defense_boost = 0
	battle_manager.turn_started.emit(battler)

	if battler.is_player_controlled:
		battle_manager._state_machine.transition_to("PlayerChoice", {battler = battler})
	else:
		battle_manager._state_machine.transition_to("ActionExecute", {
			battler = battler,
			action = "enemy_turn",
		})

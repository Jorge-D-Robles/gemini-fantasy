extends BattleState
## Checks if the battle is over after an action.


func enter(_context: Dictionary = {}) -> void:
	if not battle_manager.is_enemy_alive():
		battle_manager._state_machine.transition_to("Victory")
	elif not battle_manager.is_party_alive():
		battle_manager._state_machine.transition_to("Defeat")
	else:
		_process_next_in_queue()


func _process_next_in_queue() -> void:
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

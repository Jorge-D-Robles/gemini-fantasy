extends State

## Determines the next battler to act and transitions to appropriate state.

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	var result: int = battle_scene.check_battle_end()
	if result == 1:
		state_machine.transition_to("Victory")
		return
	if result == -1:
		state_machine.transition_to("Defeat")
		return

	var next_battler: Battler = battle_scene.turn_queue.advance()
	if not next_battler:
		push_error("TurnQueueState: turn queue returned null — reinitializing.")
		battle_scene.turn_queue.initialize(battle_scene.all_battlers)
		next_battler = battle_scene.turn_queue.advance()
		if not next_battler:
			state_machine.transition_to("Defeat")
			return

	battle_scene.current_battler = next_battler

	# Stunned battlers skip their turn
	if next_battler.is_action_prevented():
		var battle_ui: Node = battle_scene.get_node_or_null(
			"BattleUI"
		)
		if battle_ui:
			battle_ui.add_battle_log(
				"%s is stunned!" % next_battler.get_display_name()
			)
		state_machine.transition_to("TurnEnd")
		return

	if next_battler is PartyBattler:
		state_machine.transition_to("PlayerTurn")
	elif next_battler is EnemyBattler:
		state_machine.transition_to("EnemyTurn")

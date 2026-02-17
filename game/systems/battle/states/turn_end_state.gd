extends State

## Ends the current battler's turn and returns to the turn queue.

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	var battler: Battler = battle_scene.current_battler
	if battler:
		battler.tick_effects()
		battler.end_turn()

	var battle_ui: Node = battle_scene.get_node_or_null("BattleUI")
	if battle_ui:
		battle_ui.update_party_status(battle_scene.get_living_party())
		battle_ui.update_turn_order(
			battle_scene.turn_queue.peek_order()
		)

	state_machine.transition_to("TurnQueueState")

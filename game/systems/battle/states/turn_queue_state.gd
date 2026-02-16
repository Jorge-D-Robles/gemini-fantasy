extends State

## Determines the next battler to act and transitions to appropriate state.

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	var result := battle_scene.check_battle_end()
	if result == 1:
		state_machine.transition_to("Victory")
		return
	elif result == -1:
		state_machine.transition_to("Defeat")
		return

	var next_battler: Battler = battle_scene.turn_queue.advance()
	if not next_battler:
		state_machine.transition_to("Victory")
		return

	battle_scene.current_battler = next_battler

	if next_battler is PartyBattler:
		state_machine.transition_to("PlayerTurn")
	elif next_battler is EnemyBattler:
		state_machine.transition_to("EnemyTurn")

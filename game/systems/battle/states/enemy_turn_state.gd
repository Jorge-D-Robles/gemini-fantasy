extends State

## AI chooses and executes an action for the current enemy battler.

const UITheme = preload("res://ui/ui_theme.gd")
const BAX = preload("res://systems/battle/battle_action_executor.gd")
const ENEMY_TURN_DELAY: float = 0.4

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")

	var enemy := battle_scene.current_battler as EnemyBattler
	if not enemy or not enemy.is_alive:
		state_machine.transition_to("TurnQueueState")
		return

	var party: Array[Battler] = []
	party.assign(battle_scene.party_battlers)
	var allies: Array[Battler] = []
	allies.assign(battle_scene.enemy_battlers)
	var action := enemy.choose_action(party, allies)

	match action.type:
		BattleAction.Type.ATTACK:
			await _handle_attack_action(action, enemy)
		BattleAction.Type.ABILITY:
			await _handle_ability_action(action, enemy)
		BattleAction.Type.DEFEND:
			_handle_defend_action(enemy)
		BattleAction.Type.WAIT:
			_handle_wait_action(enemy)

	battle_scene.refresh_battle_ui()
	await get_tree().create_timer(ENEMY_TURN_DELAY).timeout

	var result: int = battle_scene.check_battle_end()
	if result == 1:
		state_machine.transition_to("Victory")
	elif result == -1:
		state_machine.transition_to("Defeat")
	else:
		state_machine.transition_to("TurnEnd")


func _handle_attack_action(action: BattleAction, enemy: EnemyBattler) -> void:
	await BAX.execute_attack(enemy, action.target, battle_scene, _battle_ui)


func _handle_ability_action(action: BattleAction, enemy: EnemyBattler) -> void:
	if not action.ability or not action.target:
		return
	enemy.use_ee(action.ability.ee_cost)
	await BAX.execute_ability(
		enemy, action.ability, action.target, battle_scene, _battle_ui,
	)


func _handle_defend_action(enemy: EnemyBattler) -> void:
	enemy.defend()
	if _battle_ui:
		_battle_ui.add_battle_log(
			"%s defends." % enemy.get_display_name(), UITheme.LogType.INFO,
		)


func _handle_wait_action(enemy: EnemyBattler) -> void:
	if _battle_ui:
		_battle_ui.add_battle_log(
			"%s waits." % enemy.get_display_name(), UITheme.LogType.INFO,
		)

extends State

## AI chooses and executes an action for the current enemy battler.

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

	var party_battlers: Array[Battler] = []
	for b in battle_scene.party_battlers:
		party_battlers.append(b)

	var enemy_battlers: Array[Battler] = []
	for b in battle_scene.enemy_battlers:
		enemy_battlers.append(b)

	var action := enemy.choose_action(party_battlers, enemy_battlers)

	match action.type:
		BattleAction.Type.ATTACK:
			if action.target and action.target.is_alive:
				var damage := enemy.deal_damage(enemy.attack)
				var actual := action.target.take_damage(damage)
				if _battle_ui:
					_battle_ui.add_battle_log(
						"%s attacks %s for %d damage!" % [
							enemy.get_display_name(),
							action.target.get_display_name(),
							actual,
						]
					)
		BattleAction.Type.ABILITY:
			if action.ability and action.target:
				enemy.use_ee(action.ability.ee_cost)
				var is_magical := (
					action.ability.damage_stat
					== AbilityData.DamageStat.MAGIC
				)
				var base := action.ability.damage_base
				if base > 0 and action.target.is_alive:
					var damage := enemy.deal_damage(base, is_magical)
					var actual := action.target.take_damage(
						damage, is_magical
					)
					if _battle_ui:
						_battle_ui.add_battle_log(
							"%s uses %s on %s for %d damage!" % [
								enemy.get_display_name(),
								action.ability.display_name,
								action.target.get_display_name(),
								actual,
							]
						)
		BattleAction.Type.DEFEND:
			enemy.defend()
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s defends." % enemy.get_display_name()
				)
		BattleAction.Type.WAIT:
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s waits." % enemy.get_display_name()
				)

	# Brief delay for visual feedback
	await get_tree().create_timer(0.4).timeout

	# Check battle end
	var result: int = battle_scene.check_battle_end()
	if result == 1:
		state_machine.transition_to("Victory")
	elif result == -1:
		state_machine.transition_to("Defeat")
	else:
		state_machine.transition_to("TurnEnd")

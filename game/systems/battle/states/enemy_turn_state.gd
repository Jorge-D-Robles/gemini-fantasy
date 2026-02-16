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

	match action.get("type", "wait"):
		"attack":
			var target: Battler = action.get("target", null)
			if target and target.is_alive:
				var damage := enemy.deal_damage(enemy.attack)
				var actual := target.take_damage(damage)
				if _battle_ui:
					_battle_ui.add_battle_log(
						"%s attacks %s for %d damage!" % [
							enemy.get_display_name(),
							target.get_display_name(),
							actual,
						]
					)
		"ability":
			var target: Battler = action.get("target", null)
			var ability: Resource = action.get("ability", null)
			if ability and target:
				var ee_cost: int = ability.ee_cost if "ee_cost" in ability else 0
				enemy.use_ee(ee_cost)
				var is_magical: bool = true
				if "damage_stat" in ability:
					is_magical = ability.damage_stat == 1
				var base: int = ability.damage_base if "damage_base" in ability else 0
				if base > 0 and target.is_alive:
					var damage := enemy.deal_damage(base, is_magical)
					var actual := target.take_damage(damage, is_magical)
					if _battle_ui:
						_battle_ui.add_battle_log(
							"%s uses %s on %s for %d damage!" % [
								enemy.get_display_name(),
								ability.display_name,
								target.get_display_name(),
								actual,
							]
						)
		"defend":
			enemy.defend()
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s defends." % enemy.get_display_name()
				)
		"wait":
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s waits." % enemy.get_display_name()
				)

	# Brief delay for visual feedback
	await get_tree().create_timer(0.4).timeout

	# Check battle end
	var result := battle_scene.check_battle_end()
	if result == 1:
		state_machine.transition_to("Victory")
	elif result == -1:
		state_machine.transition_to("Defeat")
	else:
		state_machine.transition_to("TurnEnd")

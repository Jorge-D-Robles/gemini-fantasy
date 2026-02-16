extends State

## Executes the chosen action (attack, ability, item) and checks battle end.

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	var battler: Battler = battle_scene.current_battler
	var command: String = battle_scene.get_meta("pending_command", "attack")
	var target: Battler = battle_scene.get_meta("pending_target", null)

	match command:
		"attack":
			_execute_attack(battler, target)
		"skill":
			var ability := battle_scene.get_meta("pending_ability", null) as AbilityData
			_execute_ability(battler, target, ability)
		"item":
			var item := battle_scene.get_meta("pending_item", null) as ItemData
			_execute_item(battler, target, item)

	# Clear pending meta
	if battle_scene.has_meta("pending_command"):
		battle_scene.remove_meta("pending_command")
	if battle_scene.has_meta("pending_target"):
		battle_scene.remove_meta("pending_target")
	if battle_scene.has_meta("pending_ability"):
		battle_scene.remove_meta("pending_ability")
	if battle_scene.has_meta("pending_item"):
		battle_scene.remove_meta("pending_item")

	# Brief delay for visual feedback
	await get_tree().create_timer(0.3).timeout

	# Check battle end
	var result: int = battle_scene.check_battle_end()
	if result == 1:
		state_machine.transition_to("Victory")
	elif result == -1:
		state_machine.transition_to("Defeat")
	else:
		state_machine.transition_to("TurnEnd")


func _execute_attack(attacker: Battler, target: Battler) -> void:
	if not target or not target.is_alive:
		return
	var damage := attacker.deal_damage(attacker.attack)
	var actual := target.take_damage(damage)
	if _battle_ui:
		_battle_ui.add_battle_log(
			"%s attacks %s for %d damage!" % [
				attacker.get_display_name(),
				target.get_display_name(),
				actual,
			]
		)


func _execute_ability(
	attacker: Battler,
	target: Battler,
	ability: AbilityData,
) -> void:
	if not ability:
		_execute_attack(attacker, target)
		return

	if not attacker.use_ee(ability.ee_cost):
		if _battle_ui:
			_battle_ui.add_battle_log("Not enough EE!")
		return

	var is_magical := ability.damage_stat == AbilityData.DamageStat.MAGIC

	if ability.damage_base > 0 and target and target.is_alive:
		var damage := attacker.deal_damage(ability.damage_base, is_magical)
		var actual := target.take_damage(damage, is_magical)
		if _battle_ui:
			_battle_ui.add_battle_log(
				"%s uses %s on %s for %d damage!" % [
					attacker.get_display_name(),
					ability.display_name,
					target.get_display_name(),
					actual,
				]
			)
	else:
		if _battle_ui:
			_battle_ui.add_battle_log(
				"%s uses %s!" % [
					attacker.get_display_name(),
					ability.display_name,
				]
			)


func _execute_item(
	_attacker: Battler,
	target: Battler,
	item: ItemData,
) -> void:
	if not item or not target:
		return
	match item.effect_type:
		ItemData.EffectType.HEAL_HP:
			var healed := target.heal(item.effect_value)
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s healed for %d HP!" % [
						target.get_display_name(),
						healed,
					]
				)
		ItemData.EffectType.HEAL_EE:
			var restored := target.restore_ee(item.effect_value)
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s restored %d EE!" % [
						target.get_display_name(),
						restored,
					]
				)

extends State

## Executes the chosen action (attack, ability, item) and checks battle end.

const UITheme = preload("res://ui/ui_theme.gd")

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	var battler: Battler = battle_scene.current_battler
	var action: BattleAction = battle_scene.current_action

	if not action:
		state_machine.transition_to("TurnEnd")
		return

	var success := true
	match action.type:
		BattleAction.Type.ATTACK:
			await _execute_attack(battler, action.target)
		BattleAction.Type.ABILITY:
			success = await _execute_ability(
				battler, action.target, action.ability
			)
		BattleAction.Type.ITEM:
			await _execute_item(battler, action.target, action.item)

	battle_scene.current_action = null

	if not success:
		# Action failed (e.g. not enough EE) — return to command menu
		state_machine.transition_to("PlayerTurn")
		return

	# Sync UI after every action so HP/EE/resonance are always current
	battle_scene.refresh_battle_ui()

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

	# Play attacker's attack animation
	await _play_attacker_anim(attacker)

	var damage := attacker.deal_damage(attacker.attack)
	var actual := target.take_damage(damage)
	if _battle_ui:
		_battle_ui.add_battle_log(
			"%s attacks %s for %d damage!" % [
				attacker.get_display_name(),
				target.get_display_name(),
				actual,
			],
			UITheme.LogType.DAMAGE,
		)


func _execute_ability(
	attacker: Battler,
	target: Battler,
	ability: AbilityData,
) -> bool:
	if not ability:
		push_warning("ActionExecute: ability is null — falling back to attack.")
		await _execute_attack(attacker, target)
		return true

	if not attacker.use_ee(ability.ee_cost):
		if _battle_ui:
			_battle_ui.add_battle_log(
				"Not enough EE!", UITheme.LogType.SYSTEM,
			)
		return false

	var is_magical := ability.damage_stat == AbilityData.DamageStat.MAGIC

	# Play attacker's attack animation
	await _play_attacker_anim(attacker)

	if ability.damage_base > 0 and target and target.is_alive:
		var damage := attacker.deal_damage(
			ability.damage_base, is_magical, true
		)
		var actual := target.take_damage(damage, is_magical)
		if _battle_ui:
			_battle_ui.add_battle_log(
				"%s uses %s on %s for %d damage!" % [
					attacker.get_display_name(),
					ability.display_name,
					target.get_display_name(),
					actual,
				],
				UITheme.LogType.DAMAGE,
			)
	else:
		if _battle_ui:
			_battle_ui.add_battle_log(
				"%s uses %s!" % [
					attacker.get_display_name(),
					ability.display_name,
				],
				UITheme.LogType.STATUS,
			)

	# Apply status effect with probability check
	_try_apply_status(ability, target)
	return true


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
			_show_heal_number(target, healed)
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s healed for %d HP!" % [
						target.get_display_name(),
						healed,
					],
					UITheme.LogType.HEAL,
				)
		ItemData.EffectType.HEAL_EE:
			var restored := target.restore_ee(item.effect_value)
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s restored %d EE!" % [
						target.get_display_name(),
						restored,
					],
					UITheme.LogType.HEAL,
				)
		ItemData.EffectType.CURE_HOLLOW:
			target.cure_hollow()
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s is grounded!" % [
						target.get_display_name(),
					],
					UITheme.LogType.STATUS,
				)


func _play_attacker_anim(attacker: Battler) -> void:
	var visual: Node2D = battle_scene.get_visual_scene(attacker)
	if visual and visual.has_method("play_attack_anim"):
		await visual.play_attack_anim()


func _try_apply_status(ability: AbilityData, target: Battler) -> void:
	if not ability or not target or not target.is_alive:
		return
	if ability.status_effect.is_empty() or ability.status_chance <= 0.0:
		return
	if randf() < ability.status_chance:
		var effect := StatusEffectData.new()
		effect.id = StringName(ability.status_effect)
		effect.display_name = ability.status_effect
		effect.duration = ability.status_effect_duration
		target.apply_status(effect)
		if _battle_ui:
			_battle_ui.add_battle_log(
				"%s is affected by %s!" % [
					target.get_display_name(),
					ability.status_effect,
				],
				UITheme.LogType.STATUS,
			)


func _show_heal_number(target: Battler, amount: int) -> void:
	var visual: Node2D = battle_scene.get_visual_scene(target)
	if visual and visual.has_method("show_heal_number"):
		visual.show_heal_number(amount)
	elif visual and visual.has_method("play_heal_anim"):
		visual.play_heal_anim()

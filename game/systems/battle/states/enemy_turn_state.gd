extends State

## AI chooses and executes an action for the current enemy battler.

const UITheme = preload("res://ui/ui_theme.gd")
const BattlerDamage = preload("res://systems/battle/battler_damage.gd")
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

	var action := enemy.choose_action(
		battle_scene.party_battlers, battle_scene.enemy_battlers,
	)

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
	if not action.target or not action.target.is_alive:
		return
	await _play_attacker_anim(enemy)
	var is_crit := BattlerDamage.roll_crit(enemy.luck)
	var damage := enemy.deal_damage(enemy.attack)
	if is_crit:
		damage = BattlerDamage.apply_crit(damage)
	var actual := action.target.take_damage(damage)
	if is_crit:
		AudioManager.play_sfx(
			load(SfxLibrary.COMBAT_CRITICAL_HIT),
			AudioManager.SfxPriority.CRITICAL,
		)
		_show_critical_popup(action.target, actual)
		if _battle_ui:
			_battle_ui.add_battle_log(
				"CRITICAL HIT! %s attacks %s for %d damage!" % [
					enemy.get_display_name(),
					action.target.get_display_name(),
					actual,
				],
				UITheme.LogType.DAMAGE,
			)
	else:
		AudioManager.play_sfx(load(SfxLibrary.COMBAT_ATTACK_HIT))
		if _battle_ui:
			_battle_ui.add_battle_log(
				"%s attacks %s for %d damage!" % [
					enemy.get_display_name(),
					action.target.get_display_name(),
					actual,
				],
				UITheme.LogType.DAMAGE,
			)
	if not action.target.is_alive:
		AudioManager.play_sfx(
			load(SfxLibrary.COMBAT_DEATH), AudioManager.SfxPriority.CRITICAL,
		)


func _handle_ability_action(action: BattleAction, enemy: EnemyBattler) -> void:
	if not action.ability or not action.target:
		return
	enemy.use_ee(action.ability.ee_cost)
	await _play_attacker_anim(enemy)
	var is_magical := action.ability.damage_stat == AbilityData.DamageStat.MAGIC
	var base := action.ability.damage_base
	AudioManager.play_sfx(load(SfxLibrary.COMBAT_MAGIC_CAST))
	if base > 0 and action.target.is_alive:
		var damage := enemy.deal_damage(base, is_magical)
		var actual := action.target.take_damage(damage, is_magical)
		if not action.target.is_alive:
			AudioManager.play_sfx(
				load(SfxLibrary.COMBAT_DEATH), AudioManager.SfxPriority.CRITICAL,
			)
		if _battle_ui:
			_battle_ui.add_battle_log(
				"%s uses %s on %s for %d damage!" % [
					enemy.get_display_name(),
					action.ability.display_name,
					action.target.get_display_name(),
					actual,
				],
				UITheme.LogType.DAMAGE,
			)
	_try_apply_status(action.ability, action.target)


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


func _play_attacker_anim(attacker: Battler) -> void:
	var visual: Node2D = battle_scene.get_visual_scene(attacker)
	if visual and visual.has_method("play_attack_anim"):
		await visual.play_attack_anim()


func _show_critical_popup(target: Battler, amount: int) -> void:
	var visual: Node2D = battle_scene.get_visual_scene(target)
	if not visual:
		return
	var popup := DamagePopup.new()
	visual.add_child(popup)
	popup.setup(amount, DamagePopup.PopupType.CRITICAL)


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
		AudioManager.play_sfx(load(SfxLibrary.COMBAT_STATUS_APPLY))
		if _battle_ui:
			_battle_ui.add_battle_log(
				"%s is affected by %s!" % [
					target.get_display_name(),
					ability.status_effect,
				],
				UITheme.LogType.STATUS,
			)

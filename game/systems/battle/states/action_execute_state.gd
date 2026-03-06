extends State

## Executes the chosen action (attack, ability, item) and checks battle end.

const UITheme = preload("res://ui/ui_theme.gd")
const BAX = preload("res://systems/battle/battle_action_executor.gd")
const GB = preload("res://systems/game_balance.gd")

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
			if BAX.is_aoe(action.ability):
				success = await _execute_aoe_ability(
					battler, action.ability,
				)
			elif action.ability.target_type == AbilityData.TargetType.SELF:
				success = await _execute_ability(
					battler, battler, action.ability,
				)
			else:
				success = await _execute_ability(
					battler, action.target, action.ability,
				)
		BattleAction.Type.ITEM:
			await _execute_item(battler, action.target, action.item)
		BattleAction.Type.ECHO:
			success = await _execute_echo(battler, action.echo, action.target)
		BattleAction.Type.GROUND:
			success = _execute_ground(battler, action.target)

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
	await BAX.execute_attack(attacker, target, battle_scene, _battle_ui)


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

	await BAX.execute_ability(attacker, ability, target, battle_scene, _battle_ui)
	return true


func _execute_aoe_ability(
	attacker: Battler,
	ability: AbilityData,
) -> bool:
	if not ability:
		return false

	if not attacker.use_ee(ability.ee_cost):
		if _battle_ui:
			_battle_ui.add_battle_log(
				"Not enough EE!", UITheme.LogType.SYSTEM,
			)
		return false

	var targets: Array[Battler] = []
	match ability.target_type:
		AbilityData.TargetType.ALL_ENEMIES:
			targets = battle_scene.get_living_enemies()
		AbilityData.TargetType.ALL_ALLIES:
			targets = battle_scene.get_living_party()

	for target: Battler in targets:
		await BAX.execute_ability(
			attacker, ability, target, battle_scene, _battle_ui,
		)
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
			AudioManager.play_sfx(load(SfxLibrary.COMBAT_HEAL_CHIME))
			_play_heal_vfx(target)
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
			AudioManager.play_sfx(load(SfxLibrary.COMBAT_HEAL_CHIME))
			_play_heal_vfx(target)
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
			AudioManager.play_sfx(load(SfxLibrary.COMBAT_HEAL_CHIME))
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s is grounded!" % [
						target.get_display_name(),
					],
					UITheme.LogType.STATUS,
				)


func _play_heal_vfx(target: Battler) -> void:
	var visual: Node2D = battle_scene.get_visual_scene(target)
	if not visual:
		return
	var vfx := BattleVFX.new()
	visual.add_child(vfx)
	vfx.setup_heal()


func _show_heal_number(target: Battler, amount: int) -> void:
	var visual: Node2D = battle_scene.get_visual_scene(target)
	if visual and visual.has_method("show_heal_number"):
		visual.show_heal_number(amount)
	elif visual and visual.has_method("play_heal_anim"):
		visual.play_heal_anim()


func _execute_echo(
	user: Battler,
	echo: EchoData,
	single_target: Battler,
) -> bool:
	if not echo:
		return false

	# Consume a use via EchoManager
	var echo_mgr: Node = battle_scene.get_node_or_null("/root/EchoManager")
	if echo_mgr and echo_mgr.has_method("consume_use"):
		if not echo_mgr.consume_use(echo.id):
			if _battle_ui:
				_battle_ui.add_battle_log(
					"No uses remaining!", UITheme.LogType.SYSTEM,
				)
			return false

	# Determine targets
	var targets: Array[Battler] = []
	match echo.target_type:
		EchoData.TargetType.ALL_ENEMIES:
			targets = battle_scene.get_living_enemies()
		EchoData.TargetType.ALL_ALLIES:
			targets = battle_scene.get_living_party()
		EchoData.TargetType.SELF:
			targets = [user]
		_:
			if single_target:
				targets = [single_target]

	for target: Battler in targets:
		await _apply_echo_effect(user, echo, target)
	return true


func _apply_echo_effect(
	user: Battler,
	echo: EchoData,
	target: Battler,
) -> void:
	if not target or not target.is_alive:
		return

	match echo.effect_type:
		EchoData.EffectType.DAMAGE:
			var damage := maxi(echo.effect_value, 1)
			var actual := target.take_damage(damage)
			AudioManager.play_sfx(load(SfxLibrary.COMBAT_MAGIC_CAST))
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s invokes %s on %s for %d damage!" % [
						user.get_display_name(),
						echo.display_name,
						target.get_display_name(),
						actual,
					],
					UITheme.LogType.DAMAGE,
				)
		EchoData.EffectType.HEAL:
			var healed := target.heal(echo.effect_value)
			AudioManager.play_sfx(load(SfxLibrary.COMBAT_HEAL_CHIME))
			_play_heal_vfx(target)
			_show_heal_number(target, healed)
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s invokes %s — %s healed for %d HP!" % [
						user.get_display_name(),
						echo.display_name,
						target.get_display_name(),
						healed,
					],
					UITheme.LogType.HEAL,
				)
		EchoData.EffectType.BUFF:
			var effect := StatusEffectData.new()
			effect.id = echo.id
			effect.display_name = echo.display_name
			effect.effect_type = StatusEffectData.EffectType.BUFF
			effect.duration = 3
			effect.attack_modifier = echo.effect_value
			target.apply_status(effect)
			AudioManager.play_sfx(load(SfxLibrary.COMBAT_STATUS_APPLY))
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s invokes %s — %s is buffed!" % [
						user.get_display_name(),
						echo.display_name,
						target.get_display_name(),
					],
					UITheme.LogType.STATUS,
				)
		EchoData.EffectType.DEBUFF:
			var effect := StatusEffectData.new()
			effect.id = echo.id
			effect.display_name = echo.display_name
			effect.effect_type = StatusEffectData.EffectType.DEBUFF
			effect.duration = 3
			effect.defense_modifier = -echo.effect_value
			target.apply_status(effect)
			AudioManager.play_sfx(load(SfxLibrary.COMBAT_STATUS_APPLY))
			if _battle_ui:
				_battle_ui.add_battle_log(
					"%s invokes %s — %s is weakened!" % [
						user.get_display_name(),
						echo.display_name,
						target.get_display_name(),
					],
					UITheme.LogType.STATUS,
				)


func _execute_ground(user: Battler, target: Battler) -> bool:
	if not target or not target.is_alive:
		return false
	if target.resonance_state != Battler.ResonanceState.HOLLOW:
		if _battle_ui:
			_battle_ui.add_battle_log(
				"%s is not Hollow!" % target.get_display_name(),
				UITheme.LogType.SYSTEM,
			)
		return false

	# Cost: 25% of user's resonance gauge
	var cost: float = GB.GROUND_RESONANCE_COST
	user.resonance_gauge = maxf(user.resonance_gauge - cost, 0.0)

	# Cure Hollow
	target.cure_hollow()

	# Restore 25% HP
	var heal_amount: int = int(target.max_hp * GB.GROUND_HEAL_PERCENT)
	target.heal(heal_amount)

	AudioManager.play_sfx(load(SfxLibrary.COMBAT_HEAL_CHIME))
	_play_heal_vfx(target)
	_show_heal_number(target, heal_amount)

	if _battle_ui:
		_battle_ui.add_battle_log(
			"%s grounds %s! Hollow cured, %d HP restored." % [
				user.get_display_name(),
				target.get_display_name(),
				heal_amount,
			],
			UITheme.LogType.HEAL,
		)
	return true

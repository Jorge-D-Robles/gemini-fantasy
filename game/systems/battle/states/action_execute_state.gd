extends State

## Executes the chosen action (attack, ability, item) and checks battle end.

const UITheme = preload("res://ui/ui_theme.gd")
const BAX = preload("res://systems/battle/battle_action_executor.gd")

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



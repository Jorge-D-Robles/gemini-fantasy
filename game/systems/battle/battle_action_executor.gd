class_name BattleActionExecutor
extends RefCounted

## Shared static helpers for attack and ability execution.
## Called by both ActionExecuteState (player) and EnemyTurnState (enemy).

const UITheme = preload("res://ui/ui_theme.gd")
const BP = preload("res://systems/battle/battle_particles.gd")
const BattlerDamageClass = preload("res://systems/battle/battler_damage.gd")


## Execute a physical attack from [param attacker] against [param target].
## Handles crit roll, damage, audio, UI log, and visual feedback.
static func execute_attack(
	attacker: Battler,
	target: Battler,
	scene: Node,
	battle_ui: Node,
) -> void:
	if not target or not target.is_alive:
		return

	await _play_attacker_anim(attacker, scene)
	_play_vfx(target, AbilityData.Element.NONE, scene)

	var is_crit := BattlerDamageClass.roll_crit(attacker.luck)
	var damage := attacker.deal_damage(attacker.attack)
	if is_crit:
		damage = BattlerDamageClass.apply_crit(damage)
	var actual := target.take_damage(damage)
	_maybe_shake(target, actual, scene)

	if is_crit:
		AudioManager.play_sfx(
			load(SfxLibrary.COMBAT_CRITICAL_HIT),
			AudioManager.SfxPriority.CRITICAL,
		)
		if not target.is_alive:
			AudioManager.play_sfx(
				load(SfxLibrary.COMBAT_DEATH),
				AudioManager.SfxPriority.CRITICAL,
			)
		_show_critical_popup(target, actual, scene)
		_flash_crit(scene)
		if battle_ui:
			battle_ui.add_battle_log(
				"CRITICAL HIT! %s attacks %s for %d damage!" % [
					attacker.get_display_name(),
					target.get_display_name(),
					actual,
				],
				UITheme.LogType.DAMAGE,
			)
	else:
		AudioManager.play_sfx(load(SfxLibrary.COMBAT_ATTACK_HIT))
		if not target.is_alive:
			AudioManager.play_sfx(
				load(SfxLibrary.COMBAT_DEATH),
				AudioManager.SfxPriority.CRITICAL,
			)
		if battle_ui:
			battle_ui.add_battle_log(
				"%s attacks %s for %d damage!" % [
					attacker.get_display_name(),
					target.get_display_name(),
					actual,
				],
				UITheme.LogType.DAMAGE,
			)


## Execute an ability from [param attacker] against [param target].
## Caller is responsible for spending EE before calling this.
static func execute_ability(
	attacker: Battler,
	ability: AbilityData,
	target: Battler,
	scene: Node,
	battle_ui: Node,
) -> void:
	if not ability:
		return

	var is_magical := ability.damage_stat == AbilityData.DamageStat.MAGIC

	await _play_attacker_anim(attacker, scene)

	if target and target.is_alive:
		_play_vfx(target, ability.element, scene)

	if ability.damage_base > 0 and target and target.is_alive:
		var damage := attacker.deal_damage(ability.damage_base, is_magical, true)
		var actual := target.take_damage(damage, is_magical)
		_maybe_shake(target, actual, scene)
		AudioManager.play_sfx(load(SfxLibrary.COMBAT_MAGIC_CAST))
		if not target.is_alive:
			AudioManager.play_sfx(
				load(SfxLibrary.COMBAT_DEATH),
				AudioManager.SfxPriority.CRITICAL,
			)
		if battle_ui:
			battle_ui.add_battle_log(
				"%s uses %s on %s for %d damage!" % [
					attacker.get_display_name(),
					ability.display_name,
					target.get_display_name(),
					actual,
				],
				UITheme.LogType.DAMAGE,
			)
	else:
		AudioManager.play_sfx(load(SfxLibrary.COMBAT_MAGIC_CAST))
		if battle_ui:
			battle_ui.add_battle_log(
				"%s uses %s!" % [
					attacker.get_display_name(),
					ability.display_name,
				],
				UITheme.LogType.STATUS,
			)

	try_apply_status(ability, target, battle_ui)


## Apply a status effect from [param ability] to [param target] if the chance roll succeeds.
static func try_apply_status(
	ability: AbilityData,
	target: Battler,
	battle_ui: Node,
) -> void:
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
		if battle_ui:
			battle_ui.add_battle_log(
				"%s is affected by %s!" % [
					target.get_display_name(),
					ability.status_effect,
				],
				UITheme.LogType.STATUS,
			)


static func _play_attacker_anim(attacker: Battler, scene: Node) -> void:
	var visual: Node2D = scene.get_visual_scene(attacker)
	if visual and visual.has_method("play_attack_anim"):
		await visual.play_attack_anim()


static func _play_vfx(
	target: Battler,
	element: AbilityData.Element,
	scene: Node,
) -> void:
	var visual: Node2D = scene.get_visual_scene(target)
	if not visual:
		return
	var vfx := BattleVFX.new()
	visual.add_child(vfx)
	vfx.setup(element)


static func _maybe_shake(target: Battler, actual: int, scene: Node) -> void:
	if not BattleShake.is_heavy_hit(actual, target.max_hp):
		return
	var intensity := BattleShake.compute_intensity(actual, target.max_hp)
	BattleShake.shake(scene as Node2D, intensity, BattleShake.SHAKE_DURATION)


static func _show_critical_popup(
	target: Battler,
	amount: int,
	scene: Node,
) -> void:
	var visual: Node2D = scene.get_visual_scene(target)
	if not visual:
		return
	var popup := DamagePopup.new()
	visual.add_child(popup)
	popup.setup(amount, DamagePopup.PopupType.CRITICAL)


static func _flash_crit(scene: Node) -> void:
	var scene_node := scene as Node2D
	if not scene_node:
		return
	var dur: float = BP.compute_crit_flash_duration()
	var color: Color = BP.compute_crit_flash_color()
	var tween := scene_node.create_tween()
	tween.tween_property(scene_node, "modulate", color, dur * 0.4)
	tween.tween_property(scene_node, "modulate", Color.WHITE, dur * 0.6)

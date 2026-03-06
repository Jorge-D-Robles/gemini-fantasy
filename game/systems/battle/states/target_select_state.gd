extends State

## Handles target selection for attacks and abilities.
## AoE and SELF abilities skip manual selection and go straight to execute.

const BAX = preload("res://systems/battle/battle_action_executor.gd")

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	if not _battle_ui:
		state_machine.transition_to("PlayerTurn")
		return

	# AoE and SELF abilities skip manual target selection
	var action: BattleAction = battle_scene.current_action
	if action and action.ability and BAX.is_auto_target(action.ability):
		state_machine.transition_to("ActionExecute")
		return

	# Echo auto-targeting for AoE/SELF echoes
	if action and action.echo:
		var tt: int = action.echo.target_type
		if (
			tt == EchoData.TargetType.ALL_ENEMIES
			or tt == EchoData.TargetType.ALL_ALLIES
			or tt == EchoData.TargetType.SELF
		):
			state_machine.transition_to("ActionExecute")
			return

	# Determine targets based on ability target_type
	var targets: Array[Battler] = _get_valid_targets()
	if targets.is_empty():
		state_machine.transition_to("PlayerTurn")
		return

	_battle_ui.show_target_selector(targets)

	if not _battle_ui.target_selected.is_connected(_on_target_selected):
		_battle_ui.target_selected.connect(_on_target_selected)
	if not _battle_ui.target_cancelled.is_connected(_on_cancelled):
		_battle_ui.target_cancelled.connect(_on_cancelled)


func exit() -> void:
	if _battle_ui:
		if _battle_ui.target_selected.is_connected(_on_target_selected):
			_battle_ui.target_selected.disconnect(_on_target_selected)
		if _battle_ui.target_cancelled.is_connected(_on_cancelled):
			_battle_ui.target_cancelled.disconnect(_on_cancelled)


func _on_target_selected(target: Battler) -> void:
	if battle_scene.current_action:
		battle_scene.current_action.target = target
	else:
		battle_scene.current_action = BattleAction.create_attack(target)
	state_machine.transition_to("ActionExecute")


func _on_cancelled() -> void:
	battle_scene.current_action = null
	state_machine.transition_to("PlayerTurn")


func _get_valid_targets() -> Array[Battler]:
	var action: BattleAction = battle_scene.current_action
	if not action:
		return battle_scene.get_living_enemies()
	var ally_targets := _get_ally_targets_for_action(action)
	if not ally_targets.is_empty():
		return ally_targets
	return battle_scene.get_living_enemies()


func _get_ally_targets_for_action(
	action: BattleAction,
) -> Array[Battler]:
	if action.type == BattleAction.Type.GROUND:
		return _hollow_party_members()
	var tt: int = -1
	if action.ability:
		tt = action.ability.target_type
	elif action.echo:
		tt = action.echo.target_type
	elif action.item:
		tt = action.item.target_type
	if tt == AbilityData.TargetType.SINGLE_ALLY or tt == AbilityData.TargetType.ALL_ALLIES:
		return battle_scene.get_living_party()
	if tt == AbilityData.TargetType.SELF:
		return _self_target_list()
	var empty: Array[Battler] = []
	return empty


func _self_target_list() -> Array[Battler]:
	var result: Array[Battler] = []
	if battle_scene.current_battler and battle_scene.current_battler.is_alive:
		result.append(battle_scene.current_battler)
	return result


func _hollow_party_members() -> Array[Battler]:
	var result: Array[Battler] = []
	for member: Battler in battle_scene.get_living_party():
		if member.resonance_state == Battler.ResonanceState.HOLLOW:
			result.append(member)
	return result

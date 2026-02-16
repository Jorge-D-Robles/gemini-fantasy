extends State

## Handles target selection for attacks and abilities.

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	if not _battle_ui:
		state_machine.transition_to("PlayerTurn")
		return

	# Determine targets based on ability target_type
	var targets: Array[Battler] = _get_valid_targets()
	if targets.is_empty():
		state_machine.transition_to("TurnQueueState")
		return

	_battle_ui.show_target_selector(targets)

	if not _battle_ui.target_selected.is_connected(_on_target_selected):
		_battle_ui.target_selected.connect(_on_target_selected)


func exit() -> void:
	if _battle_ui and _battle_ui.target_selected.is_connected(_on_target_selected):
		_battle_ui.target_selected.disconnect(_on_target_selected)


func _on_target_selected(target: Battler) -> void:
	battle_scene.set_meta("pending_target", target)
	if not battle_scene.has_meta("pending_command"):
		battle_scene.set_meta("pending_command", "attack")
	state_machine.transition_to("ActionExecute")


func _get_valid_targets() -> Array[Battler]:
	var pending_ability: Resource = battle_scene.get_meta("pending_ability", null)
	if pending_ability:
		var ability := pending_ability as AbilityData
		if ability:
			match ability.target_type:
				AbilityData.TargetType.SINGLE_ALLY, AbilityData.TargetType.ALL_ALLIES:
					return battle_scene.get_living_party()
				AbilityData.TargetType.SELF:
					var self_list: Array[Battler] = []
					if battle_scene.current_battler and battle_scene.current_battler.is_alive:
						self_list.append(battle_scene.current_battler)
					return self_list
	return battle_scene.get_living_enemies()

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

	var targets := battle_scene.get_living_enemies()
	if targets.is_empty():
		state_machine.transition_to("TurnQueueState")
		return

	_battle_ui.show_target_selector(
		targets,
		_on_target_confirmed,
	)

	if not _battle_ui.target_selected.is_connected(_on_target_selected):
		_battle_ui.target_selected.connect(_on_target_selected)


func exit() -> void:
	if _battle_ui and _battle_ui.target_selected.is_connected(_on_target_selected):
		_battle_ui.target_selected.disconnect(_on_target_selected)


func _on_target_selected(target: Battler) -> void:
	_on_target_confirmed(target)


func _on_target_confirmed(target: Battler) -> void:
	battle_scene.set_meta("pending_target", target)
	if not battle_scene.has_meta("pending_command"):
		battle_scene.set_meta("pending_command", "attack")
	state_machine.transition_to("ActionExecute")

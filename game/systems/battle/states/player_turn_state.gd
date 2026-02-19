extends State

## Shows the command menu for the active party member.

const UITheme = preload("res://ui/ui_theme.gd")

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	if not _battle_ui:
		push_error("PlayerTurnState: BattleUI not found.")
		state_machine.transition_to("TurnEnd")
		return

	_battle_ui.show_command_menu(battle_scene.current_battler)
	_battle_ui.update_party_status(battle_scene.get_living_party())
	_battle_ui.update_resonance(
		battle_scene.current_battler.resonance_gauge,
		battle_scene.current_battler.resonance_state,
	)

	if not _battle_ui.command_selected.is_connected(_on_command_selected):
		_battle_ui.command_selected.connect(_on_command_selected)


func exit() -> void:
	if _battle_ui and _battle_ui.command_selected.is_connected(_on_command_selected):
		_battle_ui.command_selected.disconnect(_on_command_selected)


func _on_command_selected(command: String) -> void:
	match command:
		"attack":
			state_machine.transition_to("TargetSelect")
		"skill":
			battle_scene.pending_command = "skill"
			state_machine.transition_to("ActionSelect")
		"item":
			battle_scene.pending_command = "item"
			state_machine.transition_to("ActionSelect")
		"defend":
			battle_scene.current_battler.defend()
			_battle_ui.add_battle_log(
				"%s defends." % battle_scene.current_battler.get_display_name(),
				UITheme.LogType.INFO,
			)
			_battle_ui.hide_command_menu()
			state_machine.transition_to("TurnEnd")
		"flee":
			if battle_scene.can_escape:
				_battle_ui.add_battle_log(
					"The party fled!", UITheme.LogType.INFO,
				)
				_battle_ui.hide_command_menu()
				battle_scene.end_battle(false)
			else:
				_battle_ui.add_battle_log(
					"Can't escape!", UITheme.LogType.SYSTEM,
				)
				_battle_ui.show_command_menu(battle_scene.current_battler)

extends State

## Handles skill and item submenu selection.

var battle_scene: Node = null
var _battle_ui: Node = null
var _mode: String = ""


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	if not _battle_ui:
		state_machine.transition_to("PlayerTurn")
		return

	# Determine mode from previous state context
	var battler: Battler = battle_scene.current_battler
	if battler is PartyBattler:
		var party_battler := battler as PartyBattler
		# Default to skill submenu; item submenu can be extended later
		if not battler.abilities.is_empty():
			_mode = "skill"
			var available := party_battler.get_available_abilities()
			_battle_ui.show_skill_submenu(available)
			if not _battle_ui.skill_selected.is_connected(_on_skill_selected):
				_battle_ui.skill_selected.connect(_on_skill_selected)
		else:
			_battle_ui.add_battle_log("No skills available.")
			state_machine.transition_to("PlayerTurn")


func exit() -> void:
	if _battle_ui and _battle_ui.skill_selected.is_connected(_on_skill_selected):
		_battle_ui.skill_selected.disconnect(_on_skill_selected)
	if _battle_ui and _battle_ui.item_selected.is_connected(_on_item_selected):
		_battle_ui.item_selected.disconnect(_on_item_selected)


func _on_skill_selected(ability: Resource) -> void:
	battle_scene.set_meta("pending_ability", ability)
	battle_scene.set_meta("pending_command", "skill")
	state_machine.transition_to("TargetSelect")


func _on_item_selected(item: Resource) -> void:
	battle_scene.set_meta("pending_item", item)
	battle_scene.set_meta("pending_command", "item")
	state_machine.transition_to("TargetSelect")

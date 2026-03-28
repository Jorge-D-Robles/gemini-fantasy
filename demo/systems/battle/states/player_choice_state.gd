extends BattleState
## Waits for the player to choose an action from the battle menu.

var _active_battler: BattlerData
var _battle_menu: PanelContainer
var _target_select: PanelContainer


func enter(context: Dictionary = {}) -> void:
	_active_battler = context.get("battler")

	_battle_menu = get_tree().current_scene.get_node("BattleUI/BattleMenu")
	_target_select = get_tree().current_scene.get_node("BattleUI/TargetSelect")

	_battle_menu.action_chosen.connect(_on_action_chosen)
	_target_select.target_selected.connect(_on_target_selected)
	_target_select.cancelled.connect(_on_target_cancelled)

	_battle_menu.show_menu()


func exit() -> void:
	_battle_menu.hide_menu()
	_target_select.hide_targets()

	if _battle_menu.action_chosen.is_connected(_on_action_chosen):
		_battle_menu.action_chosen.disconnect(_on_action_chosen)
	if _target_select.target_selected.is_connected(_on_target_selected):
		_target_select.target_selected.disconnect(_on_target_selected)
	if _target_select.cancelled.is_connected(_on_target_cancelled):
		_target_select.cancelled.disconnect(_on_target_cancelled)


func _on_action_chosen(action: String) -> void:
	match action:
		"attack":
			_battle_menu.hide_menu()
			_target_select.show_targets(battle_manager.get_alive_enemies())
		"defend":
			battle_manager._state_machine.transition_to("ActionExecute", {
				battler = _active_battler,
				action = "defend",
			})
		"magic":
			print("Magic not yet available!")
			_battle_menu.show_menu()
		"item":
			var consumables := InventoryManager.get_consumables()
			if consumables.is_empty():
				print("No items!")
				_battle_menu.show_menu()
			else:
				var item: ItemData = consumables[0].item
				battle_manager._state_machine.transition_to("ActionExecute", {
					battler = _active_battler,
					action = "item",
					target = _active_battler,
					item = item,
				})
		"flee":
			if AIController.attempt_flee(battle_manager.party, battle_manager.enemies):
				print("Got away!")
				SceneManager.return_from_battle()
			else:
				print("Can't escape!")
				_battle_menu.show_menu()


func _on_target_selected(target: BattlerData) -> void:
	_target_select.hide_targets()
	battle_manager._state_machine.transition_to("ActionExecute", {
		battler = _active_battler,
		action = "attack",
		target = target,
	})


func _on_target_cancelled() -> void:
	_target_select.hide_targets()
	_battle_menu.show_menu()

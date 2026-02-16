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

	_mode = battle_scene.pending_command

	if _mode == "item":
		var usable: Array[ItemData] = InventoryManager.get_usable_items()
		if usable.is_empty():
			_battle_ui.add_battle_log("No items available!")
			state_machine.transition_to("PlayerTurn")
			return
		var items_as_resource: Array[Resource] = []
		for item in usable:
			items_as_resource.append(item)
		_battle_ui.show_item_submenu(items_as_resource)
		if not _battle_ui.item_selected.is_connected(_on_item_selected):
			_battle_ui.item_selected.connect(_on_item_selected)
		if not _battle_ui.submenu_cancelled.is_connected(_on_cancelled):
			_battle_ui.submenu_cancelled.connect(_on_cancelled)
	else:
		var battler: Battler = battle_scene.current_battler
		if battler is PartyBattler:
			var party_battler := battler as PartyBattler
			var available := party_battler.get_available_abilities()
			if available.is_empty():
				_battle_ui.add_battle_log("No skills available!")
				state_machine.transition_to("PlayerTurn")
				return
			_mode = "skill"
			_battle_ui.show_skill_submenu(available)
			if not _battle_ui.skill_selected.is_connected(_on_skill_selected):
				_battle_ui.skill_selected.connect(_on_skill_selected)
			if not _battle_ui.submenu_cancelled.is_connected(_on_cancelled):
				_battle_ui.submenu_cancelled.connect(_on_cancelled)
		else:
			state_machine.transition_to("PlayerTurn")


func exit() -> void:
	if _battle_ui:
		if _battle_ui.skill_selected.is_connected(_on_skill_selected):
			_battle_ui.skill_selected.disconnect(_on_skill_selected)
		if _battle_ui.item_selected.is_connected(_on_item_selected):
			_battle_ui.item_selected.disconnect(_on_item_selected)
		if _battle_ui.submenu_cancelled.is_connected(_on_cancelled):
			_battle_ui.submenu_cancelled.disconnect(_on_cancelled)


func _on_skill_selected(ability: Resource) -> void:
	var ability_data := ability as AbilityData
	battle_scene.current_action = BattleAction.create_ability(ability_data, null)
	state_machine.transition_to("TargetSelect")


func _on_item_selected(item: Resource) -> void:
	var item_data := item as ItemData
	InventoryManager.remove_item(item_data.id)
	battle_scene.current_action = BattleAction.create_item(item_data, null)
	state_machine.transition_to("TargetSelect")


func _on_cancelled() -> void:
	state_machine.transition_to("PlayerTurn")

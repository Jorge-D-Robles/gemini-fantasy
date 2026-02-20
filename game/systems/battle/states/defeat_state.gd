extends State

## Handles battle defeat: shows game over screen and awaits player action.
## Player chooses "Load Last Save" or "Return to Title" via defeat screen buttons.

const UITheme = preload("res://ui/ui_theme.gd")
const SP = preload("res://systems/scene_paths.gd")

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	var battle_ui: Node = battle_scene.get_node_or_null("BattleUI")
	if battle_ui:
		battle_ui.show_defeat()
		battle_ui.add_battle_log(
			"The party has been defeated...", UITheme.LogType.DEFEAT,
		)

	if battle_ui and battle_ui.has_signal("defeat_action_chosen"):
		var action: String = await battle_ui.defeat_action_chosen
		battle_scene.end_battle(false)
		if action == "load":
			# Apply save data to restore state before the fatal encounter.
			var data := SaveManager.load_save_data(0)
			if not data.is_empty():
				SaveManager.apply_save_data(
					data, PartyManager, InventoryManager, EventFlags,
					EquipmentManager, QuestManager,
				)
				var saved_scene: String = data.get("scene_path", SP.TITLE_SCREEN)
				GameManager.change_scene(saved_scene)
			else:
				GameManager.change_scene(SP.TITLE_SCREEN)
		else:
			GameManager.change_scene(SP.TITLE_SCREEN)
	else:
		# Fallback for scenes without the defeat signal (e.g., older tests).
		await get_tree().create_timer(2.0).timeout
		battle_scene.end_battle(false)

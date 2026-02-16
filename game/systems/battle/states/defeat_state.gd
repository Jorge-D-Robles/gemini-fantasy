extends State

## Handles battle defeat: shows game over screen.

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	var battle_ui: Node = battle_scene.get_node_or_null("BattleUI")
	if battle_ui:
		battle_ui.show_defeat()
		battle_ui.add_battle_log("The party has been defeated...")

	# End battle properly so BattleManager cleans up state
	await get_tree().create_timer(2.0).timeout
	battle_scene.end_battle(false)

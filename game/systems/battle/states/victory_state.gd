extends State

## Handles battle victory: calculates rewards, shows victory screen.

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	var total_exp: int = 0
	var total_gold: int = 0
	var items: Array[String] = []

	for b in battle_scene.enemy_battlers:
		if b is EnemyBattler:
			total_exp += b.exp_reward
			total_gold += b.gold_reward
			for loot_entry in b.loot_table:
				var chance: float = loot_entry.get("drop_chance", 0.0)
				if randf() < chance:
					items.append(loot_entry.get("item_id", "unknown"))

	var battle_ui: Node = battle_scene.get_node_or_null("BattleUI")
	if battle_ui:
		battle_ui.show_victory(total_exp, total_gold, items)
		battle_ui.add_battle_log(
			"Victory! Gained %d EXP and %d Gold." % [total_exp, total_gold]
		)

	# Wait for player to dismiss victory screen
	await get_tree().create_timer(2.0).timeout
	battle_scene.end_battle(true)

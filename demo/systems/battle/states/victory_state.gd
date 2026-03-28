extends BattleState
## Battle won. Calculate and display rewards.


func enter(_context: Dictionary = {}) -> void:
	print("--- VICTORY ---")

	# Check for final boss
	var is_boss_fight: bool = false
	for enemy in battle_manager.enemies:
		if enemy.enemy_data and enemy.enemy_data.id == "crystal_guardian":
			is_boss_fight = true
			break

	if is_boss_fight:
		GameManager.set_flag("boss_defeated")
		await get_tree().create_timer(2.0).timeout
		SceneManager.change_scene("res://ui/ending/ending.tscn")
		return

	var total_xp: int = 0
	var total_gold: int = 0
	var dropped_items: Array[ItemData] = []

	for enemy in battle_manager.enemies:
		if enemy.enemy_data:
			total_xp += enemy.enemy_data.xp_reward
			total_gold += enemy.enemy_data.gold_reward
			if enemy.enemy_data.drop_item and randf() < enemy.enemy_data.drop_chance:
				dropped_items.append(enemy.enemy_data.drop_item)

	var xp_per_member: int = total_xp / max(1, battle_manager.get_alive_party().size())
	for battler in battle_manager.get_alive_party():
		_apply_xp(battler, xp_per_member)

	for battler in battle_manager.party:
		if battler.character_data:
			battler.character_data.current_hp = battler.current_hp
			battler.character_data.current_mp = battler.current_mp

	InventoryManager.add_gold(total_gold)
	print("Gained " + str(total_gold) + " gold!")

	for item in dropped_items:
		InventoryManager.add_item(item)
		print("Found: " + item.display_name + "!")

	battle_manager.battle_won.emit()
	await get_tree().create_timer(2.0).timeout
	SceneManager.return_from_battle()


func _apply_xp(battler: BattlerData, xp: int) -> void:
	if not battler.character_data:
		return
	var char_data: CharacterData = battler.character_data
	char_data.current_xp += xp
	print(char_data.display_name + " gained " + str(xp) + " XP!")

	var required: int = CharacterData.xp_for_level(char_data.level)
	while char_data.current_xp >= required:
		char_data.current_xp -= required
		var gains: Dictionary = char_data.level_up()
		print(char_data.display_name + " reached level " + str(char_data.level) + "!")
		print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
			  ", DEF +" + str(gains.defense))
		required = CharacterData.xp_for_level(char_data.level)

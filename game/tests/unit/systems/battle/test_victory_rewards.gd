extends GutTest

## Tests for victory reward calculation and HP/EE persistence round-trip.

const TestHelpers := preload("res://tests/helpers/test_helpers.gd")
const PartyManagerScript := preload("res://autoloads/party_manager.gd")


func test_total_gold_from_multiple_enemies() -> void:
	var total_gold: int = 0
	for i in 3:
		var eb := TestHelpers.make_enemy_battler(
			{"gold_reward": 10 * (i + 1)}
		)
		add_child_autofree(eb)
		total_gold += eb.gold_reward
	assert_eq(total_gold, 60)


func test_total_exp_from_multiple_enemies() -> void:
	var total_exp: int = 0
	for i in 3:
		var eb := TestHelpers.make_enemy_battler(
			{"exp_reward": 15 * (i + 1)}
		)
		add_child_autofree(eb)
		total_exp += eb.exp_reward
	assert_eq(total_exp, 90)


func test_loot_table_guaranteed_drop() -> void:
	var eb := TestHelpers.make_enemy_battler({
		"loot_table": [
			{"item_id": "potion", "drop_chance": 1.0},
		],
	})
	add_child_autofree(eb)
	var items: Array[String] = []
	for entry in eb.loot_table:
		var chance: float = entry.get("drop_chance", 0.0)
		if randf() < chance:
			items.append(entry.get("item_id", "unknown"))
	assert_eq(items.size(), 1)
	assert_eq(items[0], "potion")


func test_loot_table_zero_chance_no_drop() -> void:
	var eb := TestHelpers.make_enemy_battler({
		"loot_table": [
			{"item_id": "rare_item", "drop_chance": 0.0},
		],
	})
	add_child_autofree(eb)
	var items: Array[String] = []
	for entry in eb.loot_table:
		var chance: float = entry.get("drop_chance", 0.0)
		if randf() < chance:
			items.append(entry.get("item_id", "unknown"))
	assert_eq(items.size(), 0)


func test_party_hp_ee_persistence_round_trip() -> void:
	# Simulate: add character -> take damage -> persist -> read back
	var pm: Node = PartyManagerScript.new()
	add_child_autofree(pm)
	var data := TestHelpers.make_battler_data({
		"id": &"test_hero",
		"max_hp": 100,
		"max_ee": 50,
	})
	pm.add_character(data)
	# Full HP/EE on start
	assert_eq(pm.get_hp(&"test_hero"), 100)
	assert_eq(pm.get_ee(&"test_hero"), 50)
	# Simulate damage in battle
	pm.set_hp(&"test_hero", 35)
	pm.set_ee(&"test_hero", 12)
	# Read back — should persist
	assert_eq(pm.get_hp(&"test_hero"), 35)
	assert_eq(pm.get_ee(&"test_hero"), 12)


func test_heal_all_after_battle_damage() -> void:
	var pm: Node = PartyManagerScript.new()
	add_child_autofree(pm)
	var d1 := TestHelpers.make_battler_data({
		"id": &"hero_a",
		"max_hp": 100,
		"max_ee": 50,
	})
	var d2 := TestHelpers.make_battler_data({
		"id": &"hero_b",
		"max_hp": 200,
		"max_ee": 80,
	})
	pm.add_character(d1)
	pm.add_character(d2)
	pm.set_hp(&"hero_a", 1)
	pm.set_ee(&"hero_a", 0)
	pm.set_hp(&"hero_b", 50)
	pm.set_ee(&"hero_b", 10)
	pm.heal_all()
	assert_eq(pm.get_hp(&"hero_a"), 100)
	assert_eq(pm.get_ee(&"hero_a"), 50)
	assert_eq(pm.get_hp(&"hero_b"), 200)
	assert_eq(pm.get_ee(&"hero_b"), 80)


func test_dead_character_persists_zero_hp() -> void:
	var pm: Node = PartyManagerScript.new()
	add_child_autofree(pm)
	var data := TestHelpers.make_battler_data({
		"id": &"fallen",
		"max_hp": 100,
		"max_ee": 50,
	})
	pm.add_character(data)
	pm.set_hp(&"fallen", 0)
	assert_eq(pm.get_hp(&"fallen"), 0)


func test_multiple_enemies_zero_gold() -> void:
	var total_gold: int = 0
	for i in 3:
		var eb := TestHelpers.make_enemy_battler({"gold_reward": 0})
		add_child_autofree(eb)
		total_gold += eb.gold_reward
	assert_eq(total_gold, 0)

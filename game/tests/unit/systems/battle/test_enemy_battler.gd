extends GutTest

## Tests for EnemyBattler — AI logic, action selection, data initialization.

const Helpers = preload("res://tests/helpers/test_helpers.gd")


# ---- Initialization ----

func test_initialize_loads_enemy_data() -> void:
	var b := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.AGGRESSIVE,
		"exp_reward": 50,
		"gold_reward": 25,
	})
	add_child_autofree(b)

	assert_eq(b.ai_type, EnemyData.AiType.AGGRESSIVE)
	assert_eq(b.exp_reward, 50)
	assert_eq(b.gold_reward, 25)


func test_initialize_loads_loot_table() -> void:
	var loot := [{"item_id": "potion", "drop_chance": 0.5}]
	var b := Helpers.make_enemy_battler({"loot_table": loot})
	add_child_autofree(b)

	assert_eq(b.loot_table.size(), 1)
	assert_eq(b.loot_table[0]["item_id"], "potion")


# ---- Basic AI ----

func test_basic_ai_attacks_living_target() -> void:
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.BASIC,
	})
	add_child_autofree(enemy)

	var target := Helpers.make_battler()
	add_child_autofree(target)

	var party: Array[Battler] = [target]
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(action.type, BattleAction.Type.ATTACK)
	assert_eq(action.target, target)


func test_basic_ai_waits_with_no_living_targets() -> void:
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.BASIC,
	})
	add_child_autofree(enemy)

	var dead_target := Helpers.make_battler()
	add_child_autofree(dead_target)
	dead_target.is_alive = false

	var party: Array[Battler] = [dead_target]
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(action.type, BattleAction.Type.WAIT)


func test_basic_ai_waits_with_empty_party() -> void:
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.BASIC,
	})
	add_child_autofree(enemy)

	var party: Array[Battler] = []
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(action.type, BattleAction.Type.WAIT)


# ---- Aggressive AI ----

func test_aggressive_ai_targets_lowest_hp() -> void:
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.AGGRESSIVE,
	})
	add_child_autofree(enemy)

	var healthy := Helpers.make_battler({"max_hp": 100})
	add_child_autofree(healthy)
	var injured := Helpers.make_battler({"max_hp": 100})
	add_child_autofree(injured)
	injured.current_hp = 20

	var party: Array[Battler] = [healthy, injured]
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(action.target, injured, "Aggressive AI should target lowest HP")


func test_aggressive_ai_uses_ability_when_available() -> void:
	var ability := Helpers.make_ability({"ee_cost": 5, "damage_base": 20})
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.AGGRESSIVE,
		"max_ee": 30,
		"abilities": [ability],
	})
	add_child_autofree(enemy)

	var target := Helpers.make_battler()
	add_child_autofree(target)

	var party: Array[Battler] = [target]
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(action.type, BattleAction.Type.ABILITY)
	assert_eq(action.ability, ability)


func test_aggressive_ai_falls_back_to_attack_no_ee() -> void:
	var ability := Helpers.make_ability({"ee_cost": 50})
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.AGGRESSIVE,
		"max_ee": 10,
		"abilities": [ability],
	})
	add_child_autofree(enemy)

	var target := Helpers.make_battler()
	add_child_autofree(target)

	var party: Array[Battler] = [target]
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(
		action.type, BattleAction.Type.ATTACK,
		"Should fall back to attack when ability is too expensive"
	)


# ---- Defensive AI ----

func test_defensive_ai_defends_when_low_hp() -> void:
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.DEFENSIVE,
		"max_hp": 100,
	})
	add_child_autofree(enemy)
	enemy.current_hp = 20  # 20% HP < 30% threshold

	var target := Helpers.make_battler()
	add_child_autofree(target)

	var party: Array[Battler] = [target]
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(action.type, BattleAction.Type.DEFEND)


func test_defensive_ai_attacks_when_healthy() -> void:
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.DEFENSIVE,
		"max_hp": 100,
	})
	add_child_autofree(enemy)
	# HP is at max (100%), well above 30% threshold

	var target := Helpers.make_battler()
	add_child_autofree(target)

	var party: Array[Battler] = [target]
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(action.type, BattleAction.Type.ATTACK)


# ---- Support AI ----

func test_support_ai_attacks_when_no_injured_allies() -> void:
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.SUPPORT,
	})
	add_child_autofree(enemy)

	var target := Helpers.make_battler()
	add_child_autofree(target)

	var ally := Helpers.make_enemy_battler({"max_hp": 100})
	add_child_autofree(ally)
	# Ally is at full HP — no healing needed

	var party: Array[Battler] = [target]
	var allies: Array[Battler] = [enemy, ally]
	var action := enemy.choose_action(party, allies)

	assert_eq(action.type, BattleAction.Type.ATTACK)


# ---- Signal emission ----

func test_choose_action_emits_ai_action_chosen() -> void:
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.BASIC,
	})
	add_child_autofree(enemy)

	var target := Helpers.make_battler()
	add_child_autofree(target)

	watch_signals(enemy)
	var party: Array[Battler] = [target]
	var allies: Array[Battler] = [enemy]
	enemy.choose_action(party, allies)

	assert_signal_emitted(enemy, "ai_action_chosen")


# ---- Ability resonance cost check ----

func test_can_use_ability_enemy_checks_resonance_cost() -> void:
	var ability := Helpers.make_ability({
		"ee_cost": 5,
		"resonance_cost": 50.0,
	})
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.AGGRESSIVE,
		"max_ee": 100,
		"abilities": [ability],
	})
	add_child_autofree(enemy)
	# Resonance is 0 — should not be able to use ability with resonance_cost

	var target := Helpers.make_battler()
	add_child_autofree(target)

	var party: Array[Battler] = [target]
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(
		action.type, BattleAction.Type.ATTACK,
		"Should fall back to attack when resonance insufficient"
	)


# ---- Boss AI (uses aggressive AI) ----

func test_boss_ai_targets_lowest_hp() -> void:
	var enemy := Helpers.make_enemy_battler({
		"ai_type": EnemyData.AiType.BOSS,
	})
	add_child_autofree(enemy)

	var healthy := Helpers.make_battler({"max_hp": 100})
	add_child_autofree(healthy)
	var injured := Helpers.make_battler({"max_hp": 100})
	add_child_autofree(injured)
	injured.current_hp = 10

	var party: Array[Battler] = [healthy, injured]
	var allies: Array[Battler] = [enemy]
	var action := enemy.choose_action(party, allies)

	assert_eq(action.target, injured, "Boss AI should target lowest HP")

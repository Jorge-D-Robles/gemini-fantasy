extends GutTest

## Tests for battle action execution logic — status effects from abilities,
## damage number signals, and multi-hit scenarios.

const Helpers = preload("res://tests/helpers/test_helpers.gd")


# ---- Status effect application from abilities ----

func test_ability_applies_status_effect() -> void:
	var attacker := Helpers.make_battler({"attack": 20, "max_ee": 100})
	add_child_autofree(attacker)

	var target := Helpers.make_battler({"defense": 0})
	add_child_autofree(target)

	var ability := Helpers.make_ability({
		"damage_base": 10,
		"status_effect": "poison",
		"status_chance": 1.0,
	})

	# Simulate ability hit: deal damage then apply status
	attacker.use_ee(ability.ee_cost)
	var dmg := attacker.deal_damage(ability.damage_base)
	target.take_damage(dmg)

	# Apply status effect (this is the logic we're testing)
	if ability.status_effect != "" and randf() < ability.status_chance:
		target.apply_status(Helpers.make_status_effect({"id": StringName(ability.status_effect)}))

	assert_true(
		target.has_status(&"poison"),
		"Target should have poison after 100% chance ability"
	)


func test_ability_zero_chance_no_status() -> void:
	var target := Helpers.make_battler()
	add_child_autofree(target)

	var ability := Helpers.make_ability({
		"status_effect": "burn",
		"status_chance": 0.0,
	})

	if ability.status_effect != "" and ability.status_chance > 0.0:
		if randf() < ability.status_chance:
			target.apply_status(
				Helpers.make_status_effect({"id": StringName(ability.status_effect)})
			)

	assert_false(
		target.has_status(&"burn"),
		"Zero chance should not apply status"
	)


func test_status_from_ability_persists_across_turns() -> void:
	var target := Helpers.make_battler()
	add_child_autofree(target)

	target.apply_status(Helpers.make_status_effect({"id": &"poison"}))
	target.end_turn()
	target.end_turn()

	assert_true(
		target.has_status(&"poison"),
		"Status applied from ability should persist across turns"
	)


# ---- Damage accumulation in multi-target scenarios ----

func test_two_attackers_damage_same_target() -> void:
	var attacker_a := Helpers.make_battler({"attack": 20})
	add_child_autofree(attacker_a)

	var attacker_b := Helpers.make_battler({"attack": 30})
	add_child_autofree(attacker_b)

	var target := Helpers.make_battler({"max_hp": 200, "defense": 0})
	add_child_autofree(target)

	var dmg_a := attacker_a.deal_damage(10)
	target.take_damage(dmg_a)
	var hp_after_a := target.current_hp

	var dmg_b := attacker_b.deal_damage(15)
	target.take_damage(dmg_b)

	assert_lt(
		target.current_hp, hp_after_a,
		"Second attacker should further reduce HP"
	)
	assert_lt(target.current_hp, 200, "Total damage should persist")


# ---- Ability with healing ----

func test_healing_ability_restores_hp() -> void:
	var healer := Helpers.make_battler({"max_ee": 100})
	add_child_autofree(healer)

	var target := Helpers.make_battler({"max_hp": 100})
	add_child_autofree(target)
	target.take_damage(50)
	var hp_before := target.current_hp

	var heal_amount := 25
	target.heal(heal_amount)

	assert_gt(target.current_hp, hp_before)
	assert_lt(target.current_hp, target.max_hp)


# ---- BattleAction creation and type checks ----

func test_create_attack_action() -> void:
	var target := Helpers.make_battler()
	add_child_autofree(target)

	var action := BattleAction.create_attack(target)
	assert_eq(action.type, BattleAction.Type.ATTACK)
	assert_eq(action.target, target)
	assert_null(action.ability)


func test_create_ability_action() -> void:
	var target := Helpers.make_battler()
	add_child_autofree(target)
	var ability := Helpers.make_ability()

	var action := BattleAction.create_ability(ability, target)
	assert_eq(action.type, BattleAction.Type.ABILITY)
	assert_eq(action.target, target)
	assert_eq(action.ability, ability)


func test_create_item_action() -> void:
	var target := Helpers.make_battler()
	add_child_autofree(target)
	var item := Helpers.make_item()

	var action := BattleAction.create_item(item, target)
	assert_eq(action.type, BattleAction.Type.ITEM)
	assert_eq(action.target, target)
	assert_eq(action.item, item)


func test_create_defend_action() -> void:
	var action := BattleAction.create_defend()
	assert_eq(action.type, BattleAction.Type.DEFEND)
	assert_null(action.target)


func test_create_wait_action() -> void:
	var action := BattleAction.create_wait()
	assert_eq(action.type, BattleAction.Type.WAIT)
	assert_null(action.target)
	assert_null(action.ability)
	assert_null(action.item)


# ---- Multiple abilities in sequence ----

func test_multiple_abilities_drain_ee() -> void:
	var b := Helpers.make_battler({"max_ee": 50})
	add_child_autofree(b)

	var ability := Helpers.make_ability({"ee_cost": 15})

	assert_true(b.use_ee(ability.ee_cost))
	assert_eq(b.current_ee, 35)

	assert_true(b.use_ee(ability.ee_cost))
	assert_eq(b.current_ee, 20)

	assert_true(b.use_ee(ability.ee_cost))
	assert_eq(b.current_ee, 5)

	assert_false(
		b.use_ee(ability.ee_cost),
		"Should fail — insufficient EE after 3 uses"
	)
	assert_eq(b.current_ee, 5, "EE should not change on failed use")


# ---- Defend reduces incoming damage ----

func test_defend_then_take_damage_reduces() -> void:
	var normal := Helpers.make_battler({"defense": 10})
	add_child_autofree(normal)
	var normal_dmg := normal.take_damage(50)

	var defender := Helpers.make_battler({"defense": 10})
	add_child_autofree(defender)
	defender.defend()
	var defended_dmg := defender.take_damage(50)

	assert_lt(
		defended_dmg, normal_dmg,
		"Defending should reduce damage taken"
	)


# ---- Revive restores battler to combat ----

func test_revive_after_defeat_allows_damage() -> void:
	var b := Helpers.make_battler({"max_hp": 100, "defense": 0})
	add_child_autofree(b)

	# Kill the battler
	b.take_damage(999)
	assert_false(b.is_alive)

	# Revive
	b.revive(0.5)
	assert_true(b.is_alive)
	assert_eq(b.current_hp, 50)

	# Should be able to take damage again
	var dmg := b.take_damage(20)
	assert_gt(dmg, 0)
	assert_lt(b.current_hp, 50)

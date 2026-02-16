extends GutTest

## Tests for battle state flow — skill availability, cancel handling,
## and graceful fallback when actions fail mid-execution.

const Helpers = preload("res://tests/helpers/test_helpers.gd")


# ---- Skill availability filtering ----

func test_no_available_abilities_when_ee_depleted() -> void:
	var ability := Helpers.make_ability({"ee_cost": 20})
	var b := Helpers.make_party_battler({
		"max_ee": 20,
		"abilities": [ability],
	})
	add_child_autofree(b)

	# Use all EE
	b.use_ee(20)
	assert_eq(b.current_ee, 0)

	var available := b.get_available_abilities()
	assert_eq(
		available.size(), 0,
		"Should have no available abilities when EE is 0"
	)


func test_partial_ee_filters_expensive_abilities() -> void:
	var cheap := Helpers.make_ability({"id": &"cheap", "ee_cost": 5})
	var expensive := Helpers.make_ability({"id": &"expensive", "ee_cost": 30})
	var b := Helpers.make_party_battler({
		"max_ee": 50,
		"abilities": [cheap, expensive],
	})
	add_child_autofree(b)

	# Spend most EE, leaving only enough for cheap
	b.use_ee(40)
	assert_eq(b.current_ee, 10)

	var available := b.get_available_abilities()
	assert_eq(
		available.size(), 1,
		"Only cheap ability should be available"
	)
	assert_eq(
		(available[0] as AbilityData).id, &"cheap",
		"Available ability should be the cheap one"
	)


func test_hollow_state_returns_no_abilities() -> void:
	var ability := Helpers.make_ability({"ee_cost": 5})
	var b := Helpers.make_party_battler({
		"max_ee": 100,
		"abilities": [ability],
	})
	add_child_autofree(b)

	# Force hollow state by reaching overload then getting defeated
	b.resonance_gauge = Battler.RESONANCE_OVERLOAD_THRESHOLD + 1
	b.resonance_state = Battler.ResonanceState.HOLLOW

	var available := b.get_available_abilities()
	assert_eq(
		available.size(), 0,
		"Hollow state should return no abilities"
	)


func test_all_abilities_available_with_full_ee() -> void:
	var a1 := Helpers.make_ability({"id": &"a1", "ee_cost": 10})
	var a2 := Helpers.make_ability({"id": &"a2", "ee_cost": 20})
	var b := Helpers.make_party_battler({
		"max_ee": 50,
		"abilities": [a1, a2],
	})
	add_child_autofree(b)

	var available := b.get_available_abilities()
	assert_eq(
		available.size(), 2,
		"Both abilities should be available with full EE"
	)


# ---- EE failure should not waste the turn ----

func test_use_ee_failure_preserves_ee() -> void:
	var b := Helpers.make_battler({"max_ee": 20})
	add_child_autofree(b)

	b.use_ee(15)
	assert_eq(b.current_ee, 5)

	# Attempt to use more than remaining
	var result := b.use_ee(10)
	assert_false(result, "use_ee should fail with insufficient EE")
	assert_eq(b.current_ee, 5, "EE should be unchanged after failed use")


func test_use_ee_after_depletion_fails() -> void:
	var b := Helpers.make_battler({"max_ee": 10})
	add_child_autofree(b)

	b.use_ee(10)
	assert_eq(b.current_ee, 0)

	var result := b.use_ee(1)
	assert_false(result, "Cannot use EE when at zero")
	assert_eq(b.current_ee, 0)


# ---- BattleAction should preserve context for retry ----

func test_create_ability_action_stores_ability() -> void:
	var target := Helpers.make_battler()
	add_child_autofree(target)
	var ability := Helpers.make_ability({"ee_cost": 15})

	var action := BattleAction.create_ability(ability, target)
	assert_eq(action.type, BattleAction.Type.ABILITY)
	assert_eq(action.ability, ability)
	assert_eq(action.ability.ee_cost, 15)


# ---- Ability availability updates after using skills ----

func test_abilities_shrink_after_using_ee() -> void:
	var a1 := Helpers.make_ability({"id": &"cheap", "ee_cost": 5})
	var a2 := Helpers.make_ability({"id": &"mid", "ee_cost": 15})
	var a3 := Helpers.make_ability({"id": &"pricey", "ee_cost": 25})
	var b := Helpers.make_party_battler({
		"max_ee": 30,
		"abilities": [a1, a2, a3],
	})
	add_child_autofree(b)

	# Initially all affordable
	assert_eq(b.get_available_abilities().size(), 3)

	# Use the pricey one (costs 25)
	b.use_ee(25)
	assert_eq(b.current_ee, 5)

	# Now only cheap is affordable
	var available := b.get_available_abilities()
	assert_eq(
		available.size(), 1,
		"Only the 5-EE ability should remain available"
	)
	assert_eq((available[0] as AbilityData).id, &"cheap")


func test_abilities_unavailable_then_restored_via_ee_restore() -> void:
	var ability := Helpers.make_ability({"ee_cost": 20})
	var b := Helpers.make_party_battler({
		"max_ee": 30,
		"abilities": [ability],
	})
	add_child_autofree(b)

	# Deplete EE
	b.use_ee(30)
	assert_eq(b.get_available_abilities().size(), 0)

	# Restore some EE
	b.restore_ee(25)
	assert_eq(
		b.get_available_abilities().size(), 1,
		"Ability should be available again after EE restore"
	)

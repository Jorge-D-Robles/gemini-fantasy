extends GutTest

## Tests that battle state (HP, EE, resonance) persists correctly
## across multiple turns and operations.

const Helpers = preload("res://tests/helpers/test_helpers.gd")


# ---- Multi-turn HP accumulation ----

func test_hp_accumulates_damage_across_turns() -> void:
	var b := Helpers.make_battler({"max_hp": 200, "defense": 0})
	add_child_autofree(b)

	var hp_after_first := b.current_hp
	b.take_damage(30)
	hp_after_first = b.current_hp
	assert_lt(hp_after_first, 200, "HP should decrease after first hit")

	b.end_turn()
	assert_eq(b.current_hp, hp_after_first, "HP should not reset on end_turn")

	b.take_damage(30)
	assert_lt(b.current_hp, hp_after_first, "HP should decrease further")

	b.end_turn()
	var expected_still_lower: bool = b.current_hp < hp_after_first
	assert_true(expected_still_lower, "HP remains reduced after second turn end")


func test_hp_never_resets_between_turns() -> void:
	var b := Helpers.make_battler({"max_hp": 100, "defense": 0})
	add_child_autofree(b)

	# Simulate 5 rounds of taking damage
	for i in 5:
		var hp_before := b.current_hp
		if not b.is_alive:
			break
		b.take_damage(10)
		assert_lt(
			b.current_hp, hp_before,
			"HP should decrease on turn %d" % (i + 1)
		)
		b.end_turn()


func test_partial_heal_does_not_restore_full() -> void:
	var b := Helpers.make_battler({"max_hp": 100, "defense": 0})
	add_child_autofree(b)

	b.take_damage(60)
	var hp_after_damage := b.current_hp
	assert_lt(hp_after_damage, 100)

	b.heal(20)
	assert_gt(b.current_hp, hp_after_damage, "Heal should increase HP")
	assert_lt(b.current_hp, 100, "Partial heal should not restore to max")


func test_damage_then_heal_then_damage() -> void:
	var b := Helpers.make_battler({"max_hp": 100, "defense": 0})
	add_child_autofree(b)

	b.take_damage(50)
	var after_first_hit := b.current_hp

	b.heal(20)
	var after_heal := b.current_hp
	assert_gt(after_heal, after_first_hit)

	b.take_damage(30)
	assert_lt(b.current_hp, after_heal, "Damage after heal reduces HP further")


# ---- EE persistence ----

func test_ee_accumulates_usage_across_turns() -> void:
	var b := Helpers.make_battler({"max_ee": 50})
	add_child_autofree(b)

	b.use_ee(10)
	assert_eq(b.current_ee, 40)
	b.end_turn()
	assert_eq(b.current_ee, 40, "EE should not reset on end_turn")

	b.use_ee(15)
	assert_eq(b.current_ee, 25)
	b.end_turn()
	assert_eq(b.current_ee, 25)


func test_ee_partial_restore() -> void:
	var b := Helpers.make_battler({"max_ee": 50})
	add_child_autofree(b)

	b.use_ee(30)
	assert_eq(b.current_ee, 20)

	b.restore_ee(10)
	assert_eq(b.current_ee, 30, "Partial restore should add to current EE")
	assert_lt(b.current_ee, b.max_ee, "Should not be at max")


# ---- Resonance persistence ----

func test_resonance_accumulates_across_turns() -> void:
	var b := Helpers.make_battler()
	add_child_autofree(b)

	b.add_resonance(30.0)
	assert_almost_eq(b.resonance_gauge, 30.0, 0.01)
	b.end_turn()
	assert_almost_eq(
		b.resonance_gauge, 30.0, 0.01,
		"Resonance should not reset on end_turn"
	)

	b.add_resonance(20.0)
	assert_almost_eq(b.resonance_gauge, 50.0, 0.01)


# ---- Signal emission on each state change ----

func test_hp_signal_emitted_every_damage() -> void:
	var b := Helpers.make_battler()
	add_child_autofree(b)
	watch_signals(b)

	b.take_damage(10)
	b.take_damage(10)
	b.take_damage(10)

	assert_signal_emit_count(b, "hp_changed", 3)


func test_hp_signal_emitted_on_heal() -> void:
	var b := Helpers.make_battler()
	add_child_autofree(b)
	b.take_damage(50)

	watch_signals(b)
	b.heal(20)
	assert_signal_emitted(b, "hp_changed")


func test_damage_taken_signal_per_hit() -> void:
	var b := Helpers.make_battler()
	add_child_autofree(b)
	watch_signals(b)

	b.take_damage(10)
	b.take_damage(20)

	assert_signal_emit_count(b, "damage_taken", 2)


# ---- Battle end detection with accumulated damage ----

func test_defeat_after_accumulated_damage() -> void:
	var b := Helpers.make_battler({"max_hp": 50, "defense": 0})
	add_child_autofree(b)

	b.take_damage(20)
	assert_true(b.is_alive, "Should still be alive")

	b.take_damage(20)
	assert_true(b.is_alive, "Should still be alive after second hit")

	b.take_damage(20)
	assert_false(b.is_alive, "Should be defeated after accumulated damage")


func test_defend_stance_persists_through_end_turn() -> void:
	# is_defending should NOT clear in end_turn — it persists so enemy attacks
	# in the same round use the halved damage. PlayerTurnState.enter() clears it.
	var b := Helpers.make_battler()
	add_child_autofree(b)

	b.defend()
	assert_true(b.is_defending)
	b.end_turn()
	assert_true(b.is_defending, "Defend persists after end_turn (cleared by PlayerTurnState)")

	# Simulate PlayerTurnState.enter() clearing is_defending for next player turn
	b.is_defending = false
	assert_false(b.is_defending, "Defend clears at start of next player turn")


# ---- Status effects persist across turns ----

func test_status_effects_persist_across_turns() -> void:
	var b := Helpers.make_battler()
	add_child_autofree(b)

	b.apply_status_effect(&"poison")
	assert_true(b.has_status_effect(&"poison"))

	b.end_turn()
	assert_true(
		b.has_status_effect(&"poison"),
		"Status effect should persist after end_turn"
	)

	b.end_turn()
	assert_true(
		b.has_status_effect(&"poison"),
		"Status effect should persist after multiple turns"
	)

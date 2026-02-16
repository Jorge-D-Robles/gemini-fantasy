extends GutTest

## Tests for Battler — HP, EE, damage formulas, Resonance, status effects.

const Helpers = preload("res://tests/helpers/test_helpers.gd")

var _battler: Battler


func before_each() -> void:
	_battler = Helpers.make_battler()
	add_child_autofree(_battler)


# ---- HP ----

func test_take_damage_reduces_hp() -> void:
	var dmg := _battler.take_damage(30)
	assert_gt(dmg, 0)
	assert_lt(_battler.current_hp, _battler.max_hp)


func test_take_damage_minimum_one() -> void:
	# With high defense, damage should still be at least 1
	var tank := Helpers.make_battler({"defense": 190})
	add_child_autofree(tank)
	var dmg := tank.take_damage(1)
	assert_eq(dmg, 1)


func test_dead_battler_takes_zero_damage() -> void:
	_battler.current_hp = 0
	_battler.is_alive = false
	var dmg := _battler.take_damage(50)
	assert_eq(dmg, 0)


func test_heal_caps_at_max() -> void:
	_battler.current_hp = 50
	var healed := _battler.heal(999)
	assert_eq(_battler.current_hp, _battler.max_hp)
	assert_eq(healed, 50)


func test_heal_dead_battler_returns_zero() -> void:
	_battler.current_hp = 0
	_battler.is_alive = false
	var healed := _battler.heal(50)
	assert_eq(healed, 0)


# ---- Echo Energy ----

func test_use_ee_success() -> void:
	assert_true(_battler.use_ee(10))
	assert_eq(_battler.current_ee, 40)


func test_use_ee_insufficient() -> void:
	assert_false(_battler.use_ee(999))
	assert_eq(_battler.current_ee, 50)


func test_restore_ee_caps_at_max() -> void:
	_battler.current_ee = 40
	var restored := _battler.restore_ee(999)
	assert_eq(_battler.current_ee, _battler.max_ee)
	assert_eq(restored, 10)


# ---- Damage Formulas ----

func test_deal_damage_physical() -> void:
	# base 10 + attack(20) * 0.5 = 10 + 10 = 20
	var total := _battler.deal_damage(10, false)
	assert_eq(total, 20)


func test_deal_damage_magical() -> void:
	# base 10 + magic(15) * 0.5 = 10 + 7 = 17 (int truncation)
	var total := _battler.deal_damage(10, true)
	assert_eq(total, 17)


# ---- Resonance ----

func test_initial_state_focused() -> void:
	assert_eq(
		_battler.resonance_state, Battler.ResonanceState.FOCUSED
	)
	assert_eq(_battler.resonance_gauge, 0.0)


func test_resonance_transitions_to_resonant() -> void:
	_battler.add_resonance(75.0)
	assert_eq(
		_battler.resonance_state, Battler.ResonanceState.RESONANT
	)


func test_resonance_transitions_to_overload() -> void:
	_battler.add_resonance(100.0)
	assert_eq(
		_battler.resonance_state, Battler.ResonanceState.OVERLOAD
	)


func test_hollow_on_defeat_while_overloaded() -> void:
	_battler.add_resonance(100.0)
	assert_eq(
		_battler.resonance_state, Battler.ResonanceState.OVERLOAD
	)
	# Kill the battler — should transition to HOLLOW
	_battler.current_hp = 1
	_battler.take_damage(999)
	assert_eq(
		_battler.resonance_state, Battler.ResonanceState.HOLLOW
	)
	assert_eq(_battler.resonance_gauge, 0.0)


func test_defeat_without_overload_not_hollow() -> void:
	# Kill battler while not in OVERLOAD — should NOT become HOLLOW
	_battler.current_hp = 1
	_battler.take_damage(999)
	assert_false(_battler.is_alive)
	assert_ne(
		_battler.resonance_state, Battler.ResonanceState.HOLLOW
	)


func test_hollow_ignores_resonance_gain() -> void:
	# Force HOLLOW state
	_battler.add_resonance(100.0)
	_battler.current_hp = 1
	_battler.take_damage(999)
	assert_eq(
		_battler.resonance_state, Battler.ResonanceState.HOLLOW
	)
	# Try to add resonance — should be ignored
	_battler.add_resonance(50.0)
	assert_eq(_battler.resonance_gauge, 0.0)


func test_defend_gains_resonance() -> void:
	_battler.defend()
	# DEFEND_RESONANCE_BASE(10) * RESONANCE_GAIN_DEFENDING(1.5) = 15
	assert_almost_eq(_battler.resonance_gauge, 15.0, 0.01)


func test_resonance_capped_at_max() -> void:
	_battler.add_resonance(200.0)
	assert_eq(_battler.resonance_gauge, Battler.RESONANCE_MAX)


# ---- Defend ----

func test_defend_reduces_damage() -> void:
	var normal_dmg := _battler.take_damage(50)
	var defender := Helpers.make_battler()
	add_child_autofree(defender)
	defender.defend()
	var defended_dmg := defender.take_damage(50)
	assert_lt(defended_dmg, normal_dmg)


func test_end_turn_clears_defend() -> void:
	_battler.defend()
	assert_true(_battler.is_defending)
	_battler.end_turn()
	assert_false(_battler.is_defending)


# ---- Status Effects ----

func test_apply_status_effect() -> void:
	_battler.apply_status_effect(&"poison")
	assert_true(_battler.has_status_effect(&"poison"))


func test_apply_duplicate_status_no_stack() -> void:
	_battler.apply_status_effect(&"poison")
	_battler.apply_status_effect(&"poison")
	assert_eq(_battler.status_effects.size(), 1)


func test_remove_status_effect() -> void:
	_battler.apply_status_effect(&"burn")
	_battler.remove_status_effect(&"burn")
	assert_false(_battler.has_status_effect(&"burn"))


func test_status_effect_signals() -> void:
	watch_signals(_battler)
	_battler.apply_status_effect(&"freeze")
	assert_signal_emitted_with_parameters(
		_battler, "status_effect_applied", [&"freeze"]
	)
	_battler.remove_status_effect(&"freeze")
	assert_signal_emitted_with_parameters(
		_battler, "status_effect_removed", [&"freeze"]
	)


# ---- Revive ----

func test_revive_restores_hp() -> void:
	_battler.current_hp = 0
	_battler.is_alive = false
	_battler.revive(0.5)
	assert_true(_battler.is_alive)
	assert_eq(_battler.current_hp, 50)


func test_revive_minimum_one_hp() -> void:
	_battler.current_hp = 0
	_battler.is_alive = false
	_battler.revive(0.001)
	assert_true(_battler.is_alive)
	assert_gte(_battler.current_hp, 1)


func test_revive_no_op_if_alive() -> void:
	var hp_before := _battler.current_hp
	_battler.revive(0.5)
	assert_eq(_battler.current_hp, hp_before)


# ---- Turn Delay ----

func test_turn_delay_inversely_proportional_to_speed() -> void:
	var slow := Helpers.make_battler({"speed": 5})
	add_child_autofree(slow)
	var fast := Helpers.make_battler({"speed": 20})
	add_child_autofree(fast)
	assert_gt(slow.turn_delay, fast.turn_delay)


func test_turn_delay_zero_speed_fallback() -> void:
	var zero_speed := Helpers.make_battler({"speed": 0})
	add_child_autofree(zero_speed)
	assert_eq(zero_speed.turn_delay, 100.0)


# ---- Signals ----

func test_hp_changed_signal() -> void:
	watch_signals(_battler)
	_battler.take_damage(10)
	assert_signal_emitted(_battler, "hp_changed")


func test_ee_changed_signal() -> void:
	watch_signals(_battler)
	_battler.use_ee(5)
	assert_signal_emitted(_battler, "ee_changed")


func test_defeated_signal() -> void:
	watch_signals(_battler)
	_battler.current_hp = 1
	_battler.take_damage(999)
	assert_signal_emitted(_battler, "defeated")


func test_resonance_changed_signal() -> void:
	watch_signals(_battler)
	_battler.add_resonance(10.0)
	assert_signal_emitted(_battler, "resonance_changed")


func test_resonance_state_changed_signal() -> void:
	watch_signals(_battler)
	_battler.add_resonance(75.0)
	assert_signal_emitted(_battler, "resonance_state_changed")


# ---- Overload Damage Multipliers ----

func test_overload_doubles_outgoing_damage() -> void:
	var normal := _battler.deal_damage(10, false)
	var overloaded := Helpers.make_battler()
	add_child_autofree(overloaded)
	overloaded.add_resonance(100.0)
	var boosted := overloaded.deal_damage(10, false)
	assert_eq(boosted, normal * 2)


func test_overload_doubles_incoming_damage() -> void:
	var normal_dmg := _battler.take_damage(50)
	var overloaded := Helpers.make_battler()
	add_child_autofree(overloaded)
	overloaded.add_resonance(100.0)
	var overloaded_dmg := overloaded.take_damage(50)
	assert_gt(overloaded_dmg, normal_dmg)

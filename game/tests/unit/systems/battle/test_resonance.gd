extends GutTest

## Tests for Resonance gauge mechanics — Hollow stat penalties, Resonant
## ability bonus, Hollow cure, and state transition behavior.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _battler: Battler


func before_each() -> void:
	_battler = Helpers.make_battler({
		"attack": 20,
		"magic": 15,
		"defense": 10,
		"resistance": 10,
		"speed": 10,
	})
	add_child_autofree(_battler)


# Helper: force a battler into HOLLOW state via Overload → KO.
func _force_hollow(b: Battler) -> void:
	b.add_resonance(100.0)
	assert_eq(b.resonance_state, Battler.ResonanceState.OVERLOAD)
	b.current_hp = 1
	b.take_damage(999)
	assert_eq(b.resonance_state, Battler.ResonanceState.HOLLOW)
	# Revive so we can test stat effects while alive but Hollow
	b.revive(1.0)
	assert_true(b.is_alive)
	assert_eq(b.resonance_state, Battler.ResonanceState.HOLLOW)


# --- Hollow Stat Penalties ---


func test_hollow_halves_attack_in_deal_damage() -> void:
	# Normal physical damage: base 10 + attack(20) * 0.5 = 20
	var normal := _battler.deal_damage(10, false)
	assert_eq(normal, 20, "Expected normal deal_damage = 20")

	var hollow := Helpers.make_battler({"attack": 20, "defense": 0})
	add_child_autofree(hollow)
	_force_hollow(hollow)
	# Hollow: attack halved to 10 → base 10 + 10 * 0.5 = 15
	var hollow_dmg := hollow.deal_damage(10, false)
	assert_lt(
		hollow_dmg, normal,
		"Hollow should reduce outgoing physical damage",
	)


func test_hollow_halves_magic_in_deal_damage() -> void:
	# Normal magical damage: base 10 + magic(15) * 0.5 = 17
	var normal := _battler.deal_damage(10, true)

	var hollow := Helpers.make_battler({"magic": 15, "defense": 0})
	add_child_autofree(hollow)
	_force_hollow(hollow)
	var hollow_dmg := hollow.deal_damage(10, true)
	assert_lt(
		hollow_dmg, normal,
		"Hollow should reduce outgoing magical damage",
	)


func test_hollow_halves_speed_in_turn_delay() -> void:
	var normal_delay := _battler.turn_delay
	var hollow := Helpers.make_battler({"speed": 10})
	add_child_autofree(hollow)
	_force_hollow(hollow)
	# Speed halved → turn_delay doubled
	assert_gt(
		hollow.turn_delay, normal_delay,
		"Hollow should increase turn delay (halved speed)",
	)


func test_hollow_get_modified_stat_halved() -> void:
	_force_hollow(_battler)
	# All stats should be ~50% of base
	assert_eq(
		_battler.get_modified_stat("attack"),
		10,
		"Hollow attack should be 50%",
	)
	assert_eq(
		_battler.get_modified_stat("magic"),
		7,
		"Hollow magic should be 50% (int truncation: 15*0.5=7)",
	)
	assert_eq(
		_battler.get_modified_stat("defense"),
		5,
		"Hollow defense should be 50%",
	)
	assert_eq(
		_battler.get_modified_stat("resistance"),
		5,
		"Hollow resistance should be 50%",
	)
	assert_eq(
		_battler.get_modified_stat("speed"),
		5,
		"Hollow speed should be 50%",
	)


func test_focused_no_stat_penalty() -> void:
	assert_eq(_battler.resonance_state, Battler.ResonanceState.FOCUSED)
	assert_eq(_battler.get_modified_stat("attack"), 20)
	assert_eq(_battler.get_modified_stat("defense"), 10)


# --- Resonant Ability Damage Bonus ---


func test_resonant_ability_damage_bonus() -> void:
	var base := Helpers.make_battler({"attack": 20})
	add_child_autofree(base)

	# Normal ability damage
	var normal := base.deal_damage(10, false, true)

	var resonant := Helpers.make_battler({"attack": 20})
	add_child_autofree(resonant)
	resonant.add_resonance(75.0)
	assert_eq(
		resonant.resonance_state, Battler.ResonanceState.RESONANT,
	)

	# Resonant ability damage should be 20% higher
	var boosted := resonant.deal_damage(10, false, true)
	assert_gt(
		boosted, normal,
		"Resonant state should boost ability damage by 20%",
	)
	assert_eq(boosted, int(normal * 1.2))


func test_resonant_no_bonus_on_basic_attack() -> void:
	# Basic attacks (is_ability=false) should NOT get the Resonant bonus
	var normal := _battler.deal_damage(10, false, false)

	var resonant := Helpers.make_battler({"attack": 20})
	add_child_autofree(resonant)
	resonant.add_resonance(75.0)
	assert_eq(
		resonant.resonance_state, Battler.ResonanceState.RESONANT,
	)
	var resonant_basic := resonant.deal_damage(10, false, false)
	assert_eq(
		resonant_basic, normal,
		"Resonant should not boost basic attacks",
	)


func test_overload_overrides_resonant_bonus() -> void:
	# When in OVERLOAD, the 2x multiplier applies — not the 1.2x Resonant
	var overloaded := Helpers.make_battler({"attack": 20})
	add_child_autofree(overloaded)
	overloaded.add_resonance(100.0)
	assert_eq(
		overloaded.resonance_state, Battler.ResonanceState.OVERLOAD,
	)

	var base := Helpers.make_battler({"attack": 20})
	add_child_autofree(base)
	var normal := base.deal_damage(10, false)

	var boosted := overloaded.deal_damage(10, false, true)
	# Overload = 2x, not 1.2x
	assert_eq(boosted, normal * 2)


# --- Hollow Cure ---


func test_cure_hollow_resets_to_focused() -> void:
	_force_hollow(_battler)
	assert_eq(_battler.resonance_state, Battler.ResonanceState.HOLLOW)
	_battler.cure_hollow()
	assert_eq(
		_battler.resonance_state, Battler.ResonanceState.FOCUSED,
	)
	assert_eq(_battler.resonance_gauge, 0.0)


func test_cure_hollow_restores_resonance_gain() -> void:
	_force_hollow(_battler)
	_battler.cure_hollow()
	# Should now accept resonance gain again
	_battler.add_resonance(10.0)
	assert_eq(_battler.resonance_gauge, 10.0)


func test_cure_hollow_restores_stat_values() -> void:
	_force_hollow(_battler)
	assert_eq(
		_battler.get_modified_stat("attack"), 10,
		"Hollow: halved",
	)
	_battler.cure_hollow()
	assert_eq(
		_battler.get_modified_stat("attack"), 20,
		"Cured: full stats",
	)


func test_cure_hollow_no_op_when_not_hollow() -> void:
	assert_eq(_battler.resonance_state, Battler.ResonanceState.FOCUSED)
	_battler.add_resonance(50.0)
	var gauge_before := _battler.resonance_gauge
	_battler.cure_hollow()
	# Should not change anything
	assert_eq(_battler.resonance_gauge, gauge_before)
	assert_eq(_battler.resonance_state, Battler.ResonanceState.FOCUSED)


func test_cure_hollow_emits_state_changed_signal() -> void:
	_force_hollow(_battler)
	watch_signals(_battler)
	_battler.cure_hollow()
	assert_signal_emitted_with_parameters(
		_battler,
		"resonance_state_changed",
		[Battler.ResonanceState.HOLLOW, Battler.ResonanceState.FOCUSED],
	)


func test_cure_hollow_recalculates_turn_delay() -> void:
	var delay_before := _battler.turn_delay
	_force_hollow(_battler)
	var hollow_delay := _battler.turn_delay
	assert_gt(hollow_delay, delay_before)
	_battler.cure_hollow()
	assert_eq(
		_battler.turn_delay, delay_before,
		"Turn delay should restore after cure",
	)


# --- Hollow Cure via Item ---


func test_cure_hollow_item_effect_type_exists() -> void:
	# CURE_HOLLOW should be a valid EffectType enum value
	var item := ItemData.new()
	item.effect_type = ItemData.EffectType.CURE_HOLLOW
	assert_eq(item.effect_type, ItemData.EffectType.CURE_HOLLOW)


# --- Resonance State Changed Signal with State Name ---


func test_resonance_state_changed_focused_to_resonant() -> void:
	watch_signals(_battler)
	_battler.add_resonance(75.0)
	assert_signal_emitted_with_parameters(
		_battler,
		"resonance_state_changed",
		[Battler.ResonanceState.FOCUSED, Battler.ResonanceState.RESONANT],
	)


func test_resonance_state_changed_resonant_to_overload() -> void:
	_battler.add_resonance(75.0)
	watch_signals(_battler)
	_battler.add_resonance(25.0)
	assert_signal_emitted_with_parameters(
		_battler,
		"resonance_state_changed",
		[Battler.ResonanceState.RESONANT, Battler.ResonanceState.OVERLOAD],
	)

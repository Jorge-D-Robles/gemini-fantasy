extends GutTest

## Tests for BattlerResonance static utility class.
## ResonanceState int mapping: 0=FOCUSED, 1=RESONANT, 2=OVERLOAD, 3=HOLLOW

const BResonance = preload("res://systems/battle/battler_resonance.gd")
const GB = preload("res://systems/game_balance.gd")

# Named constants for readability
const FOCUSED: int = 0
const RESONANT: int = 1
const OVERLOAD: int = 2
const HOLLOW: int = 3


func test_add_to_gauge_clamps_at_max() -> void:
	var result := BResonance.add_to_gauge(140.0, 20.0)
	assert_eq(result, GB.RESONANCE_MAX, "Should clamp at RESONANCE_MAX")


func test_add_to_gauge_normal_addition() -> void:
	var result := BResonance.add_to_gauge(10.0, 5.0)
	assert_eq(result, 15.0, "Should add normally when below max")


func test_evaluate_state_focused() -> void:
	var result := BResonance.evaluate_state(50.0, FOCUSED)
	assert_eq(result, FOCUSED, "Below 75 should be FOCUSED")


func test_evaluate_state_resonant() -> void:
	var result := BResonance.evaluate_state(80.0, FOCUSED)
	assert_eq(result, RESONANT, "75-99 should be RESONANT")


func test_evaluate_state_overload() -> void:
	var result := BResonance.evaluate_state(100.0, FOCUSED)
	assert_eq(result, OVERLOAD, "100+ should be OVERLOAD")


func test_evaluate_state_hollow_unchanged() -> void:
	var result := BResonance.evaluate_state(50.0, HOLLOW)
	assert_eq(result, HOLLOW, "HOLLOW should stay HOLLOW regardless of gauge")


func test_on_defeated_overload_to_hollow() -> void:
	var result := BResonance.on_defeated(OVERLOAD)
	assert_eq(result["state"], HOLLOW, "Overload on defeat becomes HOLLOW")
	assert_eq(result["gauge"], 0.0, "Gauge should reset to 0")
	assert_true(result["changed"], "Should report state changed")


func test_on_defeated_non_overload_unchanged() -> void:
	var result := BResonance.on_defeated(FOCUSED)
	assert_false(result["changed"], "Non-overload should not change state")


func test_calculate_turn_delay_normal() -> void:
	# speed=10, FOCUSED -> 100/10 = 10.0
	var result := BResonance.calculate_turn_delay(10, FOCUSED)
	assert_eq(result, 10.0, "Should be TURN_DELAY_BASE / speed")


func test_calculate_turn_delay_hollow_penalty() -> void:
	# speed=10, HOLLOW -> effective_speed = 10*0.5 = 5; 100/5 = 20.0
	var result := BResonance.calculate_turn_delay(10, HOLLOW)
	assert_eq(result, 20.0, "Hollow should halve effective speed")


func test_calculate_turn_delay_zero_speed() -> void:
	var result := BResonance.calculate_turn_delay(0, FOCUSED)
	assert_eq(result, GB.TURN_DELAY_BASE, "Zero speed should use base delay")

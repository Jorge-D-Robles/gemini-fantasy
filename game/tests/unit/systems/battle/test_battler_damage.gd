extends GutTest

## Tests for BattlerDamage static utility class.
## ResonanceState int mapping: 0=FOCUSED, 1=RESONANT, 2=OVERLOAD, 3=HOLLOW

const BDamage = preload("res://systems/battle/battler_damage.gd")
const GB = preload("res://systems/game_balance.gd")


func test_calculate_outgoing_base_plus_stat() -> void:
	# base=10, stat=20, FOCUSED, not ability
	var result := BDamage.calculate_outgoing(10, 20, 0, false)
	# 10 + 20*0.5 = 20
	assert_eq(result, 20, "Should be base + stat*scaling")


func test_calculate_outgoing_overload_doubles() -> void:
	# base=10, stat=20, OVERLOAD(2), not ability
	var result := BDamage.calculate_outgoing(10, 20, 2, false)
	# (10 + 20*0.5) * 2.0 = 40
	assert_eq(result, 40, "Overload should double outgoing damage")


func test_calculate_outgoing_resonant_ability_bonus() -> void:
	# base=10, stat=20, RESONANT(1), is_ability=true
	var result := BDamage.calculate_outgoing(10, 20, 1, true)
	# (10 + 20*0.5) * 1.2 = 24
	assert_eq(result, 24, "Resonant ability should get 1.2x bonus")


func test_calculate_outgoing_resonant_no_bonus_for_basic() -> void:
	# base=10, stat=20, RESONANT(1), is_ability=false
	var result := BDamage.calculate_outgoing(10, 20, 1, false)
	# No bonus for non-ability attacks in resonant
	assert_eq(result, 20, "Resonant non-ability should get no bonus")


func test_calculate_outgoing_hollow_penalty() -> void:
	# base=10, stat=20, HOLLOW(3), not ability
	var result := BDamage.calculate_outgoing(10, 20, 3, false)
	# stat = 20*0.5 = 10; 10 + 10*0.5 = 15
	assert_eq(result, 15, "Hollow should halve stat before scaling")


func test_calculate_outgoing_focused_no_modifier() -> void:
	# base=10, stat=20, FOCUSED(0), not ability
	var result := BDamage.calculate_outgoing(10, 20, 0, false)
	assert_eq(result, 20, "Focused should have no special modifier")


func test_calculate_incoming_with_defense() -> void:
	# base=100, def=50, FOCUSED(0), not defending
	var result := BDamage.calculate_incoming(100, 50, 0, false)
	# defense_mod = 1.0 - 50/200 = 0.75; 100 * 0.75 = 75
	assert_eq(result, 75, "Defense should reduce incoming damage")


func test_calculate_incoming_minimum_one() -> void:
	# base=1, def=200, FOCUSED(0), not defending
	var result := BDamage.calculate_incoming(1, 200, 0, false)
	# defense_mod = 1.0 - 200/200 = 0.0, clamped to 0.1; 1 * 0.1 = 0.1 -> floor to 1
	assert_eq(result, 1, "Damage should never go below 1")


func test_calculate_incoming_defend_halves() -> void:
	# base=100, def=0, FOCUSED(0), defending
	var result := BDamage.calculate_incoming(100, 0, 0, true)
	# defense_mod = 1.0; * 0.5 (defend) = 0.5; 100 * 0.5 = 50
	assert_eq(result, 50, "Defending should halve incoming damage")

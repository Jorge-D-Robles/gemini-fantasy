extends GutTest

## Tests for T-0143: critical hit mechanic.
## Validates crit chance formula, crit damage calculation, and GameBalance constants.

const BattlerDamage := preload("res://systems/battle/battler_damage.gd")
const GameBalance := preload("res://systems/game_balance.gd")


func test_compute_crit_chance_zero_luck() -> void:
	var chance := BattlerDamage.compute_crit_chance(0)
	assert_almost_eq(chance, 0.05, 0.0001, "0 luck = 5% crit chance")


func test_compute_crit_chance_ten_luck() -> void:
	var chance := BattlerDamage.compute_crit_chance(10)
	assert_almost_eq(chance, 0.10, 0.0001, "10 luck = 10% crit chance")


func test_compute_crit_chance_twenty_luck() -> void:
	var chance := BattlerDamage.compute_crit_chance(20)
	assert_almost_eq(chance, 0.15, 0.0001, "20 luck = 15% crit chance")


func test_compute_crit_chance_clamped_to_one() -> void:
	# With very high luck (e.g. 200), chance should never exceed 1.0
	var chance := BattlerDamage.compute_crit_chance(200)
	assert_true(chance <= 1.0, "Crit chance capped at 100%")


func test_compute_crit_chance_is_positive() -> void:
	var chance := BattlerDamage.compute_crit_chance(0)
	assert_gt(chance, 0.0, "Crit chance always positive")


func test_apply_crit_multiplies_by_one_point_five() -> void:
	var critted := BattlerDamage.apply_crit(100)
	assert_eq(critted, 150, "100 damage x1.5 = 150")


func test_apply_crit_rounds_down() -> void:
	# int(75 * 1.5) = 112, not 113
	var critted := BattlerDamage.apply_crit(75)
	assert_eq(critted, 112, "apply_crit truncates to int")


func test_apply_crit_zero_damage() -> void:
	var critted := BattlerDamage.apply_crit(0)
	assert_eq(critted, 0, "Crit on 0 damage is still 0")


func test_compute_crit_chance_increases_with_luck() -> void:
	var low := BattlerDamage.compute_crit_chance(5)
	var high := BattlerDamage.compute_crit_chance(15)
	assert_true(high > low, "Higher luck = higher crit chance")

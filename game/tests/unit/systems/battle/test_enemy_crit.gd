extends GutTest

## Tests for T-0168: enemy crit routing through BattlerDamage.
## Verifies that enemy crit chance uses the 5% + luck*0.5% formula,
## and that apply_crit returns the correct 1.5x multiplied damage.

const BattlerDamage := preload("res://systems/battle/battler_damage.gd")
const Helpers := preload("res://tests/helpers/test_helpers.gd")


func test_enemy_crit_chance_base_is_five_percent() -> void:
	var enemy := Helpers.make_enemy_battler({"luck": 0})
	add_child_autofree(enemy)
	var chance := BattlerDamage.compute_crit_chance(enemy.luck)
	assert_almost_eq(chance, 0.05, 0.0001, "Enemy with 0 luck has 5% base crit chance")


func test_enemy_crit_chance_scales_with_luck() -> void:
	var enemy := Helpers.make_enemy_battler({"luck": 10})
	add_child_autofree(enemy)
	var chance := BattlerDamage.compute_crit_chance(enemy.luck)
	assert_almost_eq(chance, 0.10, 0.0001, "Enemy with 10 luck has 10% crit chance")


func test_enemy_crit_chance_formula_matches_spec() -> void:
	# Formula: 5% base + luck * 0.5% per point
	var enemy := Helpers.make_enemy_battler({"luck": 20})
	add_child_autofree(enemy)
	var chance := BattlerDamage.compute_crit_chance(enemy.luck)
	assert_almost_eq(chance, 0.15, 0.0001, "Enemy with 20 luck has 15% crit chance")


func test_enemy_crit_damage_multiplier_is_one_point_five() -> void:
	var enemy := Helpers.make_enemy_battler({})
	add_child_autofree(enemy)
	var base_damage := 100
	var critted := BattlerDamage.apply_crit(base_damage)
	assert_eq(critted, 150, "Enemy crit damage is 1.5x base damage")


func test_higher_luck_enemy_has_higher_crit_chance() -> void:
	var low_luck := Helpers.make_enemy_battler({"luck": 5})
	var high_luck := Helpers.make_enemy_battler({"luck": 15})
	add_child_autofree(low_luck)
	add_child_autofree(high_luck)
	var low_chance := BattlerDamage.compute_crit_chance(low_luck.luck)
	var high_chance := BattlerDamage.compute_crit_chance(high_luck.luck)
	assert_true(high_chance > low_chance, "Higher luck enemy crits more often")


func test_enemy_crit_chance_at_typical_enemy_luck() -> void:
	# Most enemies have luck in the 5-15 range
	var enemy := Helpers.make_enemy_battler({"luck": 5})
	add_child_autofree(enemy)
	var chance := BattlerDamage.compute_crit_chance(enemy.luck)
	assert_almost_eq(chance, 0.075, 0.0001, "Enemy with 5 luck has 7.5% crit chance")

extends GutTest

## Tests for AoE ability targeting and execution logic.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const BAX = preload("res://systems/battle/battle_action_executor.gd")


func test_is_aoe_all_enemies() -> void:
	var ability := Helpers.make_ability({
		"target_type": AbilityData.TargetType.ALL_ENEMIES,
	})
	assert_true(
		BAX.is_aoe(ability),
		"ALL_ENEMIES should be AoE",
	)


func test_is_aoe_all_allies() -> void:
	var ability := Helpers.make_ability({
		"target_type": AbilityData.TargetType.ALL_ALLIES,
	})
	assert_true(
		BAX.is_aoe(ability),
		"ALL_ALLIES should be AoE",
	)


func test_is_not_aoe_single_enemy() -> void:
	var ability := Helpers.make_ability({
		"target_type": AbilityData.TargetType.SINGLE_ENEMY,
	})
	assert_false(
		BAX.is_aoe(ability),
		"SINGLE_ENEMY should not be AoE",
	)


func test_is_not_aoe_single_ally() -> void:
	var ability := Helpers.make_ability({
		"target_type": AbilityData.TargetType.SINGLE_ALLY,
	})
	assert_false(
		BAX.is_aoe(ability),
		"SINGLE_ALLY should not be AoE",
	)


func test_is_not_aoe_self() -> void:
	var ability := Helpers.make_ability({
		"target_type": AbilityData.TargetType.SELF,
	})
	assert_false(
		BAX.is_aoe(ability),
		"SELF should not be AoE",
	)


func test_is_auto_target_self() -> void:
	var ability := Helpers.make_ability({
		"target_type": AbilityData.TargetType.SELF,
	})
	assert_true(
		BAX.is_auto_target(ability),
		"SELF should be auto-target",
	)


func test_is_auto_target_all_enemies() -> void:
	var ability := Helpers.make_ability({
		"target_type": AbilityData.TargetType.ALL_ENEMIES,
	})
	assert_true(
		BAX.is_auto_target(ability),
		"ALL_ENEMIES should be auto-target (no manual selection needed)",
	)


func test_is_not_auto_target_single_enemy() -> void:
	var ability := Helpers.make_ability({
		"target_type": AbilityData.TargetType.SINGLE_ENEMY,
	})
	assert_false(
		BAX.is_auto_target(ability),
		"SINGLE_ENEMY requires manual target selection",
	)

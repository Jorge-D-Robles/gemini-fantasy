extends GutTest

## Tests for heal-targeting: abilities with ally target types should heal,
## not damage. Also tests that BattleActionExecutor correctly detects
## whether an ability is ally-targeted.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const BAX = preload("res://systems/battle/battle_action_executor.gd")


func test_is_ally_target_single_ally() -> void:
	var ability: AbilityData = Helpers.make_ability({
		"target_type": AbilityData.TargetType.SINGLE_ALLY,
	})
	assert_true(BAX.is_ally_target(ability))


func test_is_ally_target_all_allies() -> void:
	var ability: AbilityData = Helpers.make_ability({
		"target_type": AbilityData.TargetType.ALL_ALLIES,
	})
	assert_true(BAX.is_ally_target(ability))


func test_is_ally_target_self() -> void:
	var ability: AbilityData = Helpers.make_ability({
		"target_type": AbilityData.TargetType.SELF,
	})
	assert_true(BAX.is_ally_target(ability))


func test_is_ally_target_false_for_single_enemy() -> void:
	var ability: AbilityData = Helpers.make_ability({
		"target_type": AbilityData.TargetType.SINGLE_ENEMY,
	})
	assert_false(BAX.is_ally_target(ability))


func test_is_ally_target_false_for_all_enemies() -> void:
	var ability: AbilityData = Helpers.make_ability({
		"target_type": AbilityData.TargetType.ALL_ENEMIES,
	})
	assert_false(BAX.is_ally_target(ability))


func test_is_ally_target_null_ability() -> void:
	assert_false(BAX.is_ally_target(null))

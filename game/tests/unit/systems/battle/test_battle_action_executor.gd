extends GutTest

## Tests for BattleActionExecutor — shared attack/ability execution helpers.

const Helpers = preload("res://tests/helpers/test_helpers.gd")
const BAX = preload("res://systems/battle/battle_action_executor.gd")


# ---- try_apply_status ----

func test_try_apply_status_applies_when_chance_is_100() -> void:
	var ability := Helpers.make_ability({
		"status_effect": "poison",
		"status_chance": 1.0,
		"status_effect_duration": 2,
	})
	var target := Helpers.make_battler({"defense": 0})
	add_child_autofree(target)

	BAX.try_apply_status(ability, target, null)

	assert_true(target.has_status(&"poison"), "Status should be applied at 100% chance")


func test_try_apply_status_skips_when_chance_is_zero() -> void:
	var ability := Helpers.make_ability({
		"status_effect": "burn",
		"status_chance": 0.0,
	})
	var target := Helpers.make_battler({"defense": 0})
	add_child_autofree(target)

	BAX.try_apply_status(ability, target, null)

	assert_false(target.has_status(&"burn"), "Status should not be applied at 0% chance")


func test_try_apply_status_skips_when_effect_empty() -> void:
	var ability := Helpers.make_ability({
		"status_effect": "",
		"status_chance": 1.0,
	})
	var target := Helpers.make_battler()
	add_child_autofree(target)

	BAX.try_apply_status(ability, target, null)

	assert_eq(
		target.get_status_effect_list().size(),
		0,
		"No status should be applied when effect name is empty",
	)


func test_try_apply_status_skips_null_target() -> void:
	var ability := Helpers.make_ability({
		"status_effect": "stun",
		"status_chance": 1.0,
	})

	# Should not crash with null target
	BAX.try_apply_status(ability, null, null)

	assert_true(true, "try_apply_status with null target should not crash")


func test_try_apply_status_skips_dead_target() -> void:
	var ability := Helpers.make_ability({
		"status_effect": "poison",
		"status_chance": 1.0,
	})
	var target := Helpers.make_battler()
	add_child_autofree(target)
	target.is_alive = false

	BAX.try_apply_status(ability, target, null)

	assert_false(target.has_status(&"poison"), "Dead targets should not receive status")


func test_try_apply_status_skips_null_ability() -> void:
	var target := Helpers.make_battler()
	add_child_autofree(target)

	# Should not crash with null ability
	BAX.try_apply_status(null, target, null)

	assert_eq(
		target.get_status_effect_list().size(),
		0,
		"No status when ability is null",
	)

extends GutTest

## Tests for BattlerStatus static utility class.

const BStatus = preload("res://systems/battle/battler_status.gd")
const Helpers := preload("res://tests/helpers/test_helpers.gd")


func test_apply_new_effect() -> void:
	var effects: Array[Dictionary] = []
	var eff := Helpers.make_status_effect({"id": &"poison", "duration": 3})
	var result := BStatus.apply(effects, eff)
	assert_eq(result, &"poison", "Should return id for new effect")
	assert_eq(effects.size(), 1, "Should add one entry")


func test_apply_duplicate_refreshes_duration() -> void:
	var effects: Array[Dictionary] = []
	var eff := Helpers.make_status_effect({"id": &"burn", "duration": 3})
	BStatus.apply(effects, eff)
	var eff2 := Helpers.make_status_effect({"id": &"burn", "duration": 5})
	var result := BStatus.apply(effects, eff2)
	assert_eq(result, &"", "Should return empty for refresh")
	assert_eq(effects.size(), 1, "Should not duplicate entry")
	assert_eq(effects[0]["remaining"], 5, "Should refresh duration to new value")


func test_remove_existing() -> void:
	var effects: Array[Dictionary] = []
	var eff := Helpers.make_status_effect({"id": &"stun"})
	BStatus.apply(effects, eff)
	var result := BStatus.remove(effects, &"stun")
	assert_true(result, "Should return true for existing removal")
	assert_eq(effects.size(), 0, "Should be empty after removal")


func test_remove_nonexistent() -> void:
	var effects: Array[Dictionary] = []
	var result := BStatus.remove(effects, &"nonexistent")
	assert_false(result, "Should return false for missing effect")


func test_has_present_and_absent() -> void:
	var effects: Array[Dictionary] = []
	var eff := Helpers.make_status_effect({"id": &"regen"})
	BStatus.apply(effects, eff)
	assert_true(BStatus.has(effects, &"regen"), "Should find present effect")
	assert_false(BStatus.has(effects, &"poison"), "Should not find absent effect")


func test_get_remaining_turns() -> void:
	var effects: Array[Dictionary] = []
	var eff := Helpers.make_status_effect({"id": &"shield", "duration": 4})
	BStatus.apply(effects, eff)
	assert_eq(
		BStatus.get_remaining_turns(effects, &"shield"),
		4,
		"Should return remaining turns",
	)
	assert_eq(
		BStatus.get_remaining_turns(effects, &"missing"),
		-1,
		"Should return -1 for missing effect",
	)


func test_is_action_prevented() -> void:
	var effects: Array[Dictionary] = []
	assert_false(
		BStatus.is_action_prevented(effects),
		"No effects should not prevent action",
	)
	var stun := Helpers.make_status_effect({
		"id": &"stun",
		"prevents_action": true,
	})
	BStatus.apply(effects, stun)
	assert_true(
		BStatus.is_action_prevented(effects),
		"Stun should prevent action",
	)


func test_get_total_modifier_sums_by_stat() -> void:
	var effects: Array[Dictionary] = []
	var buff := Helpers.make_status_effect({
		"id": &"atk_up",
		"attack_modifier": 5,
	})
	var debuff := Helpers.make_status_effect({
		"id": &"atk_down",
		"attack_modifier": -3,
	})
	BStatus.apply(effects, buff)
	BStatus.apply(effects, debuff)
	assert_eq(
		BStatus.get_total_modifier(effects, "attack"),
		2,
		"Should sum attack modifiers (5 + -3 = 2)",
	)
	assert_eq(
		BStatus.get_total_modifier(effects, "defense"),
		0,
		"Unaffected stats should be 0",
	)

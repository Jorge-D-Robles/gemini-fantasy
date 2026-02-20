extends GutTest

## Tests for BanterManager static eligibility helper.
## Verifies that compute_eligible_banters() correctly filters by party,
## flags, location, and one-shot guards.

const BM = preload("res://systems/banter_manager.gd")

## Full conditions for bond_01_knife_lessons:
## - gate: iris_recruited = true
## - party: iris + kael both present
## - location: "verdant_forest"
## - one-shot flag bond_01_knife_lessons NOT set


func test_returns_bond01_when_all_conditions_met() -> void:
	var flags := {"iris_recruited": true}
	var party: Array = ["kael", "iris"]
	var result: Array[String] = BM.compute_eligible_banters(
		party, flags, "verdant_forest",
	)
	assert_true("bond_01_knife_lessons" in result, "bond01 should be eligible")


func test_empty_when_one_shot_flag_already_set() -> void:
	var flags := {"iris_recruited": true, "bond_01_knife_lessons": true}
	var party: Array = ["kael", "iris"]
	var result: Array[String] = BM.compute_eligible_banters(
		party, flags, "verdant_forest",
	)
	assert_false("bond_01_knife_lessons" in result, "bond01 must not replay")


func test_empty_when_gate_flag_missing() -> void:
	var flags: Dictionary = {}
	var party: Array = ["kael", "iris"]
	var result: Array[String] = BM.compute_eligible_banters(
		party, flags, "verdant_forest",
	)
	assert_false("bond_01_knife_lessons" in result, "gate flag required")


func test_empty_when_iris_not_in_party() -> void:
	var flags := {"iris_recruited": true}
	var party: Array = ["kael", "garrick"]
	var result: Array[String] = BM.compute_eligible_banters(
		party, flags, "verdant_forest",
	)
	assert_false("bond_01_knife_lessons" in result, "iris must be in party")


func test_empty_when_kael_not_in_party() -> void:
	var flags := {"iris_recruited": true}
	var party: Array = ["iris", "garrick"]
	var result: Array[String] = BM.compute_eligible_banters(
		party, flags, "verdant_forest",
	)
	assert_false("bond_01_knife_lessons" in result, "kael must be in party")


func test_empty_when_location_mismatch() -> void:
	var flags := {"iris_recruited": true}
	var party: Array = ["kael", "iris"]
	var result: Array[String] = BM.compute_eligible_banters(
		party, flags, "roothollow",
	)
	assert_false("bond_01_knife_lessons" in result, "location must match")


func test_returns_empty_array_when_no_banters_eligible() -> void:
	var flags: Dictionary = {}
	var party: Array = []
	var result: Array[String] = BM.compute_eligible_banters(
		party, flags, "roothollow",
	)
	assert_eq(result.size(), 0, "should be empty when no banters match")


func test_returns_empty_array_for_unknown_location() -> void:
	var flags := {"iris_recruited": true}
	var party: Array = ["kael", "iris"]
	var result: Array[String] = BM.compute_eligible_banters(
		party, flags, "overgrown_ruins",
	)
	assert_eq(result.size(), 0, "no banters registered for overgrown_ruins")

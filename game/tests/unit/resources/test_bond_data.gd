extends GutTest

## Tests for BondData static helpers — pair ID, level computation, combat bonuses.


func test_make_pair_id_alphabetical_order() -> void:
	var pair_id: StringName = BondData.make_pair_id(&"iris", &"kael")
	assert_eq(pair_id, &"iris+kael", "Pair ID should be alphabetical")


func test_make_pair_id_same_result_regardless_of_order() -> void:
	var ab: StringName = BondData.make_pair_id(&"kael", &"iris")
	var ba: StringName = BondData.make_pair_id(&"iris", &"kael")
	assert_eq(ab, ba, "Pair ID must be order-independent")


func test_compute_level_at_zero_is_D() -> void:
	assert_eq(
		BondData.compute_level(0),
		BondData.BondLevel.D,
		"Zero points should be level D",
	)


func test_compute_level_at_threshold_boundaries() -> void:
	assert_eq(
		BondData.compute_level(9),
		BondData.BondLevel.D,
		"9 points should still be D",
	)
	assert_eq(
		BondData.compute_level(10),
		BondData.BondLevel.C,
		"10 points should be C",
	)
	assert_eq(
		BondData.compute_level(25),
		BondData.BondLevel.B,
		"25 points should be B",
	)
	assert_eq(
		BondData.compute_level(50),
		BondData.BondLevel.A,
		"50 points should be A",
	)
	assert_eq(
		BondData.compute_level(80),
		BondData.BondLevel.S,
		"80 points should be S",
	)


func test_compute_level_at_max_points() -> void:
	assert_eq(
		BondData.compute_level(999),
		BondData.BondLevel.S,
		"Very high points should cap at S",
	)


func test_compute_combat_bonus_level_D_no_bonus() -> void:
	var bonus: Dictionary = BondData.compute_combat_bonus(
		BondData.BondLevel.D,
	)
	assert_eq(bonus["damage_bonus"], 0.0, "D-rank has no damage bonus")
	assert_eq(bonus["defense_bonus"], 0.0, "D-rank has no defense bonus")


func test_compute_combat_bonus_level_S_full_bonus() -> void:
	var bonus: Dictionary = BondData.compute_combat_bonus(
		BondData.BondLevel.S,
	)
	assert_almost_eq(
		bonus["damage_bonus"], 0.20, 0.001, "S-rank damage bonus is 20%",
	)
	assert_almost_eq(
		bonus["defense_bonus"], 0.15, 0.001, "S-rank defense bonus is 15%",
	)

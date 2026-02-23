extends GutTest

## Tests for BondManager — bond tracking, point awards, serialization.

const BondManagerScript = preload("res://autoloads/bond_manager.gd")

var _mgr: Node


func before_each() -> void:
	_mgr = BondManagerScript.new()
	add_child_autofree(_mgr)


func test_add_bond_points_increases_points() -> void:
	_mgr.add_bond_points(&"kael", &"iris", 5)
	assert_eq(
		_mgr.get_bond_points(&"kael", &"iris"), 5,
		"Points should increase by 5",
	)
	_mgr.add_bond_points(&"iris", &"kael", 3)
	assert_eq(
		_mgr.get_bond_points(&"kael", &"iris"), 8,
		"Points should accumulate regardless of arg order",
	)


func test_get_bond_level_default_is_D() -> void:
	assert_eq(
		_mgr.get_bond_level(&"kael", &"iris"),
		BondData.BondLevel.D,
		"Default bond level should be D",
	)


func test_get_bond_level_after_points_added() -> void:
	_mgr.add_bond_points(&"kael", &"iris", 25)
	assert_eq(
		_mgr.get_bond_level(&"kael", &"iris"),
		BondData.BondLevel.B,
		"25 points should yield level B",
	)


func test_bond_level_changed_signal_emitted() -> void:
	watch_signals(_mgr)
	_mgr.add_bond_points(&"kael", &"iris", 10)
	assert_signal_emitted(_mgr, "bond_level_changed")


func test_award_battle_bond_points_all_pairs() -> void:
	var party: Array[StringName] = [&"kael", &"iris", &"garrick"]
	_mgr.award_battle_bond_points(party)
	# 3 members = 3 pairs, each +2
	assert_eq(_mgr.get_bond_points(&"kael", &"iris"), 2)
	assert_eq(_mgr.get_bond_points(&"kael", &"garrick"), 2)
	assert_eq(_mgr.get_bond_points(&"garrick", &"iris"), 2)


func test_award_camp_bond_points_all_pairs() -> void:
	var party: Array[StringName] = [&"kael", &"iris"]
	_mgr.award_camp_bond_points(party)
	assert_eq(
		_mgr.get_bond_points(&"kael", &"iris"), 3,
		"Camp awards 3 points per pair",
	)


func test_get_party_combat_bonus_aggregated() -> void:
	# Set kael+iris to C rank (10 pts = +5% damage)
	_mgr.add_bond_points(&"kael", &"iris", 10)
	var bonus: Dictionary = _mgr.get_party_combat_bonus(
		[&"kael", &"iris"] as Array[StringName],
	)
	assert_almost_eq(
		bonus["damage_bonus"], 0.05, 0.001,
		"One C-rank pair should give 5% damage bonus",
	)


func test_get_party_combat_bonus_capped() -> void:
	# Set 3 pairs all to S rank (80 pts each = +20% damage each = 60% total)
	_mgr.add_bond_points(&"kael", &"iris", 80)
	_mgr.add_bond_points(&"kael", &"garrick", 80)
	_mgr.add_bond_points(&"iris", &"garrick", 80)
	var bonus: Dictionary = _mgr.get_party_combat_bonus(
		[&"kael", &"iris", &"garrick"] as Array[StringName],
	)
	assert_almost_eq(
		bonus["damage_bonus"], BondData.MAX_PARTY_DAMAGE_BONUS, 0.001,
		"Damage bonus should be capped at MAX_PARTY_DAMAGE_BONUS",
	)
	assert_almost_eq(
		bonus["defense_bonus"], BondData.MAX_PARTY_DEFENSE_BONUS, 0.001,
		"Defense bonus should be capped at MAX_PARTY_DEFENSE_BONUS",
	)


func test_get_party_combat_bonus_empty_party() -> void:
	var bonus: Dictionary = _mgr.get_party_combat_bonus(
		[] as Array[StringName],
	)
	assert_eq(bonus["damage_bonus"], 0.0, "Empty party has no damage bonus")
	assert_eq(bonus["defense_bonus"], 0.0, "Empty party has no defense bonus")


func test_serialize_round_trip() -> void:
	_mgr.add_bond_points(&"kael", &"iris", 15)
	_mgr.add_bond_points(&"kael", &"garrick", 30)
	var data: Dictionary = _mgr.serialize()
	_mgr.reset_all()
	assert_eq(
		_mgr.get_bond_points(&"kael", &"iris"), 0,
		"After reset, points should be 0",
	)
	_mgr.deserialize(data)
	assert_eq(
		_mgr.get_bond_points(&"kael", &"iris"), 15,
		"After deserialize, points should be restored",
	)
	assert_eq(
		_mgr.get_bond_points(&"kael", &"garrick"), 30,
		"After deserialize, all pairs should be restored",
	)


func test_reset_all_clears_bonds() -> void:
	_mgr.add_bond_points(&"kael", &"iris", 50)
	_mgr.reset_all()
	assert_eq(
		_mgr.get_bond_points(&"kael", &"iris"), 0,
		"reset_all should clear all bond points",
	)
	assert_eq(
		_mgr.get_bond_level(&"kael", &"iris"),
		BondData.BondLevel.D,
		"reset_all should reset level to D",
	)

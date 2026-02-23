extends GutTest

## Tests for ReputationManager — faction reputation tracking, tiers, pricing,
## serialization, and validation.
## Creates a fresh instance per test — never touches the global singleton.

var _rep: Node


func before_each() -> void:
	_rep = load("res://autoloads/reputation_manager.gd").new()
	add_child_autofree(_rep)


# ---- Initial state ----

func test_initial_reputation_is_zero() -> void:
	assert_eq(_rep.get_reputation(&"shepherds"), 0)
	assert_eq(_rep.get_reputation(&"initiative"), 0)
	assert_eq(_rep.get_reputation(&"free_resonants"), 0)


# ---- add_reputation ----

func test_add_reputation_positive() -> void:
	_rep.add_reputation(&"shepherds", 25)
	assert_eq(_rep.get_reputation(&"shepherds"), 25)


func test_add_reputation_negative() -> void:
	_rep.add_reputation(&"initiative", -30)
	assert_eq(_rep.get_reputation(&"initiative"), -30)


func test_reputation_clamped_at_upper_bound() -> void:
	_rep.add_reputation(&"free_resonants", 200)
	assert_eq(
		_rep.get_reputation(&"free_resonants"), 100,
		"Reputation must not exceed 100",
	)


func test_reputation_clamped_at_lower_bound() -> void:
	_rep.add_reputation(&"shepherds", -200)
	assert_eq(
		_rep.get_reputation(&"shepherds"), -100,
		"Reputation must not go below -100",
	)


func test_set_reputation_overrides() -> void:
	_rep.add_reputation(&"initiative", 50)
	_rep.set_reputation(&"initiative", -20)
	assert_eq(_rep.get_reputation(&"initiative"), -20)


func test_add_zero_is_no_op_no_signal() -> void:
	watch_signals(_rep)
	_rep.add_reputation(&"shepherds", 0)
	assert_eq(_rep.get_reputation(&"shepherds"), 0)
	assert_signal_not_emitted(_rep, "reputation_changed")


# ---- compute_tier — boundary tests ----

func test_compute_tier_at_minus_100_is_hostile() -> void:
	assert_eq(_rep.compute_tier(-100), _rep.Tier.HOSTILE)


func test_compute_tier_at_minus_50_is_hostile() -> void:
	assert_eq(_rep.compute_tier(-50), _rep.Tier.HOSTILE)


func test_compute_tier_at_minus_49_is_unfriendly() -> void:
	assert_eq(_rep.compute_tier(-49), _rep.Tier.UNFRIENDLY)


func test_compute_tier_at_minus_10_is_unfriendly() -> void:
	assert_eq(_rep.compute_tier(-10), _rep.Tier.UNFRIENDLY)


func test_compute_tier_at_minus_9_is_neutral() -> void:
	assert_eq(_rep.compute_tier(-9), _rep.Tier.NEUTRAL)


func test_compute_tier_at_9_is_neutral() -> void:
	assert_eq(_rep.compute_tier(9), _rep.Tier.NEUTRAL)


func test_compute_tier_at_10_is_friendly() -> void:
	assert_eq(_rep.compute_tier(10), _rep.Tier.FRIENDLY)


func test_compute_tier_at_49_is_friendly() -> void:
	assert_eq(_rep.compute_tier(49), _rep.Tier.FRIENDLY)


func test_compute_tier_at_50_is_allied() -> void:
	assert_eq(_rep.compute_tier(50), _rep.Tier.ALLIED)


func test_compute_tier_at_100_is_allied() -> void:
	assert_eq(_rep.compute_tier(100), _rep.Tier.ALLIED)


# ---- compute_price_modifier ----

func test_compute_price_modifier_all_tiers() -> void:
	assert_almost_eq(
		_rep.compute_price_modifier(_rep.Tier.HOSTILE), 1.5, 0.001,
	)
	assert_almost_eq(
		_rep.compute_price_modifier(_rep.Tier.UNFRIENDLY), 1.2, 0.001,
	)
	assert_almost_eq(
		_rep.compute_price_modifier(_rep.Tier.NEUTRAL), 1.0, 0.001,
	)
	assert_almost_eq(
		_rep.compute_price_modifier(_rep.Tier.FRIENDLY), 0.9, 0.001,
	)
	assert_almost_eq(
		_rep.compute_price_modifier(_rep.Tier.ALLIED), 0.8, 0.001,
	)


# ---- has_tier ----

func test_has_tier_true_when_meets_minimum() -> void:
	_rep.set_reputation(&"shepherds", 25)
	assert_true(
		_rep.has_tier(&"shepherds", _rep.Tier.NEUTRAL),
		"FRIENDLY should meet minimum NEUTRAL",
	)


func test_has_tier_false_when_below_minimum() -> void:
	_rep.set_reputation(&"shepherds", 0)
	assert_false(
		_rep.has_tier(&"shepherds", _rep.Tier.FRIENDLY),
		"NEUTRAL should not meet minimum FRIENDLY",
	)


# ---- Signal emission ----

func test_reputation_changed_signal_emitted() -> void:
	watch_signals(_rep)
	_rep.add_reputation(&"initiative", 15)
	assert_signal_emitted(_rep, "reputation_changed")


func test_reset_all_emits_signals_for_nonzero() -> void:
	_rep.set_reputation(&"shepherds", 30)
	_rep.set_reputation(&"initiative", -20)
	# free_resonants stays at 0
	watch_signals(_rep)
	_rep.reset_all()
	assert_signal_emit_count(_rep, "reputation_changed", 2)


func test_reset_all_no_signal_for_zero_factions() -> void:
	# All at 0 — no signals expected
	watch_signals(_rep)
	_rep.reset_all()
	assert_signal_not_emitted(_rep, "reputation_changed")


# ---- Serialization ----

func test_serialize_round_trip() -> void:
	_rep.set_reputation(&"shepherds", 40)
	_rep.set_reputation(&"initiative", -60)
	_rep.set_reputation(&"free_resonants", 80)
	var data: Dictionary = _rep.serialize()
	# Reset state to prove deserialize restores it
	_rep.reset_all()
	assert_eq(_rep.get_reputation(&"shepherds"), 0)
	_rep.deserialize(data)
	assert_eq(_rep.get_reputation(&"shepherds"), 40)
	assert_eq(_rep.get_reputation(&"initiative"), -60)
	assert_eq(_rep.get_reputation(&"free_resonants"), 80)


func test_deserialize_missing_key_defaults_to_zero() -> void:
	_rep.set_reputation(&"shepherds", 50)
	# Deserialize a dict missing shepherds key
	_rep.deserialize({"initiative": 10})
	assert_eq(
		_rep.get_reputation(&"shepherds"), 0,
		"Missing faction key should default to 0",
	)
	assert_eq(_rep.get_reputation(&"initiative"), 10)


func test_deserialize_out_of_range_clamped() -> void:
	_rep.deserialize({"shepherds": 999, "initiative": -500})
	assert_eq(
		_rep.get_reputation(&"shepherds"), 100,
		"Out-of-range high value should clamp to 100",
	)
	assert_eq(
		_rep.get_reputation(&"initiative"), -100,
		"Out-of-range low value should clamp to -100",
	)


# ---- Validation ----

func test_add_reputation_unknown_faction_is_no_op() -> void:
	watch_signals(_rep)
	_rep.add_reputation(&"bogus_faction", 10)
	assert_signal_not_emitted(_rep, "reputation_changed")


func test_set_reputation_unknown_faction_is_no_op() -> void:
	watch_signals(_rep)
	_rep.set_reputation(&"bogus_faction", 50)
	assert_signal_not_emitted(_rep, "reputation_changed")


func test_get_all_reputations_returns_copy() -> void:
	_rep.set_reputation(&"shepherds", 30)
	var all: Dictionary = _rep.get_all_reputations()
	assert_eq(all.size(), 3)
	assert_eq(all[&"shepherds"], 30)
	# Mutating the copy should not affect internal state
	all[&"shepherds"] = 99
	assert_eq(
		_rep.get_reputation(&"shepherds"), 30,
		"get_all_reputations must return a copy",
	)

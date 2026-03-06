# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Limit Break system:
## AbilityData.is_limit_break flag + CharacterData.limit_break field
## + 4 Limit Break ability .tres files (Kael, Iris, Garrick, Nyx).

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _kael_lb: AbilityData
var _iris_lb: AbilityData
var _garrick_lb: AbilityData
var _nyx_lb: AbilityData


func before_each() -> void:
	_kael_lb = load(
		"res://data/abilities/fragments_of_infinity.tres"
	)
	_iris_lb = load(
		"res://data/abilities/phoenix_protocol.tres"
	)
	_garrick_lb = load(
		"res://data/abilities/shield_of_the_fallen.tres"
	)
	_nyx_lb = load(
		"res://data/abilities/birth_of_the_new.tres"
	)


# --- AbilityData.is_limit_break ---


func test_ability_data_is_limit_break_default_false() -> void:
	var ability := Helpers.make_ability({})
	assert_false(
		ability.is_limit_break,
		"Default ability should not be a limit break",
	)


func test_ability_data_is_limit_break_settable() -> void:
	var ability := Helpers.make_ability({})
	ability.is_limit_break = true
	assert_true(
		ability.is_limit_break,
		"is_limit_break should be settable to true",
	)


# --- CharacterData.limit_break ---


func test_character_data_has_limit_break_field() -> void:
	var character := CharacterData.new()
	assert_null(
		character.limit_break,
		"Default limit_break should be null",
	)


func test_character_data_limit_break_assignable() -> void:
	var character := CharacterData.new()
	var ability := Helpers.make_ability(
		{"id": &"test_limit", "display_name": "Test LB"}
	)
	ability.is_limit_break = true
	character.limit_break = ability
	assert_eq(
		character.limit_break.id,
		&"test_limit",
		"Limit break should be assignable",
	)


# --- Kael: Fragments of Infinity ---


func test_kael_lb_exists() -> void:
	assert_not_null(_kael_lb, "Kael LB .tres should exist")


func test_kael_lb_is_limit_break() -> void:
	assert_true(_kael_lb.is_limit_break, "Should be a LB")


func test_kael_lb_identity() -> void:
	assert_eq(_kael_lb.id, &"fragments_of_infinity")
	assert_eq(_kael_lb.display_name, "Fragments of Infinity")


func test_kael_lb_costs_full_resonance() -> void:
	assert_eq(
		_kael_lb.resonance_cost, 100.0,
		"Should cost 100% resonance",
	)


func test_kael_lb_targets_all_enemies() -> void:
	assert_eq(
		_kael_lb.target_type,
		AbilityData.TargetType.ALL_ENEMIES,
	)


# --- Iris: Phoenix Protocol ---


func test_iris_lb_exists() -> void:
	assert_not_null(_iris_lb, "Iris LB .tres should exist")


func test_iris_lb_is_limit_break() -> void:
	assert_true(_iris_lb.is_limit_break, "Should be a LB")


func test_iris_lb_identity() -> void:
	assert_eq(_iris_lb.id, &"phoenix_protocol")
	assert_eq(_iris_lb.display_name, "Phoenix Protocol")


func test_iris_lb_targets_self() -> void:
	assert_eq(
		_iris_lb.target_type, AbilityData.TargetType.SELF,
	)


# --- Garrick: Shield of the Fallen ---


func test_garrick_lb_exists() -> void:
	assert_not_null(
		_garrick_lb, "Garrick LB .tres should exist",
	)


func test_garrick_lb_is_limit_break() -> void:
	assert_true(
		_garrick_lb.is_limit_break, "Should be a LB",
	)


func test_garrick_lb_identity() -> void:
	assert_eq(_garrick_lb.id, &"shield_of_the_fallen")
	assert_eq(
		_garrick_lb.display_name, "Shield of the Fallen",
	)


func test_garrick_lb_targets_all_allies() -> void:
	assert_eq(
		_garrick_lb.target_type,
		AbilityData.TargetType.ALL_ALLIES,
	)


# --- Nyx: Birth of the New ---


func test_nyx_lb_exists() -> void:
	assert_not_null(_nyx_lb, "Nyx LB .tres should exist")


func test_nyx_lb_is_limit_break() -> void:
	assert_true(_nyx_lb.is_limit_break, "Should be a LB")


func test_nyx_lb_identity() -> void:
	assert_eq(_nyx_lb.id, &"birth_of_the_new")
	assert_eq(_nyx_lb.display_name, "Birth of the New")


func test_nyx_lb_targets_all_enemies() -> void:
	assert_eq(
		_nyx_lb.target_type,
		AbilityData.TargetType.ALL_ENEMIES,
	)


# --- Cross-checks ---


func test_all_limit_breaks_cost_full_resonance() -> void:
	for lb in [_kael_lb, _iris_lb, _garrick_lb, _nyx_lb]:
		assert_eq(
			lb.resonance_cost, 100.0,
			"%s should cost 100%% resonance" % lb.id,
		)


func test_all_limit_breaks_flagged() -> void:
	for lb in [_kael_lb, _iris_lb, _garrick_lb, _nyx_lb]:
		assert_true(
			lb.is_limit_break,
			"%s should be flagged as limit break" % lb.id,
		)

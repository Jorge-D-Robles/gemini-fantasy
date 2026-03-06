extends GutTest

## Tests for Resonance Tuning system:
## EquipmentData tuning_slots, tuned_echoes, and helper methods.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _equipment: EquipmentData
var _echo: EchoData


func before_each() -> void:
	_equipment = Helpers.make_equipment({"tuning_slots": 2})
	_echo = EchoData.new()
	_echo.id = &"test_echo"
	_echo.display_name = "Test Echo"


# --- Default state ---


func test_tuning_slots_default_zero() -> void:
	var eq := EquipmentData.new()
	assert_eq(eq.tuning_slots, 0, "Default should be 0 slots")


func test_tuned_echoes_default_empty() -> void:
	var eq := EquipmentData.new()
	assert_eq(
		eq.tuned_echoes.size(), 0,
		"Default should have no tuned echoes",
	)


# --- can_tune() ---


func test_can_tune_when_slots_available() -> void:
	assert_true(
		_equipment.can_tune(),
		"Should be able to tune with empty slots",
	)


func test_cannot_tune_when_full() -> void:
	_equipment.tuning_slots = 1
	_equipment.tune_echo(_echo)
	assert_false(
		_equipment.can_tune(),
		"Should not tune when slots are full",
	)


func test_cannot_tune_zero_slots() -> void:
	_equipment.tuning_slots = 0
	assert_false(
		_equipment.can_tune(),
		"Should not tune equipment with 0 slots",
	)


# --- tune_echo() ---


func test_tune_echo_success() -> void:
	var result := _equipment.tune_echo(_echo)
	assert_true(result, "Should return true on success")
	assert_eq(_equipment.tuned_echoes.size(), 1)


func test_tune_echo_fails_when_full() -> void:
	_equipment.tuning_slots = 1
	_equipment.tune_echo(_echo)
	var echo2 := EchoData.new()
	echo2.id = &"test_echo_2"
	var result := _equipment.tune_echo(echo2)
	assert_false(result, "Should return false when full")
	assert_eq(_equipment.tuned_echoes.size(), 1)


func test_tune_multiple_echoes() -> void:
	var echo2 := EchoData.new()
	echo2.id = &"test_echo_2"
	_equipment.tune_echo(_echo)
	_equipment.tune_echo(echo2)
	assert_eq(_equipment.tuned_echoes.size(), 2)


# --- replace_echo() ---


func test_replace_echo_returns_old() -> void:
	_equipment.tune_echo(_echo)
	var new_echo := EchoData.new()
	new_echo.id = &"replacement"
	var old := _equipment.replace_echo(0, new_echo)
	assert_eq(old, _echo, "Should return the old echo")
	assert_eq(
		_equipment.tuned_echoes[0], new_echo,
		"Slot should have new echo",
	)


func test_replace_echo_invalid_index() -> void:
	var result := _equipment.replace_echo(5, _echo)
	assert_null(result, "Invalid index should return null")


func test_replace_echo_negative_index() -> void:
	var result := _equipment.replace_echo(-1, _echo)
	assert_null(result, "Negative index should return null")


# --- remove_echo() ---


func test_remove_echo_returns_removed() -> void:
	_equipment.tune_echo(_echo)
	var removed := _equipment.remove_echo(0)
	assert_eq(removed, _echo, "Should return the removed echo")
	assert_eq(_equipment.tuned_echoes.size(), 0)


func test_remove_echo_invalid_index() -> void:
	var result := _equipment.remove_echo(3)
	assert_null(result, "Invalid index should return null")


# --- Slot limits ---


func test_tuning_slots_range() -> void:
	for slots in [0, 1, 2, 3]:
		_equipment.tuning_slots = slots
		assert_eq(
			_equipment.tuning_slots, slots,
			"Should accept %d slots" % slots,
		)

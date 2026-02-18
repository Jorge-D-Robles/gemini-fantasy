extends GutTest

## Tests for BossEncounter event script.
## Verifies structure, constants, and signal contract.

var _encounter: Node


func before_each() -> void:
	_encounter = load("res://events/boss_encounter.gd").new()
	add_child_autofree(_encounter)


func test_flag_name_is_boss_defeated() -> void:
	assert_eq(_encounter.FLAG_NAME, "boss_defeated")


func test_last_gardener_path_constant() -> void:
	assert_eq(
		_encounter.LAST_GARDENER_PATH,
		"res://data/enemies/last_gardener.tres",
	)


func test_has_sequence_completed_signal() -> void:
	assert_true(_encounter.has_signal("sequence_completed"))


func test_has_trigger_method() -> void:
	assert_true(_encounter.has_method("trigger"))

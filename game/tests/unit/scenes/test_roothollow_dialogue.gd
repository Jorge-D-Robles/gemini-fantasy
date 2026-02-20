# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Roothollow NPC dialogue — flag routing and slang invariants.
## Verifies that flag state changes dialogue selection and that
## regional slang rules are respected across all flag states.

var _rh: GDScript


func before_each() -> void:
	_rh = load("res://scenes/roothollow/roothollow_dialogue.gd")


func _flags(names: Array = []) -> Dictionary:
	var d := {}
	for n in names:
		d[n] = true
	return d


func _any_line_contains(
	lines: PackedStringArray,
	substring: String,
) -> bool:
	for line in lines:
		if line.contains(substring):
			return true
	return false


func _has_tangle_slang(lines: PackedStringArray) -> bool:
	return (
		_any_line_contains(lines, "root deep")
		or _any_line_contains(lines, "overgrown")
		or _any_line_contains(lines, "memory bloom")
	)


# --- Flag routing: dialogue changes with flags ---

func test_maren_flag_priority_garrick_over_iris() -> void:
	var with_garrick: PackedStringArray = _rh.get_maren_dialogue(
		_flags([
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		])
	)
	var with_iris: PackedStringArray = _rh.get_maren_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_ne(with_garrick[0], with_iris[0])


func test_bram_flag_priority_iris_over_lyra() -> void:
	var with_iris: PackedStringArray = _rh.get_bram_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	var with_lyra: PackedStringArray = _rh.get_bram_dialogue(
		_flags(["opening_lyra_discovered"])
	)
	assert_ne(with_iris[0], with_lyra[0])


func test_maren_changes_per_flag_state() -> void:
	var default_lines := _rh.get_maren_dialogue(_flags())
	var lyra_lines := _rh.get_maren_dialogue(_flags(["opening_lyra_discovered"]))
	var iris_lines := _rh.get_maren_dialogue(
		_flags(["opening_lyra_discovered", "iris_recruited"])
	)
	assert_ne(default_lines[0], lyra_lines[0])
	assert_ne(lyra_lines[0], iris_lines[0])


func test_wren_changes_per_flag_state() -> void:
	var default_lines := _rh.get_wren_dialogue(_flags())
	var lyra_lines := _rh.get_wren_dialogue(_flags(["opening_lyra_discovered"]))
	assert_ne(default_lines[0], lyra_lines[0])


# --- Regional slang invariants ---

func test_maren_uses_tangle_slang() -> void:
	var states: Array[Array] = [
		[],
		["opening_lyra_discovered"],
		["opening_lyra_discovered", "iris_recruited"],
		[
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		],
	]
	for state in states:
		var lines: PackedStringArray = _rh.get_maren_dialogue(
			_flags(state)
		)
		assert_true(
			_has_tangle_slang(lines),
			"Maren should use Tangle slang in state: %s" % [
				str(state),
			],
		)


func test_bram_uses_tangle_slang() -> void:
	var states: Array[Array] = [
		[],
		["opening_lyra_discovered"],
		["opening_lyra_discovered", "iris_recruited"],
		[
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		],
	]
	for state in states:
		var lines: PackedStringArray = _rh.get_bram_dialogue(
			_flags(state)
		)
		assert_true(
			_has_tangle_slang(lines),
			"Bram should use Tangle slang in state: %s" % [
				str(state),
			],
		)


func test_thessa_uses_tangle_slang() -> void:
	var states: Array[Array] = [
		[],
		["opening_lyra_discovered"],
		["opening_lyra_discovered", "iris_recruited"],
		[
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		],
	]
	for state in states:
		var lines: PackedStringArray = _rh.get_thessa_dialogue(
			_flags(state)
		)
		assert_true(
			_has_tangle_slang(lines),
			"Thessa should use Tangle slang in state: %s" % [
				str(state),
			],
		)


func test_wren_uses_tangle_slang() -> void:
	var states: Array[Array] = [
		[],
		["opening_lyra_discovered"],
		["opening_lyra_discovered", "iris_recruited"],
		[
			"opening_lyra_discovered",
			"iris_recruited",
			"garrick_recruited",
		],
	]
	for state in states:
		var lines: PackedStringArray = _rh.get_wren_dialogue(
			_flags(state)
		)
		assert_true(
			_has_tangle_slang(lines),
			"Wren should use Tangle slang in state: %s" % [
				str(state),
			],
		)


func test_garrick_uses_fire_metaphor() -> void:
	var lines: PackedStringArray = (
		_rh.get_garrick_casual_dialogue(_flags())
	)
	assert_true(
		_any_line_contains(lines, "burned")
		or _any_line_contains(lines, "fire")
		or _any_line_contains(lines, "ash"),
		"Garrick should use fire/ash metaphor",
	)


func test_garrick_no_tangle_slang() -> void:
	var default_lines: PackedStringArray = (
		_rh.get_garrick_casual_dialogue(_flags())
	)
	var lyra_lines: PackedStringArray = (
		_rh.get_garrick_casual_dialogue(
			_flags(["opening_lyra_discovered"])
		)
	)
	assert_false(
		_has_tangle_slang(default_lines),
		"Garrick should not use Tangle slang (default)",
	)
	assert_false(
		_has_tangle_slang(lyra_lines),
		"Garrick should not use Tangle slang (lyra)",
	)


# --- Briefing and arrival scenes ---

func test_iris_arrival_flag_name_not_empty() -> void:
	var flag: String = _rh.get_iris_arrival_flag()
	assert_false(flag.is_empty(), "Arrival flag must not be empty")


func test_thessa_briefing_flag_not_empty() -> void:
	var flag: String = _rh.get_thessa_briefing_flag()
	assert_false(flag.is_empty(), "Briefing flag must not be empty")


func test_iris_arrival_returns_array() -> void:
	var lines: Array = _rh.get_iris_arrival_lines()
	assert_gt(lines.size(), 0, "Should have arrival dialogue lines")


func test_thessa_briefing_returns_array() -> void:
	var lines: Array = _rh.get_thessa_briefing_lines()
	assert_gt(lines.size(), 0, "Should have briefing dialogue lines")

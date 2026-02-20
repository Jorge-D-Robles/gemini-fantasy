extends GutTest

## Tests for Roothollow spring shrine zone trigger logic.
## The Garrick recruitment zone fires only after the correct
## flag sequence: lyra discovered → iris recruited → not yet garrick.
## Uses static helpers from roothollow.gd for pure testability.

var _rh: GDScript


func before_each() -> void:
	_rh = load("res://scenes/roothollow/roothollow_zone.gd")


func _flags(names: Array = []) -> Dictionary:
	var d: Dictionary = {}
	for n: String in names:
		d[n] = true
	return d


# -- compute_garrick_zone_can_trigger --

func test_garrick_zone_blocked_with_no_flags() -> void:
	assert_false(
		_rh.compute_garrick_zone_can_trigger(_flags()),
		"Zone should not trigger with no flags set",
	)


func test_garrick_zone_requires_iris_recruited() -> void:
	var flags: Dictionary = _flags(["opening_lyra_discovered"])
	assert_false(
		_rh.compute_garrick_zone_can_trigger(flags),
		"Zone should not trigger without iris_recruited",
	)


func test_garrick_zone_requires_lyra_discovered() -> void:
	var flags: Dictionary = _flags(["iris_recruited"])
	assert_false(
		_rh.compute_garrick_zone_can_trigger(flags),
		"Zone should not trigger without opening_lyra_discovered",
	)


func test_garrick_zone_allows_with_both_flags() -> void:
	var flags: Dictionary = _flags(
		["opening_lyra_discovered", "iris_recruited"]
	)
	assert_true(
		_rh.compute_garrick_zone_can_trigger(flags),
		"Zone should trigger when both prerequisite flags are set",
	)


func test_garrick_zone_blocked_if_already_recruited() -> void:
	var flags: Dictionary = _flags([
		"opening_lyra_discovered",
		"iris_recruited",
		"garrick_recruited",
	])
	assert_false(
		_rh.compute_garrick_zone_can_trigger(flags),
		"Zone should not trigger if garrick already recruited",
	)


# -- compute_shrine_marker_visible --

func test_shrine_marker_hidden_with_no_flags() -> void:
	assert_false(
		_rh.compute_shrine_marker_visible(_flags()),
		"Shrine marker should be hidden before any flags set",
	)


func test_shrine_marker_visible_when_iris_recruited() -> void:
	var flags: Dictionary = _flags(
		["opening_lyra_discovered", "iris_recruited"]
	)
	assert_true(
		_rh.compute_shrine_marker_visible(flags),
		"Shrine marker should be visible after iris_recruited",
	)


func test_shrine_marker_hidden_after_garrick_recruited() -> void:
	var flags: Dictionary = _flags([
		"opening_lyra_discovered",
		"iris_recruited",
		"garrick_recruited",
	])
	assert_false(
		_rh.compute_shrine_marker_visible(flags),
		"Shrine marker should hide once Garrick is recruited",
	)

extends GutTest

## Tests for EchoManager — core echo collection system (T-0182).
## All tests load a fresh instance to avoid cross-test state pollution.

const EchoManagerScript = preload("res://autoloads/echo_manager.gd")

var _mgr: Node


func before_each() -> void:
	_mgr = EchoManagerScript.new()
	add_child_autofree(_mgr)


# -- collect_echo / has_echo --


func test_collect_echo_adds_to_collection() -> void:
	_mgr.collect_echo(&"burning_village")
	assert_true(
		_mgr.has_echo(&"burning_village"),
		"burning_village should be collected after collect_echo()",
	)


func test_has_echo_false_when_not_collected() -> void:
	assert_false(
		_mgr.has_echo(&"burning_village"),
		"has_echo should return false for uncollected echo",
	)


func test_collect_echo_duplicate_not_counted_twice() -> void:
	_mgr.collect_echo(&"childs_laughter")
	_mgr.collect_echo(&"childs_laughter")
	assert_eq(
		_mgr.get_echo_count(),
		1,
		"Collecting same echo twice should not increase count beyond 1",
	)


func test_collect_multiple_echoes_tracked_independently() -> void:
	_mgr.collect_echo(&"burning_village")
	_mgr.collect_echo(&"childs_laughter")
	assert_true(_mgr.has_echo(&"burning_village"), "burning_village should be collected")
	assert_true(_mgr.has_echo(&"childs_laughter"), "childs_laughter should be collected")


# -- get_collected_echoes / get_echo_count --


func test_get_collected_echoes_empty_initially() -> void:
	var collected: Array[StringName] = _mgr.get_collected_echoes()
	assert_eq(collected.size(), 0, "No echoes collected initially")


func test_get_collected_echoes_returns_all_collected() -> void:
	_mgr.collect_echo(&"burning_village")
	_mgr.collect_echo(&"soldiers_fear")
	var collected: Array[StringName] = _mgr.get_collected_echoes()
	assert_eq(collected.size(), 2, "get_collected_echoes should return 2 entries")


func test_get_echo_count_zero_initially() -> void:
	assert_eq(_mgr.get_echo_count(), 0, "Echo count should start at 0")


func test_get_echo_count_increments_on_collect() -> void:
	_mgr.collect_echo(&"burning_village")
	_mgr.collect_echo(&"childs_laughter")
	assert_eq(_mgr.get_echo_count(), 2, "Echo count should be 2 after two collects")


# -- compute_echo_count static --


func test_compute_echo_count_empty_array() -> void:
	var empty: Array[StringName] = []
	assert_eq(
		EchoManagerScript.compute_echo_count(empty),
		0,
		"compute_echo_count([]) should return 0",
	)


func test_compute_echo_count_returns_array_size() -> void:
	var ids: Array[StringName] = [&"burning_village", &"childs_laughter"]
	assert_eq(
		EchoManagerScript.compute_echo_count(ids),
		2,
		"compute_echo_count should return array size",
	)


# -- serialize / deserialize --


func test_serialize_returns_dict_with_echoes_key() -> void:
	var data: Dictionary = _mgr.serialize()
	assert_true(data.has("echoes"), "serialize() must return dict with 'echoes' key")


func test_serialize_echoes_are_strings() -> void:
	_mgr.collect_echo(&"burning_village")
	var data: Dictionary = _mgr.serialize()
	var echoes: Array = data["echoes"]
	for entry in echoes:
		assert_true(
			entry is String,
			"Each serialized echo entry must be a String",
		)


func test_deserialize_restores_collection() -> void:
	var data: Dictionary = {"echoes": ["burning_village", "childs_laughter"]}
	_mgr.deserialize(data)
	assert_true(_mgr.has_echo(&"burning_village"), "burning_village should be restored")
	assert_true(_mgr.has_echo(&"childs_laughter"), "childs_laughter should be restored")
	assert_eq(_mgr.get_echo_count(), 2, "Echo count should be 2 after deserialize")


func test_serialize_deserialize_round_trip() -> void:
	_mgr.collect_echo(&"burning_village")
	_mgr.collect_echo(&"soldiers_fear")
	var data: Dictionary = _mgr.serialize()

	var mgr2: Node = EchoManagerScript.new()
	add_child_autofree(mgr2)
	mgr2.deserialize(data)
	assert_true(mgr2.has_echo(&"burning_village"), "burning_village survives round-trip")
	assert_true(mgr2.has_echo(&"soldiers_fear"), "soldiers_fear survives round-trip")
	assert_eq(mgr2.get_echo_count(), 2, "Count matches after round-trip")


# -- echo_collected signal --


func test_echo_collected_signal_emitted_on_first_collect() -> void:
	watch_signals(_mgr)
	_mgr.collect_echo(&"burning_village")
	assert_signal_emitted(_mgr, "echo_collected")


func test_echo_collected_signal_not_emitted_on_duplicate() -> void:
	_mgr.collect_echo(&"burning_village")
	watch_signals(_mgr)
	_mgr.collect_echo(&"burning_village")
	assert_signal_not_emitted(_mgr, "echo_collected")

extends GutTest

## Tests for T-0189: EchoManager wiring in SaveManager call sites.
## Verifies that save/load round-trips include echo state when echo_mgr is passed,
## and that omitting echo_mgr drops echo data (documenting why wiring matters).

const SaveManagerScript := preload("res://autoloads/save_manager.gd")
const EchoManagerScript := preload("res://autoloads/echo_manager.gd")
const PartyManagerScript := preload("res://autoloads/party_manager.gd")
const InventoryManagerScript := preload("res://autoloads/inventory_manager.gd")
const EventFlagsScript := preload("res://events/event_flags.gd")

var _save_mgr: Node
var _echo_mgr: Node
var _party_mgr: Node
var _inv_mgr: Node
var _flags: Node


func before_each() -> void:
	_save_mgr = SaveManagerScript.new()
	add_child_autofree(_save_mgr)
	_echo_mgr = EchoManagerScript.new()
	add_child_autofree(_echo_mgr)
	_party_mgr = PartyManagerScript.new()
	add_child_autofree(_party_mgr)
	_inv_mgr = InventoryManagerScript.new()
	add_child_autofree(_inv_mgr)
	_flags = EventFlagsScript.new()
	add_child_autofree(_flags)


func test_gather_save_data_with_echo_mgr_includes_echoes_save_key() -> void:
	_echo_mgr.collect_echo(&"roots_memory")
	var data: Dictionary = _save_mgr.gather_save_data(
		_party_mgr, _inv_mgr, _flags,
		"res://scenes/roothollow/roothollow.tscn", Vector2.ZERO,
		null, null, 0.0, _echo_mgr,
	)
	assert_true(
		data.has("echoes_save"),
		"gather_save_data must include 'echoes_save' key when echo_mgr is passed",
	)


func test_gather_save_data_without_echo_mgr_excludes_echoes_save_key() -> void:
	var data: Dictionary = _save_mgr.gather_save_data(
		_party_mgr, _inv_mgr, _flags,
		"res://scenes/roothollow/roothollow.tscn", Vector2.ZERO,
	)
	assert_false(
		data.has("echoes_save"),
		"gather_save_data must NOT include 'echoes_save' key when echo_mgr is null",
	)


func test_apply_save_data_with_echo_mgr_restores_collected_echoes() -> void:
	_echo_mgr.collect_echo(&"village_flame")
	_echo_mgr.collect_echo(&"soldiers_fear")
	var data: Dictionary = _save_mgr.gather_save_data(
		_party_mgr, _inv_mgr, _flags,
		"res://scenes/roothollow/roothollow.tscn", Vector2.ZERO,
		null, null, 0.0, _echo_mgr,
	)
	var fresh_echo_mgr: Node = EchoManagerScript.new()
	add_child_autofree(fresh_echo_mgr)
	_save_mgr.apply_save_data(
		data, _party_mgr, _inv_mgr, _flags,
		null, null, fresh_echo_mgr,
	)
	assert_eq(
		fresh_echo_mgr.get_echo_count(), 2,
		"apply_save_data must restore all collected echoes when echo_mgr is passed",
	)

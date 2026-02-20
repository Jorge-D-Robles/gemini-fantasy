extends GutTest

## Tests for party_ui.gd signal wiring: party_changed and party_state_changed
## must connect on open() and disconnect on close() so the UI stays fresh
## without leaking connections after the screen is dismissed.

const PartyUIScript = preload("res://ui/party_ui/party_ui.gd")


## Minimal mock that exposes the same signals as PartyManager.
class MockPM:
	extends Node

	signal party_changed
	signal party_state_changed

	func get_active_party() -> Array:
		return []

	func get_roster() -> Array:
		return []

	func is_in_party(_m: Resource) -> bool:
		return false


var _mock_pm: MockPM
var _ui: Control


func before_each() -> void:
	_mock_pm = MockPM.new()
	add_child_autofree(_mock_pm)
	_ui = PartyUIScript.new()
	add_child_autofree(_ui)
	# Inject mock after _ready() runs (which would otherwise call get_node_or_null)
	_ui._pm = _mock_pm


func test_connect_wires_party_changed() -> void:
	_ui._connect_party_signals()
	assert_true(
		_mock_pm.party_changed.is_connected(_ui._on_party_changed),
		"_connect_party_signals() should connect party_changed to _on_party_changed",
	)


func test_connect_wires_party_state_changed() -> void:
	_ui._connect_party_signals()
	assert_true(
		_mock_pm.party_state_changed.is_connected(_ui._on_party_changed),
		"_connect_party_signals() should connect party_state_changed to _on_party_changed",
	)


func test_disconnect_unwires_party_changed() -> void:
	_ui._connect_party_signals()
	_ui._disconnect_party_signals()
	assert_false(
		_mock_pm.party_changed.is_connected(_ui._on_party_changed),
		"_disconnect_party_signals() should disconnect party_changed",
	)


func test_disconnect_unwires_party_state_changed() -> void:
	_ui._connect_party_signals()
	_ui._disconnect_party_signals()
	assert_false(
		_mock_pm.party_state_changed.is_connected(_ui._on_party_changed),
		"_disconnect_party_signals() should disconnect party_state_changed",
	)


func test_repeated_connect_does_not_double_connect() -> void:
	_ui._connect_party_signals()
	_ui._connect_party_signals()
	# get_connections() returns one entry per connection; verify no duplicates
	var connections: Array = _mock_pm.party_changed.get_connections()
	var count := 0
	for c in connections:
		if c["callable"].get_method() == "_on_party_changed":
			count += 1
	assert_eq(count, 1, "double _connect_party_signals() must not duplicate connections")

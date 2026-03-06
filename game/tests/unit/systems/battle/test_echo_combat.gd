extends GutTest

## Tests for Echo combat system: equip/unequip, per-battle uses,
## serialization, and echo effect execution.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const EchoManagerScript = preload("res://autoloads/echo_manager.gd")

var _mgr: Node


func before_each() -> void:
	_mgr = EchoManagerScript.new()
	add_child_autofree(_mgr)


# --- Equip / Unequip ---

func test_equip_echo_adds_to_equipped_list() -> void:
	var echo: EchoData = Helpers.make_echo({"id": &"fire_blast"})
	_mgr.collect_echo(&"fire_blast")
	var ok: bool = _mgr.equip_echo(echo)
	assert_true(ok, "equip_echo should return true")
	assert_eq(_mgr.get_equipped_echoes().size(), 1)


func test_equip_echo_rejects_beyond_max_slots() -> void:
	for i in 6:
		var echo: EchoData = Helpers.make_echo({"id": StringName("echo_%d" % i)})
		_mgr.collect_echo(echo.id)
		_mgr.equip_echo(echo)
	var extra: EchoData = Helpers.make_echo({"id": &"overflow"})
	_mgr.collect_echo(&"overflow")
	var ok: bool = _mgr.equip_echo(extra)
	assert_false(ok, "Should reject 7th echo")
	assert_eq(_mgr.get_equipped_echoes().size(), 6)


func test_unequip_echo_removes_from_list() -> void:
	var echo: EchoData = Helpers.make_echo({"id": &"fire_blast"})
	_mgr.collect_echo(&"fire_blast")
	_mgr.equip_echo(echo)
	_mgr.unequip_echo(echo)
	assert_eq(_mgr.get_equipped_echoes().size(), 0)


func test_equip_duplicate_rejected() -> void:
	var echo: EchoData = Helpers.make_echo({"id": &"fire_blast"})
	_mgr.collect_echo(&"fire_blast")
	_mgr.equip_echo(echo)
	var ok: bool = _mgr.equip_echo(echo)
	assert_false(ok, "Duplicate equip should be rejected")
	assert_eq(_mgr.get_equipped_echoes().size(), 1)


# --- Per-battle uses ---

func test_reset_battle_uses_initializes_tracking() -> void:
	var echo: EchoData = Helpers.make_echo({
		"id": &"fire_blast", "uses_per_battle": 2,
	})
	_mgr.collect_echo(&"fire_blast")
	_mgr.equip_echo(echo)
	_mgr.reset_battle_uses()
	assert_eq(_mgr.get_remaining_uses(&"fire_blast"), 2)


func test_consume_use_decrements_and_returns_true() -> void:
	var echo: EchoData = Helpers.make_echo({
		"id": &"fire_blast", "uses_per_battle": 1,
	})
	_mgr.collect_echo(&"fire_blast")
	_mgr.equip_echo(echo)
	_mgr.reset_battle_uses()
	var ok: bool = _mgr.consume_use(&"fire_blast")
	assert_true(ok)
	assert_eq(_mgr.get_remaining_uses(&"fire_blast"), 0)


func test_consume_use_returns_false_when_exhausted() -> void:
	var echo: EchoData = Helpers.make_echo({
		"id": &"fire_blast", "uses_per_battle": 1,
	})
	_mgr.collect_echo(&"fire_blast")
	_mgr.equip_echo(echo)
	_mgr.reset_battle_uses()
	_mgr.consume_use(&"fire_blast")
	var ok: bool = _mgr.consume_use(&"fire_blast")
	assert_false(ok, "Should fail when uses exhausted")


# --- Serialization ---

func test_serialize_includes_equipped_echoes() -> void:
	var echo: EchoData = Helpers.make_echo({"id": &"fire_blast"})
	_mgr.collect_echo(&"fire_blast")
	_mgr.equip_echo(echo)
	var data: Dictionary = _mgr.serialize()
	assert_true(data.has("equipped"), "Serialized data should have 'equipped'")
	var equipped: Array = data["equipped"]
	assert_eq(equipped.size(), 1)
	assert_eq(equipped[0], "fire_blast")


func test_deserialize_restores_equipped_echo_ids() -> void:
	var data: Dictionary = {
		"echoes": ["fire_blast", "heal_pulse"],
		"equipped": ["fire_blast"],
	}
	_mgr.deserialize(data)
	assert_true(_mgr.has_echo(&"fire_blast"))
	assert_true(_mgr.has_echo(&"heal_pulse"))
	var equipped_ids: Array[StringName] = _mgr.get_equipped_echo_ids()
	assert_eq(equipped_ids.size(), 1)
	assert_eq(equipped_ids[0], &"fire_blast")


# --- get_available_echoes filters exhausted ones ---

func test_get_available_echoes_excludes_exhausted() -> void:
	var echo_a: EchoData = Helpers.make_echo({
		"id": &"echo_a", "uses_per_battle": 1,
	})
	var echo_b: EchoData = Helpers.make_echo({
		"id": &"echo_b", "uses_per_battle": 2,
	})
	_mgr.collect_echo(&"echo_a")
	_mgr.collect_echo(&"echo_b")
	_mgr.equip_echo(echo_a)
	_mgr.equip_echo(echo_b)
	_mgr.reset_battle_uses()
	_mgr.consume_use(&"echo_a")
	var available: Array[EchoData] = _mgr.get_available_echoes()
	assert_eq(available.size(), 1)
	assert_eq(available[0].id, &"echo_b")

extends GutTest

## Tests for PartyManager roster logic.
## Creates a fresh instance per test — never touches the global singleton.

const TestHelpers := preload("res://tests/helpers/test_helpers.gd")

var _pm: Node
var _chars: Array[Resource] = []


func before_each() -> void:
	_pm = load("res://autoloads/party_manager.gd").new()
	add_child_autofree(_pm)
	_chars = []
	for i in 6:
		var r := Resource.new()
		r.resource_name = "char_%d" % i
		_chars.append(r)


func test_add_to_empty_party() -> void:
	_pm.add_character(_chars[0])
	assert_eq(_pm.active_party.size(), 1)
	assert_eq(_pm.roster.size(), 1)


func test_fifth_character_goes_to_reserve() -> void:
	for i in 5:
		_pm.add_character(_chars[i])
	assert_eq(_pm.active_party.size(), 4)
	assert_eq(_pm.reserve_party.size(), 1)
	assert_eq(_pm.reserve_party[0], _chars[4])


func test_duplicate_rejected() -> void:
	_pm.add_character(_chars[0])
	_pm.add_character(_chars[0])
	assert_eq(_pm.roster.size(), 1)


func test_remove_promotes_reserve() -> void:
	for i in 5:
		_pm.add_character(_chars[i])
	# Remove an active member — reserve should promote
	_pm.remove_character(_chars[0])
	assert_eq(_pm.active_party.size(), 4)
	assert_true(_pm.is_in_party(_chars[4]))


func test_swap_members() -> void:
	for i in 5:
		_pm.add_character(_chars[i])
	var old_active: Resource = _pm.active_party[0]
	var old_reserve: Resource = _pm.reserve_party[0]
	_pm.swap_members(0, 0)
	assert_eq(_pm.active_party[0], old_reserve)
	assert_eq(_pm.reserve_party[0], old_active)


func test_is_in_party() -> void:
	_pm.add_character(_chars[0])
	assert_true(_pm.is_in_party(_chars[0]))
	assert_false(_pm.is_in_party(_chars[1]))


func test_get_active_party_returns_copy() -> void:
	_pm.add_character(_chars[0])
	var copy: Array[Resource] = _pm.get_active_party()
	copy.append(_chars[1])
	assert_eq(_pm.active_party.size(), 1)


func test_party_changed_signal() -> void:
	watch_signals(_pm)
	_pm.add_character(_chars[0])
	assert_signal_emitted(_pm, "party_changed")


func test_character_added_signal() -> void:
	watch_signals(_pm)
	_pm.add_character(_chars[0])
	assert_signal_emitted_with_parameters(
		_pm, "character_added", [_chars[0]]
	)


func test_character_removed_signal() -> void:
	_pm.add_character(_chars[0])
	watch_signals(_pm)
	_pm.remove_character(_chars[0])
	assert_signal_emitted_with_parameters(
		_pm, "character_removed", [_chars[0]]
	)


func test_remove_nonexistent_no_crash() -> void:
	_pm.remove_character(_chars[0])
	assert_eq(_pm.roster.size(), 0)


func test_get_party_size() -> void:
	_pm.add_character(_chars[0])
	_pm.add_character(_chars[1])
	assert_eq(_pm.get_party_size(), 2)


func test_get_roster_returns_copy() -> void:
	_pm.add_character(_chars[0])
	var copy: Array[Resource] = _pm.get_roster()
	copy.append(_chars[1])
	assert_eq(_pm.roster.size(), 1)


func test_add_null_character_rejected() -> void:
	_pm.add_character(null)
	assert_eq(_pm.roster.size(), 0)


func test_remove_null_character_no_crash() -> void:
	_pm.add_character(_chars[0])
	_pm.remove_character(null)
	assert_eq(_pm.roster.size(), 1)


func test_swap_invalid_active_index_no_crash() -> void:
	for i in 5:
		_pm.add_character(_chars[i])
	var old_active: Resource = _pm.active_party[0]
	_pm.swap_members(-1, 0)
	assert_eq(_pm.active_party[0], old_active)
	_pm.swap_members(99, 0)
	assert_eq(_pm.active_party[0], old_active)


func test_swap_invalid_reserve_index_no_crash() -> void:
	for i in 5:
		_pm.add_character(_chars[i])
	var old_reserve: Resource = _pm.reserve_party[0]
	_pm.swap_members(0, -1)
	assert_eq(_pm.reserve_party[0], old_reserve)
	_pm.swap_members(0, 99)
	assert_eq(_pm.reserve_party[0], old_reserve)


func test_remove_from_reserve() -> void:
	for i in 5:
		_pm.add_character(_chars[i])
	# chars[4] is in reserve
	_pm.remove_character(_chars[4])
	assert_eq(_pm.reserve_party.size(), 0)
	assert_eq(_pm.active_party.size(), 4)
	assert_eq(_pm.roster.size(), 4)


# -------------------------------------------------------------------
# Runtime HP/EE state tests
# -------------------------------------------------------------------


func _make_char(id: StringName, hp: int = 100, ee: int = 50) -> BattlerData:
	return TestHelpers.make_battler_data({
		"id": id,
		"max_hp": hp,
		"max_ee": ee,
	})


func test_runtime_state_initialized_on_add() -> void:
	var data := _make_char(&"lyra", 120, 60)
	_pm.add_character(data)
	assert_eq(_pm.get_hp(&"lyra"), 120)
	assert_eq(_pm.get_ee(&"lyra"), 60)


func test_set_hp_updates_state() -> void:
	var data := _make_char(&"lyra", 100, 50)
	_pm.add_character(data)
	_pm.set_hp(&"lyra", 42)
	assert_eq(_pm.get_hp(&"lyra"), 42)


func test_set_ee_updates_state() -> void:
	var data := _make_char(&"lyra", 100, 50)
	_pm.add_character(data)
	_pm.set_ee(&"lyra", 15)
	assert_eq(_pm.get_ee(&"lyra"), 15)


func test_get_hp_unknown_id_returns_zero() -> void:
	assert_eq(_pm.get_hp(&"nobody"), 0)


func test_get_ee_unknown_id_returns_zero() -> void:
	assert_eq(_pm.get_ee(&"nobody"), 0)


func test_heal_all_restores_full() -> void:
	var lyra := _make_char(&"lyra", 100, 50)
	var garrick := _make_char(&"garrick", 200, 80)
	_pm.add_character(lyra)
	_pm.add_character(garrick)
	_pm.set_hp(&"lyra", 10)
	_pm.set_ee(&"lyra", 5)
	_pm.set_hp(&"garrick", 50)
	_pm.set_ee(&"garrick", 20)
	_pm.heal_all()
	assert_eq(_pm.get_hp(&"lyra"), 100)
	assert_eq(_pm.get_ee(&"lyra"), 50)
	assert_eq(_pm.get_hp(&"garrick"), 200)
	assert_eq(_pm.get_ee(&"garrick"), 80)


func test_get_runtime_state_returns_copy() -> void:
	var data := _make_char(&"lyra", 100, 50)
	_pm.add_character(data)
	var state: Dictionary = _pm.get_runtime_state(&"lyra")
	assert_eq(state["current_hp"], 100)
	assert_eq(state["current_ee"], 50)
	# Modifying the copy should not affect internal state
	state["current_hp"] = 0
	assert_eq(_pm.get_hp(&"lyra"), 100)


func test_get_runtime_state_unknown_returns_empty() -> void:
	var state: Dictionary = _pm.get_runtime_state(&"nobody")
	assert_true(state.is_empty())


func test_runtime_state_removed_on_character_remove() -> void:
	var data := _make_char(&"lyra", 100, 50)
	_pm.add_character(data)
	_pm.remove_character(data)
	assert_eq(_pm.get_hp(&"lyra"), 0)
	assert_true(_pm.get_runtime_state(&"lyra").is_empty())


func test_party_state_changed_signal_on_set_hp() -> void:
	var data := _make_char(&"lyra", 100, 50)
	_pm.add_character(data)
	watch_signals(_pm)
	_pm.set_hp(&"lyra", 80)
	assert_signal_emitted(_pm, "party_state_changed")


func test_party_state_changed_signal_on_heal_all() -> void:
	var data := _make_char(&"lyra", 100, 50)
	_pm.add_character(data)
	_pm.set_hp(&"lyra", 10)
	watch_signals(_pm)
	_pm.heal_all()
	assert_signal_emitted(_pm, "party_state_changed")


func test_plain_resource_no_runtime_state() -> void:
	# Existing tests use plain Resource.new() — runtime state should
	# silently skip these (no id field).
	var r := Resource.new()
	_pm.add_character(r)
	assert_eq(_pm.roster.size(), 1)
	# No runtime state for non-BattlerData
	assert_true(_pm.get_runtime_state(&"").is_empty())


func test_set_hp_clamped_to_zero() -> void:
	var data := _make_char(&"lyra", 100, 50)
	_pm.add_character(data)
	_pm.set_hp(&"lyra", -10)
	assert_eq(_pm.get_hp(&"lyra"), 0)


func test_set_hp_clamped_to_max() -> void:
	var data := _make_char(&"lyra", 100, 50)
	_pm.add_character(data)
	_pm.set_hp(&"lyra", 999)
	assert_eq(_pm.get_hp(&"lyra"), 100)


func test_set_ee_clamped_to_bounds() -> void:
	var data := _make_char(&"lyra", 100, 50)
	_pm.add_character(data)
	_pm.set_ee(&"lyra", -5)
	assert_eq(_pm.get_ee(&"lyra"), 0)
	_pm.set_ee(&"lyra", 999)
	assert_eq(_pm.get_ee(&"lyra"), 50)

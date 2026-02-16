extends GutTest

## Tests for PartyManager roster logic.
## Creates a fresh instance per test — never touches the global singleton.

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

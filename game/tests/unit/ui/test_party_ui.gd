extends GutTest

## Tests for T-0020: Party Management UI static helper functions.
## Uses PartyUIData (RefCounted) which is testable without a live scene.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const PartyUIData := preload("res://ui/party_ui/party_ui_data.gd")
const PartyManagerScript := preload("res://autoloads/party_manager.gd")


func _make_pm(members: Array[Dictionary] = []) -> Node:
	var pm: Node = PartyManagerScript.new()
	add_child_autofree(pm)
	for overrides in members:
		var data := Helpers.make_character_data(overrides)
		pm.add_character(data)
	return pm


# -- compute_member_display --

func test_member_display_has_name() -> void:
	var member := Helpers.make_character_data({"display_name": "Kael"})
	var d: Dictionary = PartyUIData.compute_member_display(member, null)
	assert_eq(d["name"], "Kael", "Display should include character name")


func test_member_display_has_level() -> void:
	var member := Helpers.make_character_data({"level": 5})
	var d: Dictionary = PartyUIData.compute_member_display(member, null)
	assert_eq(d["level"], 5, "Display should include character level")


func test_member_display_has_max_hp() -> void:
	var member := Helpers.make_character_data({"max_hp": 120})
	var d: Dictionary = PartyUIData.compute_member_display(member, null)
	assert_eq(d["max_hp"], 120, "Display should include max HP")


func test_member_display_current_hp_equals_max_without_pm() -> void:
	var member := Helpers.make_character_data({"max_hp": 80})
	var d: Dictionary = PartyUIData.compute_member_display(member, null)
	assert_eq(d["current_hp"], 80, "Current HP should equal max when no PM provided")


func test_member_display_reads_current_hp_from_pm() -> void:
	var pm := _make_pm([{"id": &"kael", "max_hp": 100}])
	pm.set_hp(&"kael", 42)
	var member: Resource = pm.get_active_party()[0]
	var d: Dictionary = PartyUIData.compute_member_display(member, pm)
	assert_eq(d["current_hp"], 42, "Current HP should come from PartyManager runtime state")


func test_member_display_has_all_combat_stats() -> void:
	var member := Helpers.make_character_data({
		"attack": 15, "magic": 12, "defense": 8,
		"resistance": 9, "speed": 11,
	})
	var d: Dictionary = PartyUIData.compute_member_display(member, null)
	assert_eq(d["attack"], 15)
	assert_eq(d["magic"], 12)
	assert_eq(d["defense"], 8)
	assert_eq(d["resistance"], 9)
	assert_eq(d["speed"], 11)


# -- compute_swap_valid --

func test_swap_valid_with_valid_indices() -> void:
	assert_true(
		PartyUIData.compute_swap_valid(0, 0, 3, 2),
		"Valid indices should return true",
	)


func test_swap_valid_negative_active_index() -> void:
	assert_false(
		PartyUIData.compute_swap_valid(-1, 0, 3, 2),
		"Negative active index should be invalid",
	)


func test_swap_valid_negative_reserve_index() -> void:
	assert_false(
		PartyUIData.compute_swap_valid(0, -1, 3, 2),
		"Negative reserve index should be invalid",
	)


func test_swap_valid_active_out_of_bounds() -> void:
	assert_false(
		PartyUIData.compute_swap_valid(3, 0, 3, 2),
		"Active index >= active_size should be invalid",
	)


func test_swap_valid_reserve_out_of_bounds() -> void:
	assert_false(
		PartyUIData.compute_swap_valid(0, 2, 3, 2),
		"Reserve index >= reserve_size should be invalid",
	)


func test_swap_valid_empty_active() -> void:
	assert_false(
		PartyUIData.compute_swap_valid(0, 0, 0, 2),
		"Active size of 0 should make any index invalid",
	)


# -- compute_panel_sections --

func test_panel_sections_active_only() -> void:
	var pm := _make_pm([{"display_name": "Kael"}, {"display_name": "Iris"}])
	var active: Array[Resource] = pm.get_active_party()
	var reserve: Array[Resource] = []
	var sections: Dictionary = PartyUIData.compute_panel_sections(
		active, reserve, pm
	)
	assert_eq(
		sections["active"].size(), 2,
		"Active entries should match active party size",
	)
	assert_eq(
		sections["reserve"].size(), 0,
		"Reserve entries should be empty when no reserve",
	)
	assert_false(
		sections["has_reserve"],
		"has_reserve should be false when reserve is empty",
	)


func test_panel_sections_with_reserve() -> void:
	var pm := _make_pm([
		{"display_name": "Kael"},
		{"display_name": "Iris"},
		{"display_name": "Garrick"},
		{"display_name": "Lyra"},
		{"display_name": "Reserve1"},
	])
	var active: Array[Resource] = pm.get_active_party()
	var reserve_list: Array[Resource] = []
	for m in pm.get_roster():
		if not pm.is_in_party(m):
			reserve_list.append(m)
	var sections: Dictionary = PartyUIData.compute_panel_sections(
		active, reserve_list, pm
	)
	assert_true(
		sections["has_reserve"],
		"has_reserve should be true when reserve members exist",
	)
	assert_eq(
		sections["reserve"].size(), 1,
		"Reserve entries should match reserve count",
	)


func test_panel_sections_names_preserved() -> void:
	var pm := _make_pm([{"display_name": "Kael", "id": &"kael"}])
	var active: Array[Resource] = pm.get_active_party()
	var sections: Dictionary = PartyUIData.compute_panel_sections(
		active, [], pm
	)
	assert_eq(
		sections["active"][0]["name"], "Kael",
		"Member names should be preserved in sections",
	)

extends GutTest

## Regression tests for T-0115: pause menu was showing max HP/EE
## instead of current HP/EE. Tests the static compute_member_stats()
## function that extracts display values.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const PauseMenuScript := preload("res://ui/pause_menu/pause_menu.gd")
const PartyManagerScript := preload("res://autoloads/party_manager.gd")


func _make_party_with_damage() -> Node:
	var pm: Node = PartyManagerScript.new()
	add_child_autofree(pm)
	var data := Helpers.make_character_data({
		"id": &"hero",
		"display_name": "Test Hero",
		"max_hp": 100,
		"max_ee": 50,
	})
	pm.add_character(data)
	pm.set_hp(&"hero", 35)
	pm.set_ee(&"hero", 12)
	return pm


func test_compute_member_stats_shows_current_hp() -> void:
	var pm := _make_party_with_damage()
	var member: Resource = pm.get_active_party()[0]
	var stats := PauseMenuScript.compute_member_stats(member, pm)
	assert_eq(stats["current_hp"], 35)


func test_compute_member_stats_shows_max_hp() -> void:
	var pm := _make_party_with_damage()
	var member: Resource = pm.get_active_party()[0]
	var stats := PauseMenuScript.compute_member_stats(member, pm)
	assert_eq(stats["max_hp"], 100)


func test_compute_member_stats_shows_current_ee() -> void:
	var pm := _make_party_with_damage()
	var member: Resource = pm.get_active_party()[0]
	var stats := PauseMenuScript.compute_member_stats(member, pm)
	assert_eq(stats["current_ee"], 12)


func test_compute_member_stats_shows_max_ee() -> void:
	var pm := _make_party_with_damage()
	var member: Resource = pm.get_active_party()[0]
	var stats := PauseMenuScript.compute_member_stats(member, pm)
	assert_eq(stats["max_ee"], 50)


func test_compute_member_stats_full_hp_when_undamaged() -> void:
	var pm: Node = PartyManagerScript.new()
	add_child_autofree(pm)
	var data := Helpers.make_character_data({
		"id": &"fresh",
		"max_hp": 200,
		"max_ee": 80,
	})
	pm.add_character(data)
	var member: Resource = pm.get_active_party()[0]
	var stats := PauseMenuScript.compute_member_stats(member, pm)
	assert_eq(stats["current_hp"], 200)
	assert_eq(stats["max_hp"], 200)
	assert_eq(stats["current_ee"], 80)
	assert_eq(stats["max_ee"], 80)


func test_compute_member_stats_zero_hp_dead() -> void:
	var pm := _make_party_with_damage()
	var member: Resource = pm.get_active_party()[0]
	pm.set_hp(&"hero", 0)
	var stats := PauseMenuScript.compute_member_stats(member, pm)
	assert_eq(stats["current_hp"], 0)
	assert_eq(stats["max_hp"], 100)


func test_compute_member_stats_null_pm_falls_back_to_max() -> void:
	var data := Helpers.make_character_data({
		"id": &"hero",
		"max_hp": 100,
		"max_ee": 50,
	})
	var stats := PauseMenuScript.compute_member_stats(data, null)
	assert_eq(stats["current_hp"], 100)
	assert_eq(stats["max_hp"], 100)
	assert_eq(stats["current_ee"], 50)
	assert_eq(stats["max_ee"], 50)

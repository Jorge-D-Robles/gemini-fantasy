extends GutTest

## Tests for CampMenuData static helpers —
## verifies menu option enumeration, rest messaging, and heal-needed logic.

const CampMenuData := preload("res://ui/camp_menu/camp_menu_data.gd")


func test_menu_options_returns_two_entries() -> void:
	var options := CampMenuData.compute_menu_options()
	assert_eq(options.size(), 2, "Camp menu must have exactly 2 options")


func test_menu_options_first_entry_is_rest() -> void:
	var options := CampMenuData.compute_menu_options()
	assert_eq(options[0], "Rest", "First option must be 'Rest'")


func test_menu_options_last_entry_is_leave_camp() -> void:
	var options := CampMenuData.compute_menu_options()
	assert_eq(options[options.size() - 1], "Leave Camp", "Last option must be 'Leave Camp'")


func test_rest_message_when_healing_needed() -> void:
	var msg := CampMenuData.compute_rest_message(true)
	assert_true(
		msg.contains("rested"),
		"Rest message when healing was needed should mention 'rested'",
	)


func test_rest_message_when_already_healthy() -> void:
	var msg := CampMenuData.compute_rest_message(false)
	assert_true(
		msg.contains("already"),
		"Rest message when at full health should mention 'already'",
	)


func test_healing_needed_when_hp_depleted() -> void:
	var entries: Array[Dictionary] = [
		{"current_hp": 20, "max_hp": 100, "current_ee": 50, "max_ee": 50},
	]
	assert_true(
		CampMenuData.compute_healing_needed(entries),
		"Healing is needed when HP is below max",
	)


func test_healing_needed_when_ee_depleted() -> void:
	var entries: Array[Dictionary] = [
		{"current_hp": 100, "max_hp": 100, "current_ee": 0, "max_ee": 50},
	]
	assert_true(
		CampMenuData.compute_healing_needed(entries),
		"Healing is needed when EE is below max",
	)


func test_healing_not_needed_when_all_full() -> void:
	var entries: Array[Dictionary] = [
		{"current_hp": 100, "max_hp": 100, "current_ee": 50, "max_ee": 50},
		{"current_hp": 80, "max_hp": 80, "current_ee": 30, "max_ee": 30},
	]
	assert_false(
		CampMenuData.compute_healing_needed(entries),
		"Healing is not needed when all members are at full HP and EE",
	)


func test_healing_needed_when_second_member_depleted() -> void:
	var entries: Array[Dictionary] = [
		{"current_hp": 100, "max_hp": 100, "current_ee": 50, "max_ee": 50},
		{"current_hp": 10, "max_hp": 80, "current_ee": 30, "max_ee": 30},
	]
	assert_true(
		CampMenuData.compute_healing_needed(entries),
		"Healing is needed when any party member has depleted HP",
	)


func test_healing_not_needed_for_empty_party() -> void:
	var entries: Array[Dictionary] = []
	assert_false(
		CampMenuData.compute_healing_needed(entries),
		"Empty party does not need healing",
	)

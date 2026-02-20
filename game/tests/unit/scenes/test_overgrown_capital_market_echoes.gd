extends GutTest

## Unit tests for Market District echo placement in Overgrown Capital.
## T-0199: Place Morning Commute and Family Dinner echo interactables
## in Overgrown Capital Market District.

const OvergrownCapital = preload("res://scenes/overgrown_capital/overgrown_capital.gd")


func test_compute_market_echo_positions_returns_two_positions() -> void:
	var positions := OvergrownCapital.compute_market_echo_positions()
	assert_eq(positions.size(), 2)


func test_morning_commute_position_within_map_bounds() -> void:
	var positions := OvergrownCapital.compute_market_echo_positions()
	var pos: Vector2 = positions[0]
	assert_true(pos.x > 0.0 and pos.x < 640.0, "Morning Commute X must be within map width")
	assert_true(pos.y > 0.0 and pos.y < 448.0, "Morning Commute Y must be within map height")


func test_family_dinner_position_within_map_bounds() -> void:
	var positions := OvergrownCapital.compute_market_echo_positions()
	var pos: Vector2 = positions[1]
	assert_true(pos.x > 0.0 and pos.x < 640.0, "Family Dinner X must be within map width")
	assert_true(pos.y > 0.0 and pos.y < 448.0, "Family Dinner Y must be within map height")


func test_morning_commute_vision_lines_has_even_count() -> void:
	var lines := OvergrownCapital.compute_morning_commute_vision_lines()
	assert_eq(lines.size() % 2, 0, "vision_lines must have even count for speaker/text pairing")


func test_family_dinner_vision_lines_has_even_count() -> void:
	var lines := OvergrownCapital.compute_family_dinner_vision_lines()
	assert_eq(lines.size() % 2, 0, "vision_lines must have even count for speaker/text pairing")


func test_morning_commute_vision_lines_minimum_count() -> void:
	var lines := OvergrownCapital.compute_morning_commute_vision_lines()
	assert_true(lines.size() >= 4, "Morning Commute vision must have at least 2 dialogue pairs")


func test_family_dinner_vision_lines_minimum_count() -> void:
	var lines := OvergrownCapital.compute_family_dinner_vision_lines()
	assert_true(lines.size() >= 4, "Family Dinner vision must have at least 2 dialogue pairs")


func test_morning_commute_vision_mentions_network_or_memory() -> void:
	var lines := OvergrownCapital.compute_morning_commute_vision_lines()
	var combined: String = " ".join(PackedStringArray(lines)).to_lower()
	assert_true(
		"network" in combined or "memory" in combined or "eyes" in combined,
		"Morning Commute vision must reference the Memory Network",
	)


func test_family_dinner_vision_mentions_family_theme() -> void:
	var lines := OvergrownCapital.compute_family_dinner_vision_lines()
	var combined: String = " ".join(PackedStringArray(lines)).to_lower()
	assert_true(
		"table" in combined or "family" in combined or "waiting" in combined,
		"Family Dinner vision must reference the family/table scene",
	)


func test_capital_declares_morning_commute_echo_id() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(source.contains("morning_commute"), "Capital must reference morning_commute echo ID")


func test_capital_declares_family_dinner_echo_id() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(source.contains("family_dinner"), "Capital must reference family_dinner echo ID")

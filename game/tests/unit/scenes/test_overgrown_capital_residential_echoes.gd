extends GutTest

## Unit tests for Residential Quarter echo placement in Overgrown Capital.
## T-0205: Seed and place Residential Quarter echo interactables.

const OvergrownCapital = preload("res://scenes/overgrown_capital/overgrown_capital.gd")


func test_compute_residential_echo_positions_returns_two_positions() -> void:
	var positions := OvergrownCapital.compute_residential_echo_positions()
	assert_eq(positions.size(), 2)


func test_mothers_comfort_position_within_map_bounds() -> void:
	var positions := OvergrownCapital.compute_residential_echo_positions()
	var pos: Vector2 = positions[0]
	assert_true(pos.x > 0.0 and pos.x < 640.0, "Mother's Comfort X must be within map width")
	assert_true(pos.y > 0.0 and pos.y < 448.0, "Mother's Comfort Y must be within map height")


func test_first_day_of_school_position_within_map_bounds() -> void:
	var positions := OvergrownCapital.compute_residential_echo_positions()
	var pos: Vector2 = positions[1]
	assert_true(pos.x > 0.0 and pos.x < 640.0, "First Day of School X must be within map width")
	assert_true(pos.y > 0.0 and pos.y < 448.0, "First Day of School Y must be within map height")


func test_residential_echoes_are_in_upper_half_of_map() -> void:
	## Residential Quarter is north of Market District — rows 10-18, y: 160-288.
	var positions := OvergrownCapital.compute_residential_echo_positions()
	for pos: Vector2 in positions:
		assert_true(pos.y < 300.0, "Residential echoes must be north of Market District (y < 300)")


func test_mothers_comfort_vision_lines_has_even_count() -> void:
	var lines := OvergrownCapital.compute_mothers_comfort_vision_lines()
	assert_eq(lines.size() % 2, 0, "vision_lines must have even count for speaker/text pairing")


func test_first_day_of_school_vision_lines_has_even_count() -> void:
	var lines := OvergrownCapital.compute_first_day_of_school_vision_lines()
	assert_eq(lines.size() % 2, 0, "vision_lines must have even count for speaker/text pairing")


func test_mothers_comfort_vision_minimum_count() -> void:
	var lines := OvergrownCapital.compute_mothers_comfort_vision_lines()
	assert_true(lines.size() >= 4, "Mother's Comfort vision must have at least 2 dialogue pairs")


func test_first_day_of_school_vision_minimum_count() -> void:
	var lines := OvergrownCapital.compute_first_day_of_school_vision_lines()
	assert_true(lines.size() >= 4, "First Day of School vision must have at least 2 dialogue pairs")


func test_mothers_comfort_vision_mentions_warmth_or_child() -> void:
	var lines := OvergrownCapital.compute_mothers_comfort_vision_lines()
	var combined: String = " ".join(PackedStringArray(lines)).to_lower()
	assert_true(
		"child" in combined or "warm" in combined or "hum" in combined or "bread" in combined,
		"Mother's Comfort vision must evoke warmth and family",
	)


func test_first_day_of_school_vision_mentions_learning() -> void:
	var lines := OvergrownCapital.compute_first_day_of_school_vision_lines()
	var combined: String = " ".join(PackedStringArray(lines)).to_lower()
	assert_true(
		"learn" in combined or "network" in combined or "child" in combined or "school" in combined,
		"First Day of School vision must reference the Network education system",
	)


func test_capital_declares_mothers_comfort_echo_id() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("mothers_comfort"),
		"Capital must reference mothers_comfort echo ID",
	)


func test_capital_declares_first_day_of_school_echo_id() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/overgrown_capital/overgrown_capital.gd"
	)
	assert_true(
		source.contains("first_day_of_school"),
		"Capital must reference first_day_of_school echo ID",
	)


func test_first_day_of_school_tres_exists() -> void:
	assert_true(
		FileAccess.file_exists("res://data/echoes/first_day_of_school.tres"),
		"first_day_of_school.tres must exist in game/data/echoes/",
	)


func test_first_day_of_school_has_unique_id() -> void:
	var echo_data := load("res://data/echoes/first_day_of_school.tres") as Resource
	assert_not_null(echo_data)
	assert_eq(echo_data.get("id"), &"first_day_of_school")

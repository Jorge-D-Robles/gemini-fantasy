extends GutTest

## Tests for OvergrownCapitalMap — tilemap constants for Overgrown Capital dungeon.
## Verifies dimension integrity and legend key format.

const EXPECTED_ROWS: int = 28
const EXPECTED_COLS: int = 40

var _script: GDScript


func before_each() -> void:
	_script = load("res://scenes/overgrown_capital/overgrown_capital_map.gd")


func test_ground_map_has_expected_dimensions() -> void:
	assert_eq(_script.GROUND_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.GROUND_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_detail_map_has_expected_dimensions() -> void:
	assert_eq(_script.DETAIL_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.DETAIL_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_wall_map_has_expected_dimensions() -> void:
	assert_eq(_script.WALL_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.WALL_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_objects_map_has_expected_dimensions() -> void:
	assert_eq(_script.OBJECTS_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.OBJECTS_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_legend_keys_are_single_chars() -> void:
	for key: String in _script.GROUND_LEGEND.keys():
		assert_eq(key.length(), 1, "GROUND key must be 1 char: " + key)
	for key: String in _script.DETAIL_LEGEND.keys():
		assert_eq(key.length(), 1, "DETAIL key must be 1 char: " + key)
	for key: String in _script.WALL_LEGEND.keys():
		assert_eq(key.length(), 1, "WALL key must be 1 char: " + key)
	for key: String in _script.OBJECTS_LEGEND.keys():
		assert_eq(key.length(), 1, "OBJECTS key must be 1 char: " + key)

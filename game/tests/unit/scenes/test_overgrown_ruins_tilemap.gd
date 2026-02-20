extends GutTest

## Data integrity tests for Overgrown Ruins tilemap map constants.
## Verifies dimensions and that debris/detail maps fit within the grid.

const EXPECTED_ROWS: int = 24
const EXPECTED_COLS: int = 40

var _script: GDScript


func before_each() -> void:
	_script = load("res://scenes/overgrown_ruins/overgrown_ruins.gd")


func test_ground_map_has_expected_dimensions() -> void:
	assert_eq(_script.GROUND_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.GROUND_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_detail_map_has_expected_dimensions() -> void:
	assert_eq(_script.DETAIL_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.DETAIL_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_debris_map_has_expected_dimensions() -> void:
	assert_eq(_script.DEBRIS_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.DEBRIS_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_wall_map_has_expected_dimensions() -> void:
	assert_eq(_script.WALL_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.WALL_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_objects_map_has_expected_dimensions() -> void:
	assert_eq(_script.OBJECTS_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.OBJECTS_MAP:
		assert_eq(row.length(), EXPECTED_COLS)

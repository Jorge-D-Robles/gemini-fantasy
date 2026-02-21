extends GutTest

## Tests for OvergrownCapitalMap — tilemap constants for Overgrown Capital dungeon.
## Verifies dimension integrity and legend key format.

const EXPECTED_ROWS: int = 28
const EXPECTED_COLS: int = 40

var _script: GDScript


func before_each() -> void:
	_script = load("res://scenes/overgrown_capital/overgrown_capital_map.gd")


func test_map_dimensions_constants() -> void:
	assert_eq(_script.COLS, EXPECTED_COLS, "COLS must be 40")
	assert_eq(_script.ROWS, EXPECTED_ROWS, "ROWS must be 28")


func test_ground_entries_nonempty_with_catchall() -> void:
	assert_true(_script.GROUND_ENTRIES.size() > 0, "GROUND_ENTRIES must have entries")
	var last: Dictionary = _script.GROUND_ENTRIES[_script.GROUND_ENTRIES.size() - 1]
	assert_eq(last.get("threshold", 0.0), -1.0, "Last GROUND_ENTRY must be catch-all (-1.0)")


func test_detail_entries_nonempty() -> void:
	assert_true(_script.DETAIL_ENTRIES.size() > 0, "DETAIL_ENTRIES must have entries")


func test_wall_map_has_expected_dimensions() -> void:
	assert_eq(_script.WALL_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.WALL_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_objects_map_has_expected_dimensions() -> void:
	assert_eq(_script.OBJECTS_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.OBJECTS_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_legend_keys_are_single_chars() -> void:
	for key: String in _script.WALL_LEGEND.keys():
		assert_eq(key.length(), 1, "WALL key must be 1 char: " + key)
	for key: String in _script.OBJECTS_LEGEND.keys():
		assert_eq(key.length(), 1, "OBJECTS key must be 1 char: " + key)


func test_ground_entries_have_multiple_terrain_types() -> void:
	## Procedural ground must offer 2+ terrain variants for visual variety.
	assert_true(
		_script.GROUND_ENTRIES.size() >= 2,
		"GROUND_ENTRIES must have 2+ entries for terrain variety",
	)


func test_ground_entries_thresholds_ordered_high_to_low() -> void:
	## Thresholds must be in descending order (first-match wins).
	for i: int in range(1, _script.GROUND_ENTRIES.size()):
		var prev: float = _script.GROUND_ENTRIES[i - 1].get("threshold", 0.0)
		var curr: float = _script.GROUND_ENTRIES[i].get("threshold", 0.0)
		assert_true(
			prev > curr,
			"GROUND_ENTRIES threshold at index %d (%f) must be > index %d (%f)" % [i - 1, prev, i, curr],
		)


func test_wall_map_has_boundary_walls() -> void:
	## Row 0 must have at least 30 wall ('W') characters.
	var row_0: String = _script.WALL_MAP[0]
	var w_count: int = 0
	for col_idx: int in range(row_0.length()):
		if row_0[col_idx] == "W":
			w_count += 1
	assert_true(
		w_count >= 30,
		"Row 0 must have 30+ W chars, got %d" % w_count,
	)


func test_detail_entries_have_reasonable_density() -> void:
	## Each DETAIL_ENTRY density must be between 0.01 and 0.30.
	for entry: Dictionary in _script.DETAIL_ENTRIES:
		var density: float = entry.get("density", 0.0)
		assert_true(density >= 0.01, "DETAIL_ENTRY density must be >= 0.01")
		assert_true(density <= 0.30, "DETAIL_ENTRY density must be <= 0.30 (no carpet-bombing)")


func test_debris_entries_nonempty_with_reasonable_density() -> void:
	assert_true(_script.DEBRIS_ENTRIES.size() > 0, "DEBRIS_ENTRIES must have entries")
	for entry: Dictionary in _script.DEBRIS_ENTRIES:
		var density: float = entry.get("density", 0.0)
		assert_true(density >= 0.01, "DEBRIS_ENTRY density must be >= 0.01")
		assert_true(density <= 0.20, "DEBRIS_ENTRY density must be <= 0.20")


func test_echo_positions_are_navigable() -> void:
	## All echo/event positions must have walkable cells in WALL_MAP (not 'W' or 'G').
	var navigable_positions: Array = [
		Vector2i(20, 25),  # Entry spawn
		Vector2i(10, 23),  # Market save point
		Vector2i(6, 20),   # Morning Commute echo
		Vector2i(34, 20),  # Family Dinner echo
		Vector2i(18, 13),  # Purification Node (market)
		Vector2i(18, 12),  # Crystal Wall (market)
		Vector2i(5, 15),   # Mother's Comfort echo
		Vector2i(9, 12),   # First Day of School echo
		Vector2i(30, 10),  # Purification Node (entertainment)
		Vector2i(30, 9),   # Crystal Wall (entertainment)
		Vector2i(28, 6),   # Lyra Fragment 2 echo
		Vector2i(20, 3),   # Last Gardener zone
		Vector2i(20, 27),  # ExitToRuins
	]
	for pos: Vector2i in navigable_positions:
		var col: int = pos.x
		var row: int = pos.y
		var ch: String = _script.WALL_MAP[row][col]
		assert_true(
			ch == ".",
			"Position (col=%d, row=%d) must be navigable in WALL_MAP, got '%s'" % [col, row, ch],
		)


func test_debris_entries_have_source_id() -> void:
	for entry: Dictionary in _script.DEBRIS_ENTRIES:
		assert_true(entry.has("source_id"), "Each DEBRIS_ENTRY must have source_id")


func test_above_player_map_has_expected_dimensions() -> void:
	assert_eq(_script.ABOVE_PLAYER_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.ABOVE_PLAYER_MAP:
		assert_eq(row.length(), EXPECTED_COLS)

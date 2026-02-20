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


func test_ground_map_is_fully_tiled() -> void:
	## Every cell in GROUND_MAP must be a valid GROUND_LEGEND key (no '.' or unknown chars).
	var valid_keys: Array = _script.GROUND_LEGEND.keys()
	for row_idx: int in range(_script.GROUND_MAP.size()):
		var row: String = _script.GROUND_MAP[row_idx]
		for col_idx: int in range(row.length()):
			var ch: String = row[col_idx]
			assert_true(
				ch != ".",
				"GROUND_MAP row %d col %d is '.' (empty)" % [row_idx, col_idx],
			)
			assert_true(
				valid_keys.has(ch),
				"GROUND_MAP row %d col %d has '%s' not in GROUND_LEGEND" % [row_idx, col_idx, ch],
			)


func test_ground_map_has_terrain_variety() -> void:
	## At least 2 terrain types, and the non-dominant type appears 10+ times.
	var counts: Dictionary = {}
	for row: String in _script.GROUND_MAP:
		for col_idx: int in range(row.length()):
			var ch: String = row[col_idx]
			counts[ch] = counts.get(ch, 0) + 1
	assert_true(counts.size() >= 2, "Need at least 2 terrain types, got %d" % counts.size())
	# Find non-dominant types and check they appear meaningfully
	var max_count: int = 0
	var dominant_key: String = ""
	for key: String in counts.keys():
		if counts[key] > max_count:
			max_count = counts[key]
			dominant_key = key
	var non_dominant_total: int = 0
	for key: String in counts.keys():
		if key != dominant_key:
			non_dominant_total += counts[key]
	assert_true(
		non_dominant_total >= 10,
		"Non-dominant terrain must appear 10+ times, got %d" % non_dominant_total,
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


func test_market_district_has_detail_tiles() -> void:
	## Rows 19-27 in DETAIL_MAP must have at least 20 ornate tiles ('O').
	var o_count: int = 0
	for row_idx: int in range(19, 28):
		var row: String = _script.DETAIL_MAP[row_idx]
		for col_idx: int in range(row.length()):
			if row[col_idx] == "O":
				o_count += 1
	assert_true(
		o_count >= 20,
		"Market district (rows 19-27) must have 20+ 'O' tiles, got %d" % o_count,
	)


func test_residential_quarter_has_vegetation() -> void:
	## Cols 2-19, rows 10-18 in GROUND_MAP must have 10+ V or D chars.
	var veg_count: int = 0
	for row_idx: int in range(10, 19):
		var row: String = _script.GROUND_MAP[row_idx]
		for col_idx: int in range(2, 20):
			var ch: String = row[col_idx]
			if ch == "V" or ch == "D":
				veg_count += 1
	assert_true(
		veg_count >= 10,
		"Residential quarter (cols 2-19, rows 10-18) must have 10+ V/D tiles, got %d" % veg_count,
	)


func test_debris_map_has_organic_placement() -> void:
	## Total debris tile count must be between 20 and 80 (sparse, intentional).
	var debris_count: int = 0
	for row: String in _script.DEBRIS_MAP:
		for col_idx: int in range(row.length()):
			if row[col_idx] != ".":
				debris_count += 1
	assert_true(
		debris_count >= 20,
		"Debris count must be >= 20, got %d" % debris_count,
	)
	assert_true(
		debris_count <= 80,
		"Debris count must be <= 80, got %d" % debris_count,
	)


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


func test_debris_map_has_expected_dimensions() -> void:
	assert_eq(_script.DEBRIS_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.DEBRIS_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_above_player_map_has_expected_dimensions() -> void:
	assert_eq(_script.ABOVE_PLAYER_MAP.size(), EXPECTED_ROWS)
	for row: String in _script.ABOVE_PLAYER_MAP:
		assert_eq(row.length(), EXPECTED_COLS)

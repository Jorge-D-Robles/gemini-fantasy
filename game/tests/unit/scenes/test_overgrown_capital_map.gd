extends GutTest

## Tests for OvergrownCapitalMap — tilemap constants for Overgrown Capital dungeon.
## Validates: TF_DUNGEON coords, A5 ban, position hash variety, seed distinctness,
## map dimensions, echo navigability. Updated for T-0256 migration.

const Maps = preload("res://scenes/overgrown_capital/overgrown_capital_map.gd")

const EXPECTED_ROWS: int = 28
const EXPECTED_COLS: int = 40


# -- Map dimensions --


func test_map_dimensions_constants() -> void:
	assert_eq(Maps.COLS, EXPECTED_COLS, "COLS must be 40")
	assert_eq(Maps.ROWS, EXPECTED_ROWS, "ROWS must be 28")


func test_wall_map_has_expected_dimensions() -> void:
	assert_eq(Maps.WALL_MAP.size(), EXPECTED_ROWS)
	for row: String in Maps.WALL_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_objects_map_has_expected_dimensions() -> void:
	assert_eq(Maps.OBJECTS_MAP.size(), EXPECTED_ROWS)
	for row: String in Maps.OBJECTS_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


func test_above_player_map_has_expected_dimensions() -> void:
	assert_eq(Maps.ABOVE_PLAYER_MAP.size(), EXPECTED_ROWS)
	for row: String in Maps.ABOVE_PLAYER_MAP:
		assert_eq(row.length(), EXPECTED_COLS)


# -- Floor/wall tile validation --


func test_floor_tiles_valid_coords() -> void:
	for tile: Vector2i in Maps.FLOOR_TILES:
		assert_true(
			tile.x >= 0 and tile.x <= 20,
			"Floor tile %s col must be 0-20" % tile,
		)
		assert_eq(tile.y, 1, "Floor tile %s must be in row 1" % tile)
	var border: Vector2i = Maps.WALL_BORDER_TILE
	assert_true(
		border.x >= 0 and border.x <= 20,
		"WALL_BORDER_TILE %s col must be 0-20" % border,
	)
	assert_true(
		border.y >= 1 and border.y <= 3,
		"WALL_BORDER_TILE %s row must be 1-3" % border,
	)


func test_pick_floor_tile_variety() -> void:
	var seen: Dictionary = {}
	for y: int in range(10):
		for x: int in range(10):
			var tile: Vector2i = Maps.pick_floor_tile(x, y)
			seen[tile] = true
	assert_eq(
		seen.size(), Maps.FLOOR_TILES.size(),
		"Hash should produce all %d floor variants" % Maps.FLOOR_TILES.size(),
	)


func test_pick_wall_tile_variety() -> void:
	var seen: Dictionary = {}
	for y: int in range(10):
		for x: int in range(10):
			var tile: Vector2i = Maps.pick_wall_tile(x, y)
			seen[tile] = true
	assert_eq(
		seen.size(), Maps.WALL_TILES.size(),
		"Hash should produce all %d wall variants" % Maps.WALL_TILES.size(),
	)


# -- A5 ban enforcement --


func test_no_a5_references() -> void:
	var scripts: Array[String] = [
		"res://scenes/overgrown_capital/overgrown_capital.gd",
		"res://scenes/overgrown_capital/overgrown_capital_map.gd",
	]
	var banned_patterns: Array[String] = [
		"FAIRY_FOREST", "RUINS_A5", "A5_A", "A5_B",
		"build_noise_layer",
	]
	for script_path: String in scripts:
		var file := FileAccess.open(script_path, FileAccess.READ)
		assert_not_null(file, "Should be able to read %s" % script_path)
		if file == null:
			continue
		var content: String = file.get_as_text()
		file.close()
		for pattern: String in banned_patterns:
			assert_false(
				content.contains(pattern),
				"%s must not reference '%s'" % [script_path, pattern],
			)


# -- Detail/debris entries --


func test_detail_entries_valid() -> void:
	assert_gt(Maps.DETAIL_ENTRIES.size(), 0, "DETAIL_ENTRIES must not be empty")
	for entry: Dictionary in Maps.DETAIL_ENTRIES:
		assert_eq(
			int(entry["source_id"]), 1,
			"Detail entry %s must use source_id=1 (RUINS_OBJECTS)" % entry,
		)
		var density: float = entry.get("density", 0.0)
		assert_true(density >= 0.01 and density <= 0.30, "Density must be 0.01-0.30")


func test_debris_entries_valid() -> void:
	assert_gt(Maps.DEBRIS_ENTRIES.size(), 0, "DEBRIS_ENTRIES must not be empty")
	for entry: Dictionary in Maps.DEBRIS_ENTRIES:
		assert_eq(
			int(entry["source_id"]), 2,
			"Debris entry %s must use source_id=2" % entry,
		)
		var density: float = entry.get("density", 0.0)
		assert_true(density >= 0.01 and density <= 0.20, "Density must be 0.01-0.20")


# -- Seed distinctness --


func test_seeds_all_distinct() -> void:
	var seeds: Array[int] = [
		Maps.FLOOR_HASH_SEED,
		Maps.WALL_HASH_SEED,
		Maps.GROUND_NOISE_SEED,
		Maps.GROUND_NOISE_SEED + 1,  # detail noise
		Maps.GROUND_NOISE_SEED + 2,  # debris noise
	]
	var seen: Dictionary = {}
	for seed_val: int in seeds:
		assert_false(
			seen.has(seed_val),
			"Seed value %d appears twice" % seed_val,
		)
		seen[seed_val] = true


# -- Dead code removal --


func test_no_dead_code() -> void:
	var file := FileAccess.open(
		"res://scenes/overgrown_capital/overgrown_capital_map.gd", FileAccess.READ,
	)
	assert_not_null(file, "Should be able to read map file")
	if file == null:
		return
	var content: String = file.get_as_text()
	file.close()
	assert_false(
		content.contains("GROUND_ENTRIES"),
		"Must not contain GROUND_ENTRIES (replaced by FLOOR_TILES)",
	)
	assert_false(
		content.contains("WALL_LEGEND"),
		"Must not contain WALL_LEGEND (replaced by WALL_TILES + WALL_BORDER_TILE)",
	)


# -- Structural integrity --


func test_wall_map_has_boundary_walls() -> void:
	var row_0: String = Maps.WALL_MAP[0]
	var w_count: int = 0
	for col_idx: int in range(row_0.length()):
		if row_0[col_idx] == "W":
			w_count += 1
	assert_true(w_count >= 30, "Row 0 must have 30+ W chars, got %d" % w_count)


func test_echo_positions_are_navigable() -> void:
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
		var ch: String = Maps.WALL_MAP[pos.y][pos.x]
		assert_true(
			ch == ".",
			"Position (col=%d, row=%d) must be navigable, got '%s'" % [pos.x, pos.y, ch],
		)

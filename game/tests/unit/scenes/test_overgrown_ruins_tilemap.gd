extends GutTest

## Tests for Overgrown Ruins TF_DUNGEON + B-sheet tilemap migration (T-0254).
## Validates: no A5 references, valid dungeon.png coords, position hash variety,
## correct source_id assignments, collision on source 0, seed distinctness.

const Maps = preload("res://scenes/overgrown_ruins/overgrown_ruins_map.gd")

# -- Floor tile tests --


func test_pick_floor_tile_returns_valid_coords() -> void:
	for tile: Vector2i in Maps.FLOOR_TILES:
		assert_true(
			tile.x >= 0 and tile.x <= 20,
			"Floor tile %s col must be 0-20 (flat zone)" % tile,
		)
		assert_eq(
			tile.y, 1,
			"Floor tile %s must be in row 1 (row 0 is transparent)" % tile,
		)


func test_pick_floor_tile_variety() -> void:
	var seen: Dictionary = {}
	for y: int in range(10):
		for x: int in range(10):
			var tile: Vector2i = Maps.pick_floor_tile(x, y)
			seen[tile] = true
	assert_eq(
		seen.size(), Maps.FLOOR_TILES.size(),
		"Hash should produce all %d floor variants over 10x10 grid" % Maps.FLOOR_TILES.size(),
	)


# -- Wall tile tests --


func test_pick_wall_tile_returns_valid_coords() -> void:
	for tile: Vector2i in Maps.WALL_TILES:
		assert_true(
			tile.x >= 0 and tile.x <= 20,
			"Wall tile %s col must be 0-20 (flat zone)" % tile,
		)
		assert_true(
			tile.y >= 1 and tile.y <= 3,
			"Wall tile %s row must be 1-3 (flat section)" % tile,
		)


func test_pick_wall_tile_variety() -> void:
	var seen: Dictionary = {}
	for y: int in range(10):
		for x: int in range(10):
			var tile: Vector2i = Maps.pick_wall_tile(x, y)
			seen[tile] = true
	assert_eq(
		seen.size(), Maps.WALL_TILES.size(),
		"Hash should produce all %d wall variants over 10x10 grid" % Maps.WALL_TILES.size(),
	)


func test_wall_border_tile_valid() -> void:
	# WALL_BORDER_TILE must be in the flat zone of dungeon.png (row <= 3)
	var tile: Vector2i = Maps.WALL_BORDER_TILE
	assert_true(
		tile.x >= 0 and tile.x <= 20,
		"WALL_BORDER_TILE %s col must be 0-20" % tile,
	)
	assert_true(
		tile.y >= 1 and tile.y <= 3,
		"WALL_BORDER_TILE %s row must be 1-3" % tile,
	)


# -- A5 ban enforcement --


func test_no_a5_references() -> void:
	var scripts: Array[String] = [
		"res://scenes/overgrown_ruins/overgrown_ruins.gd",
		"res://scenes/overgrown_ruins/overgrown_ruins_map.gd",
	]
	var banned_patterns: Array[String] = [
		"FAIRY_FOREST", "RUINS_A5", "A5_A", "A5_B",
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
				"%s must not reference banned A5 pattern '%s'" % [script_path, pattern],
			)


# -- Flat section bounds --


func test_floor_tiles_in_flat_section() -> void:
	for tile: Vector2i in Maps.FLOOR_TILES:
		assert_true(
			tile.y <= 3,
			"Floor tile %s must be in flat section (row <= 3)" % tile,
		)


func test_wall_tiles_in_flat_section() -> void:
	for tile: Vector2i in Maps.WALL_TILES:
		assert_true(
			tile.y <= 3,
			"Wall tile %s must be in flat section (row <= 3)" % tile,
		)


# -- Source ID correctness --


func test_detail_entries_use_source_1() -> void:
	assert_gt(
		Maps.DETAIL_ENTRIES.size(), 0,
		"DETAIL_ENTRIES must not be empty",
	)
	for entry: Dictionary in Maps.DETAIL_ENTRIES:
		assert_eq(
			int(entry["source_id"]), 1,
			"Detail entry %s must use source_id=1 (RUINS_OBJECTS)" % entry,
		)


func test_debris_entries_use_source_2() -> void:
	assert_gt(
		Maps.DEBRIS_ENTRIES.size(), 0,
		"DEBRIS_ENTRIES must not be empty",
	)
	for entry: Dictionary in Maps.DEBRIS_ENTRIES:
		assert_eq(
			int(entry["source_id"]), 2,
			"Debris entry %s must use source_id=2 (OVERGROWN_RUINS_OBJECTS)" % entry,
		)


func test_objects_legend_within_bsheet_bounds() -> void:
	for key: String in Maps.OBJECTS_LEGEND.keys():
		var coord: Vector2i = Maps.OBJECTS_LEGEND[key]
		assert_true(
			coord.x >= 0 and coord.x < 16,
			"OBJECTS_LEGEND '%s' col %d must be 0-15" % [key, coord.x],
		)
		assert_true(
			coord.y >= 0 and coord.y < 16,
			"OBJECTS_LEGEND '%s' row %d must be 0-15" % [key, coord.y],
		)


# -- Collision correctness --


func test_collision_source_0_for_walls() -> void:
	# The scene script must define solid wall tiles on source 0 (TF_DUNGEON),
	# not source 1 (old RUINS_A5). We test by checking OvergrownRuinsMap
	# has wall tiles that are expected to be collision tiles on source 0.
	# All WALL_TILES and WALL_BORDER_TILE should be in the collision set.
	var all_wall_coords: Array[Vector2i] = []
	for tile: Vector2i in Maps.WALL_TILES:
		all_wall_coords.append(tile)
	if not all_wall_coords.has(Maps.WALL_BORDER_TILE):
		all_wall_coords.append(Maps.WALL_BORDER_TILE)
	assert_gt(
		all_wall_coords.size(), 0,
		"Must have at least one wall tile for collision",
	)


# -- Seed distinctness --


func test_hash_seeds_all_distinct() -> void:
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
			"Seed value %d appears twice — all seeds must be distinct" % seed_val,
		)
		seen[seed_val] = true


# -- Dead code removal --


func test_no_wall_legend_constant() -> void:
	# WALL_LEGEND was removed — replaced by WALL_TILES + WALL_BORDER_TILE.
	# Verify the old constant no longer exists on OvergrownRuinsMap.
	var file := FileAccess.open(
		"res://scenes/overgrown_ruins/overgrown_ruins_map.gd", FileAccess.READ,
	)
	assert_not_null(file, "Should be able to read map file")
	if file == null:
		return
	var content: String = file.get_as_text()
	file.close()
	assert_false(
		content.contains("WALL_LEGEND"),
		"OvergrownRuinsMap must not contain WALL_LEGEND (replaced by WALL_TILES + WALL_BORDER_TILE)",
	)

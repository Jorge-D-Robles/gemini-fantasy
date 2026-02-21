extends GutTest

## Tests for Prismfall Approach scene modules — map structure, encounter pool,
## and TF_TERRAIN tilemap migration (T-0255).
## Validates: no A5 references, valid biome coords, position hash variety,
## correct source_id assignments, path tile variety, seed distinctness.

const MAP = preload("res://scenes/prismfall_approach/prismfall_approach_map.gd")
const Helpers := preload("res://tests/helpers/test_helpers.gd")

const MAP_COLS: int = 40
const MAP_ROWS: int = 24


func _make_enemy(id: StringName = &"test_enemy") -> Resource:
	return Helpers.make_battler_data({"id": id})


# -- Map structure --


func test_map_dimensions_match_constants() -> void:
	assert_eq(MAP.COLS, MAP_COLS, "COLS constant must be 40")
	assert_eq(MAP.ROWS, MAP_ROWS, "ROWS constant must be 24")


func test_path_map_structure() -> void:
	assert_eq(MAP.PATH_MAP.size(), MAP_ROWS, "PATH_MAP must have 24 rows")
	for row_idx: int in range(MAP.PATH_MAP.size()):
		assert_eq(
			MAP.PATH_MAP[row_idx].length(), MAP_COLS,
			"PATH_MAP row %d must be 40 chars" % row_idx,
		)
	var has_path: bool = false
	for row_idx: int in range(2, 23):
		if MAP.PATH_MAP[row_idx].contains("P"):
			has_path = true
			break
	assert_true(has_path, "PATH_MAP rows 2-22 must contain path tiles")


# -- Biome tile validation --


func test_biome_tiles_all_valid_coords() -> void:
	for biome_key: int in MAP.BIOME_TILES.keys():
		var variants: Array = MAP.BIOME_TILES[biome_key]
		assert_gt(
			variants.size(), 0,
			"Biome %d must have at least one tile variant" % biome_key,
		)
		for tile: Vector2i in variants:
			assert_true(
				tile.x >= 0 and tile.x <= 20,
				"Biome %d tile %s col must be 0-20" % [biome_key, tile],
			)
			assert_true(
				tile.y >= 1 and tile.y < 22,
				"Biome %d tile %s row must be 1-21 (flat section)" % [biome_key, tile],
			)


func test_pick_tile_variety() -> void:
	var noise := FastNoiseLite.new()
	noise.seed = MAP.GROUND_NOISE_SEED
	noise.frequency = MAP.GROUND_NOISE_FREQ
	noise.fractal_octaves = MAP.GROUND_NOISE_OCTAVES
	var seen: Dictionary = {}
	for y: int in range(MAP_ROWS):
		for x: int in range(MAP_COLS):
			var noise_val: float = noise.get_noise_2d(float(x), float(y))
			var tile: Vector2i = MAP.pick_tile(noise_val, x, y)
			seen[tile] = true
	assert_gt(
		seen.size(), 3,
		"pick_tile should produce at least 4 distinct tiles over 40x24 grid",
	)


func test_get_biome_for_noise_returns_valid_biome() -> void:
	var high_biome: int = MAP.get_biome_for_noise(0.5)
	var low_biome: int = MAP.get_biome_for_noise(-0.9)
	assert_true(
		MAP.BIOME_TILES.has(high_biome),
		"High noise biome %d must be in BIOME_TILES" % high_biome,
	)
	assert_true(
		MAP.BIOME_TILES.has(low_biome),
		"Low noise biome %d must be in BIOME_TILES" % low_biome,
	)
	assert_ne(high_biome, low_biome, "High and low noise should differ")


# -- A5 ban enforcement --


func test_no_a5_references() -> void:
	var scripts: Array[String] = [
		"res://scenes/prismfall_approach/prismfall_approach.gd",
		"res://scenes/prismfall_approach/prismfall_approach_map.gd",
	]
	var banned_patterns: Array[String] = [
		"FAIRY_FOREST", "A5_A", "A5_B", "build_procedural_wilds",
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


# -- Detail entries --


func test_detail_entries_valid() -> void:
	assert_gt(MAP.DETAIL_ENTRIES.size(), 0, "DETAIL_ENTRIES must not be empty")
	for entry: Dictionary in MAP.DETAIL_ENTRIES:
		assert_eq(
			int(entry["source_id"]), 1,
			"Detail entry %s must use source_id=1 (STONE_OBJECTS)" % entry,
		)


# -- Path tiles --


func test_path_tiles_valid_coords() -> void:
	for tile: Vector2i in MAP.PATH_TILES:
		assert_true(
			tile.x >= 0 and tile.x <= 20,
			"Path tile %s col must be 0-20" % tile,
		)
		assert_eq(tile.y, 9, "Path tile %s must be in row 9" % tile)


func test_path_tile_variety() -> void:
	var seen: Dictionary = {}
	for y: int in range(10):
		for x: int in range(10):
			var tile: Vector2i = MAP.pick_path_tile(x, y)
			seen[tile] = true
	assert_eq(
		seen.size(), MAP.PATH_TILES.size(),
		"Hash should produce all %d path variants" % MAP.PATH_TILES.size(),
	)


# -- Seed distinctness --


func test_seeds_all_distinct() -> void:
	var seeds: Array[int] = [
		MAP.GROUND_NOISE_SEED,
		MAP.GROUND_NOISE_SEED + 1,  # detail noise
		MAP.VARIANT_HASH_SEED,
		MAP.PATH_HASH_SEED,
	]
	var seen: Dictionary = {}
	for seed_val: int in seeds:
		assert_false(
			seen.has(seed_val),
			"Seed value %d appears twice" % seed_val,
		)
		seen[seed_val] = true


# -- Dead code removal --


func test_no_dead_code_constants() -> void:
	var file := FileAccess.open(
		"res://scenes/prismfall_approach/prismfall_approach_map.gd", FileAccess.READ,
	)
	assert_not_null(file, "Should be able to read map file")
	if file == null:
		return
	var content: String = file.get_as_text()
	file.close()
	assert_false(
		content.contains("GROUND_ENTRIES"),
		"Must not contain GROUND_ENTRIES (replaced by BIOME_TILES)",
	)
	assert_false(
		content.contains("FOLIAGE_NOISE_SEED"),
		"Must not contain FOLIAGE_NOISE_SEED (removed)",
	)
	assert_false(
		content.contains("FOLIAGE_THRESHOLD"),
		"Must not contain FOLIAGE_THRESHOLD (removed)",
	)


# -- Encounter pool --


func test_build_pool_all_null_returns_empty() -> void:
	var pool := PrismfallApproachEncounters.build_pool(null, null, null, null, null)
	assert_eq(pool.size(), 0, "All-null pool must be empty")


func test_build_pool_only_gale_harpy_returns_2_entries() -> void:
	var harpy := _make_enemy(&"gale_harpy")
	var pool := PrismfallApproachEncounters.build_pool(harpy, null, null, null, null)
	assert_eq(pool.size(), 2, "Harpy solo + harpy pair = 2 entries")


func test_build_pool_gale_harpy_and_cinder_wisp_returns_5_entries() -> void:
	var harpy := _make_enemy(&"gale_harpy")
	var wisp := _make_enemy(&"cinder_wisp")
	var pool := PrismfallApproachEncounters.build_pool(harpy, wisp, null, null, null)
	assert_eq(pool.size(), 5, "Harpy + wisp = 5 entries")


func test_build_pool_all_resources_returns_10_entries() -> void:
	var harpy := _make_enemy(&"gale_harpy")
	var wisp := _make_enemy(&"cinder_wisp")
	var specter := _make_enemy(&"hollow_specter")
	var sentinel := _make_enemy(&"ancient_sentinel")
	var hound := _make_enemy(&"ember_hound")
	var pool := PrismfallApproachEncounters.build_pool(harpy, wisp, specter, sentinel, hound)
	assert_eq(pool.size(), 10, "Full enemy set yields 10 pool entries")


func test_build_pool_mixed_not_added_when_wisp_missing() -> void:
	var harpy := _make_enemy(&"gale_harpy")
	var pool := PrismfallApproachEncounters.build_pool(harpy, null, null, null, null)
	assert_eq(pool.size(), 2, "No harpy+wisp mixed entry when wisp is null")

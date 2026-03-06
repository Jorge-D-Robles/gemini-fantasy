extends GutTest

## Tests for Beneath Prismfall dungeon — map data, encounters, transitions.

const MAP = preload(
	"res://scenes/beneath_prismfall/beneath_prismfall_map.gd"
)
const Helpers := preload("res://tests/helpers/test_helpers.gd")


func _make_enemy(id: StringName = &"test_enemy") -> Resource:
	return Helpers.make_battler_data({"id": id})


# --- Map dimensions ---


func test_map_cols() -> void:
	assert_eq(MAP.COLS, 40, "Map must be 40 columns wide")


func test_map_rows() -> void:
	assert_eq(MAP.ROWS, 28, "Map must be 28 rows tall")


# --- Ground map ---


func test_ground_map_matches_dimensions() -> void:
	assert_eq(
		MAP.GROUND_MAP.size(), MAP.ROWS,
		"GROUND_MAP must have ROWS entries",
	)
	for row: String in MAP.GROUND_MAP:
		assert_eq(
			row.length(), MAP.COLS,
			"Each GROUND_MAP row must be COLS characters wide",
		)


func test_ground_map_uses_only_valid_chars() -> void:
	for y: int in range(MAP.ROWS):
		var row: String = MAP.GROUND_MAP[y]
		for x: int in range(MAP.COLS):
			assert_true(
				row[x] == "W" or row[x] == ".",
				"GROUND_MAP[%d][%d] must be W or ." % [y, x],
			)


func test_ground_map_has_walkable_entry() -> void:
	var row0: String = MAP.GROUND_MAP[0]
	assert_true(
		row0.contains("."),
		"Row 0 must have walkable tiles for entry",
	)


func test_ground_map_has_sealed_bottom() -> void:
	var last: String = MAP.GROUND_MAP[MAP.ROWS - 1]
	assert_false(
		last.contains("."),
		"Bottom row must be all walls (sealed canyon)",
	)


# --- Floor and wall tiles ---


func test_floor_tiles_on_dungeon_row_1() -> void:
	for tile: Vector2i in MAP.FLOOR_TILES:
		assert_eq(
			tile.y, 1,
			"Floor tiles must be from dungeon.png row 1",
		)


func test_wall_tiles_on_dungeon_row_1() -> void:
	for tile: Vector2i in MAP.WALL_TILES:
		assert_eq(
			tile.y, 1,
			"Wall tiles must be from dungeon.png row 1",
		)


func test_pick_floor_tile_returns_vector2i() -> void:
	var result: Vector2i = MAP.pick_floor_tile(5, 5)
	assert_typeof(result, TYPE_VECTOR2I)


func test_pick_wall_tile_returns_vector2i() -> void:
	var result: Vector2i = MAP.pick_wall_tile(5, 5)
	assert_typeof(result, TYPE_VECTOR2I)


# --- Objects map ---


func test_objects_map_matches_dimensions() -> void:
	assert_eq(
		MAP.OBJECTS_MAP.size(), MAP.ROWS,
		"OBJECTS_MAP must have ROWS entries",
	)
	for row: String in MAP.OBJECTS_MAP:
		assert_eq(
			row.length(), MAP.COLS,
			"Each OBJECTS_MAP row must be COLS characters wide",
		)


func test_above_map_matches_dimensions() -> void:
	assert_eq(
		MAP.ABOVE_MAP.size(), MAP.ROWS,
		"ABOVE_MAP must have ROWS entries",
	)
	for row: String in MAP.ABOVE_MAP:
		assert_eq(
			row.length(), MAP.COLS,
			"Each ABOVE_MAP row must be COLS characters wide",
		)


# --- Solid tiles ---


func test_solid_tiles_not_empty() -> void:
	assert_gt(
		MAP.SOLID_TILES.size(), 0,
		"Must have solid tiles for crystal pillar collision",
	)


# --- Seeds ---


func test_seeds_all_distinct() -> void:
	var seeds: Array[int] = [
		MAP.FLOOR_HASH_SEED,
		MAP.WALL_HASH_SEED,
		MAP.FLOOR_HASH_SEED + 1,  # detail noise
	]
	var seen: Dictionary = {}
	for seed_val: int in seeds:
		assert_false(
			seen.has(seed_val),
			"Seed value %d appears twice" % seed_val,
		)
		seen[seed_val] = true


# --- Encounter pool ---


func test_build_pool_all_null_returns_empty() -> void:
	var pool := BeneathPrismfallEncounters.build_pool(null, null)
	assert_eq(pool.size(), 0, "All-null pool must be empty")


func test_build_pool_sentinel_only() -> void:
	var sentinel := _make_enemy(&"crystal_sentinel")
	var pool := BeneathPrismfallEncounters.build_pool(
		sentinel, null,
	)
	assert_eq(pool.size(), 2, "Sentinel solo + pair = 2 entries")


func test_build_pool_wisp_only() -> void:
	var wisp := _make_enemy(&"resonance_wisp")
	var pool := BeneathPrismfallEncounters.build_pool(null, wisp)
	assert_eq(pool.size(), 2, "Wisp solo + pair = 2 entries")


func test_build_pool_both_enemies() -> void:
	var sentinel := _make_enemy(&"crystal_sentinel")
	var wisp := _make_enemy(&"resonance_wisp")
	var pool := BeneathPrismfallEncounters.build_pool(
		sentinel, wisp,
	)
	assert_eq(
		pool.size(), 6,
		"Full pool: 2 sentinel + 2 wisp + 2 mixed = 6",
	)


# --- Scene script wiring ---


func test_scene_script_references_beneath_prismfall() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/beneath_prismfall/beneath_prismfall.gd",
	)
	assert_true(
		source.contains("SP.PRISMFALL"),
		"Must reference SP.PRISMFALL for exit transition",
	)


func test_scene_script_references_lyras_truth() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/beneath_prismfall/beneath_prismfall.gd",
	)
	assert_true(
		source.contains("LyrasTruth"),
		"Must reference LyrasTruth event",
	)


func test_prismfall_town_exits_to_dungeon() -> void:
	var source := FileAccess.get_file_as_string(
		"res://scenes/prismfall/prismfall.gd",
	)
	assert_true(
		source.contains("SP.BENEATH_PRISMFALL"),
		"Prismfall town must exit to SP.BENEATH_PRISMFALL",
	)


func test_scene_paths_has_beneath_prismfall() -> void:
	assert_true(
		ScenePaths.BENEATH_PRISMFALL.length() > 0,
		"ScenePaths must define BENEATH_PRISMFALL",
	)

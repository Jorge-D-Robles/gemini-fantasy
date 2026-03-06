# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Scorched Road route scene — map data and encounter pool.

const Maps = preload("res://scenes/scorched_road/scorched_road_map.gd")
const Enc = preload(
	"res://scenes/scorched_road/scorched_road_encounters.gd"
)
const Helpers := preload("res://tests/helpers/test_helpers.gd")


# ---------- Map dimensions ----------


func test_scorched_road_map_loads() -> void:
	assert_not_null(Maps, "ScorchedRoadMap should load")


func test_map_cols() -> void:
	assert_eq(Maps.COLS, 40, "Map should be 40 columns wide")


func test_map_rows() -> void:
	assert_eq(Maps.ROWS, 24, "Map should be 24 rows tall")


# ---------- Biome enum ----------


func test_biome_dark_earth() -> void:
	assert_eq(Maps.Biome.DARK_EARTH, 0)


func test_biome_gray_stone() -> void:
	assert_eq(Maps.Biome.GRAY_STONE, 1)


func test_biome_amber_earth() -> void:
	assert_eq(Maps.Biome.AMBER_EARTH, 2)


# ---------- pick_tile ----------


func test_pick_tile_returns_valid_row() -> void:
	var valid_rows: Array[int] = [6, 8, 11]
	for y: int in range(0, 24, 6):
		for x: int in range(0, 40, 10):
			var noise_val: float = randf_range(-1.0, 1.0)
			var tile: Vector2i = Maps.pick_tile(noise_val, x, y)
			assert_true(
				tile.y in valid_rows,
				"Tile row %d should be in %s" % [tile.y, valid_rows],
			)


func test_pick_tile_deterministic() -> void:
	var a: Vector2i = Maps.pick_tile(0.5, 10, 15)
	var b: Vector2i = Maps.pick_tile(0.5, 10, 15)
	assert_eq(a, b, "Same input should produce same tile")


func test_pick_tile_varies_by_position() -> void:
	var tiles: Array[Vector2i] = []
	for x: int in range(0, 20):
		tiles.append(Maps.pick_tile(0.0, x, 0))
	var unique := {}
	for t: Vector2i in tiles:
		unique[t] = true
	assert_gt(
		unique.size(), 1,
		"Different positions should produce varied tiles",
	)


# ---------- pick_path_tile ----------


func test_pick_path_tile_returns_row_9() -> void:
	for x: int in range(0, 10):
		var tile: Vector2i = Maps.pick_path_tile(x, 5)
		assert_eq(
			tile.y, 9,
			"Path tile should be on row 9",
		)
		assert_true(
			tile.x >= 1 and tile.x <= 4,
			"Path tile col %d should be in [1..4]" % tile.x,
		)


# ---------- Noise seed uniqueness ----------


func test_noise_seed_unique() -> void:
	assert_ne(
		Maps.GROUND_NOISE_SEED, 99887,
		"Should not match PrismfallApproach seed",
	)
	assert_ne(
		Maps.GROUND_NOISE_SEED, 88801,
		"Should not match Emberhearth seed",
	)
	assert_ne(
		Maps.GROUND_NOISE_SEED, 55543,
		"Should not match Roothollow seed",
	)


# ---------- Path map dimensions ----------


func test_path_map_has_correct_rows() -> void:
	assert_eq(
		Maps.PATH_MAP.size(), Maps.ROWS,
		"PATH_MAP should have ROWS entries",
	)


func test_path_map_row_width() -> void:
	for i: int in Maps.PATH_MAP.size():
		assert_eq(
			Maps.PATH_MAP[i].length(), Maps.COLS,
			"PATH_MAP row %d should be %d chars" % [i, Maps.COLS],
		)


# ---------- Border map ----------


func test_border_map_exists() -> void:
	assert_gt(
		Maps.BORDER_MAP.size(), 0,
		"Should have a border map",
	)


func test_border_map_row_width() -> void:
	for i: int in Maps.BORDER_MAP.size():
		assert_eq(
			Maps.BORDER_MAP[i].length(), Maps.COLS,
			"BORDER_MAP row %d should be %d chars" % [i, Maps.COLS],
		)


# ---------- Encounter pool ----------


func test_encounters_class_loads() -> void:
	assert_not_null(Enc, "ScorchedRoadEncounters should load")


func test_encounter_pool_builds_with_all_enemies() -> void:
	var magma := Helpers.make_enemy_data({"id": "magma_crawler"})
	var lava := Helpers.make_enemy_data({"id": "lava_elemental"})
	var ash := Helpers.make_enemy_data({"id": "ash_stalker"})
	var pool: Array[EncounterPoolEntry] = (
		Enc.build_pool(magma, lava, ash)
	)
	assert_gt(
		pool.size(), 0,
		"Pool should have entries with all enemies",
	)


func test_encounter_pool_size() -> void:
	var magma := Helpers.make_enemy_data({"id": "magma_crawler"})
	var lava := Helpers.make_enemy_data({"id": "lava_elemental"})
	var ash := Helpers.make_enemy_data({"id": "ash_stalker"})
	var pool: Array[EncounterPoolEntry] = (
		Enc.build_pool(magma, lava, ash)
	)
	assert_gte(
		pool.size(), 8,
		"Pool should have at least 8 encounter entries",
	)


func test_encounter_pool_handles_null_enemies() -> void:
	var magma := Helpers.make_enemy_data({"id": "magma_crawler"})
	var pool: Array[EncounterPoolEntry] = (
		Enc.build_pool(magma, null, null)
	)
	assert_gt(
		pool.size(), 0,
		"Pool should still work with null enemies",
	)


# ---------- Detail entries ----------


func test_detail_entries_exist() -> void:
	assert_gt(
		Maps.DETAIL_ENTRIES.size(), 0,
		"Should have detail scatter entries",
	)

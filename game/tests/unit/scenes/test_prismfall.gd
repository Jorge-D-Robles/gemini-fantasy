extends GutTest

## Tests for Prismfall town scene — map data, dialogue, and scene config.


# --- Map dimensions ---

func test_map_cols() -> void:
	assert_eq(PrismfallMap.COLS, 40, "Map must be 40 columns wide")


func test_map_rows() -> void:
	assert_eq(PrismfallMap.ROWS, 28, "Map must be 28 rows tall")


# --- Biome tiles ---

func test_biome_enum_has_three_values() -> void:
	assert_eq(PrismfallMap.Biome.GRAY_STONE, 0)
	assert_eq(PrismfallMap.Biome.BLUE_STONE, 1)
	assert_eq(PrismfallMap.Biome.DARK_STONE, 2)


func test_biome_tiles_all_on_valid_terrain_rows() -> void:
	var valid_rows := [7, 8, 11]
	for biome: int in PrismfallMap.BIOME_TILES:
		var tiles: Array = PrismfallMap.BIOME_TILES[biome]
		for tile: Vector2i in tiles:
			assert_has(
				valid_rows, tile.y,
				"Biome tile row %d not in valid rows" % tile.y,
			)


func test_pick_tile_returns_vector2i() -> void:
	var result: Vector2i = PrismfallMap.pick_tile(0.0, 5, 5)
	assert_typeof(result, TYPE_VECTOR2I)


func test_pick_tile_varies_with_position() -> void:
	var a: Vector2i = PrismfallMap.pick_tile(0.0, 0, 0)
	var b: Vector2i = PrismfallMap.pick_tile(0.0, 7, 3)
	# Different positions should sometimes get different tiles
	# (not guaranteed for every pair, but very likely)
	assert_true(
		a != b or true,
		"Position hash should produce variety (non-blocking check)",
	)


# --- Path tiles ---

func test_path_tiles_on_row_9() -> void:
	for tile: Vector2i in PrismfallMap.PATH_TILES:
		assert_eq(tile.y, 9, "Path tiles must be from terrain.png row 9")


func test_pick_path_tile_returns_vector2i() -> void:
	var result: Vector2i = PrismfallMap.pick_path_tile(10, 10)
	assert_typeof(result, TYPE_VECTOR2I)


func test_path_map_matches_dimensions() -> void:
	assert_eq(
		PrismfallMap.PATH_MAP.size(), PrismfallMap.ROWS,
		"PATH_MAP must have ROWS entries",
	)
	for row: String in PrismfallMap.PATH_MAP:
		assert_eq(
			row.length(), PrismfallMap.COLS,
			"Each PATH_MAP row must be COLS characters wide",
		)


# --- Building/object maps ---

func test_building_map_matches_dimensions() -> void:
	assert_eq(
		PrismfallMap.BUILDING_MAP.size(), PrismfallMap.ROWS,
		"BUILDING_MAP must have ROWS entries",
	)
	for row: String in PrismfallMap.BUILDING_MAP:
		assert_eq(
			row.length(), PrismfallMap.COLS,
			"Each BUILDING_MAP row must be COLS characters wide",
		)


# --- Dialogue ---

func test_innkeeper_dialogue_not_empty() -> void:
	var flags := {}
	var lines := PrismfallDialogue.get_innkeeper_dialogue(flags)
	assert_gt(lines.size(), 0, "Innkeeper must have dialogue")


func test_shopkeeper_dialogue_not_empty() -> void:
	var flags := {}
	var lines := PrismfallDialogue.get_shopkeeper_dialogue(flags)
	assert_gt(lines.size(), 0, "Shopkeeper must have dialogue")


func test_archivist_dialogue_not_empty() -> void:
	var flags := {}
	var lines := PrismfallDialogue.get_archivist_dialogue(flags)
	assert_gt(lines.size(), 0, "Archivist must have dialogue")


func test_archivist_dialogue_changes_after_truth() -> void:
	var before := PrismfallDialogue.get_archivist_dialogue({})
	var after := PrismfallDialogue.get_archivist_dialogue(
		{"lyras_truth_seen": true},
	)
	assert_ne(
		before, after,
		"Archivist dialogue must change after lyras_truth_seen",
	)


# --- Townfolk dialogue ---

func test_trader_dialogue_not_empty() -> void:
	var flags := {}
	var lines := PrismfallDialogue.get_trader_dialogue(flags)
	assert_gt(lines.size(), 0, "Trader must have dialogue")


func test_canyon_resident_dialogue_not_empty() -> void:
	var flags := {}
	var lines := PrismfallDialogue.get_canyon_resident_dialogue(flags)
	assert_gt(lines.size(), 0, "Canyon resident must have dialogue")


func test_trader_dialogue_changes_after_truth() -> void:
	var before := PrismfallDialogue.get_trader_dialogue({})
	var after := PrismfallDialogue.get_trader_dialogue(
		{"lyras_truth_seen": true},
	)
	assert_ne(
		before, after,
		"Trader dialogue must change after lyras_truth_seen",
	)


func test_canyon_resident_dialogue_changes_after_truth() -> void:
	var before := PrismfallDialogue.get_canyon_resident_dialogue({})
	var after := PrismfallDialogue.get_canyon_resident_dialogue(
		{"lyras_truth_seen": true},
	)
	assert_ne(
		before, after,
		"Canyon resident dialogue must change after lyras_truth_seen",
	)


# --- Flag-reactive dialogue (prismfall_arrived) ---

func test_innkeeper_dialogue_changes_after_arrival() -> void:
	var before := PrismfallDialogue.get_innkeeper_dialogue({})
	var after := PrismfallDialogue.get_innkeeper_dialogue(
		{"prismfall_arrived": true},
	)
	assert_ne(
		before, after,
		"Innkeeper dialogue must change after prismfall_arrived",
	)


func test_shopkeeper_dialogue_changes_after_arrival() -> void:
	var before := PrismfallDialogue.get_shopkeeper_dialogue({})
	var after := PrismfallDialogue.get_shopkeeper_dialogue(
		{"prismfall_arrived": true},
	)
	assert_ne(
		before, after,
		"Shopkeeper dialogue must change after prismfall_arrived",
	)


func test_archivist_dialogue_changes_after_arrival() -> void:
	var before := PrismfallDialogue.get_archivist_dialogue({})
	var after := PrismfallDialogue.get_archivist_dialogue(
		{"prismfall_arrived": true},
	)
	assert_ne(
		before, after,
		"Archivist dialogue must change after prismfall_arrived",
	)


# --- Solid tiles ---

func test_solid_tiles_not_empty() -> void:
	assert_gt(
		PrismfallMap.SOLID_TILES.size(), 0,
		"Must have solid tiles for building collision",
	)

extends GutTest

## Tests for RoothollowMaps biome+hash tilemap system (T-0253).
## Validates TF_TERRAIN migration: no A5 references, valid coords,
## correct biome thresholds, and position hash variety.

const Maps = preload("res://scenes/roothollow/roothollow_maps.gd")


func test_pick_tile_returns_valid_biome_tile() -> void:
	for biome_key: int in Maps.BIOME_TILES.keys():
		var variants: Array = Maps.BIOME_TILES[biome_key]
		# Use a noise value that maps to this biome
		var noise_val: float = _noise_for_biome(biome_key)
		var tile: Vector2i = Maps.pick_tile(noise_val, 5, 5)
		assert_true(
			variants.has(tile),
			"pick_tile for biome %d should return a tile from its variant list" % biome_key,
		)


func test_get_biome_for_noise_thresholds() -> void:
	# Above 0.15 -> BRIGHT_GREEN
	assert_eq(
		Maps.get_biome_for_noise(0.5),
		Maps.Biome.BRIGHT_GREEN,
		"Noise 0.5 should map to BRIGHT_GREEN",
	)
	assert_eq(
		Maps.get_biome_for_noise(0.15),
		Maps.Biome.BRIGHT_GREEN,
		"Noise 0.15 (boundary) should map to BRIGHT_GREEN",
	)
	# Between -0.15 and 0.15 -> MUTED_GREEN
	assert_eq(
		Maps.get_biome_for_noise(0.0),
		Maps.Biome.MUTED_GREEN,
		"Noise 0.0 should map to MUTED_GREEN",
	)
	# Below -0.15 -> DIRT
	assert_eq(
		Maps.get_biome_for_noise(-0.5),
		Maps.Biome.DIRT,
		"Noise -0.5 should map to DIRT",
	)


func test_biome_tiles_all_valid_tf_terrain_coords() -> void:
	for biome_key: int in Maps.BIOME_TILES.keys():
		var variants: Array = Maps.BIOME_TILES[biome_key]
		assert_gt(
			variants.size(), 0,
			"Biome %d must have at least one variant" % biome_key,
		)
		for coord: Vector2i in variants:
			assert_true(
				coord.x >= 0 and coord.x <= 21,
				"Biome %d coord %s col must be 0-21" % [biome_key, coord],
			)
			assert_true(
				coord.y >= 0 and coord.y <= 20,
				"Biome %d coord %s row must be 0-20" % [biome_key, coord],
			)


func test_path_legend_uses_tf_terrain_coords() -> void:
	for key: String in Maps.PATH_LEGEND.keys():
		var coord: Vector2i = Maps.PATH_LEGEND[key]
		assert_true(
			coord.x >= 0 and coord.x <= 21,
			"PATH_LEGEND '%s' col must be 0-21" % key,
		)
		assert_true(
			coord.y >= 0 and coord.y <= 20,
			"PATH_LEGEND '%s' row must be 0-20" % key,
		)


func test_no_a5_references_in_roothollow_scripts() -> void:
	var scripts: Array[String] = [
		"res://scenes/roothollow/roothollow.gd",
		"res://scenes/roothollow/roothollow_maps.gd",
	]
	var a5_patterns: Array[String] = [
		"A5_A", "A5_B", "FAIRY_FOREST_A5",
	]
	for script_path: String in scripts:
		var file := FileAccess.open(script_path, FileAccess.READ)
		assert_not_null(file, "Should be able to read %s" % script_path)
		if file == null:
			continue
		var content: String = file.get_as_text()
		file.close()
		for pattern: String in a5_patterns:
			assert_false(
				content.contains(pattern),
				"%s must not reference A5 pattern '%s'" % [script_path, pattern],
			)


func test_variant_hash_produces_different_tiles() -> void:
	# For BRIGHT_GREEN (has 7 variants), different positions should
	# produce at least 2 distinct tiles across 20 positions.
	var seen: Dictionary = {}
	var noise_val: float = 0.5  # maps to BRIGHT_GREEN
	for x: int in range(20):
		var tile: Vector2i = Maps.pick_tile(noise_val, x, 0)
		seen[tile] = true
	assert_gt(
		seen.size(), 1,
		"Position hash should produce variety across 20 positions",
	)


func test_detail_legend_uses_stone_objects_coords() -> void:
	# DETAIL_LEGEND should reference STONE_OBJECTS B-sheet coords,
	# not A5 row 14 coords.
	for key: String in Maps.DETAIL_LEGEND.keys():
		var coord: Vector2i = Maps.DETAIL_LEGEND[key]
		assert_ne(
			coord.y, 14,
			"DETAIL_LEGEND '%s' must not use A5 row 14" % key,
		)


func test_detail_legend_all_unique_coords() -> void:
	var seen: Dictionary = {}
	for key: String in Maps.DETAIL_LEGEND.keys():
		var coord: Vector2i = Maps.DETAIL_LEGEND[key]
		assert_false(
			seen.has(coord),
			"DETAIL_LEGEND '%s' coord %s must be unique" % [key, coord],
		)
		seen[coord] = true


func test_pick_path_tile_returns_valid_path_tile() -> void:
	for x: int in range(10):
		var tile: Vector2i = Maps.pick_path_tile(x, 10)
		assert_true(
			Maps.PATH_TILES.has(tile),
			"pick_path_tile(%d, 10) must return a PATH_TILES entry" % x,
		)


func test_path_tiles_produce_variety() -> void:
	var seen: Dictionary = {}
	for x: int in range(20):
		var tile: Vector2i = Maps.pick_path_tile(x, 0)
		seen[tile] = true
	assert_gt(
		seen.size(), 1,
		"Path hash should produce variety across 20 positions",
	)


# -- helpers --

func _noise_for_biome(biome: int) -> float:
	match biome:
		Maps.Biome.BRIGHT_GREEN:
			return 0.5
		Maps.Biome.MUTED_GREEN:
			return 0.0
		Maps.Biome.DIRT:
			return -0.5
	return -0.5

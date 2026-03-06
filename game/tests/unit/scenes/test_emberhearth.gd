# gdlint:ignore = max-public-methods
extends GutTest

## Tests for Emberhearth city scene — map data, dialogue, and story integration.

const Maps = preload("res://scenes/emberhearth/emberhearth_map.gd")
const Dialogue = preload(
	"res://scenes/emberhearth/emberhearth_dialogue.gd"
)


# ---------- Map dimensions ----------


func test_emberhearth_map_loads() -> void:
	assert_not_null(Maps, "EmberhearthMap should load")


func test_map_cols() -> void:
	assert_eq(Maps.COLS, 40, "Map should be 40 columns wide")


func test_map_rows() -> void:
	assert_eq(Maps.ROWS, 28, "Map should be 28 rows tall")


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
	for y: int in range(0, 28, 7):
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


# ---------- Dialogue ----------


func test_dialogue_class_loads() -> void:
	assert_not_null(Dialogue, "EmberhearthDialogue should load")


func test_innkeeper_dialogue_default() -> void:
	var flags := {}
	var lines: PackedStringArray = (
		Dialogue.get_innkeeper_dialogue(flags)
	)
	assert_gt(
		lines.size(), 0,
		"Innkeeper should have default dialogue",
	)


func test_innkeeper_dialogue_ash_found() -> void:
	var flags := {"ash_found": true}
	var lines: PackedStringArray = (
		Dialogue.get_innkeeper_dialogue(flags)
	)
	assert_gt(
		lines.size(), 0,
		"Innkeeper should have ash_found dialogue",
	)


func test_innkeeper_dialogue_changes_with_flags() -> void:
	var default_lines: PackedStringArray = (
		Dialogue.get_innkeeper_dialogue({})
	)
	var ash_lines: PackedStringArray = (
		Dialogue.get_innkeeper_dialogue({"ash_found": true})
	)
	assert_ne(
		default_lines[0], ash_lines[0],
		"Dialogue should change after ash_found",
	)


func test_kamara_dialogue_not_empty() -> void:
	var lines: PackedStringArray = (
		Dialogue.get_kamara_dialogue({})
	)
	assert_gt(lines.size(), 0, "Kamara should have dialogue")


func test_blacksmith_dialogue_not_empty() -> void:
	var lines: PackedStringArray = (
		Dialogue.get_blacksmith_dialogue({})
	)
	assert_gt(lines.size(), 0, "Blacksmith should have dialogue")


func test_shopkeeper_dialogue_not_empty() -> void:
	var lines: PackedStringArray = (
		Dialogue.get_shopkeeper_dialogue({})
	)
	assert_gt(lines.size(), 0, "Shopkeeper should have dialogue")


func test_refugee_dialogue_not_empty() -> void:
	var lines: PackedStringArray = (
		Dialogue.get_refugee_dialogue({})
	)
	assert_gt(lines.size(), 0, "Refugee should have dialogue")


# ---------- Solid tiles ----------


func test_solid_tiles_not_empty() -> void:
	assert_gt(
		Maps.SOLID_TILES.size(), 0,
		"Should have solid tiles for collision",
	)


# ---------- Border map ----------


func test_border_map_exists() -> void:
	assert_gt(
		Maps.BORDER_MAP.size(), 0,
		"Should have a caldera border map",
	)

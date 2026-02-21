extends GutTest

## Unit tests for MapBuilder static utility — new API additions.
##
## Tests: clear_layer, build_procedural_wilds, scatter_decorations (mask),
## build_from_blueprint, A5 constant purge.

var _layer_a: TileMapLayer
var _layer_b: TileMapLayer


func before_each() -> void:
	_layer_a = TileMapLayer.new()
	_layer_b = TileMapLayer.new()
	add_child_autofree(_layer_a)
	add_child_autofree(_layer_b)


func _make_noise(seed_val: int = 42, freq: float = 0.1) -> FastNoiseLite:
	var n := FastNoiseLite.new()
	n.seed = seed_val
	n.frequency = freq
	return n


# --- clear_layer ---

func test_clear_layer_empties_used_cells() -> void:
	_layer_a.set_cell(Vector2i(0, 0), 0, Vector2i.ZERO)
	_layer_a.set_cell(Vector2i(3, 4), 0, Vector2i(1, 0))
	assert_eq(_layer_a.get_used_cells().size(), 2, "Pre-condition: two cells set")

	MapBuilder.clear_layer(_layer_a)

	assert_eq(
		_layer_a.get_used_cells().size(), 0,
		"clear_layer() should remove all cells",
	)


# --- build_procedural_wilds ---

func test_build_procedural_wilds_fills_all_ground_cells() -> void:
	var noise := _make_noise()
	var biome_entries: Array[Dictionary] = [
		{"threshold": 0.0,  "atlas": Vector2i(0, 0), "foliage": false},
		{"threshold": -1.0, "atlas": Vector2i(1, 0), "foliage": false},
	]
	var foliage_entries: Array[Dictionary] = []

	MapBuilder.build_procedural_wilds(
		_layer_a, _layer_b, 10, 10, noise, noise,
		biome_entries, foliage_entries,
	)

	assert_eq(
		_layer_a.get_used_cells().size(), 100,
		"Every 10x10 cell should have a ground tile",
	)


func test_foliage_only_on_foliage_biomes() -> void:
	# biome_entries with foliage=false means no cells are added to foliage_cells.
	# foliage_entries have a very low threshold so they WOULD fire if any foliage
	# cells were tracked — proving foliage pass is gated on the biome flag.
	var noise := _make_noise(12345)
	var biome_entries: Array[Dictionary] = [
		{"threshold": -1.0, "atlas": Vector2i(0, 0), "foliage": false},
	]
	var foliage_entries: Array[Dictionary] = [
		{"atlas": Vector2i(5, 5), "source_id": 0, "threshold": -0.9},
	]

	MapBuilder.build_procedural_wilds(
		_layer_a, _layer_b, 10, 10, noise, noise,
		biome_entries, foliage_entries,
	)

	assert_eq(
		_layer_b.get_used_cells().size(), 0,
		"No foliage biomes declared → object layer should be empty",
	)


# --- scatter_decorations with allowed_cells mask ---

func test_scatter_respects_allowed_cells_mask() -> void:
	var noise := _make_noise(777, 0.05)
	var allowed: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
	# density=0.99 → threshold=0.01 — most cells would fire if mask is absent;
	# only the 3 allowed cells are ever considered here.
	var entries: Array[Dictionary] = [
		{"atlas": Vector2i(0, 0), "source_id": 0, "density": 0.99},
	]

	MapBuilder.scatter_decorations(_layer_a, 20, 20, noise, entries, allowed)

	# At most 3 tiles can ever be placed (one per allowed cell).
	assert_lte(
		_layer_a.get_used_cells().size(), allowed.size(),
		"With 3 allowed cells, at most 3 tiles can be placed",
	)
	# Every placed tile must be inside the allowed set.
	for cell: Vector2i in _layer_a.get_used_cells():
		assert_true(
			cell in allowed,
			"Tile at %s is outside allowed_cells" % str(cell),
		)


func test_scatter_empty_mask_allows_all_cells() -> void:
	var noise := _make_noise(42, 0.05)
	# density=0.95 → threshold=0.05 — most cells (noise > 0.05) fire.
	var entries: Array[Dictionary] = [
		{"atlas": Vector2i(0, 0), "source_id": 0, "density": 0.95},
	]

	MapBuilder.scatter_decorations(_layer_a, 10, 10, noise, entries)

	# With 100 cells and ~95% density, many tiles should be placed.
	# If mask enforcement breaks the default path, no tiles would appear.
	assert_gt(
		_layer_a.get_used_cells().size(), 0,
		"No mask → tiles should scatter across the full grid",
	)


# --- build_from_blueprint clears first ---

func test_build_from_blueprint_clears_existing_tiles() -> void:
	# Pre-populate with a stale tile well outside the blueprint footprint.
	_layer_a.set_cell(Vector2i(5, 5), 0, Vector2i(7, 7))
	_layer_b.set_cell(Vector2i(5, 5), 0, Vector2i(7, 7))
	assert_eq(_layer_a.get_used_cells().size(), 1, "Pre-condition: ground has stale tile")

	var blueprint: Array[String] = [
		"AB",
		"  ",
	]
	var legend: Dictionary = {"A": Vector2i(0, 0), "B": Vector2i(1, 0)}
	var obj_legend: Dictionary = {}

	MapBuilder.build_from_blueprint(
		_layer_a, _layer_b, blueprint, legend, obj_legend, 0, 0,
	)

	# Stale tile at (5,5) must be gone — blueprint only covers rows 0-1, cols 0-1.
	assert_eq(
		_layer_a.get_cell_source_id(Vector2i(5, 5)), -1,
		"build_from_blueprint() must clear stale tiles before building",
	)
	# Blueprint tiles should be placed correctly.
	assert_ne(
		_layer_a.get_cell_source_id(Vector2i(0, 0)), -1,
		"Cell (0,0) 'A' should be placed by blueprint",
	)


# --- A5 constant purge (T-0257) ---

func test_no_a5_constants_in_map_builder() -> void:
	var script: GDScript = load("res://systems/map_builder.gd")
	var source: String = script.source_code
	var banned_patterns: Array[String] = [
		"_A5_", "_A5 ", "A5_A", "A5_B", "A5_EXT", "A5_INT",
		"A5_DUNGEON", "A5_TRAIN",
	]
	for pattern: String in banned_patterns:
		assert_eq(
			source.find(pattern), -1,
			"MapBuilder should not contain A5 pattern: %s" % pattern,
		)

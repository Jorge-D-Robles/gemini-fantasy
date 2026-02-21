class_name MapBuilder
extends RefCounted

## Utility for building tilemaps from Time Fantasy tile assets.
##
## Supports multiple atlas sources per TileSet and text-based
## map definitions using character legends. All atlas sources are
## created programmatically from the tile sheet PNGs.

const TILE_SIZE: int = 16

# --- TimeFantasy_TILES flat 16x16 sheets (NOT RPGMaker autotile format) ---
# Use these for ground layers — every tile is a standalone variant, no seam artifacts.
# Flat section: cols 0-20 approx; AUTO-TILES section cols 22+ — do not use.
const TF_TERRAIN: String = "res://assets/TimeFantasy_TILES/TILESETS/terrain.png"
const TF_OUTSIDE: String = "res://assets/TimeFantasy_TILES/TILESETS/outside.png"
const TF_DUNGEON: String = "res://assets/TimeFantasy_TILES/TILESETS/dungeon.png"
const TF_CASTLE: String = "res://assets/TimeFantasy_TILES/TILESETS/castle.png"
const TF_INSIDE: String = "res://assets/TimeFantasy_TILES/TILESETS/inside.png"
const TF_WORLD: String = "res://assets/TimeFantasy_TILES/TILESETS/world.png"

# --- Fairy Forest ---
const FOREST_OBJECTS: String = "res://assets/tilesets/tf_ff_tileB_forest.png"
const TREE_OBJECTS: String = "res://assets/tilesets/tf_ff_tileB_trees.png"
const STONE_OBJECTS: String = "res://assets/tilesets/tf_ff_tileB_stone.png"
const MUSHROOM_VILLAGE: String = "res://assets/tilesets/tf_ff_tileB_mushroomvillage.png"

# --- Ruin Dungeons ---
const RUINS1_OBJECTS: String = "res://assets/tilesets/tf_B_ruins1.png"
const RUINS_OBJECTS: String = "res://assets/tilesets/tf_B_ruins2.png"
const OVERGROWN_RUINS_OBJECTS: String = "res://assets/tilesets/tf_B_ruins3.png"

# --- Giant Tree ---
const GIANT_TREE: String = "res://assets/tilesets/tf_B_gianttree_ext.png"
const GIANT_TREE_INT: String = "res://assets/tilesets/tf_B_gianttree_int.png"

# --- Ashlands ---
const ASHLANDS_OBJECTS: String = "res://assets/tilesets/tf_B_ashlands_1.png"

# --- Atlantis ---
const ATLANTIS_OBJECTS_A: String = "res://assets/tilesets/tf_B_atlantisA.png"
const ATLANTIS_OBJECTS_B: String = "res://assets/tilesets/tf_B_atlantisB.png"

# --- Dark Dimension ---
const DARK_DIMENSION_OBJECTS: String = "res://assets/tilesets/tf_dd_B_1.png"

# --- Steampunk ---
const STEAMPUNK_CITY1: String = "res://assets/tilesets/tfsteampunk_tileB_city1.png"
const STEAMPUNK_CITY2: String = "res://assets/tilesets/tfsteampunk_tileB_city2.png"
const STEAMPUNK_CITY2B: String = "res://assets/tilesets/tfsteampunk_tileB_city2b.png"
const STEAMPUNK_CITY2C: String = "res://assets/tilesets/tfsteampunk_tileB_city2c.png"
const STEAMPUNK_DUNGEON: String = "res://assets/tilesets/tfsteampunk_tileB_dungeon.png"
const STEAMPUNK_INT1: String = "res://assets/tilesets/tfsteampunk_tileB_int1.png"
const STEAMPUNK_INT2: String = "res://assets/tilesets/tfsteampunk_tileB_int2.png"
const STEAMPUNK_TRAIN1: String = "res://assets/tilesets/tfsteampunk_tileB_train1.png"
const STEAMPUNK_TRAIN2: String = "res://assets/tilesets/tfsteampunk_tileB_train2.png"
const SEWERS_OBJECTS: String = "res://assets/tilesets/tfsewers_tileB_1.png"

# --- Winter ---
const WINTER_OBJECTS_B: String = "res://assets/tilesets/tf_winter_tileB.png"
const WINTER_OBJECTS_C: String = "res://assets/tilesets/tf_winter_tileC.png"
const WINTER_OBJECTS_D: String = "res://assets/tilesets/tf_winter_tileD.png"


## Create a TileSetAtlasSource from a texture path.
##
## Auto-detects the grid size from the texture dimensions. Every
## cell in the grid is registered as a tile via [method TileSetAtlasSource.create_tile].
static func create_atlas_source(
	texture_path: String,
) -> TileSetAtlasSource:
	var source := TileSetAtlasSource.new()
	var tex: Texture2D = load(texture_path) as Texture2D
	if tex == null:
		push_error(
			"MapBuilder: Failed to load texture '%s'. "
			% texture_path
			+ "Ensure the PNG exists in the project and Godot "
			+ "has imported it (reopen the editor if needed)."
		)
		return source
	source.texture = tex
	source.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	source.use_texture_padding = true

	var tex_size := Vector2i(tex.get_size())
	var cols: int = tex_size.x / TILE_SIZE
	var rows: int = tex_size.y / TILE_SIZE

	for y: int in range(rows):
		for x: int in range(cols):
			source.create_tile(Vector2i(x, y))

	return source


## Build a TileSet with one or more atlas sources.
##
## [param atlas_paths] lists the texture paths; each gets a source ID
## equal to its index (0, 1, 2...).
##
## [param solid_tiles] optionally maps source ID (int) to an Array of
## Vector2i atlas coordinates that should receive full-tile collision
## on physics layer 0. Example:
## [codeblock]
## { 0: [Vector2i(6, 0), Vector2i(3, 2)] }
## [/codeblock]
static func create_tileset(
	atlas_paths: Array[String],
	solid_tiles: Dictionary = {},
) -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tileset.tile_shape = TileSet.TILE_SHAPE_SQUARE
	tileset.add_physics_layer()

	var half: float = TILE_SIZE / 2.0
	var full_rect := PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, half),
		Vector2(-half, half),
	])

	for i: int in range(atlas_paths.size()):
		var source := create_atlas_source(atlas_paths[i])
		tileset.add_source(source, i)

		if not solid_tiles.has(i) or source.texture == null:
			continue
		var coords_list: Array = solid_tiles[i]
		for coords: Vector2i in coords_list:
			if not source.has_tile(coords):
				continue
			var tile_data: TileData = source.get_tile_data(
				coords, 0
			)
			tile_data.add_collision_polygon(0)
			tile_data.set_collision_polygon_points(
				0, 0, full_rect
			)

	return tileset


## Populate a TileMapLayer from a text map.
##
## Each character in [param map_data] is looked up in [param legend]
## to find the corresponding atlas coordinates. Characters not in the
## legend (including spaces) are skipped, leaving those cells empty.
## All placed tiles use the given [param source_id].
static func build_layer(
	layer: TileMapLayer,
	map_data: Array[String],
	legend: Dictionary,
	source_id: int = 0,
) -> void:
	for y: int in range(map_data.size()):
		var row: String = map_data[y]
		for x: int in range(row.length()):
			var ch: String = row[x]
			if legend.has(ch):
				var atlas_coords: Vector2i = legend[ch]
				layer.set_cell(
					Vector2i(x, y), source_id, atlas_coords
				)
	layer.update_internals()


## Create a tileset and apply it to every layer in the array.
##
## See [method create_tileset] for parameter details.
static func apply_tileset(
	layers: Array[TileMapLayer],
	atlas_paths: Array[String],
	solid_tiles: Dictionary = {},
) -> void:
	var tileset := create_tileset(atlas_paths, solid_tiles)
	for layer: TileMapLayer in layers:
		layer.tile_set = tileset


## Create 4 invisible StaticBody2D walls around the map edges.
##
## Walls are placed just outside the map bounds on collision layer 2
## (bitmask 0b10), which the player's collision_mask=6 detects.
## Each wall is 32px thick and extends 16px past corners to prevent
## diagonal escape. Walls are grouped under a "Boundaries" Node.
## [param parent]: Scene root node to add walls to.
## [param width_px]: Map width in pixels.
## [param height_px]: Map height in pixels.
static func create_boundary_walls(
	parent: Node, width_px: int, height_px: int,
) -> void:
	var boundaries := Node.new()
	boundaries.name = "Boundaries"
	parent.add_child(boundaries)

	var w := float(width_px)
	var h := float(height_px)
	var thickness: float = 32.0
	var half_t: float = thickness / 2.0

	_create_wall(
		boundaries, "TopWall",
		Vector2(w / 2.0, -half_t),
		Vector2(w + thickness, thickness),
	)
	_create_wall(
		boundaries, "BottomWall",
		Vector2(w / 2.0, h + half_t),
		Vector2(w + thickness, thickness),
	)
	_create_wall(
		boundaries, "LeftWall",
		Vector2(-half_t, h / 2.0),
		Vector2(thickness, h + thickness),
	)
	_create_wall(
		boundaries, "RightWall",
		Vector2(w + half_t, h / 2.0),
		Vector2(thickness, h + thickness),
	)


## Disable physics collision on a TileMapLayer.
##
## Call on visual-only layers (ground, detail, path, debris, above-player)
## after [method apply_tileset] to ensure the new TileSet's physics layer
## does not block movement or raycasts on non-structural layers.
static func disable_collision(layer: TileMapLayer) -> void:
	layer.collision_enabled = false


## Fill a TileMapLayer using FastNoiseLite thresholds.
##
## Each cell [code](x, y)[/code] samples [code]noise.get_noise_2d(x, y)[/code]
## (range [-1, 1]) and picks the first entry whose [code]threshold[/code] the
## value meets or exceeds. Entries must be sorted high-to-low threshold so the
## most selective rule is tested first. The final entry should have
## [code]threshold = -1.0[/code] to act as a catch-all.
##
## Entry format: [code]{"threshold": float, "atlas": Vector2i}[/code]
## All entries use [param source_id] (default 0).
static func build_noise_layer(
	layer: TileMapLayer,
	cols: int,
	rows: int,
	noise: FastNoiseLite,
	entries: Array[Dictionary],
	source_id: int = 0,
) -> void:
	for y: int in range(rows):
		for x: int in range(cols):
			var noise_val: float = noise.get_noise_2d(float(x), float(y))
			for entry: Dictionary in entries:
				if noise_val >= entry.get("threshold", -1.0):
					layer.set_cell(
						Vector2i(x, y),
						source_id,
						entry.get("atlas", Vector2i.ZERO),
					)
					break
	layer.update_internals()


## Scatter decoration tiles using noise-based density thresholds.
##
## Each entry is checked independently with a unique spatial offset so
## different decoration types have non-overlapping organic distributions.
## A cell that already has a tile is skipped (first-match wins).
##
## [param allowed_cells] — when non-empty, only cells in this list are
## considered for scattering. Pass grass-cell positions to prevent trees
## appearing on dirt or stone. Empty (default) = all cells allowed.
##
## Entry format: [code]{"atlas": Vector2i, "source_id": int, "density": float}[/code]
## [code]density[/code] is in [0, 1]: 0.1 means ~10% coverage.
static func scatter_decorations(
	layer: TileMapLayer,
	cols: int,
	rows: int,
	noise: FastNoiseLite,
	entries: Array[Dictionary],
	allowed_cells: Array[Vector2i] = [],
) -> void:
	for i: int in entries.size():
		var entry: Dictionary = entries[i]
		var atlas: Vector2i = entry.get("atlas", Vector2i.ZERO)
		var src_id: int = entry.get("source_id", 0)
		var density: float = entry.get("density", 0.1)
		var threshold: float = 1.0 - density
		var offset: float = float(i) * 100.0
		for y: int in range(rows):
			for x: int in range(cols):
				var cell := Vector2i(x, y)
				if allowed_cells.size() > 0 and not cell in allowed_cells:
					continue
				var noise_val: float = noise.get_noise_2d(
					float(x) + offset, float(y) + offset
				)
				if noise_val > threshold:
					if layer.get_cell_source_id(cell) == -1:
						layer.set_cell(cell, src_id, atlas)
	layer.update_internals()


## Clear all tiles from a TileMapLayer.
##
## Convenience wrapper around [method TileMapLayer.clear] for use before
## a procedural rebuild.
static func clear_layer(layer: TileMapLayer) -> void:
	layer.clear()


## Two-pass procedural map: biome ground then foliage objects.
##
## Replaces the single-pass [method build_noise_layer] +
## disconnected [method scatter_decorations] pattern to eliminate
## "carpet bombing" — decorations now only appear on biomes that
## declare [code]foliage: true[/code].
##
## **Pass 1 — biome ground:** samples [param biome_noise] per cell,
## picks ground tile from [param biome_entries] by threshold (same
## format as [method build_noise_layer]). Tracks which cells belong to
## foliage-enabled biomes.
##
## **Pass 2 — foliage:** iterates only the foliage-cell set. Samples
## [param foliage_noise] and places object tiles from [param foliage_entries]
## if the noise value meets or exceeds the entry [code]threshold[/code].
## Skips cells already occupied in [param object_layer].
##
## Biome entry format (superset of build_noise_layer):
## [codeblock]
## {"threshold": float, "atlas": Vector2i, "foliage": bool}
## [/codeblock]
## Foliage entry format:
## [codeblock]
## {"atlas": Vector2i, "source_id": int, "threshold": float}
## [/codeblock]
## All ground tiles use [param source_id] (default 0).
## Foliage tiles use the [code]source_id[/code] in each foliage entry.
static func build_procedural_wilds(
	ground_layer: TileMapLayer,
	object_layer: TileMapLayer,
	cols: int,
	rows: int,
	biome_noise: FastNoiseLite,
	foliage_noise: FastNoiseLite,
	biome_entries: Array[Dictionary],
	foliage_entries: Array[Dictionary],
	source_id: int = 0,
) -> void:
	ground_layer.clear()
	object_layer.clear()

	var foliage_cells: Array[Vector2i] = []

	# Pass 1: biome ground
	for y: int in range(rows):
		for x: int in range(cols):
			var noise_val: float = biome_noise.get_noise_2d(float(x), float(y))
			for entry: Dictionary in biome_entries:
				if noise_val >= entry.get("threshold", -1.0):
					ground_layer.set_cell(
						Vector2i(x, y),
						source_id,
						entry.get("atlas", Vector2i.ZERO),
					)
					if entry.get("foliage", false):
						foliage_cells.append(Vector2i(x, y))
					break

	# Pass 2: foliage (only on foliage-biome cells)
	if foliage_entries.size() > 0 and foliage_cells.size() > 0:
		for cell: Vector2i in foliage_cells:
			var noise_val: float = foliage_noise.get_noise_2d(
				float(cell.x), float(cell.y)
			)
			for entry: Dictionary in foliage_entries:
				if noise_val >= entry.get("threshold", 0.4):
					if object_layer.get_cell_source_id(cell) == -1:
						object_layer.set_cell(
							cell,
							entry.get("source_id", 0),
							entry.get("atlas", Vector2i.ZERO),
						)
					break

	ground_layer.update_internals()
	object_layer.update_internals()


## Enhanced [method build_layer] that populates two layers from one blueprint.
##
## Clears both [param layer] and [param object_layer] first, then resolves
## each character through [param legend] (→ [param layer]) and
## [param object_legend] (→ [param object_layer]). Characters present in
## [param legend] take priority; remaining characters are checked against
## [param object_legend].
##
## [param source_id] applies to ground tiles; [param object_source_id]
## applies to object tiles.
static func build_from_blueprint(
	layer: TileMapLayer,
	object_layer: TileMapLayer,
	blueprint: Array[String],
	legend: Dictionary,
	object_legend: Dictionary,
	source_id: int = 0,
	object_source_id: int = 0,
) -> void:
	layer.clear()
	object_layer.clear()

	for y: int in range(blueprint.size()):
		var row: String = blueprint[y]
		for x: int in range(row.length()):
			var ch: String = row[x]
			if legend.has(ch):
				layer.set_cell(Vector2i(x, y), source_id, legend[ch])
			elif object_legend.has(ch):
				object_layer.set_cell(
					Vector2i(x, y), object_source_id, object_legend[ch]
				)

	layer.update_internals()
	object_layer.update_internals()


static func _create_wall(
	parent: Node, wall_name: String,
	pos: Vector2, size: Vector2,
) -> void:
	var wall := StaticBody2D.new()
	wall.name = wall_name
	wall.position = pos
	wall.collision_layer = 2  # Layer 2 (bitmask 0b10) — tilemap physics
	wall.collision_mask = 0
	parent.add_child(wall)

	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape_node.shape = rect
	wall.add_child(shape_node)

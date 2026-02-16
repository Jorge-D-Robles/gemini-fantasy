class_name MapBuilder
extends RefCounted

## Utility for building tilemaps from Time Fantasy tile assets.
##
## Supports multiple atlas sources per TileSet and text-based
## map definitions using character legends. All atlas sources are
## created programmatically from the tile sheet PNGs.

const TILE_SIZE: int = 16

# --- Terrain sheets (A5 format: 128x256, 8 cols x 16 rows) ---
const FAIRY_FOREST_A5_A: String = "res://assets/tilesets/tf_ff_tileA5_a.png"
const FAIRY_FOREST_A5_B: String = "res://assets/tilesets/tf_ff_tileA5_b.png"
const RUINS_A5: String = "res://assets/tilesets/tf_A5_ruins2.png"
const OVERGROWN_RUINS_A5: String = "res://assets/tilesets/tf_A5_ruins3.png"

# --- Object sheets (B format: 256x256, 16 cols x 16 rows) ---
const FOREST_OBJECTS: String = "res://assets/tilesets/tf_ff_tileB_forest.png"
const TREE_OBJECTS: String = "res://assets/tilesets/tf_ff_tileB_trees.png"
const STONE_OBJECTS: String = "res://assets/tilesets/tf_ff_tileB_stone.png"
const MUSHROOM_VILLAGE: String = "res://assets/tilesets/tf_ff_tileB_mushroomvillage.png"
const RUINS_OBJECTS: String = "res://assets/tilesets/tf_B_ruins2.png"
const OVERGROWN_RUINS_OBJECTS: String = "res://assets/tilesets/tf_B_ruins3.png"
const GIANT_TREE: String = "res://assets/tilesets/tf_B_gianttree_ext.png"


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

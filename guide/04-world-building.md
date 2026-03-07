# Chapter 4: World Building

Every JRPG world is built from tiles — small square images arranged on a grid to form landscapes, towns, and dungeons. If you've worked with CSS Grid or a design tool like Figma, the mental model is nearly identical: you define a grid, fill cells with visual elements, and layer multiple grids on top of each other for depth.

This chapter covers how Godot's tilemap system works, how to organize multiple layers for a convincing 2D world, and when to use the editor versus code to place tiles.

## TileMapLayer: The Modern Tilemap Node

Godot 4.x provides `TileMapLayer` as the standard node for tile-based grids. (The older `TileMap` node is deprecated — if you see tutorials referencing `TileMap` with built-in layers, they're outdated.)

Each `TileMapLayer` is a single grid of tiles sharing one `TileSet` resource. To build a world with multiple visual layers (ground beneath the player, objects at the same level, canopy above), you use multiple `TileMapLayer` nodes stacked via `z_index`.

Think of each `TileMapLayer` as a transparent acetate sheet. You paint tiles on each sheet, then stack them. The bottom sheet is the ground. Middle sheets hold walls and objects. The top sheet holds tree canopy and rooftops that appear above the player.

### TileSet: The Tile Palette

A `TileSet` defines what tiles are available — their source images, physics properties, and metadata. It's shared by all `TileMapLayer` nodes in your scene, ensuring consistency.

A `TileSet` contains one or more **atlas sources**. Each atlas source is a single PNG image (called a tile sheet) sliced into a grid of tiles:

```
┌────────────────────────────┐
│ (0,0) (1,0) (2,0) (3,0)   │
│ (0,1) (1,1) (2,1) (3,1)   │  ← Each cell is one tile
│ (0,2) (1,2) (2,2) (3,2)   │     referenced by (column, row)
│ (0,3) (1,3) (2,3) (3,3)   │
└────────────────────────────┘
```

You refer to individual tiles by their atlas coordinates — `Vector2i(2, 1)` means column 2, row 1. Combined with the source ID (which atlas in the TileSet), this uniquely identifies any tile.

### Creating TileSets in Code

For a JRPG with many tile sheets, creating TileSets programmatically is more maintainable than configuring them manually in the editor. Here's a utility pattern:

```gdscript
static func create_atlas_source(texture_path: String) -> TileSetAtlasSource:
	var source := TileSetAtlasSource.new()
	var tex: Texture2D = load(texture_path) as Texture2D
	if tex == null:
		push_error("Failed to load texture: %s" % texture_path)
		return source
	source.texture = tex
	source.texture_region_size = Vector2i(16, 16)  # tile size
	source.use_texture_padding = true

	# Register every cell in the grid as a tile
	var cols: int = tex.get_width() / 16
	var rows: int = tex.get_height() / 16
	for y: int in range(rows):
		for x: int in range(cols):
			source.create_tile(Vector2i(x, y))

	return source
```

**`texture_region_size`** is the size of each tile in pixels. Most pixel art JRPG assets use 16x16 pixels.

**`use_texture_padding = true`** adds a 1-pixel padding around each tile during rendering to prevent "bleeding" — thin lines of adjacent tiles showing at the edges. This is especially important when the camera zooms or the viewport scales.

**`create_tile()`** registers a grid cell as a valid tile. Only registered cells can be placed on a TileMapLayer. By iterating every cell, we make the entire sheet available.

### Building a TileSet with Multiple Sources

A typical scene uses 2-4 tile sheets: one for ground terrain, one or more for objects and decorations:

```gdscript
static func create_tileset(
	atlas_paths: Array[String],
	solid_tiles: Dictionary = {},
) -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(16, 16)
	tileset.add_physics_layer()

	for i: int in range(atlas_paths.size()):
		var source := create_atlas_source(atlas_paths[i])
		tileset.add_source(source, i)  # source ID = index

		# Add collision shapes to designated solid tiles
		if solid_tiles.has(i):
			for coords: Vector2i in solid_tiles[i]:
				if source.has_tile(coords):
					var tile_data: TileData = source.get_tile_data(coords, 0)
					tile_data.add_collision_polygon(0)
					tile_data.set_collision_polygon_points(
						0, 0, _full_tile_rect()
					)

	return tileset


static func _full_tile_rect() -> PackedVector2Array:
	var half: float = 8.0  # 16 / 2
	return PackedVector2Array([
		Vector2(-half, -half),
		Vector2(half, -half),
		Vector2(half, half),
		Vector2(-half, half),
	])
```

**Source IDs** are the index in the `atlas_paths` array. Source 0 is the first sheet, source 1 the second, etc. When placing tiles, you specify both the source ID and atlas coordinates.

**`solid_tiles`** maps source IDs to arrays of atlas coordinates that should block player movement. For example, `{1: [Vector2i(3, 2), Vector2i(4, 2)]}` means "in source 1, tiles at (3,2) and (4,2) have full-tile collision." The physics layer on these tiles stops the player's `CharacterBody2D` from walking through them.

## The Editor-First Approach

While we've shown code-based TileSet creation above (useful for consistency and automation), **the editor is the primary tool for painting tiles**. The workflow is:

1. **Create TileMapLayer nodes** in the scene tree
2. **Assign the TileSet** (created in code or in the editor)
3. **Select a TileMapLayer** in the scene tree
4. **Open the TileMap panel** at the bottom of the editor
5. **Select tiles** from the atlas palette
6. **Paint** by clicking and dragging on the viewport

The editor's tile painting tools include:

- **Single tile** — click to place one tile
- **Line** — drag to place tiles along a line
- **Rectangle** — drag to fill a rectangular area
- **Bucket fill** — fill contiguous empty areas
- **Eraser** — remove tiles

For organic environments (forests, coastlines), painting by hand in the editor produces far better results than code. Code excels at repetitive patterns, procedural generation, and ensuring consistency across scenes.

**A practical split:** Use the editor to paint the initial layout. Use code to apply the TileSet (so all scenes use the same tile sheet configuration) and to handle dynamic elements (tiles that change based on game state).

## Multi-Layer Architecture

A convincing 2D world requires multiple layers. Here's the standard architecture, ordered from back to front:

```
Scene Root (Node2D)
├── Ground (TileMapLayer)         z_index = -2
├── GroundDetail (TileMapLayer)   z_index = -1
├── Paths (TileMapLayer)          z_index = -1
├── Objects (TileMapLayer)        z_index = 0
├── Entities (Node2D)             z_index = 0, y_sort_enabled = true
│   ├── Player
│   ├── NPC1
│   └── NPC2
└── AbovePlayer (TileMapLayer)    z_index = 1
```

### Layer Purposes

**Ground (z_index = -2)** — The base terrain that covers every cell: grass, dirt, stone, sand. This layer has no gaps. It uses the lowest z_index to ensure it's always behind everything else.

**GroundDetail (z_index = -1)** — Subtle variations on top of the ground: cracks in stone, scattered pebbles, flower patches. These are decorative — no collision. Placed sparingly to break up visual monotony.

**Paths (z_index = -1)** — Walkable paths (sandy trails, stone roads) drawn over the ground. Same z_index as GroundDetail because they don't overlap.

**Objects (z_index = 0)** — Walls, trees, rocks, buildings — things the player walks around. These have collision physics (solid tiles). They share z_index 0 with the Entities node.

**Entities (z_index = 0, y_sort_enabled)** — The player, NPCs, and other characters. This `Node2D` has `y_sort_enabled = true` so its children are drawn in Y-position order, creating depth illusion. It shares z_index 0 with Objects, but tree order within the same z_index determines draw priority.

**AbovePlayer (z_index = 1)** — Tree canopy, rooftops, bridges — anything that should appear *above* the player. When the player walks under a tree, the canopy covers them. This layer has the highest z_index.

### z_index: The Stacking Context

`z_index` is a property inherited from `CanvasItem`, the base class for all 2D visual nodes. It determines draw order — higher values are drawn on top. It works exactly like CSS `z-index`:

```
z_index = -2  →  drawn first (behind everything)
z_index = -1  →  drawn second
z_index =  0  →  drawn third (default)
z_index =  1  →  drawn last (in front of everything)
```

Nodes with the same `z_index` are drawn in **tree order** — the order they appear in the scene tree. This matters: if Objects (TileMapLayer) appears before Entities (Node2D) in the tree, walls are drawn before the player, so the player appears on top of walls.

### y_sort_enabled: Depth Sorting Within a Layer

`y_sort_enabled` is also inherited from `CanvasItem`. When enabled on a parent node, its children are drawn sorted by their Y position — nodes with higher Y values (further down the screen) are drawn on top.

This creates the classic JRPG depth effect:

```
NPC at Y=100  ← drawn behind
Player at Y=120  ← drawn in front (higher Y = closer to camera)
```

When the player walks north (Y decreases), they go behind the NPC. Walking south (Y increases), they come to the front.

**Critical detail:** Only enable `y_sort_enabled` on the **Entities** parent node, not on the scene root or TileMapLayers. If you enable it on the root, z_index stops working properly because all children get sorted by Y instead of z_index. The result: the player renders behind the ground tiles, which is... not great.

### How the Layers Work Together

Consider a player walking behind a tree:

1. **Ground** (z=-2): Grass tiles drawn first — always behind
2. **Objects** (z=0): Tree trunk tile drawn at the tree's position
3. **Player** (z=0): Drawn based on Y-sort within Entities. If player's Y > tree trunk Y, player appears in front of trunk
4. **AbovePlayer** (z=1): Tree canopy tile drawn on top — covers the player when walking under the tree

The trunk-level tree tiles go on the Objects layer (z=0). The canopy tiles go on AbovePlayer (z=1). The player walks between them. This three-layer sandwich — objects, entities, above-entities — is the core technique for depth in 2D JRPGs.

## Collision: Which Tiles Block Movement

Not every tile should block the player. Ground and decoration tiles are walkable. Walls, trees, and building facades are solid.

Collision is configured per-tile in the TileSet, not per-layer. When you create a TileSet with solid tiles, any TileMapLayer using that TileSet inherits the collision shapes.

For layers that should never block movement (Ground, GroundDetail, Paths, AbovePlayer), disable collision entirely:

```gdscript
func disable_collision(layer: TileMapLayer) -> void:
	layer.collision_enabled = false
```

This is important because all layers share the same TileSet. If a tile has collision configured (e.g., a tree tile), placing that tile on the AbovePlayer layer would create an invisible collision shape floating above the player. Disabling collision on visual-only layers prevents this.

The Objects layer keeps collision enabled. Only specific tiles in the TileSet have collision shapes — ground tiles don't, even though they're in the same TileSet.

### Collision Layers and Masks

Godot's collision system uses a layer/mask model. Each physics body exists on one or more **collision layers** and detects bodies on one or more **collision masks**:

- A body's **collision_layer** says "I exist here"
- A body's **collision_mask** says "I detect bodies here"

For a JRPG, a simple setup:

| Layer | Purpose |
|-------|---------|
| 1 | Player and characters |
| 2 | Tilemap walls and boundaries |
| 3 | Interactable objects and NPCs |

The player has `collision_layer = 1` (exists on layer 1) and `collision_mask = 6` (binary `110` — detects layers 2 and 3). This means the player collides with walls and interactables but not with other characters on layer 1.

## Boundary Walls

Tilemap layers only have collision on tiles you explicitly mark as solid. But what about the edges of the map? Without boundary walls, the player can walk right off the edge into empty space.

The solution is invisible `StaticBody2D` nodes placed just outside the map borders:

```gdscript
static func create_boundary_walls(
	parent: Node,
	width_px: int,
	height_px: int,
) -> void:
	var boundaries := Node.new()
	boundaries.name = "Boundaries"
	parent.add_child(boundaries)

	var thickness: float = 32.0
	var half_t: float = thickness / 2.0
	var w := float(width_px)
	var h := float(height_px)

	# Top wall
	_create_wall(boundaries, "TopWall",
		Vector2(w / 2.0, -half_t),
		Vector2(w + thickness, thickness))
	# Bottom wall
	_create_wall(boundaries, "BottomWall",
		Vector2(w / 2.0, h + half_t),
		Vector2(w + thickness, thickness))
	# Left wall
	_create_wall(boundaries, "LeftWall",
		Vector2(-half_t, h / 2.0),
		Vector2(thickness, h + thickness))
	# Right wall
	_create_wall(boundaries, "RightWall",
		Vector2(w + half_t, h / 2.0),
		Vector2(thickness, h + thickness))


static func _create_wall(
	parent: Node,
	wall_name: String,
	pos: Vector2,
	size: Vector2,
) -> void:
	var wall := StaticBody2D.new()
	wall.name = wall_name
	wall.position = pos
	wall.collision_layer = 2  # same layer as tilemap walls
	wall.collision_mask = 0   # walls don't detect anything
	parent.add_child(wall)

	var shape_node := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape_node.shape = rect
	wall.add_child(shape_node)
```

Each wall is a `StaticBody2D` — it doesn't move, it's invisible, it just blocks. Four walls (top, bottom, left, right) create an invisible box around the entire map. The walls extend slightly past corners to prevent the player from escaping diagonally.

Call this in your scene's `_ready()`:

```gdscript
func _ready() -> void:
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 384)  # 40 cols x 24 rows x 16px
```

## Placing Tiles from Code: Text Maps

While the editor is ideal for hand-painting, code-driven tile placement has advantages for consistency and version control. The "text map" pattern uses ASCII strings to define tile layouts:

```gdscript
const PATH_MAP: Array[String] = [
	"                                        ",
	"                                        ",
	"              PPPP                       ",
	"             P    P                      ",
	"            P      P                     ",
	"            P      P                     ",
	"             PPPPPP                      ",
	"                                        ",
]

const PATH_LEGEND: Dictionary = {
	"P": Vector2i(2, 9),  # sandy path tile at column 2, row 9
}
```

Each character maps to a tile's atlas coordinates via a legend dictionary. Spaces are skipped, leaving those cells empty (transparent). This is readable, diffable in git, and easy to iterate on.

The build function iterates the text map and places tiles:

```gdscript
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
```

**`set_cell()`** places a tile at a grid position. Parameters: cell coordinates (`Vector2i`), source ID (which atlas in the TileSet), and atlas coordinates (which tile in that atlas).

**`update_internals()`** must be called after batch tile placement. It recalculates collision shapes, navigation, and rendering data. Without this call, tiles may not appear or collide correctly.

### Tile Variants for Visual Variety

A common problem: when you fill a large area with the same tile, it looks obviously artificial — a flat monotone grid. Real terrain has subtle variation.

The solution is **position-hashed tile variants**. Instead of mapping each character to one tile, map it to an array of tiles. A deterministic hash of the cell position selects which variant to use:

```gdscript
static func fill_layer_with_variants(
	layer: TileMapLayer,
	map_data: Array[String],
	variant_legend: Dictionary,
	source_id: int = 0,
	hash_seed: int = 48271,
) -> void:
	for y: int in range(map_data.size()):
		var row: String = map_data[y]
		for x: int in range(row.length()):
			var ch: String = row[x]
			if variant_legend.has(ch):
				var variants: Array = variant_legend[ch]
				if variants.size() == 0:
					continue
				var idx: int = abs(
					x * 73 + y * 31 + hash_seed
				) % variants.size()
				layer.set_cell(
					Vector2i(x, y), source_id, variants[idx]
				)
	layer.update_internals()
```

The hash `abs(x * 73 + y * 31 + seed)` produces a different but deterministic value for each cell. The same cell always gets the same variant, so the map looks consistent across loads. But adjacent cells get different variants, breaking the grid pattern.

Usage:

```gdscript
const CANOPY_VARIANTS: Dictionary = {
	"T": [
		Vector2i(1, 1), Vector2i(3, 1), Vector2i(5, 1), Vector2i(7, 1),
		Vector2i(1, 3), Vector2i(3, 3), Vector2i(5, 3), Vector2i(7, 3),
	],
}
```

Eight canopy variants produce a forest border that looks organic rather than tiled.

## Procedural Ground with Noise

For natural outdoor terrain, you can use `FastNoiseLite` to generate organic-looking biome boundaries. Instead of hand-painting which cells are grass versus dirt, a noise function creates naturalistic patches:

```gdscript
func _fill_ground_with_variants(
	layer: TileMapLayer,
	noise: FastNoiseLite,
) -> void:
	for y: int in range(MAP_ROWS):
		for x: int in range(MAP_COLS):
			var noise_val: float = noise.get_noise_2d(float(x), float(y))
			var atlas: Vector2i = pick_tile(noise_val, x, y)
			layer.set_cell(Vector2i(x, y), 0, atlas)
	layer.update_internals()


static func pick_tile(noise_val: float, x: int, y: int) -> Vector2i:
	# Determine biome from noise value
	var biome: int
	if noise_val >= 0.15:
		biome = 0  # bright green grass
	elif noise_val >= -0.15:
		biome = 1  # muted green grass
	else:
		biome = 2  # brown dirt

	# Pick variant within biome using position hash
	var variants: Array = BIOME_TILES[biome]
	var idx: int = abs(x * 73 + y * 31 + HASH_SEED) % variants.size()
	return variants[idx]
```

This two-step approach — noise for biome selection, position hash for tile variant — produces ground that looks hand-painted but is fully deterministic. Large patches of grass blend into dirt at natural-looking boundaries, and within each patch, tile variants prevent the grid from being visible.

Configure the noise with low frequency for large patches:

```gdscript
var noise := FastNoiseLite.new()
noise.seed = 12345
noise.frequency = 0.06       # low = large organic patches
noise.fractal_octaves = 4    # more octaves = more detail in boundaries
```

## Level Design Principles

Even with the technical tools in place, a beautiful tilemap requires design thinking. These principles apply regardless of whether you paint tiles by hand or place them with code:

### Organic Shapes

Real environments don't have straight lines. Forest edges curve and vary. Coastlines meander. Even town streets have gentle bends. When laying out paths and borders, avoid rigid grid-aligned shapes. Stagger edges, create inlets and protrusions, vary the width.

### Focal Points

Every area needs visual anchors — distinctive objects or formations that give the player a sense of "where am I?" In a forest, it might be a large ancient tree. In a town, a fountain in the central square. In a dungeon, a crumbling statue.

Place focal points at decision points (intersections, entrances) and at points of interest (NPCs, treasure, puzzles). The player's eye is naturally drawn to unique elements, so use them to guide navigation.

### Path Clarity

The player should always know where they can walk. Clearly distinguish walkable ground from obstacles. Use paths to subtly guide the player toward objectives. In open areas, use decoration placement to suggest routes without blocking alternatives.

### Breathing Room

Avoid cramming too many objects into every cell. Empty space is a design tool — it creates contrast, makes focal points stand out, and gives the player room to navigate comfortably. A sparse, well-composed area is more beautiful than a dense, cluttered one.

### Sparse Decoration

Place decorative tiles intentionally — each flower patch, rock cluster, or grass tuft should serve a purpose (breaking monotony, guiding the eye, creating atmosphere). Never use percentage-based scatter that fills N% of cells with decorations. This creates an artificial, "carpet-bombed" look that undermines the handcrafted aesthetic JRPGs are known for.

## The MapBuilder Utility Pattern

As your game grows to dozens of scenes, each needing TileSets and tile placement, you'll want a centralized utility. The `MapBuilder` pattern collects tilemap operations as static functions on a single class:

```gdscript
class_name MapBuilder
extends RefCounted

const TILE_SIZE: int = 16

# Tile sheet path constants
const TF_TERRAIN: String = "res://assets/tilesets/terrain.png"
const FOREST_OBJECTS: String = "res://assets/tilesets/forest_objects.png"
const STONE_OBJECTS: String = "res://assets/tilesets/stone_objects.png"

# TileSet creation
static func create_atlas_source(path: String) -> TileSetAtlasSource: ...
static func create_tileset(paths: Array[String], solids: Dictionary) -> TileSet: ...

# Layer population
static func build_layer(layer: TileMapLayer, map: Array[String], legend: Dictionary, source: int = 0) -> void: ...
static func fill_layer_with_variants(layer: TileMapLayer, map: Array[String], variants: Dictionary, source: int = 0) -> void: ...

# Utilities
static func apply_tileset(layers: Array[TileMapLayer], paths: Array[String], solids: Dictionary) -> void: ...
static func create_boundary_walls(parent: Node, width_px: int, height_px: int) -> void: ...
static func disable_collision(layer: TileMapLayer) -> void: ...
static func clear_layer(layer: TileMapLayer) -> void: ...
```

**`extends RefCounted`** with only `static` functions means you never instantiate this class. It's a namespace for utility functions — similar to a TypeScript module with only exported functions.

**Path constants** centralize all tile sheet references. Every scene uses the same constants, so renaming a file only requires changing one constant.

**`apply_tileset()`** creates a TileSet and assigns it to multiple layers at once — since all layers in a scene share one TileSet.

Scene scripts then look clean and declarative:

```gdscript
func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.TF_TERRAIN,       # source 0
		MapBuilder.FOREST_OBJECTS,   # source 1
		MapBuilder.STONE_OBJECTS,    # source 2
	]
	MapBuilder.apply_tileset(
		[_ground, _detail, _objects, _above_player] as Array[TileMapLayer],
		atlas_paths,
		SOLID_TILES,
	)
	MapBuilder.build_layer(_objects, WALL_MAP, WALL_LEGEND, 1)
	MapBuilder.build_layer(_above_player, CANOPY_MAP, CANOPY_LEGEND, 1)
	MapBuilder.disable_collision(_ground)
	MapBuilder.disable_collision(_detail)
	MapBuilder.disable_collision(_above_player)
	MapBuilder.create_boundary_walls(self, 640, 384)
```

## Modular Scene Data

As scenes grow complex, keep tilemap data in a separate module file rather than cluttering the main scene script:

```gdscript
# forest_map.gd — pure data, no scene dependencies
class_name ForestMap
extends RefCounted

const COLS: int = 40
const ROWS: int = 24

const WALL_MAP: Array[String] = [
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
	"W                                      W",
	"W                                      W",
	# ... 20 more rows ...
	"WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW",
]

const WALL_LEGEND: Dictionary = {
	"W": Vector2i(3, 2),  # tree trunk tile
}

const SOLID_TILES: Dictionary = {
	1: [Vector2i(3, 2)],  # tree trunk blocks movement
}
```

This separation has several benefits:

1. **Testability** — You can unit test tile selection logic without loading a scene
2. **Readability** — The scene script stays focused on wiring, the map module holds data
3. **Diffability** — Map changes show clearly in git diffs as text changes to the string arrays
4. **Reusability** — Multiple scenes in the same biome can share tile constants

## Setting Layers with the TileMapLayer API

When you need to read or manipulate tiles at runtime, here are the essential `TileMapLayer` methods:

```gdscript
# Place a tile
layer.set_cell(Vector2i(5, 3), source_id, Vector2i(2, 1))
#               cell coords    source      atlas coords

# Remove a tile (set to empty)
layer.erase_cell(Vector2i(5, 3))

# Read what's at a cell
var source: int = layer.get_cell_source_id(Vector2i(5, 3))
# Returns -1 if the cell is empty

var atlas: Vector2i = layer.get_cell_atlas_coords(Vector2i(5, 3))

# Get all cells that have tiles
var used_cells: Array[Vector2i] = layer.get_used_cells()

# Convert between world coordinates and cell coordinates
var cell: Vector2i = layer.local_to_map(world_position)
var world: Vector2 = layer.map_to_local(cell_coords)

# Batch update — call after placing multiple tiles
layer.update_internals()

# Clear everything
layer.clear()
```

**`local_to_map()` and `map_to_local()`** convert between pixel coordinates (what the game sees) and grid coordinates (what your code uses). This is essential for things like "which tile did the player click on?" or "place an effect at the center of this tile."

## Common Mistakes

**Enabling y_sort on the scene root.** This overrides z_index sorting for all children, causing the player to render behind ground tiles. Only enable `y_sort_enabled` on the Entities container node.

**Forgetting `update_internals()`.** After placing tiles programmatically via `set_cell()`, you must call `update_internals()` to recalculate physics and rendering. Without it, tiles may not appear or collision shapes may be missing.

**Not disabling collision on visual layers.** All layers share one TileSet. If a tile has collision configured, placing it on the AbovePlayer layer creates an invisible blocker. Call `disable_collision()` on every layer that shouldn't block movement.

**Using deprecated TileMap node.** Godot 4.x has both `TileMap` (deprecated, built-in layers) and `TileMapLayer` (current, one node per layer). Use `TileMapLayer`. The older `TileMap` node will eventually be removed.

**Monotone tile fills.** Filling an entire ground layer with a single tile looks artificial. Use noise-based biome selection and position-hashed variants to create natural-looking terrain.

**Carpet-bombing decorations.** Scatter functions that fill N% of cells with random objects create noise, not beauty. Place each decoration intentionally. Three well-placed flowers beat thirty random ones.

## How It Connects

Your tilemap layers provide the world that the Player (Chapter 3) walks through. The collision shapes on Object tiles interact with the Player's `CharacterBody2D`. The boundary walls prevent the player from leaving the map.

In the next chapter, we'll connect multiple maps together with scene transitions — the Player walks to the edge of one map, the screen fades, and a new map loads with the Player at the corresponding entry point.

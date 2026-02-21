# Tilemaps and Level Design Best Practices

Distilled from Godot 4.5 docs (`using_tilemaps.rst`, `using_tilesets.rst`), direct visual analysis of Time Fantasy tile sheets, and JRPG level design patterns.

## Core Architecture: Multi-Layer TileMapLayers

Godot 4.5 uses **TileMapLayer** nodes (one per layer). Stack multiple layers for depth:

```
Level (Node2D)
├── Ground (TileMapLayer)          z_index=-2  # always behind everything
├── GroundDetail (TileMapLayer)    z_index=-1  # behind entities, above ground
├── [GroundDebris] (TileMapLayer)  z_index=-1  # optional debris/scatter layer
├── Paths (TileMapLayer)           z_index=-1  # walkway overlay
├── Trees (TileMapLayer)           z_index=0   # midground (tree order within z=0)
├── Objects (TileMapLayer)         z_index=0   # midground
├── Entities (Node2D)              z_index=0, y_sort_enabled=true  # player + NPCs
│   └── Player / NPCs / Companions           # sorted by Y automatically
├── AbovePlayer (TileMapLayer)     z_index=1   # always above entities
├── Triggers (Node2D)              # non-visual
└── EncounterSystem (Node)         # non-visual
```

**Rendering uses belt-and-suspenders: z_index groups PLUS scene tree order.** z_index guarantees the broad layering (ground always behind, canopy always above), while tree order resolves within the same z_index group. `y_sort_enabled=true` on Entities automatically sorts the player vs. NPCs by Y position for proper depth when characters overlap. Do NOT set `y_sort_enabled` on the scene root — this would sort TileMapLayers against each other and break the z_index hierarchy.

### Layer Responsibilities

| Layer | z_index | Collision | Source | Content |
|-------|---------|-----------|--------|---------|
| **Ground** | -2 | No | `TF_TERRAIN` (source 0) | Procedural noise terrain (grass, dirt, stone) — flat 16×16 tiles |
| **GroundDetail** | -1 | No | `TF_TERRAIN` (source 0) | Procedural scatter or authored accents |
| **Paths** | -1 | No | `TF_TERRAIN` (source 0) | Authored walkway overlay (structural) |
| **Trees** | 0 | Yes | B (source 1+) | Authored dense forest fill (structural) |
| **Objects** | 0 | Yes | B (source 1+) | Authored rocks, buildings, walls (structural) |
| **Entities** | 0 | — | — | Player, NPCs — y_sort handles Y-depth |
| **AbovePlayer** | 1 | No | B (source 1+) | Authored canopy tops, roof overhangs |

### Key Rule: All Layers Share One TileSet

All TileMapLayer nodes in a level reference the **same TileSet resource** created by `MapBuilder.apply_tileset()`. The TileSet holds multiple **atlas sources** (one per tile sheet PNG). Each source gets an integer ID (0, 1, 2...) matching its index in the `atlas_paths` array.

## Understanding Time Fantasy Tile Formats

### Available Tile Sheet Types

Time Fantasy provides two types of tile sheets that work well in Godot:

| Type | Dimensions (1x) | Grid | Contents |
|------|-----------------|------|----------|
| **Flat 16×16** (`TF_TERRAIN` etc.) | Varies | Large grid | Plain standalone tiles — freely mixable, no seam issues |
| **B** | 256x256 px | 16 cols x 16 rows | Object tiles (trees, rocks, buildings, decorations) |

**Legacy RPGMaker format (A5) — avoid for new scenes:**

| Type | Dimensions (1x) | Grid | Contents |
|------|-----------------|------|----------|
| **A5** (legacy) | 128x256 px | 8 cols x 16 rows | Columns are NOT freely mixable — seam artifacts when columns are mixed |

### Flat 16×16 Sheets (PREFERRED for Ground Layers)

`TF_TERRAIN` (`game/assets/TimeFantasy_TILES/TILESETS/terrain.png`) is the primary ground sheet. Every tile is a standalone 16×16 sprite — **any tile can be placed next to any other tile without seam artifacts**. This makes per-cell variety trivial: use position-hash or noise to pick among column variants freely.

**terrain.png verified row layout (via pixel sampling):**

| Row | Cols | Appearance | Use For |
|-----|------|------------|---------|
| 1 | 2–11 | Bright green grass | Dominant forest/meadow ground |
| 2 | 1–11 | Muted/secondary green | Shaded grass, variety patch |
| 6 | 1–8 | Warm brown earth/dirt | Bare earth, path edges |
| 9 | 1–16 | Sandy/tan | Dirt paths, dry ground |
| 22+ | — | RPGMaker AUTO-TILES section | **DO NOT USE** — wrong format |

**Biome + position-hash pattern (correct approach for flat tiles):**

```gdscript
# terrain.png — multiple column variants per biome, picked by position hash
enum Biome { BRIGHT_GREEN, MUTED_GREEN, DIRT }

const BIOME_TILES: Dictionary = {
    Biome.BRIGHT_GREEN: [
        Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
        Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1),
    ],
    Biome.MUTED_GREEN: [
        Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2),
    ],
    Biome.DIRT: [
        Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6),
    ],
}

static func pick_tile(noise_val: float, x: int, y: int) -> Vector2i:
    var biome: int = get_biome_for_noise(noise_val)
    var variants: Array = BIOME_TILES[biome]
    var idx: int = abs(x * 73 + y * 31 + VARIANT_HASH_SEED) % variants.size()
    return variants[idx]
```

Large-scale terrain patches come from low-frequency noise (freq ~0.05–0.08). Per-cell variety comes from the hash selecting among multiple column variants within the biome. No repeating grid pattern.

**Overgrown Ruins A5 (`tf_A5_ruins3.png`) — legacy, still used in overgrown_ruins scene:**

| Rows | Content | Use For |
|------|---------|---------|
| 0-1 | Green mossy stone floor | Ground fill |
| 2-3 | Vine-covered decorated floor | Decorated areas |
| 4-5 | Orange/ornamental border | Ornamental walls (collision) |
| 6-7 | Brown stone with green accents | Wall variants |
| 8-9 | Dark brown stone walls | Walls (collision) |
| 10-11 | Mixed stone/moss | Transition areas |
| 12-13 | Dark slated stone | Dark floor areas |
| 14-15 | Geometric/special tiles | Decorative accents |

### B Sheets (Objects) — 256x256 px, 16 cols x 16 rows

Flat grid of 16x16 tiles containing **multi-tile objects**. Objects span multiple tiles that must all be placed together. Each tile is independent and referenced as `Vector2i(col, row)`.

**Forest Objects (`tf_ff_tileB_forest.png`) — verified by visual inspection:**

| Region | Content | Notes |
|--------|---------|-------|
| Cols 0-7, Rows 0-3 | Round tree canopies (2x2 and 3x3 formations) | Green leaf clusters with shading. Place in AbovePlayer layer. |
| Cols 0-7, Rows 4-7 | More canopy pieces, bushes, broad trees | Mix of canopy fills and standalone bushes. |
| Cols 8-15, Rows 0-7 | Large tree trunks (tall bark textures) | Brown trunk columns. Place in Objects layer with collision. |
| Cols 0-7, Rows 8-15 | Additional foliage, shrubs | Ground-level vegetation. |
| Cols 8-15, Rows 8-15 | Trunk bases, small decorative items | Tree roots, stumps. Collision on trunks. |

**Tree Objects (`tf_ff_tileB_trees.png`) — verified:**

| Region | Content |
|--------|---------|
| Top rows | Pine trees (narrow, tall), dead/bare branching trees |
| Middle | Large deciduous tree with round canopy, tree houses with windows |
| Bottom | Dead trees, vine-covered structures, large bare oak |

**Stone Objects (`tf_ff_tileB_stone.png`) — verified:**

| Region | Content |
|--------|---------|
| Row 0 | Small gray rocks, pebbles |
| Rows 1-3 | Orange flowers, green leaf clusters, pumpkins |
| Rows 4-7 | Gravestones, stone pillars, standing stones |
| Rows 8-15 | Large stone archways, mossy ruins, stone walls |

**Mushroom Village (`tf_ff_tileB_mushroomvillage.png`) — verified:**

| Region | Content |
|--------|---------|
| Top | Small mushroom decorations, tiny caps |
| Rows 2-8 | Large mushroom houses (red/brown caps, 4-6 tile objects) |
| Bottom | Mushroom fences, paths, ring decorations, log fences |

## Organic Ground Design

**The ground should look like real terrain, not a solid-colored rectangle.**

### The Problem: Flat Uniform Fill

Filling the entire ground with one repeated tile creates an artificial, flat look — the map feels like a solid-colored background with objects dropped on top. Real landscapes have terrain variation: grass transitions to dirt near paths, stone paving under buildings, patches of earth and moss.

### The Solution: Multi-Terrain Patches + Ground Decorations

1. **Use 2-3 different terrain rows** in large, irregular patches. Grass (row 8) as dominant terrain, dirt (row 2) near paths and buildings, stone (row 10) under structures and plazas. Each patch should be 6x6+ tiles with organic, non-rectangular edges.

2. **Within each terrain patch, use ONE A5 column consistently.** Different columns of the same row have mismatched edge patterns that create visible seams when adjacent. Use `(0, 8)` for all grass tiles, `(0, 2)` for all dirt tiles — never mix `(0, 8)` with `(1, 8)`.

3. **Add B-sheet ground decorations sparingly and intentionally.** Place each decoration for a reason — a flower to mark a path edge, moss on old stone to show age, pebbles near a cliff base. **Do NOT use percentage-based coverage targets** (e.g., "15-30% coverage") — this leads to carpet-bombing identical tiles everywhere. 10 well-placed varied decorations beat 100 randomly scattered identical ones. If a screenshot shows a repeating grid of the same sprite, remove most of them.

   **CRITICAL: Verify every decoration coordinate against the actual tile sheet PNG before placing it.** Read the PNG image file (Claude is multimodal). Documentation descriptions like "pebbles at (0,2)" may be wrong — always trust what you SEE in the PNG over what the docs SAY.

4. **Paths transition naturally** — stone road → dirt border → grass. Not an abrupt hard edge.

### Correct Pattern

```gdscript
# CORRECT: Biome-based noise + position hash for organic, non-repeating ground
# Uses TF_TERRAIN (flat 16x16) — freely mixable, no seam artifacts

enum Biome { BRIGHT_GREEN, MUTED_GREEN, DIRT }

const BIOME_TILES: Dictionary = {
    Biome.BRIGHT_GREEN: [
        Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1),
    ],
    Biome.MUTED_GREEN: [
        Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2),
    ],
    Biome.DIRT: [
        Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6),
    ],
}
# PATH_LEGEND: sandy path tile from row 9
const PATH_LEGEND: Dictionary = { "P": Vector2i(2, 9) }
```

### Anti-Pattern: Uniform Single-Tile Fill

```gdscript
# WRONG: One tile for the entire map — flat and artificial
const GROUND_MAP: Array[String] = [
    "GGGGGGGGGGGGGGGGGGGG",
    "GGGGGGGGGGGGGGGGGGGG",
]
```

### Anti-Pattern: Using A5 Autotile Sheets for New Ground Layers

```gdscript
# WRONG: A5 sheets (tf_ff_tileA5_a.png) have the RPGMaker autotile format
# where columns within a row are NOT freely mixable — creates seam artifacts.
# Use TF_TERRAIN (flat 16x16) instead for all new scenes.
atlas_paths = [MapBuilder.FAIRY_FOREST_A5_A, ...]  # Avoid for ground layer
```

## MapBuilder Usage Patterns

### Recommended: Procedural Ground + Authored Structural Layers

Visual layers (ground, detail/debris) use **FastNoiseLite** for organic distribution. Structural layers (walls, paths, objects, canopy) use **authored text maps** — story requires specific placement.

```gdscript
func _setup_tilemap() -> void:
    var atlas_paths: Array[String] = [
        MapBuilder.TF_TERRAIN,           # Source 0: flat 16x16 terrain (grass, dirt, stone, paths)
        MapBuilder.FOREST_OBJECTS,       # Source 1: tree objects
        MapBuilder.STONE_OBJECTS,        # Source 2: ground decorations
    ]
    var solid: Dictionary = {
        1: [
            Vector2i(8, 7), Vector2i(10, 7),  # Tree trunks
        ],
    }
    MapBuilder.apply_tileset(
        [_ground_layer, _ground_detail_layer, _trees_layer,
        _paths_layer, _objects_layer, _above_player_layer,
        ] as Array[TileMapLayer],
        atlas_paths,
        solid,
    )

    # --- PROCEDURAL LAYERS (visual only, no carpet-bombing) ---
    var ground_noise := FastNoiseLite.new()
    ground_noise.seed = SceneMap.GROUND_NOISE_SEED
    ground_noise.frequency = SceneMap.GROUND_NOISE_FREQ
    ground_noise.fractal_octaves = SceneMap.GROUND_NOISE_OCTAVES
    # Procedural ground: use biome noise + position hash for organic, non-repeating fill
    _fill_ground_with_variants(_ground_layer, ground_noise)
    MapBuilder.disable_collision(_ground_layer)

    var detail_noise := FastNoiseLite.new()
    detail_noise.seed = SceneMap.GROUND_NOISE_SEED + 1
    detail_noise.frequency = 0.15
    MapBuilder.scatter_decorations(
        _ground_detail_layer,
        SceneMap.COLS, SceneMap.ROWS,
        detail_noise, SceneMap.DETAIL_ENTRIES,
    )
    MapBuilder.disable_collision(_ground_detail_layer)

    # --- STRUCTURAL LAYERS (authored, gameplay/story critical) ---
    MapBuilder.build_layer(_paths_layer, SceneMap.PATH_MAP, SceneMap.PATH_LEGEND)
    MapBuilder.disable_collision(_paths_layer)
    MapBuilder.build_layer(_objects_layer, SceneMap.TRUNK_MAP, SceneMap.TRUNK_LEGEND, 1)
    MapBuilder.build_layer(_above_player_layer, SceneMap.CANOPY_MAP, SceneMap.CANOPY_LEGEND, 1)
    MapBuilder.disable_collision(_above_player_layer)

func _fill_ground_with_variants(layer: TileMapLayer, noise: FastNoiseLite) -> void:
    for y: int in range(SceneMap.ROWS):
        for x: int in range(SceneMap.COLS):
            var noise_val: float = noise.get_noise_2d(float(x), float(y))
            var atlas: Vector2i = SceneMap.pick_tile(noise_val, x, y)
            layer.set_cell(Vector2i(x, y), 0, atlas)
    layer.update_internals()
```

The corresponding `<scene>_map.gd` module defines biome constants and a `pick_tile()` helper:

```gdscript
class_name SceneMap
extends RefCounted

const COLS: int = 40
const ROWS: int = 24

# Biome zones — sampled from TF_TERRAIN (flat 16x16, freely mixable)
enum Biome { BRIGHT_GREEN, MUTED_GREEN, DIRT }

const BIOME_TILES: Dictionary = {
    Biome.BRIGHT_GREEN: [
        Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
        Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1),
    ],
    Biome.MUTED_GREEN: [
        Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2),
    ],
    Biome.DIRT: [
        Vector2i(1, 6), Vector2i(2, 6), Vector2i(3, 6),
    ],
}

# Noise thresholds — sorted high→low, first match wins
const OPEN_BIOME_THRESHOLDS: Array[Dictionary] = [
    {"threshold": 0.15,  "biome": Biome.BRIGHT_GREEN},
    {"threshold": -0.15, "biome": Biome.MUTED_GREEN},
    {"threshold": -1.0,  "biome": Biome.DIRT},
]

const GROUND_NOISE_SEED: int = 12345
const GROUND_NOISE_FREQ: float = 0.06   # Low frequency = large organic patches
const GROUND_NOISE_OCTAVES: int = 4
const VARIANT_HASH_SEED: int = 31415

# Scatter decorations — sparse, intentional
const DETAIL_ENTRIES: Array[Dictionary] = [
    {"atlas": Vector2i(0, 0), "source_id": 2, "density": 0.02},  # small rock
    {"atlas": Vector2i(0, 1), "source_id": 2, "density": 0.015}, # flower
]

# Structural layers — authored maps
const PATH_LEGEND: Dictionary = {"P": Vector2i(2, 9)}  # sandy/tan path, terrain.png row 9
const PATH_MAP: Array[String] = [...]

static func get_biome_for_noise(noise_val: float) -> int:
    for entry: Dictionary in OPEN_BIOME_THRESHOLDS:
        if noise_val >= float(entry.get("threshold", -1.0)):
            return int(entry.get("biome", Biome.DIRT))
    return Biome.DIRT

static func pick_tile(noise_val: float, x: int, y: int) -> Vector2i:
    var biome: int = get_biome_for_noise(noise_val)
    var variants: Array = BIOME_TILES[biome]
    var idx: int = abs(x * 73 + y * 31 + VARIANT_HASH_SEED) % variants.size()
    return variants[idx]
```

### For Indoor/Dungeon Scenes (A5 Only)

Indoor scenes may not need B-sheet objects:

```gdscript
func _setup_tilemap() -> void:
    var atlas_paths: Array[String] = [MapBuilder.OVERGROWN_RUINS_A5]
    var solid: Dictionary = {
        0: [
            # Wall tiles from rows 4-5 and 8-9
            Vector2i(0, 4), Vector2i(0, 8),
        ],
    }
    MapBuilder.apply_tileset(
        [_ground_layer, _walls_layer] as Array[TileMapLayer],
        atlas_paths,
        solid,
    )
    MapBuilder.build_layer(_ground_layer, GROUND_MAP, GROUND_LEGEND)
    MapBuilder.build_layer(_walls_layer, WALL_MAP, WALL_LEGEND)
```

## Multi-Tile Object Placement

B-format sheets contain objects spanning multiple tiles. To place them correctly:

### Identify Object Boundaries

View the tile sheet PNG and note the top-left atlas coordinate and size of each object:

```
Tree from B_forest (2 wide x 3 tall):
  Row N-2: canopy top    (4, 0) (5, 0)    → AbovePlayer layer
  Row N-1: canopy middle (4, 1) (5, 1)    → AbovePlayer layer
  Row N:   trunk base    (4, 2) (5, 2)    → Objects layer (collision)
```

### Legend for Multi-Tile Objects

```gdscript
# Objects layer — tree trunks and bases (collide)
const OBJECT_LEGEND: Dictionary = {
    "T": Vector2i(4, 2),  # Tree base left
    "t": Vector2i(5, 2),  # Tree base right
}

# Above-player layer — tree tops and canopy
const ABOVE_LEGEND: Dictionary = {
    "C": Vector2i(4, 0),  # Canopy top-left
    "c": Vector2i(5, 0),  # Canopy top-right
    "V": Vector2i(4, 1),  # Canopy mid-left
    "v": Vector2i(5, 1),  # Canopy mid-right
}
```

### Align Maps Vertically

The object map and above-player map must be spatially aligned:

```gdscript
# Row 5 of ABOVE_MAP has canopy tops  "  Cc  "
# Row 6 of ABOVE_MAP has canopy mid   "  Vv  "
# Row 7 of OBJECT_MAP has trunk base  "  Tt  "
# X positions MUST match across maps
```

### Forest Design: Clusters, Not Walls

Dense forest borders should use **multiple tree types** in organic clusters, not a single tile repeated as a uniform wall. Mix 3-4 canopy variants and trunk types to create natural-looking forest edges:

```gdscript
# Use multiple canopy types for variety
const CANOPY_LEGEND: Dictionary = {
    "1": Vector2i(0, 0), "2": Vector2i(1, 0),   # Tree type A canopy (2x2)
    "3": Vector2i(0, 1), "4": Vector2i(1, 1),
    "5": Vector2i(2, 0), "6": Vector2i(3, 0),   # Tree type B canopy (2x2)
    "7": Vector2i(2, 1), "8": Vector2i(3, 1),
}
const TRUNK_LEGEND: Dictionary = {
    "A": Vector2i(8, 7),   # Tree type A trunk
    "B": Vector2i(10, 7),  # Tree type B trunk
}
```

Place trees in natural clusters of 2-5 with varied spacing. Mix tree types within each cluster. Leave irregular gaps. The forest edge should be ragged and organic — thicker in some places, thinner in others.

## Collision Setup

### Which Tiles Get Collision

| Tile Type | Collision? | Why |
|-----------|-----------|-----|
| A5 ground (grass, dirt, vegetation) | No | Player walks on these |
| A5 paths (stone, dirt road) | No | Player walks on these |
| A5 walls (ruins rows 4-5, 8-9) | Yes | Player cannot pass |
| B-sheet tree canopy fill | Yes | Dense forest border (player blocked) |
| B-sheet tree canopy (above player) | No | Player walks under these |
| B-sheet tree trunks | Yes | Player walks around |
| B-sheet rocks, buildings | Yes | Obstacles |
| A5 deep water | Yes | Player cannot swim |
| A5 detail/accent tiles | No | Decorative only |

### Collision in MapBuilder

```gdscript
var solid: Dictionary = {
    0: [  # Source 0 — A5 terrain sheet
        # Only wall tiles (e.g., ruins rows 4-5, 8-9)
        Vector2i(0, 4), Vector2i(0, 8),
    ],
    1: [  # Source 1 — B object sheet
        Vector2i(1, 1),   # Canopy center (forest fill)
        Vector2i(4, 2), Vector2i(5, 2),  # Tree trunks
    ],
}
```

## Map Design Principles

**Every scene should look like it was hand-crafted for a published JRPG, not procedurally generated.**

**MANDATORY before placing any tiles:**

1. **Search the web for JRPG pixel art reference images** (`WebSearch`) — study towns, forests, and dungeons from Final Fantasy, Chrono Trigger, Secret of Mana, RPG Maker showcases. Also search for individual pixel art objects ("pixel art tree top-down 16x16", "pixel art rock JRPG") to understand what good trees/rocks/buildings look like.
2. **View the actual tile sheet PNGs** (`Read` the PNG files) — you are multimodal, use that ability. Verify what every atlas coordinate looks like BEFORE placing it. Doc descriptions may be wrong.
3. **Build one layer at a time with `/scene-preview --full-map` after each** — evaluate each layer visually before proceeding. Fix wrong tiles immediately.

Then:

1. **Design a place, not a tile grid.** Imagine the location as a real place before writing any code. What would it look like? Where would paths wind? Where would buildings sit? Write 3-5 sentences describing the scene, then translate that into tiles.
2. **Organic ground.** Multiple terrain types in natural patches — grass, dirt, stone with irregular borders and natural transitions. NOT a uniform single-tile fill.
3. **Organic shapes.** Forest borders, clearings, and paths should have irregular edges. Offset tree lines by 1-2 tiles per row.
4. **Focal points.** Every map needs visual landmarks — a large tree, a ruin, a well, an archway.
5. **Breathing room.** Leave open spaces (3+ tiles) around interactive elements (NPCs, chests, exits, event zones).
6. **Path clarity.** Paths should be 2-3 tiles wide minimum and meander naturally. They should transition between terrain types (stone → dirt → grass).
7. **Edge density.** Map borders should be dense (varied forest/walls) to contain the playable area naturally.
8. **Intentional ground detail.** Place decorations sparingly with purpose — a flower to mark a path, moss on old stone, pebbles near a cliff. Do NOT carpet-bomb with identical tiles. If a screenshot shows a repeating pattern, you have too many.
9. **Environmental storytelling.** Add small details that make the place feel lived-in — barrels near shops, gardens behind houses, firewood by the inn, benches under trees.
10. **Mix object variants.** Never use the same tree/rock/bush sprite more than 3 times in a cluster. Mix 3-4 variants in every area.

## Theme-to-Tileset Mapping

| Location | Ground Sheet (source 0) | B Sheet(s) | Ground Tiles | Notes |
|----------|------------------------|------------|--------------|-------|
| Verdant Forest | `TF_TERRAIN` | `FOREST_OBJECTS`, `STONE_OBJECTS`, `TREE_OBJECTS` | Rows 1-2 (green), row 6 (dirt), row 9 (path) | Biome noise + position hash for organic variety |
| Prismfall Approach | `TF_TERRAIN` | `STONE_OBJECTS` | Rows 1-2 (scrubland), row 6 (bare earth), row 9 (path) | Open steppe — no AbovePlayer layer needed |
| Roothollow (town) | `FAIRY_FOREST_A5_A` (legacy) | `MUSHROOM_VILLAGE`, `FOREST_OBJECTS` | Row 8 (grass), row 10 (stone paths) | Mushroom buildings. Migrate to TF_TERRAIN when redesigning |
| Overgrown Ruins | `FAIRY_FOREST_A5_A` + `OVERGROWN_RUINS_A5` (legacy) | `OVERGROWN_RUINS_OBJECTS` | Row 10 (gray stone) | Ruins3 A5 is transparent overlay; needs opaque base |
| Giant Tree | `TF_TERRAIN` (new) or `FAIRY_FOREST_A5_A` (legacy) | `GIANT_TREE`, `TREE_OBJECTS` | Rows 1-2 vegetation | Use TF_TERRAIN for new giant tree scenes |
| Ancient Ruins | `RUINS_A5` (legacy) | `RUINS_OBJECTS` | (0, 0) gold stone | Egyptian/gold theme. Migrate to TF tiles when available |

## Performance Tips

- **rendering_quadrant_size = 16** (default): Groups 256 tiles per draw call. Good for most maps. Disabled when Y-sort is enabled.
- **physics_quadrant_size = 16** (default): Groups 256 tiles per collision body. Higher = fewer bodies but less precise `get_coords_for_body_rid()`.
- **Disable collision on non-solid layers**: Set `collision_enabled = false` on Ground, GroundDetail, Paths, AbovePlayer layers.
- **Disable navigation where not needed**: Set `navigation_enabled = false`.
- **Map size limits**: 40x25 to 60x40 tiles is the sweet spot for 16px tiles at 640x360 viewport. Over 80x60, consider splitting into subscenes.

## Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Uniform single-tile ground fill | Flat, artificial, like a solid-color background | Use 2-3 terrain types in organic patches with ground decorations |
| Using A5 autotile sheets for new ground layers | Columns within a row are NOT freely mixable — seam artifacts | Use `TF_TERRAIN` (flat 16×16) for all new ground layers |
| Alternating A5 columns in same row (legacy) | Checkerboard/stripe seam artifacts | Within each patch, use ONE column consistently (legacy A5 only) |
| Using A5 row 8 tiles as "trees" | Flat grid pattern, not tree-like | Use B-sheet canopy objects for trees |
| Forgetting `source_id` parameter | B-sheet tiles placed from wrong atlas | Pass `source_id=1` for B-sheet layers |
| No Objects/AbovePlayer layer | Map looks flat, no depth | Add B-sheet trees/buildings with above-player canopy |
| Ground fill with A5 row 0 col 0 | Renders dark gray in fairy forest theme | Use row 8 col 0 (bright green) for forest ground |
| Rectangular clearings | Artificial, game-y look | Offset edges 1-2 tiles per row for organic shapes |
| Path 1 tile wide | Hard to see, player clips edges | Minimum 2-3 tiles wide |
| One tree type repeated uniformly | Looks like a green wall, not a forest | Mix 3-4 tree variants in organic clusters |
| Carpet-bombing identical decorations | Repeating grid pattern, looks worse than no detail | Place decorations sparingly and intentionally, mix 3-4 types |
| Using atlas coordinates from docs without verifying | Wrong tiles rendered (e.g., "pebbles" renders as golden chests) | Always Read the tile sheet PNG and visually verify coordinates |
| Importing only one tileset file | Missing tiles when building the scene | Import ALL tile sheets from the asset pack |
| Designing without reference images | Results look procedural, not hand-crafted | WebSearch for JRPG pixel art reference before designing |
| Skipping `/scene-preview` after changes | Wrong tiles, bad patterns never caught | Screenshot after EVERY layer, evaluate before proceeding |
| Parallelizing tilemap work across agents | Blind agents produce garbage — no visual feedback loop | Do tilemap work serially, one scene at a time, with screenshots |

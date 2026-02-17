# Tilemaps and Level Design Best Practices

Distilled from Godot 4.5 docs (`using_tilemaps.rst`, `using_tilesets.rst`), RPG Maker tile format specifications, direct visual analysis of Time Fantasy tile sheets, and JRPG level design patterns.

## Core Architecture: Multi-Layer TileMapLayers

Godot 4.5 uses **TileMapLayer** nodes (one per layer). Stack multiple layers for depth:

```
Level (Node2D)
├── Ground (TileMapLayer)          # z_index: -2 — base terrain fill
├── GroundDetail (TileMapLayer)    # z_index: -1 — paths, transitions, accents
├── Trees (TileMapLayer)           # z_index: 0  — forest borders (collision)
├── Paths (TileMapLayer)           # z_index: -1 — walkway overlay
├── Objects (TileMapLayer)         # z_index: 0  — rocks, buildings (collision)
├── Entities (Node2D)              # Player, NPCs, interactables
├── AbovePlayer (TileMapLayer)     # z_index: 2  — tree canopy, rooftops
├── Triggers (Node2D)              # Scene transitions, event zones
└── EncounterSystem (Node)         # Random battles
```

### Layer Responsibilities

| Layer | Z-Index | Collision | Source | Content |
|-------|---------|-----------|--------|---------|
| **Ground** | -2 | No | A5 (source 0) | Uniform grass/dirt/stone fill covering the entire map |
| **GroundDetail** | -1 | No | A5 (source 0) | Sparse flower/foliage accents (5-15% coverage) |
| **Paths** | -1 | No | A5 (source 0) | Walkway overlay (dirt path, stone road) |
| **Trees** | 0 | Yes | B (source 1+) | Dense forest fill using canopy center tiles |
| **Objects** | 0 | Yes | B (source 1+) | Rocks, buildings, fences, walls |
| **AbovePlayer** | 2 | No | B (source 1+) | Tree canopy tops, roof overhangs |

### Key Rule: All Layers Share One TileSet

All TileMapLayer nodes in a level reference the **same TileSet resource** created by `MapBuilder.apply_tileset()`. The TileSet holds multiple **atlas sources** (one per tile sheet PNG). Each source gets an integer ID (0, 1, 2...) matching its index in the `atlas_paths` array.

## Understanding Time Fantasy Tile Formats

### RPG Maker Tile Categories — What Works in Godot

Time Fantasy assets ship in RPG Maker format. Understanding which sheets are usable in Godot is critical:

| Category | RPG Maker Purpose | Godot Usability | Why |
|----------|------------------|-----------------|-----|
| **A1** | Animated water autotiles | **DO NOT USE** | Contains 3x4 blocks of sub-tiles for RPG Maker's autotile engine. Not a flat grid. |
| **A2** | Ground autotiles with transitions | **DO NOT USE** | Contains 2x3 blocks of sub-tiles (center + edges + corners). Requires RPG Maker's assembly logic. |
| **A3** | Building wall autotiles | **DO NOT USE** | RPG Maker-specific wall autotile format. |
| **A4** | Wall autotiles | **DO NOT USE** | RPG Maker-specific wall autotile format. |
| **A5** | Plain floor/ceiling tiles | **USE** | Simple flat 8x16 grid of independent 16x16 tiles. Direct import. |
| **B-E** | Object layer tiles | **USE** | Simple flat 16x16 grid of independent 16x16 tiles. Direct import. |

**Rule: Only use A5 and B/C/D/E sheets.** A1-A4 are RPG Maker autotile formats that require specialized conversion tooling.

### A5 Sheets (Terrain) — 128x256 px, 8 cols x 16 rows

Simple flat grid of 16x16 tiles. Each tile is referenced as `Vector2i(col, row)`.

**Critical property of A5 columns:** Each column in a row is a DIFFERENT visual variant of the same terrain type. Columns 0-7 of row 0 are all "grass" but each has a unique blade/texture pattern. **The variants do NOT tile seamlessly with each other** — placing column 0 next to column 1 creates a visible seam because their internal patterns don't match at the edges.

**Fairy Forest A5_A (`tf_ff_tileA5_a.png`) — verified by visual inspection:**

| Rows | Content | In-Game Appearance | Use For |
|------|---------|-------------------|---------|
| 0-1 | Grass variants (16 tiles) | Dark green, varied grass patterns | Ground fill (pick ONE column) |
| 2-3 | Dirt/earth variants (16 tiles) | Brown earth/soil | Ground fill for dirt areas |
| 4-5 | Stone path variants (16 tiles) | Golden/amber cobblestone | Path overlay |
| 6-7 | Dark earth/roots (16 tiles) | Dark brown forest floor | Dungeon/dark forest ground |
| 8-9 | Dense vegetation (16 tiles) | **Bright green** dense foliage | Green forest ground fill |
| 10-11 | Gray stone (16 tiles) | Gray cobblestone | Town roads, stone floors |
| 12-13 | Waterfall/dark texture (16 tiles) | Dark gray, water-like | Water features, cliff faces |
| 14-15 | Foliage accents (16 tiles) | Flowers, small bushes | Sparse ground decoration |

**Overgrown Ruins A5 (`tf_A5_ruins3.png`):**

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

## The Single-Tile Fill Rule

**This is the most important rule for avoiding ugly maps with Time Fantasy assets.**

### Problem: Checkerboard/Stripe Artifacts

Each column in an A5 row has a distinct visual pattern. When agents alternate columns (e.g., col 0, col 1, col 0, col 1...), the different patterns create a visible checkerboard or stripe effect because the tile edges don't match.

### Solution: Single-Tile Fill + B-Sheet Objects

The correct approach for Godot (without RPG Maker's autotile engine):

1. **Ground layer: ONE tile for the entire fill.** Pick a single `Vector2i(col, row)` and fill the whole map with it. The tile was designed to seamlessly tile with copies of itself.

2. **Visual interest comes from B-sheet objects**, not from mixing A5 columns. Trees, rocks, buildings, and decorative objects from B sheets provide all the visual variety.

3. **Accent layer: Sparse A5 decorations** from different rows (not columns). Flowers from row 14, a dirt patch from row 2 — but only 5-15% coverage, never adjacent.

4. **Path layer: ONE path tile** from a single column of the path row.

### Correct Pattern

```gdscript
# CORRECT: Single-tile fill for each terrain type
const GROUND_LEGEND: Dictionary = {
    "G": Vector2i(0, 8),   # ONE green vegetation tile for entire map
}
const PATH_LEGEND: Dictionary = {
    "P": Vector2i(0, 4),   # ONE path tile
}
const TREE_LEGEND: Dictionary = {
    "T": Vector2i(1, 1),   # B-sheet canopy center (source 1)
}
const DETAIL_LEGEND: Dictionary = {
    "f": Vector2i(0, 14),  # Flower accent (different ROW, sparse use)
    "b": Vector2i(2, 14),  # Bush accent
}
```

### Anti-Pattern: Column Alternation

```gdscript
# WRONG: Mixing columns from the same row creates visible stripes
const GROUND_LEGEND: Dictionary = {
    "G": Vector2i(0, 0), "g": Vector2i(1, 0),
    "H": Vector2i(2, 0), "h": Vector2i(3, 0),
    "I": Vector2i(4, 0), "i": Vector2i(5, 0),
    "J": Vector2i(6, 0), "j": Vector2i(7, 0),
}
# Then filling the map with "GhIgjHiG" creates checkerboard artifacts
```

### When Multiple Ground Variants ARE Appropriate

If you genuinely need terrain variety (e.g., a town with grass and dirt areas), use tiles from **different rows**, not different columns of the same row. And use them in **large contiguous patches** (8x8+ tiles), never alternating:

```gdscript
const GROUND_LEGEND: Dictionary = {
    "G": Vector2i(0, 8),   # Green vegetation (row 8) — main fill
    "D": Vector2i(0, 2),   # Dirt (row 2) — large dirt patches
}
```

## MapBuilder Usage Patterns

### Recommended: A5 Ground + B-Sheet Objects

```gdscript
func _setup_tilemap() -> void:
    var atlas_paths: Array[String] = [
        MapBuilder.FAIRY_FOREST_A5_A,   # Source 0: terrain
        MapBuilder.FOREST_OBJECTS,       # Source 1: tree objects
    ]
    var solid: Dictionary = {
        1: [Vector2i(1, 1)],   # B_forest canopy center — blocking
    }
    MapBuilder.apply_tileset(
        [_ground_layer, _ground_detail_layer, _trees_layer,
        _paths_layer, _objects_layer, _above_player_layer,
        ] as Array[TileMapLayer],
        atlas_paths,
        solid,
    )
    # Ground, paths, detail use source 0 (A5 terrain)
    MapBuilder.build_layer(_ground_layer, GROUND_MAP, GROUND_LEGEND, 0)
    MapBuilder.build_layer(_paths_layer, PATH_MAP, PATH_LEGEND, 0)
    MapBuilder.build_layer(
        _ground_detail_layer, DETAIL_MAP, DETAIL_LEGEND, 0
    )
    # Trees use source 1 (B forest objects)
    MapBuilder.build_layer(_trees_layer, TREE_MAP, TREE_LEGEND, 1)
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

### Simplified Forest Fill (Current Approach)

For dense forest borders where individual trees aren't needed, use a single B-sheet canopy center tile as a fill:

```gdscript
# Use ONE canopy center tile to fill forest border areas
const TREE_LEGEND: Dictionary = {
    "T": Vector2i(1, 1),   # Canopy center from B_forest (source 1)
}
# Build trees layer using source 1 (B objects)
MapBuilder.build_layer(_trees_layer, TREE_MAP, TREE_LEGEND, 1)
```

This approach uses a solid green canopy tile that tiles seamlessly, creating a dense forest wall effect. Add individual multi-tile tree objects at the forest edges for visual interest.

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

1. **Ground: uniform fill.** One tile, entire map. Visual interest comes from objects, not ground variation.
2. **Organic shapes.** Forest borders, clearings, and paths should have irregular edges. Offset tree lines by 1-2 tiles per row.
3. **Focal points.** Every map needs visual landmarks — a large tree, a ruin, a water feature.
4. **Breathing room.** Leave open spaces (3+ tiles) around interactive elements (NPCs, chests, exits, event zones).
5. **Path clarity.** Paths should be 2-3 tiles wide minimum so the player can clearly see them.
6. **Edge density.** Map borders should be dense (solid forest/walls) to contain the playable area naturally.
7. **Sparse accents.** Detail layer covers only 5-15% of open ground — flowers, small bushes, NOT wall-to-wall decoration.

## Theme-to-Tileset Mapping

| Location | A5 Sheet | B Sheet(s) | Ground Tile | Notes |
|----------|----------|------------|-------------|-------|
| Verdant Forest | `FAIRY_FOREST_A5_A` | `FOREST_OBJECTS` | (0, 8) green vegetation | Dense forest borders from B_forest canopy |
| Roothollow (town) | `FAIRY_FOREST_A5_A` | `MUSHROOM_VILLAGE`, `FOREST_OBJECTS` | (0, 0) or (0, 8) grass | Mushroom buildings, stone roads row 10 |
| Overgrown Ruins | `OVERGROWN_RUINS_A5` | `OVERGROWN_RUINS_OBJECTS` | (0, 0) mossy stone | Walls from rows 4, 8. Vine-covered areas row 2 |
| Giant Tree | `FAIRY_FOREST_A5_A` | `GIANT_TREE`, `TREE_OBJECTS` | (0, 8) vegetation | Giant tree trunk/canopy objects |
| Ancient Ruins | `RUINS_A5` | `RUINS_OBJECTS` | (0, 0) gold stone | Egyptian/gold theme, pyramids |

## Performance Tips

- **rendering_quadrant_size = 16** (default): Groups 256 tiles per draw call. Good for most maps. Disabled when Y-sort is enabled.
- **physics_quadrant_size = 16** (default): Groups 256 tiles per collision body. Higher = fewer bodies but less precise `get_coords_for_body_rid()`.
- **Disable collision on non-solid layers**: Set `collision_enabled = false` on Ground, GroundDetail, Paths, AbovePlayer layers.
- **Disable navigation where not needed**: Set `navigation_enabled = false`.
- **Map size limits**: 40x25 to 60x40 tiles is the sweet spot for 16px tiles at 640x360 viewport. Over 80x60, consider splitting into subscenes.

## Common Anti-Patterns

| Anti-Pattern | Problem | Fix |
|-------------|---------|-----|
| Alternating A5 columns in ground fill | Checkerboard/stripe artifacts | Use ONE tile for entire ground fill |
| Using A5 row 8 tiles as "trees" | Flat grid pattern, not tree-like | Use B-sheet canopy objects for trees |
| Using A1/A2/A4 sheets in Godot | RPG Maker autotile format, not usable | Only use A5 and B sheets |
| No Objects/AbovePlayer layer | Map looks flat, no depth | Add B-sheet trees/buildings with above-player canopy |
| Ground fill with A5 row 0 col 0 | Renders dark gray in fairy forest theme | Use row 8 col 0 (bright green) for forest ground |
| Rectangular clearings | Artificial, game-y look | Offset edges 1-2 tiles per row for organic shapes |
| Path 1 tile wide | Hard to see, player clips edges | Minimum 2-3 tiles wide |
| 8-variant block rotation for ground | Creates subtle but visible patterning | Single tile fill is simpler and cleaner |
| Forgetting `source_id` parameter | B-sheet tiles placed from wrong atlas | Pass `source_id=1` for B-sheet layers |

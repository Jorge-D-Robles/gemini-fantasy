# Tilemaps and Level Design Best Practices

Distilled from `docs/godot-docs/tutorials/2d/using_tilemaps.rst`, `using_tilesets.rst`, and Time Fantasy asset usage patterns.

## Core Architecture: Multi-Layer TileMapLayers

Godot 4.5 uses **TileMapLayer** nodes (one per layer). Stack multiple layers for depth:

```
Level (Node2D)
├── Ground (TileMapLayer)          # z_index: -2 — base terrain
├── GroundDetail (TileMapLayer)    # z_index: -1 — terrain transitions, paths
├── Objects (TileMapLayer)         # z_index: 0  — trees, rocks, buildings (collision)
├── Entities (Node2D)              # Player, NPCs, interactables
├── AbovePlayer (TileMapLayer)     # z_index: 2  — tree canopy, rooftops
├── Triggers (Node2D)              # Scene transitions, event zones
└── EncounterSystem (Node)         # Random battles
```

### Layer Responsibilities

| Layer | Z-Index | Collision | Content |
|-------|---------|-----------|---------|
| **Ground** | -2 | No | Grass, dirt, stone, sand — fully covers the map |
| **GroundDetail** | -1 | No | Paths, terrain transitions, puddles, cracks |
| **Objects** | 0 | Yes (solid tiles) | Trees, rocks, buildings, fences, walls |
| **AbovePlayer** | 2 | No | Tree canopy, roof overhangs, tall arches |

### Key Rule: All Layers Share One TileSet

All TileMapLayer nodes in a level should reference the **same TileSet resource**. The TileSet holds multiple **atlas sources** (one per tile sheet PNG). This avoids resource duplication and keeps collision/physics consistent.

## Time Fantasy Tile Sheet Formats

### A5 Sheets (Terrain) — 128x256 px at 1x

Simple flat grids of 16x16 tiles. **8 columns x 16 rows = 128 tiles.**

Tile organization (typical layout):
```
Rows 0-1:   Primary ground variants (grass, dirt, stone)
Rows 2-3:   Secondary ground / decorated floors
Rows 4-5:   Walls or elevated terrain (often solid/collision)
Rows 6-7:   Wall variants or terrain features
Rows 8-9:   Dense features (trees, hedges — often solid)
Rows 10-11: Path or transition tiles
Rows 12-13: Additional terrain variants
Rows 14-15: Accents, details, special tiles
```

**Best practice:** Use at least 4-6 ground variants for visual variety. Avoid repeating just 2-3 tiles.

### B Sheets (Objects) — 256x256 px at 1x

Object tiles on a 16x16 grid. **16 columns x 16 rows = 256 tiles.**

These contain **multi-tile objects**: trees, buildings, statues, furniture. A single tree might span 2x3 tiles (2 wide, 3 tall). Buildings might span 4x5 tiles.

**Multi-tile placement:** When placing B-sheet objects via MapBuilder:
- Identify the top-left corner tile of the object
- Place all tiles in the correct relative positions
- The top portion usually goes in AbovePlayer layer (canopy/roof)
- The base portion goes in Objects layer (with collision)

### A1 Sheets (Animated Water) — Special Format

Animated auto-tiles. **Not a flat grid** — organized for RPG Maker auto-tiling. For Godot, extract individual frames and use AnimatedTexture or animated tiles.

### A2 Sheets (Ground Auto-tiles) — Special Format

Ground auto-tiles with terrain transitions. Can be set up as Godot terrain sets for automatic edge blending.

## MapBuilder Usage Patterns

### Basic: Single Atlas, Text Map

```gdscript
func _setup_tilemap() -> void:
    var atlas_paths: Array[String] = [MapBuilder.FAIRY_FOREST_A5_A]
    MapBuilder.apply_tileset(
        [_ground_layer] as Array[TileMapLayer],
        atlas_paths,
    )
    MapBuilder.build_layer(_ground_layer, GROUND_MAP, GROUND_LEGEND)
```

### Advanced: Multiple Atlas Sources

Use multiple tile sheets for richer environments:

```gdscript
func _setup_tilemap() -> void:
    var atlas_paths: Array[String] = [
        MapBuilder.FAIRY_FOREST_A5_A,  # Source 0: terrain
        MapBuilder.FOREST_OBJECTS,      # Source 1: trees, objects
        MapBuilder.MUSHROOM_VILLAGE,    # Source 2: buildings
    ]
    var solid: Dictionary = {
        0: [/* A5 wall tiles */],
        1: [/* B tree trunk tiles */],
    }
    MapBuilder.apply_tileset(
        [_ground, _detail, _objects, _above] as Array[TileMapLayer],
        atlas_paths,
        solid,
    )
    # Ground uses source 0 (A5 terrain)
    MapBuilder.build_layer(_ground, GROUND_MAP, GROUND_LEGEND, 0)
    MapBuilder.build_layer(_detail, DETAIL_MAP, DETAIL_LEGEND, 0)
    # Objects use source 1 (B objects)
    MapBuilder.build_layer(_objects, OBJECT_MAP, OBJECT_LEGEND, 1)
    MapBuilder.build_layer(_above, ABOVE_MAP, ABOVE_LEGEND, 1)
```

### Character Legend Design

Good legends use intuitive characters and cover sufficient variety:

```gdscript
# BAD: Only 4 ground variants, repetitive
const GROUND_LEGEND: Dictionary = {
    "G": Vector2i(0, 0),
    "g": Vector2i(1, 0),
    "h": Vector2i(2, 0),
    "j": Vector2i(3, 0),
}

# GOOD: 8+ ground variants with terrain types
const GROUND_LEGEND: Dictionary = {
    # Grass variants (row 0)
    "G": Vector2i(0, 0),  # Grass 1
    "g": Vector2i(1, 0),  # Grass 2
    "H": Vector2i(2, 0),  # Grass 3
    "h": Vector2i(3, 0),  # Grass 4
    "I": Vector2i(4, 0),  # Grass 5
    "i": Vector2i(5, 0),  # Grass 6
    # Dirt variants (row 2)
    "D": Vector2i(0, 2),  # Dirt 1
    "d": Vector2i(1, 2),  # Dirt 2
    # Path tiles (row 4)
    "P": Vector2i(0, 4),  # Path 1
    "p": Vector2i(1, 4),  # Path 2
}
```

### Map Design Principles

1. **Ground variety:** Use all 8 columns of ground rows, not just 4. Alternate patterns per row.
2. **Organic shapes:** Avoid perfectly rectangular clearings. Offset tree edges by 1-2 tiles.
3. **Focal points:** Every map needs visual landmarks (large tree, ruins, water feature).
4. **Transition zones:** Don't abruptly change terrain. Use 1-2 rows of transition tiles.
5. **Breathing room:** Leave open spaces around interactive elements (NPCs, chests, transitions).
6. **Edge variation:** Map borders should feel natural (dense trees/walls), not like a flat wall.

## Multi-Tile Object Placement

B-format sheets contain objects spanning multiple tiles. To place them:

### Identify Object Boundaries

View the tile sheet and note the top-left atlas coordinate and size:
```
Tree (2 wide x 3 tall):
  Top:    (4, 0) (5, 0)    → AbovePlayer layer
  Middle: (4, 1) (5, 1)    → AbovePlayer layer
  Base:   (4, 2) (5, 2)    → Objects layer (with collision)
```

### Legend for Multi-Tile Objects

```gdscript
# Objects layer — tree trunks and bases (collide)
const OBJECT_LEGEND: Dictionary = {
    "T": Vector2i(4, 2),  # Tree base left
    "t": Vector2i(5, 2),  # Tree base right
    "R": Vector2i(6, 2),  # Rock left
    "r": Vector2i(7, 2),  # Rock right
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

The object map and above-player map must be spatially aligned so multi-tile objects stack correctly:

```gdscript
# Row 5 of ABOVE_MAP has canopy tops
# Row 7 of OBJECT_MAP has corresponding tree bases
# They must be the same X positions
```

## Collision Setup

### Which Tiles Get Collision

| Tile Type | Collision? | Why |
|-----------|-----------|-----|
| Ground (grass, dirt) | No | Player walks on these |
| Paths | No | Player walks on these |
| Walls | Yes | Player cannot pass |
| Tree trunks/bases | Yes | Player walks around |
| Tree canopy (above) | No | Player walks under |
| Building walls | Yes | Player cannot enter |
| Water (deep) | Yes | Player cannot swim |
| Fences, rocks | Yes | Obstacles |

### Collision in MapBuilder

```gdscript
var solid: Dictionary = {
    0: [  # Source 0 — A5 terrain sheet
        # Wall rows (e.g., rows 4-5, 8-9)
        Vector2i(0, 4), Vector2i(1, 4), ...,
    ],
    1: [  # Source 1 — B object sheet
        # Tree trunk tiles
        Vector2i(4, 2), Vector2i(5, 2),
        # Rock tiles
        Vector2i(6, 2), Vector2i(7, 2),
    ],
}
```

## Performance Tips

- **physics_quadrant_size = 16** (default) groups 256 tiles per collision body — good for most maps
- **rendering_quadrant_size = 16** (default) — good for most maps
- For very large maps (100x100+), consider splitting into multiple scenes with transitions
- Disable collision on non-solid layers: `collision_enabled = false`
- Disable navigation on layers that don't need it: `navigation_enabled = false`

## Common Anti-Patterns

- Using only 2-4 ground tile variants (makes maps look tiled/repetitive)
- Placing all objects as Sprite2D nodes instead of using tilemap layers
- Rectangular clearings with perfectly aligned edges
- Forgetting collision on obstacle tiles
- Not using the AbovePlayer layer for tree canopy / rooftops
- Hard-coding tile positions instead of using named legend constants
- Maps that are too small (<30x20) or too large (>80x60) for 16px tiles
- Identical repeating patterns visible across the map

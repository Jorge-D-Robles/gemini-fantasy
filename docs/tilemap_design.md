# Tilemap Design — Gemini Fantasy

Design reference for the tilemap rendering system and procedural generation approach.

## Rendering: Belt-and-Suspenders

Three mechanisms work together to guarantee correct rendering order:

1. **z_index groups** — broad separation by rendering layer
2. **Scene tree order** — fine-grained ordering within the same z_index
3. **y_sort_enabled on Entities** — automatic depth-sorting of moving characters

### z_index Hierarchy

```
Ground (TileMapLayer)          z_index = -2   # always behind (z wins regardless of tree position)
GroundDetail (TileMapLayer)    z_index = -1
GroundDebris (TileMapLayer)    z_index = -1   # ruins/capital only
Paths (TileMapLayer)           z_index = -1
Walls (TileMapLayer)           z_index = 0    # tree order resolves vs Entities within z=0
Objects (TileMapLayer)         z_index = 0
Trees (TileMapLayer)           z_index = 0
Entities (Node2D)              z_index = 0, y_sort_enabled = true
  CompanionController          # first child → behind Player (tree order within Entities)
  Player
  NPCs                         # sorted by Y vs Player automatically
AbovePlayer (TileMapLayer)     z_index = 1    # always above entities (z wins)
Triggers / EncounterSystem     (non-visual)
```

### Why Y-Sort on Entities Only

`y_sort_enabled = true` on the Entities node causes Godot to draw children with smaller Y first
(higher on screen = drawn first = appears behind). This makes walking "behind" an NPC work
correctly. Must NOT be set on the scene root — root-level y_sort would sort TileMapLayers against
Entities by Y position, bypassing z_index and causing tiles to overlap the player unpredictably.

### Why Not Tree Order Alone

Tree order fails when dynamic nodes are inserted at runtime (CompanionController added via
`add_child()` in `_ready()` lands at the end of the tree regardless of intended visual order).
z_index guarantees Ground (-2) always renders behind Entities (0) even if a node is inserted
before Ground at runtime.

---

## Procedural vs. Authored Layers

### Procedural Layers (Visual Only)

Ground, GroundDetail, and GroundDebris use **FastNoiseLite** for organic tile distribution.
This eliminates carpet-bombing (identical tiles repeated uniformly) that hand-crafted text maps
produce.

**A layer is procedural if:**
- It has no collision
- Its content doesn't affect gameplay, story, or navigation
- Variety looks better than precise control

Procedural layers per scene:

| Scene | Procedural Layers |
|-------|------------------|
| `overgrown_ruins` | Ground, GroundDetail, GroundDebris |
| `verdant_forest` | Ground, GroundDetail |
| `roothollow` | Ground |
| `prismfall_approach` | Ground, GroundDetail |
| `overgrown_capital` | Ground, GroundDetail, GroundDebris |

### Authored Layers (Structural)

Walls, Paths, Objects, Trees, and AbovePlayer (canopy) remain hand-crafted `Array[String]` text
maps. Story requires specific placement — an exit must be in the right column, a path must reach
an NPC zone, a forest border must block navigation.

**A layer is authored if:**
- It has collision that affects player navigation
- Its placement affects story events, spawn points, or exits
- The exact visual matches a design document

---

## MapBuilder API Reference

### `build_noise_layer(layer, cols, rows, noise, entries, source_id=0)`

Fills every cell using FastNoiseLite. For each cell (x, y), the noise value
`get_noise_2d(x, y)` is compared against threshold entries (checked in order — first match wins).
Entries must be listed high→low threshold; the last entry should have `threshold: -1.0` as a
catch-all.

```gdscript
const GROUND_ENTRIES: Array[Dictionary] = [
    {"threshold": 0.3,  "atlas": Vector2i(0, 8)},   # common terrain (noise > 0.3)
    {"threshold": -0.2, "atlas": Vector2i(0, 2)},   # dirt (noise -0.2..0.3)
    {"threshold": -1.0, "atlas": Vector2i(0, 6)},   # catch-all (any remaining)
]
```

### `scatter_decorations(layer, cols, rows, noise, entries)`

Scatters decoration tiles using a density threshold. For each entry, a tile is placed where
`noise_value > (1.0 - density)`. Each entry uses a unique spatial offset so different decoration
types don't overwrite each other. Only places on empty cells (`get_cell_source_id == -1`).

```gdscript
const DETAIL_ENTRIES: Array[Dictionary] = [
    {"atlas": Vector2i(0, 0), "source_id": 1, "density": 0.06},  # ~6% coverage
    {"atlas": Vector2i(1, 0), "source_id": 1, "density": 0.05},  # ~5% coverage
]
```

### `disable_collision(layer)`

Sets `layer.collision_enabled = false`. Call on all visual-only layers after building them.
Reduces physics overhead and prevents invisible collision bodies on decorations.

### `build_layer(layer, map, legend, source_id=0)`

Fills cells from a hand-crafted `Array[String]` text map. Space = no tile. Each non-space
character is looked up in the legend dictionary for its atlas coordinates.

---

## Noise Configuration by Scene

Different seeds and frequencies ensure visual variety across scenes:

| Scene | Seed | Freq | Character |
|-------|------|------|-----------|
| overgrown_ruins | 12345 | 0.08 | Low-freq patches (large terrain zones) |
| overgrown_capital | 54321 | 0.09 | Slightly tighter ruins variation |
| verdant_forest | 77777 | 0.10 | Medium-freq for denser variation |
| roothollow | 55543 | 0.10 | Gentle organic patches (town feel) |
| prismfall_approach | 99887 | 0.12 | Higher-freq rocky steppe variation |

Each scene uses `seed + 1` for detail/scatter noise so decorations land independently from the
ground pattern.

---

## Future: Terrain Autotile (T-TMFIX-TERRAIN)

Godot's `set_cells_terrain_connect()` can produce automatic tile transitions (grass→dirt edges)
if tiles have peering bits defined. Time Fantasy A5 sheets have 8 column variants per row —
these columns map to different blob positions (center, N-edge, NE-corner, etc.).

To implement:
1. View each A5 PNG and map each column (0-7) to its blob position
2. Assign `TileData.set_terrain_peering_bit()` for each variant
3. Replace `build_noise_layer()` with `set_cells_terrain_connect()` for smooth transitions

This is deferred because it requires examining tile sheet PNGs to understand column→blob-position
mapping per sheet. The noise + `set_cell()` approach produces organic distribution without
requiring that knowledge.

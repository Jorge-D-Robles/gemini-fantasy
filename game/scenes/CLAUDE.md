# Scene Asset Usage Guide

Reference for which Time Fantasy assets each scene uses and why. Consult this before modifying any scene's tilemap or visual content to maintain consistency.

## Overgrown Ruins (`overgrown_ruins/`)

**Theme:** Ancient golden ruins overgrown with vegetation. Starting area.

**Atlas Sources (3):**

| Source ID | MapBuilder Constant | Asset | Purpose |
|-----------|-------------------|-------|---------|
| 0 | `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | Opaque ground tiles |
| 1 | `RUINS_A5` | `tf_A5_ruins2.png` | Golden Egyptian walls and ornamental borders |
| 2 | `OVERGROWN_RUINS_OBJECTS` | `tf_B_ruins3.png` | Ruins objects (statues, rubble, bushes) |

**Tile Usage:**

| Layer | Source | Tiles | Notes |
|-------|--------|-------|-------|
| Ground (z=-2) | 0 (fairy forest) | Row 10, col 0 — gray-green stone | Fully opaque. Ruins3 A5 tiles are semi-transparent overlays and cannot be used as ground fill. |
| GroundDetail (z=-1) | 1 (ruins2) | Row 2 — ornate golden floor | Decorative accent in sacred chamber and corridor edges |
| GroundDetail (z=-1) | 2 (B-sheet) | (0,2) pebbles, (1,2) rocks | Scattered debris across walkable floor |
| Walls (z=0) | 1 (ruins2) | Row 4 — golden Egyptian wall (W), Row 8 — dark ornamental border (G) | Both rows fully opaque. Rows 0-3 are semi-transparent. |
| Objects (z=0) | 2 (B-sheet) | Face statues, bushes, stone blocks, rubble | See OBJECTS_LEGEND in script for full mapping |

**Key Objects (B-sheet source 2):**
- Teal face statue: 3x2 tiles at (4-6, 2-3) — placed in sacred chamber
- Gold face statue: 2x2 tiles at (8-9, 2-3) — placed in south gallery
- Green bushes: (0,4) and (1,4) — two variants for organic variety
- Stone rubble/blocks: (0,0), (2,0), (3,0), (4,0) — scattered in corridors

**Important Notes:**
- Ruins3 A5 (`tf_A5_ruins3.png`) tiles are mostly TRANSPARENT overlays designed to layer on top of a base sheet. Only row 2 (vine-covered) is opaque. Do not use other rows as ground fill.
- Ruins2 A5 (`tf_A5_ruins2.png`) rows 0-3 are also semi-transparent. Only rows 4-5 (walls) and 8-9 (ornamental borders) are fully opaque.
- The fairy forest A5_A sheet provides reliable opaque ground tiles for any scene.

**Map Dimensions:** 40 cols x 24 rows (640x384 pixels)

---

## Verdant Forest (`verdant_forest/`)

**Theme:** Lush green forest with winding paths and clearings. Overworld area.

**Atlas Sources (2):**

| Source ID | MapBuilder Constant | Asset | Purpose |
|-----------|-------------------|-------|---------|
| 0 | `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | Ground, paths, detail accents |
| 1 | `FOREST_OBJECTS` | `tf_ff_tileB_forest.png` | Tree canopy border tiles |

**Tile Usage:**

| Layer | Source | Tiles | Notes |
|-------|--------|-------|-------|
| Ground (z=-3) | 0 | Row 8, col 0 — bright green vegetation | Single-tile fill, fully opaque |
| GroundDetail (z=-2) | 0 | Row 14 — flower (0,14) and bush (2,14) accents | Sparse placement for variety |
| Trees (z=-1) | 1 (B-sheet) | (1,1) — canopy center | Used as solid blocking tree borders |
| Paths (z=0) | 0 | Row 4, col 0 — dirt path | Single-tile path through forest |
| Objects (z=1) | — | Not currently populated | Available for future detail |
| AbovePlayer (z=5) | — | Not currently populated | Available for canopy overlay |

**Important Notes:**
- Row 8 = bright green (forest floor). Row 0 = dark green (used by Roothollow for grass).
- Tree borders use B-sheet canopy tiles as solid walls to bound the map.
- The forest has 6 layers defined in the scene even though not all are actively populated.

**Map Dimensions:** 40 cols x 25 rows (640x400 pixels)

---

## Roothollow (`roothollow/`)

**Theme:** Cozy fairy forest village with stone paths. Safe town hub.

**Atlas Sources (1):**

| Source ID | MapBuilder Constant | Asset | Purpose |
|-----------|-------------------|-------|---------|
| 0 | `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | Ground, paths, detail |

**Tile Usage:**

| Layer | Source | Tiles | Notes |
|-------|--------|-------|-------|
| Ground | 0 | Row 0, all 8 columns — dark green grass variants | Uses block-rotation pattern with 6 permuted 8-char blocks for pseudo-random variety |
| Paths | 0 | Row 10, cols 0-5 — gray stone walkway variants | 6 variants for visual variety |
| GroundDetail | 0 | Row 14, cols 0-3 — flower/foliage accents | 4 variants scattered around buildings and paths |

**Important Notes:**
- Roothollow uses only A5_A tiles (no B-sheet objects yet). Visual variety comes from cycling all 8 column variants of row 0 in randomized blocks.
- Row 10 = gray stone (same as Overgrown Ruins ground) — provides consistent stone palette for town paths.
- Row 14 = decorative flower/foliage tiles — lightweight ground accents.
- No B-sheet buildings or structures are placed yet. Future work should add mushroom village objects from `tf_ff_tileB_mushroomvillage.png`.

**Map Dimensions:** 48 cols x 38 rows (768x608 pixels)

---

## Cross-Scene Consistency Rules

1. **Fairy Forest A5_A is the universal ground sheet.** All three scenes use it for ground or detail. It has fully opaque tiles at every row.
2. **Row 0 = dark green grass** (Roothollow). **Row 8 = bright green vegetation** (Verdant Forest). **Row 10 = gray stone** (Overgrown Ruins ground, Roothollow paths).
3. **Ruins tiles should not appear in forest/town scenes.** Golden Egyptian walls and overgrown rubble break the fairy forest aesthetic.
4. **Forest B-sheet objects should not appear in ruins.** Tree canopies and forest objects don't fit the indoor ruins theme. Use ruins3 B-sheet objects instead.
5. **Single-tile fills for ground.** Never alternate A5 columns — they are different tile variants, not left/right halves. Use one `Vector2i(col, row)` per fill.
6. **B-sheet objects for visual variety.** Ground variety comes from detail layers and B-sheet objects, not from mixing A5 columns.

## Available MapBuilder Constants

```
FAIRY_FOREST_A5_A   = tf_ff_tileA5_a.png     (128x256 A5 — universal ground)
FAIRY_FOREST_A5_B   = tf_ff_tileA5_b.png     (128x256 A5 — fairy forest variant)
RUINS_A5            = tf_A5_ruins2.png        (128x256 A5 — golden/Egyptian ruins)
OVERGROWN_RUINS_A5  = tf_A5_ruins3.png        (128x256 A5 — overgrown ruins overlays)
FOREST_OBJECTS      = tf_ff_tileB_forest.png  (256x256 B — forest canopy/objects)
TREE_OBJECTS        = tf_ff_tileB_trees.png   (256x256 B — individual trees)
STONE_OBJECTS       = tf_ff_tileB_stone.png   (256x256 B — stone structures)
MUSHROOM_VILLAGE    = tf_ff_tileB_mushroomvillage.png (256x256 B — village buildings)
RUINS_OBJECTS       = tf_B_ruins2.png         (256x256 B — golden ruins objects)
OVERGROWN_RUINS_OBJECTS = tf_B_ruins3.png     (256x256 B — overgrown ruins objects)
GIANT_TREE          = tf_B_gianttree_ext.png  (256x256 B — giant tree exterior)
```

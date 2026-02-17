# Scene Asset Reference

Reference for which Time Fantasy assets each scene uses and why.
Consult this before modifying any scene to maintain visual consistency.

## Overgrown Ruins (`overgrown_ruins/`)

**Theme:** Ancient golden ruins overgrown with vegetation. Starting area.

**Atlas Sources (3):**

| Source ID | MapBuilder Constant | Asset | Pack Origin | Purpose |
|-----------|-------------------|-------|-------------|---------|
| 0 | `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | `tf_fairyforest_12.28.20/1x/` | Opaque ground tiles (row 10 gray stone) |
| 1 | `RUINS_A5` | `tf_A5_ruins2.png` | `tf_ruindungeons/16/` | Golden Egyptian walls (rows 4-5), dark borders (rows 8-9), ornate floor (row 2) |
| 2 | `OVERGROWN_RUINS_OBJECTS` | `tf_B_ruins3.png` | `tf_ruindungeons/16/` | B-sheet objects: face statues, stone blocks, bushes, rubble |

**Key Tile Choices:**

| Layer | Source | Tile | Notes |
|-------|--------|------|-------|
| Ground (z=-2) | 0 | `(0, 10)` gray stone | Fairy Forest A5_A — fully opaque. Ruins3 A5 tiles are semi-transparent and CANNOT be used as ground. |
| GroundDetail (z=-1) | 1 | `(0, 2)` ornate gold | Ruins2 decorative floor in sacred chamber and corridors |
| GroundDetail (z=-1) | 2 | `(0,2)` pebbles, `(1,2)` rocks | B-sheet debris scattered on floor |
| Walls (z=0) | 1 | `(0, 4)` golden wall, `(0, 8)` dark border | Ruins2 rows 4-5 and 8-9 are fully opaque |
| Objects (z=0) | 2 | Face statues, bushes, stones | See OBJECTS_LEGEND in script |

**B-Sheet Objects (source 2):**
- Teal face statue: 3x2 tiles at `(4-6, 2-3)` — sacred chamber
- Gold face statue: 2x2 tiles at `(8-9, 2-3)` — south gallery
- Green bushes: `(0,4)` and `(1,4)` — two variants
- Stone rubble: `(0,0)`, `(2,0)`, `(3,0)`, `(4,0)` — corridors

**Critical:** Ruins3 A5 tiles are TRANSPARENT overlays. Ruins2 rows 0-3 are also semi-transparent. Only Fairy Forest A5_A provides reliable opaque ground for all scenes.

**Map:** 40 cols x 24 rows (640x384 px)

---

## Verdant Forest (`verdant_forest/`)

**Theme:** Lush enchanted forest with clearings, dirt path, dense tree borders.

**Atlas Sources (4):**

| Source ID | MapBuilder Constant | Asset | Pack Origin | Purpose |
|-----------|-------------------|-------|-------------|---------|
| 0 | `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | `tf_fairyforest_12.28.20/1x/` | Ground (row 8), paths (row 4) |
| 1 | `FOREST_OBJECTS` | `tf_ff_tileB_forest.png` | `tf_fairyforest_12.28.20/1x/` | Tree canopy fill, canopy overhang, foliage details |
| 2 | `STONE_OBJECTS` | `tf_ff_tileB_stone.png` | `tf_fairyforest_12.28.20/1x/` | Rocks, pebbles, orange flowers in clearing |
| 3 | `TREE_OBJECTS` | `tf_ff_tileB_trees.png` | `tf_fairyforest_12.28.20/1x/` | Reserved for individual tree objects |

**Key Tile Choices:**

| Layer | Source | Tile | Notes |
|-------|--------|------|-------|
| Ground | 0 | `(0, 8)` bright green | Row 8 = dense vegetation. Single-tile fill. |
| Trees | 1 | `(1, 1)` canopy center | B_forest solid green — blocks movement |
| Paths | 0 | `(0, 4)` amber cobble | Row 4 = golden path. Single-tile fill. |
| Detail | 1 | `(0, 8)`, `(2, 8)` foliage | B_forest small ground plants |
| Objects | 2 | Rows 0-1: rocks, flowers | B_stone scattered in clearing |
| AbovePlayer | 1 | `(1, 1)` canopy | Same canopy tile, 1 row inside tree border for depth overhang |

**Map:** 40 cols x 24 rows (640x384 px)

---

## Roothollow (`roothollow/`)

**Theme:** Cozy fairy forest village — safe town hub with natural forest border.

**Atlas Sources (4):**

| Source ID | MapBuilder Constant | Asset | Pack Origin | Purpose |
|-----------|-------------------|-------|-------------|---------|
| 0 | `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | `tf_fairyforest_12.28.20/1x/` | Ground (row 8), paths (row 10), details (row 14) |
| 1 | `MUSHROOM_VILLAGE` | `tf_ff_tileB_mushroomvillage.png` | `tf_fairyforest_12.28.20/1x/` | Small mushroom decorations near buildings |
| 2 | `FOREST_OBJECTS` | `tf_ff_tileB_forest.png` | `tf_fairyforest_12.28.20/1x/` | Forest canopy border around town perimeter |
| 3 | `STONE_OBJECTS` | `tf_ff_tileB_stone.png` | `tf_fairyforest_12.28.20/1x/` | Small rocks and flowers in grass |

**Key Tile Choices:**

| Layer | Source | Tile | Notes |
|-------|--------|------|-------|
| Ground | 0 | `(0, 8)` bright green | Row 8 = dense vegetation. Single-tile fill. |
| Paths | 0 | `(0, 10)` gray stone | Row 10 = stone walkway. Single-tile fill. |
| Detail | 0 | Row 14 flowers/bushes | 4 variants `(0-3, 14)` sparse at 10-12% coverage |
| TreesBorder | 2 | `(1, 1)` canopy center | Irregular-thickness forest border from `_BORDER_SPEC`, gap on west for exit |
| Decorations | 1, 3 | Mushrooms + rocks | Small accents near buildings and in grass |

**Building Sprites (Sprite2D, NOT tilemap):**

| Building | Sprite | Pack Origin |
|----------|--------|-------------|
| Inn | `lodge_clean.png` | `tf_farmandfort/` (medieval farm/fort) |
| Shop, Elder House | `hut.png` | `tf_fairyforest_12.28.20/1x/` (mushroom village) |
| Trees (decorative) | `tree_small/medium/tall.png` | `tf_fairyforest_12.28.20/1x/` |
| Signpost | `signpost.png` | `tf_fairyforest_12.28.20/1x/` |

**NPC Sprites:** `npc_char1.png`, `npc_char2.png` from `npc-animations/rpgmaker/1/`

**Map:** 48 cols x 38 rows (768x608 px)

---

## Cross-Scene Consistency Rules

1. **Fairy Forest A5_A is the universal ground sheet.** All scenes use it. It has fully opaque tiles at every row.
2. **Row 8 = bright green** (forest/town ground). **Row 10 = gray stone** (ruins ground, town paths). **Row 4 = amber cobble** (forest paths).
3. **Ruins tiles stay in ruins scenes.** Golden Egyptian walls/objects break the fairy forest aesthetic.
4. **Forest B-sheets stay in forest/town scenes.** Tree canopies don't fit indoor ruins.
5. **Single-tile fills for ground and paths.** Never alternate A5 columns. One `Vector2i(col, row)` per fill.
6. **B-sheet objects provide visual variety**, not A5 column mixing.
7. **Mixing packs is OK** for different purposes — e.g., Inn uses `tf_farmandfort` lodge while the rest uses fairy forest.

## MapBuilder Constants Reference

```
# A5 terrain sheets (128x256, 8 cols x 16 rows)
FAIRY_FOREST_A5_A   = tf_ff_tileA5_a.png         # Universal opaque ground
FAIRY_FOREST_A5_B   = tf_ff_tileA5_b.png         # Fairy forest variant B
RUINS_A5            = tf_A5_ruins2.png            # Golden/Egyptian ruins
OVERGROWN_RUINS_A5  = tf_A5_ruins3.png            # Semi-transparent overlays!

# B object sheets (256x256, 16 cols x 16 rows)
FOREST_OBJECTS      = tf_ff_tileB_forest.png      # Tree canopy, bushes, trunks
TREE_OBJECTS        = tf_ff_tileB_trees.png       # Individual trees, dead trees
STONE_OBJECTS       = tf_ff_tileB_stone.png       # Rocks, flowers, gravestones
MUSHROOM_VILLAGE    = tf_ff_tileB_mushroomvillage.png  # Village decorations
RUINS_OBJECTS       = tf_B_ruins2.png             # Golden ruins objects
OVERGROWN_RUINS_OBJECTS = tf_B_ruins3.png         # Overgrown ruins objects
GIANT_TREE          = tf_B_gianttree_ext.png      # Giant tree exterior
```

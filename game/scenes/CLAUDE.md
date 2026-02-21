# game/scenes/

Overworld area scenes — each is a self-contained playable location.
See root `CLAUDE.md` for project-wide conventions and tilemap rules.

## Scene Index

| Directory | Scene | Type | Description |
|-----------|-------|------|-------------|
| `overgrown_ruins/` | `overgrown_ruins.tscn` | Dungeon/ruins | Game start — Lyra discovery, Memory Bloom encounters |
| `verdant_forest/` | `verdant_forest.tscn` | Overworld forest | Connects ruins <-> town, Iris recruitment, 6-enemy pool |
| `roothollow/` | `roothollow.tscn` | Town hub | Safe zone, NPCs, Garrick recruitment, no encounters |
| `prismfall_approach/` | `prismfall_approach.tscn` | Overworld steppes | Crystalline Steppes south of Verdant Forest, 5-enemy pool |

## Standard Scene Pattern

**Script:** `extends Node2D` (no `class_name`)

**Node tree layout — belt-and-suspenders rendering (z_index groups + tree order):**
```
AreaName (Node2D)
  Ground (TileMapLayer)            z_index=-2   # always behind everything
  [GroundDetail] (TileMapLayer)    z_index=-1
  [GroundDebris] (TileMapLayer)    z_index=-1   # optional debris layer (ruins, capital)
  [Paths] (TileMapLayer)           z_index=-1
  [Walls / Trees / Objects] (TileMapLayer)  z_index=0  # midground (tree order within z=0)
  Entities (Node2D)                z_index=0, y_sort_enabled=true
    CompanionController            # first child = drawn behind player (tree order)
    Player (CharacterBody2D)
    SpawnFrom* (Marker2D)          # one per entry point; added to named group in _ready()
    [NPCName] (StaticBody2D)       # sorted by Y vs Player automatically
  [AbovePlayer] (TileMapLayer)     z_index=1    # always above entities
  Triggers (Node2D)                # non-visual
    ExitTo* (Area2D)               # scene transition triggers
    [EventZone] (Area2D)           # story event activation zones
  EncounterSystem                  # non-visual (random encounters, combat areas only)
  [EventNode]                      # recruitment/sequence node
```

**Rendering rule:** z_index (-2/-1/0/1) handles broad group separation. Tree order within z=0 resolves Walls/Objects vs Entities. `y_sort_enabled=true` on Entities auto-sorts player vs NPCs by Y for depth. Do NOT set `y_sort_enabled` on the scene root — it would sort TileMapLayers against each other, breaking z_index.

**`_ready()` responsibilities:**
1. Call `_setup_tilemap()` — applies atlas and fills layers via `MapBuilder`
2. Set `UILayer.hud.location_name = "Scene Name"`
3. Add spawn `Marker2D` nodes to groups
4. Connect `body_entered` on trigger `Area2D` nodes
5. Build encounter pool and call `_encounter_system.setup(pool)` (combat areas)
6. Gate story events via `EventFlags.has_flag()`

## Tilemap Setup Pattern

Tilemap data (legends + map arrays) lives in a separate `<SceneName>Map` module file. Encounter
pool building lives in `<SceneName>Encounters`. The scene script delegates to these modules.

```gdscript
# <scene_name>_map.gd — pure data, no Node deps
class_name SceneNameMap
extends RefCounted

const COLS: int = 40
const ROWS: int = 24

# Ground uses TF_TERRAIN (flat 16x16 — freely mixable, no seam artifacts)
# Biome enum MUST come before constants (gdlint order requirement)
enum Biome { BRIGHT_GREEN, MUTED_GREEN, DIRT }

# Column variants per biome — picked by position hash for per-cell variety
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

const OPEN_BIOME_THRESHOLDS: Array[Dictionary] = [
    {"threshold": 0.15,  "biome": Biome.BRIGHT_GREEN},
    {"threshold": -0.15, "biome": Biome.MUTED_GREEN},
    {"threshold": -1.0,  "biome": Biome.DIRT},
]

const GROUND_NOISE_SEED: int = 12345
const GROUND_NOISE_FREQ: float = 0.06   # Low = large organic patches
const GROUND_NOISE_OCTAVES: int = 4
const VARIANT_HASH_SEED: int = 31415

const PATH_LEGEND: Dictionary = { "P": Vector2i(2, 9) }  # sandy/tan, terrain.png row 9
const PATH_MAP: Array[String] = [ "...", ... ]

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

# <scene_name>_encounters.gd — pool builder, testable without live scene
class_name SceneNameEncounters
extends RefCounted

static func build_pool(enemy1: Resource, ...) -> Array[EncounterPoolEntry]:
    ...

# <scene_name>.gd — delegates to modules
func _setup_tilemap() -> void:
    var atlas_paths: Array[String] = [
        MapBuilder.TF_TERRAIN,        # source 0 — flat 16x16 ground + path
        MapBuilder.FOREST_OBJECTS,    # source 1 — trees, trunks, canopies
        MapBuilder.STONE_OBJECTS,     # source 2 — detail: rocks, flowers
    ]
    MapBuilder.apply_tileset(layers, atlas_paths, solid)
    # Procedural ground — biome noise + position hash, organic, no carpet-bombing
    var noise := FastNoiseLite.new()
    noise.seed = SceneNameMap.GROUND_NOISE_SEED
    noise.frequency = SceneNameMap.GROUND_NOISE_FREQ
    noise.fractal_octaves = SceneNameMap.GROUND_NOISE_OCTAVES
    _fill_ground_with_variants(_ground, noise)
    MapBuilder.disable_collision(_ground)
    # Structural layers — authored
    MapBuilder.build_layer(_paths, SceneNameMap.PATH_MAP, SceneNameMap.PATH_LEGEND)
    MapBuilder.disable_collision(_paths)

func _fill_ground_with_variants(layer: TileMapLayer, noise: FastNoiseLite) -> void:
    for y: int in range(SceneNameMap.ROWS):
        for x: int in range(SceneNameMap.COLS):
            var noise_val: float = noise.get_noise_2d(float(x), float(y))
            var atlas: Vector2i = SceneNameMap.pick_tile(noise_val, x, y)
            layer.set_cell(Vector2i(x, y), 0, atlas)
    layer.update_internals()
```

- **Source 0 = `TF_TERRAIN`** (flat 16×16 — `TimeFantasy_TILES/TILESETS/terrain.png`), Source 1+ = B sheets (objects — pass `source_id`)
- Flat tiles are freely mixable — no seam artifacts between column variants
- Solid tiles declared in `solid: Dictionary = { source_id: [Vector2i, ...] }`
- Module files use `class_name` + `extends RefCounted` — zero runtime cost, testable in isolation

## Scene Details

### overgrown_ruins/

**Theme:** Ancient golden ruins overgrown with vegetation. Starting area.
**Map:** 40 cols x 24 rows (640x384 px)

**Atlas Sources:**

| Source | Constant | Asset | Purpose |
|--------|----------|-------|---------|
| 0 | `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | Opaque ground (row 10 gray stone) |
| 1 | `RUINS_A5` | `tf_A5_ruins2.png` | Golden walls (rows 4-5), dark borders (rows 8-9), ornate floor (row 2) |
| 2 | `OVERGROWN_RUINS_OBJECTS` | `tf_B_ruins3.png` | B-sheet: face statues, stone blocks, bushes, rubble |

**Critical:** Ruins3 A5 tiles are TRANSPARENT overlays. Only Fairy Forest A5_A provides opaque ground.

**Encounters:** Memory Bloom (common), Creeping Vine (uncommon), mixed
**Modules:** `overgrown_ruins_map.gd` (`OvergrownRuinsMap`) — tilemap constants; `overgrown_ruins_encounters.gd` (`OvergrownRuinsEncounters`) — pool builder
**Story:** `OpeningSequence` triggered by `LyraDiscoveryZone` — guarded by `EventFlags`
**Init:** Adds Kael to `PartyManager` if roster is empty (game start)
**Autoloads:** GameManager, BattleManager, DialogueManager, EventFlags, UILayer, PartyManager, MapBuilder

### verdant_forest/

**Theme:** Lush enchanted forest with clearings, dirt path, dense tree borders.
**Map:** 40 cols x 25 rows (640x400 px)

**Atlas Sources:**

| Source | Constant | Asset | Purpose |
|--------|----------|-------|---------|
| 0 | `TF_TERRAIN` | `TimeFantasy_TILES/TILESETS/terrain.png` | Flat 16×16 ground: rows 1-2 (green grass), row 6 (dirt), row 9 (sandy path) |
| 1 | `FOREST_OBJECTS` | `tf_ff_tileB_forest.png` | Tree canopy, foliage details |
| 2 | `STONE_OBJECTS` | `tf_ff_tileB_stone.png` | Rocks, flowers in clearing |
| 3 | `TREE_OBJECTS` | `tf_ff_tileB_trees.png` | Individual tree objects |

**Ground:** Biome noise (3 zones: BRIGHT_GREEN/MUTED_GREEN/DIRT) + position hash for per-cell variety. Implemented via `_fill_ground_with_variants()` in `verdant_forest.gd` using `VerdantForestMap.pick_tile()`.

**Layers:** Ground, GroundDetail, Trees, Paths, Objects, AbovePlayer
**Encounters:** 11 entries — creeping_vine, ash_stalker, hollow_specter, ancient_sentinel, gale_harpy, ember_hound + mixed
**Modules:** `verdant_forest_map.gd` (`VerdantForestMap`) — tilemap constants; `verdant_forest_encounters.gd` (`VerdantForestEncounters`) — pool builder
**Story:** `IrisRecruitment` triggered by `IrisEventZone` — disables encounters during sequence
**Transitions:** ExitToRuins -> overgrown_ruins (`spawn_from_forest`); ExitToTown -> roothollow (`spawn_from_forest`)

### roothollow/

**Theme:** Cozy fairy forest village — safe town hub.
**Map:** 40 cols x 28 rows (640x448 px)

**Atlas Sources:**

| Source | Constant | Asset | Purpose |
|--------|----------|-------|---------|
| 0 | `TF_TERRAIN` | `TimeFantasy_TILES/TILESETS/terrain.png` | Flat 16x16 ground: rows 1-2 (green grass), row 6 (dirt), row 9 (sandy path) |
| 1 | `MUSHROOM_VILLAGE` | `tf_ff_tileB_mushroomvillage.png` | Mushroom buildings, decorations |
| 2 | `FOREST_OBJECTS` | `tf_ff_tileB_forest.png` | Forest canopy border |
| 3 | `STONE_OBJECTS` | `tf_ff_tileB_stone.png` | Rocks, flowers, pebbles |
| 4 | `TREE_OBJECTS` | `tf_ff_tileB_trees.png` | Tree variant mixing |

**Ground:** Biome noise (3 zones: BRIGHT_GREEN/MUTED_GREEN/DIRT) + position hash for per-cell variety. Implemented via `_fill_ground_with_variants()` using `RoothollowMaps.pick_tile()`.
**Paths:** 4 sandy/tan variants from TF_TERRAIN row 9, position-hashed via `_fill_paths_with_variants()`.

**Building Sprites (Sprite2D, NOT tilemap):** Inn=`lodge_clean.png`, Shop/Elder=`hut.png`
**NPC Sprites:** `npc_char1.png`, `npc_char2.png` from `npc-animations/rpgmaker/1/`

**No encounters** — safe town hub
**NPCs:** Maren (innkeeper, heals party), Bram (shop), Elder Thessa, Wren, Garrick (pre-recruit), Lina
**Flag-reactive dialogue:** 4 states based on EventFlags — `default` -> `opening_lyra_discovered` -> `iris_recruited` -> `garrick_recruited`
**Story:** `GarrickRecruitment` — requires `opening_lyra_discovered` AND `iris_recruited` flags

### prismfall_approach/

**Theme:** Open rocky Crystalline Steppes — steppe road leading south toward Prismfall canyon.
**Map:** 40 cols x 24 rows (640x384 px)

**Atlas Sources:**

| Source | Constant | Asset | Purpose |
|--------|----------|-------|---------|
| 0 | `TF_TERRAIN` | `TimeFantasy_TILES/TILESETS/terrain.png` | Flat 16×16 ground: scrubland, bare earth, sandy path |
| 1 | `STONE_OBJECTS` | `tf_ff_tileB_stone.png` | Scattered rocks (detail layer) |

**Layers:** Ground, GroundDetail, Paths (no trees/AbovePlayer — open steppe)
**Encounters:** 10 entries — gale_harpy, cinder_wisp, hollow_specter, ancient_sentinel, ember_hound + mixed
**Modules:** `prismfall_approach_map.gd` (`PrismfallApproachMap`) — tilemap constants; `prismfall_approach_encounters.gd` (`PrismfallApproachEncounters`) — pool builder
**BGM:** `Wandering Through Quiet Lands.ogg`
**Transitions:** ExitToForest → verdant_forest (`spawn_from_prismfall`); ExitToPrismfall → future dungeon

## Scene Transition Protocol

All trigger handlers check three guards:

```gdscript
func _on_exit_entered(body: Node2D) -> void:
    if not body.is_in_group("player"):    return
    if GameManager.is_transitioning():    return
    if DialogueManager.is_active():       return
    if BattleManager.is_in_battle():      return  # combat areas only
    GameManager.change_scene(TARGET_PATH, GameManager.FADE_DURATION, "spawn_group")
```

## Cross-Scene Consistency Rules

1. **`TF_TERRAIN` is the standard ground sheet for new/updated outdoor scenes** — flat 16×16 tiles from `TimeFantasy_TILES/TILESETS/terrain.png`. Freely mixable, no seam artifacts. Overgrown Ruins still uses legacy `FAIRY_FOREST_A5_A` (migrate when redesigning).
2. **TF_TERRAIN row guide:** Row 1-2 = green grass. Row 6 = brown dirt. Row 9 = sandy/tan. Rows 22+ = RPGMaker auto-tiles — DO NOT USE.
3. **Ruins tiles stay in ruins scenes** — golden walls break forest/steppe aesthetic
4. **Organic ground** — use 2-3 biome types in large natural patches via noise + position hash. Never fill the entire map with one repeated tile. Flat tiles (TF_TERRAIN) can freely mix column variants — no seam restriction.
5. **B-sheet objects and ground decorations provide visual variety** — trees, rocks, flowers, barrels, fences. Place decorations sparingly and intentionally — no percentage-based carpet bombing.
6. **Search for JRPG reference images** before designing any tilemap — study how professional level designers create organic environments
7. **Mixing packs is OK** for different purposes (e.g., Inn uses `tf_farmandfort`)

## MapBuilder Constants Reference

```
# Flat 16x16 terrain sheets (PREFERRED for source 0 — freely mixable)
TF_TERRAIN          = TimeFantasy_TILES/TILESETS/terrain.png  # Grass, dirt, stone, sandy path
TF_OUTSIDE          = TimeFantasy_TILES/TILESETS/outside.png  # Outdoor cliffs, extra terrain
TF_DUNGEON          = TimeFantasy_TILES/TILESETS/dungeon.png  # Dungeon floors/walls
TF_CASTLE           = TimeFantasy_TILES/TILESETS/castle.png   # Castle interior
TF_INSIDE           = TimeFantasy_TILES/TILESETS/inside.png   # Room interiors
TF_WORLD            = TimeFantasy_TILES/TILESETS/world.png    # World map tiles

# Legacy A5 autotile sheets (columns NOT freely mixable — avoid for new scenes)
FAIRY_FOREST_A5_A   = tf_ff_tileA5_a.png         # Legacy — still used in roothollow, overgrown_ruins
FAIRY_FOREST_A5_B   = tf_ff_tileA5_b.png         # Legacy — fairy forest variant B
RUINS_A5            = tf_A5_ruins2.png            # Legacy — Golden/Egyptian ruins
OVERGROWN_RUINS_A5  = tf_A5_ruins3.png            # Legacy — Semi-transparent overlays!

# B object sheets (256x256, 16 cols x 16 rows — still used for objects/canopy)
FOREST_OBJECTS      = tf_ff_tileB_forest.png      # Tree canopy, bushes, trunks
TREE_OBJECTS        = tf_ff_tileB_trees.png       # Individual trees, dead trees
STONE_OBJECTS       = tf_ff_tileB_stone.png       # Rocks, flowers, gravestones
MUSHROOM_VILLAGE    = tf_ff_tileB_mushroomvillage.png  # Village decorations
RUINS_OBJECTS       = tf_B_ruins2.png             # Golden ruins objects
OVERGROWN_RUINS_OBJECTS = tf_B_ruins3.png         # Overgrown ruins objects
GIANT_TREE          = tf_B_gianttree_ext.png      # Giant tree exterior
```

## Adding a New Scene

1. Create `game/scenes/<name>/` with `<name>.tscn` + `<name>.gd`
2. Root node: `Node2D`, script `extends Node2D`
3. Add standard layers, `Entities/` subtree, `Triggers/` subtree
4. Add spawn `Marker2D` nodes + register groups in `_ready()`
5. Call `MapBuilder.apply_tileset()` + `MapBuilder.build_layer()` per layer
6. Set `UILayer.hud.location_name`
7. Wire triggers with the 3-guard pattern above
8. Register in `GameManager` or link from existing scenes

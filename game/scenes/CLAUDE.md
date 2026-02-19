# game/scenes/

Overworld area scenes — each is a self-contained playable location.
See root `CLAUDE.md` for project-wide conventions and tilemap rules.

## Scene Index

| Directory | Scene | Type | Description |
|-----------|-------|------|-------------|
| `overgrown_ruins/` | `overgrown_ruins.tscn` | Dungeon/ruins | Game start — Lyra discovery, Memory Bloom encounters |
| `verdant_forest/` | `verdant_forest.tscn` | Overworld forest | Connects ruins <-> town, Iris recruitment, 6-enemy pool |
| `roothollow/` | `roothollow.tscn` | Town hub | Safe zone, NPCs, Garrick recruitment, no encounters |

## Standard Scene Pattern

**Script:** `extends Node2D` (no `class_name`)

**Node tree layout:**
```
AreaName (Node2D)
  Ground (TileMapLayer)
  [GroundDetail] (TileMapLayer)
  [Paths / Walls / Trees / Objects / AbovePlayer] (TileMapLayer)
  EncounterSystem          # random encounters (combat areas only)
  [EventNode]              # recruitment/sequence node
  Entities (Node2D)
    Player (CharacterBody2D)   # instance of entities/player/player.tscn
    SpawnFrom* (Marker2D)      # one per entry point; added to named group in _ready()
    [NPCName] (StaticBody2D)   # NPC instances
  Triggers (Node2D)
    ExitTo* (Area2D)           # scene transition triggers
    [EventZone] (Area2D)       # story event activation zones
```

**`_ready()` responsibilities:**
1. Call `_setup_tilemap()` — applies atlas and fills layers via `MapBuilder`
2. Set `UILayer.hud.location_name = "Scene Name"`
3. Add spawn `Marker2D` nodes to groups
4. Connect `body_entered` on trigger `Area2D` nodes
5. Build encounter pool and call `_encounter_system.setup(pool)` (combat areas)
6. Gate story events via `EventFlags.has_flag()`

## Tilemap Setup Pattern

```gdscript
const GROUND_LEGEND: Dictionary = { "G": Vector2i(col, row), ... }
const GROUND_MAP: Array[String] = [ "GGGG...", ... ]

func _setup_tilemap() -> void:
    var atlas_paths: Array[String] = [MapBuilder.FAIRY_FOREST_A5_A]
    MapBuilder.apply_tileset(layers, atlas_paths, solid)
    MapBuilder.build_layer(_ground, GROUND_MAP, GROUND_LEGEND)
    MapBuilder.build_layer(_trees, TREE_MAP, TREE_LEGEND, 1)  # source_id=1 for B-sheet
```

- Source 0 = A5 sheet (terrain), Source 1+ = B sheets (objects — pass `source_id`)
- Solid tiles declared in `solid: Dictionary = { source_id: [Vector2i, ...] }`

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
**Story:** `OpeningSequence` triggered by `LyraDiscoveryZone` — guarded by `EventFlags`
**Init:** Adds Kael to `PartyManager` if roster is empty (game start)
**Autoloads:** GameManager, BattleManager, DialogueManager, EventFlags, UILayer, PartyManager, MapBuilder

### verdant_forest/

**Theme:** Lush enchanted forest with clearings, dirt path, dense tree borders.
**Map:** 40 cols x 24 rows (640x384 px)

**Atlas Sources:**

| Source | Constant | Asset | Purpose |
|--------|----------|-------|---------|
| 0 | `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | Ground (row 8), paths (row 4) |
| 1 | `FOREST_OBJECTS` | `tf_ff_tileB_forest.png` | Tree canopy, foliage details |
| 2 | `STONE_OBJECTS` | `tf_ff_tileB_stone.png` | Rocks, flowers in clearing |
| 3 | `TREE_OBJECTS` | `tf_ff_tileB_trees.png` | Individual tree objects |

**Layers:** Ground, GroundDetail, Trees, Paths, Objects, AbovePlayer
**Encounters:** 10 entries — creeping_vine, ash_stalker, hollow_specter, ancient_sentinel, gale_harpy, ember_hound + mixed
**Story:** `IrisRecruitment` triggered by `IrisEventZone` — disables encounters during sequence
**Transitions:** ExitToRuins -> overgrown_ruins (`spawn_from_forest`); ExitToTown -> roothollow (`spawn_from_forest`)

### roothollow/

**Theme:** Cozy fairy forest village — safe town hub.
**Map:** 48 cols x 38 rows (768x608 px)

**Atlas Sources:**

| Source | Constant | Asset | Purpose |
|--------|----------|-------|---------|
| 0 | `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | Ground (row 8), paths (row 10), flowers (row 14) |
| 1 | `MUSHROOM_VILLAGE` | `tf_ff_tileB_mushroomvillage.png` | Mushroom decorations |
| 2 | `FOREST_OBJECTS` | `tf_ff_tileB_forest.png` | Forest canopy border |
| 3 | `STONE_OBJECTS` | `tf_ff_tileB_stone.png` | Rocks, flowers |

**Building Sprites (Sprite2D, NOT tilemap):** Inn=`lodge_clean.png`, Shop/Elder=`hut.png`
**NPC Sprites:** `npc_char1.png`, `npc_char2.png` from `npc-animations/rpgmaker/1/`

**No encounters** — safe town hub
**NPCs:** Maren (innkeeper, heals party), Bram (shop), Elder Thessa, Wren, Garrick (pre-recruit), Lina
**Flag-reactive dialogue:** 4 states based on EventFlags — `default` -> `opening_lyra_discovered` -> `iris_recruited` -> `garrick_recruited`
**Story:** `GarrickRecruitment` — requires `opening_lyra_discovered` AND `iris_recruited` flags

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

1. **Fairy Forest A5_A is the universal ground sheet** — fully opaque at every row
2. **Row 8** = bright green (forest/town). **Row 10** = gray stone (ruins/paths). **Row 4** = amber cobble (forest paths)
3. **Ruins tiles stay in ruins scenes** — golden walls break fairy forest aesthetic
4. **Organic ground** — use 2-3 terrain types in natural patches (grass, dirt, stone). Within each patch, use one A5 column consistently (different columns create seam artifacts). Never fill the entire map with one repeated tile.
5. **B-sheet objects and ground decorations provide visual variety** — trees, rocks, flowers, barrels, fences. Ground detail coverage should be 15-30%, not sparse.
6. **Search for JRPG reference images** before designing any tilemap — study how professional level designers create organic environments
6. **Mixing packs is OK** for different purposes (e.g., Inn uses `tf_farmandfort`)

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

## Adding a New Scene

1. Create `game/scenes/<name>/` with `<name>.tscn` + `<name>.gd`
2. Root node: `Node2D`, script `extends Node2D`
3. Add standard layers, `Entities/` subtree, `Triggers/` subtree
4. Add spawn `Marker2D` nodes + register groups in `_ready()`
5. Call `MapBuilder.apply_tileset()` + `MapBuilder.build_layer()` per layer
6. Set `UILayer.hud.location_name`
7. Wire triggers with the 3-guard pattern above
8. Register in `GameManager` or link from existing scenes

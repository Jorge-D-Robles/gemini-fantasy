# Asset Source Packs — Time Fantasy

All game art comes from **Time Fantasy** packs by Jason Perry. Source packs live at `/Users/robles/repos/games/assets/`. Assets are copied into `game/assets/` for Godot (PNGs are gitignored; only `.import` files are committed).

## Source Pack Index

| Pack Directory | Theme | Assets Imported |
|----------------|-------|-----------------|
| `tf_fairyforest_12.28.20` | Fairy forest, mushroom village | A5 terrain, B-sheet forest/stone/trees/mushroom objects |
| `tf_ruindungeons` | Ancient ruins (3 variants) | A5 terrain x3, B-sheet objects x3 |
| `tf_giant-tree` | Giant tree exterior/interior | A5 terrain x2, B-sheet objects x2 |
| `tf_ashlands` | Volcanic ashlands | A5 terrain, B-sheet objects |
| `tf_atlantis_updated2020` | Underwater Atlantis | A5 terrain x2, B-sheet objects x2 |
| `tf_darkdimension_updated2020` | Dark dimension, void | A5 terrain, B-sheet objects, waterfall |
| `tf_steampunk_complete` | Steampunk city/dungeon/train, sewers | A5 terrain x3 + sewers, B-sheet objects x8 + sewers |
| `TimeFantasy_Winter` | Winter/snow landscapes | B-sheet objects x3, terrain, water |
| `tf_farmandfort` | Farm buildings, fort structures | B-sheet farm/fort objects |
| `cloud_tileset` | Sky backgrounds, clouds | Background layers, cloud tileset |
| `tf_final_tower_12.24.22` | Final tower dungeon | Full tower tileset |
| `halloween_10.2022` | Halloween-themed tiles/icons | Tiles, icons |
| `tf_mythicalbosses` / `_v2` | Boss enemy sprites | Large boss sprites (chimera, kraken, etc.) |
| `tf_svbattle` | Side-view battler sprites | Battle sprites for characters |
| `tf_dwarfvelf_v1.2` | Dwarf/elf character sprites | Walk sprites + emotes |
| `beast_tribes` | Beast hero characters | Walk sprites + emotes + battle sprites |
| `elements_core_pack_9` | Core RPG characters | 5 hero characters, NPC sets |
| `elements_hometown_6` | Town NPCs | Children, NPCs, household sprites |
| `npc-animations` / `npc-animations 2` | NPC activity sprites | Eating, carrying, crafting, actions |
| `tf_animals` | Farm/wild animals | Animal walk sprites (5 sets + birds + horse) |
| `tf-faces-6.11.20` | Character portraits | Face portraits for dialogue |
| `tf-minis` | Chibi/mini characters | Mini versions of characters |
| `FutureFantasy` | Sci-fi/modern characters | Future characters, vehicles, screens |
| `icons_12.26.19` / `icons_8.13.20` | Item/ability icons | 24px and 32px icon sheets |
| `tf_ship_` | Ships and boats | Airship, boats, pirate ship |
| `monsterbelly_11.42.21` | Monster interior dungeon | Inside-belly tileset, doors, tentacles |
| `christmas` | Holiday content | Santa, reindeer, presents, gnomes |
| `shadowless` | Shadow-free animal variants | Shadowless versions of animal sprites |
| `quirky_npcs` | Additional NPC characters | Various NPC walk sprites |

## Tile Sheet Format Reference

| Sheet Type | Prefix | Dimensions | Grid | Tile Size | Use For |
|------------|--------|-----------|------|-----------|---------|
| A5 (terrain) | `tf_A5_*`, `tf_ff_tileA5_*` | 128x256 | 8 col x 16 row | 16x16 | Ground terrain fills — one column per terrain type |
| A1 (autotile) | `tf_A1_*` | varies | varies | 16x16 | Animated water/lava autotiles |
| A2 (autotile) | `tf_A2_*` | varies | varies | 16x16 | Ground autotiles with transitions |
| B (objects) | `tf_B_*`, `tf_ff_tileB_*` | 256x256 | 16 col x 16 row | 16x16 | Objects: trees, rocks, buildings, decorations |

**Key rule:** Within a single terrain patch, use tiles from **one A5 column only**. Mixing columns creates visible seam artifacts.

## MapBuilder Constants

All imported tilesets have corresponding constants in `game/systems/map_builder.gd`. Use these instead of raw paths:

### Fairy Forest
| Constant | File | Type |
|----------|------|------|
| `FAIRY_FOREST_A5_A` | `tf_ff_tileA5_a.png` | A5 — universal opaque ground (grass, dirt, stone, waterfall) |
| `FAIRY_FOREST_A5_B` | `tf_ff_tileA5_b.png` | A5 — fairy forest variant B |
| `FOREST_OBJECTS` | `tf_ff_tileB_forest.png` | B — tree canopies (rows 0-1), trunks (cols 8-15), foliage |
| `TREE_OBJECTS` | `tf_ff_tileB_trees.png` | B — individual trees, dead trees |
| `STONE_OBJECTS` | `tf_ff_tileB_stone.png` | B — rocks, flowers, gravestones |
| `MUSHROOM_VILLAGE` | `tf_ff_tileB_mushroomvillage.png` | B — mushroom village decorations |

### Ruin Dungeons
| Constant | File | Type |
|----------|------|------|
| `RUINS1_A5` | `tf_A5_ruins1.png` | A5 — blue/silver ruins terrain |
| `RUINS_A5` | `tf_A5_ruins2.png` | A5 — golden/Egyptian ruins terrain |
| `OVERGROWN_RUINS_A5` | `tf_A5_ruins3.png` | A5 — **TRANSPARENT overlays** (moss, vines) |
| `RUINS1_OBJECTS` | `tf_B_ruins1.png` | B — blue/silver ruins objects |
| `RUINS_OBJECTS` | `tf_B_ruins2.png` | B — golden ruins objects |
| `OVERGROWN_RUINS_OBJECTS` | `tf_B_ruins3.png` | B — overgrown ruins objects (face statues, rubble, bushes) |

### Giant Tree
| Constant | File | Type |
|----------|------|------|
| `GIANT_TREE_A5_EXT` | `tf_A5_gianttree_ext.png` | A5 — giant tree exterior terrain |
| `GIANT_TREE_A5_INT` | `tf_A5_gianttree_int.png` | A5 — giant tree interior terrain |
| `GIANT_TREE` | `tf_B_gianttree_ext.png` | B — giant tree exterior objects |
| `GIANT_TREE_INT` | `tf_B_gianttree_int.png` | B — giant tree interior objects |

### Ashlands
| Constant | File | Type |
|----------|------|------|
| `ASHLANDS_A5` | `tf_A5_ashlands_1.png` | A5 — volcanic ashland terrain |
| `ASHLANDS_OBJECTS` | `tf_B_ashlands_1.png` | B — ashland objects |

### Atlantis
| Constant | File | Type |
|----------|------|------|
| `ATLANTIS_A5_A` | `tf_A5_atlantisA.png` | A5 — underwater terrain A |
| `ATLANTIS_A5_B` | `tf_A5_atlantisB.png` | A5 — underwater terrain B |
| `ATLANTIS_OBJECTS_A` | `tf_B_atlantisA.png` | B — underwater objects A |
| `ATLANTIS_OBJECTS_B` | `tf_B_atlantisB.png` | B — underwater objects B |

### Dark Dimension
| Constant | File | Type |
|----------|------|------|
| `DARK_DIMENSION_A5` | `tf_dd_A5_1.png` | A5 — dark dimension terrain |
| `DARK_DIMENSION_OBJECTS` | `tf_dd_B_1.png` | B — dark dimension objects |

### Steampunk
| Constant | File | Type |
|----------|------|------|
| `STEAMPUNK_A5_DUNGEON` | `tfsteampunk_tileA5_dungeon.png` | A5 — steampunk dungeon terrain |
| `STEAMPUNK_A5_INT` | `tfsteampunk_tileA5_int.png` | A5 — steampunk interior terrain |
| `STEAMPUNK_A5_TRAIN` | `tfsteampunk_tileA5_trainint.png` | A5 — train interior terrain |
| `STEAMPUNK_CITY1` | `tfsteampunk_tileB_city1.png` | B — city buildings/streets |
| `STEAMPUNK_CITY2` | `tfsteampunk_tileB_city2.png` | B — city objects set 2 |
| `STEAMPUNK_CITY2B` | `tfsteampunk_tileB_city2b.png` | B — city variant B |
| `STEAMPUNK_CITY2C` | `tfsteampunk_tileB_city2c.png` | B — city variant C |
| `STEAMPUNK_DUNGEON` | `tfsteampunk_tileB_dungeon.png` | B — dungeon objects |
| `STEAMPUNK_INT1` | `tfsteampunk_tileB_int1.png` | B — interior objects 1 |
| `STEAMPUNK_INT2` | `tfsteampunk_tileB_int2.png` | B — interior objects 2 |
| `STEAMPUNK_TRAIN1` | `tfsteampunk_tileB_train1.png` | B — train objects 1 |
| `STEAMPUNK_TRAIN2` | `tfsteampunk_tileB_train2.png` | B — train objects 2 |
| `SEWERS_A5` | `tfsewers_tileA5_1.png` | A5 — sewer terrain |
| `SEWERS_OBJECTS` | `tfsewers_tileB_1.png` | B — sewer objects |

### Winter
| Constant | File | Type |
|----------|------|------|
| `WINTER_OBJECTS_B` | `tf_winter_tileB.png` | B — winter objects B |
| `WINTER_OBJECTS_C` | `tf_winter_tileC.png` | B — winter objects C |
| `WINTER_OBJECTS_D` | `tf_winter_tileD.png` | B — winter objects D |

### Additional Tilesets (no MapBuilder constant yet)

| File | Source Pack | Description |
|------|------------|-------------|
| `cloud_bg_bluesky.png` | `cloud_tileset` | Blue sky background layer |
| `cloud_bg_cloud1.png` | `cloud_tileset` | Cloud background layer 1 |
| `cloud_bg_cloud2.png` | `cloud_tileset` | Cloud background layer 2 |
| `cloud_tileset.png` | `cloud_tileset` | Cloud tile objects |
| `dd_waterfall_tileA1_1.png` | `tf_darkdimension` | Dark dimension waterfall autotile |
| `ff_master_tile_sheet.png` | `tf_fairyforest` | Full fairy forest master sheet (large) |
| `finaltower_complete_tfcolor.png` | `tf_final_tower` | Complete final tower tileset |
| `giantworm_terrain_1.png` | `monsterbelly` | Giant worm terrain |
| `grass_tile.png` | misc | Simple grass tile |
| `hallowtiles_1.png` | `halloween` | Halloween-themed tiles |
| `tf_A1_ashlands_1.png` | `tf_ashlands` | Ashlands animated water/lava autotile |
| `tf_A2_ashlands_1.png` | `tf_ashlands` | Ashlands ground autotile |
| `tf_ff_tileA2.png` | `tf_fairyforest` | Fairy forest A2 autotile |
| `tf_insidebelly_fullsheet.png` | `monsterbelly` | Monster interior full tileset |
| `tf_winter_terrain.png` | `TimeFantasy_Winter` | Winter terrain tiles |
| `tf_winter_water.png` | `TimeFantasy_Winter` | Winter water tiles |
| `tileB_farmA.png` | `tf_farmandfort` | Farm building objects |
| `tileB_fortA.png` | `tf_farmandfort` | Fort building objects |
| `witchtiles_1.png` | `halloween` | Witch-themed tiles |

## Sprite Assets

### Characters (`sprites/characters/`)

Walk sprites use the RPG Maker format: **3 columns x 4 rows** per character (down/left/right/up, 3 frames each). Standard sheet size varies by source pack.

| File | Source Pack | Description |
|------|------------|-------------|
| `kael_overworld.png` | custom | Kael protagonist walk sprite |
| `beast_hero_1-5.png` | `beast_tribes` | Beast tribe heroes (5 variants) |
| `beast_hero_1-5_emote.png` | `beast_tribes` | Beast hero emote overlays |
| `dwarf1.png`, `dwarf2.png` | `tf_dwarfvelf` | Dwarf characters + emotes |
| `elf1.png`, `elf2.png` | `tf_dwarfvelf` | Elf characters + emotes |
| `elements_char1-5.png` | `elements_core_pack` | Core RPG hero characters |
| `elements_e_childrenA/B.png` | `elements_hometown` | Child NPC sets |
| `elements_e_npcA/B.png` | `elements_hometown` | Town NPC sets |
| `npc_char1.png`, `npc_char2.png` | `npc-animations` | NPC walk sprites (used in Roothollow) |
| `npc_actions1/2.png` | `npc-animations` | NPCs doing activities |
| `npc_bard.png` | `npc-animations 2` | Bard NPC |
| `npc_blacksmith.png` | `npc-animations 2` | Blacksmith NPC |
| `npc_carrying.png` | `npc-animations 2` | NPC carrying items |
| `npc_children.png` | `npc-animations 2` | Children NPCs |
| `npc_eating.png` | `npc-animations 2` | NPC eating |
| `npc_elder.png` | `npc-animations 2` | Elder NPC |
| `npc_executioner.png` | `npc-animations 2` | Executioner NPC |
| `npc_farmer.png` | `npc-animations 2` | Farmer NPC |
| `npc_household.png` | `npc-animations 2` | Household activity NPCs |
| `npc_knights.png`, `npc_knights2.png` | `npc-animations 2` | Knight NPCs |
| `npc_townsfolk.png` | `npc-animations 2` | Town NPCs |
| `children.png` | `elements_hometown` | Children sprite sheet |
| `elder.png` | `elements_hometown` | Elder sprite |
| `farmer.png` | `elements_hometown` | Farmer sprite |
| `household.png` | `elements_hometown` | Household sprite |
| `knights.png` | `elements_hometown` | Knight sprite |
| `mer_8_1.png`, `mer_8_chars1.png`, `mer_human_1.png` | `tf_atlantis` | Merfolk/underwater characters |
| `future_*` | `FutureFantasy` | Sci-fi characters, vehicles, doors, screens |
| `steam_*` | `tf_steampunk` | Steampunk character animations, doors |
| `ff_*` | `tf_fairyforest` | Fairy creatures (dryads, fairies, bugs) |
| `xmas_*` | `christmas` | Holiday characters (Santa, reindeer, gnomes) |

### Battle Sprites (`sprites/characters/battle/`)

Side-view battler sprites for combat scenes.

| File | Source Pack | Description |
|------|------------|-------------|
| `kael_battle.png` | custom | Kael battle sprite |
| `iris_battle.png` | custom | Iris battle sprite |
| `garrick_battle.png` | custom | Garrick battle sprite |
| `beast_hero_1-5_sv.png` | `tf_svbattle` | Beast hero side-view battlers |
| `future_svb_future1-4.png` | `tf_svbattle` | Future character battlers |

### Enemy Sprites (`sprites/enemies/`)

| File | Source Pack | Description |
|------|------------|-------------|
| `ghost1.png` | `tf_fairyforest` | Ghost enemy |
| `harpy_a_1.png`, `harpy_b_1.png` | `tf_mythicalbosses` | Harpy variants (ground pose) |
| `harpy_a_fly_1.png`, `harpy_b_fly_1.png` | `tf_mythicalbosses` | Harpy variants (flying pose) |
| `centaur_a/b/c_1.png` | `tf_mythicalbosses` | Centaur variants |
| `beholder_a/b_1.png` | `tf_mythicalbosses` | Beholder variants |
| `cerberus_1.png` | `tf_mythicalbosses` | Three-headed dog |
| `hydra_3_1.png`, `hydra_5_1.png` | `tf_mythicalbosses` | Hydra (3-head and 5-head) |
| `medusa_1.png` | `tf_mythicalbosses` | Medusa |
| `mummy_1.png` | `tf_mythicalbosses` | Mummy |
| `sasquatch_1.png` | `tf_mythicalbosses` | Sasquatch/yeti |
| `snowmonster_1.png` | `tf_mythicalbosses` | Snow monster |
| `dragon_green_reg.png` | `tf_mythicalbosses_v2` | Green dragon |
| `dragon_red_reg.png` | `tf_mythicalbosses_v2` | Red dragon |
| `boss_chimera_1.png` | `tf_mythicalbosses_v2` | Chimera boss |
| `boss_drider_1.png` | `tf_mythicalbosses_v2` | Drider boss |
| `boss_garuda_1.png` | `tf_mythicalbosses_v2` | Garuda boss |
| `boss_giant_1.png` | `tf_mythicalbosses_v2` | Giant boss |
| `boss_kraken_1.png` | `tf_mythicalbosses_v2` | Kraken boss |
| `boss_statue_east/west_1.png` | `tf_mythicalbosses_v2` | Statue boss (two halves) |

### Building Sprites (`sprites/buildings/`)

Standalone building/structure sprites placed as `Sprite2D` nodes (not tilemap).

| File | Source Pack | Description | Used In |
|------|------------|-------------|---------|
| `hut.png` | `tf_farmandfort` | Small hut building | Roothollow (shop, elder) |
| `lodge_clean.png` | `tf_farmandfort` | Lodge/inn building | Roothollow (inn) |
| `signpost.png` | `tf_farmandfort` | Directional signpost | — |
| `tree_small/medium/tall.png` | `tf_farmandfort` | Standalone tree sprites (3 sizes) | — |

### Animal Sprites (`sprites/animals/`)

Walk sprite sheets for animals and creatures.

| File | Source Pack | Description |
|------|------------|-------------|
| `animals1-5.png` | `tf_animals` | Animal walk sprites (5 sheets — dogs, cats, farm animals) |
| `birds1.png`, `birds2.png` | `tf_animals` | Bird sprites |
| `horse1.png` | `tf_animals` | Horse walk sprite |
| `shadowless_*` | `shadowless` | Shadow-free versions of animal sprites |

### Misc Sprites (`sprites/misc/`)

Vehicles, mini-characters, dungeon props, effects.

| File | Source Pack | Description |
|------|------------|-------------|
| `ship_airship_1/2.png` | `tf_ship_` | Airship sprites (2 variants) |
| `ship_boat_1/2.png` | `tf_ship_` | Small boat sprites |
| `ship_ship_1/2.png` | `tf_ship_` | Large ship sprites |
| `ship_pirates_100.png` | `tf_ship_` | Pirate ship sprite |
| `minis_minis_*.png` | `tf-minis` | Mini/chibi character sprites (15 sets) |
| `dd_doorA/B_1.png` | `tf_darkdimension` | Dark dimension doors |
| `dd_floatingrocks_1.png` | `tf_darkdimension` | Floating rock props |
| `monsterbelly_doors_1.png` | `monsterbelly` | Monster interior doors |
| `monsterbelly_tentacle_1.png` | `monsterbelly` | Tentacle props |
| `char_bubbles.png` | misc | Speech/emote bubble overlays |
| `heartbeat_1.png` | `pixel_animations` | Heartbeat effect animation |
| `future_spacebg.png` | `FutureFantasy` | Space background |

## Portraits (`portraits/`)

Face portraits for dialogue boxes. Format: 96x96 or similar square.

| File | Source Pack | Description | Used As |
|------|------------|-------------|---------|
| `kael_portrait.png` | custom | Kael dialogue portrait | Kael |
| `iris_portrait.png` | custom | Iris dialogue portrait | Iris |
| `garrick_portrait.png` | custom | Garrick dialogue portrait | Garrick |
| `face_tf_char1-8.png` | `tf-faces` | Generic character portraits (8 variants) | Available for NPCs |
| `face_tf_military1-3.png` | `tf-faces` | Military character portraits | Available for guards/soldiers |
| `face_tf_orc1-2.png` | `tf-faces` | Orc portraits | Available for enemies/NPCs |

## Icons (`icons/`)

| File | Source Pack | Description |
|------|------------|-------------|
| `tficons_24.png` | `icons_12.26.19` | 24x24 icon sheet (items, abilities, status effects) |
| `tficons_32.png` | `icons_8.13.20` | 32x32 icon sheet (items, abilities, status effects) |
| `hallowicons_1.png` | `halloween` | Halloween-themed icons |

## Asset Workflow

### Copying New Assets

Use the `/copy-assets` skill, or manually:

```bash
# Copy to main repo (Godot runs from here)
cp /Users/robles/repos/games/assets/<pack>/<file>.png \
   /Users/robles/repos/games/gemini-fantasy/game/assets/<subdir>/<file>.png

# Copy to worktree (agent edits here)
cp /Users/robles/repos/games/assets/<pack>/<file>.png \
   /Users/robles/repos/games/gemini-fantasy/.worktrees/feature-claude1/game/assets/<subdir>/<file>.png
```

After copying, **reopen Godot** to generate `.import` files. Without them, `load()` returns `null`.

### Finding Assets in Source Packs

1. Check this index first for what's already imported
2. Browse source packs at `/Users/robles/repos/games/assets/<pack>/`
3. Only use **1x/16px** versions (skip `2x/`, `3x/`, `4x/` scaled duplicates)
4. Look for files in the root or `1/`, `100/` subdirectories of each pack

### Mapping Game Regions to Art Packs

| Game Region | Primary Tileset Pack | Object Pack |
|-------------|---------------------|-------------|
| Verdant Tangle (forests) | `tf_fairyforest` | `tf_fairyforest` B-sheets |
| Overgrown Ruins | `tf_fairyforest` (ground) + `tf_ruindungeons` (walls/objects) | `tf_ruindungeons` ruins3 |
| Roothollow (town) | `tf_fairyforest` | `tf_fairyforest` mushroom + `tf_farmandfort` buildings |
| Cindral Wastes | `tf_ashlands` | `tf_ashlands` |
| Crystalline Steppes | `tf_atlantis` or `tf_winter` | corresponding B-sheets |
| Ironcoast Federation | `tf_steampunk` | `tf_steampunk` city/interior |
| The Hollows | `tf_darkdimension` | `tf_darkdimension` |
| Giant Tree | `tf_giant-tree` | `tf_giant-tree` |
| Sewers/Underground | `tf_steampunk` sewers | `tf_steampunk` sewers |

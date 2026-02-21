# Asset Pack Index

Comprehensive index of all Time Fantasy and related asset packs in this directory.
All assets are by **finalbossblues** (timefantasy.net) unless otherwise noted.
All files are PNG format with RGBA transparency (8-bit/color) unless noted.

---

## Quick Reference

### Character Walk Sprites (top-down RPG, 4-direction, 3 frames per direction)

| Pack | Characters | 1x Path | Tile Size |
|------|-----------|---------|-----------|
| **FutureFantasy** | Sci-fi/modern heroes, military, vehicles | `FutureFantasy/100/characters/` | 16x16 base |
| **beast_tribes** | Wolf, Cat, Lizard, Bird, Fish heroes + tribes | `beast_tribes/100/` | 16x16 base |
| **tf_dwarfvelf** | 16 dwarves + 16 elves with walk + emote | `tf_dwarfvelf_v1.2/regularsize/` | 16x16 base |
| **tf_japan** | Samurai, ninja, monks, villagers | `tf_japan_11.2.19/RPGMAKER100/char/` | 16x16 base |
| **tf_ship** | 4 pirate characters | `tf_ship_/100/char/pirates_100.png` | 16x16 base |
| **tf_fairyforest** | Dryad, fairies, bugs | `tf_fairyforest_12.28.20/1x/chara/` | 16x16 base |
| **quirky_npcs** | 28 unique NPCs (astronaut, sumo, lucha, etc.) | `quirky_npcs/fullcolor/` | 16x16 base |

### Town/Building Tilesets

| Pack | Theme | 1x Path |
|------|-------|---------|
| **tf_farmandfort** | Medieval farms, forts, tents, crops | `tf_farmandfort/` (icons + master sheet only) |
| **tf_japan** | Japanese buildings, shrines, rooftops | `tf_japan_11.2.19/RPGMAKER100/` (16px) |
| **tf_steampunk** | Industrial city, train stations, interiors | `tf_steampunk_complete/tf_steampunk/RPGMAKER_16x16/` |
| **FutureFantasy** | Modern/sci-fi cities, houses, labs | `FutureFantasy/100/tilesets/` |
| **tf_fairyforest** | Mushroom village, stone structures | `tf_fairyforest_12.28.20/1x/` |
| **TimeFantasy_Winter** | Snow towns, winter buildings | `TimeFantasy_Winter/tiles/` |

### Dungeon/Interior Tilesets

| Pack | Theme | 1x Path |
|------|-------|---------|
| **tf_ruindungeons** | 3 ruin dungeon themes (ancient stone/green/cave) | `tf_ruindungeons/16/` |
| **tf_final_tower** | Dark tower, villain lair, final dungeon | `tf_final_tower_12.24.22/RPGMaker_100/` |
| **tf_giant-tree** | Giant tree exterior + interior | `tf_giant-tree/RPGMAKER-100/` |
| **tf_steampunk (sewers)** | Sewer dungeon tileset | `tf_steampunk_complete/tf_sewers/RPGMAKER_16x16/` |
| **tf_steampunk (dungeon)** | Industrial dungeon | `tf_steampunk_complete/tf_steampunk/RPGMAKER_16x16/` |
| **monsterbelly** | Inside giant monster's belly dungeon | `monsterbelly_11.42.21/100/` |

### Enemy/Boss Sprites

| Pack | Creatures | 1x Path |
|------|-----------|---------|
| **tf_mythicalbosses** | Chimera, Drider, Garuda, Giant, Kraken, Statues + 20 more | `tf_mythicalbosses/100/` |
| **tf_mythicalbosses (dinosaurs)** | T-Rex, Raptor, Pterosaur, Neckosaurus (normal + attack) | `tf_mythicalbosses/dinosaurs/` |
| **monsterbelly** | Cell monsters, giant worm | `monsterbelly_11.42.21/100/` |

### Battle System Sprites

| Pack | Contents | Path |
|------|----------|------|
| **tf_svbattle** | 10 hero characters x 8 color variants, side-view battle | `tf_svbattle/RMMV/sv_actors/` |
| **beast_tribes (SV)** | 5 beast hero SV battlers | `beast_tribes/100/sv_battler/` |
| **FutureFantasy (SV)** | 4 sci-fi SV battlers | `FutureFantasy/RMMV/svbattler/` |
| **tf_japan (SV)** | Samurai, ninja, monk SV battlers | `tf_japan_11.2.19/RPGMAKER100/char/sv_*.png` |

### NPC Animation Sprites

| Pack | Contents | 1x Path |
|------|----------|---------|
| **npc-animations** | Townsfolk, blacksmith, bard, elder, farmer, knights, children, etc. | `npc-animations/rpgmaker/1/` |

### Character Face Portraits

| Pack | Contents | 1x Path |
|------|----------|---------|
| **tf-faces** | 8 hero faces + 3 military + 2 orc (transparent + solid bg) | `tf-faces-6.11.20/transparent/1x/` |

### Icons

| Pack | Count | Sizes | Path |
|------|-------|-------|------|
| **tf_farmandfort (icons)** | 335 RPG icons (weapons, armor, items, gems, food) | 16/24/32px | `tf_farmandfort/IconSet/` |
| **icons_12.26.19** | 1023 general RPG icons | 16/24/32px | `icons_12.26.19/fullcolor/` |
| **icons_8.13.20** | 1023 general RPG icons (updated) | 16/24/32px | `icons_8.13.20/fullcolor/` |

### Miscellaneous

| Pack | Contents | Path |
|------|----------|------|
| **pixel_animations_gfxpack** | Battle VFX: fire, ice, lightning, wind, water, earth, holy, darkness, heal, weapons, status, smoke, dust, etc. | `pixel_animations_gfxpack/animationsheets/` |
| **pixel_tarot_deck** | 78 pixel tarot cards (22 major + 56 minor arcana) + spin/flash animations | `pixel_tarot_deck/` |
| **mecha_war_pack** | 4 mecha designs x 4 poses (stand, fly, wings, standwings) + fighters | `mecha_war_pack/fullcolor/1X_normal/` |
| **tf_animals** | Dogs, cats, ducks, foxes, rabbits, horses, birds (walk sprites) | `tf_animals/sheets/` |
| **shadowless** | Same animals as tf_animals but without shadow sprites | `shadowless/` |

---

## Scale/Format Reference

Most packs provide 3 scale variants:

| Label | Tile Size | Character Cell | Intended For | Recommended For Godot |
|-------|-----------|---------------|--------------|----------------------|
| **100** / **1x** / **16** / **regularsize** | 16x16 px | ~26x48 px per frame | Base / general use | Yes (import at 1x, scale in engine) |
**For Godot 4.5**: Use the **1x (16x16)** versions as the base. Import as-is and let Godot handle scaling via `texture_filter = "nearest"` for crisp pixel art.

### Color Variants

Some packs include two color palettes:
- **Full color** / **fullcolor**: Vivid, saturated colors for general use
- **TF color** / **tfcolor**: Desaturated palette matching the original Time Fantasy style

---

## Detailed Pack Descriptions

### 1. beast_tribes

**Path**: `beast_tribes/`
**Contents**: Fantasy beast-race character sprites -- five animal tribes
**Tribes**: Wolf Men (Kobolds), Cat Men, Lizard Men, Bird Men, Fish Men

**Files per format variant**:
- `beast_hero_[1-5].png` -- Hero character walk sprites (3 cols x 4 rows = 12 frames, 4-direction)
- `beast_hero_[1-5]_emote.png` -- Hero emote animations
- `beast_tribe_[1-5].png` -- 8 regular NPCs per tribe (12 cols x 8 rows)
- `sv_battler/beast_hero_[1-5]_sv.png` -- Side-view battle sprites

**Dimensions (100/1x)**: Hero sprites 78x144 px; SV battlers 432x288 px
**Formats**: 100

**Character Layout**: Each hero sprite sheet is 3 columns x 4 rows. Each row is one direction (down, left, right, up). Each column is one animation frame. Single character per file (26x36 px per frame at 1x).

---

### 2. FutureFantasy

**Path**: `FutureFantasy/`
**Contents**: Modern/sci-fi themed tileset and character expansion

**Characters** (in `characters/` subdirectory):
- `future[1-4].png` -- Sci-fi hero sprites (8 characters per sheet)
- `modern[1-3].png` -- Modern-day character sprites
- `military[2-3].png` -- Military character sprites
- `cars.png` -- Vehicle sprites
- `chests.png` -- Sci-fi chest animations
- `!doors_future.png`, `!doors_moderna.png`, `!doors_modernb.png` -- Animated doors
- `!screens_*.png` -- Animated screen objects
- `!conveyerbelt*.png` -- Animated conveyor belts

**Tilesets** (in `tilesets/` subdirectory):
- `future_tileA5_*.png` -- Sci-fi terrain (city, factory, spacestation, inside)
- `future_tileB_*.png` -- Sci-fi objects (city, lab, factory, inside)
- `modern_tileA5_*.png` -- Modern terrain (outside, inside, junkyard)
- `modern_tileB_*.png` -- Modern objects (house1-6, outside, inside, junkyard)

**SV Battlers**: `svbattler/svb_future[1-4].png` (4 sci-fi battle characters)
**Other**: `spacebg.png` -- Space background

**Dimensions (100/1x)**: Character sheets 312x288 px; Tile A5 sheets 128x256 px
**Formats**: 100

---

### 3. icons_12.26.19

**Path**: `icons_12.26.19/`
**Contents**: 1023 individual RPG icons -- weapons, armor, potions, status effects, items, gems, UI elements

**Structure**:
- `fullcolor/icons_full_16.png` -- Complete spritesheet (256x1024 px, all 1023 icons at 16x16)
- `fullcolor/individual_16x16/icon[001-1023].png` -- Individual 16x16 icons
- `fullcolor/individual_24x24/` -- Individual 24x24 icons (same set)
- `fullcolor/individual_32x32/` -- Individual 32x32 icons (same set)
- `tfcolor/` -- Same structure in Time Fantasy color palette

**Icon sizes**: 16x16, 24x24, 32x32 (individually extracted)

---

### 4. icons_8.13.20

**Path**: `icons_8.13.20/`
**Contents**: Same 1023-icon set as icons_12.26.19 (updated release)

**Structure**: Same as icons_12.26.19 with an additional `updated_layout/` folder containing:
- `icons_full_16.png`, `icons_full_32.png` -- Full color spritesheets
- `icons_tf_16.png`, `icons_tf_32.png` -- TF color spritesheets

**Icon sizes**: 16x16, 24x24, 32x32

---

### 5. mecha_war_pack

**Path**: `mecha_war_pack/`
**Contents**: 4 giant mecha robot designs with multiple poses, plus fighter craft

**Files per mech (A through D)**:
- `mech[A-D]_stand.png` -- Standing pose
- `mech[A-D]_standwings.png` -- Standing with wings deployed
- `mech[A-D]_wingsready.png` -- Wings in ready position
- `mech[A-D]_fly.png` -- Flying pose
- `fighters.png` -- Small fighter craft sprites
- `fighter_shots.png` -- Projectile sprites

**Dimensions (1x)**: 240x320 px per mech sheet
**Color variants**: `fullcolor/` and `tfcolor/`
**Formats**: 1X_normal

---

### 6. monsterbelly_11.42.21

**Path**: `monsterbelly_11.42.21/`
**Contents**: "Inside the Monster's Belly" dungeon tileset expansion

**Files**:
- `tf_insidebelly_fullsheet.png` -- Complete tileset in one sheet (100 only, 576x272 px)
- `tf_insidebelly_tileA[1,2,5]_*.png` -- Terrain tiles (organic walls, fleshy floors)
- `tf_insidebelly_tileB_*.png` -- Object tiles
- `!tf_insidebelly_tentacle_*.png` -- Animated tentacle obstacles
- `!tf_insidebelly_doors_*.png` -- Animated organic doors
- `$cellmonsters_*.png` -- Bacteria cell enemy sprites
- `$heartbeat_*.png` -- Animated heartbeat (3 frames, with shadow variants)
- `giantworm_1.png` -- Giant worm entrance sprite (576x384 at 1x)
- `giantworm_terrain_1.png` -- Giant worm blended with terrain

**Formats**: 100

---

### 7. npc-animations

**Path**: `npc-animations/`
**Contents**: Animated NPC sprites with activity-specific animations (not just walking)

**Sprite Sheets** (in `rpgmaker/1/`):
- `townsfolk.png` -- 4 townsfolk with various actions (456x288 px at 1x)
- `blacksmith.png` -- Blacksmith hammering animation
- `bard.png` -- Bard playing music
- `elder.png` -- Elder NPC
- `farmer.png` -- Farming animations
- `knights.png` -- Knight characters
- `knights2.png` -- Additional knights (RMVX/1x only; `knights3.png` in RMMV)
- `children.png` -- Child NPCs
- `eating.png` -- Eating animation
- `carrying.png` -- Carrying objects
- `household.png` -- Household activity animations
- `executioner.png` -- Executioner character
- `actions1.png`, `actions2.png` -- Miscellaneous action animations

**Updated blacksmith**: `blacksmith_updated/blacksmith_updated_[1-3].png` (3 scale variants)
**Individual frames**: `individual_frames/townsfolk/` -- Per-frame PNGs for each townsfolk action

**Dimensions (1x)**: Sheets are 456x288 px (varies by sheet)
**Formats**: 1

**Note**: `npc-animations 2/` is a duplicate of this pack.

---

### 8. pixel_animations_gfxpack

**Path**: `pixel_animations_gfxpack/`
**Contents**: Battle visual effect animations for RPG combat

**Animation Sheets** (in `animationsheets/`):
- **Elemental**: `fire.png`, `ice.png`, `water.png`, `lightning.png`, `wind.png`, `earth1.png`, `earth2.png`
- **Magic**: `holy.png`, `darkness.png`, `heal.png`
- **Physical**: `claw_bite.png`, `arrow.png`, `weapons_1.png`, `weapons_2.png`, `weapons_3.png`
- **Impact**: `impact1.png`, `impact2.png`, `explosion.png`
- **Particles**: `smoke.png`, `dust.png`, `diamond.png`, `clock.png`
- **Status**: `status_1.png`, `status_2.png`
- **Objects**: `object.png`

**Dimensions**: Varies per sheet (e.g., fire.png is 320x384 px). Each sheet contains multiple animation variants arranged in rows, with 4-8 frames per row.

**Individual frames**: `individual_frames/[effect_name]/` -- Per-frame PNGs for each effect (diamond, smoke, dust, lightning, etc.)

---

### 9. pixel_tarot_deck

**Path**: `pixel_tarot_deck/`
**Contents**: Complete 78-card pixel art tarot deck

**Structure**:
- `major_arcana/` -- 22 cards (tarot__fool.png through tarot__world.png)
- `minor_arcana/` -- 56 cards (4 suits: cups, pentacles, swords, wands; ace through king)
- `animations/` -- Card flip/spin animations (tarot__flash_[1-4].png, tarot__spin_[1-7+].png)

**Card dimensions**: 58x90 px each
**Naming**: `tarot__[name].png` (double underscore)

---

### 10. quirky_npcs

**Path**: `quirky_npcs/`
**Contents**: 28 unique/humorous NPC character sprites

**Characters** (in `fullcolor/`):
- aeronaut, astronaut (+ walk variant), barrel, barrelgob, barrelman, bush
- cobra, conductor, coolcat (+ shadow variant), foodboys
- ironchef (+ walk variant), lucha (+ shadow variant)
- onionboss (+ shadow variant), pigman (+ walk variant)
- shoewoman, signguy, snakecharmer, sumo, sunandmoon
- trenchcoat, tunneler, twins

**Dimensions (1x)**: ~138x192 px per character (varies)

**Character Layout**: Same as standard Time Fantasy -- 3 cols x 4 rows per character (single character per file).

---

### 11. shadowless

**Path**: `shadowless/`
**Contents**: Animal sprites from tf_animals pack but WITHOUT ground shadows

**Files**:
- `animals[1-5]_shadowless.png` -- Base 1x versions
- `animals[1-5]_shadowless_2x.png` -- 2x scale
- `animals[1-5]_shadowless_3x.png` -- 3x scale
- `birds1_shadowless.png` (+ 2x, 3x)
- `horse1_shadowless.png` (+ 2x, 3x)

**Dimensions (1x)**: 312x288 px (same as tf_animals sheets)
**Use case**: When you need animals rendered over terrain without baked-in shadows (e.g., for dynamic shadow systems).

---

### 12. tf_animals

**Path**: `tf_animals/`
**Contents**: Domestic and wild animal walk sprites with shadows

**Sprite Sheets** (in `sheets/` for 1x):
- `animals1.png` -- Dogs, cats, rabbits, foxes (312x288 px)
- `animals2.png` -- More small animals
- `animals3.png` -- Additional animals
- `animals4.png` -- Additional animals
- `animals5.png` -- Additional animals
- `birds1.png`, `birds2.png` -- Bird sprites
- `horse1.png` -- Horse sprites

**Individual frames**: `individual_frames/animals1/` etc. -- Per-frame PNGs

**Dimensions (1x/sheets)**: 312x288 px per sheet
**Formats**: sheets (1x)

**Layout**: Multiple characters per sheet, 3 frames x 4 directions per character.

---

### 13. tf_dwarfvelf_v1.2

**Path**: `tf_dwarfvelf_v1.2/`
**Contents**: 32 character sprites -- 16 dwarves + 16 elves with walk and emote animations

**Files per format**:
- `dwarf1.png`, `dwarf2.png` -- 8 dwarf characters each (16 total)
- `dwarf1_emote.png`, `dwarf2_emote.png` -- Dwarf emote animations
- `elf1.png`, `elf2.png` -- 8 elf characters each (16 total)
- `elf1_emote.png`, `elf2_emote.png` -- Elf emote animations

**Dimensions (regularsize/1x)**: 312x288 px per character sheet (8 characters per sheet)
**Formats**: regularsize

---

### 14. tf_fairyforest_12.28.20

**Path**: `tf_fairyforest_12.28.20/`
**Contents**: Fairy forest tileset expansion -- enchanted woods, mushroom village, stone ruins

**Tilesets** (in `1x/` for base size):
- `tf_ff_tileA5_a.png`, `tf_ff_tileA5_b.png` -- Terrain tiles (128x256, 8x16 grid)
- `tf_ff_tileB_forest.png` -- Forest objects (trees, bushes, stumps) (256x256 px)
- `tf_ff_tileB_trees.png` -- Large tree objects
- `tf_ff_tileB_stone.png` -- Stone/ruin objects
- `tf_ff_tileB_mushroomvillage.png` -- Mushroom house village objects

**Characters** (in `1x/chara/`):
- `dryad_green_1.png`, `dryad_skin_1.png` -- Dryad character walk sprites (78x144 px at 1x, single character)
- `littlefairies_1.png` -- Tiny fairy sprites
- `bugz_1.png` -- Bug/butterfly sprites
- `tf_ff_doors_1.png` -- Animated fairy forest doors

**Master sheet**: `ff_master_tiles.png` -- Complete tileset in one image
**Formats**: 1x

---

### 15. tf_farmandfort

**Path**: `tf_farmandfort/`
**Contents**: Medieval farm + fortress tilesets and 335 RPG icons

**Icon Set** (in `IconSet/`):
- `tf_icon_16.png` -- All 335 icons on one sheet at 16px
- `tf_icon_32.png` -- All icons at 32px

**Icon categories**: Hearts, stars, status icons, swords, shields, axes, spears, staffs, wands, bows, whips, guns, bombs, armor (body/helmet/gloves/boots), rings, keys, books, scrolls, tools, potions, herbs, food, crops, fish, gems, ores, metals, wood, soil, gold, treasures, musical instruments, feathers, claws, scales, shells, slimes, UI elements.

**Master sheet**: `ff_master_tile_sheet.png` (656x832 px)
**Note**: Only the icon set and master sheet remain. Individual tile sheets were only available in upscaled formats (removed).

---

### 16. tf_final_tower_12.24.22

**Path**: `tf_final_tower_12.24.22/`
**Contents**: Final dungeon tower tileset -- villain's lair, dark tower interior

**Files per format**:
- `tileA5a.png`, `tileA5b.png` -- Wall/floor terrain tiles
- `tileB.png` -- Object layer tiles (256x256 at 100, 768x768 at MVZ)
- `towercharA.png`, `towercharB.png`, `towercharC.png` -- Animated character-format tiles (doors, effects)

**World Map Bonus**:
- `finaltower_worldmap_fullcolor.png` / `finaltower_worldmap_tfcolor.png` -- World map tower tiles (100)
- `finaltower_worldmap_*_2x.png` (VX), `*_3x.png` (MVZ)

**Complete sheets**: `finaltower_complete_fullcolor.png`, `finaltower_complete_tfcolor.png`
**Color variants**: Full_color and TF_color subdirectories
**Formats**: RPGMaker_100

---

### 17. tf_giant-tree

**Path**: `tf_giant-tree/`
**Contents**: Giant tree tileset -- massive tree exterior and interior

**Files per format**:
- `tf_A5_gianttree_ext.png` -- Exterior terrain tiles
- `tf_A5_gianttree_int.png` -- Interior terrain tiles
- `tf_B_gianttree_ext.png` -- Exterior objects (256x256 at 100, 768x768 at MV)
- `tf_B_gianttree_int.png` -- Interior objects

**Master sheet**: `tf_gianttree_tiles.png`
**Promo**: `promo/screenshot1.png`, `promo/screenshot2.png`, `promo/itch_cover.png`
**Formats**: RPGMAKER-100

---

### 18. tf_japan_11.2.19

**Path**: `tf_japan_11.2.19/`
**Contents**: Japanese-themed tileset expansion -- feudal Japan buildings, shrines, outdoors

**Tilesets** (in `RPGMAKER100/`):
- `tileA5_japan_inside.png` -- Interior terrain
- `tileA5_japan_outside.png` -- Exterior terrain
- `tileB_japan_buildings.png` -- Japanese building parts (256x256 at 100, 768x768 at MV)
- `tileB_japan_inside1.png` -- Interior objects
- `tileB_japan_inside2_shrine.png` -- Shrine interior
- `tileB_japan_outside1.png`, `tileB_japan_outside2.png` -- Outdoor objects
- `tileB_japan_rooftop.png` -- Rooftop tiles

**Characters** (in `char/`):
- `samurai.png` -- Samurai walk sprite (78x144 at 100, single character)
- `ninja.png` -- Ninja walk sprite
- `monks.png` -- Monk walk sprites (multiple characters)
- `char_japan.png` -- Japanese villager characters
- `fish.png` -- Fish sprites
- `sv_samurai.png`, `sv_ninja.png`, `sv_mon.png` / `sv_monk1.png` -- Side-view battlers
- `!doors1a.png`, `!doors1b.png`, `!doors2.png` -- Animated door tiles

**Master sheet**: `tf_japan_master.png`
**Formats**: RPGMAKER100

---

### 19. tf_mythicalbosses / tf_mythicalbosses_v2

**Path**: `tf_mythicalbosses/` and `tf_mythicalbosses_v2/`
**Contents**: Large boss/enemy sprites for RPG battles. v2 appears to be an updated release of the same set.

**Boss sprites** (per format):
- `boss_chimera_*.png` -- Chimera (321x368 px at 1x) -- multi-headed beast
- `boss_drider_*.png` -- Drider (spider-centaur)
- `boss_garuda_*.png` -- Garuda (winged deity)
- `boss_giant_*.png` -- Giant humanoid
- `boss_kraken_*.png` -- Kraken (sea monster)
- `boss_statue_east_*.png`, `boss_statue_west_*.png` -- Animated guardian statues

**Monster sprites**:
- `beholder_a_*.png`, `beholder_b_*.png` -- Beholder variants
- `centaur_a_*.png`, `centaur_b_*.png`, `centaur_c_*.png` -- Centaur variants
- `cerberus_*.png` -- Three-headed dog
- `dragon_green_*.png`, `dragon_red_*.png` -- Dragons
- `ghost[1-3].png` -- Ghost sprite
- `harpy_a_*.png`, `harpy_b_*.png` (+ `_fly` variants) -- Harpies
- `hydra_3_*.png`, `hydra_5_*.png` -- 3-headed and 5-headed hydra
- `medusa_*.png` -- Medusa
- `mummy_*.png` -- Mummy
- `sasquatch_*.png` -- Sasquatch/yeti
- `snowmonster_*.png` -- Snow creature

**Dinosaurs** (in `dinosaurs/`):
- `dd__trex.png`, `dd__trex_atk.png` -- Tyrannosaurus Rex (idle + attack)
- `dd__raptor.png`, `dd__raptor_atk.png` -- Velociraptor
- `dd__neckosaurus.png`, `dd__neckosaurus_atk.png` -- Long-neck dinosaur
- `dd__ptersaur.png`, `dd__pterosaur_atk.png` -- Pterosaur
- Scaled variants in `dinosaurs-VX/` (2x) and `dinosaurs-MV/` (3x)

**Dimensions (100/1x)**: Varies per boss (e.g., chimera 321x368 px)
**Formats**: 100

**Layout**: Each boss sprite is arranged as 3 columns x 4 rows -- showing animation frames from different angles. Large bosses may span multiple tile cells.

---

### 20. tf_ruindungeons

**Path**: `tf_ruindungeons/`
**Contents**: 3 themed ruin dungeon tilesets with terrain, objects, and animated water

**Tilesets per dungeon variant** (in `16/` for 1x):
- `tf_A5_ruins[1-3].png` -- 3 terrain/floor variants (128x256, 8x16 grid each)
- `tf_B_ruins[1-3].png` -- 3 object layer variants (256x256 at 16px, 512x512 at 32px, 768x768 at 48px)

**Master sheet**: `ruindungeons_sheet_full.png`
**Formats**: 16 (16x16)

The 3 dungeon themes are: ancient stone ruins, overgrown green ruins, and cave/underground ruins.

---

### 21. tf_ship_

**Path**: `tf_ship_/`
**Contents**: Ship construction tileset -- build ships facing different directions

**Tilesets** (per format, in `tileset/` or `tiles/`):
- `tf_ship_tileA5_east.png` -- Ship hull facing east
- `tf_ship_tileA5_west.png` -- Ship hull facing west
- `tf_ship_tileA5_north.png` -- Ship hull facing north
- `tf_ship_tileA5_interior.png` -- Ship interior
- `tf_ship_tileB.png` -- Ship objects (masts, sails, cannons, barrels, etc.) (256x256 at 100)
- `tf_ship_tileC.png` -- Additional ship objects

**Characters** (in `char/`):
- `pirates_100.png` / `pirates_vxa.png` / `pirates_MV.png` -- 4 pirate walk sprites (312x288 at 100)
- `ship_1.png`, `ship_2.png` -- Ship vehicle sprites
- `boat_1.png`, `boat_2.png` -- Boat vehicle sprites
- `airship_1.png`, `airship_2.png` -- Airship vehicle sprites
- `!$ship_wave_east.png`, `!$ship_wave_west.png` -- Animated wave effects

**Parallax**: `parallax/parallax_water_[a-d].png` -- Sea water parallax backgrounds
**Master sheet**: `ship_big_tileset.png`
**Formats**: 100

---

### 22. tf_steampunk_complete

**Path**: `tf_steampunk_complete/`
**Contents**: Complete steampunk theme -- city, train, dungeon, interior, AND sewer tilesets

#### tf_steampunk (main)

**Tilesets** (in `tf_steampunk/RPGMAKER_16x16/tileset/` for 1x):
- `tfsteampunk_tileA5_int.png` -- Interior terrain
- `tfsteampunk_tileA5_dungeon.png` -- Dungeon terrain
- `tfsteampunk_tileA5_trainint.png` -- Train interior terrain
- `tfsteampunk_tileB_city1.png` -- City objects set 1 (256x256 at 16px, 768x768 at MV)
- `tfsteampunk_tileB_city2.png` -- City objects set 2
- `tfsteampunk_tileB_city2b.png`, `tfsteampunk_tileB_city2c.png` -- Additional city objects
- `tfsteampunk_tileB_int1.png`, `tfsteampunk_tileB_int2.png` -- Interior objects
- `tfsteampunk_tileB_train1.png`, `tfsteampunk_tileB_train2.png` -- Train objects
- `tfsteampunk_tileB_dungeon.png` -- Dungeon objects

**Character/Animations** (in `charset/`):
- `!animchar_steampunk[1-3].png` -- Animated steampunk character effects
- `!animchar_smoke.png`, `!animchar_steam.png` -- Smoke/steam effects
- `!doors1.png`, `!doors2.png` -- Animated doors
- `!traindoors[1-3].png` -- Animated train doors

**Master sheet**: `tfsteampunk_tileset_master.png`

#### tf_sewers

**Tilesets** (in `tf_sewers/RPGMAKER_16x16/` for 1x):
- `tfsewers_tileA5_1.png` -- Floor terrain
- `tfsewers_tileB_1.png` -- Sewer objects

**Master sheet**: `tfsewer_tileset_master.png`
**Example**: `example.png` -- Screenshot showing tileset in use

**Formats**: RPGMAKER_16x16 (16px)

---

### 23. tf_svbattle

**Path**: `tf_svbattle/`
**Contents**: Side-view battle character sprites for RPG combat -- 10 base characters with 8 color recolors each

**RMMV format** (in `RMMV/sv_actors/`):
- `[1-7]_[1-8].png` -- Characters 1-7 in 8 color variants (1296x864 px each)
- `mil[1-3]_[1-8].png` -- Military characters 1-3 in 8 color variants

**Layout**: Each SV battler sheet is 9 columns x 6 rows. Rows represent animation states: idle, walk/step forward, slash/attack, guard, cast spell, skill, take damage, collapse/KO. Each state has 3 frames.

**System**: `RMMV/system/` -- UI system graphics for battle

**Single frames**: `singleframes/set[1-7]/[1-8]/` and `singleframes/military[1-3]/[1-8]/` -- Individual animation frames extracted per character per color variant.

**Total files**: ~3042 PNG files
**Formats**: RMMV (48px scale)

---

### 24. tf-faces-6.11.20

**Path**: `tf-faces-6.11.20/`
**Contents**: Character face/portrait graphics for dialogue boxes and menus

**Characters**:
- `tf_char[1-8]` -- 8 main hero character face sets
- `tf_military[1-3]` -- 3 military character face sets
- `tf_orc[1-2]` -- 2 orc character face sets

**Each face file**: Contains a 4x2 grid of face expressions/emotions for use in dialogue.

**Dimensions (1x)**: 192x96 px per face sheet (48x48 per individual face at 1x)

**Variants**:
- `transparent/` -- Transparent background
- `solid/` -- Solid background fill

**Structure**:
- `transparent/1x/tf_char1.png` -- Base size, transparent
- `solid/` -- Same structure with solid backgrounds

---

### 25. TimeFantasy_Winter

**Path**: `TimeFantasy_Winter/`
**Contents**: Winter/snow themed tileset expansion -- snowy towns, ice caves, winter trees

**Tilesets** (in `tiles/` for 1x, 16x16 grid):
- `tf_winter_terrain.png` -- Snow terrain base tiles
- `tf_winter_water.png` -- Animated ice/snow water
- `tf_winter_tileB.png` -- Winter objects (256x256) -- snowy trees, buildings, fences, rocks, bushes
- `tf_winter_tileC.png` -- Additional winter objects (trees, tents, mountains, stumps)
- `tf_winter_tileD.png` -- More winter objects

**Dimensions (tiles/1x)**: 256x256 px per tile sheet
**Formats**: tiles (1x/16px)

---

---

### 26. TimeFantasy_TILES

**Path**: `TimeFantasy_TILES/`
**Contents**: Original Time Fantasy base tileset -- flat 16x16 grid (NOT RPGMaker autotile format). Hundreds of tiles covering all core biomes: terrain, outdoor, dungeon, castle, interior, world map, and animated water.
**License**: Commercial (finalbossblues / timefantasy.net)
**Free**: No

**TILESETS/ (flat 16x16 grid sheets -- use these directly in Godot):**

| File | Contents |
|------|----------|
| `terrain.png` | Grass, dirt, rock, sand terrain with many variants |
| `outside.png` | Forest, mountain, cliff, and desert outdoor tiles |
| `dungeon.png` | Cave, mine, ruin, and temple dungeon tiles |
| `castle.png` | Castle interior and exterior tiles |
| `house.png` | House base tiles (updated 2017 -- multi-story, mix-and-match roofs) |
| `inside.png` | Generic interior floor/wall tiles |
| `water.png` | Water tiles in 8x8 RPGMaker autotile chunk format (legacy) |
| `world.png` | World map tiles |
| `desert.png` | Desert terrain tiles |

**TILESETS/animated/ (animated tile sheets, RPGMaker character format):**

| File | Contents |
|------|----------|
| `doors.png` | Animated door open/close (RPGMaker VX/Ace compatible format) |
| `fireplace.png` | Animated fireplace effect |
| `puzzle.png` | Animated traps and switches for puzzles |
| `torch.png` | Animated torch/light effect |

**RPGMAKER/ (RPGMaker-formatted variants -- separated A1/A2/A4/A5/B/C/D sheets):**

The RPGMAKER folder provides the same content split into RPGMaker slot-specific sheets at two scales:
- `RMMV/` -- 3x scale for RPGMaker MV/MZ
- `RMVX/` -- 2x scale for RPGMaker VX/Ace

Both contain sheets named `tileA1_*`, `tileA2_*`, `tileA4_*`, `tileA5_*`, `tileB_*`, `tileC_*`, `tileD_*` covering outside, dungeon, inside, world, desert, house, castle, and house rooftop (6 color variants: black, blue, gold, gray, green, red, snow).

**Key format notes:**
- `TILESETS/*.png` (except `water.png`) -- flat 16x16 grids, safe to import directly as Godot TileSet atlas sources
- `water.png` -- uses 8x8 RPGMaker autotile chunks (legacy). Use `water_updated.png` instead (see below)
- **`water_updated.png`** -- plain 16x16 water tiles (not autotile chunks). This is the correct file for Godot. Added in the 6.6.2016 update.
- `inside.png` ceiling border tiles were also corrected in a past update; use `inside_ceilingborders_updated.png` if present
- The 2017 update reorganized most sheets to include extra tiles; the RPGMAKER sheets also include the rooftop expansion with 6 color variants

**Visual Guide**: `guide.png` -- essential reference showing how to best combine these tiles

---

### 27. tf_ashlands

**Path**: `tf_ashlands/`
**Contents**: Ashlands tileset -- volcanic/barren wastelands biome. Mini-expansion compatible with all Time Fantasy graphics. Free release (Patreon reward).
**License**: Free (Patreon community release -- finalbossblues)
**Tile size**: 16x16

**Master sheet (flat, use in Godot):**

| File | Contents |
|------|----------|
| `ashlands_tileset.png` | Complete ashlands tileset on a single flat sheet (imported into Godot) |

**Individual sheets by scale** (in `1x/`, `2x_RMVX/`, `3x_RMMV/`):

Each scale folder contains four sheets:
| File | Contents |
|------|----------|
| `tf_A1_ashlands_1.png` | Animated water/lava terrain (A1 RPGMaker slot) |
| `tf_A2_ashlands_1.png` | Ground terrain (A2 slot) |
| `tf_A5_ashlands_1.png` | Terrain overlay / flat ground tiles (A5 slot) |
| `tf_B_ashlands_1.png` | Object tiles -- rocks, dead trees, volcanic features |

**Formats**: 1x (16px), 2x_RMVX, 3x_RMMV

**Note**: The `1x/` folder files have `.import` sidecars, indicating they are already tracked by Godot. Use `ashlands_tileset.png` (master) as the primary atlas source or the individual `1x/` sheets for slot-matched layering.

---

### 28. elements_cavesandmines_6.3.23

**Path**: `elements_cavesandmines_6.3.23/`
**Contents**: Time Elements -- Caves and Mines pack. Three underground biomes (root caves, mossy caverns, stone dungeons) plus mine tracks, ore carts, ores in multiple colors, vines/foliage, prison jail cells, interactive switches/levers, traps, and spotlight effects. Designed to work with Time Elements character sprites.
**License**: Commercial (finalbossblues)
**Tile size**: 16x16

**Master sheets (flat, use directly in Godot):**

| File | Contents |
|------|----------|
| `master_cavesmines.png` | All tile and object assets on a single flat sheet (100% size, autotiles included) |
| `ores_mining_animation_sheet.png` | Mining ore animation frames (16x16 grid aligned) |

**Individual sheets (in `RPGMAKER/1X/`):**

Tilesets:
| File | Contents |
|------|----------|
| `tileA1_caves.png` | Animated cave water/lava (A1 slot) |
| `tileA2_caves.png` | Cave ground terrain (A2 slot) |
| `tileA5_cave1.png` | Root cave flat terrain |
| `tileA5_cave2.png` | Mossy cavern flat terrain |
| `tileA5_cave3.png` | Stone dungeon flat terrain |
| `tileB_cave1.png` | Root cave objects (walls, stalagmites, roots) |
| `tileB_cave2.png` | Mossy cavern objects |

Characters (animated objects, RPGMaker format):
| File | Contents |
|------|----------|
| `!levers.png` | Interactive lever switches (on/neutral/off states) |
| `!lights.png` | Semi-transparent flickering spotlight effects (multiple alignment variants) |
| `!minecart.png` | Animated mine cart |
| `!traps.png` | Animated traps |

Animations (battle animation format for mining):
| File | Contents |
|------|----------|
| `ores_mining_anim_A.png` | Ore mining strike animation set A |
| `ores_mining_anim_B.png` | Ore mining strike animation set B |

**Formats**: 1X (16px), 2X (RMVX), 3X (RMMV/MZ)

**Animation notes**: Levers use 3 static frames representing states. Lights use 4-frame spinning animation. Minecart uses 3-frame stepping animation. Mining animations are in RPGMaker battle-animation format; for MZ, right-click and select "MV-compatible data".

---

### 29. elements_hometown_6.3.23

**Path**: `elements_hometown_6.3.23/`
**Contents**: Time Elements -- Hometown Tileset pack. Classic fantasy towns and villages with surrounding forest environments. Includes farmland with multi-growth-stage crops, home/shop/inn/blacksmith interiors, fireplace/torch/candle animations, and outdoor natural terrain. Designed to work with Time Elements character sprites.
**License**: Commercial (finalbossblues)
**Tile size**: 16x16

**Master sheet (flat, use directly in Godot):**

| File | Contents |
|------|----------|
| `master_everything.png` | All assets on a single flat sheet (100% size, full autotiles included) |

**Individual sheets (in `RPGMAKER/1X/`):**

Tilesets:
| File | Contents |
|------|----------|
| `tileA1.png` | Animated water / terrain borders (A1 slot) |
| `tileA2.png` | Ground terrain -- grass, dirt, paths (A2 slot) |
| `tileA3.png` | Buildings/walls top-layer terrain (A3 slot) |
| `tileA4.png` | Wall tiles (A4 slot) |
| `tileA5_inside.png` | Interior floor tiles |
| `tileA5_outside.png` | Outdoor flat terrain |
| `tileA5_town.png` | Town square / cobblestone terrain |
| `tileB_inside.png` | Interior object tiles (furniture, shelving, counters) |
| `tileB_outside.png` | Outdoor objects (trees, rocks, fences, wells) |
| `tileB_town.png` | Town object tiles (market stalls, signs, barrels) |

Characters (animated objects, RPGMaker format):
| File | Contents |
|------|----------|
| `!chests.png` | Animated treasure chest open/close |
| `!crops.png` | Crop growth stages (farm plots) |
| `!doors1a.png`, `!doors1b.png` | Animated door variants (set 1) |
| `!doors2a.png`, `!doors2b.png` | Animated door variants (set 2) |
| `!fires.png` | Animated fireplace / campfire |
| `!objects1.png` | Animated table objects (books, food) |
| `!objects2.png` | Additional animated objects |
| `!smoke.png` | Animated chimney smoke |

**Formats**: 1X (16px), 2X (RMVX), 3X (RMMV/MZ)

**Animation notes**: Most animated objects use 4-frame animation (spinning motion in RPGMaker). Some use 3-frame stepping animation. Still-frame objects (table decorations) are single frames.

---

### 30. tiles_fourseasons

**Path**: `tiles_fourseasons/`
**Contents**: Four Seasons tileset expansion -- three seasonal variants (spring, fall, winter) designed as tile-swap replacements for the Elements Hometown pack's "summer" tileset. Free update released December 2025 by finalbossblues. Terrain (A1, A2) tiles added January 2026.
**License**: Free update to Elements Hometown owners (finalbossblues)
**Tile size**: 16x16

**Root-level flat sheets (use directly in Godot):**

| File | Season | Contents |
|------|--------|----------|
| `tileA1_spring.png` | Spring | Animated water/terrain borders, spring palette |
| `tileA1_fall.png` | Fall | Animated water/terrain borders, autumn palette |
| `tileA1_winter.png` | Winter | Animated water/terrain borders, winter palette |
| `tileA2_spring.png` | Spring | Ground terrain, spring coloring |
| `tileA2_fall.png` | Fall | Ground terrain, autumn coloring |
| `tileA2_winter.png` | Winter | Ground terrain, winter/snow coloring |
| `tileA5_outside_spring.png` | Spring | Outdoor flat terrain overlay, spring |
| `tileA5_outside_fall.png` | Fall | Outdoor flat terrain overlay, autumn |
| `tileA5_outside_winter.png` | Winter | Outdoor flat terrain overlay, winter |
| `tileB_outside_spring.png` | Spring | Outdoor objects (spring trees, spring flora) |
| `tileB_outside_fall.png` | Fall | Outdoor objects (autumn foliage, bare branches) |
| `tileB_outside_winter.png` | Winter | Outdoor objects (snow-covered trees, icicles) |

**Formats**: 1x (root-level flat sheets), 2x_VX, 3x_MVMZ

**Usage**: These are direct slot-for-slot replacements for the corresponding Elements Hometown sheets. Swap between seasons at runtime or per-scene by using the matching slot (A1/A2/A5/B outside). No summer variant is included here -- use the Elements Hometown sheets for summer.

---

### 31. Asset Pack 2 UI Supplemental

**Path**: `Asset Pack 2 UI Supplemental/`
**Contents**: Spooky NES Style Horror Game Asset Pack #2 -- UI supplemental elements. Not Time Fantasy. NES-style pixel art for horror-themed game menus. Designed to complement Asset Pack #1 by Programancer.
**License**: $1 Non-Commercial / $10 Commercial (Programancer, 2019)
**Author**: Programancer (@Programancer on Twitter)
**Tile size**: 16x16 (icons)

**Files:**

| File | Contents |
|------|----------|
| `AssetPack2-UI.png` | Single spritesheet containing all UI elements |

**Spritesheet contents (per README):**
- Spooky pixel font (lowercase and uppercase)
- 7 menu frames / window borders
- Pointers and cursors
- 62 16x16 menu icons
- Miscellaneous menu elements
- Example usage screenshot

**Note**: This is NOT a Time Fantasy pack. It is NES-style horror-themed UI art by a different author. Useful for horror/spooky menu overlays. Requires Asset Pack #1 (not included) for full context.

---

### 32. NES SFX Pack

**Path**: `NES SFX Pack/`
**Contents**: 42 NES-style sound effects in WAV format. Made in Famitracker for authentic chiptune authenticity. Covers menu navigation, combat, explosions, environment, and misc. Not Time Fantasy -- different author.
**License**: $1 Non-Commercial / $10 Commercial (Programancer, 2020)
**Author**: Programancer (@Programancer on Twitter)
**Format**: WAV (all files)

**Sound Effect Categories:**

| Category | Files |
|----------|-------|
| Menu navigation | `MenuOpen.wav`, `MenuOpen2.wav`, `MenuClose.wav`, `MenuClose2.wav`, `MenuUp.wav`, `MenuDown.wav`, `MenuConfirm.wav`, `Switch.wav` |
| Combat -- physical | `Slash.wav`, `Throw.wav`, `Toss.wav`, `Hit.wav`, `Hit2.wav` -- `Hit7.wav` |
| Combat -- damage | `Ouch1.wav` -- `Ouch5.wav` |
| Combat -- magic/ranged | `Zap.wav`, `LongZap.wav`, `Burn.wav`, `Fwoosh.wav`, `Charge.wav`, `FireMusket.wav` |
| Explosions | `SmallExplosion.wav`, `Explosion2.wav`, `LongExplosion.wav`, `ExplosionLoop.wav` |
| Environment | `Splash.wav`, `WaterSplash.wav`, `DoorOpen.wav`, `DoorSlam.wav` |
| Pickup / loot | `Pickup.wav`, `Pickup2.wav` |
| Enemy | `MonsterShriek.wav` |
| Misc | `Poot.wav` |

**Total**: 42 WAV files

**Note**: This is NOT a Time Fantasy pack. Chiptune/NES aesthetic may not match the broader game audio style. Best used for retro battle SFX or secondary UI sounds.

---

### 33. TimeFantasyAnimals2

**Path**: `TimeFantasyAnimals2/`
**Contents**: Time Fantasy Animals 2 -- 60+ exotic and aquatic animal walk sprites. Expansion pack for the existing `tf_animals/` pack. Compatible with all Time Fantasy graphics. Focuses on safari, jungle, and sea animals not in the original animals pack.
**License**: Commercial (finalbossblues / timefantasy.net)
**Tile size**: 16x16 base (walk sprites, same format as tf_animals)
**Formats**: 1x (16px), 2x - RMVX, 3x - RMMVMZ

**Individual animal sprites (in `1x/`):**

Each file is a single animal in standard Time Fantasy walk sprite format (3 frames x 4 directions = 12 frames). File naming: `$` prefix = single-character file (for RPGMaker); `_8sheet` = multi-character sheet.

| File | Animal |
|------|--------|
| `elephant.png`, `elephant_baby.png` | Elephant + baby |
| `lion.png`, `lioness.png`, `lion_cub.png` | Lion family |
| `tiger.png`, `tiger_cub.png` | Tiger + cub |
| `panther.png`, `panther_cub.png` | Panther + cub |
| `gorilla.png` | Gorilla |
| `hippo.png`, `hippo_water.png` | Hippo (land + water) |
| `rhinoceros.png` | Rhinoceros |
| `zebra.png` | Zebra |
| `bison.png`, `buffalo.png` | Bison and buffalo |
| `mammoth.png` | Woolly mammoth |
| `sabretooth.png` | Sabre-tooth cat |
| `camel_a.png`, `camel_a_pack.png`, `camel_b.png`, `camel_b_pack.png` | Camel variants (with/without pack) |
| `kangaroo.png` | Kangaroo |
| `crocodile.png`, `crocodile_water.png` | Crocodile (land + water) |
| `lizard.png` | Lizard |
| `turtle.png`, `seaturtle.png` | Land turtle + sea turtle |
| `frog.png` | Frog |
| `walrus.png` | Walrus |
| `seal.png` | Seal |
| `penguin.png`, `penguin_baby.png` | Penguin + baby |
| `crab.png`, `horseshoe_crab.png` | Crab variants |
| `shark_full_blue_1.png`, `shark_full_brown_1.png` | Full shark (2 colors) |
| `shark_fin_blue_1.png`, `shark_fin_brown_1.png` | Shark fin only (2 colors) |
| `shark_finshadow_blue_1.png`, `shark_finshadow_brown_1.png` | Shark fin with shadow |
| `swordfish.png` | Swordfish |
| `ray.png` | Stingray |
| `pufferfish_big.png`, `pufferfish_small.png` | Pufferfish (2 sizes) |
| `monkey_8sheet.png` | Monkey (8-character sheet) |
| `birds_8sheet.png` | Birds (8-character sheet) |
| `bugs_8sheet.png` | Bugs (8-character sheet) |
| `fish_8sheet.png` | Fish (8-character sheet) |
| `bee.png` | Bee |
| `owl_fly.png`, `owl_sit.png` | Owl (flying + sitting) |
| `parrot_fly.png`, `parrot_sit.png` | Parrot (flying + sitting) |
| `toucan_fly.png`, `toucan_sit.png` | Toucan (flying + sitting) |
| `vulture_fly.png`, `vulture_sit.png` | Vulture (flying + sitting) |

**Layout**: Same as tf_animals -- single animal per file (3 cols x 4 rows = 12 frames). Multi-character sheets (`_8sheet`) use 8 animals per sheet (12 cols x 8 rows).

**Companion pack**: `tf_animals/` (original animals pack -- dogs, cats, horses, domestic animals)

---

## Tileset Atlas Position Guide (for Godot TileMapLayer)

This section maps specific tile positions within each sheet to what they visually represent. Use this when building tilemaps programmatically (e.g., with MapBuilder character legends).

Tiles are referenced as `Vector2i(column, row)` where (0,0) is the top-left tile.

### A5 Sheet Grid Layout

All A5 sheets are 128x256 px at 1x, making an **8 column x 16 row** grid of 16x16 tiles.

```
     Col 0   Col 1   Col 2   Col 3   Col 4   Col 5   Col 6   Col 7
Row 0  [0,0]   [1,0]   [2,0]   [3,0]   [4,0]   [5,0]   [6,0]   [7,0]
Row 1  [0,1]   [1,1]   [2,1]   [3,1]   [4,1]   [5,1]   [6,1]   [7,1]
...
Row 15 [0,15]  [1,15]  [2,15]  [3,15]  [4,15]  [5,15]  [6,15]  [7,15]
```

### B Sheet Grid Layout

All B sheets are 256x256 px at 1x, making a **16 column x 16 row** grid of 16x16 tiles.

```
     Col 0 ... Col 7   Col 8 ... Col 15
Row 0  [0,0]     [7,0]   [8,0]     [15,0]
...
Row 15 [0,15]    [7,15]  [8,15]    [15,15]
```

B sheets contain **multi-tile objects** — a single tree or building may span 2-6+ tiles. When placing multi-tile objects, you must place ALL constituent tiles in the correct relative positions.

### Fairy Forest A5_A (`tf_ff_tileA5_a.png`)

| Rows | Tile Positions | Visual Content | Collision? |
|------|---------------|----------------|------------|
| 0-1 | (0,0)-(7,1) | Grass / green ground — 16 variants | No |
| 2-3 | (0,2)-(7,3) | Dirt / brown earth — 16 variants | No |
| 4-5 | (0,4)-(7,5) | Light stone path / cobblestone — 16 variants | No |
| 6-7 | (0,6)-(7,7) | Dark roots / forest floor — 16 variants | No |
| 8-9 | (0,8)-(7,9) | Dense hedges / thick vegetation — 16 variants | **Yes** (solid) |
| 10-11 | (0,10)-(7,11) | Gray stone / cobblestone — 16 variants | No |
| 12-13 | (0,12)-(7,13) | Water / shallow pool tiles — 16 variants | Optional |
| 14-15 | (0,14)-(7,15) | Flower accents / foliage details — 16 variants | No |

### Fairy Forest A5_B (`tf_ff_tileA5_b.png`)

| Rows | Tile Positions | Visual Content | Collision? |
|------|---------------|----------------|------------|
| 0-1 | (0,0)-(7,1) | Alt grass / meadow ground — 16 variants | No |
| 2-3 | (0,2)-(7,3) | Alt dirt / sandy earth — 16 variants | No |
| 4-5 | (0,4)-(7,5) | Alt stone / worn path — 16 variants | No |
| 6-7 | (0,6)-(7,7) | Mushroom / special terrain — 16 variants | No |
| 8-9 | (0,8)-(7,9) | Vine/moss surfaces — 16 variants | **Yes** (solid variants) |
| 10-11 | (0,10)-(7,11) | Dark cave stone — 16 variants | No |
| 12-13 | (0,12)-(7,13) | Glowing / magical ground — 16 variants | No |
| 14-15 | (0,14)-(7,15) | Decorative accents — 16 variants | No |

### Ruins A5 (`tf_A5_ruins2.png`)

| Rows | Tile Positions | Visual Content | Collision? |
|------|---------------|----------------|------------|
| 0-1 | (0,0)-(7,1) | Stone floor — 16 variants | No |
| 2-3 | (0,2)-(7,3) | Decorated / ornate floor — 16 variants | No |
| 4-5 | (0,4)-(7,5) | Gold / ornate walls — 16 variants | **Yes** (solid) |
| 6-7 | (0,6)-(7,7) | Cracked / damaged floor — 16 variants | No |
| 8-9 | (0,8)-(7,9) | Dark stone walls — 16 variants | **Yes** (solid) |
| 10-11 | (0,10)-(7,11) | Mossy stone — 16 variants | No |
| 12-13 | (0,12)-(7,13) | Flooded / water areas — 16 variants | Optional |
| 14-15 | (0,14)-(7,15) | Special floor variants — 16 variants | No |

### Forest Objects B (`tf_ff_tileB_forest.png`)

| Rows | Visual Content | Notes |
|------|---------------|-------|
| 0-3 | Tree canopy tops, leaf clusters | Multi-tile: 2x2 canopy pieces. Place in AbovePlayer layer |
| 4-7 | Tree trunks, fallen logs, stumps, roots | Multi-tile: tree trunks are 1-2 wide. **Collision on trunk tiles** |
| 8-11 | Bushes, flowers, mushrooms, small plants | Most are 1x1 or 2x1 tiles. Some need collision |
| 12-15 | Rocks, boulders, path edges, ground decor | Rocks: 1x1 to 2x2. **Collision on large rocks** |

### Tree Objects B (`tf_ff_tileB_trees.png`)

| Rows | Visual Content | Notes |
|------|---------------|-------|
| 0-5 | Large trees (canopy + trunk) | Multi-tile: 3-4 wide x 4-5 tall. Top 2-3 rows → AbovePlayer, bottom → Objects w/ collision |
| 6-9 | Medium trees | Multi-tile: 2 wide x 3 tall |
| 10-13 | Small trees, saplings | 1-2 wide x 2-3 tall |
| 14-15 | Leaf piles, branches, bark pieces | 1x1 decorative tiles |

### Stone Objects B (`tf_ff_tileB_stone.png`)

| Rows | Visual Content | Notes |
|------|---------------|-------|
| 0-3 | Stone archways, pillars, columns | Multi-tile: 2-3 wide x 3-4 tall. Top → AbovePlayer, base → collision |
| 4-7 | Ruined walls, broken columns | 2-4 wide. **All collision** |
| 8-11 | Standing stones, gravestones, markers | 1-2 wide x 2-3 tall. **Collision** |
| 12-15 | Small rocks, pebbles, debris | 1x1 decorative, no collision |

### Mushroom Village B (`tf_ff_tileB_mushroomvillage.png`)

| Rows | Visual Content | Notes |
|------|---------------|-------|
| 0-5 | Mushroom houses (red cap, blue cap) | Multi-tile: 3-4 wide x 4-5 tall. Roof → AbovePlayer, walls → collision |
| 6-9 | Small mushroom structures, benches | 2-3 wide x 2-3 tall |
| 10-13 | Lanterns, fences, signs, market stalls | 1-2 wide. Fences and stalls → collision |
| 14-15 | Mushroom ground decor, paths | 1x1 decorative |

### Ruins Objects B (`tf_B_ruins2.png`)

| Rows | Visual Content | Notes |
|------|---------------|-------|
| 0-3 | Ornate pillars, archways, statues | Multi-tile: 2-4 wide x 3-4 tall. **Collision** |
| 4-7 | Broken walls, rubble piles | 2-3 wide. **Collision** |
| 8-11 | Vases, urns, altar pieces, chests | 1-2 wide x 1-2 tall |
| 12-15 | Floor debris, cracks, scattered items | 1x1 decorative |

### Giant Tree Objects B (`tf_B_gianttree_ext.png`)

| Rows | Visual Content | Notes |
|------|---------------|-------|
| 0-7 | Giant tree trunk, roots, bark | Multi-tile: up to 8 wide x 8 tall. **Collision** on trunk |
| 8-11 | Giant tree branches, canopy | Place in AbovePlayer layer |
| 12-15 | Forest floor details, fallen leaves | 1x1 decorative |

### Using Multiple Atlas Sources in MapBuilder

When creating a TileSet with both A5 terrain AND B object sheets:

```gdscript
var atlas_paths: Array[String] = [
    MapBuilder.FAIRY_FOREST_A5_A,   # Source ID 0
    MapBuilder.FOREST_OBJECTS,       # Source ID 1
    MapBuilder.TREE_OBJECTS,         # Source ID 2
]
```

Then reference tiles by source ID:
```gdscript
# Ground layer uses source 0 (A5 terrain)
MapBuilder.build_layer(_ground, GROUND_MAP, GROUND_LEGEND, 0)

# Objects layer uses source 1 (B forest objects)
MapBuilder.build_layer(_objects, OBJECT_MAP, OBJECT_LEGEND, 1)

# Tree layer uses source 2 (B tree objects)
MapBuilder.build_layer(_trees, TREE_MAP, TREE_LEGEND, 2)
```

---

## Tile Sheet Types

| Type | Dimensions (1x) | Grid | Contents |
|------|-----------------|------|----------|
| **A5** | 128x256 px | 8 cols x 16 rows | Flat terrain tiles (grass, dirt, stone, paths, accents) |
| **B** | 256x256 px | 16 cols x 16 rows | Object tiles (trees, rocks, buildings, decorations) |
| **C/D/E** | 256x256 px | 16 cols x 16 rows | Additional object layers |

All tile sheets are flat grids of 16x16 tiles at 1x scale. Import directly as TileSet atlas sources in Godot.

---

## Sprite Sheet Layout Reference

### Standard Walk Sprite (single character)
```
Frame:  1    2    3
Down:  [D1] [D2] [D3]
Left:  [L1] [L2] [L3]
Right: [R1] [R2] [R3]
Up:    [U1] [U2] [U3]
```
- 3 columns x 4 rows = 12 frames
- Frame 2 is the idle/standing frame
- At 1x: each frame is approximately 26x36 pixels (within a 26x36 cell)
- File size for single char at 1x: 78x144 px

### Standard Walk Sprite (8 characters per sheet)
```
[Char1][Char2][Char3][Char4]
[Char5][Char6][Char7][Char8]
```
- 12 columns x 8 rows = 8 characters, each with 3 frames x 4 directions
- At 1x: 312x288 px total for 8 characters

### Side-View Battler
```
Columns: 9 frames (3 per state)
Rows: 6 states (idle, step, attack, guard, cast, damage)
+ Row 7: KO/collapse
```
- At MV scale: 1296x864 px per character

---

## File Naming Conventions

- `_1` / `_100` / no suffix = 1x base size (16x16 tile grid)
- `!` prefix = Tile-aligned animated sprite
- `$` prefix = Single oversized character
- `sv_` prefix = Side-view battle sprite
- `_emote` suffix = Emotion/expression animation variant
- `_atk` suffix = Attack animation variant
- `_fly` suffix = Flying pose variant
- `_walk` suffix = Walking animation variant
- `_shadow` / `_shadowless` suffix = With/without ground shadow

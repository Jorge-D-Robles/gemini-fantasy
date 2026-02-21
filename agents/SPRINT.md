# Current Sprint

Sprint: S04-m0-close-m1-begin
Milestone: M0 close / M1 begin
Goal: Close M0 with campfire placement and hygiene sweep; begin M1 with Echo system, Chapter 5 dungeon, and Prismfall Approach scene
Started: 2026-02-20

---

## Active

*(none)*

---

## Queue

### Other

- **T-0250**: Fix EnemyBattler.choose_action() typed array mismatch (battle crash)

*(pull next tasks from BACKLOG.md — T-0246, T-0249, T-0105, T-0104, T-0223)*

---

## Done This Sprint

- T-0262: Revert root y_sort — remove y_sort_enabled from all 5 scene roots + z=0 TileMapLayers, keep only on Entities; update regression tests + scenes/CLAUDE.md
- T-0261: Update CLAUDE.md + scenes/CLAUDE.md + entities/CLAUDE.md rendering conventions — corrected y_sort guidance, documented sprite offset
- T-0260: Lower scatter noise frequencies — detail 0.15→0.04, debris 0.2→0.05 in overgrown_ruins.gd + overgrown_capital.gd
- T-0259: Enable per-tile Y-sort on all 5 scene roots + z=0 TileMapLayers, 4 new regression tests
- T-0258: Fix player sprite Y-sort origin — AnimatedSprite2D offset=(0,-8), regression test
- T-0257: Final A5 purge — removed all 15 deprecated A5 constants from map_builder.gd, regression test added
- T-0256: Redo Overgrown Capital tilemap — TF_DUNGEON flat tiles + RUINS_OBJECTS B-sheet scatter, position-hashed floor/walls, 14 tests 153 assertions
- T-0255: Redo Prismfall Approach tilemap — TF_TERRAIN 3-biome steppe ground (gray stone/amber earth/dark earth) + sandy path hash, 16 tests
- T-0254: Redo Overgrown Ruins tilemap — TF_DUNGEON flat tiles + RUINS_OBJECTS B-sheet scatter, position-hashed floor/walls, 14 tests 91 assertions
- T-0253: Redo Roothollow tilemap — TF_TERRAIN biome+hash ground, path variants, STONE_OBJECTS flowers, 10 tests
- T-0252: Enhance tilemap review workflow — JRPG reference search, A5 instant-fail check, dual reviewer gate in build-tilemap skill
- T-0251: Hard-ban A5 sheets — AGENT_RULES HARD BANS section + map_builder.gd deprecation comments
- T-0249: Chapter 7 "A Village Burns" story event scaffold
- T-0223: Seed AbilityData .tres for Nyx (4) and Lyra (fragment_vision)
- T-0105: Build Prismfall Approach area (Crystalline Steppes overworld scene)
- T-0104: Chapters 8-10 story event scaffolds (crystal_city_arrival, lyras_truth, captured)
- T-MBTM: MapBuilder overhaul + asset pack documentation — clear_layer(), build_procedural_wilds() (biome-constrained foliage), build_from_blueprint(), scatter_decorations() allowed_cells mask; 8 new packs documented in CLAUDE.md; 6 tests

See `agents/COMPLETED.md` for the archive.

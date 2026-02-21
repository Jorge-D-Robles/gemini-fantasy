# Current Sprint

Sprint: S04-m0-close-m1-begin
Milestone: M0 close / M1 begin
Goal: Close M0 with campfire placement and hygiene sweep; begin M1 with Echo system, Chapter 5 dungeon, and Prismfall Approach scene
Started: 2026-02-20

---

## Active

*(no tasks in progress)*

---

## Queue

### Tilemap Overhaul — Top Priority Block

- **T-0251**: Hard-ban A5 sheets — update AGENT_RULES + map_builder.gd deprecation warnings
- **T-0252**: Enhance tilemap review workflow — web search comparison + A5 blocking check + mandate dual review gate in build-tilemap skill
- **T-0253**: Redo Roothollow tilemap — TF_TERRAIN biome system, full dual-reviewer sign-off
- **T-0254**: Redo Overgrown Ruins tilemap — TF_DUNGEON + B-sheets, no A5
- **T-0255**: Redo Prismfall Approach tilemap — complete TF_TERRAIN migration (GROUND_ENTRIES still uses A5 coords)
- **T-0256**: Redo Overgrown Capital tilemap — TF_DUNGEON + B-sheets, no A5
- **T-0257**: Final purge — remove all A5 constants from map_builder.gd after all scenes migrated

### Other

- **T-0250**: Fix EnemyBattler.choose_action() typed array mismatch (battle crash)

*(pull next tasks from BACKLOG.md — T-0246, T-0249, T-0105, T-0104, T-0223)*

---

## Done This Sprint

- T-0249: Chapter 7 "A Village Burns" story event scaffold
- T-0223: Seed AbilityData .tres for Nyx (4) and Lyra (fragment_vision)
- T-0105: Build Prismfall Approach area (Crystalline Steppes overworld scene)
- T-0104: Chapters 8-10 story event scaffolds (crystal_city_arrival, lyras_truth, captured)
- T-MBTM: MapBuilder overhaul + asset pack documentation — clear_layer(), build_procedural_wilds() (biome-constrained foliage), build_from_blueprint(), scatter_decorations() allowed_cells mask; 8 new packs documented in CLAUDE.md; 6 tests

See `agents/COMPLETED.md` for the archive.

# Completed Tasks

Append-only archive. Each entry: `[date] T-XXXX: Title (agent)` or historical `[date] Description`.

---
- [2026-02-20] T-MBTM: MapBuilder overhaul — clear_layer(), build_procedural_wilds() (biome-constrained foliage, eliminates carpet-bombing), build_from_blueprint(), scatter_decorations() allowed_cells mask; lower noise freq 0.10→0.05 in all scenes; 8 new asset packs documented; 6 tests (claude)
- [2026-02-20] T-0225: Nyx introduction cutscene — NyxIntroduction event, 24-line dialogue, gate flags garrick_recruited + lyra_fragment_2_collected; 14 tests (1785 total); PR #272 (claude)
- [2026-02-20] T-BGM-01: AudioManager BGM pause fix + full OST library wiring — PROCESS_MODE_ALWAYS; defeat/level-up/echo BGMs; character themes via push/pop; 49 tracks OGG-converted; 12 tests (1800 total); PR #273 (claude)
- [2026-02-20] T-0233/T-0234/T-0235/T-0236: Code health sprint — fix gdlint violations, remove 4 dead Battler wrapper methods, eliminate ScenePaths const duplication, centralize resonance Color literals into UITheme; all tests pass (claude)
- [2026-02-20] T-0228/T-0229/T-0230/T-0231/T-0232: Test suite cleanup sprint — removed ~150 low-value tests; slimmed 12 event files; deleted 5 low-value test files; all 1800 tests passing (claude)
- [2026-02-20] T-0237/T-0238/T-0240/T-0241/T-0242: Code health sprint round 2 — AudioManager _do_crossfade() helper; enemy_turn_state helpers; equipment SLOT_KEYS; quest_manager helpers; pause_menu helpers; all tests pass (claude)
- [2026-02-20] T-0245/T-0239/T-0243/T-0244: Code health sprint round 3 — BattleActionExecutor static class; _connect_battler_signals() helper; _create_popup_label() helper; EventFlagRegistry with 17 flag constants; 18 new tests (claude)
- [2026-02-20] T-0248: Nyx recruitment — nyx.tres CharacterData (magic=22, luck=18, STAFF+CRYSTAL), NYX_CHARACTER_PATH constant, PartyManager.add_character() in trigger(); 9 tests; PR #278 (claude)
T-0249 | 2026-02-20 | Chapter 7 "A Village Burns" story event scaffold | VillageBurns.gd Scenes 1-2, 7 tests
T-0223 | 2026-02-20 | Seed AbilityData .tres files for Nyx and Lyra (4-ability stubs each) | 5 new abilities + nyx.tres/lyra.tres wired, 6 tests
T-0105 | 2026-02-20 | Build Prismfall Approach area (Crystalline Steppes) | _map.gd + _encounters.gd + .gd + .tscn + ScenePaths constant, 13 tests, 830 total passing
T-0252 | 2026-02-21 | Enhance tilemap review workflow | Adversarial reviewer: JRPG reference search step + A5 instant-fail check + rule #8; build-tilemap skill: mandatory dual reviewer gate step (claude)
T-0253 | 2026-02-21 | Redo Roothollow tilemap | TF_TERRAIN biome+hash ground, 4-variant path tiles, STONE_OBJECTS flowers/pebbles, organic canopy, 10 tests 80 assertions (claude)
T-0255 | 2026-02-21 | Redo Prismfall Approach tilemap | TF_TERRAIN 3-biome steppe (gray stone row 8 + amber earth row 6 + dark earth row 11) + sandy path hash row 9, 16 tests (claude)
T-0254 | 2026-02-21 | Redo Overgrown Ruins tilemap | TF_DUNGEON flat tiles (brown earth floor + blue-gray walls) + RUINS_OBJECTS B-sheet scatter, position-hashed variants, 14 tests 91 assertions (claude)
T-0251 | 2026-02-21 | Hard-ban A5 sheets | AGENT_RULES HARD BANS section + deprecation comments on all 15 A5 constants in map_builder.gd (claude)
T-0104 | 2026-02-20 | Chapters 6-10 story event scaffolds | crystal_city_arrival.gd (Ch8) + lyras_truth.gd (Ch9) + captured.gd (Ch10) + 5 EventFlagRegistry constants, 24 tests, 754 passing

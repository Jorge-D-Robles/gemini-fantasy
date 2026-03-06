# Backlog

All tickets not in the current sprint. Sorted by milestone, then priority.
Completed and superseded tickets are in `agents/COMPLETED.md`.

---

## M1 — Act I: The Echo Thief

### T-0180
- Title: Test suite de-bloat — remove redundant tests that don't test behaviors or contracts
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Tags: tests, code-health
- Depends: —
- Blocked-by: —
- Refs: game/tests/
- Notes: Audit entire test suite. Remove tests that verify trivial properties (non-empty strings, array lengths, type checks on constants) rather than actual behaviors/contracts. Keep tests that verify: computation logic, state transitions, edge cases, integration contracts, regressions. Delete tests that merely assert obvious truths about static data. Target: meaningful coverage of real behaviors, not inflated test counts. Previous cleanup (T-0228 thru T-0232) removed ~150 low-value tests — this pass should finish the job.


### T-0107
- Title: Implement full character ability trees for all party members
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0018
- Refs: docs/mechanics/character-abilities.md
- Completed: 2026-02-22

### T-0226
- Title: Overgrown Capital playtest pass — end-to-end Chapter 5 flow verification
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Depends: T-0211, T-0224
- Refs: game/tools/playtest_presets/, docs/story/act1/05-into-the-capital.md
- Notes: Full Chapter 5 flow: enter from Verdant Forest, collect Market echoes, activate Market Purification Node, navigate Entertainment District, activate Entertainment Purification Node, collect Lyra Fragment 2, trigger Last Gardener, trigger Leaving Capital, exit to Verdant Forest. Create/update overgrown_capital playtest preset JSON. Verify save/load round-trip persists echo IDs and cleared purification flags. Log discovered bugs as new BACKLOG entries.


### T-0214
- Title: Add Research Quarter Resonance terminal puzzle — unlock Palace District path
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M1
- Depends: T-0195, T-0191
- Completed: 2026-02-22


### T-0207
- Title: Add Government Center sub-area to Overgrown Capital — political debate echoes and hidden bunker
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md (Government Center), docs/lore/04-echo-catalog.md
- Notes: Capitol building area. Create 1-2 Story Echo .tres about political dissent re: Resonance regulation. Hidden bunker secret area with rare echo. 3+ tests.

### T-0213
- Title: Add Merchant's Regret optional mini-boss to Overgrown Capital Market District
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md, game/data/enemies/
- Notes: Create game/data/enemies/merchants_regret.tres (EnemyData: BOSS AI, ~200 HP, coin_shower AoE + desperate_bargain debuff). Trigger zone in Market stall cluster. Pre-battle 2-line dialogue. Flag: merchants_regret_encountered. compute_merchants_regret_can_trigger(flags) static helper. 3+ tests.

### T-0215
- Title: Add hidden VIP lounge in Entertainment District — legendary echo collectible
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/04-echo-catalog.md
- Notes: Secret area accessible via hidden stage entrance in theater area. Create game/data/echoes/final_performance.tres (EchoData: LEGENDARY rarity, STORY echo_type, 3-line lore about a performer's last show before The Severance). MemorialEchoStrategy. Flag: vip_lounge_found. compute_vip_lounge_eligible(flags) helper. 3+ tests.

### T-0216
- Title: Add rooftop garden secret area to Residential Quarter — rare echo collectible
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md, docs/lore/04-echo-catalog.md
- Notes: Secret rooftop area accessible via collapsed building rubble path. Create game/data/echoes/rooftop_garden.tres (EchoData: RARE rarity, STORY echo_type, family tending a garden above the city). MemorialEchoStrategy with 2-3 line vision. Flag: rooftop_garden_found. 3+ tests.

### T-0217
- Title: Add hidden archives secret room in Government Center — Historical Records lore
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/05-dungeon-designs.md, game/entities/interactable/
- Notes: Secret room in Government Center accessible via collapsed wall. Plain dialogue Interactable (one_time=true) with 3-line lore dump about pre-Severance political history. Flag: hidden_archives_found. compute_archives_lore_text() static helper. 2+ tests.

### T-0024
- Title: Implement fast travel system
- Status: done
- Assigned: claude
- Priority: low
- Milestone: M1
- Depends: none
- Refs: docs/game-design/03-world-map-and-locations.md
- Completed: 2026-02-22

### T-0025
- Title: Build bonding system framework
- Status: done
- Assigned: claude
- Priority: low
- Milestone: M1
- Depends: none
- Refs: docs/game-design/01-core-mechanics.md, docs/lore/03-characters.md
- Notes: BondData Resource. Affinity tracking between characters. Bond events at camp.

### T-0109
- Title: Add weather and time-of-day visual system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: none
- Refs: docs/game-design/06-audio-design.md
- Notes: Day/night cycle, weather effects. CanvasModulate for lighting, GPUParticles2D for weather.

### T-0110
- Title: Implement crafting system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: —
- Refs: docs/game-design/01-core-mechanics.md
- Notes: Combine materials into items. Recipe system, crafting UI, material gathering.

### T-0265
- Title: Remove unused signals from EventBus and PartyManager
- Status: in-progress
- Assigned: claude
- Priority: high
- Milestone: M1
- Tags: code-health, cleanup
- Depends: —
- Blocked-by: —
- Refs: game/autoloads/event_bus.gd:9,12, game/autoloads/party_manager.gd:6-7, game/autoloads/dialogue_manager.gd:8
- Notes: Remove 5 signals that are emitted but never connected to by production code: EventBus.player_interacted (line 9), EventBus.npc_talked_to (line 12), PartyManager.character_added (line 6), PartyManager.character_removed (line 7), DialogueManager.line_finished (line 8). Also remove corresponding emit helper functions (emit_player_interacted, emit_npc_talked_to). Update any tests that reference these signals. Run /run-tests to verify nothing breaks.

### T-0266
- Title: Remove dead functions — get_failed_quests() and compute_echo_count()
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: code-health, cleanup
- Depends: —
- Blocked-by: —
- Refs: game/autoloads/quest_manager.gd:135, game/autoloads/echo_manager.gd:59
- Notes: Remove QuestManager.get_failed_quests() (line 135, never called in production — only tests). Remove EchoManager.compute_echo_count() (line 59, redundant wrapper around .size()). Delete or update any tests that call these functions. These are dead code with zero production callers.

### T-0267
- Title: Consolidate duplicated dialogue pair-builder into DialogueLine.build_from_pairs()
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: code-health, refactor
- Depends: —
- Blocked-by: —
- Refs: game/resources/dialogue_line.gd, game/entities/interactable/strategies/diary_strategy.gd:24-35, game/entities/interactable/strategies/purification_node_strategy.gd:42-53, game/entities/interactable/strategies/memorial_echo_strategy.gd:87-113, game/entities/interactable/strategies/resonance_terminal_strategy.gd:73-80
- Notes: Four strategy files duplicate the same dialogue-line pair-building pattern (iterate raw_lines by 2, create DialogueLine pairs, warn on odd count). Extract into a single static method DialogueLine.build_from_pairs(raw_lines, source_name) in dialogue_line.gd. Replace all 4 implementations with calls to the new method. Write test for build_from_pairs(). Run /run-tests.

### T-0268
- Title: De-duplicate quest restore functions in QuestManager
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: code-health, refactor
- Depends: —
- Blocked-by: —
- Refs: game/autoloads/quest_manager.gd:203-235
- Notes: Three near-identical functions (_restore_active_quests, _restore_completed_quests, _restore_failed_quests) differ only by state enum. Also has inconsistent String conversion (one uses qid_str directly, another wraps with String()). Consolidate into a single parameterized _restore_quests_by_state(quest_list, state, lookup) function. Fix the String conversion inconsistency. Existing tests should still pass.

### T-0269
- Title: Test suite de-bloat round 2 — remove ~78 trivial/redundant test functions
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Tags: tests, code-health
- Depends: —
- Blocked-by: —
- Refs: game/tests/unit/systems/test_game_balance.gd, game/tests/unit/ui/test_ui_helpers.gd, game/tests/unit/resources/test_iris_garrick_abilities.gd, game/tests/unit/resources/test_nyx_lyra_abilities.gd, game/tests/unit/ui/test_battle_log_colors.gd, game/tests/unit/systems/battle/test_status_icons.gd, game/tests/unit/scenes/test_roothollow_quests.gd, game/tests/unit/ui/test_settings_data.gd, game/tests/unit/ui/test_party_ui_feedback.gd, game/tests/unit/ui/test_defeat_screen.gd, game/tests/unit/ui/test_tutorial_hints.gd, game/tests/unit/ui/test_title_screen.gd
- Notes: ~78 test functions across 12 files that test trivial properties (constant values, enum mappings, string non-emptiness, type checks). Categories: (1) Constant-per-test in test_game_balance (~19 tests) — replace with 1 parameterized test or delete. (2) Property type checks in test_ui_helpers (7 tests, lines 127-159) — delete entirely. (3) One-resource-per-test in test_iris_garrick_abilities (10) and test_nyx_lyra_abilities (5) — consolidate to parameterized tests. (4) Enum-per-test in test_battle_log_colors (7+2) and test_status_icons (5) — consolidate to parameterized. (5) String emptiness tests in test_roothollow_quests (12), test_settings_data (3), test_party_ui_feedback (3), test_defeat_screen (2), test_tutorial_hints (1), test_title_screen (1). Delete all trivial emptiness checks. Target: reduce ~78 tests to ~5-10 parameterized tests. Run /run-tests after.

### T-0270
- Title: Simplify BattleActionExecutor.execute_attack() — extract crit/non-crit branches
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Tags: code-health, refactor, battle
- Depends: —
- Blocked-by: —
- Refs: game/systems/battle/battle_action_executor.gd:14-69
- Notes: 56-line function with crit and non-crit branches that are 90% identical. Extract common damage calculation, then handle crit-specific UI (popup, flash, log message) separately. Target: <30 lines for main function, extracted _handle_attack_result() helper. Run /run-tests.

### T-0271
- Title: Simplify MemorialEchoStrategy.execute() with early returns
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Tags: code-health, refactor
- Depends: —
- Blocked-by: —
- Refs: game/entities/interactable/strategies/memorial_echo_strategy.gd:37-85
- Notes: 49-line function with 3 levels of if-else nesting. Simplify using early returns: check has_been_used first, check compute_should_collect next, then simple happy path. Also benefits from T-0267 (dialogue pair builder extraction). Run /run-tests.

### T-0264
- Title: Implement save/load system with 3 save slots and autosave on scene change
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M1
- Tags: save, core
- Depends: —
- Blocked-by: —
- Refs: docs/best-practices/09-save-load.md
- Notes: 3 manual save slots + autosave slot. Autosave triggers on every scene change. Save data includes party state, inventory, quest flags, current scene. Title screen shows Continue/New Game/Load. Critical for playtesting.

---

## M2 — Act II: The Weight of Echoes

*(Tickets will be created during M2 sprint planning.)*

---

## M3 — Act III: Convergence

*(Tickets will be created during M3 sprint planning.)*

---

## M4 — Optional Content & Polish

*(Tickets will be created during M4 sprint planning.)*

---

## M5 — Release Readiness

*(Tickets will be created during M5 sprint planning.)*

---

## Unscheduled

*(Tickets with no milestone assigned yet. Move to a milestone section when scheduled.)*

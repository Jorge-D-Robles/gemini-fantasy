# Backlog

All tickets not in the current sprint. Sorted by milestone, then priority.

---

## M0 — Foundation

### T-0175
- Title: Add fade-in on BGM stack pop/restore to prevent audio snap
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0117, T-0128
- Refs: game/autoloads/audio_manager.gd
- Notes: pop_bgm() resumes overworld track at saved position but volume snaps immediately to _bgm_volume_db. Should fade from 0.0 to _bgm_volume_db over 0.5s (half normal crossfade). compute_bgm_restore_fade_duration() static helper. 2+ tests.

### T-0174
- Title: Add Iris personal quest stub to quest log after recruitment
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0081, T-0090
- Refs: docs/story/character-quests/iris-engineers-oath.md, game/data/quests/
- Notes: After iris_recruited, create QuestData .tres "The Engineer's Oath: Pending" with one objective: "Understand why Iris left the Initiative." Single-stage narrative breadcrumb. QuestManager auto-accepts on iris_recruited flag. compute_should_auto_accept_iris_quest(flags) static helper. 3+ tests.

### T-0173
- Title: Add Garrick personal quest stub to quest log after recruitment
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0082, T-0090
- Refs: docs/story/character-quests/garrick-three-burns.md, game/data/quests/
- Notes: After garrick_recruited, create QuestData .tres "Something He Carries" with one objective: "Travel with Garrick and learn his story." Single-stage narrative breadcrumb. QuestManager auto-accepts on garrick_recruited flag in GarrickRecruitment.trigger(). compute_should_auto_accept_garrick_quest(flags) static helper. 3+ tests.

### T-0172
- Title: Add party banter trigger scaffold — BanterManager static helper
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0081, T-0082
- Refs: docs/story/camp-scenes/party-banter.md, game/scenes/verdant_forest/verdant_forest.gd
- Notes: Lightweight static class BanterManager (RefCounted, no autoload). compute_eligible_banters(party_ids, flags, location) returns Array of eligible banter keys. Enables T-0169 and future banters without per-scene boilerplate. 5+ tests verifying eligibility conditions.

### T-0171
- Title: Add Overgrown Capital entry scene — 3-person party gate dialogue on entry
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0085
- Refs: docs/story/act1/05-into-the-capital.md (Scene 1), game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Chapter 5 Scene 1 gate dialogue (4-5 lines): Garrick reacts to scale of ruins, Iris reports crystal density and pre-Sev population, Kael quiet. Gated by garrick_recruited AND overgrown_capital_entry_seen flag (one-shot). Trigger on scene entry via call_deferred. Static module pattern from T-0162. 3+ tests.

### T-0170
- Title: Disambiguate innkeeper rest options — priority logic for night events
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0148, T-0135
- Refs: game/scenes/roothollow/roothollow.gd, game/events/camp_three_fires.gd, game/events/garrick_night_scene.gd
- Notes: Innkeeper fires CampThreeFires or GarrickNightScene from same handler. If both flags are unset, GarrickNightScene (garrick_met_lyra gate) takes priority over CampThreeFires (garrick_recruited gate) per story order. compute_innkeeper_night_event(flags) static helper for TDD. 3+ tests.

### T-0169
- Title: Add Iris-Kael overworld banter — BOND-01 "Knife Lessons" post-Chapter-3 scene
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0081
- Refs: docs/story/camp-scenes/party-banter.md (BOND-01), game/scenes/verdant_forest/verdant_forest.gd
- Notes: 5-line campfire banter at Verdant Forest after iris_recruited flag. Iris corrects Kael's knife grip. EventFlags gate: bond_01_knife_lessons. Static compute_bond01_eligible(flags, party) helper. 3+ tests.

### T-0165
- Title: Add keyboard and gamepad focus navigation to party_ui sub-screen
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0020
- Refs: game/ui/party_ui/party_ui.gd, docs/best-practices/08-ui-patterns.md
- Notes: party_ui.gd wires UIHelpers.setup_focus_wrap but inter-column navigation (arrow keys to move between active and reserve panels, confirm to select, cancel to deselect) needs wiring. Match the pattern in inventory_ui.gd and shop_ui.gd. 5+ tests.

### T-0164
- Title: Wire party_changed signal from PartyManager into party_ui refresh
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0020
- Refs: game/ui/party_ui/party_ui.gd, game/autoloads/party_manager.gd
- Notes: party_ui builds its two-column display once at open time. If another system modifies the roster while the sub-screen is open, the display will be stale. Connect PartyManager.party_changed and party_state_changed to _refresh_display in open(), disconnect in close(). 3+ tests.

### T-0163
- Title: Add party swap validation feedback in party UI
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0020
- Refs: game/ui/party_ui/party_ui.gd, game/ui/party_ui/party_ui_data.gd
- Notes: compute_swap_valid() returns false for invalid swaps (edge cases like 0-size lists). Currently the UI silently ignores the action. Add a 0.3s red flash on the active member button and a transient status label. compute_swap_feedback_text() static helper for TDD. 3+ tests.

### T-0166
- Title: BUG — Defend stance clears before enemy can attack (is_defending reset in TurnEnd)
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battler.gd, game/systems/battle/states/turn_end_state.gd, game/systems/battle/states/player_turn_state.gd
- Notes: end_turn() clears is_defending immediately in TurnEnd. Enemy attacks in subsequent EnemyTurn see is_defending=false so damage is not halved. JRPG-correct behavior: is_defending should persist until the player's next turn starts. Fix: clear is_defending in PlayerTurnState.enter() for the active battler, not in end_turn(). Requires removing is_defending=false from Battler.end_turn() and updating test_end_turn_clears_defend. Also update CLAUDE.md docs for battler.end_turn().

### T-0167
- Title: Add playtime accumulation gate — prevent ticking during battle or cutscene
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0130
- Refs: game/autoloads/game_manager.gd
- Notes: T-0130 adds playtime_seconds incremented in _process. Without a gate, playtime accumulates during BATTLE and CUTSCENE states, inflating reported time. Add compute_should_tick_playtime(state) static helper, gate increment to OVERWORLD state only. 2+ tests.

### T-0168
- Title: Verify and fix enemy turn routing through ActionExecuteState for consistent crit behavior
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0143, T-0156
- Refs: game/systems/battle/states/enemy_turn_state.gd, game/systems/battle/states/action_execute_state.gd
- Notes: Supersedes T-0156. Confirm whether EnemyTurnState routes through ActionExecuteState (crits already applied). If not, wire BattlerDamage.roll_crit(attacker.luck) and apply_crit() into the enemy damage path. Also confirm COMBAT_CRITICAL_HIT SFX plays on enemy crits. 3+ tests verifying enemy crit roll uses 5% + luck*0.5% formula.

### T-0162
- Title: Add Verdant Forest traversal dialogue — party comments heading to Overgrown Capital
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0085
- Refs: docs/story/act1/04-old-iron.md (End of Chapter hook), game/scenes/verdant_forest/verdant_forest.gd
- Notes: After garrick_recruited flag is set, the three-person party crosses the Verdant Forest toward Overgrown Ruins. Add a 3-4 line on-entry dialogue gated by garrick_recruited (and forest_traversal_full_party flag to fire once only). Garrick notes crystal density, Iris assesses threat level, Kael orients the group. 3+ tests.

### T-0008
- Title: Replace has_method/has_signal with proper typing in autoloads
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/battle_manager.gd, game/autoloads/dialogue_manager.gd
- Notes: Uses duck-typing instead of specific class types. Low priority — works but not type-safe.

### T-0009
- Title: Implement party healing at rest points in Roothollow
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd
- Notes: Placeholder comment for party healing logic. Partially addressed by innkeeper healing (T-0029).

### T-0010
- Title: Add return type hints to all methods
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/entities/battle/enemy_battler.gd, game/systems/battle/battle_scene.gd, game/autoloads/battle_manager.gd
- Notes: Numerous methods missing explicit -> void or return type hints.

### T-0011
- Title: Add doc comments to signals and public methods
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battle_scene.gd, game/systems/battle/battler.gd
- Notes: Many signals and public methods lack ## doc comments.

### T-0018
- Title: Build skill tree framework
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0019
- Refs: docs/mechanics/character-abilities.md, game/resources/ability_data.gd
- Notes: SkillTreeData Resource. Unlock nodes with skill points on level up. Character-specific trees per design doc.

### T-0023
- Title: Implement camp/rest system
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0009
- Refs: docs/game-design/01-core-mechanics.md
- Notes: Rest at designated points. Full HP/EE restore. Optional bonding scenes. Camp menu UI.

### T-0024
- Title: Implement fast travel system
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: docs/game-design/03-world-map-and-locations.md
- Notes: Unlock fast travel points as discovered. World map selection UI. Transition animations.

### T-0025
- Title: Build bonding system framework
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: docs/game-design/01-core-mechanics.md, docs/lore/03-characters.md
- Notes: BondData Resource. Affinity tracking between characters. Bond events at camp.

### T-0026
- Title: Build debug console
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: docs/IMPLEMENTATION_GUIDE.md
- Notes: Toggle with ~ key. Commands: add_item, set_level, heal_all, teleport, start_battle.

---

## S03 — Demo Polish & Completeness

### Bug Fixes

### T-0049
- Title: BUG — Verdant Forest camera limit cuts off bottom row
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M0
- Depends: none
- Refs: game/scenes/verdant_forest/verdant_forest.tscn
- Notes: GROUND_MAP has 25 rows (400px tall) but Camera2D limit_bottom is 384 (24 rows). Bottom 16px of map is inaccessible. Fix: change limit_bottom to 400 in the .tscn Camera2D node.

### T-0050
- Title: BUG — Overgrown Ruins spawn position check uses Vector2.ZERO comparison
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/overgrown_ruins/overgrown_ruins.gd (lines 226-228)
- Notes: Checks `player_node.global_position == Vector2.ZERO` as spawn condition. Fragile — should always set spawn position or use a "first_entry" flag.

---

### Battle UI & Background

### T-0051
- Title: Add battle background sprite and scene backdrop
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battle_scene.tscn, game/systems/battle/battle_scene.gd
- Notes: BattleBackground Sprite2D node exists but has no texture. Combat occurs against transparent overworld — breaks immersion, makes UI hard to read. Source backgrounds from Time Fantasy packs. Consider multiple backgrounds that change based on encounter area (forest, ruins, town).

### T-0052
- Title: Color-code battle log messages by type
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd
- Notes: Battle log shows plain white text. Color-code: red for damage, green for healing, yellow for status effects, blue for resonance, white for neutral. Use RichTextLabel BBCode. Add subtle fade-in animation.

### T-0053
- Title: Add floating damage numbers above targets
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/action_execute_state.gd
- Notes: Spawn a floating Label on damage: rises and fades out above target. Red for damage, green for healing, gold for criticals. Create reusable DamagePopup scene. Tween position + alpha over 0.8s.

### T-0054
- Title: Add status effect icons/badges on battler panels
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd, game/resources/status_effect_data.gd
- Notes: No visual indicator of active status effects on party/enemy panels. Add small icon badges (poison=green, burn=fire, buff=up arrow) next to battler names. Show remaining duration.

### T-0055
- Title: Improve battle target selector with name label and highlight
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd
- Notes: Current selector is just a yellow ">" arrow. Add enemy name label, subtle highlight on selected sprite, HP bar preview.

### T-0056
- Title: Enhance victory screen with portraits and level-up display
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/victory_state.gd, game/ui/battle_ui/battle_ui.gd
- Notes: Add character portraits, animated XP bar fill, "LEVEL UP!" callout with stat gains, item icons for loot drops, gold coin icon.

### T-0057
- Title: Improve turn order display with current actor highlight
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd
- Notes: Turn order bar shows abbreviated names in small text. Add larger text, active character border/glow, slide animation on order change, ally=blue vs enemy=red.

### T-0058
- Title: Add screen shake on heavy damage
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battle_scene.gd
- Notes: Camera jitter when character takes >25% max HP damage. 3-4 frame shake, 2-3px offset. Reusable shake function on battle Camera2D.

---

### Tilemap Quality

### T-0059
- Title: Roothollow — add AbovePlayer tilemap layer and consolidate tree sprites
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd, game/scenes/roothollow/roothollow.tscn, docs/best-practices/11-tilemaps-and-level-design.md
- Notes: CRITICAL tilemap violation. Missing AbovePlayer TileMapLayer (z_index=2) for forest border canopy. Uses 10+ manual Sprite2D + StaticBody2D trees (expensive, inconsistent). Add AbovePlayer layer with canopy tiles from FOREST_OBJECTS. Remove manual Tree01-Tree10 and collision nodes. Let TreesBorder tilemap handle rendering/collision. Verify with /scene-preview.

### T-0060
- Title: Roothollow — reduce ground detail density from 50% to 15%
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd
- Notes: DETAIL_MAP has ~50% tile coverage. Best practice is 5-15%. Remove 60-70% of f/F/b/B characters. Concentrate remaining accents in town plaza area and scattered clearings. Verify with /scene-preview.

### T-0061
- Title: Overgrown Ruins — separate debris layer and fix z-index ambiguity
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Two MapBuilder.build_layer() calls on same GroundDetail layer. Should separate into distinct Debris layer. Also Walls and Objects both at z_index=0 — set Objects to z_index=1.

### T-0062
- Title: Add boundary collision walls to all map edges
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd, game/scenes/verdant_forest/verdant_forest.gd, game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Player can walk to the very edge of maps. Add invisible StaticBody2D collision walls around all map perimeters (or use tilemap collision on border tiles). Ensure transition zones are properly placed before the boundary. Consider shared helper function for generating boundary walls.

---

### Audio & Music

### T-0063
- Title: Source and import BGM tracks for demo areas
- Status: done
- Assigned: user
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/assets/music/
- Notes: DONE — 12 OGG tracks already imported at game/assets/music/ with .import files generated. Tracks: Battle Theme Organ, Battle! Intro, Castle, Desert Theme, Epic Boss Battle 1st section, Main Character, My Hometown, Peaceful Days, Success!, Town Theme Day, Town Theme Night, Welcoming Heart Piano.
- Completed: 2026-02-18

### T-0064
- Title: Integrate BGM playback into all scenes and battle system
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/scenes/roothollow/roothollow.gd, game/scenes/verdant_forest/verdant_forest.gd, game/scenes/overgrown_ruins/overgrown_ruins.gd, game/autoloads/battle_manager.gd, game/systems/battle/battle_scene.gd, game/systems/battle/states/victory_state.gd
- Notes: 12 BGM tracks exist at res://assets/music/. Wire AudioManager.play_bgm() into all relevant game events. Suggested mapping — Roothollow: "Town Theme Day.ogg" or "My Hometown.ogg". Verdant Forest: "Peaceful Days.ogg". Overgrown Ruins: "Castle.ogg". Standard battles: "Battle Theme Organ.ogg" (use "Battle! Intro.ogg" as optional intro). Boss battles: "Epic Boss Battle 1st section.ogg". Victory: "Success!.ogg". Title screen: "Main Character.ogg" or "Welcoming Heart Piano.ogg". Implementation: load each track in scene _ready() or as preloaded const, call AudioManager.play_bgm(stream). Battle music: play on battle start, restore area BGM on battle end (save reference to current area track before battle). Victory jingle: play "Success!.ogg" in victory_state.gd, then resume area BGM after results screen. All load() calls must null-check. Crossfade between tracks using AudioManager's built-in fade_time parameter.

### T-0065
- Title: Add battle music (standard encounters and boss)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/autoloads/battle_manager.gd
- Notes: MERGED INTO T-0064. This ticket is superseded — battle music integration is now part of the unified BGM integration task T-0064.

### T-0066
- Title: Add UI sound effects (menu, dialogue, buttons)
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/ui/dialogue/dialogue_box.gd
- Notes: SFX for: menu open/close, button hover/select, dialogue advance, choice select. Wire AudioManager.play_sfx() into UI scripts. No SFX assets exist yet — will need to source or create.

### T-0067
- Title: Add combat sound effects (attack, magic, heal, death)
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/systems/battle/states/action_execute_state.gd
- Notes: SFX: physical attack hit, magic cast, healing chime, enemy death, critical hit, status effect apply, resonance overload. Wire into action_execute_state.gd. No SFX assets exist yet — will need to source or create.

### T-0068
- Title: Build settings/options menu with volume sliders
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0064
- Refs: docs/best-practices/08-ui-patterns.md, game/autoloads/audio_manager.gd
- Notes: Options screen from pause menu + title screen. Volume sliders: Master, BGM, SFX. Persist to user://settings.json. Wire to AudioServer bus volumes.

---

### Code Refactoring — Reusable Components

### T-0069
- Title: Extract shared UI helpers (colors, focus nav, panel styles, clear_children)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd, game/ui/inventory_ui/inventory_ui.gd, game/ui/shop_ui/shop_ui.gd, game/ui/pause_menu/pause_menu.gd
- Notes: 4 UI files duplicate: PANEL_BG/PANEL_BORDER color constants, _clear_children(), _setup_focus_wrap(), StyleBoxFlat creation, TEXT_PRIMARY/TEXT_SECONDARY. Create game/ui/ui_helpers.gd with static methods and shared constants. Update all 4 files. Saves 40+ lines of duplication. Add tests.

### T-0070
- Title: Split battler.gd into damage calculator, resonance controller, and status manager
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battler.gd (518 lines)
- Notes: 6 distinct responsibilities. Extract: battler_damage.gd (damage formulas), battler_resonance.gd (resonance state transitions), battler_status.gd (status effect tracking). Keep core HP/EE/stats in battler.gd (~200 lines). Must NOT break existing tests.

### T-0071
- Title: Centralize game balance constants into game_balance.gd
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battler.gd (lines 32-50)
- Notes: 27 magic constants hardcoded: RESONANCE_MAX, DEFENSE_SCALING_DIVISOR, HOLLOW_STAT_PENALTY, etc. Create game/systems/game_balance.gd as single source of truth. Enables easy tuning without hunting through battler.gd.

### T-0072
- Title: Create scene_paths.gd for centralized scene path constants
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd, game/scenes/verdant_forest/verdant_forest.gd, game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Each scene script defines own path constants (VERDANT_FOREST_PATH, ROOTHOLLOW_PATH, etc). Duplicated across 3+ files. Create game/constants/scene_paths.gd. Prevents path typos.

### T-0073
- Title: Split roothollow.gd into tilemap, dialogue, and quest handler modules
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd (985 lines)
- Notes: Largest file. Combines tilemap building, NPC dialogue trees, NPC management, flag-driven dialogue. Extract: roothollow_tilemap.gd, roothollow_dialogue.gd, roothollow_quests.gd. Main becomes orchestrator (~200 lines).

### T-0074
- Title: Split battle_ui.gd into composable panel components
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0069
- Refs: game/ui/battle_ui/battle_ui.gd (570 lines)
- Notes: Extract: battle_command_menu.gd, battle_party_display.gd, battle_target_selector.gd, battle_log_display.gd. Each becomes a scene component.

### T-0075
- Title: Split inventory_ui.gd into category manager, detail panel, and applicator
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0069
- Refs: game/ui/inventory_ui/inventory_ui.gd (658 lines)
- Notes: Extract: inventory_category_filter.gd, inventory_detail_panel.gd, inventory_item_applicator.gd. Main composes these components.

### T-0076
- Title: Split shop_ui.gd into buy panel, sell panel, and character selector
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0069
- Refs: game/ui/shop_ui/shop_ui.gd (522 lines)
- Notes: Extract buy mode into shop_buy_panel.gd, sell mode into shop_sell_panel.gd, character selection into shop_character_selector.gd.

### T-0077
- Title: Split verdant_forest.gd and overgrown_ruins.gd into tilemap/encounter/dialogue modules
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0073
- Refs: game/scenes/verdant_forest/verdant_forest.gd (381 lines), game/scenes/overgrown_ruins/overgrown_ruins.gd (377 lines)
- Notes: Same pattern as roothollow. Lower priority since <400 lines.

### T-0078
- Title: Create reusable asset loader helper with consistent null-check pattern
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/party_manager.gd, game/scenes/roothollow/roothollow.gd
- Notes: load() calls scattered with inconsistent error handling. Create game/systems/asset_loader.gd with static method that always null-checks and logs descriptive errors.

---

### Story & Narrative — Script Alignment

### T-0079
- Title: Expand opening sequence to match Chapter 1 story script
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/events/opening_sequence.gd, docs/story/act1/chapter-01-the-collector.md
- Notes: Current opening is 6 lines. Chapter 1 script has 650+ words. Expand to 20-30 lines: Kael's internal thoughts, familiarity with ruins, Lyra's first voice, his shock. Reference story script for dialogue and emotional beats.

### T-0080
- Title: Expand Lyra discovery dialogue to match story script (~50 lines)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: T-0079
- Refs: game/events/opening_sequence.gd, docs/story/act1/chapter-02-a-voice-in-the-crystal.md
- Notes: Lyra's introduction is minimal. Chapter 2 has extensive dialogue: confusion about consciousness, fragmented memories, Kael's conflicted response. Expand post-discovery sequence with 30-50 lines.

### T-0081
- Title: Expand Iris recruitment to match Chapter 3 story script
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/events/iris_recruitment.gd, docs/story/act1/chapter-03-the-deserter.md
- Notes: Current: pre-battle (1 line) + post-battle (2 lines). Chapter 3 has: Initiative confrontation, Iris's backstory, chase sequence, decision to desert. Expand to 15-25 lines.

### T-0082
- Title: Expand Garrick recruitment to match story script
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/events/garrick_recruitment.gd, docs/story/act1/chapter-03-the-deserter.md
- Notes: Expand with 10-20 lines capturing his gruff, guilt-laden character voice. Backstory as penitent knight, reasons for being at shrine, reluctant agreement to join.

### T-0083
- Title: Update Roothollow NPC dialogue to match story scripts and style guide
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd, docs/story/camp-scenes/npc-dialogue.md, docs/story/STYLE_GUIDE.md
- Notes: Cross-reference NPC lines against npc-dialogue.md. Apply voice patterns from STYLE_GUIDE.md (regional slang, character-specific speech). Ensure flag states match correctly.

### T-0084
- Title: Add companion follower sprites in overworld
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/entities/player/player.gd, game/autoloads/party_manager.gd
- Notes: After recruiting party members, they only appear in party menu — not visible in overworld. Add follower sprites trailing behind player (delayed movement). AnimatedSprite2D with walk sprite system. Show/hide based on PartyManager roster. Breadcrumb trail of recent player positions.

### T-0085
- Title: Implement Chapter 4 content — Garrick's deeper story at the shrine
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0082
- Refs: docs/story/act1/chapter-04-fragments-of-tomorrow.md
- Notes: After Garrick recruitment, continue with deeper character introductions and first fragment quest. Shrine scene dialogue, bonding moments, narrative hook driving party forward.

### T-0086
- Title: Add demo ending sequence with "Thanks for playing" screen
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0085
- Refs: game/events/, game/ui/title_screen/
- Notes: After demo content complete: "Thanks for playing" screen, party portrait lineup, playtime display, hint at full game. Option to return to title. Replace Elder Thessa conclusion with cinematic ending.

---

### Visual Markers & Player Navigation

### T-0087
- Title: Add on-screen objective tracker UI
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/ui/hud/hud.gd, game/autoloads/quest_manager.gd
- Notes: Small HUD panel (top-right) showing current active quest name and objective text. Auto-update on quest progress. Toggle visibility. Pull from QuestManager. 2-3 lines max.

### T-0088
- Title: Add visual markers for zone transitions (sparkle/arrow effects)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.tscn, game/scenes/verdant_forest/verdant_forest.tscn, game/scenes/overgrown_ruins/overgrown_ruins.tscn
- Notes: Zone exits are invisible. Add animated arrows, particle sparkles, or glowing borders at each exit. AnimatedSprite2D or GPUParticles2D. Include label like "To Verdant Forest ->".

### T-0089
- Title: Add NPC interaction indicators (speech bubble icon above head)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/entities/npc/npc.gd, game/entities/interactable/interactable.gd
- Notes: No visual indicator that NPCs are interactable. Add floating speech bubble / "!" for quests / "?" for info above NPC heads when player in range. Different icons for: quest available, quest in progress, shop, general chat.

### T-0090
- Title: Add quest log/journal UI screen
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/quest_manager.gd, docs/best-practices/08-ui-patterns.md
- Notes: QuestManager tracks quests but no UI to view them. Quest log from pause menu: active quests with objectives + completion, completed quests (grayed), descriptions, reward previews. VBoxContainer + ScrollContainer. Focus nav.

### T-0091
- Title: Add area name display on zone transitions
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/game_manager.gd, game/ui/hud/hud.gd
- Notes: Display area name prominently for 2-3s on entering new zone (centered, large text, fade-in/fade-out). Triggered by GameManager after scene change. Tween animation.

### T-0092
- Title: Add tutorial hints for controls on first playthrough
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/autoloads/event_flags.gd, game/ui/dialogue/dialogue_box.gd
- Notes: Contextual tutorial popups on first occurrence: "Press [interact] to talk", "Press [cancel] for pause menu", "Walk into glowing area to travel." Use EventFlags for show-once. Non-intrusive, any-key dismiss.

### T-0093
- Title: Add fragment tracker / compass UI for story objectives
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0087
- Refs: docs/story/act1/chapter-02-a-voice-in-the-crystal.md, game/ui/hud/hud.gd
- Notes: Story describes fragment tracker that pulses toward objectives. Small HUD crystal icon with directional arrow. Could simplify to pulsing when near objective. Lower priority — text tracker may suffice.

---

### Demo Completeness

### T-0094
- Title: Implement battle ability animations and visual effects
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/action_execute_state.gd, game/resources/ability_data.gd
- Notes: No VFX when abilities used. Add per-element effects: fire (orange particles), ice (blue), healing (green), physical (slash). AnimatedSprite2D or GPUParticles2D. Link to AbilityData.element. Check pixel_animations_gfxpack.

### T-0095
- Title: Add battler idle animations in combat
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/entities/battle/party_battler_scene.gd, game/entities/battle/enemy_battler_scene.gd
- Notes: Sprites static during combat. Add idle bob (sine wave Y, 2px amplitude, 2s period). Different phases per battler. Attack animation: quick lunge (4px, 0.15s). Hit animation: red flash (modulate tween).

### T-0096
- Title: Add particle effects for healing, resonance, and criticals
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0094
- Notes: Healing aura, resonance overload energy, critical hit star burst, status effect mist. GPUParticles2D. Reusable particle scenes.

### T-0097
- Title: Add save point visual markers in scenes
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/entities/interactable/strategies/save_point_strategy.gd
- Notes: Save points have no distinctive visual. Add glowing crystal sprite or shimmering pillar. AnimatedSprite2D with slow pulse. Visually distinct from other interactables.

### T-0098
- Title: Add overworld encounter warning (grass rustle before battle)
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/systems/encounter/encounter_system.gd
- Notes: Random encounters trigger without warning. Add 0.5s warning: screen edge flash, grass rustle particles, or camera zoom. Audio cue if SFX available.

### T-0099
- Title: Add transition animations between zones (beyond fade)
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/game_manager.gd
- Notes: Currently only fade-to-black. Add variety: slide transitions, iris wipe for dungeons, screen shatter for boss encounters. TransitionEffect scene with multiple types.

---

### Polish & Quality of Life

### T-0100
- Title: Add NPC idle animations (breathing, head turn, fidget)
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/entities/npc/npc.gd
- Notes: NPCs are static sprites. Add subtle breathing (scale Y oscillation), head turn, fidget. AnimationPlayer or Tween. Check npc-animations pack for animated sprites.

### T-0101
- Title: Implement party formation and swap UI in pause menu
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0020
- Refs: game/ui/pause_menu/pause_menu.gd, game/autoloads/party_manager.gd
- Notes: Pause menu lacks party management. View all members with stats/equipment, swap positions, character detail view. Reuse patterns from inventory_ui. Focus navigation.

### T-0102
- Title: Add minimap or compass to HUD
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/hud/hud.gd
- Notes: No minimap/compass. Start with compass (simpler), upgrade to minimap later. Low priority for 3-scene demo.

### T-0159
- Title: Fix Verdant Forest south canopy gap — extend AbovePlayer layer to rows 15-24
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/verdant_forest/verdant_forest.gd (CANOPY_MAP), docs/best-practices/11-tilemaps-and-level-design.md
- Notes: CANOPY_MAP has no entries in rows 15-24. The south forest has TREE_MAP tiles and TRUNK_MAP trunk placements (rows 17-23) but no AbovePlayer canopy overlay — breaking the walk-under depth effect that works in the north half. Extend CANOPY_MAP with 2x2 canopy tiles above each south-half trunk position using existing CANOPY_LEGEND keys. Run /scene-preview --full-map after. 2+ tests verifying south rows have non-empty CANOPY_MAP data.

### T-0160
- Title: Wire quest-NPC indicator refresh on QuestManager signals
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0089, T-0090
- Refs: game/scenes/roothollow/roothollow.gd, game/autoloads/quest_manager.gd, game/entities/npc/npc.gd
- Notes: Supersedes T-0112. NPC indicator_type computed once at scene load; quest progress while in scene doesn't refresh indicators. Connect QuestManager.quest_accepted, quest_progressed, quest_completed signals to re-evaluate NPC indicators in roothollow.gd. Static compute_npc_indicator_type(npc_id) helper for TDD. 4+ tests.

### T-0156
- Title: Verify and wire enemy crit attacks through ActionExecute state
- Status: superseded
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0143
- Refs: game/systems/battle/states/enemy_turn_state.gd, game/systems/battle/states/action_execute_state.gd
- Notes: T-0143 added crit rolls in _execute_attack() inside ActionExecuteState. Confirm whether EnemyTurnState routes through ActionExecute (if so, crits already apply to enemies). If enemies use a separate execution path, wire BattlerDamage.roll_crit(attacker.luck) + apply_crit() there. 3+ tests verifying enemy crit chance matches the 5%+luck*0.5% formula.

### T-0158
- Title: Add hit flash animation on battler sprites when taking damage
- Status: done
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/entities/battle/party_battler_scene.gd, game/entities/battle/enemy_battler_scene.gd
- Notes: SUPERSEDED — play_damage_anim() already implements white+red flash with position recoil shake in both battler scenes, wired to _on_damage_taken() via battler.damage_taken signal. Functionality fully present.

---

## M1 — Act I: The Echo Thief

### T-0103
- Title: Implement Chapter 5 — The Overgrown Capital dungeon
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0085
- Refs: docs/story/act1/chapter-05-overgrown-capital.md, docs/game-design/05-dungeon-designs.md
- Notes: First full dungeon. Multi-room tilemap, puzzles, encounters, boss. Major content milestone.

### T-0104
- Title: Implement Chapters 6-10 story events and dialogue
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0103
- Refs: docs/story/act1/
- Notes: Remaining Act I chapters. New areas, character development, faction conflicts.

### T-0105
- Title: Build Prismfall Approach area
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0103
- Refs: docs/game-design/03-world-map-and-locations.md
- Notes: New overworld area. Tilemap, encounters, NPCs, transitions.

### T-0106
- Title: Implement Echo Fragment collection system
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: none
- Refs: docs/lore/04-echo-catalog.md, docs/game-design/01-core-mechanics.md
- Notes: Core gameplay mechanic. EchoFragment Resource, EchoManager autoload, collection UI, world placement.

### T-0107
- Title: Implement full character ability trees for all party members
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M1
- Depends: T-0018
- Refs: docs/mechanics/character-abilities.md
- Notes: 8 characters x 10-15 abilities = 80-120 definitions.

### T-0108
- Title: Build faction reputation system
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M1
- Depends: none
- Refs: docs/game-design/04-side-quests.md, docs/lore/01-world-overview.md
- Notes: Track reputation with Shepherds, Initiative, factions. Affects dialogue, prices, quest availability.

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
- Depends: T-0012
- Refs: docs/game-design/01-core-mechanics.md
- Notes: Combine materials into items. Recipe system, crafting UI, material gathering.

### T-0150
- Title: Add Garrick character quest scaffold — QuestData .tres and quest hook
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0082
- Refs: docs/story/character-quests/garrick-three-burns.md, game/data/quests/
- Notes: Create QuestData .tres resource for "Three Burns" (Garrick's character quest). Multi-part quest with three objective locations from his past. Prerequisites: garrick_recruited. No full scene implementation — just data file and QuestManager integration so the quest appears in the quest log. 3+ tests.

### T-0151
- Title: Add Iris character quest scaffold — QuestData .tres and quest hook
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M1
- Depends: T-0081
- Refs: docs/story/character-quests/iris-engineers-oath.md, game/data/quests/
- Notes: Create QuestData .tres resource for "The Engineer's Oath" (Iris's character quest). Prerequisites: iris_recruited. No full scene implementation — just data file and QuestManager integration so quest appears in quest log. 3+ tests.

### T-0112
- Title: Wire quest-NPC indicator updates on quest state change
- Status: done
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0089
- Refs: game/scenes/roothollow/roothollow.gd, game/autoloads/quest_manager.gd
- Notes: SUPERSEDED by T-0160 (more specific, M0-scoped, includes TDD plan). T-0160 covers the same scope with explicit signal connections and static helper for testability.

### T-0113
- Title: Add interaction prompt label near player when ray hits target
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0089
- Refs: game/entities/player/player.gd, game/ui/hud/hud.gd
- Notes: Small HUD hint ("[E] Talk") when player InteractionRay detects target. May overlap with T-0092 (tutorial hints).

### T-0115
- Title: BUG — Pause menu party panel shows max HP/EE instead of current HP/EE
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/ui/pause_menu/pause_menu.gd
- Notes: _create_member_info() reads member.max_hp and displays both values as max. Should read PartyManager runtime HP/EE state. Visible bug for demo players.

### T-0116
- Title: Disable or stub Settings button on title screen
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/ui/title_screen/title_screen.gd
- Notes: Resolved by T-0068 — settings menu is fully implemented.

### T-0117
- Title: Implement BGM stack in AudioManager for battle music restore
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, game/autoloads/battle_manager.gd
- Notes: push_bgm()/pop_bgm() stack to save/restore overworld music across battle transitions. Required for T-0064 to work end-to-end.

### T-0122
- Title: Add AudioBus volume persistence — save/restore BGM+SFX volumes across sessions
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: T-0068
- Refs: game/autoloads/audio_manager.gd
- Notes: Superseded by T-0068 — SettingsData persists BGM/SFX/Master volumes to user://settings.json.

### T-0123
- Title: BUG — Overworld BGM restore timing after battle may produce audio glitch
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/battle_manager.gd, game/autoloads/audio_manager.gd
- Notes: Resolved by T-0117 — push_bgm()/pop_bgm() stack cleanly saves and restores overworld BGM across battle transitions.

### T-0124
- Title: BUG — XP computed and displayed in victory screen but never applied to party members
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/victory_state.gd, game/systems/progression/level_manager.gd
- Notes: victory_state.gd computes total_exp and passes to show_victory() for display only. No call to LevelManager.add_xp() exists. Characters never level up. Fix: iterate party data, call add_xp(), log level-ups.

### T-0127
- Title: Add playtime display to save/load screen
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/save_manager.gd, game/ui/title_screen/title_screen.gd
- Notes: Save slots show no playtime. SaveManager serializes a timestamp field. Compute elapsed hours:minutes and display in each slot label. Acceptance: each save slot shows "XX:XX" playtime alongside location name. 4+ tests.

### T-0130
- Title: Add live playtime accumulation to GameManager for save slot display
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/autoloads/game_manager.gd, game/autoloads/save_manager.gd
- Notes: SaveManager accepts playtime param but nothing accumulates it. Add playtime_seconds to GameManager, increment in _process during OVERWORLD/MENU. Wire into save calls. Prerequisite for T-0127. 4+ tests.

### T-0132
- Title: Add "Defend" status badge on party battler panels during combat
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd, game/systems/battle/battler.gd
- Notes: Battler.is_defending is tracked but the battle UI shows no visual indicator. Add a "DEF" badge (similar to status effect badges from T-0054) that appears when is_defending is true. Reuse UITheme.get_status_color() pattern. 3+ tests.

### T-0133
- Title: Add save slot summary (location + timestamp) on Continue button
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/title_screen/title_screen.gd, game/autoloads/save_manager.gd
- Notes: Continue button shows no save context. Add a label showing saved scene name and timestamp. Use compute_area_display_name() for location. 3+ tests.

### T-0138
- Title: Add scrollable battle log with history
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd
- Notes: Battle log currently shows fixed lines with oldest pushed off. Add ScrollContainer wrapping RichTextLabel. Auto-scroll to bottom on new entry. 3+ tests.

### T-0139
- Title: Source SFX assets from Time Fantasy packs for UI and combat
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/audio_manager.gd, docs/game-design/06-audio-design.md
- Notes: T-0066 and T-0067 require SFX files to exist. Search /Users/robles/repos/games/assets/ for WAV/OGG SFX in Time Fantasy packs. Copy to game/assets/sfx/ui/ and game/assets/sfx/combat/ using /copy-assets workflow. Minimum set — UI: confirm, cancel, menu-open, dialogue-advance. Combat: attack-hit, magic-cast, heal-chime, death, critical-hit, status-apply. All files need .import entries. 3+ tests verifying load paths.

### T-0140
- Title: Refactor AudioManager to support named SFX channels with priority
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0139
- Refs: game/autoloads/audio_manager.gd
- Notes: Current round-robin SFX pool has no priority system. Add SfxPriority enum (CRITICAL, NORMAL, AMBIENT). Critical sounds (combat hits, death) always claim next free player. Ambient sounds skip if all pool players are busy. 5+ tests.

### T-0141
- Title: Add accessibility tooltips and keyboard shortcut hints to settings menu
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0068
- Refs: game/ui/settings_menu/settings_menu.gd, docs/game-design/06-audio-design.md
- Notes: Add tooltip text on each slider explaining what it controls, keyboard left/right arrow hint label, and reset-to-default button per slider. 3+ tests for compute_slider_tooltip() static function.

### T-0144
- Title: Build playtest runner — core scene with state injection and screenshot capture
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M0
- Depends: none
- Refs: docs/game-design/09-playtest-runner.md, game/tools/scene_preview.gd
- **RESERVED: This ticket is part of the playtest runner feature (T-0144..T-0147). Skip this and pick another task unless you were specifically assigned to implement the playtest runner.**
- Notes: Phase 1 of playtest runner. Create playtest_runner.tscn/gd in game/tools/. JSON config parsing (--config=) + inline CLI arg fallback. State injection: party (PartyManager.add_character), flags (EventFlags.set_flag), inventory (InventoryManager.add_item), gold. Scene navigation via GameManager.change_scene(). Basic actions: wait, screenshot, move (via InputEventAction). Report JSON output (screenshots, errors, final state). Timeout safety exit. Update game/tools/CLAUDE.md.

### T-0145
- Title: Add full action set to playtest runner (dialogue, battle, input simulation)
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M0
- Depends: T-0144
- Refs: docs/game-design/09-playtest-runner.md
- **RESERVED: This ticket is part of the playtest runner feature (T-0144..T-0147). Skip this and pick another task unless you were specifically assigned to implement the playtest runner.**
- Notes: Phase 2 of playtest runner. Input simulation via Input.parse_input_event(): interact, cancel, menu. Dialogue actions: advance_dialogue, wait_dialogue (await DialogueManager.is_active() == false), select_choice. Battle actions: trigger_battle (BattleManager.start_battle), wait_battle. State actions: wait_state, set_flag, log. Equipment injection (EquipmentManager.equip). Quest injection (QuestManager.accept_quest). Error collection via push_error monitoring. Periodic screenshot capture (capture_interval_seconds). Auto-screenshot on error (capture_on_error).

### T-0146
- Title: Create /playtest skill and preset configs for common test scenarios
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: T-0145
- Refs: docs/game-design/09-playtest-runner.md
- **RESERVED: This ticket is part of the playtest runner feature (T-0144..T-0147). Skip this and pick another task unless you were specifically assigned to implement the playtest runner.**
- Notes: Phase 3 of playtest runner. Create /playtest Claude Code skill wrapping Godot CLI invocation. Preset configs in game/tools/playtest_presets/ as JSON files: new_game (empty state, title screen), early_game (kael only, ruins), mid_game (3 party, roothollow), late_game (full party, all flags), battle_test (immediate battle), boss_test (boss encounter), dialogue_test (NPC interaction), full_walkthrough (automated demo playthrough). Inline CLI args: --scene, --party, --flags, --gold, --screenshot-after. Update root CLAUDE.md with /playtest usage and preset docs.

### T-0147
- Title: Add battle auto-play mode to playtest runner for combat balance testing
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0145
- Refs: docs/game-design/09-playtest-runner.md
- **RESERVED: This ticket is part of the playtest runner feature (T-0144..T-0147). Skip this and pick another task unless you were specifically assigned to implement the playtest runner.**
- Notes: Phase 4 of playtest runner (optional). AI-driven party actions during playtested battles — auto-select attack on random enemy. Battle outcome logging: victory/defeat, total turns, per-character HP remaining, abilities used, items consumed. Balance data CSV export for tuning. Configurable party AI strategy (aggressive/balanced/defensive). Multiple battle runs for statistical analysis.

### T-0148
- Title: Add camp scene "Three Around a Fire" — Garrick, Iris, Kael evening dialogue
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0085
- Refs: docs/story/act1/04-old-iron.md (Camp Scene), game/events/
- Notes: Camp fire scene where Garrick cooks stew and party plans Overgrown Capital run. Triggers at Roothollow inn after garrick_met_lyra flag. 3 optional camp dialogue snippets (about shield, Kael, Iris). Main tactical-planning sequence ~15 lines. EventFlags gate: camp_scene_three_fires. New event file game/events/camp_three_fires.gd. 5+ tests.

### T-0149
- Title: Add Spring Shrine interactable south of Roothollow — Garrick meeting location
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0082
- Refs: docs/story/act1/04-old-iron.md (Scene 2), game/scenes/roothollow/roothollow.gd
- Notes: Chapter 4 Scene 2 places the Garrick recruitment at a spring shrine south of Roothollow. Add a trigger zone in Roothollow or Verdant Forest scene that activates garrick_recruitment event when approached (after iris_recruited, before garrick_recruited). Shrine should have a glowing crystal interactable. 4+ tests.

### T-0153
- Title: Seed luck stat in CharacterData .tres files for Kael, Iris, Garrick, Lyra
- Status: done
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/data/characters/, game/resources/character_data.gd
- Notes: SUPERSEDED — all four CharacterData .tres files already have non-zero luck values (Kael=10, Iris=8, Garrick=8, Lyra=12) set during Sprint S02 character data creation. These feed directly into BattlerDamage.compute_crit_chance() in T-0143. No code changes needed.

### T-0154
- Title: Add camp/rest trigger zone at Roothollow inn entrance for T-0148 camp event
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0148
- Refs: game/scenes/roothollow/roothollow.gd, game/entities/interactable/strategies/innkeeper_strategy.gd
- Notes: T-0148 Three Around a Fire camp scene triggers at the Roothollow inn after garrick_met_lyra flag. Add a trigger zone or second interaction option at the inn offering "Rest" (heal, existing) and "Spend the Evening" (camp scene, flag-gated). 3+ tests.

### T-0155
- Title: Wire dismiss prompt text to InputMap for remappable key display
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0129
- Refs: game/ui/battle_ui/battle_ui.gd, game/ui/battle_ui/battle_ui_victory.gd
- Notes: compute_dismiss_prompt_text("interact") uses a static string. Wire to InputMap.action_get_events("interact") to dynamically show the actual key binding. Groundwork for future remapping feature. 2+ tests verifying prompt updates for keyboard vs joypad events.

---

## M2 — Act II: The Weight of Echoes

(Tickets will be created during M2 sprint planning.)

---

## M3 — Act III: Convergence

(Tickets will be created during M3 sprint planning.)

---

## M4 — Optional Content & Polish

(Tickets will be created during M4 sprint planning.)

---

## M5 — Release Readiness

(Tickets will be created during M5 sprint planning.)

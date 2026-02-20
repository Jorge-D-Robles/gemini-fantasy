# Current Sprint

Sprint: S04-m0-close-m1-begin
Milestone: M0 close / M1 begin
Goal: Close M0 with campfire placement and hygiene sweep; begin M1 with Echo system, Chapter 5 dungeon, and Prismfall Approach scene
Started: 2026-02-20

---

## Active

---

## Queue

### T-0180
- Title: Place campfire interactable in Verdant Forest
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Depends: T-0023
- Refs: game/scenes/verdant_forest/verdant_forest.gd

### T-0181
- Title: M0 hygiene sweep — type hints, return types, and doc comments
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none

### T-0182
- Title: Implement EchoFragment Resource and EchoManager autoload
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: high
- Depends: none

### T-0189
- Title: Wire EchoManager into all SaveManager call sites
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Depends: T-0182

### T-0187
- Title: Build Echo Collection Journal UI (view collected echoes in pause menu)
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Depends: T-0182

### T-0103
- Title: Implement Chapter 5 — The Overgrown Capital dungeon
- Status: superseded
- Assigned: unassigned
- Priority: high
- Depends: T-0085
- Notes: Superseded by T-0190/T-0191/T-0192/T-0193/T-0194/T-0195. Work against sub-tasks.

### T-0198
- Title: Refactor MemorialEchoStrategy for generic echo placement
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: high
- Depends: T-0182

### T-0197
- Title: Seed Story Echo .tres files (Morning Commute, Family Dinner, Warning Ignored, The First Crack)
- Status: in-progress
- Assigned: claude
- Started: 2026-02-20
- Priority: high
- Depends: T-0182

### T-0190
- Title: Implement Chapter 5 Overgrown Capital dungeon tilemap and navigation skeleton
- Status: todo
- Assigned: unassigned
- Priority: high
- Depends: T-0198, T-0197

### T-0184
- Title: Seed ability tree .tres files for all 8 party members
- Status: todo
- Assigned: unassigned
- Priority: high
- Depends: T-0018

---

### T-0168
- Title: Verify and fix enemy turn routing through ActionExecuteState for consistent crit behavior
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0143, T-0156
- Refs: game/systems/battle/states/enemy_turn_state.gd, game/systems/battle/states/action_execute_state.gd
- Notes: Confirm whether EnemyTurnState routes through ActionExecuteState (crits already applied). If not, wire BattlerDamage.roll_crit(attacker.luck) and apply_crit() into the enemy damage path. Also confirm COMBAT_CRITICAL_HIT SFX plays on enemy crits. 3+ tests verifying enemy crit roll uses 5% + luck*0.5% formula.

### T-0130
- Title: Add live playtime accumulation to GameManager for save slot display
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Refs: game/autoloads/game_manager.gd, game/autoloads/save_manager.gd
- Notes: SaveManager accepts playtime param but nothing accumulates it. Add playtime_seconds to GameManager, increment in _process during OVERWORLD/MENU. Wire into save calls. Prerequisite for T-0127. 4+ tests.

### T-0138
- Title: Add scrollable battle log with history
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd
- Notes: Battle log currently shows fixed lines with oldest pushed off. Add ScrollContainer wrapping RichTextLabel. Auto-scroll to bottom on new entry. 3+ tests.

### T-0162
- Title: Add Verdant Forest traversal dialogue — party comments heading to Overgrown Capital
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0085
- Refs: docs/story/act1/04-old-iron.md (End of Chapter hook), game/scenes/verdant_forest/verdant_forest.gd
- Notes: After garrick_recruited flag is set, the three-person party crosses the Verdant Forest toward Overgrown Ruins. Add a 3-4 line on-entry dialogue gated by garrick_recruited (and forest_traversal_full_party flag to fire once only). Garrick notes crystal density, Iris assesses threat level, Kael orients the group. 3+ tests.

### T-0163
- Title: Add party swap validation feedback in party UI
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0020
- Refs: game/ui/party_ui/party_ui.gd, game/ui/party_ui/party_ui_data.gd
- Notes: compute_swap_valid() returns false for invalid swaps (edge cases like 0-size lists). Currently the UI silently ignores the action. Add a 0.3s red flash on the active member button and a transient status label. compute_swap_feedback_text() static helper for TDD. 3+ tests.

### T-0020
- Title: Build party management UI
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Depends: T-0013
- Refs: docs/best-practices/08-ui-patterns.md
- Notes: party_ui_data.gd (3 static helpers), party_ui.gd (Control sub-screen, two-column active/reserve, swap), pause_menu wired. 15 tests. PR #194 merged.

### T-0121
- Title: Add Roothollow Chapter 4 NPC dialogue updates (Iris arrival reactions)
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: T-0082
- Refs: docs/story/act1/04-old-iron.md (Scene 1), game/scenes/roothollow/roothollow.gd
- Notes: Chapter 4 Scene 1: 5 NPCs with iris_recruited flag variants. Maeve greets Iris, Old Wick accepts "deserter" label, Tomas mentions shrine stranger, Yara asks about horse, Petra notes Garrick refused food. 6+ tests. T-0082 done — unblocked.

### T-0131
- Title: Add Kael-Iris arrival dialogue at Roothollow entrance (Chapter 4 Scene 1)
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: T-0082
- Refs: docs/story/act1/04-old-iron.md (Scene 1), game/scenes/roothollow/roothollow.gd
- Notes: 6-8 lines on first entry with iris_recruited=true. Iris comments on tree architecture. EventFlags gate. 5+ tests. T-0082 done — unblocked.

### T-0134
- Title: Add Elder Morin briefing scene — tactical objective-setting for Overgrown Capital
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: T-0082
- Refs: docs/story/act1/04-old-iron.md (Scene 3), game/scenes/roothollow/roothollow.gd
- Notes: 6-9 lines in Morin's study after garrick_recruited flag. Establishes Overgrown Capital as next objective. 4+ tests. T-0082 done — unblocked.

### T-0143
- Title: Implement critical hit mechanic and wire CRITICAL_HIT SFX and popup
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: T-0067
- Refs: game/systems/battle/battler_damage.gd, game/systems/battle/states/action_execute_state.gd, game/entities/battle/damage_popup.gd
- Notes: luck stat is unused. Add crit chance: base 5% + (luck * 0.5)%. BattlerDamage returns crit flag. On crit: ×1.5 damage, COMBAT_CRITICAL_HIT SFX, DamagePopup.CRITICAL. 5+ tests. T-0067 done — unblocked.

### T-0111
- Title: Add interaction indicators to Interactable objects (save points, chests, signs)
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: T-0089
- Refs: game/entities/interactable/interactable.gd
- Notes: IndicatorType enum (NONE/INTERACT/SAVE); compute_indicator_text/visible static helpers; floating Label with bob tween; InteractionArea body signals; hides permanently after one_time use; gold color for SAVE; 11 tests (1104 total).

### T-0120
- Title: Add quest accept/complete toast notification in HUD
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: T-0087
- Refs: game/ui/hud/hud.gd, game/autoloads/quest_manager.gd
- Notes: compute_toast_text() static helper; "New Quest: [name]" / "Quest Complete: [name]"; _setup_quest_toast() creates Label at PRESET_CENTER_BOTTOM in gold color; queue-based _process_quest_toasts() coroutine; fade-in 0.3s / hold 2.0s / fade-out 0.5s; 7 tests (1118 total).

### T-0119
- Title: Quest log reward display should show item display names, not IDs
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: T-0090
- Refs: game/ui/quest_log/quest_log.gd
- Notes: compute_quest_list() returns raw item ID strings. Resolve to display names via ItemData lookup. T-0090 done — unblocked.

### T-0136
- Title: Add player-driven defeat screen with Load/Title recovery options
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: none
- Refs: game/systems/battle/states/defeat_state.gd, game/ui/battle_ui/battle_ui.gd
- Notes: defeat_action_chosen signal; compute_defeat_options(has_save) helper; RetryButton hidden when no save; defeat_state awaits signal, loads save or goes to title; 9 tests.

### T-0126
- Title: Show level-up callouts and stat gains in victory screen
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: T-0124
- Refs: game/ui/battle_ui/battle_ui.gd, game/systems/battle/states/victory_state.gd
- Notes: compute_level_up_callout_text(character, level, changes) static helper; format "★ Kael reached Level 4! HP+10, ATK+2"; used in _build_victory_party_section and level_up_messages; 7 tests (1111 total).

### T-0159
- Title: Fix Verdant Forest south canopy gap — extend AbovePlayer layer to rows 15-24
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-20
- Priority: medium
- Depends: none
- Refs: game/scenes/verdant_forest/verdant_forest.gd (CANOPY_MAP), docs/best-practices/11-tilemaps-and-level-design.md
- Notes: CANOPY_MAP rows 15-22 filled with 88 type-matched 2x2 canopy tiles above 22 south-half trunks. Trunk A→1234, B→5678, C→abcd, D→efgh. Canopy top at trunk_row-2, bottom at trunk_row-1, cols trunk_col-1 and trunk_col. 6 tests (1164 total).

### T-0128
- Title: BUG — AudioManager.play_bgm() resets volume_db to 0.0, ignoring user volume setting
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: low
- Depends: T-0068
- Refs: game/autoloads/audio_manager.gd
- Notes: Added _bgm_volume_db field; set_bgm_volume() persists it; play_bgm cold-start and pop_bgm restore use _bgm_volume_db; crossfade tweens fade to _bgm_volume_db; 5 tests (1126 total).

### T-0135
- Title: Add Chapter 4 Scene 5 night scene — Garrick and Lyra conversation at camp
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0085
- Refs: docs/story/act1/04-old-iron.md (Scene 5), game/events/garrick_meets_lyra.gd
- Notes: Quiet night scene at Roothollow before departure. 8-10 lines. Gated by garrick_met_lyra flag. T-0085 done — unblocked.

### T-0137
- Title: Add Roothollow market expansion — Maeve stocks Forest Remedy and Crystal Wick after Iris
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0082
- Refs: docs/story/act1/04-old-iron.md (Scene 1), game/scenes/roothollow/roothollow_dialogue.gd
- Notes: Flag-conditional item pool addition when iris_recruited is set. May need new ItemData resources. 3+ tests. T-0082 done — unblocked.

### T-0171
- Title: Add Overgrown Capital entry scene — 3-person party gate dialogue on entry
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Depends: T-0085
- Refs: docs/story/act1/05-into-the-capital.md (Scene 1), game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Chapter 5 Scene 1 gate dialogue (4-5 lines): Garrick reacts to scale of ruins, Iris reports crystal density, Kael quiet. Gated by garrick_recruited AND overgrown_capital_entry_seen flag (one-shot). Trigger on scene entry via call_deferred. Static module pattern from T-0162 (VerdantForestDialogue). 3+ tests.

### T-0095
- Title: Add battler idle animations in combat
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: none
- Notes: BOB_AMPLITUDE=3.0px, BOB_HALF_PERIOD=0.6s; looping sine-wave tween on sprite.position.y; pauses during attack/damage, stops on defeat; _exit_tree cleanup; 8 tests (1134 total).

### T-0097
- Title: Add save point visual markers in scenes
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Priority: medium
- Depends: none
- Notes: SavePointMarker script-only Node2D (ZoneMarker pattern); gold ★ Label, looping alpha pulse (0.4→1.0, 0.8s half-period); integrated into roothollow._ready() with indicator_type=SAVE; 7 tests (1141 total).

### T-0101
- Title: Implement party formation and swap UI in pause menu
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Depends: T-0020
- Notes: compute_equipment_slots helper + character detail panel (stats + equipment) in party_ui. 5 new tests. PR #195 merged.

### T-0165
- Title: Add keyboard and gamepad focus navigation to party_ui sub-screen
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Depends: T-0020
- Refs: game/ui/party_ui/party_ui.gd, docs/best-practices/08-ui-patterns.md
- Notes: compute_cross_column_focus_index() static helper in party_ui_data.gd; _setup_focus() rewritten with vertical wrap per column, right/left cross-column neighbors, Back button wired downward from column bottoms. 5 tests. PR #199 merged.

### T-0057
- Title: Improve turn order display with current actor highlight
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Notes: compute_turn_order_entries() static helper in BattleUIStatus returns ordered entries with [ActiveBattler] brackets + ACTIVE_HIGHLIGHT, party=blue, enemy=red. update_turn_order() simplified to render from entries. 6 tests. PR #200 merged.

### T-0058
- Title: Add screen shake on heavy damage
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Notes: BattleShake static utility (is_heavy_hit, compute_intensity, shake). Threshold=25% max HP, intensity 3–7px, duration 0.35s. Wired in action_execute_state.gd after attack and ability take_damage calls. 10 tests. PR merged.

### T-0061
- Title: Overgrown Ruins — separate debris layer and fix z-index ambiguity
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Notes: GroundDebris TileMapLayer created dynamically in _ready(); DEBRIS_MAP now built on it (was _ground_detail_layer). Fixed Walls/Objects z_index from -1 to 0 (walls were hidden under ground). 5 dimension-check tests. PR merged.

### T-0077
- Title: Split verdant_forest.gd and overgrown_ruins.gd into tilemap/encounter/dialogue modules
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0073
- Notes: Extracted VerdantForestMap, VerdantForestEncounters, OvergrownRuinsMap, OvergrownRuinsEncounters modules. 11 new tests. Scene files delegated to modules. 1265 tests passing.

### T-0078
- Title: Create reusable asset loader helper with consistent null-check pattern
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Notes: AssetLoader static utility in game/systems/; load_sfx/load_bgm/load_texture/load_scene/load_resource with ResourceLoader.exists() guard + push_warning. 10 tests. PR merged.

### T-0093
- Title: Add fragment tracker / compass UI for story objectives
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0087

### T-0096
- Title: Add particle effects for healing, resonance, and criticals
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0094

### T-0098
- Title: Add overworld encounter warning (grass rustle before battle)
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Notes: encounter_warning signal + warning_delay=0.8s export on EncounterSystem; _on_step() emits warning, sets _warning_in_progress, stores _pending_group, fires one-shot timer; _on_warning_timeout() clears state and emits encounter_triggered; both scenes wire flash tween (modulate Color(1.3,1.3,0.9)→WHITE). 6 new tests, 2 updated. 1248 total.

### T-0099
- Title: Add transition animations between zones (beyond fade)
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none

### T-0100
- Title: Add NPC idle animations (breathing, head turn, fidget)
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Notes: BREATHE_SCALE_DELTA=0.03/BREATHE_HALF_DURATION=1.1s/HEAD_TURN_MIN=3.5s/HEAD_TURN_MAX=8.0s; start_idle_animation()/stop_idle_animation() in _ready()/_exit_tree()/interact(); 8 tests in test_npc_idle_anim.gd (1438 total). PR #230 merged.

### T-0102
- Title: Add minimap or compass to HUD
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Notes: HudCompass static module; compute_compass_text()/compute_compass_visible() pure helpers; zone adjacency map (Roothollow↔VerdantForest↔OvergrownRuins); wired into hud.gd _ready()/_on_scene_changed(); 12 tests. PR #232 merged.

### T-0160
- Title: Wire quest-NPC indicator refresh on QuestManager signals
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0089, T-0090
- Refs: game/scenes/roothollow/roothollow.gd, game/autoloads/quest_manager.gd, game/entities/npc/npc.gd
- Notes: compute_npc_indicator_type() static helper in roothollow_quests.gd. _refresh_npc_indicators() wired to quest_accepted/progressed/completed signals in _ready(). 7 tests. PR #201 merged.

### T-0132
- Title: Add "Defend" status badge on party battler panels during combat
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Refs: game/ui/battle_ui/battle_ui.gd, game/systems/battle/battler.gd
- Notes: DEFEND_BADGE_COLOR in UITheme; compute_defend_badge() static helper in BattleUIStatus; wired in battle_ui._create_party_row(); fixed TurnEnd to update_party_status() before end_turn(); fixed PlayerTurnState to update_party_status() after defend(). 4 tests. PR #196 merged.

### T-0133
- Title: Add save slot summary (location + timestamp) on Continue button
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Refs: game/ui/title_screen/title_screen.gd, game/autoloads/save_manager.gd
- Notes: timestamp field in gather_save_data(); compute_save_summary() + _format_save_timestamp() static helpers; _show_save_label() adds Label below ContinueButton. 8 tests. PR #197 merged.

### T-0166
- Title: BUG — Defend stance clears before enemy can attack
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: none
- Refs: game/systems/battle/battler.gd, game/systems/battle/states/turn_end_state.gd, game/systems/battle/states/player_turn_state.gd
- Notes: Removed is_defending=false from Battler.end_turn(); added clear in PlayerTurnState.enter() so defend persists through enemy attacks. Updated test_battler.gd and test_battle_state_persistence.gd. 4 tests. PR #198 merged.

### T-0148
- Title: Add camp scene "Three Around a Fire" — Garrick, Iris, Kael evening dialogue
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: low
- Depends: T-0085
- Refs: docs/story/act1/04-old-iron.md (Camp Scene), game/events/
- Notes: Campfire scene where Garrick cooks stew and party plans Overgrown Capital run. Triggers at Roothollow inn after garrick_met_lyra flag. 3 optional snippets + 15-line main sequence. EventFlags gate: camp_scene_three_fires. New event file game/events/camp_three_fires.gd. 5+ tests.

### T-0149
- Title: Add Spring Shrine interactable south of Roothollow — Garrick meeting location
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Priority: medium
- Depends: T-0082
- Refs: docs/story/act1/04-old-iron.md (Scene 2), game/scenes/roothollow/roothollow.gd
- Notes: Extracted zone trigger conditions to roothollow_zone.gd (RoothollowZone, RefCounted). compute_garrick_zone_can_trigger() requires opening_lyra_discovered AND iris_recruited, blocks if garrick_recruited. compute_shrine_marker_visible() shows "↓ Spring Shrine" label between iris and garrick recruitment. _on_garrick_zone_entered refactored to use module. 8 tests (1172 total).

---

## Done This Sprint

### T-0026
- Title: Build debug console
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Notes: DebugCommands static class with compute_debug_command_result() and execute_command(); CanvasLayer UI with LineEdit/output label (layer=100); backtick toggle; 5 commands: heal_all/set_level/add_item/teleport/set_flag; OS.is_debug_build() guard in UILayer; 18 tests (1536 total). PR #241 merged.

### T-0178
- Title: Add read-only control bindings display to settings menu
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Notes: compute_control_bindings()/compute_action_label()/compute_action_key_label() in SettingsData; Controls section (GridContainer) in settings_menu.gd; panel expanded to 380px min height; 8 tests (1518 total passing). PR #240 merged.

### T-0175
- Title: Add fade-in on BGM stack pop/restore to prevent audio snap
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Notes: BGM_RESTORE_FADE_TIME=0.5s constant; compute_bgm_restore_fade_duration() static helper; pop_bgm() cold-start else branch fades from -80.0 to _bgm_volume_db instead of snapping; 2 new tests (1402 total).

### T-0164
- Title: Wire party_changed signal from PartyManager into party_ui refresh
- Status: done
- Assigned: claude
- Started: 2026-02-20
- Completed: 2026-02-20
- Notes: _connect_party_signals() / _disconnect_party_signals() extracted; idempotent is_connected guard; _on_party_changed() rebuilds UI; removed redundant manual _build_ui() after swap; 5 tests (1400 total). PR #222 merged.

### T-0128
- Title: BUG — AudioManager BGM player volume resets on BGM change
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Notes: _bgm_volume_db field added; set_bgm_volume() stores field; play_bgm/pop_bgm/crossfade tweens all use _bgm_volume_db; 5 tests (1126 total).

### T-0119
- Title: Quest log reward display should show item display names, not IDs
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Notes: compute_item_display_name() static helper with ResourceLoader.exists() guard; fallback to raw ID; rewards.items now Array[String] of display names; _on_quest_selected renders names via join(); 3 new tests (1121 total).

### T-0120
- Title: Add quest accept/complete toast notification in HUD
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Notes: compute_toast_text() static helper; "New Quest: [name]" / "Quest Complete: [name]"; _setup_quest_toast() creates Label at PRESET_CENTER_BOTTOM in gold color; queue-based _process_quest_toasts() coroutine; fade-in 0.3s / hold 2.0s / fade-out 0.5s; 7 tests (1118 total).

### T-0126
- Title: Show level-up callouts and stat gains in victory screen
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Notes: compute_level_up_callout_text(character, level, changes) static helper; format "★ Kael reached Level 4! HP+10, ATK+2"; wired into _build_victory_party_section replacing hardcoded text; level_up_messages uses same helper; 7 tests (1111 total).

### T-0111
- Title: Add interaction indicators to Interactable objects (save points, chests, signs)
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Notes: IndicatorType enum (NONE/INTERACT/SAVE); compute_indicator_text/visible static helpers; floating Label with bob tween; InteractionArea body signals; hides permanently after one_time use; gold color for SAVE; 11 tests (1104 total).

### T-0125
- Title: Improve game over / defeat screen with recovery options
- Status: duplicate
- Assigned: unassigned
- Notes: DUPLICATE of T-0136 (completed 2026-02-19). T-0136 fully implements defeat screen dismiss flow with Load Last Save / Return to Title buttons, compute_defeat_options() helper, and signal-based state machine integration.

### T-0143
- Title: Implement critical hit mechanic and wire CRITICAL_HIT SFX and popup
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Notes: compute_crit_chance/roll_crit/apply_crit in BattlerDamage; CRIT_BASE_CHANCE=0.05, CRIT_LUCK_BONUS=0.005, CRIT_DAMAGE_MULT=1.5 in GameBalance; crit branch in _execute_attack with CRITICAL_HIT SFX, death SFX if kill, CRITICAL popup; 12 tests.

### T-0136
- Title: Add player-driven defeat screen with Load/Title recovery options
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Notes: defeat_action_chosen signal; compute_defeat_options(has_save) helper; defeat_state awaits signal, loads save or goes to title; 9 tests.

### T-0129
- Title: Add player-driven victory screen dismissal (confirm input replaces 2.0s timer)
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Notes: GRACE_PERIOD=0.5 const; await grace period then show_victory_dismiss_prompt() + await victory_dismissed signal; compute_dismiss_prompt_text("interact") static helper; _unhandled_input gate on "interact" key; 7 tests. Also fixed stale test_player_z_index.gd (tscn file parsing, z=0 design). Verdant forest muted green variant + canopy legend extension bundled.

### T-0147
- Title: Add battle auto-play mode to playtest runner for combat balance testing
- Status: done
- Assigned: claude
- Started: 2026-02-19
- Completed: 2026-02-19
- Notes: Added auto_play_battle action type to PlaytestActions and runner. AI-driven party auto-attack: polls BattleStateMachine.current_state, emits command_selected("attack") on PlayerTurn and target_selected(first_enemy) on TargetSelect. Captures victory/defeat via BattleManager.battle_ended signal. Logs outcome, player action count, and final HP per character. 4 new tests (1065 total). Updated battle_test.json preset to use auto_play_battle.

### T-0146
- Title: Create /playtest skill and preset configs for common test scenarios
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: /playtest skill (SKILL.md) wrapping CLI invocation with preset support. 7 preset configs: new_game, mid_game, late_game, battle_test, boss_test, dialogue_test, full_walkthrough. Fixed runner scene loading — uses root.add_child.call_deferred() instead of GameManager.change_scene() (which would free the runner). Verified end-to-end: runner exits 0 with success=true, screenshot+report written, HUD shows injected party state. No new tests (all test coverage in T-0144/T-0145).

### T-0145
- Title: Add full action set to playtest runner (dialogue, battle, input simulation)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: PlaytestActions static registry (14 action types, validate_action, get_action_input_name). Full action set in runner: interact/cancel/menu, advance_dialogue, wait_dialogue (timeout), select_choice, trigger_battle (loads enemies), wait_battle (timeout), wait_state (GameState parse), set_flag, log. Structured log file output (playtest.log). _warnings array distinct from _errors. _finishing guard against double-quit. 36 new tests (1061 total).

### T-0144
- Title: Build playtest runner — core scene with state injection and screenshot capture
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: playtest_runner.tscn/gd (Node2D entry point with full autoload support). playtest_config.gd (static: JSON parse, CLI arg parse, merge_defaults, validate). playtest_capture.gd (static: screenshot filename format, viewport capture, JSON report builder). State injection: party/levels, flags, inventory, gold, equipment, quests. Basic actions: wait, screenshot, move. Timeout safety exit. Report JSON at /tmp/playtest/report.json. 34 new tests (1025 total). Updated game/tools/CLAUDE.md.

### T-0094
- Title: Implement battle ability animations and visual effects
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: BattleVFX script-only Node2D (follows DamagePopup fire-and-forget pattern). Per-element AnimatedSprite2D built from pixel_animations_gfxpack sprite sheets (9 VFX: fire, ice, water, wind, earth, holy, darkness, impact, heal). Static get_vfx_config()/build_sprite_frames() for testability. Integrated into action_execute_state.gd for attacks, abilities, and healing items. 7 new tests (988 total).

### T-0092
- Title: Add tutorial hints for controls on first playthrough
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: TutorialHints static utility (3 hints: interact, menu, zone_travel). HUD overlay with tween fade animation, interact-only dismiss, state-change cleanup. Triggers in scene scripts (Roothollow interact, Overgrown Ruins menu/zone_travel). EventFlags for show-once persistence. 11 new tests (981 total).

### T-0083
- Title: Update Roothollow NPC dialogue to match story scripts and style guide
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Added Verdant Tangle regional slang ("root deep", "overgrown") to all 5 native NPCs across 4 flag states. Garrick uses Cindral Wastes fire/ash metaphors (no Tangle slang). Fixed 4 cliché/banned-pattern lines in Thessa. Trimmed Thessa garrick_recruited from 5 to 4 lines. Shortened Garrick's sentences with more pauses. 6 new slang verification tests (970 total).

### T-0067
- Title: Add combat sound effects (attack, magic, heal, death)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Wired AudioManager.play_sfx(load(SfxLibrary.COMBAT_*)) into 2 battle state scripts. 5 SFX types: ATTACK_HIT (melee), MAGIC_CAST (abilities), HEAL_CHIME (items), DEATH (kill), STATUS_APPLY (effects). Covers both player and enemy actions. CRITICAL_HIT deferred (no crit detection exists). All 964 tests pass.

### T-0066
- Title: Add UI sound effects (menu, dialogue, buttons)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Wired AudioManager.play_sfx(load(SfxLibrary.UI_*)) into 8 UI scripts (27 insertion points). 4 SFX types: UI_CONFIRM (buttons), UI_CANCEL (close/back), UI_MENU_OPEN (panels), UI_DIALOGUE_ADVANCE (dialogue). Covers dialogue, pause, title, settings, inventory, shop, quest log, battle UI. All 964 tests pass.

### T-0139
- Title: Source SFX assets for UI and combat
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Time Fantasy packs have no audio. Generated 10 procedural placeholder SFX (Python+ffmpeg). SfxLibrary constants class with 4 UI + 6 combat path constants. OGG Vorbis 44.1kHz mono. sfx/CLAUDE.md docs. 7 new tests (964 total).

### T-0084
- Title: Add companion follower sprites in overworld
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: CompanionController (position history buffer, FOLLOW_OFFSET=15, MAX_HISTORY=200) + CompanionFollower (3x4 sprite AnimatedSprite2D, z_index=-1). Iris/Garrick sprites extracted from Time Fantasy elements_core_pack_9. Kael filtered by ID. Signal cleanup in _exit_tree(). Wired into all 3 scenes. 18 new tests (957 total).

### T-0068
- Title: Build settings/options menu with volume sliders
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: SettingsData static utility (percent/dB conversion, bus-level control, JSON persistence). SettingsMenu script-only Control with 3 HSliders, live preview, save on close. Wired into title screen and pause menu. AudioManager loads on startup. 14 new tests (939 total).

### T-0076
- Title: Split shop_ui.gd into buy panel, sell panel, and character selector
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Extracted ShopUIDetail (equip stat lines, item effect text, detail panel info) and ShopUIList (buy/sell entry computation with Callable DI). shop_ui.gd reduced 484->457 lines. 20 new tests (925 total).

### T-0075
- Title: Split inventory_ui.gd into category manager, detail panel, and applicator
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Extracted InventoryUIFilter (matches_category + compute_item_entries with Callable resolver) and InventoryUIDetail (compute_equipment_stats + compute_item_detail with guards). inventory_ui.gd reduced from 602 to 531 lines. Added HP/EE bonus display. 20 new tests (905 total).

### T-0074
- Title: Split battle_ui.gd into composable panel components
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Extracted 4 static methods into BattleUIStatus (compute_status_badges + compute_target_info) and BattleUIVictory (compute_victory_display + stat_abbreviation). battle_ui.gd reduced from 793 to ~700 lines. Updated 3 test files. All 885 tests pass.

### T-0086
- Title: Add demo ending sequence with "Thanks for playing" screen
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: DemoEnding event (4-line closing dialogue, BGM stop, scene transition). DemoEndScreen Control with party lineup and return-to-title. Save-reload edge case in overgrown_ruins.gd. 17 new tests (885 total).

### T-0060
- Title: Roothollow — reduce ground detail density from 50% to 15%
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Thinned DECOR_MAP from 18.5% to ~13% density (89 decorations on 672 open tiles). Kept intentional placements near buildings/paths. 7 new tests covering map dimensions and density bounds (868 total).

### T-0085
- Title: Implement Chapter 4 content — Garrick's deeper story at the shrine
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: GarrickMeetsLyra event (14-line dialogue compressing Chapter 4 Scene 5). Three-state LyraDiscoveryZone logic in overgrown_ruins.gd. Garrick confronts Lyra — "Are you in pain?" emotional peak. Flag garrick_met_lyra. 12 new tests (861 total).

### T-0073
- Title: Split roothollow.gd into tilemap, dialogue, and quest handler modules
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Extracted roothollow_dialogue.gd (6 static NPC dialogue functions) and roothollow_quests.gd (quest text + condition helpers). Coordinator reduced from 803 to 389 lines. All 849 tests pass.

### T-0091
- Title: Add area name display on zone transitions
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Centered popup Label with fade-in/hold/fade-out tween (0.3s/2.0s/0.5s). Static compute_area_display_name() maps scene paths to display names. AREA_NAMES dict for 3 zones. 5 tests (849 total).

### T-0056
- Title: Enhance victory screen with portraits and level-up display
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Character portraits (32x32 atlas), name+level, "LEVEL UP!" callout with stat changes. compute_victory_display() static method. show_victory() extended with default args for backward compat. victory_state.gd passes party and level_ups. 7 tests.

### T-0055
- Title: Improve battle target selector with name label and highlight
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Name label on TargetSelector showing target display name, visual highlight tint (modulate) on selected battler with cache/restore, compute_target_info() static method, TARGET_HIGHLIGHT_ENEMY/PARTY in UITheme. 5 tests.

### T-0050
- Title: BUG — Overgrown Ruins spawn position check uses Vector2.ZERO comparison
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Removed fragile Vector2.ZERO comparison. Always set player to spawn point — GameManager and SaveManager override after _ready() as needed.

### T-0070
- Title: Split battler.gd into damage calculator, resonance controller, and status manager
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: 3 static utility classes (BattlerDamage, BattlerResonance, BattlerStatus) with delegation from battler.gd. tick_effects() kept in Battler for HP state ownership. 28 new tests (779 total). Updated systems/CLAUDE.md.

### T-0080
- Title: Expand Lyra discovery dialogue to match story script (~50 lines)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Expanded from 23 to 48 lines compressing Chapter 1 Scene 5 + Chapter 2 Scene 2. Added structured fragmentation, sealed truth, Resonance energy/fading, emotional connection (Lyra sensing Kael listening), vague fragment quest hook, closing beat. 6 new content tests (16 total). Updated events/CLAUDE.md.

### T-0082
- Title: Expand Garrick recruitment to match story script
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Expanded from 6 to 17 lines matching Chapter 4 story script. Extracted _build_dialogue() helper. Covers Scenes 2+4 beats: Iris Shepherd recognition, identity reveal, crystal corruption, Willowmere confession, Lyra proposition, conditions, honey cakes closing. 10 tests.

### T-0081
- Title: Expand Iris recruitment to match Chapter 3 story script
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Expanded from 7 to 19 lines (7 pre-battle + 12 post-battle). Extracted _build_pre_battle_dialogue() and static _build_post_battle_lines() helpers. Covers Scenes 2-4 beats: combat encounter, identity reveal, Resonance Cage, Lyra reveal, Dane foreshadowing, pragmatic joining. 12 tests.

### T-0079
- Title: Expand opening sequence to match Chapter 1 story script
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Expanded Lyra discovery dialogue from 6 to 23 lines matching Chapter 1 story script beats (discovery, analysis, first contact, identity, warning, resolve). Extracted _build_dialogue() helper. 9 tests.

### T-0090
- Title: Add quest log/journal UI screen
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Script-only Control (no .tscn) opened from pause menu. Active/Completed tabs, quest list with detail panel, objectives with checkmarks, reward previews. compute_quest_list() static function for TDD. QuestsButton added to pause menu. 8 tests.

### T-0089
- Title: Add NPC interaction indicators (speech bubble icon above head)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: IndicatorType enum (NONE/CHAT/QUEST/QUEST_ACTIVE/SHOP) in npc.gd. Floating Label with bob animation, proximity show/hide via InteractionArea, dialogue-aware, tween cleanup. Dynamic quest-state indicators for Thessa/Wren. 13 tests.

### T-0059
- Title: Roothollow — add AbovePlayer tilemap layer and consolidate tree sprites
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: CANOPY_LEGEND (3 tiles from FOREST_OBJECTS) and CANOPY_MAP (40x28, canopy at inner border edges). build_layer call added to _setup_tilemap(). No overlap with ROOF_MAP.

### T-0062
- Title: Add boundary collision walls to all map edges
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: MapBuilder.create_boundary_walls() static method. 4 invisible StaticBody2D walls per scene on collision layer 2. All 3 scenes wired. Fixed CLAUDE.md map dimension errors. 12 tests.

### T-0049
- Title: BUG — Verdant Forest camera limit cuts off bottom row
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Already fixed in codebase — limit_bottom=400 matches 25-row map (400px)

### T-0051
- Title: Add battle background sprite and scene backdrop
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Programmatic gradient backgrounds per area type (forest/ruins/town/cave). 10 unit tests.

### T-0069
- Title: Extract shared UI helpers (colors, focus nav, panel styles, clear_children)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Created ui_theme.gd (19 color constants) and ui_helpers.gd (3 static utilities). Refactored 6 UI files. 19 tests.

### T-0071
- Title: Centralize game balance constants into game_balance.gd
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Created game_balance.gd (22 constants, 7 categories). Refactored 5 source files. 23 tests.

### T-0052
- Title: Color-code battle log messages by type
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: LogType enum + 7 LOG_* colors in ui_theme.gd, BBCode color wrapping in add_battle_log(), all 25 call sites updated across 8 files. Fixed duplicate const GB in enemy_battler.gd. 16 tests.

### T-0053
- Title: Add floating damage numbers above targets
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Created reusable DamagePopup component (script-only Node2D). Supports DAMAGE/HEAL/CRITICAL types with colored text, 0.8s float-up animation. Replaced inline single-label in both battler scenes. Added missing show_heal_number() to EnemyBattlerScene. 11 tests.

### T-0087
- Title: Add on-screen objective tracker UI
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: PanelContainer in HUD (top-right, below PartyStatus). QuestTitle (gold) + ObjectiveLabel (lavender). Static compute_tracker_state() for testability. Connected to 4 QuestManager signals. 7 tests.

### T-0064
- Title: Integrate BGM playback into all scenes and battle system
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Scene-owned BGM via SCENE_BGM_PATH constants and _start_scene_music() in _ready(). BattleManager plays battle/boss BGM with boss detection via EnemyData.AiType.BOSS. Victory fanfare. AudioManager.get_current_bgm_path() accessor. Null-safe OGG loading. 8 new tests (787 total).

### T-0117
- Title: Implement BGM stack in AudioManager for battle music restore
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: push_bgm()/pop_bgm()/has_stacked_bgm() in AudioManager. BattleManager pushes before battle, pops after. _crossfade_bgm_at() for position-aware restore. 8 new tests (818 total).

### T-0115
- Title: BUG — Pause menu party panel shows max HP/EE instead of current HP/EE
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Extracted static compute_member_stats() in pause_menu.gd. Reads PartyManager runtime HP/EE state for current values, falls back to max when unavailable. 7 new tests (810 total).

### T-0072
- Title: Create scene_paths.gd for centralized scene path constants
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: ScenePaths class with 5 constants (ROOTHOLLOW, VERDANT_FOREST, OVERGROWN_RUINS, TITLE_SCREEN, BATTLE_SCENE). Refactored 8 consumer files. 7 new tests (803 total).

### T-0124
- Title: BUG — XP computed and displayed in victory screen but never applied to party members
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Extracted static apply_xp_rewards() in victory_state.gd. Calls LevelManager.add_xp() for each CharacterData in party, logs level-ups in battle log. Added make_character_data() to test_helpers.gd. 9 new tests (796 total).

### T-0054
- Title: Add status effect icons/badges on battler panels
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: Color-coded 2-char badges by EffectType (BUFF/DEBUFF/DOT/HOT/STUN). Battler.get_effect_data() + get_status_effect_list() accessors, UITheme.get_status_color(), BattleUI.compute_status_badges(). Enemy battler sprites now show status icons. 14 new tests (832 total).

### T-0088
- Title: Add visual markers for zone transitions (sparkle/arrow effects)
- Status: done
- Assigned: claude
- Completed: 2026-02-19
- Notes: ZoneMarker script-only Node2D with _draw() chevron arrow, alpha pulse + directional bob tweens, optional destination label. Integrated into all 3 scenes (4 exit triggers). 11 tests.

### T-0176
- Title: Reconcile BACKLOG.md — mark all COMPLETED.md tickets as done
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Notes: Updated 72 task statuses from todo/in-progress to done in BACKLOG.md. Added T-0177, T-0178, T-0179 to backlog. BACKLOG.md now accurately reflects project state: ~97 M0 tasks done, 9 remaining M0 todos, M1 tasks pending.

### T-0177
- Title: Wire SfxPriority.CRITICAL to combat death and crit SFX calls
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Notes: Added CRITICAL_PRIORITY_PATHS constant and compute_sfx_priority() static helper to SfxLibrary. Updated action_execute_state.gd and enemy_turn_state.gd — COMBAT_DEATH and COMBAT_CRITICAL_HIT use SfxPriority.CRITICAL; all others remain NORMAL. 8 tests (1478 total passing).

### T-0018
- Title: Build skill tree framework
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Notes: SkillTreeNodeData + SkillTreeData Resources; SkillTreeManager static utility with compute_can_unlock() + compute_unlock_result(); CharacterData gains skill_points/unlocked_skill_ids/skill_trees; LevelManager.level_up() awards 1 SP; stat_abbreviation() gains "sp" entry; 17 tests (1495 total passing).

### T-0179
- Title: Add interaction prompt near player for interactable objects (supersedes T-0113)
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Notes: InteractionHint static helper (compute_interaction_hint_text) looks up bound key via InputMap; player._update_interaction_prompt() called each physics frame after move_and_slide(); set_movement_enabled(false) hides prompt; fallback "[ ] Interact"; 5 tests (1500 total passing).

### T-0023
- Title: Implement camp/rest system
- Status: done
- Assigned: claude
- Completed: 2026-02-20
- Notes: CampMenuData pure static helper (compute_menu_options/compute_rest_message/compute_healing_needed); CampMenu script-only Control with Rest+Leave Camp buttons, pushes MENU state; CampStrategy Resource that instantiates and opens CampMenu via UILayer; 10 tests (1510 total passing).

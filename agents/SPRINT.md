# Current Sprint

Sprint: S03-demo-polish
Milestone: M0
Goal: Polish demo to professional quality — fix tilemaps, add battle backgrounds, integrate audio, align dialogue with story scripts, add navigation markers, refactor monolithic code into reusable components
Started: 2026-02-18

---

## Active

---

## Queue

### T-0094
- Title: Implement battle ability animations and visual effects
- Status: todo
- Assigned: unassigned
- Priority: medium
- Depends: none

### T-0095
- Title: Add battler idle animations in combat
- Status: todo
- Assigned: unassigned
- Priority: medium
- Depends: none

### T-0097
- Title: Add save point visual markers in scenes
- Status: todo
- Assigned: unassigned
- Priority: medium
- Depends: none

### T-0101
- Title: Implement party formation and swap UI in pause menu
- Status: todo
- Assigned: unassigned
- Priority: medium
- Depends: T-0020

### T-0057
- Title: Improve turn order display with current actor highlight
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: none

### T-0058
- Title: Add screen shake on heavy damage
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: none

### T-0061
- Title: Overgrown Ruins — separate debris layer and fix z-index ambiguity
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: none

### T-0077
- Title: Split verdant_forest.gd and overgrown_ruins.gd into tilemap/encounter/dialogue modules
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: T-0073

### T-0078
- Title: Create reusable asset loader helper with consistent null-check pattern
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: none

### T-0093
- Title: Add fragment tracker / compass UI for story objectives
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: T-0087

### T-0096
- Title: Add particle effects for healing, resonance, and criticals
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: T-0094

### T-0098
- Title: Add overworld encounter warning (grass rustle before battle)
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: none

### T-0099
- Title: Add transition animations between zones (beyond fade)
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: none

### T-0100
- Title: Add NPC idle animations (breathing, head turn, fidget)
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: none

### T-0102
- Title: Add minimap or compass to HUD
- Status: todo
- Assigned: unassigned
- Priority: low
- Depends: none

---

## Done This Sprint

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

# Backlog

All tickets not in the current sprint. Sorted by milestone, then priority.

---

## M0 — Foundation

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

### T-0020
- Title: Build party management UI
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0013
- Refs: docs/best-practices/08-ui-patterns.md
- Notes: View party members, stats, equipment. Swap active/reserve members. Focus navigation for gamepad support.

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
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: docs/game-design/06-audio-design.md, game/autoloads/audio_manager.gd
- Notes: AudioManager exists with crossfade but no audio files. Source BGM: Roothollow (peaceful village), Verdant Forest (mysterious/nature), Overgrown Ruins (tense/ancient). Search Time Fantasy packs and /Users/robles/repos/games/assets/ for audio. Copy to game/assets/audio/bgm/.

### T-0064
- Title: Integrate BGM playback into scene _ready() methods
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: T-0063
- Refs: game/autoloads/audio_manager.gd, game/scenes/roothollow/roothollow.gd, game/scenes/verdant_forest/verdant_forest.gd, game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: Add AudioManager.play_bgm() calls in each scene's _ready(). Crossfade between area themes on scene transition. Load tracks with null check.

### T-0065
- Title: Add battle music (standard encounters and boss)
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: T-0063
- Refs: game/autoloads/audio_manager.gd, game/autoloads/battle_manager.gd
- Notes: Play battle BGM when combat starts, restore area BGM when combat ends. 2 tracks: standard encounter + boss. Wire into BattleManager or battle_start_state.

### T-0066
- Title: Add UI sound effects (menu, dialogue, buttons)
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0063
- Refs: game/autoloads/audio_manager.gd, game/ui/dialogue/dialogue_box.gd
- Notes: SFX for: menu open/close, button hover/select, dialogue advance, choice select. Wire AudioManager.play_sfx() into UI scripts.

### T-0067
- Title: Add combat sound effects (attack, magic, heal, death)
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0063
- Refs: game/autoloads/audio_manager.gd, game/systems/battle/states/action_execute_state.gd
- Notes: SFX: physical attack hit, magic cast, healing chime, enemy death, critical hit, status effect apply, resonance overload. Wire into action_execute_state.gd.

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

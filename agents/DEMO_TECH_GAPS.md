# Demo Technical Gap Assessment

**Date:** 2026-02-16
**Auditor:** claude (tech-agent)
**Scope:** Full codebase audit — all `.gd` scripts, `.tscn` scenes, `.tres` data files
**Baseline:** 222 passing unit tests, 3 scenes, 6 autoloads, 9 resource classes

---

## Executive Summary

The codebase has a **solid battle system** and **clean architecture**, but is missing several systems critical for a playable demo: no inventory management, no save/load, no XP/leveling, no gold tracking, and NPC dialogue is single-line only. The battle system works mechanically but items cannot be used (not wired), status effects are name-only (no gameplay impact), and victory rewards are displayed but never applied.

**Critical gaps:** 6 | **High gaps:** 7 | **Medium gaps:** 5 | **Low gaps:** 4

---

## 1. Inventory System — CRITICAL

**Status:** Does not exist. No InventoryManager autoload, no inventory data structure anywhere.

**What exists:**
- `ItemData` resource class (`game/resources/item_data.gd`) — fully defined with type, effect, targeting, economy fields
- 5 item `.tres` files: potion, ether, antidote, phoenix_down, resonance_tonic (`game/data/items/`)
- `ChestStrategy` (`game/entities/interactable/strategies/chest_strategy.gd:11-17`) — displays "Obtained X!" message but **never adds item to any collection**
- `ItemPickupStrategy` (`game/entities/interactable/strategies/item_pickup_strategy.gd:10-19`) — same problem, displays message only
- `BattleAction.create_item()` exists (`game/resources/battle_action.gd:44-52`) — creates item actions but nothing feeds items into it

**What's missing:**
- `InventoryManager` autoload — needs: `add_item()`, `remove_item()`, `get_items()`, `has_item()`, `get_item_count()`
- Inventory data structure (Dictionary of item_id -> count, or Array of item stacks)
- Integration with `ChestStrategy` and `ItemPickupStrategy` to actually add items
- Integration with battle `ActionSelectState` to show item submenu from inventory
- Integration with `VictoryState` to add loot drops to inventory
- Pause menu item panel (`game/ui/pause_menu/pause_menu.gd:111-120`) — currently shows hardcoded "No items" placeholder

**Priority:** CRITICAL — Without inventory, chests/pickups are decorative, items can't be used in battle, and shops are impossible.

---

## 2. Battle Items Not Wired — CRITICAL

**Status:** Item command exists in battle UI but is never connected to actual item data.

**What exists:**
- Battle UI has an Item button (`game/ui/battle_ui/battle_ui.gd:39`) that emits `command_selected("item")`
- `PlayerTurnState` (`game/systems/battle/states/player_turn_state.gd:43`) routes "item" to `ActionSelectState`
- `ActionSelectState` (`game/systems/battle/states/action_select_state.gd:14-36`) — **only handles "skill" mode**, never enters "item" mode
- `ActionExecuteState._execute_item()` (`game/systems/battle/states/action_execute_state.gd:121-147`) — fully implemented for HEAL_HP and HEAL_EE effects
- `BattleUI.show_item_submenu()` (`game/ui/battle_ui/battle_ui.gd:139-153`) — fully implemented, ready to display items
- `BattleUI.item_selected` signal exists and `_on_item_selected` handler exists in `ActionSelectState` line 55-58

**What's missing:**
- `ActionSelectState.enter()` always sets `_mode = "skill"` and shows skill submenu — no code path ever sets `_mode = "item"` or calls `show_item_submenu()`
- Need to pass the previous command context ("skill" vs "item") into `ActionSelectState` so it knows which submenu to show
- Need to source items from the (nonexistent) InventoryManager
- Need to consume the item after use (remove from inventory)

**Priority:** CRITICAL — The "Item" button in battle does nothing useful. Players will click it and get skills instead.

---

## 3. XP/Leveling System — CRITICAL

**Status:** Does not exist. EXP is calculated and displayed in victory screen but never applied.

**What exists:**
- `EnemyData.exp_reward` field (`game/resources/enemy_data.gd:29`) — all 8 enemies have exp values
- `VictoryState` (`game/systems/battle/states/victory_state.gd:13-31`) — sums `total_exp` and displays it, but **never calls any level-up function**
- `CharacterData` has growth rates (`game/resources/character_data.gd:7-14`) — hp_growth, attack_growth, etc. — but no code reads them
- `BattlerData` has base stats (`game/resources/battler_data.gd:13-20`) — these are fixed values, no level scaling

**What's missing:**
- Level field on `CharacterData` or a separate progression tracker
- XP accumulation system (autoload or per-character)
- Level-up formula (XP thresholds per level)
- Stat growth application using `CharacterData` growth rates
- Level-up notification/UI
- `VictoryState` integration to distribute XP to living party members
- `Battler._load_stats_from_data()` (`game/systems/battle/battler.gd:279-290`) needs to apply level-based scaling

**Priority:** CRITICAL — Characters never get stronger. After 10 battles the demo becomes repetitive with zero progression.

---

## 4. Gold/Economy System — CRITICAL

**Status:** Gold is displayed but never tracked or awarded.

**What exists:**
- `EnemyData.gold_reward` field — all enemies have gold values
- `VictoryState` sums `total_gold` and displays in UI
- `HUD.set_gold()` (`game/ui/hud/hud.gd:48-50`) — ready to display gold amount
- `ItemData` has `buy_price` and `sell_price` fields
- HUD has a `_gold_label` that shows "Gold: 0"

**What's missing:**
- No gold variable stored anywhere persistent — no autoload, no GameManager field, nothing
- `VictoryState` displays gold but never adds it to any wallet
- No shop system (needed for Roothollow shopkeeper NPC)
- HUD gold is hardcoded to 0, never updated

**Priority:** CRITICAL — Gold rewards are meaningless, shops impossible, economy is purely cosmetic.

---

## 5. Save/Load System — CRITICAL

**Status:** Save point exists but does nothing. Continue button on title screen checks for `user://save.dat` but nothing creates it.

**What exists:**
- `SavePointStrategy` (`game/entities/interactable/strategies/save_point_strategy.gd:9-13`) — displays "Progress saved." message but **does not save anything**
- `EventFlags` has `get_all_flags()` and `load_flags()` (`game/events/event_flags.gd:21-26`) — ready for serialization
- `TitleScreen._check_save_data()` (`game/ui/title_screen/title_screen.gd:47-49`) — checks `user://save.dat` existence to enable Continue button
- Continue button's `_on_continue_pressed()` (`game/ui/title_screen/title_screen.gd:73-74`) — emits signal but **loads nothing**

**What's missing:**
- Save file format definition (what data to persist)
- Save function: serialize event flags, party roster, character levels/XP, inventory, gold, current scene, player position
- Load function: deserialize and restore all game state
- `SavePointStrategy.execute()` needs to actually call the save function
- `TitleScreen._on_continue_pressed()` needs to load save data and transition to the saved scene
- Error handling for corrupt/missing save files

**Priority:** CRITICAL — Players lose all progress on death or quit. The save point in Roothollow is a lie.

---

## 6. Persistent Character State — CRITICAL

**Status:** Characters have no persistent HP/EE between battles.

**What exists:**
- `Battler` tracks `current_hp`, `current_ee` during battle, but these are initialized from `data.max_hp/max_ee` every time
- `Battler.initialize_from_data()` (`game/systems/battle/battler.gd:77-88`) resets HP/EE to full on every battle start
- `PartyManager` stores `Resource` references (CharacterData) but these are static data with no mutable state
- Roothollow innkeeper has a TODO: `# TODO: Heal party HP/EE once persistent character state is added` (`game/scenes/roothollow/roothollow.gd:188`)

**What's missing:**
- Mutable character state layer (current HP, current EE, current level, current XP) separate from static `CharacterData`
- `BattleManager` should save post-battle HP/EE back to persistent state
- Innkeeper heal should actually restore persistent HP/EE
- HUD party display (`game/ui/hud/hud.gd:69-76`) shows max values as current (line 76: `hp_bar.value = max_val`)

**Priority:** CRITICAL — Without this, every battle starts at full HP. Healing items are useless. Resource management is nonexistent.

---

## 7. NPC Dialogue System Limitations — HIGH

**Status:** Functional but extremely basic. Single-line flat dialogue only.

**What exists:**
- `DialogueManager` autoload with full signal system (started, ended, line_displayed, choices)
- `DialogueLine` resource with speaker, text, portrait, choices array
- `DialogueBox` UI with typewriter effect, portrait display, choice buttons, slide animation
- `NPC` class (`game/entities/npc/npc.gd`) — converts `dialogue_lines: Array[String]` to DialogueLine objects
- Choice system is fully implemented (select_choice, choice_presented signal, UI buttons)

**What's missing:**
- NPC dialogue is `Array[String]` — no branching, no conditions, no multi-visit variation
- No flag-conditional dialogue (e.g., different text before/after Lyra discovery)
- No callback system for dialogue outcomes (e.g., "Yes" to shop opens shop UI)
- Dialogue has no speaker portraits loaded — NPC `portrait_path` is exported but no NPC instances set it
- No dialogue tree / conversation flow beyond linear sequences
- No way to trigger events from dialogue choices (choice_selected signal exists but nothing listens to results)
- No "talked to" tracking for NPCs

**Priority:** HIGH — NPCs are the core interaction in a JRPG town. Single-line dialogue makes Roothollow feel lifeless.

---

## 8. Status Effects — HIGH

**Status:** Name-only system. Effects are tracked but have zero gameplay impact.

**What exists:**
- `Battler.apply_status_effect(effect: StringName)` — adds name to array, emits signal
- `Battler.remove_status_effect()` / `has_status_effect()` — basic CRUD
- `AbilityData.status_effect: String` and `status_chance: float` — abilities can specify status application
- `ActionExecuteState._try_apply_status()` — rolls chance and applies
- Visual: `PartyBattlerScene._on_status_applied()` creates a 2-character abbreviation label

**What's missing:**
- No status effect definitions (what does "poison" actually do? How much damage per turn?)
- No per-turn processing (status effects never tick — no poison damage, no paralysis skip, no regen heal)
- `TurnEndState` (`game/systems/battle/states/turn_end_state.gd`) does NOT process status effects at all
- No status duration or removal logic (effects last forever once applied)
- No status immunity checking
- `ItemData.EffectType.CURE_STATUS` exists but is never handled in `ActionExecuteState._execute_item()`
- Only HEAL_HP and HEAL_EE are implemented in `_execute_item()` (line 128-147)

**Priority:** HIGH — Without working status effects, abilities like poison/stun are broken. The antidote item is useless.

---

## 9. Victory Rewards Not Applied — HIGH

**Status:** Victory screen shows EXP, gold, and items but none are applied to game state.

**What exists:**
- `VictoryState.enter()` (`game/systems/battle/states/victory_state.gd:12-35`) — calculates totals, rolls loot drops, shows UI
- `BattleUI.show_victory()` — displays rewards

**What's missing:**
- EXP never distributed to party (requires leveling system — gap #3)
- Gold never added to wallet (requires economy system — gap #4)
- Dropped items never added to inventory (requires inventory — gap #1)
- Victory screen auto-dismisses after 2.0 seconds with no player input — should wait for button press

**Priority:** HIGH — All battle rewards are purely cosmetic. This is the convergence point of gaps #1, #3, and #4.

---

## 10. Elemental Weakness/Resistance System — HIGH

**Status:** Data exists but is never checked during damage calculation.

**What exists:**
- `EnemyData.weaknesses: Array[Element]` and `resistances: Array[Element]` — all enemies have these set in `.tres` files
- `AbilityData.element: Element` — abilities have elemental typing
- Element enums defined in `AbilityData`, `EnemyData`, and `EchoData` (duplicated — see note)

**What's missing:**
- `Battler.take_damage()` and `Battler.deal_damage()` have NO elemental parameter — element is never passed through the damage pipeline
- No weakness multiplier (e.g., 1.5x) or resistance reduction (e.g., 0.5x)
- No UI indicator for weakness hits ("Super Effective!") or resisted hits
- Element enums are duplicated across 3 files — should be a shared enum

**Priority:** HIGH — Weaknesses are a core JRPG mechanic. Without them, all abilities are functionally identical in damage type.

---

## 11. Opening Sequence Flow — HIGH

**Status:** Works but has no guard rails for demo flow.

**What exists:**
- `OpeningSequence` (`game/events/opening_sequence.gd`) — triggers Lyra discovery dialogue in Overgrown Ruins
- `IrisRecruitment` (`game/events/iris_recruitment.gd`) — triggers in Verdant Forest with forced battle
- `GarrickRecruitment` (`game/events/garrick_recruitment.gd`) — triggers in Roothollow after both previous flags set
- Recruitment order enforced: Lyra first, then Iris, then Garrick (checked via EventFlags)

**What's missing:**
- Game starts in Overgrown Ruins with just Kael, but there's no tutorial or guidance text
- No hint system pointing player toward Lyra discovery zone
- No visual indicator for NPCs/areas the player should visit
- After opening sequence, no story direction — player must discover the correct area flow on their own
- No "quest log" or objective tracker for demo
- `GarrickRecruitment` requires both `opening_lyra_discovered` AND `iris_recruited` — if player goes to Roothollow before forest, Garrick is invisible with no explanation

**Priority:** HIGH — Players will get lost without guidance. Demo needs a clear critical path.

---

## 12. Pause Menu Item/Status Panels — MEDIUM

**Status:** Partially functional. Party panel works, item panel is placeholder, status panel is empty.

**What exists:**
- `PauseMenu` (`game/ui/pause_menu/pause_menu.gd`) — opens/closes, pauses tree, has 4 tabs
- Party panel (`_refresh_party_panel`, line 95-108) — shows member names and static stats
- Item panel (`_refresh_item_panel`, line 111-120) — hardcoded "No items" placeholder
- Status panel — exists in UI but `_show_panel("status")` shows `%StatusPanel` with no content generation

**What's missing:**
- Item panel needs InventoryManager integration (gap #1)
- Status panel has no content — should show detailed character stats, equipment, abilities
- Party panel shows `max_hp/max_hp` for HP (not current/max) — no persistent state to show
- No equipment system (not needed for demo but status panel is misleading without it)
- Quit button goes to title screen but doesn't warn about unsaved progress

**Priority:** MEDIUM — Pause menu is accessible but two of its three content panels are empty.

---

## 13. Echo Fragment System — MEDIUM

**Status:** Data class exists but system is not implemented.

**What exists:**
- `EchoData` resource (`game/resources/echo_data.gd`) — fully defined with rarity, type, effect, element, uses_per_battle
- 4 echo `.tres` files in `game/data/echoes/` (burning_village, childs_laughter, mothers_comfort, soldiers_fear)
- `PartyBattler.equipped_echoes: Array[Resource]` (`game/systems/battle/party_battler.gd:10`) — field exists but never populated

**What's missing:**
- No echo inventory/collection system
- No echo equip/unequip UI
- No echo activation in battle (no "Echo" command in battle menu)
- No integration with battle damage/effects
- Echoes are a signature mechanic per design docs — absence makes combat feel generic

**Priority:** MEDIUM — Core to the Resonance system identity, but demo can work without it if other combat is solid.

---

## 14. Audio — MEDIUM

**Status:** System works but no audio content.

**What exists:**
- `AudioManager` autoload (`game/autoloads/audio_manager.gd`) — fully functional BGM player with crossfade, SFX pool of 8 players
- Bus routing to "BGM" and "SFX" buses

**What's missing:**
- No BGM files loaded or played anywhere — all scenes are silent
- No SFX for: battle attacks, damage hits, healing, victory, defeat, dialogue advance, menu navigation, door transitions, encounter trigger
- No audio buses configured in Godot (BGM/SFX buses referenced but may not exist in default_bus_layout.tres)
- Title screen has no music
- Battle has no music

**Priority:** MEDIUM — Game is completely silent. Audio dramatically impacts demo feel but is functional without it.

---

## 15. Scene Transitions & Polish — MEDIUM

**Status:** Work correctly but lack visual polish.

**What exists:**
- `GameManager.change_scene()` with fade-to-black transitions
- Spawn point system via groups — works for all 3 scene transitions
- `BattleManager` saves and restores player position after battle

**What's missing:**
- No encounter flash/animation before battle (just instant fade)
- No battle transition effect (spiral, shatter, etc.)
- Camera limits only set in Overgrown Ruins — missing in Verdant Forest and Roothollow
- No area name popup when entering a new zone

**Priority:** MEDIUM — Transitions work but feel abrupt. Polish item.

---

## 16. Defeat Handling — MEDIUM

**Status:** Shows game over screen but recovery path is weak.

**What exists:**
- `DefeatState` shows defeat screen with Retry and Quit buttons
- Retry reloads current scene, Quit goes to title

**What's missing:**
- Retry reloads the battle scene (`current.scene_file_path` is the battle scene) which would re-trigger BattleManager in a broken state
- No "load last save" option (requires save system — gap #5)
- No graceful state cleanup on defeat — GameManager state stack may not be properly unwound
- Party state after defeat is undefined

**Priority:** MEDIUM — Defeat path may crash or softlock. Needs testing.

---

## 17. NPC Walk Animations — LOW

**Status:** NPCs are static sprites.

**What exists:**
- `NPC` class uses `Sprite2D` (not `AnimatedSprite2D`)
- NPCs flip horizontally to face player on interaction
- Player has full 4-directional walk/idle animations

**What's missing:**
- NPCs have no idle animation (breathing, bobbing)
- NPCs have no walk animation (can't move/patrol)
- NPC visual scene (`game/entities/npc/npc.tscn`) — Sprite2D only

**Priority:** LOW — Static NPCs are acceptable for a demo. Nice to have.

---

## 18. Battle VFX — LOW

**Status:** Minimal tween animations only.

**What exists:**
- Attack lunge animation (step forward, snap back)
- Damage flash (white -> red -> recoil)
- Heal flash (green tint)
- Defeat fade-out
- Floating damage numbers

**What's missing:**
- No spell/ability VFX (fire, ice, etc.) — all abilities look identical to basic attacks
- No particle effects
- `AbilityData.animation_name` field exists but is never used
- `pixel_animations_gfxpack` asset pack has battle VFX sprites available but unused

**Priority:** LOW — Tween animations are functional. Spell VFX would significantly improve feel but aren't blocking.

---

## 19. Resonance Gauge Overload Resolution — LOW

**Status:** Overload state works but HOLLOW recovery is missing.

**What exists:**
- Full resonance gauge system: FOCUSED -> RESONANT -> OVERLOAD -> HOLLOW
- Resonance gain from damage dealt/taken/defending
- Overload doubles outgoing and incoming damage
- HOLLOW blocks all abilities and halves defense
- If defeated in OVERLOAD, transitions to HOLLOW

**What's missing:**
- No mechanic to exit HOLLOW state (stays forever once entered)
- No turn-based resonance decay
- No "Release" command to intentionally trigger Overload burst
- Design doc specifies HOLLOW should be temporary (recovers after X turns)

**Priority:** LOW — The resonance system works for its core loop. Recovery mechanic is a balance concern.

---

## 20. Duplicate Element Enums — LOW

**Status:** Element enum defined in 3 separate places.

**Locations:**
- `AbilityData.Element` (`game/resources/ability_data.gd:19-28`)
- `EnemyData.Element` (`game/resources/enemy_data.gd:14-23`)
- `EchoData.Element` (`game/resources/echo_data.gd:29-38`)

**Impact:** If one is modified, others become inconsistent. Should be unified into a shared enum (e.g., `game/resources/enums.gd` or a shared autoload).

**Priority:** LOW — Works fine now, but will cause bugs when elemental system is implemented.

---

## Data File Inventory

### Characters (3)
| File | Has Abilities | Has Portrait | Has Battle Sprite |
|------|:---:|:---:|:---:|
| kael.tres | Yes (echo_strike, resonance_pulse) | Yes | Yes |
| iris.tres | Yes (emp_burst, purifying_light) | Yes | Yes |
| garrick.tres | Yes (heavy_strike, guardians_stand) | Yes | Yes |

### Enemies (8)
| File | Has Abilities | Has Weaknesses | Has Loot |
|------|:---:|:---:|:---:|
| creeping_vine.tres | No | Yes | Yes |
| ash_stalker.tres | No | Yes | Yes |
| memory_bloom.tres | No | Yes | Yes |
| hollow_specter.tres | No | Yes | Yes |
| ancient_sentinel.tres | No | Yes | Yes |
| gale_harpy.tres | No | Yes | Yes |
| ember_hound.tres | No | Yes | Yes |
| cinder_wisp.tres | No | Yes | Yes |

**Note:** No enemies have abilities assigned — all enemies only use basic attacks.

### Items (5)
| File | Type | Effect | Usable in Battle |
|------|------|--------|:---:|
| potion.tres | Consumable | Heal HP 50 | Yes |
| ether.tres | Consumable | Heal EE 30 | Yes |
| antidote.tres | Consumable | Cure Status | Yes |
| phoenix_down.tres | Consumable | Revive | Yes |
| resonance_tonic.tres | Consumable | Buff | Yes |

### Abilities (7)
All abilities are assigned to characters. 0 abilities assigned to enemies.

### Echoes (4)
All exist as data but are unreachable in-game.

---

## Architecture Notes

**Well-architected systems (no changes needed):**
- State machine pattern (StateMachine + State base classes)
- Battle state machine flow (BattleStart -> TurnQueue -> PlayerTurn/EnemyTurn -> ActionExecute -> TurnEnd -> loop)
- Encounter system (step-based, weighted pools)
- MapBuilder utility (text-based tilemap generation)
- InteractionStrategy pattern (extensible interactable types)
- DialogueManager signal-based architecture
- GameManager state stack with fade transitions

**Code quality:** Clean, consistent GDScript style. Static typing used throughout. Proper null checks. No obvious bugs in existing code.

---

## Priority Summary

| Priority | Count | Gaps |
|----------|-------|------|
| CRITICAL | 6 | Inventory (#1), Battle Items (#2), XP/Leveling (#3), Gold (#4), Save/Load (#5), Persistent State (#6) |
| HIGH | 5 | NPC Dialogue (#7), Status Effects (#8), Victory Rewards (#9), Elemental System (#10), Opening Flow (#11) |
| MEDIUM | 5 | Pause Menu (#12), Echo System (#13), Audio (#14), Transitions (#15), Defeat Handling (#16) |
| LOW | 4 | NPC Animations (#17), Battle VFX (#18), Resonance Recovery (#19), Duplicate Enums (#20) |

### Recommended Implementation Order

1. **Persistent Character State** (#6) — foundation for everything else
2. **Gold/Wallet** (#4) — simple, unblocks economy
3. **Inventory Manager** (#1) — unblocks items, shops, chests
4. **Battle Items Wiring** (#2) — connects inventory to battle
5. **XP/Leveling** (#3) — progression system
6. **Victory Rewards Application** (#9) — ties 1-5 together
7. **Save/Load** (#5) — persistence layer
8. **NPC Dialogue Enhancement** (#7) — town content quality
9. **Status Effects** (#8) — combat depth
10. **Elemental System** (#10) — combat variety

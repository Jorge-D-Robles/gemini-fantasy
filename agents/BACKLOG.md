# Backlog

All tickets not in the current sprint. Sorted by milestone, then priority.

---

## M0 — Foundation

### T-0001
- Title: Add class_name declarations to all autoload scripts
- Status: wontfix
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/project.godot, docs/best-practices/03-autoloads-and-singletons.md
- Notes: INVALID — Godot autoloads cannot have class_name (conflicts with the autoload singleton name). Reverted. Autoloads are already globally accessible by their registered name.
- Completed: 2026-02-16

### T-0002
- Title: Extract TurnQueue into its own scene
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battle_scene.tscn, docs/best-practices/01-scene-architecture.md
- Notes: Migrated from ISSUES_TRACKER [HIGH]. TurnQueue is a child node with a script attached directly in the main scene. Violates "one script per scene" rule.
- Completed: 2026-02-16

### T-0003
- Title: Refactor Interactable into composition pattern
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/entities/interactable/interactable.gd, docs/best-practices/01-scene-architecture.md
- Notes: Migrated from ISSUES_TRACKER [HIGH]. Single script handles all interaction types via match statement. Refactored to strategy pattern with InteractionStrategy Resource + 5 concrete strategies.
- Completed: 2026-02-16

### T-0004
- Title: Replace Dictionary-based dialogue/encounter data with custom Resources
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: game/autoloads/dialogue_manager.gd, game/systems/encounter/encounter_system.gd, docs/best-practices/04-resources-and-data.md
- Notes: Migrated from ISSUES_TRACKER [HIGH]. Created DialogueLine and EncounterPoolEntry Resource classes. Updated all callers.
- Completed: 2026-02-16

### T-0005
- Title: Replace meta-based state communication with typed BattleAction
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/states/action_execute_state.gd, game/resources/battle_action.gd
- Notes: Migrated from ISSUES_TRACKER [MEDIUM]. Added current_action: BattleAction to BattleScene. All states now use typed property instead of meta. Zero get_meta/set_meta remaining.
- Completed: 2026-02-16

### T-0006
- Title: Use AnimatedSprite2D for player animation
- Status: done
- Assigned: claude
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/entities/player/player.gd, docs/best-practices/05-node-lifecycle.md
- Notes: Migrated from ISSUES_TRACKER [MEDIUM]. Replaced Sprite2D + manual frame math with AnimatedSprite2D + programmatic SpriteFrames. 8 animations created.
- Completed: 2026-02-16

### T-0007
- Title: Wire unconnected signals to EventBus or QuestManager
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0016
- Refs: game/entities/player/player.gd, game/entities/interactable/interactable.gd, game/entities/npc/npc.gd
- Notes: Migrated from ISSUES_TRACKER [MEDIUM]. Signals like interacted_with are emitted but never connected.

### T-0008
- Title: Replace has_method/has_signal with proper typing in autoloads
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: T-0001
- Refs: game/autoloads/battle_manager.gd, game/autoloads/dialogue_manager.gd
- Notes: Migrated from ISSUES_TRACKER [WARNING]. Uses duck-typing instead of specific class types.

### T-0009
- Title: Implement party healing at rest points in Roothollow
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: none
- Refs: game/scenes/roothollow/roothollow.gd
- Notes: Migrated from ISSUES_TRACKER [TODO]. Placeholder comment for party healing logic. Implement HP/EE restoration at resting points.

### T-0010
- Title: Add return type hints to all methods
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/entities/battle/enemy_battler.gd, game/systems/battle/battle_scene.gd, game/autoloads/battle_manager.gd, game/autoloads/game_manager.gd, game/ui/battle_ui/battle_ui.gd, game/entities/player/player.gd
- Notes: Migrated from ISSUES_TRACKER [STYLE]. Numerous methods missing explicit -> void or return type hints.

### T-0011
- Title: Add doc comments to signals and public methods
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: game/systems/battle/battle_scene.gd, game/systems/battle/battler.gd
- Notes: Migrated from ISSUES_TRACKER [STYLE]. Many signals and public methods lack ## doc comments.

### T-0012
- Title: Build inventory system
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: docs/game-design/01-core-mechanics.md, game/resources/item_data.gd, docs/best-practices/03-autoloads-and-singletons.md
- Notes: InventoryManager autoload. Add/remove/use items. Stack management. ItemData already exists as Resource class.
- Completed: 2026-02-16

### T-0013
- Title: Build equipment system
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: T-0012
- Refs: docs/game-design/01-core-mechanics.md, game/resources/character_data.gd
- Notes: EquipmentData Resource class. Equip/unequip with stat modifiers. Weapon, armor, accessory slots per character.
- Completed: 2026-02-16

### T-0014
- Title: Build save/load system
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: T-0012
- Refs: docs/best-practices/09-save-load.md, docs/IMPLEMENTATION_GUIDE.md
- Notes: Done as T-0032. SaveManager autoload with JSON serialization.
- Completed: 2026-02-16

### T-0015
- Title: Implement Resonance gauge UI and overload/hollow mechanics
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: docs/game-design/01-core-mechanics.md, game/resources/battler_data.gd
- Notes: Visual gauge in battle UI. Overload state (100%+): 2x damage dealt/taken. Hollow state on KO during overload: -50% all stats. Cure items/abilities needed.

### T-0016
- Title: Build quest tracking system
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: docs/game-design/04-side-quests.md, docs/best-practices/03-autoloads-and-singletons.md
- Notes: QuestManager autoload. QuestData Resource class. Accept/progress/complete quests. Objective tracking. Journal UI (separate ticket).

### T-0017
- Title: Implement status effect system
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: none
- Refs: docs/game-design/01-core-mechanics.md, game/systems/battle/battler.gd
- Notes: StatusEffect Resource class. Apply/tick/expire effects. Buff/debuff/DoT/HoT. Visual indicators on battlers. Integrates with turn processing.

### T-0018
- Title: Build skill tree framework
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0019
- Refs: docs/mechanics/character-abilities.md, game/resources/ability_data.gd
- Notes: SkillTreeData Resource. Unlock nodes with skill points on level up. Character-specific trees per design doc.

### T-0019
- Title: Implement leveling and XP system
- Status: done
- Assigned: claude
- Priority: high
- Milestone: M0
- Depends: none
- Refs: docs/game-design/01-core-mechanics.md, game/resources/character_data.gd
- Notes: XP gain from battles. Level-up stat growth. Skill points awarded. XP curve balancing. Victory screen XP display.
- Completed: 2026-02-16

### T-0020
- Title: Build party management UI
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0013
- Refs: docs/best-practices/08-ui-patterns.md
- Notes: View party members, stats, equipment. Swap active/reserve members. Focus navigation for gamepad support.

### T-0021
- Title: Build inventory UI
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0012, T-0013
- Refs: docs/best-practices/08-ui-patterns.md
- Notes: Item list with categories. Use/equip items. Item descriptions. Stack display. Focus navigation.

### T-0022
- Title: Build shop system
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0012
- Refs: docs/game-design/01-core-mechanics.md
- Notes: ShopData Resource. Buy/sell with gold. Price modifiers. Shop UI with item comparison.

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
- Notes: BondData Resource. Affinity tracking between characters. Bond events at camp. Stat bonuses from high affinity.

### T-0026
- Title: Build debug console
- Status: todo
- Assigned: unassigned
- Priority: low
- Milestone: M0
- Depends: none
- Refs: docs/IMPLEMENTATION_GUIDE.md
- Notes: Toggle with ~ key. Commands: add_item, set_level, heal_all, unlock_echo, teleport, start_battle. Overlay UI.

### T-0027
- Title: Implement party HP/EE persistence between battles
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M0
- Depends: none
- Refs: game/autoloads/party_manager.gd, game/systems/battle/battle_scene.gd
- Notes: Track runtime HP/EE state on PartyManager. Battle start reads persistent state, battle end writes back. Required for demo — without this, combat has zero stakes.

### T-0028
- Title: Wire item usage in battle
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M0
- Depends: T-0012
- Refs: game/systems/battle/states/action_select_state.gd, game/ui/battle_ui/battle_ui.gd
- Notes: Item button opens inventory submenu. Select item → select target → consume and apply effect. action_execute_state.gd has _execute_item() but ActionSelect never routes to it.

### T-0029
- Title: Implement innkeeper healing with persistent HP/EE
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M0
- Depends: T-0027
- Refs: game/scenes/roothollow/roothollow.gd
- Notes: Innkeeper interaction restores all party members to full HP/EE via persistent state.

### T-0030
- Title: Build battle victory rewards screen
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M0
- Depends: T-0012
- Refs: game/systems/battle/states/victory_state.gd, game/resources/enemy_data.gd
- Notes: Display gold earned, items dropped (loot table rolls), XP earned (display only). Add gold and items to InventoryManager.

### T-0031
- Title: Add NPC entities and dialogue content to Roothollow
- Status: todo
- Assigned: unassigned
- Priority: critical
- Milestone: M0
- Depends: none
- Refs: docs/game-design/demo-npc-content.md, game/scenes/roothollow/roothollow.gd
- Notes: Add 4-6 NPC StaticBody2D nodes. Flag-reactive dialogue based on story progress. Each NPC needs 3-8 lines of lore-appropriate dialogue.

### T-0032
- Title: Build basic save/load system
- Status: todo
- Assigned: unassigned
- Priority: high
- Milestone: M0
- Depends: T-0027, T-0012
- Refs: docs/best-practices/09-save-load.md, game/entities/interactable/strategies/save_point_strategy.gd
- Notes: SaveManager autoload. Serialize party, flags, scene, HP/EE, inventory, gold. Wire save_point_strategy. Load from title screen.

### T-0033
- Title: Add demo conclusion event
- Status: todo
- Assigned: unassigned
- Priority: medium
- Milestone: M0
- Depends: T-0031
- Refs: game/events/, game/autoloads/event_flags.gd
- Notes: After Garrick recruited, Elder Rowan NPC triggers conclusion dialogue hinting at Prismfall and the full game.

### T-0034
- Title: BUG — Dialogue and encounter can overlap in same frame
- Status: done
- Assigned: claude
- Priority: critical
- Milestone: M0
- Depends: none
- Refs: game/autoloads/battle_manager.gd, game/autoloads/dialogue_manager.gd, game/scenes/overgrown_ruins/overgrown_ruins.gd
- Notes: When player enters Lyra discovery zone and an encounter triggers in the same physics frame, both dialogue and battle start simultaneously. Fix: guard BattleManager.start_battle() against active dialogue/non-OVERWORLD state, and guard scene encounter handlers.
- Started: 2026-02-16
- Completed: 2026-02-16

---

## M1 — Act I: The Echo Thief

(Tickets will be created when M0 nears completion and M1 sprint planning begins.)

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

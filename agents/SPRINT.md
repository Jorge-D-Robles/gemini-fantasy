# Current Sprint

Sprint: S02-demo
Milestone: M0
Goal: Build the first playable demo — 3 areas, NPC dialogue, inventory, battle rewards, HP persistence
Started: 2026-02-16

---

## Active

(No tasks currently in progress — claim from Queue below.)

---

## Queue

### T-0027
- Title: Implement party HP/EE persistence between battles
- Priority: critical
- Depends: none
- Refs: game/autoloads/party_manager.gd, game/systems/battle/battle_scene.gd, game/resources/character_data.gd
- Notes: Currently party members always start battles at full HP/EE. Must track runtime HP/EE state on PartyManager (not CharacterData, which is the template). Battle start reads from persistent state, battle end writes back. Innkeeper healing (T-0029) depends on this. Without this, combat has zero stakes.
- Size: M

### T-0012
- Title: Build inventory system
- Priority: critical
- Depends: none
- Refs: game/resources/item_data.gd, docs/best-practices/03-autoloads-and-singletons.md, agents/DEMO_REQUIREMENTS.md
- Notes: InventoryManager autoload. Add/remove/query/use items. Stack management. Starting inventory (3x Potion, 1x Ether). Gold tracking. Required for battle items (T-0028) and loot drops (T-0030).
- Size: M

### T-0028
- Title: Wire item usage in battle
- Priority: critical
- Depends: T-0012
- Refs: game/systems/battle/states/action_select_state.gd, game/systems/battle/states/action_execute_state.gd, game/ui/battle_ui/battle_ui.gd
- Notes: Item button in battle UI opens inventory submenu. Player selects item → selects target → item is consumed and effect applied. ItemData already has EffectType (HEAL_HP, HEAL_EE). action_execute_state.gd already has _execute_item() but ActionSelect never routes to it. Must wire the full flow.
- Size: M

### T-0029
- Title: Implement innkeeper healing with persistent HP/EE
- Priority: critical
- Depends: T-0027
- Refs: game/scenes/roothollow/roothollow.gd, game/autoloads/party_manager.gd
- Notes: Innkeeper interaction restores all party members to full HP/EE using the persistent state from T-0027. Currently shows placeholder dialogue. Needs to actually modify the runtime HP/EE state so subsequent battles reflect the heal.
- Size: S

### T-0030
- Title: Build battle victory rewards screen
- Priority: critical
- Depends: T-0012
- Refs: game/systems/battle/states/victory_state.gd, game/ui/battle_ui/battle_ui.gd, game/resources/enemy_data.gd
- Notes: After battle victory, display: gold earned (sum of enemy gold_reward), items dropped (roll against enemy loot_table), XP earned (sum of exp_reward, display only for now). Add gold to InventoryManager. Add dropped items to InventoryManager. Brief 2-3 second display before transition.
- Size: M

### T-0031
- Title: Add NPC entities and dialogue content to Roothollow
- Priority: critical
- Depends: none
- Refs: docs/game-design/demo-npc-content.md, game/scenes/roothollow/roothollow.tscn, game/scenes/roothollow/roothollow.gd, game/entities/npc/npc.gd
- Notes: Add 4-6 NPC StaticBody2D nodes to Roothollow scene. Each needs dialogue lines from the content doc. Flag-reactive dialogue: NPCs say different things based on story flags (opening_lyra_discovered, iris_recruited, garrick_recruited). Must use DialogueLine resource and DialogueManager.
- Size: M

### T-0019
- Title: Implement leveling and XP system
- Priority: high
- Depends: none
- Refs: docs/game-design/01-core-mechanics.md, game/resources/character_data.gd, game/autoloads/party_manager.gd
- Notes: XP gain from battles. Level-up stat growth using CharacterData.growth_rates. Skill points awarded. XP curve. Victory screen XP integration. Level-up notification in battle victory.
- Size: M

### T-0032
- Title: Build basic save/load system
- Priority: high
- Depends: T-0027, T-0012
- Refs: docs/best-practices/09-save-load.md, game/entities/interactable/strategies/save_point_strategy.gd
- Notes: SaveManager autoload. Serialize: party roster, event flags, current scene + player position, persistent HP/EE, inventory, gold. save_point_strategy already exists as InteractionStrategy — wire it to SaveManager. Load from title screen. File-based with user://saves/.
- Size: L

### T-0033
- Title: Add demo conclusion event
- Priority: medium
- Depends: T-0031
- Refs: game/events/, game/autoloads/event_flags.gd
- Notes: After Garrick is recruited, Elder Rowan NPC gets new flag-reactive dialogue: "The Council at Prismfall must hear about this Conscious Echo. The road south is dangerous, but you have allies now..." Brief 4-5 line conversation that gives narrative closure and hooks the full game.
- Size: S

---

## Done This Sprint

(Carried over from S01)

### T-0020
- Title: Battle system state persistence, real-time UI sync, and visual feedback
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0001
- Title: Add class_name declarations to all autoload scripts
- Status: wontfix
- Assigned: claude
- Notes: INVALID — Godot autoloads cannot have class_name; causes "hides autoload singleton" error. Reverted.
- Completed: 2026-02-16

### T-0002
- Title: Extract TurnQueue into its own scene
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0003
- Title: Refactor Interactable into composition pattern
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0004
- Title: Replace Dictionary-based dialogue/encounter data with custom Resources
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0005
- Title: Replace meta-based state communication with typed BattleAction
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0006
- Title: Use AnimatedSprite2D for player animation
- Status: done
- Assigned: claude
- Completed: 2026-02-16

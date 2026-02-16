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

### T-0027
- Title: Implement party HP/EE persistence between battles
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0012
- Title: Build inventory system
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0028
- Title: Wire item usage in battle
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0029
- Title: Implement innkeeper healing with persistent HP/EE
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0030
- Title: Build battle victory rewards screen
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0031
- Title: Add NPC entities and dialogue content to Roothollow
- Status: done
- Assigned: claude
- Completed: 2026-02-16

### T-0019
- Title: Implement leveling and XP system
- Status: done
- Assigned: claude
- Completed: 2026-02-16

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

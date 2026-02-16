# Gemini Fantasy Issues Tracker

This file tracks technical debt, bugs, and architectural issues identified during code reviews. Agents MUST check this file before starting work on a system and update it after performing reviews.

## Battle System

### [CRITICAL] Loose Typing in Battler/EnemyBattler
- **File:** `game/systems/battle/battler.gd`
- **Issue:** `data` property is typed as `Resource` instead of a specific base class, requiring frequent `in` checks.
- **Fix:** Create a base `BattlerData` resource and inherit `CharacterData`/`EnemyData` from it. Use the specific type for the `data` variable.

### [CRITICAL] Dictionary-based Action Passing
- **File:** `game/systems/battle/enemy_battler.gd`
- **Issue:** `choose_action` returns a loose `Dictionary`. This is error-prone and lacks IDE autocompletion/type safety.
- **Fix:** Implement a `BattleAction` RefCounted or Resource class to encapsulate action data.

### [WARNING] Hardcoded Battle Positions
- **File:** `game/systems/battle/battle_scene.gd`
- **Issue:** Spawn positions for party and enemies are hardcoded in arrays.
- **Fix:** Use `Marker2D` nodes in the `battle_scene.tscn` or exported arrays of positions.

### [WARNING] Magic Numbers in Damage Formulas
- **File:** `game/systems/battle/battler.gd`
- **Issue:** Multipliers like `200.0`, `0.5`, `2.0` are hardcoded in `_calculate_incoming_damage`.
- **Fix:** Move these to named constants at the top of the file.

### [STYLE] Missing Return Type
- **File:** `game/systems/battle/turn_queue.gd`
- **Issue:** `_compare_by_delay` is missing a return type hint.
- **Fix:** Add `-> bool`.

---

## UI & Systems

### [WARNING] Hardcoded UI Offsets
- **File:** `game/ui/dialogue/dialogue_box.gd`
- **Issue:** Slide animation uses hardcoded `120.0` value.
- **Fix:** Export the value or calculate it based on the panel's rect size.

### [STYLE] Loop Variable Typing
- **File:** `game/systems/state_machine/state_machine.gd`
- **Issue:** Child loop in `_ready()` lacks explicit type.
- **Fix:** `for child: Node in get_children():`

---

## Organization & Composition

### [HIGH] Redundant UI Instantiation
- **Files:** `game/scenes/**/*.tscn`
- **Issue:** HUD, DialogueBox, and PauseMenu are manually added to every level.
- **Fix:** Centralize UI into a global CanvasLayer managed by an autoload. Remove local instances from level scenes.

### [HIGH] Duplicate DialogueBox Implementation
- **Files:** `game/systems/dialogue/` and `game/ui/dialogue/`
- **Issue:** Duplicate scene and script for dialogue box.
- **Fix:** Consolidate into `game/ui/dialogue/` and delete the redundant folder.

### [MEDIUM] Hardcoded Battle Spawn Positions
- **File:** `game/systems/battle/battle_scene.gd`
- **Issue:** Uses Vector2 arrays for positioning.
- **Fix:** Use Marker2D nodes in the scene for spawn points.

---

## Documentation & Standards

### [STYLE] Signal/Method Documentation
- **Files:** Multiple (e.g., `battle_scene.gd`, `battler.gd`)
- **Issue:** Many signals and public methods lack `##` doc comments.
- **Fix:** Add comprehensive doc comments to all public APIs.

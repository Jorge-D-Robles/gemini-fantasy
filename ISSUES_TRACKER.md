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

### [STYLE] Missing Return Type Hints
- **Files:** 
    - `game/systems/battle/enemy_battler.gd` (`_support_ai`)
    - `game/systems/battle/battle_scene.gd` (`setup_battle`)
    - `game/autoloads/battle_manager.gd` (`start_battle`)
    - `game/autoloads/game_manager.gd` (`change_scene`)
    - `game/ui/battle_ui/battle_ui.gd` (`show_target_selector`)
    - `game/entities/player/player.gd` (`_on_game_state_changed`)
- **Issue:** Several public and private methods are missing explicit `-> void` or other return type hints.
- **Fix:** Add appropriate return type hints to all method definitions.

### [TODO] Party Healing in Roothollow
- **File:** `game/scenes/roothollow/roothollow.gd`
- **Issue:** Placeholder comment for party healing logic once persistent state is implemented.
- **Fix:** Implement party HP/EE restoration at appropriate resting points in Roothollow.

---

## Architecture & Design Patterns

### [CRITICAL] Meta-based State Communication
- **File:** `game/systems/battle/states/action_execute_state.gd`, `game/systems/battle/states/action_select_state.gd`
- **Issue:** Uses `get_meta`/`set_meta` to pass action data between states. This is fragile and lacks type safety.
- **Fix:** Replace with a typed `BattleAction` object held by the `BattleScene` or the `BattleStateMachine`.

### [HIGH] Violation of SRP in Interactable.gd
- **File:** `game/entities/interactable/interactable.gd`
- **Issue:** Single script handles all interaction types (chest, sign, save point, etc.) using a match statement. This is hard to maintain and extend.
- **Fix:** Refactor into a base `Interactable` class and specialized children, or use composition (Interaction Behaviors).

### [MEDIUM] Manual Animation in Player.gd
- **File:** `game/entities/player/player.gd`
- **Issue:** Manually calculates animation frames in `_physics_process`.
- **Fix:** Use `AnimationPlayer` or `AnimatedSprite2D` for more maintainable animations.

### [WARNING] Unsafe has_method/has_signal in Autoloads
- **File:** `game/autoloads/battle_manager.gd`, `game/autoloads/dialogue_manager.gd`
- **Issue:** Uses `has_method` or `has_signal` instead of proper typing or interfaces when interacting with scenes.
- **Fix:** Use specific class types or defined interfaces to ensure type safety.

---

## Data Structures & Type Safety

### [HIGH] Dictionary-based Data for Core Systems
- **File:** `game/autoloads/dialogue_manager.gd`, `game/systems/encounter/encounter_system.gd`
- **Issue:** Uses `Array[Dictionary]` for dialogue lines and encounter pools. Lacks type safety and IDE support.
- **Fix:** Create custom `Resource` classes for `DialogueLine` and `EncounterPoolEntry`.

### [WARNING] Missing Bus Layout
- **File:** `game/autoloads/audio_manager.gd`
- **Issue:** Assumes "BGM" and "SFX" buses exist, but `default_bus_layout.tres` is missing or not configured.
- **Fix:** Create and configure `game/default_bus_layout.tres` with the appropriate buses.

### [STYLE] Literal Strings for Enum-like State
- **File:** `game/systems/battle/states/action_execute_state.gd`
- **Issue:** Uses strings like `"attack"`, `"skill"`, `"item"` to identify action types.
- **Fix:** Use an `enum` defined in a shared battle constants or base class.

---

## Documentation & Standards

### [STYLE] Signal/Method Documentation
- **Files:** Multiple (e.g., `battle_scene.gd`, `battler.gd`)
- **Issue:** Many signals and public methods lack `##` doc comments.
- **Fix:** Add comprehensive doc comments to all public APIs.

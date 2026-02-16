# Gemini Fantasy Issues Tracker

This file tracks technical debt, bugs, and architectural issues identified during code reviews. Agents MUST check this file before starting work on a system and update it after performing reviews.

## [CRITICAL] Core Blockers

### Battle Visuals Not Instantiated
- **File:** `game/systems/battle/battle_scene.gd`
- **Issue:** `_spawn_party` and `_spawn_enemies` instantiate logic nodes (`PartyBattler.new()`) but do not load or bind the visual scenes (`party_battler_scene.tscn`). Battlers are invisible.
- **Fix:** Instantiate visual scenes and call `bind_battler()` during spawning. Reference: `docs/best-practices/01-scene-architecture.md`.

## Architecture & Design Patterns

### [HIGH] Autoload Class Definitions Missing
- **File:** `game/project.godot`
- **Issue:** Global managers (GameManager, etc.) lack `class_name` declarations. This prevents using them as type hints in other scripts, leading to `Variant` inference.
- **Fix:** Add `class_name [ManagerName]` to all autoload scripts. Reference: `docs/best-practices/03-autoloads-and-singletons.md`.

### [HIGH] SRP Violation: Sub-node Scripts
- **File:** `game/systems/battle/battle_scene.tscn`
- **Issue:** `TurnQueue` is a child node with a script attached directly in the main scene.
- **Fix:** Extract `TurnQueue` into its own `.tscn` scene to adhere to "one script per scene" rule. Reference: `docs/best-practices/01-scene-architecture.md`.

### [HIGH] Violation of SRP in Interactable.gd
- **File:** `game/entities/interactable/interactable.gd`
- **Issue:** Single script handles all interaction types (chest, sign, save point, etc.) using a match statement.
- **Fix:** Refactor into a base `Interactable` class and specialized children, or use composition.

### [CRITICAL] Meta-based State Communication
- **File:** `game/systems/battle/states/action_execute_state.gd`
- **Issue:** Uses `get_meta`/`set_meta` to pass action data between states. Fragile and lacks type safety.
- **Fix:** Replace with a typed `BattleAction` object held by the `BattleScene`.

### [MEDIUM] Manual Animation in Player.gd
- **File:** `game/entities/player/player.gd`
- **Issue:** Manually calculates animation frames in `_physics_process`.
- **Fix:** Use `AnimationPlayer` or `AnimatedSprite2D`.

### [WARNING] Unsafe has_method/has_signal in Autoloads
- **File:** `game/autoloads/battle_manager.gd`, `game/autoloads/dialogue_manager.gd`
- **Issue:** Uses `has_method` or `has_signal` instead of proper typing/interfaces.
- **Fix:** Use specific class types or defined interfaces.

---

## Data Structures & Type Safety

### [HIGH] Dictionary-based Data for Core Systems
- **File:** `game/autoloads/dialogue_manager.gd`, `game/systems/encounter/encounter_system.gd`
- **Issue:** Uses `Array[Dictionary]` for dialogue and encounter pools. Lacks IDE support.
- **Fix:** Create custom `Resource` classes for `DialogueLine` and `EncounterPoolEntry`. Reference: `docs/best-practices/04-resources-and-data.md`.

### [CRITICAL] Loose Typing in Battler/EnemyBattler
- **File:** `game/systems/battle/battler.gd`
- **Issue:** `data` property is typed as `Resource` instead of a specific base class.
- **Fix:** Create a base `BattlerData` resource and inherit.

### [WARNING] Missing Bus Layout
- **File:** `game/autoloads/audio_manager.gd`
- **Issue:** Assumes "BGM" and "SFX" buses exist, but `default_bus_layout.tres` is missing.
- **Fix:** Create and configure `game/default_bus_layout.tres`.

---

## Logic & Polish

### [WARNING] Hardcoded Battle Positions
- **File:** `game/systems/battle/battle_scene.gd`
- **Issue:** Spawn positions for party and enemies are hardcoded in arrays.
- **Fix:** Use `Marker2D` nodes or exported arrays of positions.

### [WARNING] Magic Numbers in Damage Formulas
- **File:** `game/systems/battle/battler.gd`
- **Issue:** Multipliers like `200.0`, `0.5` are hardcoded in `_calculate_incoming_damage`.
- **Fix:** Move to named constants.

### [MEDIUM] Unconnected Signals
- **Files:** `player.gd`, `interactable.gd`, `npc.gd`
- **Issue:** Signals like `interacted_with` are emitted but never connected to any system.
- **Fix:** Wire up interaction signals to a global EventBus or QuestManager.

### [TODO] Party Healing in Roothollow
- **File:** `game/scenes/roothollow/roothollow.gd`
- **Issue:** Placeholder comment for party healing logic.
- **Fix:** Implement party HP/EE restoration at resting points.

---

## Documentation & Standards

### [STYLE] Missing Return Type Hints
- **Files:** `enemy_battler.gd`, `battle_scene.gd`, `battle_manager.gd`, `game_manager.gd`, `battle_ui.gd`, `player.gd`
- **Issue:** Numerous methods missing explicit `-> void` or return type hints.
- **Fix:** Add appropriate return type hints to all method definitions.

### [STYLE] Signal/Method Documentation
- **Files:** Multiple (e.g., `battle_scene.gd`, `battler.gd`)
- **Issue:** Many signals and public methods lack `##` doc comments.
- **Fix:** Add comprehensive doc comments to all public APIs.

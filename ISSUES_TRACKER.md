# Gemini Fantasy Issues Tracker

This file tracks technical debt, bugs, and architectural issues identified during code reviews. Agents MUST check this file before starting work on a system and update it after performing reviews.

## Open Issues

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

### [HIGH] Dictionary-based Data for Core Systems
- **File:** `game/autoloads/dialogue_manager.gd`, `game/systems/encounter/encounter_system.gd`
- **Issue:** Uses `Array[Dictionary]` for dialogue and encounter pools. Lacks IDE support.
- **Fix:** Create custom `Resource` classes for `DialogueLine` and `EncounterPoolEntry`. Reference: `docs/best-practices/04-resources-and-data.md`.

### [MEDIUM] Meta-based State Communication
- **File:** `game/systems/battle/states/action_execute_state.gd`
- **Issue:** Uses `get_meta`/`set_meta` to pass action data between states. Fragile and lacks type safety.
- **Fix:** Replace with a typed `BattleAction` object held by the `BattleScene`.

### [MEDIUM] Manual Animation in Player.gd
- **File:** `game/entities/player/player.gd`
- **Issue:** Manually calculates animation frames in `_physics_process`.
- **Fix:** Use `AnimationPlayer` or `AnimatedSprite2D`.

### [MEDIUM] Unconnected Signals
- **Files:** `player.gd`, `interactable.gd`, `npc.gd`
- **Issue:** Signals like `interacted_with` are emitted but never connected to any system.
- **Fix:** Wire up interaction signals to a global EventBus or QuestManager.

### [WARNING] Unsafe has_method/has_signal in Autoloads
- **File:** `game/autoloads/battle_manager.gd`, `game/autoloads/dialogue_manager.gd`
- **Issue:** Uses `has_method` or `has_signal` instead of proper typing/interfaces.
- **Fix:** Use specific class types or defined interfaces.

### [TODO] Party Healing in Roothollow
- **File:** `game/scenes/roothollow/roothollow.gd`
- **Issue:** Placeholder comment for party healing logic.
- **Fix:** Implement party HP/EE restoration at resting points.

### [STYLE] Missing Return Type Hints
- **Files:** `enemy_battler.gd`, `battle_scene.gd`, `battle_manager.gd`, `game_manager.gd`, `battle_ui.gd`, `player.gd`
- **Issue:** Numerous methods missing explicit `-> void` or return type hints.
- **Fix:** Add appropriate return type hints to all method definitions.

### [STYLE] Signal/Method Documentation
- **Files:** Multiple (e.g., `battle_scene.gd`, `battler.gd`)
- **Issue:** Many signals and public methods lack `##` doc comments.
- **Fix:** Add comprehensive doc comments to all public APIs.

---

## Recently Fixed (2026-02-16 Audit)

### CRITICAL Fixes
1. **Defeat state never ended battle** — `defeat_state.gd` now calls `battle_scene.end_battle(false)` after showing defeat screen, preventing permanent `BattleManager._is_in_battle = true` corruption
2. **Double-fire on target confirmation** — Removed callback pattern from `battle_ui.gd` and `target_select_state.gd`; now uses only `target_selected` signal
3. **Hardcoded enum magic numbers** — `action_execute_state.gd` now uses `AbilityData.DamageStat.MAGIC`, `ItemData.EffectType.HEAL_HP/HEAL_EE` with proper casts
4. **Invisible battlers in battle** — `battle_scene.gd` now instantiates `PartyBattlerScene`/`EnemyBattlerScene` visual scenes and binds them to logic battlers
5. **Iris recruitment post-battle unreachable** — Rewrote `iris_recruitment.gd` to use static functions and `CONNECT_ONE_SHOT` on `BattleManager.battle_ended`, surviving scene changes
6. **Iris recruitment no victory check** — Post-battle now checks `victory` parameter; clears flag on defeat so event can re-trigger
7. **Duplicate Camera2D in Roothollow** — Fixed `roothollow.tscn` to use property override syntax (no `type=`) matching Verdant Forest pattern
8. **Missing icon.svg** — Created `game/icon.svg` placeholder
9. **Missing audio bus layout** — Created `game/default_bus_layout.tres` with BGM and SFX buses

### HIGH Fixes
10. **PartyManager array reference leak** — `get_active_party()` and `get_roster()` now return `.duplicate()`
11. **6 trees missing collision in Roothollow** — Added `StaticBody2D` + `CollisionShape2D` for Tree02, Tree05, Tree07, Tree08, Tree10, Tree12
12. **Dead code in player_turn_state.gd** — Removed unused `_pending_command`, `_pending_ability`, `_pending_item` variables
13. **Dead DamageStat enum in CharacterData** — Removed (duplicated from AbilityData)
14. **OVERLOAD_OUTGOING_DAMAGE_MULT type mismatch** — Changed from `int = 2` to `float = 2.0` for consistency
15. **TurnQueueState default to Victory on empty queue** — Now reinitializes turn order; only falls back to Defeat
16. **Unused delta/event params** — Prefixed with `_` in `state.gd` base class
17. **NPC global dialogue signal** — Changed from persistent `connect()` in `_ready()` to `CONNECT_ONE_SHOT` per interaction
18. **Duplicate AIType enum** — `EnemyBattler` now uses `EnemyData.AiType` directly instead of duplicate `AIType`
19. **Ability target_type ignored** — `target_select_state.gd` now reads ability target_type and selects party/enemies/self accordingly
20. **UILayer wrong type annotations** — Removed `CanvasLayer` type from `hud`, `dialogue_box`, `pause_menu` (script types inferred via `:=`)

### MEDIUM Fixes
21. **BattleAction parameter shadowing** — Renamed `ability`/`target` params to `p_ability`/`p_target` in static constructors
22. **VerdantForest→OvgrownRuins no spawn point** — Added `spawn_from_forest` Marker2D and group in overgrown_ruins
23. **Misleading sub-resource name** — Renamed `RectangleShape2D_garrick` to `CircleShape2D_garrick` in roothollow.tscn
24. **@onready with .new()** — `game_manager.gd` now initializes `_transition_layer`/`_fade_rect` in `_setup_transition_layer()` instead
25. **HUD duck-typing** — `hud.gd` now casts member to `BattlerData` instead of `"max_hp" in member` pattern
26. **NPC portrait null warning** — Added `push_warning()` when portrait fails to load

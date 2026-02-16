# Gemini Fantasy Issues Tracker

This file tracks technical debt, bugs, and architectural issues identified during code reviews. Agents MUST check this file before starting work on a system and update it after performing reviews.

No open issues.

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

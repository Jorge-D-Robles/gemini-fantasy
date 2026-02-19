# game/systems/

Core game systems: state machine framework, battle logic, encounter management, progression, and tilemap utilities.

## Subdirectory Index

| Directory | Purpose |
|-----------|---------|
| `state_machine/` | Generic node-based state machine base classes |
| `battle/` | Battle scene, battlers, turn queue, and all battle states |
| `battle/states/` | Individual state nodes for the battle state machine |
| `encounter/` | Step-based random encounter trigger |
| `progression/` | XP and leveling calculation utilities |
| `map_builder.gd` | Static utility for building TileMapLayers from Time Fantasy tiles |
| `game_balance.gd` | Centralized game balance constants (resonance, damage, XP, AI, party limits) |

---

## game_balance.gd

Centralized balance constants. Import via `const GameBalance = preload("res://systems/game_balance.gd")`.

| Category | Constants |
|----------|-----------|
| Resonance | `RESONANCE_MAX`, `RESONANCE_RESONANT_THRESHOLD`, `RESONANCE_OVERLOAD_THRESHOLD`, `RESONANCE_GAIN_*`, `DEFEND_RESONANCE_BASE` |
| Damage | `DEFENSE_SCALING_DIVISOR`, `DEFENSE_MOD_MIN`, `HOLLOW_STAT_PENALTY`, `DEFEND_DAMAGE_REDUCTION`, `OVERLOAD_*_DAMAGE_MULT`, `RESONANT_ABILITY_BONUS`, `STAT_DAMAGE_SCALING` |
| Turn order | `TURN_DELAY_BASE` |
| Revive | `REVIVE_HP_PERCENT` |
| XP / Leveling | `XP_CURVE_BASE` |
| Party limits | `MAX_ACTIVE_PARTY`, `MAX_RESERVE_PARTY` |
| Enemy AI | `AI_DEFENSIVE_HP_THRESHOLD`, `AI_SUPPORT_HEAL_THRESHOLD` |

---

## state_machine/

Two base classes consumed by every state machine in the project.

| Class | File | Extends |
|-------|------|---------|
| `StateMachine` | `state_machine.gd` | `Node` |
| `State` | `state.gd` | `Node` |

### StateMachine API
- `@export var initial_state: State` — set in inspector to auto-enter on `_ready()`
- `func transition_to(state_name: StringName)` — exit current, enter named child state
- `signal state_changed(old_state, new_state)`
- Delegates `_process`, `_physics_process`, `_unhandled_input` to `current_state`

### State API (override in subclasses)
```gdscript
func enter() -> void:      # called when transitioning into this state
func exit() -> void:       # called when transitioning out
func process(delta) -> void
func physics_process(delta) -> void
func handle_input(event) -> void
```
- Each state gets `var state_machine: StateMachine` set automatically in `StateMachine._ready()`

---

## battle/

The battle subsystem is the most complex system. It uses a `BattleStateMachine` (extends `StateMachine`) whose child states each receive a reference to `BattleScene`.

### Key Classes

| Class | File | Role |
|-------|------|------|
| `Battler` | `battler.gd` | Base class for all combatants. Holds HP, EE, Resonance gauge, status effects. Delegates pure logic to static helpers. |
| `BattlerDamage` | `battler_damage.gd` | Static utility: outgoing/incoming damage formulas with resonance modifiers. |
| `BattlerResonance` | `battler_resonance.gd` | Static utility: gauge transitions, state evaluation, turn delay calculation. |
| `BattlerStatus` | `battler_status.gd` | Static utility: status effect apply/remove/query/modifier helpers. |
| `PartyBattler` | `party_battler.gd` | Player-controlled battler. Emits `action_requested` / `target_requested`. |
| `EnemyBattler` | `enemy_battler.gd` | AI-controlled battler. Implements BASIC/AGGRESSIVE/DEFENSIVE/SUPPORT/BOSS AI. |
| `TurnQueue` | `turn_queue.gd` | Sorts alive battlers by `turn_delay` (100/speed). Emits `turn_ready(battler)`. |
| `BattleStateMachine` | `battle_state_machine.gd` | Extends `StateMachine`; calls `set_battle_scene()` on all child states in `setup()`. |
| `BattleScene` | `battle_scene.gd` | Root orchestrator. Spawns battlers, wires signals, drives `battle_finished`. |

### Battler.ResonanceState Enum
```
FOCUSED  → 0..74   — normal operation
RESONANT → 75..99  — +20% ability damage
OVERLOAD → 100..150 — ×2 outgoing and incoming damage
HOLLOW   → post-defeat-while-overload — −50% stats, no resonance gain
```
Resonance thresholds: `RESONANCE_RESONANT_THRESHOLD = 75.0`, `RESONANCE_OVERLOAD_THRESHOLD = 100.0`, `RESONANCE_MAX = 150.0`

### Battler Key Methods
```gdscript
func initialize_from_data(equip_manager: Node = null) -> void
func take_damage(amount: int, is_magical: bool = false) -> int
func deal_damage(base: int, is_magical: bool, is_ability: bool) -> int
func heal(amount: int) -> int
func defend() -> void                  # halves incoming damage, gains resonance
func end_turn() -> void                # clears is_defending, recalculates turn_delay
func add_resonance(amount: float) -> void
func apply_status(effect_data: StatusEffectData) -> void
func tick_effects() -> void            # call once per turn end
func get_modified_stat(stat_name: String) -> int  # includes status modifiers + Hollow penalty
```

### BattleScene Public API
```gdscript
func setup_battle(party_data, enemy_data, escapable) -> void   # call to start a fight
func get_living_party() -> Array[Battler]
func get_living_enemies() -> Array[Battler]
func check_battle_end() -> int         # 0=ongoing, 1=victory, -1=defeat
func end_battle(victory: bool) -> void
func refresh_battle_ui() -> void
signal battle_finished(victory: bool)
```
Reads/writes HP+EE back to `PartyManager` via `_apply_persistent_state` / `_persist_party_state`.

### Battle States (child nodes of BattleStateMachine)

| State Node Name | File | Description |
|-----------------|------|-------------|
| `BattleStart` | `battle_start_state.gd` | 0.5s delay → `TurnQueueState` |
| `TurnQueueState` | `turn_queue_state.gd` | Calls `TurnQueue.advance()`, routes to player or enemy turn |
| `PlayerTurn` | `player_turn_state.gd` | Shows command menu, waits for BattleUI signals |
| `ActionSelect` | `action_select_state.gd` | Shows skill/item submenus |
| `TargetSelect` | `target_select_state.gd` | Shows target selector, emits chosen target |
| `ActionExecute` | `action_execute_state.gd` | Applies the chosen `BattleAction` |
| `EnemyTurn` | `enemy_turn_state.gd` | Calls `EnemyBattler.choose_action()` |
| `TurnEnd` | `turn_end_state.gd` | Ticks status effects, checks battle end |
| `Victory` | `victory_state.gd` | Awards EXP/gold, shows victory screen |
| `Defeat` | `defeat_state.gd` | Shows defeat screen |

Each state file defines `func set_battle_scene(scene: Node)` which is called by `BattleStateMachine.setup()`.

### TurnQueue API
```gdscript
func initialize(battlers: Array[Battler]) -> void
func advance() -> Battler         # pops and returns next battler
func peek_order(count: int) -> Array[Battler]
func remove_battler(battler: Battler) -> void
func add_battler(battler: Battler) -> void
signal turn_ready(battler: Battler)
signal turn_order_changed(order: Array[Battler])
```

---

## encounter/

`EncounterSystem` (extends `Node`) — add as a child of any overworld/dungeon scene.

```gdscript
@export var encounter_rate: float = 0.1    # probability per step
@export var min_steps_between: int = 5
@export var step_distance: float = 16.0   # pixels per "step"
@export var enabled: bool = true
var enemy_pool: Array[EncounterPoolEntry] = []

func setup(pool: Array[EncounterPoolEntry]) -> void
func reset_steps() -> void
signal encounter_triggered(enemy_group: Array[Resource])
```

- Finds player via `get_tree().get_first_node_in_group("player")`
- Respects `GameManager.current_state == OVERWORLD` and `BattleManager.is_in_battle()`
- Enemy groups selected by weighted random from `enemy_pool`

---

## progression/

`LevelManager` (extends `RefCounted`) — **not an autoload**. Use static methods directly.

```gdscript
LevelManager.xp_for_level(level: int) -> int         # 100 * level²
LevelManager.xp_to_next_level(character) -> int
LevelManager.can_level_up(character) -> bool
LevelManager.get_stat_at_level(base, growth, level) -> int  # base + floor(growth*(level-1))
LevelManager.level_up(character) -> Dictionary        # increments level, returns stat changes
LevelManager.add_xp(character, amount) -> Array[Dictionary]  # handles multi-level-ups
```

---

## map_builder.gd

`MapBuilder` (extends `RefCounted`) — static tilemap utility. Do not instantiate.

```gdscript
MapBuilder.create_atlas_source(texture_path: String) -> TileSetAtlasSource
MapBuilder.create_tileset(atlas_paths: Array[String], solid_tiles: Dictionary) -> TileSet
MapBuilder.build_layer(layer: TileMapLayer, map_data: Array[String], legend: Dictionary, source_id: int) -> void
MapBuilder.apply_tileset(layers: Array[TileMapLayer], atlas_paths: Array[String], solid_tiles: Dictionary) -> void
MapBuilder.create_boundary_walls(parent: Node, width_px: int, height_px: int) -> void
```

`create_boundary_walls()` adds 4 invisible `StaticBody2D` walls around the map edges on collision layer 2 (bitmask `0b10`). The player's `collision_mask = 6` (layers 2+3) detects these walls. Each wall is 32px thick with 16px corner extensions to prevent diagonal escape. Walls are grouped under a `Boundaries` node.

Pre-defined texture path constants: `FAIRY_FOREST_A5_A/B`, `RUINS_A5`, `OVERGROWN_RUINS_A5`, `FOREST_OBJECTS`, `TREE_OBJECTS`, `STONE_OBJECTS`, `MUSHROOM_VILLAGE`, `RUINS_OBJECTS`, `OVERGROWN_RUINS_OBJECTS`, `GIANT_TREE`.

See `docs/best-practices/11-tilemaps-and-level-design.md` for usage patterns.

---

## Dependencies

- `PartyManager` autoload — persistent HP/EE across battles
- `EquipmentManager` autoload — equipment stat bonuses applied in `Battler.initialize_from_data()`
- `BattleManager` autoload — `is_in_battle()` checked by EncounterSystem
- `GameManager` autoload — state checks in EncounterSystem
- `LevelManager` static class — used inside `Battler._load_stats_from_data()` for `CharacterData`
- Resources: `BattlerData`, `CharacterData`, `EnemyData`, `AbilityData`, `StatusEffectData`, `BattleAction`, `EncounterPoolEntry`

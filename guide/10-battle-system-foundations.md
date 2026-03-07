# Chapter 10 — Battle System Foundations

Every JRPG needs a battle system, and every battle system needs a state machine. When you press "Attack," the game is in a different state than when it is waiting for you to pick a target, which is different from when it is playing the damage animation. Without explicit states, you end up with a tangle of boolean flags — `is_selecting_target`, `is_animating`, `is_waiting_for_input`, `has_battle_ended` — that interact in unpredictable ways.

This chapter builds the foundation: a generic state machine framework, a battle-specific extension, the Battler class hierarchy, and a speed-based turn queue. The next two chapters will add commands, targeting, damage formulas, and AI on top of this foundation.

## What We Are Building

- **StateMachine** and **State** — reusable, generic base classes (used beyond battle)
- **BattleStateMachine** — extends StateMachine with a reference to BattleScene
- **BattleScene** — the root Node2D that orchestrates everything in a fight
- **Battler** — base class for all combatants, holding stats, HP, EE, and the Resonance gauge
- **PartyBattler** and **EnemyBattler** — player-controlled and AI-controlled specializations
- **TurnQueue** — speed-based ordering that determines who acts next
- **Battle states** — the 10 states that drive the flow of combat

## Why Battles Need a State Machine

Consider the states a battle passes through:

1. Battle starts (intro animation, spawn battlers)
2. Determine whose turn it is (speed-based queue)
3. If it is a party member's turn, show the command menu
4. Player picks "Abilities" — show the ability list
5. Player picks a specific ability — show the target selector
6. Player picks a target — execute the ability
7. Check if any enemy died. Check if all enemies died.
8. If battle continues, tick status effects, recalculate turn order
9. Determine whose turn it is next — maybe an enemy this time
10. Enemy AI picks an action and target — execute it

Each of these is a distinct state with distinct behavior. In state 3, the system waits for UI input. In state 6, it runs damage calculations and animations. In state 9, it runs AI logic with no player input at all.

**Engineering parallel:** If you have used NgRx, think of each state as a reducer case. The current state plus an action (player input, timer expiry, animation completion) determines the next state. The StateMachine is the store dispatcher — it routes transitions and ensures only one state is active at a time.

Without a state machine, you would need conditional checks everywhere: "if we are in the targeting phase AND the player has already selected an ability AND the battle has not ended..." That is the path to unmaintainable code.

## The Generic State Machine

The state machine framework has two classes. They are generic — not battle-specific — so you can reuse them for NPC AI, menu navigation, player movement modes, or anything else that has discrete states.

### State — The Base Class

```gdscript
# game/systems/state_machine/state.gd
class_name State
extends Node

## Base class for state machine states. Override enter/exit/process methods.

var state_machine: StateMachine


func enter() -> void:
	pass


func exit() -> void:
	pass


func process(_delta: float) -> void:
	pass


func physics_process(_delta: float) -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass
```

Every state is a Node. This is deliberate — it means states live in the scene tree, are visible in the editor, and can have their own children. Each state gets five lifecycle methods to override:

| Method | When Called | Typical Use |
|--------|-----------|-------------|
| `enter()` | Transitioning *into* this state | Show UI, start timers, connect signals |
| `exit()` | Transitioning *out of* this state | Hide UI, disconnect signals, clean up |
| `process(delta)` | Every frame while this state is active | Animations, timers |
| `physics_process(delta)` | Every physics tick while active | Movement, collision |
| `handle_input(event)` | On unhandled input while active | Player keypresses |

The `state_machine` variable is set by the parent StateMachine during `_ready()` — you never set it manually.

### StateMachine — The Manager

```gdscript
# game/systems/state_machine/state_machine.gd
class_name StateMachine
extends Node

## Generic node-based state machine. Each state is a child node extending State.

signal state_changed(old_state: State, new_state: State)

@export var initial_state: State

var current_state: State


func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			child.state_machine = self
	if initial_state:
		_enter_state(initial_state)


func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func transition_to(state_name: StringName) -> void:
	var new_state: State = get_node_or_null(NodePath(state_name))
	if not new_state:
		push_error("StateMachine: state '%s' not found." % state_name)
		return
	if new_state == current_state:
		return
	var old_state := current_state
	if current_state:
		current_state.exit()
	_enter_state(new_state)
	state_changed.emit(old_state, new_state)


func _enter_state(new_state: State) -> void:
	current_state = new_state
	current_state.enter()
```

The key design decisions:

1. **States are child nodes.** The StateMachine finds them by name using `get_node_or_null()`. In the scene tree, it looks like:

```
BattleStateMachine (StateMachine)
  ├── BattleStart (State)
  ├── TurnQueueState (State)
  ├── PlayerTurn (State)
  ├── ActionSelect (State)
  ├── TargetSelect (State)
  ├── ActionExecute (State)
  ├── EnemyTurn (State)
  ├── TurnEnd (State)
  ├── Victory (State)
  └── Defeat (State)
```

2. **Transition by name.** `transition_to("PlayerTurn")` finds the child node named "PlayerTurn". This keeps transitions readable and decoupled — states do not hold references to each other.

3. **Delegates frame callbacks.** The StateMachine's `_process`, `_physics_process`, and `_unhandled_input` all forward to the current state. Only one state receives these callbacks at a time.

4. **`@export var initial_state`** lets you set the starting state in the editor inspector. For battles, this is set to `BattleStart`.

5. **`state_changed` signal** is useful for debugging — connect a logger to it and you can trace every state transition.

## The Battle State Machine

The battle needs one addition to the generic framework: a reference to `BattleScene`, so states can access party battlers, enemy battlers, the turn queue, and the UI.

```gdscript
# game/systems/battle/battle_state_machine.gd
class_name BattleStateMachine
extends StateMachine

## Extends the generic state machine with battle-specific context.
## Child states can access battle_scene for party, enemies, turn queue, etc.

var battle_scene: Node = null


func setup(scene: Node) -> void:
	battle_scene = scene
	for child in get_children():
		if child is State and child.has_method("set_battle_scene"):
			child.set_battle_scene(scene)
```

`setup()` is called by `BattleScene._ready()`. It iterates every child state and passes the scene reference via `set_battle_scene()`. This is manual dependency injection — each state that needs the battle context defines that method.

Why not put `battle_scene` on the base `State` class? Because the generic State is reused for non-battle state machines. Adding battle-specific fields to the generic class would violate separation of concerns.

## Battle States Overview

Here is the complete flow of a battle, shown as a state diagram:

```
                    ┌──────────────┐
                    │ BattleStart  │
                    └──────┬───────┘
                           │ (0.5s delay)
                    ┌──────▼───────┐
               ┌───►│ TurnQueue    │◄────────────────────────┐
               │    │   State      │                         │
               │    └──┬───────┬───┘                         │
               │       │       │                             │
               │   party?   enemy?                           │
               │       │       │                             │
               │ ┌─────▼──┐ ┌─▼────────┐                    │
               │ │ Player  │ │ Enemy    │                    │
               │ │  Turn   │ │  Turn    │                    │
               │ └──┬──────┘ └────┬─────┘                    │
               │    │             │ (AI decides)             │
               │    │ command     │                          │
               │    │             │                          │
               │ ┌──▼────────┐   │                          │
               │ │ Action    │   │                          │
               │ │  Select   │   │                          │
               │ └──┬────────┘   │                          │
               │    │ skill/item │                          │
               │ ┌──▼────────┐   │                          │
               │ │ Target    │   │                          │
               │ │  Select   │   │                          │
               │ └──┬────────┘   │                          │
               │    │ target     │                          │
               │ ┌──▼────────┐   │                          │
               │ │ Action    │◄──┘                          │
               │ │  Execute  │                              │
               │ └──┬───┬────┘                              │
               │    │   │                                   │
               │  alive? dead?                              │
               │    │   │                                   │
               │ ┌──▼──┐ ┌──▼────┐ ┌──▼────┐               │
               │ │Turn │ │Victory│ │Defeat │               │
               │ │ End │ └───────┘ └───────┘               │
               │ └──┬──┘                                    │
               │    │ (tick effects, recalc delay)          │
               └────┘
```

Each box is a State node. Arrows are `transition_to()` calls. Let us walk through each state.

### BattleStart

The simplest state — a brief delay before combat begins. This is where you would play an intro animation or "Battle!" text flash.

```gdscript
# game/systems/battle/states/battle_start_state.gd
extends State

## Initial battle state. Brief intro delay then starts turn queue.

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	await get_tree().create_timer(0.5).timeout
	state_machine.transition_to("TurnQueueState")
```

`await` pauses this function for 0.5 seconds without blocking the engine. When the timer fires, it transitions to the turn queue.

### TurnQueueState

The routing hub. This state determines *whose turn it is* and sends control to the appropriate state:

```gdscript
# game/systems/battle/states/turn_queue_state.gd
extends State

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	# Check if battle is already over
	var result: int = battle_scene.check_battle_end()
	if result == 1:
		state_machine.transition_to("Victory")
		return
	if result == -1:
		state_machine.transition_to("Defeat")
		return

	# Get next battler from the queue
	var next_battler: Battler = battle_scene.turn_queue.advance()
	if not next_battler:
		state_machine.transition_to("Defeat")
		return

	battle_scene.current_battler = next_battler

	# Stunned battlers skip their turn
	if next_battler.is_action_prevented():
		state_machine.transition_to("TurnEnd")
		return

	# Route to player or enemy turn
	if next_battler is PartyBattler:
		state_machine.transition_to("PlayerTurn")
	elif next_battler is EnemyBattler:
		state_machine.transition_to("EnemyTurn")
```

Three checks happen every time control returns here:
1. **Battle end check** — if all enemies are dead, go to Victory. If all party members are dead, go to Defeat.
2. **Stun check** — if the next battler has a status effect that prevents action, skip their turn entirely.
3. **Type check** — `is PartyBattler` routes to player input handling, `is EnemyBattler` routes to AI.

### TurnEnd

After every action executes, control flows to TurnEnd before returning to TurnQueueState:

```gdscript
# game/systems/battle/states/turn_end_state.gd
extends State

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	var battler: Battler = battle_scene.current_battler
	if battler:
		battler.tick_effects()
		battler.end_turn()

	state_machine.transition_to("TurnQueueState")
```

Two things happen at turn end:
1. `tick_effects()` — status effects process (poison deals damage, buffs count down, expired effects are removed).
2. `end_turn()` — the battler's `turn_delay` is recalculated for the next round.

We will cover the remaining states (PlayerTurn, ActionSelect, TargetSelect, ActionExecute, EnemyTurn, Victory, Defeat) in Chapters 11 and 12.

## The Battler Class

A `Battler` is any combatant in battle — player character or enemy. It holds runtime combat state: current HP, current EE, stat values, the Resonance gauge, active status effects, and turn delay.

### Why Battler Exists Separately from BattlerData

`BattlerData` (the Resource) defines *what* a character is: base stats, abilities, identity. `Battler` (the Node2D) represents *that character in this specific battle*: current HP after taking hits, current resonance gauge, active status effects, position on the battle field.

Think of it like a class instance versus a class definition. `BattlerData` is the class. `Battler` is an instance created for this particular fight.

```
BattlerData (Resource)              Battler (Node2D)
┌─────────────────────┐            ┌─────────────────────────┐
│ Template / Blueprint │────────►  │ Runtime Instance         │
│ max_hp: 120          │  copied   │ current_hp: 85           │
│ attack: 15           │  into     │ attack: 15 + 3 (equip)   │
│ abilities: [...]     │           │ resonance_gauge: 42.0     │
└─────────────────────┘            │ is_defending: false       │
                                   │ _active_effects: [...]    │
                                   └─────────────────────────┘
```

### The Battler Script

Here is the core of the Battler class (abbreviated for focus — we will cover damage, resonance, and status effects in detail in Chapter 12):

```gdscript
# game/systems/battle/battler.gd
class_name Battler
extends Node2D

## Base class for all combatants in battle.

signal hp_changed(new_hp: int, max_hp: int)
signal ee_changed(new_ee: int, max_ee: int)
signal defeated
signal resonance_changed(new_value: float)
signal resonance_state_changed(old_state: ResonanceState, new_state: ResonanceState)
signal status_effect_applied(effect: StringName)
signal status_effect_removed(effect: StringName)
signal damage_taken(amount: int)

enum ResonanceState {
	FOCUSED,
	RESONANT,
	OVERLOAD,
	HOLLOW,
}

@export var data: BattlerData

var current_hp: int = 0
var max_hp: int = 0
var current_ee: int = 0
var max_ee: int = 0
var attack: int = 0
var magic: int = 0
var defense: int = 0
var resistance: int = 0
var speed: int = 0
var luck: int = 0

var resonance_gauge: float = 0.0
var resonance_state: ResonanceState = ResonanceState.FOCUSED
var abilities: Array[Resource] = []
var is_defending: bool = false
var is_alive: bool = true
var turn_delay: float = 0.0

var _active_effects: Array[Dictionary] = []
```

Signals are the main communication mechanism. When a battler takes damage, it emits `hp_changed` and `damage_taken`. The battle UI connects to these signals to update health bars and show damage popups. The BattleScene connects to `defeated` to remove dead battlers from the turn queue.

### Initializing from Data

When BattleScene spawns a battler, it calls `initialize_from_data()` to copy stats from the Resource:

```gdscript
func initialize_from_data(equip_manager: Node = null) -> void:
	if not data:
		push_error("Battler: no data resource assigned.")
		return
	_load_stats_from_data()
	_apply_equipment_bonuses(equip_manager)
	current_hp = max_hp
	current_ee = max_ee
	resonance_gauge = 0.0
	resonance_state = ResonanceState.FOCUSED
	is_alive = true
	is_defending = false
	turn_delay = BattlerResonance.calculate_turn_delay(speed, resonance_state)
```

The initialization sequence:
1. Copy base stats from the data Resource.
2. Add equipment bonuses (only for party members — enemies do not equip gear).
3. Set HP and EE to their maximums.
4. Reset resonance to FOCUSED state.
5. Calculate the initial turn delay (used by the TurnQueue to determine turn order).

`_load_stats_from_data()` handles the `CharacterData` vs generic `BattlerData` distinction:

```gdscript
func _load_stats_from_data() -> void:
	if not data:
		return
	if data is CharacterData:
		var char_data := data as CharacterData
		max_hp = LevelManager.get_stat_at_level(
			char_data.max_hp, char_data.hp_growth, char_data.level
		)
		max_ee = LevelManager.get_stat_at_level(
			char_data.max_ee, char_data.ee_growth, char_data.level
		)
		attack = LevelManager.get_stat_at_level(
			char_data.attack, char_data.attack_growth, char_data.level
		)
		# ... same pattern for magic, defense, resistance, speed, luck
	else:
		max_hp = data.max_hp
		max_ee = data.max_ee
		attack = data.attack
		# ... direct copy for enemies (they don't level up)
	abilities = data.abilities
```

For party members (`CharacterData`), stats scale with level using the growth rate formula: `base + floor(growth * (level - 1))`. A character with base attack 15 and attack_growth 1.5 at level 10 has: `15 + floor(1.5 * 9) = 15 + 13 = 28` attack.

For enemies (`EnemyData`), stats are used as-is from the Resource — enemies have fixed stats.

### Equipment Bonuses

Party battlers get stat bonuses from equipped gear:

```gdscript
func _apply_equipment_bonuses(equip_manager: Node) -> void:
	if equip_manager == null:
		return
	if not (data is CharacterData):
		return
	var char_data := data as CharacterData
	if char_data.id == &"":
		return
	var bonuses: Dictionary = equip_manager.get_stat_bonuses(char_data.id)
	max_hp += bonuses.get("max_hp", 0)
	max_ee += bonuses.get("max_ee", 0)
	attack += bonuses.get("attack", 0)
	magic += bonuses.get("magic", 0)
	defense += bonuses.get("defense", 0)
	resistance += bonuses.get("resistance", 0)
	speed += bonuses.get("speed", 0)
	luck += bonuses.get("luck", 0)
```

The `EquipmentManager` autoload tracks what each character has equipped and computes total stat bonuses. The Battler does not know about individual equipment pieces — it just receives a flat bonus dictionary.

## PartyBattler and EnemyBattler

The base Battler handles all shared combat logic. The two subclasses add what makes each side unique.

### PartyBattler — Player-Controlled

```gdscript
# game/systems/battle/party_battler.gd
class_name PartyBattler
extends Battler

## Player-controlled battler. Waits for player input to select actions.

signal action_requested
signal target_requested(valid_targets: Array[Battler])

var character_id: StringName = &""
var equipped_echoes: Array[Resource] = []


func initialize_from_data(equip_manager: Node = null) -> void:
	super.initialize_from_data(equip_manager)
	if data:
		character_id = data.id


func get_available_abilities() -> Array[Resource]:
	if resonance_state == ResonanceState.HOLLOW:
		return []
	var available: Array[Resource] = []
	for ability in abilities:
		if _can_use_ability(ability):
			available.append(ability)
	return available


func _can_use_ability(ability: Resource) -> bool:
	var ability_data := ability as AbilityData
	if not ability_data:
		return false
	if current_ee < ability_data.ee_cost:
		return false
	if ability_data.resonance_cost > 0.0 and resonance_gauge < ability_data.resonance_cost:
		return false
	return true
```

Key additions over the base Battler:
- `character_id` — links back to PartyManager's runtime state (HP/EE persistence).
- `get_available_abilities()` — filters the ability list to only those the character can afford. The HOLLOW resonance state disables all abilities entirely.
- `_can_use_ability()` — checks both EE cost and resonance cost.

### EnemyBattler — AI-Controlled

```gdscript
# game/systems/battle/enemy_battler.gd
class_name EnemyBattler
extends Battler

## AI-controlled battler. Selects actions based on AI patterns from EnemyData.

signal ai_action_chosen(action: BattleAction)

@export var ai_type: EnemyData.AiType = EnemyData.AiType.BASIC

var loot_table: Array[Dictionary] = []
var exp_reward: int = 0
var gold_reward: int = 0


func initialize_from_data(equip_manager: Node = null) -> void:
	super.initialize_from_data(equip_manager)
	var enemy_data := data as EnemyData
	if enemy_data:
		ai_type = enemy_data.ai_type
		loot_table = enemy_data.loot_table
		exp_reward = enemy_data.exp_reward
		gold_reward = enemy_data.gold_reward


func choose_action(
	party: Array[Battler],
	allies: Array[Battler],
) -> BattleAction:
	var action: BattleAction
	match ai_type:
		EnemyData.AiType.BASIC:
			action = _basic_ai(party)
		EnemyData.AiType.AGGRESSIVE:
			action = _aggressive_ai(party)
		EnemyData.AiType.DEFENSIVE:
			action = _defensive_ai(party)
		EnemyData.AiType.SUPPORT:
			action = _support_ai(party, allies)
		EnemyData.AiType.BOSS:
			action = _aggressive_ai(party)
		_:
			action = BattleAction.create_wait()
	ai_action_chosen.emit(action)
	return action
```

Key additions:
- `ai_type` — determines which AI strategy the enemy uses (covered in detail in Chapter 11).
- `loot_table`, `exp_reward`, `gold_reward` — reward data copied from EnemyData during initialization.
- `choose_action()` — the entry point for AI decision-making. Takes the opposing party and allied enemies as context, returns a `BattleAction`.

## The TurnQueue

Turn order in a speed-based system is simple: faster characters act first. The TurnQueue calculates a `turn_delay` for each battler (lower delay = acts sooner), sorts by delay, and pops the next battler when asked.

### Turn Delay Formula

```
turn_delay = 100.0 / speed
```

A character with 20 speed has a turn_delay of 5.0. A character with 10 speed has a delay of 10.0. The faster character acts first.

The HOLLOW resonance state halves effective speed, doubling the delay. A 20-speed character in HOLLOW state has an effective speed of 10, giving a delay of 10.0.

### The TurnQueue Implementation

```gdscript
# game/systems/battle/turn_queue.gd
class_name TurnQueue
extends Node

## Manages turn order based on speed. Lower turn_delay = acts sooner.

signal turn_ready(battler: Battler)
signal turn_order_changed(order: Array[Battler])

var _battlers: Array[Battler] = []
var _turn_order: Array[Battler] = []


func initialize(battlers: Array[Battler]) -> void:
	_battlers = battlers
	_calculate_turn_order()


func advance() -> Battler:
	if _turn_order.is_empty():
		_calculate_turn_order()
	if _turn_order.is_empty():
		return null
	var next: Battler = _turn_order.pop_front()
	turn_ready.emit(next)
	return next


func peek_order(count: int = 5) -> Array[Battler]:
	if _turn_order.is_empty():
		_calculate_turn_order()
	var result: Array[Battler] = []
	var limit := mini(count, _turn_order.size())
	for i in limit:
		result.append(_turn_order[i])
	return result


func remove_battler(battler: Battler) -> void:
	_battlers.erase(battler)
	_turn_order.erase(battler)
	turn_order_changed.emit(_turn_order)


func _calculate_turn_order() -> void:
	_turn_order.clear()
	for b in _battlers:
		if b.is_alive:
			_turn_order.append(b)
	_turn_order.sort_custom(_compare_by_delay)
	turn_order_changed.emit(_turn_order)


func _compare_by_delay(a: Battler, b: Battler) -> bool:
	return a.turn_delay < b.turn_delay
```

The flow:
1. `initialize()` is called once at battle start with all battlers.
2. `_calculate_turn_order()` filters to living battlers and sorts by `turn_delay` (ascending).
3. `advance()` pops the first battler from the sorted list. When the list is empty, it recalculates (a new "round").
4. `peek_order()` returns the upcoming turn order without consuming it — used by the UI to show "who acts next."
5. `remove_battler()` is called when a battler dies (connected via `BattleScene._on_battler_defeated`).

After each battler's turn ends, `Battler.end_turn()` recalculates their `turn_delay`. When the TurnQueue recalculates on the next round, the new delays determine the new order. A character who got a speed buff will have a lower delay and act sooner.

## The BattleScene

BattleScene is the root orchestrator — the conductor of the battle orchestra. It does not contain game logic itself. Instead, it:

1. Spawns battlers from data Resources
2. Wires up signals between battlers, the turn queue, and the state machine
3. Provides query methods (`get_living_party()`, `check_battle_end()`)
4. Manages the battle lifecycle (start, end, persist state)

```gdscript
# game/systems/battle/battle_scene.gd
class_name BattleScene
extends Node2D

## Main battle scene. Orchestrates battlers, turn queue, and state machine.

signal battle_finished(victory: bool)

var party_battlers: Array[PartyBattler] = []
var enemy_battlers: Array[EnemyBattler] = []
var all_battlers: Array[Battler] = []
var current_battler: Battler = null
var current_action: BattleAction = null
var can_escape: bool = true

@onready var party_node: Node2D = $Battlers/PartyBattlers
@onready var enemy_node: Node2D = $Battlers/EnemyBattlers
@onready var turn_queue: TurnQueue = $TurnQueue
@onready var state_machine: BattleStateMachine = $BattleStateMachine
```

### Scene Tree Structure

The BattleScene `.tscn` file has this hierarchy:

```
BattleScene (Node2D)
  ├── BattleBackground (Sprite2D)
  ├── Battlers (Node2D)
  │   ├── PartyBattlers (Node2D)
  │   │   ├── Marker2D  ← position slot 1
  │   │   ├── Marker2D  ← position slot 2
  │   │   ├── Marker2D  ← position slot 3
  │   │   └── Marker2D  ← position slot 4
  │   └── EnemyBattlers (Node2D)
  │       ├── Marker2D  ← position slot 1
  │       ├── Marker2D  ← position slot 2
  │       └── Marker2D  ← position slot 3
  ├── TurnQueue (Node)
  ├── BattleStateMachine (BattleStateMachine)
  │   ├── BattleStart (State)
  │   ├── TurnQueueState (State)
  │   ├── PlayerTurn (State)
  │   ├── ActionSelect (State)
  │   ├── TargetSelect (State)
  │   ├── ActionExecute (State)
  │   ├── EnemyTurn (State)
  │   ├── TurnEnd (State)
  │   ├── Victory (State)
  │   └── Defeat (State)
  └── BattleUI (CanvasLayer)
```

Marker2D nodes define where battlers are placed on screen. Party members line up on the right, enemies on the left (classic JRPG layout). When a battler is spawned, it is positioned at the corresponding marker.

### Setting Up a Battle

```gdscript
func setup_battle(
	party_data: Array[Resource],
	enemy_data: Array[Resource],
	escapable: bool = true,
) -> void:
	can_escape = escapable
	_spawn_party(party_data)
	_spawn_enemies(enemy_data)
	_build_battler_list()
	turn_queue.initialize(all_battlers)
	state_machine.transition_to("BattleStart")
```

The setup sequence:
1. Spawn `PartyBattler` nodes from character data, positioned at markers.
2. Spawn `EnemyBattler` nodes from enemy data, positioned at markers.
3. Build the combined `all_battlers` array.
4. Initialize the turn queue with all combatants.
5. Start the state machine at `BattleStart`.

### Spawning Party Battlers

```gdscript
func _spawn_party(party_data: Array[Resource]) -> void:
	var slots := _get_marker_positions(party_node)
	var visual_scene := load(PARTY_BATTLER_SCENE_PATH) as PackedScene
	var equip_mgr: Node = get_node_or_null("/root/EquipmentManager")

	for i in party_data.size():
		var battler := PartyBattler.new()
		battler.data = party_data[i]
		battler.initialize_from_data(equip_mgr)
		_apply_persistent_state(battler)
		if i < slots.size():
			battler.position = slots[i]
		party_node.add_child(battler)
		party_battlers.append(battler)
```

The critical step is `_apply_persistent_state()` — after initializing a battler to full HP from the Resource, it overwrites HP and EE with the actual current values from PartyManager:

```gdscript
func _apply_persistent_state(battler: PartyBattler) -> void:
	if battler.character_id == &"":
		return
	var pm: Node = get_node_or_null("/root/PartyManager")
	if not pm:
		return
	var state: Dictionary = pm.get_runtime_state(battler.character_id)
	if state.is_empty():
		return
	battler.current_hp = clampi(state["current_hp"], 0, battler.max_hp)
	battler.current_ee = clampi(state["current_ee"], 0, battler.max_ee)
	if battler.current_hp <= 0:
		battler.is_alive = false
```

This is the "read" half of the persistence cycle described in Chapter 9. If a character entered this battle with 85/120 HP, they start the battle with 85 HP — not full.

### Checking Battle End

```gdscript
func check_battle_end() -> int:
	if get_living_enemies().is_empty():
		return 1   # victory
	if get_living_party().is_empty():
		return -1  # defeat
	return 0       # ongoing
```

Returns an int instead of an enum for simplicity — 1 for victory, -1 for defeat, 0 for "keep fighting." Called by TurnQueueState and ActionExecuteState after every action.

### Ending a Battle

```gdscript
func end_battle(victory: bool) -> void:
	_persist_party_state()
	battle_finished.emit(victory)


func _persist_party_state() -> void:
	var pm: Node = get_node_or_null("/root/PartyManager")
	if not pm:
		return
	for battler in party_battlers:
		if battler.character_id != &"":
			pm.set_hp(battler.character_id, battler.current_hp)
			pm.set_ee(battler.character_id, battler.current_ee)
```

This is the "write" half — every party battler's current HP and EE are pushed back to PartyManager. If a character was defeated (0 HP), that 0 persists. The player will need to use a revive item or visit a healer.

## Putting It All Together

Here is how a typical battle flows from start to finish:

1. `BattleManager.start_battle()` is called (by the encounter system or a story event).
2. BattleManager transitions GameManager to the BATTLE state.
3. BattleManager creates a BattleScene instance and calls `setup_battle()` with party data and enemy data.
4. BattleScene spawns all battlers, initializes the turn queue.
5. State machine starts at BattleStart → waits 0.5s → transitions to TurnQueueState.
6. TurnQueueState checks battle end (no — everyone is alive), advances the queue, gets the fastest battler.
7. If PartyBattler → PlayerTurn (show command menu, wait for input).
8. Player selects "Attack" → TargetSelect (show target cursor).
9. Player picks a target → ActionExecute (calculate damage, play animation).
10. ActionExecute checks battle end. If enemies remain → TurnEnd.
11. TurnEnd ticks status effects, recalculates turn delay → TurnQueueState.
12. TurnQueueState advances → gets an EnemyBattler → EnemyTurn.
13. AI picks an action → ActionExecute → TurnEnd → TurnQueueState.
14. ... repeat until all enemies or all party members are defeated.
15. Victory/Defeat state handles rewards or game over.
16. `BattleScene.end_battle()` persists state to PartyManager and emits `battle_finished`.
17. BattleManager cleans up and returns GameManager to OVERWORLD state.

## How It Connects

| System | Connection |
|--------|-----------|
| **PartyManager** | Provides party data, receives HP/EE updates after battle |
| **BattleManager** | Creates BattleScene, manages game state transitions |
| **EquipmentManager** | Provides stat bonuses during battler initialization |
| **BattleUI** | Connects to battler signals for health bars, damage popups |
| **AudioManager** | States trigger battle music, hit sounds, fanfares |

## Common Mistakes

**Putting game logic in BattleScene.** BattleScene is an orchestrator. Damage formulas go in static utility classes. AI logic goes in EnemyBattler. State transitions go in state nodes. BattleScene just wires things together.

**Forgetting to disconnect signals on state exit.** If PlayerTurnState connects to `BattleUI.command_selected` in `enter()`, it must disconnect in `exit()`. Otherwise, the signal fires in a different state and causes chaos. This is the single most common battle system bug.

**Not handling the "everyone is dead" edge case in TurnQueueState.** If the last enemy and last party member kill each other simultaneously (status effect ticks), the turn queue can be empty. Always check `battle_scene.check_battle_end()` before advancing the queue.

**Storing state on the StateMachine instead of BattleScene.** The state machine should be stateless — it only knows which state is current. Battle data (`current_battler`, `current_action`, `party_battlers`) belongs on BattleScene, where all states can access it through the shared reference.

## What Is Next

The foundation is in place: a state machine drives the flow, battlers hold combat state, and the turn queue determines order. In the next chapter, we build the states that handle player input — the command menu, ability and item selection, target picking — and the enemy AI that decides what monsters do on their turn.

# State Machine Best Practices

Patterns for managing game state in a 2D JRPG.

## When to Use State Machines

- **Character behavior**: Idle, Walk, Run, Attack, Hurt, Dead
- **Combat flow**: PlayerTurn, EnemyTurn, ActionSelect, Targeting, Animating
- **Game state**: Exploration, Combat, Dialogue, Menu, Cutscene
- **UI state**: Main, SubMenu, Confirm, Animating
- **Enemy AI**: Patrol, Chase, Attack, Flee, Stunned

## Basic State Machine Pattern

```gdscript
class_name StateMachine
extends Node

## Generic state machine. Manages a set of State children.

signal state_changed(old_state: State, new_state: State)

@export var initial_state: State

var current_state: State


func _ready() -> void:
	for child in get_children():
		if child is State:
			child.state_machine = self
	if initial_state:
		transition_to(initial_state)


func _process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_process(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)


func transition_to(new_state: State) -> void:
	if current_state == new_state:
		return
	var old_state := current_state
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()
	state_changed.emit(old_state, new_state)
```

## Base State

```gdscript
class_name State
extends Node

## Base class for state machine states.

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

## Enum-Based State Machine (simpler, for small state sets)

```gdscript
enum CharacterState {
	IDLE,
	WALK,
	ATTACK,
	HURT,
	DEAD,
}

var state: CharacterState = CharacterState.IDLE


func _physics_process(delta: float) -> void:
	match state:
		CharacterState.IDLE:
			_process_idle(delta)
		CharacterState.WALK:
			_process_walk(delta)
		CharacterState.ATTACK:
			_process_attack(delta)
		CharacterState.HURT:
			_process_hurt(delta)
		CharacterState.DEAD:
			pass


func _change_state(new_state: CharacterState) -> void:
	state = new_state
	match state:
		CharacterState.IDLE:
			sprite.play("idle")
		CharacterState.WALK:
			sprite.play("walk")
		# ...
```

## When to Use Which

| Pattern | States | Complexity | Reusability |
|---------|--------|------------|-------------|
| **Enum** | 2-5 | Low | Not reusable |
| **Node-based** | 5+ | Medium-High | Highly reusable |
| **AnimationTree** | Animation blending | Built-in | Godot-native |

## JRPG-Specific State Machines

### Battle Flow State Machine

```
BattleStates/
  ├── BattleStart     # Initiative roll, intro animation
  ├── TurnQueue       # Determine next actor
  ├── PlayerTurn      # Show action menu
  ├── ActionSelect    # Choose attack/skill/item/flee
  ├── TargetSelect    # Choose target
  ├── ActionExecute   # Play animation, apply damage
  ├── EnemyTurn       # AI decision + execution
  ├── TurnEnd         # Status effects tick, check win/lose
  ├── BattleWon       # XP, loot, transition out
  └── BattleLost      # Game over or retry
```

### Overworld Player State Machine

```
PlayerStates/
  ├── Idle            # Standing still
  ├── Walk            # Moving (4/8 direction)
  ├── Run             # Fast movement (shift held)
  ├── Interact        # Talking to NPC, opening chest
  └── Disabled        # Cutscene, transition, menu open
```

## Anti-Patterns

- State machines that reference concrete sibling states (use signals or parent)
- States that modify other states directly
- Deeply nested state machines without clear hierarchy
- Using strings for state names instead of enums or node references
- Forgetting to call `exit()` on the previous state before `enter()` on the new

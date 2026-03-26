# Module 11: Battle Foundations — State Machines and Turn Order

## What We Have So Far

A connected world with NPCs, dialogue, inventory, and Resources. Everything before this was building the world and its data. Now we tackle the battle system.

## What We're Building This Module

The battle scene skeleton — party and enemies displayed on screen, a state machine controlling the flow of combat, a turn order system, and transitions between the overworld and battle. By the end, battles will start and cycle through turns, even if we can't take actions yet (that's Module 12).

## Scaling Up: From Enum to Node-Based State Machine

In Module 5, we built an enum-based state machine for the player with four states. That approach works great for simple cases — but the battle system has significantly more states with complex transitions:

```
INTRO → TURN_START → PLAYER_CHOICE → ACTION_EXECUTE → CHECK_RESULT → VICTORY → DEFEAT
```

An enum-based `match` block for 7+ states becomes a single massive function that's hard to read and harder to modify. Each state might need its own `_process()`, `enter()`, and `exit()` logic. The node-based pattern handles this cleanly.

### The Node-Based Pattern

Each state is a **Node** with three methods (`enter`, `process`, `exit`), plus a reference to the battle manager. Save this as `res://systems/battle/battle_state.gd`:

```gdscript
extends Node
class_name BattleState
## Base class for all battle states.

var battle_manager: Node  # Set by BattleManager during _ready()

## Called when this state becomes active.
func enter(_context: Dictionary = {}) -> void:
    pass

## Called every frame while this state is active.
func process(_delta: float) -> void:
    pass

## Called when transitioning away from this state.
func exit() -> void:
    pass
```

The state machine node manages which state is active:

```gdscript
extends Node
class_name BattleStateMachine
## Manages battle state transitions.

signal state_changed(old_state: String, new_state: String)

var current_state: BattleState
var states: Dictionary = {}


func _ready() -> void:
    # Register all child nodes as states
    for child in get_children():
        if child is BattleState:
            states[child.name] = child
    if states.is_empty():
        push_error("BattleStateMachine: no states registered. Attach BattleState scripts to child nodes.")


func start(initial_state: String, context: Dictionary = {}) -> void:
    current_state = states.get(initial_state)
    if current_state:
        current_state.enter(context)


func transition_to(new_state_name: String, context: Dictionary = {}) -> void:
    var new_state: BattleState = states.get(new_state_name)
    if not new_state:
        push_error("BattleStateMachine: no state named " + new_state_name)
        return

    var old_name := current_state.name if current_state else ""

    if current_state:
        current_state.exit()

    current_state = new_state
    current_state.enter(context)
    state_changed.emit(old_name, new_state_name)


func _process(delta: float) -> void:
    if current_state:
        current_state.process(delta)
```

Save these as `res://systems/battle/battle_state.gd` and `res://systems/battle/battle_state_machine.gd`.

> **Spiral:** Compare this to Module 5's enum state machine. The enum approach uses `match` in `_physics_process` to route to different functions. The node approach uses polymorphism — each state is a separate Node, and the machine just calls `enter()`/`process()`/`exit()` on whichever one is current. Same pattern, different scale.

## BattlerData: Who's Fighting

We need a Resource to represent someone in battle — combining their base stats with runtime battle state.

Create `res://resources/battler_data.gd`:

```gdscript
extends Resource
class_name BattlerData
## Runtime data for a combatant in battle.

@export var character_data: CharacterData
@export var is_player_controlled: bool = true

# Runtime state (not saved to .tres — set during battle)
var current_hp: int = 0
var current_mp: int = 0
var current_attack: int = 0
var current_defense: int = 0
var current_speed: int = 0
var defense_boost: int = 0  # Temporary boost from Defend action


func initialize_from_character() -> void:
    if not character_data:
        return
    current_hp = character_data.max_hp
    current_mp = character_data.max_mp
    current_attack = character_data.attack
    current_defense = character_data.defense
    current_speed = character_data.speed


func get_effective_defense() -> int:
    return current_defense + defense_boost


func is_alive() -> bool:
    return current_hp > 0


func take_damage(amount: int) -> int:
    var actual_damage: int = max(1, amount)
    current_hp = max(0, current_hp - actual_damage)
    return actual_damage


func heal(amount: int) -> int:
    var old_hp := current_hp
    current_hp = min(current_hp + amount, character_data.max_hp)
    return current_hp - old_hp  # Actual amount healed
```

## The Battle Scene

Create `res://scenes/battle/battle.tscn`:

### Scene Layout

```
Battle (Node2D)
├── Background (TextureRect or ColorRect)
├── PartyPositions (Node2D)
│   ├── PartySlot0 (Marker2D)
│   ├── PartySlot1 (Marker2D)
│   └── PartySlot2 (Marker2D)
├── EnemyPositions (Node2D)
│   ├── EnemySlot0 (Marker2D)
│   ├── EnemySlot1 (Marker2D)
│   └── EnemySlot2 (Marker2D)
├── BattleUI (CanvasLayer)
│   └── ... (we'll build this in Module 12)
└── StateMachine (BattleStateMachine)
    ├── Intro (BattleState)
    ├── TurnStart (BattleState)
    ├── PlayerChoice (BattleState)
    ├── ActionExecute (BattleState)
    ├── CheckResult (BattleState)
    ├── Victory (BattleState)
    └── Defeat (BattleState)
```

Position the Marker2D nodes to create the classic JRPG battle layout. In the Inspector, set the `position` property for each:

| Node | Position | Role |
|------|----------|------|
| PartySlot0 | (240, 60) | Top party member |
| PartySlot1 | (240, 120) | Middle party member |
| PartySlot2 | (240, 180) | Bottom party member |
| EnemySlot0 | (80, 60) | Top enemy |
| EnemySlot1 | (80, 120) | Middle enemy |
| EnemySlot2 | (80, 180) | Bottom enemy |

Party on the right, enemies on the left, with space in the center for action animations.

For the background, add the `ColorRect` node first. Set its color to a dark blue-grey (e.g., `Color(0.15, 0.15, 0.25)`) and set its Layout to **Full Rect** (select the node, then in the toolbar use Layout → Full Rect).

### Battler Sprites

We need sprites for both party members and enemies in battle. Create a simple battler scene `res://entities/battle/battler_sprite.tscn`:

```
BattlerSprite (Node2D)
└── Sprite (Sprite2D)
```

With script `res://entities/battle/battler_sprite.gd`:

```gdscript
extends Node2D
## Visual representation of a combatant in battle.

var battler_data: BattlerData

@onready var _sprite: Sprite2D = $Sprite


func setup(data: BattlerData) -> void:
    battler_data = data
    add_to_group("battler_sprites")
    if data.character_data and data.character_data.portrait:
        _sprite.texture = data.character_data.portrait
```

## The BattleManager

The battle manager orchestrates the entire fight. Create `res://systems/battle/battle_manager.gd` and **attach it to the `Battle` root node** in `battle.tscn`:

> **Note:** BattleManager is NOT an autoload — it is the root script of `battle.tscn`, which means it only exists while a battle is happening. The SceneManager loads the battle scene and calls its `initialize_battle()` method.

```gdscript
extends Node2D
## Orchestrates battle flow. Attached to the Battle scene root (Node2D).

signal battle_started(party: Array[BattlerData], enemies: Array[BattlerData])
signal turn_started(battler: BattlerData)
signal action_executed(attacker: BattlerData, target: BattlerData, damage: int)
signal battle_won
signal battle_lost

var party: Array[BattlerData] = []
var enemies: Array[BattlerData] = []
var turn_queue: Array[BattlerData] = []
var current_battler: BattlerData

@onready var _state_machine: BattleStateMachine = $StateMachine
@onready var _party_positions: Node2D = $PartyPositions
@onready var _enemy_positions: Node2D = $EnemyPositions

const BattlerSpriteScene := preload("res://entities/battle/battler_sprite.tscn")


func _ready() -> void:
    # Pass a reference to this manager into every state
    for state in _state_machine.states.values():
        state.battle_manager = self
    # Don't start the state machine here — wait for initialize_battle()
    # to populate party and enemies first.


func initialize_battle(party_data: Array[BattlerData], enemy_data: Array[BattlerData]) -> void:
    party = party_data
    enemies = enemy_data

    # Initialize runtime stats
    for battler in party:
        battler.initialize_from_character()
    for battler in enemies:
        battler.initialize_from_character()

    # Spawn sprites
    _spawn_battler_sprites(party, _party_positions)
    _spawn_battler_sprites(enemies, _enemy_positions)

    battle_started.emit(party, enemies)

    # NOW start the state machine — data is ready
    _state_machine.start("Intro")


func _spawn_battler_sprites(battlers: Array[BattlerData], positions: Node2D) -> void:
    var slots := positions.get_children()
    for i in battlers.size():
        if i >= slots.size():
            break
        var sprite_node: Node2D = BattlerSpriteScene.instantiate()
        slots[i].add_child(sprite_node)
        sprite_node.setup(battlers[i])


func build_turn_queue() -> void:
    turn_queue.clear()

    # Gather all alive combatants
    var all_battlers: Array[BattlerData] = []
    for b in party:
        if b.is_alive():
            all_battlers.append(b)
    for b in enemies:
        if b.is_alive():
            all_battlers.append(b)

    # Sort by speed (highest first)
    all_battlers.sort_custom(func(a: BattlerData, b: BattlerData) -> bool:
        return a.current_speed > b.current_speed
    )

    turn_queue = all_battlers


func get_next_battler() -> BattlerData:
    if turn_queue.is_empty():
        return null
    return turn_queue.pop_front()


func is_party_alive() -> bool:
    return party.any(func(b: BattlerData) -> bool: return b.is_alive())


func is_enemy_alive() -> bool:
    return enemies.any(func(b: BattlerData) -> bool: return b.is_alive())


func get_alive_enemies() -> Array[BattlerData]:
    return enemies.filter(func(b: BattlerData) -> bool: return b.is_alive())


func get_alive_party() -> Array[BattlerData]:
    return party.filter(func(b: BattlerData) -> bool: return b.is_alive())
```

## Implementing the Battle States

Each state is a small script. Let's implement them one by one.

Save each state script in `res://systems/battle/states/`. After creating all the scripts, you need to **attach each script to its corresponding node** in the scene tree:

1. In the editor, select the **Intro** node under StateMachine.
2. In the Inspector, click the Script dropdown and choose **Load**, then select `intro_state.gd`.
3. Repeat for each state node: TurnStart → `turn_start_state.gd`, PlayerChoice → `player_choice_state.gd`, etc.

Alternatively, you can right-click each state node → **Attach Script** → change the path to the existing file.

### Intro State

Save as `res://systems/battle/states/intro_state.gd`:

```gdscript
extends BattleState
## Brief intro animation before combat begins.


func enter(_context: Dictionary = {}) -> void:
    # In a full game, play a swipe animation or battle start effect
    # For now, just wait briefly and proceed
    await get_tree().create_timer(0.5).timeout
    battle_manager._state_machine.transition_to("TurnStart")
```

### TurnStart State

Save as `res://systems/battle/states/turn_start_state.gd`:

```gdscript
extends BattleState
## Builds the turn queue and starts processing turns.


func enter(_context: Dictionary = {}) -> void:
    battle_manager.build_turn_queue()
    _process_next_turn()


func _process_next_turn() -> void:
    var battler := battle_manager.get_next_battler()

    if battler == null:
        # All turns exhausted — start a new round
        battle_manager._state_machine.transition_to("TurnStart")
        return

    battle_manager.current_battler = battler

    # Reset temporary buffs at the start of each turn
    battler.defense_boost = 0

    battle_manager.turn_started.emit(battler)

    if battler.is_player_controlled:
        battle_manager._state_machine.transition_to("PlayerChoice", {battler = battler})
    else:
        battle_manager._state_machine.transition_to("ActionExecute", {
            battler = battler,
            action = "enemy_turn",
        })
```

### PlayerChoice State

Save as `res://systems/battle/states/player_choice_state.gd`:

```gdscript
extends BattleState
## Waits for the player to choose an action.

var _active_battler: BattlerData


func enter(context: Dictionary = {}) -> void:
    _active_battler = context.get("battler")
    # Module 12 will add the battle menu UI here.
    # For now, auto-attack the first enemy as a placeholder.
    print(_active_battler.character_data.display_name + "'s turn! (auto-attacking)")
    await get_tree().create_timer(0.3).timeout

    var targets := battle_manager.get_alive_enemies()
    if targets.is_empty():
        return

    battle_manager._state_machine.transition_to("ActionExecute", {
        battler = _active_battler,
        action = "attack",
        target = targets[0],
    })
```

### ActionExecute State

Save as `res://systems/battle/states/action_execute_state.gd`:

```gdscript
extends BattleState
## Executes the chosen action (attack, defend, magic, item, enemy AI).


func enter(context: Dictionary = {}) -> void:
    var battler: BattlerData = context.get("battler")
    var action: String = context.get("action", "attack")
    var target: BattlerData = context.get("target")

    match action:
        "attack":
            _execute_attack(battler, target)
        "enemy_turn":
            _execute_enemy_turn(battler)
        _:
            print("Unknown action: ", action)

    # Brief pause for the action to feel impactful
    await get_tree().create_timer(0.5).timeout

    battle_manager._state_machine.transition_to("CheckResult")


func _execute_attack(attacker: BattlerData, target: BattlerData) -> void:
    var damage: int = max(1, attacker.current_attack - target.get_effective_defense())
    damage += randi_range(-2, 2)  # Small random variance
    damage = max(1, damage)

    var actual := target.take_damage(damage)
    battle_manager.action_executed.emit(attacker, target, actual)
    print(attacker.character_data.display_name + " attacks " +
          target.character_data.display_name + " for " + str(actual) + " damage!")


func _execute_enemy_turn(battler: BattlerData) -> void:
    # Simple AI: attack a random party member
    var targets := battle_manager.get_alive_party()
    if targets.is_empty():
        return

    var target: BattlerData = targets[randi() % targets.size()]
    _execute_attack(battler, target)
```

### CheckResult State

Save as `res://systems/battle/states/check_result_state.gd`:

```gdscript
extends BattleState
## Checks if the battle is over after an action.


func enter(_context: Dictionary = {}) -> void:
    if not battle_manager.is_enemy_alive():
        battle_manager._state_machine.transition_to("Victory")
    elif not battle_manager.is_party_alive():
        battle_manager._state_machine.transition_to("Defeat")
    else:
        # More turns to process — go back to TurnStart
        # The TurnStart state will get the next battler from the queue
        _process_next_in_queue()


func _process_next_in_queue() -> void:
    var battler := battle_manager.get_next_battler()

    if battler == null:
        # Round over — start a new round
        battle_manager._state_machine.transition_to("TurnStart")
        return

    battle_manager.current_battler = battler
    battler.defense_boost = 0
    battle_manager.turn_started.emit(battler)

    if battler.is_player_controlled:
        battle_manager._state_machine.transition_to("PlayerChoice", {battler = battler})
    else:
        battle_manager._state_machine.transition_to("ActionExecute", {
            battler = battler,
            action = "enemy_turn",
        })
```

### Victory and Defeat States

Save as `res://systems/battle/states/victory_state.gd`:

```gdscript
# victory_state.gd
extends BattleState
## Battle won! Show results and return to overworld.


func enter(_context: Dictionary = {}) -> void:
    print("Victory! All enemies defeated!")
    battle_manager.battle_won.emit()
    # Module 15 will add XP, gold, and item drops here
    await get_tree().create_timer(2.0).timeout
    # Return to overworld (Module 15 will handle this properly)
```

Save as `res://systems/battle/states/defeat_state.gd`:

```gdscript
# defeat_state.gd
extends BattleState
## Party wiped. Game over flow.


func enter(_context: Dictionary = {}) -> void:
    print("Defeat... the party has fallen.")
    battle_manager.battle_lost.emit()
    # Module 15 will add the game over screen
    await get_tree().create_timer(2.0).timeout
```

## Transitioning to Battle

The overworld needs to trigger battle transitions. Update the SceneManager to support battle-specific transitions:

```gdscript
# Add to scene_manager.gd

var _previous_scene_path: String = ""
var _previous_player_position: Vector2 = Vector2.ZERO


func start_battle(encounter_data: Dictionary) -> void:
    if _is_transitioning:
        return

    _is_transitioning = true

    # Remember where we were
    var player := get_tree().get_first_node_in_group("player")
    if player:
        _previous_player_position = player.global_position
    _previous_scene_path = get_tree().current_scene.scene_file_path

    transition_started.emit()
    _anim_player.play("fade_out")
    await _anim_player.animation_finished

    get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
    await get_tree().process_frame

    # Initialize the battle with encounter data
    var battle_scene := get_tree().current_scene
    if battle_scene.has_method("initialize_battle"):
        battle_scene.initialize_battle(
            encounter_data.get("party", []),
            encounter_data.get("enemies", []),
        )

    _anim_player.play("fade_in")
    await _anim_player.animation_finished
    _is_transitioning = false
    transition_finished.emit()


func return_from_battle() -> void:
    if _previous_scene_path.is_empty():
        return

    change_scene(_previous_scene_path, "default")
    # After scene loads, restore player position
    await transition_finished
    var player := get_tree().get_first_node_in_group("player")
    if player:
        player.global_position = _previous_player_position
```

## Testing the Battle

For now, you can test by adding a temporary button or trigger in Willowbrook that starts a battle. Add this to `willowbrook.gd`:

```gdscript
func _input(event: InputEvent) -> void:
    # Temporary: press B to start a test battle
    if event is InputEventKey and event.pressed and event.keycode == KEY_B:
        _start_test_battle()


func _start_test_battle() -> void:
    var hero_data := BattlerData.new()
    hero_data.character_data = load("res://data/characters/aiden.tres")
    hero_data.is_player_controlled = true

    # Create a temporary enemy
    var enemy_char := CharacterData.new()
    enemy_char.display_name = "Slime"
    enemy_char.max_hp = 30
    enemy_char.attack = 5
    enemy_char.defense = 2
    enemy_char.speed = 4

    var enemy_data := BattlerData.new()
    enemy_data.character_data = enemy_char
    enemy_data.is_player_controlled = false

    SceneManager.start_battle({
        party = [hero_data],
        enemies = [enemy_data],
    })
```

## The Battle Flow

Here's the complete state flow visualized:

```
[INTRO] → Brief pause/animation
    ↓
[TURN_START] → Build turn queue (sorted by speed)
    ↓
[PLAYER_CHOICE] or [ACTION_EXECUTE (enemy)]
    ↓                        ↓
(Player picks action)   (Enemy AI picks action)
    ↓                        ↓
[ACTION_EXECUTE] ←──────────┘
    ↓
[CHECK_RESULT]
    ↓
    ├── All enemies dead → [VICTORY]
    ├── All party dead → [DEFEAT]
    └── More turns → next battler in queue (PlayerChoice or ActionExecute)
         └── Queue empty → back to [TURN_START] for new round
```

Each state is isolated. Adding new actions (magic, items, defend) means adding branches in `PlayerChoice` and `ActionExecute` — not restructuring the entire flow.

> **See:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html) — the base class for all scene tree nodes. The node-based state machine pattern uses `get_children()` and polymorphism.

> **See:** [SceneTree.create_timer()](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-create-timer) — creates a one-shot timer. Used with `await` in states for pacing.

> **See:** [Array.sort_custom()](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-sort-custom) — custom sorting with a callable. Used for speed-based turn ordering.

**Autoload reference card** (unchanged from Module 10 — no new autoloads this module):

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 6 | Scene transitions with fade effects |
| InventoryManager | 10 | Item storage, add/remove, signals |

> **Note:** BattleManager is NOT an autoload. It is the root script of `battle.tscn` and only exists during battles. The SceneManager loads the battle scene and calls `initialize_battle()` on it.

## What We've Learned

- **Node-based state machines** use child Nodes with `enter()`/`process()`/`exit()` methods, managed by a machine node. Better than enums for complex state flows.
- **BattlerData** is a Resource combining character stats with runtime battle state (current HP, temporary buffs).
- **Turn order** is speed-based: sort all alive battlers by speed, process them in order.
- The **battle scene** has party on one side, enemies on the other, with Marker2D nodes for positioning.
- **State transitions** pass **context dictionaries** so states can share data (the active battler, the chosen target, the action type).
- The **SceneManager** remembers the previous scene and player position for returning from battle.
- Each battle state is a separate script file — easy to modify one state without touching others.

## What You Should See

When you press B (our temporary test trigger) in Willowbrook:
- Screen fades to black
- Battle scene appears with the hero and a Slime
- Output panel shows turn-by-turn combat:
  - "Aiden's turn! (auto-attacking)"
  - "Aiden attacks Slime for 10 damage!"
  - "Slime attacks Aiden for 5 damage!"
- Combat continues until one side is defeated
- "Victory!" or "Defeat..." appears in output

## Next Module

The battle runs automatically — the player can't choose actions yet. In **Module 12: Player Actions**, we'll build the battle menu UI (Attack/Magic/Defend/Item), implement the command pattern for actions, add target selection, and create battle animations with Tweens. The battle system will transform from a debug log into a visual, interactive experience.

# Merged Tutorial Part IV: Combat and the Dungeon

This generated file combines the tutorial Markdown files for this tutorial part.

## Included Files

- `14_battle_foundations.md`
- `15_player_actions.md`
- `16_crystal_cavern.md`
- `17_enemies_and_ai.md`
- `18_victory_and_leveling.md`
- `19_part_iv_review.md`

---

<!-- Source: 14_battle_foundations.md -->

# Module 14: Battle Foundations: State Machines and Turn Order

## What We Have So Far

A connected world with NPCs, dialogue, inventory, and Resources. Everything before this was building the world and its data. Now we tackle the battle system.

## What We're Building This Module

The battle scene skeleton: party and enemies displayed on screen, a state machine controlling the flow of combat, a turn order system, and transitions between the overworld and battle. By the end, battles will start and cycle through turns, even if we can't take actions yet (that's Module 15).

## Scaling Up: From Enum to Node-Based State Machine

A JRPG battle is one of the most complex state flows in all of game development. Think about a single turn in Final Fantasy VI: the game waits for your ATB gauge to fill, shows the command menu, you pick Magic, it shows the spell list, you pick Fire, it shows the target list, you pick an enemy, the character runs forward, the spell animation plays, damage numbers pop up, the game checks if anyone died, and then it moves to the next character. Each of those phases has different rules about what input is allowed, what's displayed, and what happens next.

In Module 6, we built an enum-based state machine for the player with four states. That approach works great for simple cases, but the battle system has significantly more states with complex transitions:

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

> **Spiral:** Compare this to Module 6's enum state machine. The enum approach uses `match` in `_physics_process` to route to different functions. The node approach uses polymorphism: each state is a separate Node, and the machine just calls `enter()`/`process()`/`exit()` on whichever one is current. Same pattern, different scale.

## BattlerData: Who's Fighting

Characters in an RPG exist in two contexts: their permanent identity (name, base stats, level) and their temporary battle state (current HP this fight, a defense buff that wears off next turn). In Final Fantasy, Cloud's base stats live on his character sheet, but when he uses Defend, the temporary defense boost only lasts until his next turn. We need a wrapper that holds both: the permanent data from CharacterData and the temporary state that exists only during one battle.

We need a Resource to represent someone in battle, combining their base stats with runtime battle state.

Create `res://resources/battler_data.gd`:

```gdscript
extends Resource
class_name BattlerData
## Runtime data for a combatant in battle.

@export var character_data: CharacterData
@export var is_player_controlled: bool = true

# Runtime state (not saved to .tres, set during battle)
var current_hp: int = 0
var current_mp: int = 0
var current_attack: int = 0
var current_defense: int = 0
var current_speed: int = 0
var defense_boost: int = 0  # Temporary boost from Defend action


func initialize_from_character() -> void:
    if not character_data:
        return
    current_hp = character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp
    current_mp = character_data.current_mp if character_data.current_mp > 0 else character_data.max_mp
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
│   └── ... (we'll build this in Module 15)
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
    else:
        # Fallback so sprites are always visible during testing
        _sprite.texture = preload("res://icon.svg")
```

> **Important:** Battler sprites will be invisible until you set the `portrait` property on your CharacterData resources. For testing, open `res://data/characters/aiden.tres` in the Inspector and drag `res://icon.svg` into the `portrait` field. For enemies created in code, set `char_data.portrait = preload("res://icon.svg")` in the test battle setup. The fallback code above handles this automatically.

## The BattleManager

The battle manager orchestrates the entire fight. Create `res://systems/battle/battle_manager.gd` and **attach it to the `Battle` root node** in `battle.tscn`:

> **Note:** BattleManager is NOT an autoload. It is the root script of `battle.tscn`, which means it only exists while a battle is happening. The SceneManager loads the battle scene and calls its `initialize_battle()` method.

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
    # Don't start the state machine here. Wait for initialize_battle()
    # to populate party and enemies first.
    #
    # NOTE: Child nodes' _ready() runs BEFORE the parent's _ready().
    # That means each state's _ready() has already fired by this point,
    # so battle_manager was null during their _ready(). Never access
    # battle_manager in a state's _ready(). Use enter() instead.


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

    # NOW start the state machine, data is ready
    _state_machine.start("Intro")


func transition_to_state(state_name: String, context: Dictionary = {}) -> void:
    _state_machine.transition_to(state_name, context)


func _spawn_battler_sprites(battlers: Array[BattlerData], positions: Node2D) -> void:
    var slots := positions.get_children()
    for i in battlers.size():
        if i >= slots.size():
            break
        var sprite_node: Node2D = BattlerSpriteScene.instantiate()
        slots[i].add_child(sprite_node)
        sprite_node.setup(battlers[i])
```

Turn order is what makes the Speed stat matter. In Dragon Quest, faster characters act first, which means a healer with high speed can save a dying ally before the enemy lands the killing blow. A slow but powerful warrior might deal massive damage but always acts last, creating the risk that the enemy attacks first. This single mechanic, who goes when, turns a stat number into a tactical consideration.

```gdscript
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

    # Sort by speed (highest first). sort_custom() takes an inline function
    # (also called a lambda): func(a, b) -> bool returns true if a should
    # come before b. GDScript supports these for one-off comparisons.
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

Each state is a small script. Here they are, one by one.

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
    battle_manager.transition_to_state("TurnStart")
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
        # All turns exhausted, start a new round
        battle_manager.transition_to_state("TurnStart")
        return

    battle_manager.current_battler = battler

    # Reset temporary buffs at the start of each turn
    battler.defense_boost = 0

    battle_manager.turn_started.emit(battler)

    if battler.is_player_controlled:
        battle_manager.transition_to_state("PlayerChoice", {battler = battler})
    else:
        battle_manager.transition_to_state("ActionExecute", {
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
    # Module 15 will add the battle menu UI here.
    # For now, auto-attack the first enemy as a placeholder.
    print(_active_battler.character_data.display_name + "'s turn! (auto-attacking)")
    await get_tree().create_timer(0.3).timeout

    var targets := battle_manager.get_alive_enemies()
    if targets.is_empty():
        return

    battle_manager.transition_to_state("ActionExecute", {
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

    battle_manager.transition_to_state("CheckResult")


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
        battle_manager.transition_to_state("Victory")
    elif not battle_manager.is_party_alive():
        battle_manager.transition_to_state("Defeat")
    else:
        # More turns to process, go back to TurnStart
        # The TurnStart state will get the next battler from the queue
        _process_next_in_queue()


func _process_next_in_queue() -> void:
    var battler := battle_manager.get_next_battler()

    if battler == null:
        # Round over, start a new round
        battle_manager.transition_to_state("TurnStart")
        return

    battle_manager.current_battler = battler
    battler.defense_boost = 0
    battle_manager.turn_started.emit(battler)

    if battler.is_player_controlled:
        battle_manager.transition_to_state("PlayerChoice", {battler = battler})
    else:
        battle_manager.transition_to_state("ActionExecute", {
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
    # Module 18 will add XP, gold, and item drops here
    await get_tree().create_timer(2.0).timeout
    # Return to overworld (Module 18 will handle this properly)
```

Save as `res://systems/battle/states/defeat_state.gd`:

```gdscript
# defeat_state.gd
extends BattleState
## Party wiped. Game over flow.


func enter(_context: Dictionary = {}) -> void:
    print("Defeat... the party has fallen.")
    battle_manager.battle_lost.emit()
    # Module 18 will add the game over screen
    await get_tree().create_timer(2.0).timeout
```

## Transitioning to Battle

The overworld needs to trigger battle transitions. Update the SceneManager to support battle-specific transitions:

```gdscript
# Add to scene_manager.gd
# Place these two variables after the existing _is_transitioning variable.
# Place both methods after the existing _place_player_at_spawn() method.

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
    await get_tree().scene_changed

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

Each state is isolated. Adding new actions (magic, items, defend) means adding branches in `PlayerChoice` and `ActionExecute`, not restructuring the entire flow.

> **See:** [Node](https://docs.godotengine.org/en/stable/classes/class_node.html): the base class for all scene tree nodes. The node-based state machine pattern uses `get_children()` and polymorphism.

> **See:** [SceneTree.create_timer()](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-create-timer): creates a one-shot timer. Used with `await` in states for pacing.

> **See:** [Array.sort_custom()](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-sort-custom): custom sorting with a callable. Used for speed-based turn ordering.

**Autoload reference card** (unchanged from Module 12; no new autoloads this module):

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |

> **Note:** BattleManager is NOT an autoload. It is the root script of `battle.tscn` and only exists during battles. The SceneManager loads the battle scene and calls `initialize_battle()` on it.

## State Machines vs State Stacks

We've now seen two kinds of state management in Crystal Saga. They solve different problems, and knowing which one to reach for will save you from architectural headaches as your game grows.

**State Machine** (mutually exclusive states): Only one state is active at a time. Transitioning from PLAYER_CHOICE to ACTION_EXECUTE *replaces* the active state. The battle system uses this because you're always in exactly one phase of combat.

**State Stack** (layered states): Multiple states can be active simultaneously, stacked on top of each other. Menus are the classic JRPG example: the game world stays loaded, the tree is paused, and a UI layer sits on top until the player closes it.

That is **not** what Crystal Saga's battle flow is doing right now. `SceneManager.start_battle()` stores the previous scene path and player position, changes to the battle scene, and `return_from_battle()` reconstructs the overworld scene afterward. The previous scene is destroyed and later rebuilt; it is not preserved underneath battle.

The same pattern applies to menus: opening the inventory pushes a new layer on top of the game. The game world is still there, just paused. Closing the menu pops the layer and the game resumes.

| Pattern | Active States | Example | When to Use |
|---------|--------------|---------|-------------|
| State Machine | Exactly one | Battle phases, player movement states | Mutually exclusive modes |
| State Stack | Many (layered) | Game + pause menu, game + dialogue, menu + sub-menu | Modes that overlay other modes |

The rule of thumb: if the previous state should be *destroyed* when you leave it, use a state machine or a scene swap. If it should be *preserved* underneath, use a state stack or overlay UI.

## Engineering Contract

- **Global state:** BattleManager is scene-local, not an autoload.
- **Public surface:** `initialize_battle()`, `transition_to_state()`, battle result signals, and read-only battle data used by states.
- **Invariant:** States transition through the BattleManager facade and do not reach into private `_state_machine` ownership.
- **Failure behavior:** Unknown state names log an error and leave the current state unchanged.
- **Copy semantics:** `BattlerData` is runtime battle state; persistent CharacterData is synced only at defined battle boundaries.

## Engine Gotcha

Node-based state machines are ordinary scene trees. Child state names are string keys, so renaming a state node without updating transition calls breaks runtime flow.

## What We've Learned

- **Node-based state machines** use child Nodes with `enter()`/`process()`/`exit()` methods, managed by a machine node. Better than enums for complex state flows.
- **State machines vs state stacks**: machines for exclusive states (battle phases), stacks for layered UI (pause and menus). Crystal Saga's current battle transition is a scene swap plus reconstruction, not an overworld-under-battle stack.
- **BattlerData** is a Resource combining character stats with runtime battle state (current HP, temporary buffs).
- **Turn order** is speed-based: sort all alive battlers by speed, process them in order.
- The **battle scene** has party on one side, enemies on the other, with Marker2D nodes for positioning.
- **State transitions** pass **context dictionaries** so states can share data (the active battler, the chosen target, the action type).
- The **SceneManager** remembers the previous scene and player position for returning from battle.
- Each battle state is a separate script file, easy to modify one state without touching others.

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

The battle runs automatically, and the player can't choose actions yet. In **Module 15: Player Actions**, we'll build the battle menu UI (Attack/Magic/Defend/Item), implement the command pattern for actions, add target selection, and create battle animations with Tweens. The battle system will go from print output to visual, interactive combat.


---

<!-- Source: 15_player_actions.md -->

# Module 15: Player Actions: Attack, Defend, Magic, Items

## What We Have So Far

A battle system with a node-based state machine, turn order, and automatic combat. But the player can't make choices. Everything happens automatically.

## What We're Building This Module

The battle menu (Attack/Magic/Defend/Item), target selection, the damage formula, battle animations, and floating damage numbers. By the end, battles will be fully interactive.

## The Battle Menu UI

Create `res://ui/battle/battle_menu.tscn`:

```
BattleMenu (PanelContainer)
└── MarginContainer
    └── ActionList (VBoxContainer)
        ├── AttackButton (Button: "Attack")
        ├── MagicButton (Button: "Magic")
        ├── DefendButton (Button: "Defend")
        └── ItemButton (Button: "Item")
```

Script `res://ui/battle/battle_menu.gd`:

```gdscript
extends PanelContainer
## The main battle action menu.

signal action_chosen(action: String)

@onready var _attack_btn: Button = $MarginContainer/ActionList/AttackButton
@onready var _magic_btn: Button = $MarginContainer/ActionList/MagicButton
@onready var _defend_btn: Button = $MarginContainer/ActionList/DefendButton
@onready var _item_btn: Button = $MarginContainer/ActionList/ItemButton


func _ready() -> void:
    _attack_btn.pressed.connect(func() -> void: action_chosen.emit("attack"))
    _magic_btn.disabled = true
    _magic_btn.tooltip_text = "Magic is a future extension."
    _defend_btn.pressed.connect(func() -> void: action_chosen.emit("defend"))
    _item_btn.pressed.connect(func() -> void: action_chosen.emit("item"))


func show_menu() -> void:
    visible = true
    _attack_btn.grab_focus()


func hide_menu() -> void:
    visible = false
```

> **See:** [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html): focus navigation between buttons with keyboard/gamepad.

## The Command Pattern

In Final Fantasy X, the game shows you a preview of the turn order before you commit to an action. Choosing Haste on yourself moves your icon up in the queue; choosing a slow spell pushes it back. This preview is only possible because actions are data objects that can be inspected before execution. If "Attack" were just a function call, there would be nothing to preview. By representing actions as data, we separate the decision from the execution.

Each battle action follows the same interface: an attacker does something to a target. We structure this as a dictionary command:

```gdscript
var command: Dictionary = {
    action = "attack",     # What to do
    battler = battler,     # Who does it
    target = target,       # Who receives it
    item = null,           # Optional: which item (for item use)
}
```

This pattern keeps the action execution generic. The `ActionExecute` state doesn't need to know the details of every possible action; it just reads the command dictionary.

## Target Selection

Target selection is where strategy enters combat. In Earthbound, choosing to focus fire on the Territorial Oak instead of spreading damage across all enemies is often the difference between a clean fight and a party wipe. Without target selection, combat would be "press Attack and watch numbers happen." With it, every attack is a decision.

When the player chooses Attack, they need to pick which enemy to target. Create a target selection sub-system:

```gdscript
extends PanelContainer
## Shows a list of targets for the player to select.

signal target_selected(target: BattlerData)
signal cancelled

@onready var _target_list: VBoxContainer = $MarginContainer/TargetList


func show_targets(targets: Array[BattlerData]) -> void:
    visible = true

    for child in _target_list.get_children():
        child.queue_free()

    await get_tree().process_frame

    for target in targets:
        var button := Button.new()
        button.text = target.character_data.display_name + " (HP: " + str(target.current_hp) + ")"
        button.pressed.connect(func() -> void: target_selected.emit(target))
        _target_list.add_child(button)

    await get_tree().process_frame
    if _target_list.get_child_count() > 0:
        _target_list.get_child(0).grab_focus()


func hide_targets() -> void:
    visible = false


func _unhandled_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        cancelled.emit()
        get_viewport().set_input_as_handled()
```

Save this as `res://ui/battle/target_select.gd`, and create `res://ui/battle/target_select.tscn` with this scene tree:

```
TargetSelect (PanelContainer)
└── MarginContainer
    └── TargetList (VBoxContainer)
```

## Integrating the Battle Menu into the Battle Scene

Open `battle.tscn` and instance both UI scenes under the `BattleUI` CanvasLayer:

```
BattleUI (CanvasLayer, layer = 10)
├── BattleMenu (instance of battle_menu.tscn)
└── TargetSelect (instance of target_select.tscn)
```

Set both to **visible = false** initially in the Inspector.

## Updating the PlayerChoice State

This is the critical wiring that connects the menu to the state machine. **Replace** the contents of `res://systems/battle/states/player_choice_state.gd` (the Module 14 placeholder that auto-attacked):

```gdscript
extends BattleState
## Waits for the player to choose an action from the battle menu.

var _active_battler: BattlerData
var _battle_menu: PanelContainer
var _target_select: PanelContainer


func enter(context: Dictionary = {}) -> void:
    _active_battler = context.get("battler")

    # Find UI nodes in the battle scene
    _battle_menu = get_tree().current_scene.get_node("BattleUI/BattleMenu")
    _target_select = get_tree().current_scene.get_node("BattleUI/TargetSelect")

    # Connect signals
    _battle_menu.action_chosen.connect(_on_action_chosen)
    _target_select.target_selected.connect(_on_target_selected)
    _target_select.cancelled.connect(_on_target_cancelled)

    _battle_menu.show_menu()


func exit() -> void:
    _battle_menu.hide_menu()
    _target_select.hide_targets()

    # Disconnect to avoid duplicate connections on re-entry
    if _battle_menu.action_chosen.is_connected(_on_action_chosen):
        _battle_menu.action_chosen.disconnect(_on_action_chosen)
    if _target_select.target_selected.is_connected(_on_target_selected):
        _target_select.target_selected.disconnect(_on_target_selected)
    if _target_select.cancelled.is_connected(_on_target_cancelled):
        _target_select.cancelled.disconnect(_on_target_cancelled)


func _on_action_chosen(action: String) -> void:
    match action:
        "attack":
            _battle_menu.hide_menu()
            _target_select.show_targets(battle_manager.get_alive_enemies())
        "defend":
            battle_manager.transition_to_state("ActionExecute", {
                battler = _active_battler,
                action = "defend",
            })
        "item":
            # Item use in battle (simplified for now)
            var consumables := InventoryManager.get_consumables()
            if consumables.is_empty():
                print("No items!")
                _battle_menu.show_menu()
            else:
                # Use first consumable on self (simplified)
                var item: ItemData = consumables[0].item
                battle_manager.transition_to_state("ActionExecute", {
                    battler = _active_battler,
                    action = "item",
                    target = _active_battler,
                    item = item,
                })


func _on_target_selected(target: BattlerData) -> void:
    _target_select.hide_targets()
    battle_manager.transition_to_state("ActionExecute", {
        battler = _active_battler,
        action = "attack",
        target = target,
    })


func _on_target_cancelled() -> void:
    _target_select.hide_targets()
    _battle_menu.show_menu()
```

This wires the complete flow: menu appears → player picks action → target selection if needed → command passed to ActionExecute.

> **Note:** Magic is visible in the menu but disabled. We keep the button because most JRPG battle menus reserve space for spells, but `AbilityData` is a future extension, not part of this core tutorial. Item use is simplified for now: it picks the first consumable automatically. In a full game, you'd show an item selection sub-menu.

## The Damage Formula

### Why Stats Exist

Before writing a formula, think about *why* stats exist at all. There are three good reasons to add a stat to your RPG:

1. **The simulation needs it.** If you want to calculate "who hits harder," you need a Strength stat. If you want "who acts first," you need Speed. Stats are numbers that feed your combat math.
2. **It defines characters by difference.** A dragon should feel different from a goblin. If you only have HP and Attack, every enemy is just a bag of hit points. Speed, Defense, and Magic create variety.
3. **It creates player choices.** Stats that the player can influence (through equipment, levels, or buffs) give strategic depth. "Do I boost Attack or Defense?" is only meaningful if both stats feed into the formula.

If a stat doesn't serve at least one of these purposes, it's clutter.

### Our Damage Formula

A damage formula should be simple to understand, produce meaningful numbers, and allow for strategic depth. Here's ours:

```gdscript
static func calculate_damage(attacker: BattlerData, target: BattlerData) -> int:
    var raw: int = attacker.current_attack - target.get_effective_defense()
    var variance: int = randi_range(-2, 2)
    return max(1, raw + variance)
```

This means:
- **Raw damage** = attacker's attack minus target's effective defense
- **Variance** adds ±2 randomness
- **Minimum damage** is always 1 (you always do at least something)

The Defend action increases `defense_boost`, making `get_effective_defense()` return a higher value, reducing incoming damage.

> **JRPG Pattern:** Most JRPGs keep their damage formula visible and understandable. Players should be able to reason about "if I equip this sword (+5 attack), I'll do roughly 5 more damage per hit." Complex formulas with hidden multipliers frustrate players.

### Alternative Formulas Used in Real RPGs

Our formula is subtractive: `attack - defense = damage`. This is the simplest family of damage formulas, and it works well for small number ranges. But it has a quirk: if defense is close to attack, damage drops to nearly zero and the `max(1)` floor kicks in constantly. With large stat growth, damage can also spike hard. Here are three other approaches real RPGs use:

**Multiplicative (Final Fantasy style):**
```
base_damage = random(attack, attack * 2)
damage = base_damage - defense
```
The random range between 1x and 2x attack adds drama. A lucky hit does double. Defense still subtracts, but the higher ceiling means defense rarely walls you completely.

**Ratio-based (Pokemon style):**
```
damage = (attack / defense) * base_power * modifier
```
The ratio means doubling your attack always doubles your damage, regardless of the target's defense. This produces stable, predictable scaling. The `modifier` term handles type effectiveness, critical hits, and random variance.

**Armor-as-percentage:**
```
reduction = defense / (defense + constant)
damage = attack * (1.0 - reduction)
```
Defense gives diminishing returns. The first 10 points of defense reduce a lot of damage; the next 10 reduce less. This prevents any character from becoming truly invincible through stacking defense. Many action RPGs use this.

Our subtractive formula is the right choice for Crystal Saga's scope. If you extend the game significantly, revisit the formula when you notice balance problems (damage too low at high levels, or defense becoming meaningless).

### Accuracy, Evasion, and Critical Hits

Our formula always hits. That's fine for a tutorial game, but commercial JRPGs usually layer accuracy on top of damage. Here's the general pattern:

```
1. Roll hit chance:   base_accuracy + (attacker.speed / max_speed) / 2
2. Roll dodge chance: base_evasion + (target.speed - attacker.speed) * 0.01
3. If miss: show "MISS", deal 0 damage
4. Roll critical:     small flat chance (5-10%)
5. If critical:       damage * 1.5 or damage + bonus roll
6. Otherwise:         normal damage
```

The key design insight: **speed should do double duty**. It determines turn order (Module 14) *and* influences hit/dodge rates. This makes Speed a meaningful stat without adding separate Accuracy and Evasion stats to your character sheet.

We won't implement this in Crystal Saga, but if you find battles feel too deterministic, adding a miss chance (even just 5-10%) adds tension. Players remember the time they dodged a killing blow.

### Isolate Your Formulas

Put all combat math in one file (we use `calculate_damage()` as a static function). When you start tuning your game's balance, you'll change these numbers constantly. Having them scattered across battle states, AI scripts, and item effects makes tuning painful. One file, one place to tweak.

## Implementing All Actions

Update the `ActionExecute` state to handle each action:

```gdscript
extends BattleState
## Executes the chosen action with animation.

func enter(context: Dictionary = {}) -> void:
    var battler: BattlerData = context.get("battler")
    var action: String = context.get("action", "attack")
    var target: BattlerData = context.get("target")
    var item = context.get("item")

    match action:
        "attack":
            await _execute_attack(battler, target)
        "defend":
            _execute_defend(battler)
        "item":
            _execute_item(battler, target, item)
        "enemy_turn":
            await _execute_enemy_turn(battler)

    await get_tree().create_timer(0.3).timeout
    battle_manager.transition_to_state("CheckResult")


func _execute_attack(attacker: BattlerData, target: BattlerData) -> void:
    var damage := max(1, attacker.current_attack - target.get_effective_defense() + randi_range(-2, 2))
    damage = max(1, damage)

    await _play_attack_animation(attacker)
    var actual := target.take_damage(damage)
    _spawn_damage_number(target, actual)
    battle_manager.action_executed.emit(attacker, target, actual)


func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense  # Double defense for one turn
    print(battler.character_data.display_name + " defends!")


func _execute_item(user: BattlerData, target: BattlerData, item: ItemData) -> void:
    if not item:
        return
    if item.hp_restore > 0:
        var healed := target.heal(item.hp_restore)
        _spawn_damage_number(target, healed, true)
    InventoryManager.remove_item(item)


func _execute_enemy_turn(battler: BattlerData) -> void:
    var targets := battle_manager.get_alive_party()
    if targets.is_empty():
        return
    var target: BattlerData = targets[randi() % targets.size()]
    await _execute_attack(battler, target)
```

## Battle Animations with Tweens

Without animation, combat is just numbers changing in a log. The original Final Fantasy proved that even simple sprite slides (a character stepping forward, pausing, then stepping back) transform a math equation into a fight. Floating damage numbers, first popularized by Diablo and now standard in everything from Final Fantasy XIV to Fortnite, give the player instant visual feedback on what just happened. These two elements, motion and numbers, are the minimum viable "game feel" for turn-based combat.

Animations make combat feel impactful. The classic JRPG attack animation: the attacker slides forward, pauses, then slides back.

Add both `_play_attack_animation` and `_find_battler_sprite` to `res://systems/battle/states/action_execute_state.gd` (the same script as the action execution code above):

```gdscript
func _play_attack_animation(attacker: BattlerData) -> void:
    var sprite := _find_battler_sprite(attacker)
    if not sprite:
        return
    var direction := -1.0 if attacker.is_player_controlled else 1.0
    var original_pos: Vector2 = sprite.position

    var tween := create_tween()
    tween.tween_property(sprite, "position:x", original_pos.x + 30.0 * direction, 0.15)
    tween.tween_interval(0.1)
    tween.tween_property(sprite, "position:x", original_pos.x, 0.15)
    await tween.finished


func _find_battler_sprite(battler: BattlerData) -> Node2D:
    for sprite in get_tree().get_nodes_in_group("battler_sprites"):
        if sprite.battler_data == battler:
            return sprite
    return null
```

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html): `tween_property()`, `tween_interval()`, chaining, and `await finished`.

## Floating Damage Numbers

A small label that rises and fades when damage is dealt. Add this method to `action_execute_state.gd` alongside the animation methods:

```gdscript
func _spawn_damage_number(target: BattlerData, amount: int, is_heal: bool = false) -> void:
    var sprite_node := _find_battler_sprite(target)
    if not sprite_node:
        return

    var label := Label.new()
    label.text = str(amount)
    label.add_theme_color_override("font_color", Color.GREEN if is_heal else Color.WHITE)
    label.z_index = 100
    # Add the label as a child of the sprite (Node2D), not the scene root.
    # This ensures the label uses Node2D coordinates, matching the sprite's position.
    sprite_node.add_child(label)
    label.position = Vector2(0, -20)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", -50.0, 0.8)
    tween.tween_property(label, "modulate:a", 0.0, 0.8)
    tween.chain().tween_callback(label.queue_free)
```

This creates a label that floats upward and fades out over 0.8 seconds, then removes itself.

> **Note:** `set_parallel(true)` makes the next tweens run simultaneously (moving up AND fading at the same time). `chain()` returns to sequential mode for the cleanup callback.

## The Defend Action as a Temporary Buff

Defend doubles the battler's defense for one turn:

```gdscript
func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense
```

The boost is reset at the start of the battler's next turn (in the turn processing logic):

```gdscript
battler.defense_boost = 0  # Reset before the battler acts
```

This is the simplest form of a temporary status effect. In Module 26 (Next Steps), we'll discuss generalizing this into a full status effects system with poison, sleep, buffs, and debuffs.

## Complete action_execute_state.gd

For reference, here is the complete `res://systems/battle/states/action_execute_state.gd` with all methods from this module merged into one file:

```gdscript
extends BattleState
## Executes the chosen action with animation.

func enter(context: Dictionary = {}) -> void:
    var battler: BattlerData = context.get("battler")
    var action: String = context.get("action", "attack")
    var target: BattlerData = context.get("target")
    var item = context.get("item")

    match action:
        "attack":
            await _execute_attack(battler, target)
        "defend":
            _execute_defend(battler)
        "item":
            _execute_item(battler, target, item)
        "enemy_turn":
            await _execute_enemy_turn(battler)

    await get_tree().create_timer(0.3).timeout
    battle_manager.transition_to_state("CheckResult")


func _execute_attack(attacker: BattlerData, target: BattlerData) -> void:
    var damage := max(1, attacker.current_attack - target.get_effective_defense() + randi_range(-2, 2))
    damage = max(1, damage)

    await _play_attack_animation(attacker)
    var actual := target.take_damage(damage)
    _spawn_damage_number(target, actual)
    battle_manager.action_executed.emit(attacker, target, actual)


func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense
    print(battler.character_data.display_name + " defends!")


func _execute_item(user: BattlerData, target: BattlerData, item: ItemData) -> void:
    if not item:
        return
    if item.hp_restore > 0:
        var healed := target.heal(item.hp_restore)
        _spawn_damage_number(target, healed, true)
    InventoryManager.remove_item(item)


func _execute_enemy_turn(battler: BattlerData) -> void:
    var targets := battle_manager.get_alive_party()
    if targets.is_empty():
        return
    var target: BattlerData = targets[randi() % targets.size()]
    await _execute_attack(battler, target)


func _play_attack_animation(attacker: BattlerData) -> void:
    var sprite := _find_battler_sprite(attacker)
    if not sprite:
        return
    var direction := -1.0 if attacker.is_player_controlled else 1.0
    var original_pos: Vector2 = sprite.position

    var tween := create_tween()
    tween.tween_property(sprite, "position:x", original_pos.x + 30.0 * direction, 0.15)
    tween.tween_interval(0.1)
    tween.tween_property(sprite, "position:x", original_pos.x, 0.15)
    await tween.finished


func _find_battler_sprite(battler: BattlerData) -> Node2D:
    for sprite in get_tree().get_nodes_in_group("battler_sprites"):
        if sprite.battler_data == battler:
            return sprite
    return null


func _spawn_damage_number(target: BattlerData, amount: int, is_heal: bool = false) -> void:
    var sprite_node := _find_battler_sprite(target)
    if not sprite_node:
        return

    var label := Label.new()
    label.text = str(amount)
    label.add_theme_color_override("font_color", Color.GREEN if is_heal else Color.WHITE)
    label.z_index = 100
    sprite_node.add_child(label)
    label.position = Vector2(0, -20)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", -50.0, 0.8)
    tween.tween_property(label, "modulate:a", 0.0, 0.8)
    tween.chain().tween_callback(label.queue_free)
```

## Engineering Contract

- **Global state:** Player actions consume InventoryManager items but battle decisions stay scene-local.
- **Public surface:** Battle menu emits action strings; target select emits chosen battlers; ActionExecute consumes command dictionaries.
- **Invariant:** Commands only use implemented fields: `action`, `battler`, `target`, and optional `item`.
- **Failure behavior:** Magic remains disabled until a future ability system exists.
- **Copy semantics:** Commands hold references to current runtime battlers; they should be executed immediately, not saved.

## Engine Gotcha

Signals connected in `enter()` must be disconnected in `exit()`. Otherwise returning to PlayerChoice can stack duplicate signal connections and execute one button press multiple times.

## What We've Learned

- The **battle menu** uses VBoxContainer with Buttons and `grab_focus()` for keyboard navigation.
- **Target selection** presents enemy names as buttons; cancelling returns to the menu.
- The **command pattern** represents actions as dictionaries: `{action, battler, target, item}`.
- **Stats exist for three reasons:** the simulation needs them, they differentiate characters, and they create player choices. If a stat doesn't serve at least one purpose, remove it.
- **Damage formula:** `max(1, attack - defense + random_variance)`. Our subtractive formula is simple and transparent. Alternatives include multiplicative (Final Fantasy), ratio-based (Pokemon), and armor-as-percentage formulas, each with different scaling behavior.
- **Isolate your formulas** in one place. Combat math gets tweaked constantly during balancing; scattering it across files makes tuning painful.
- **Battle animations** use Tweens: slide forward → pause → slide back.
- **Floating damage numbers** rise and fade using parallel tweens.
- **Defend** is a temporary defense buff, the simplest status effect pattern.
- `set_parallel(true)` and `chain()` control Tween sequencing.

## What You Should See

When a battle starts:
- A menu appears: Attack / Magic / Defend / Item
- Selecting Attack shows enemy targets
- Choosing a target plays a slide animation and shows a damage number
- Defend doubles defense for one turn
- Using an Item consumes it from inventory
- The enemy takes its turn automatically
- Combat feels responsive and interactive

## Next Module

We have interactive battles, but we're fighting placeholder Slimes with a debug key. In **Module 16: The Crystal Cavern**, we'll build a dungeon with its own tilemap, encounter zones, treasure chests, and a boss room, giving the battle system a proper home.


---

<!-- Source: 16_crystal_cavern.md -->

# Module 16: The Crystal Cavern, Dungeon Design

## What We Have So Far

A town, a forest, a battle system with actions and animations, and an inventory. We need a destination, somewhere that tests the player's skills and rewards their preparation.

## What We're Building This Module

The **Crystal Cavern**: a dungeon area with a distinct tileset, multiple rooms connected by passages, treasure chests, encounter zones for random battles, a save crystal, and a boss room at the end. This is level design, not system design. We're applying everything we've learned about TileMaps, scene transitions, and interactables.

Dungeons are where RPGs test everything the player has prepared. In Zelda, each dungeon introduces a new item and then builds puzzles around mastering it. In Final Fantasy, dungeons are gauntlets that drain your party's resources over time. Each random battle costs HP and MP, and the question is whether you can reach the boss with enough left to win. A well-designed dungeon creates a rising tension curve: easy rooms at the start, harder encounters deeper in, a save point right before the climax, and a boss that demands everything you've learned.

## Dungeon vs Overworld Design

Dungeons differ from overworld areas in several ways:

| Aspect | Overworld (Willowbrook, Whisperwood) | Dungeon (Crystal Cavern) |
|--------|--------------------------------------|--------------------------|
| Tile palette | Grass, trees, paths, buildings | Cave walls, stone floor, crystals |
| Layout | Open, organic, free-roaming | Corridors, rooms, controlled flow |
| Collision | Boundary trees and water | Walls everywhere, tight spaces |
| Encounters | Occasional (forest only) | Frequent, every few steps |
| Items | Shops (buy) | Treasure chests (find) |
| Save points | Towns (convenient) | Rare (crystals, strategic) |
| Goal | Exploration and socializing | Challenge and progression |

## Cave Tileset Assets

You'll need cave or dungeon tiles for the Crystal Cavern. Here are your options:

**Option 1, free tileset pack:** Download the [Kenney 1-Bit Pack](https://kenney.nl/assets/1-bit-pack) which includes cave and dungeon tiles. Extract it and copy the relevant tile sheets to `res://assets/tilesets/`.

**Option 2, reuse and recolor:** Duplicate the TileSet from Module 5. Open the new TileSet resource, and in the Physics/Terrain tabs, you can reuse the same workflow. Many JRPG tileset packs include both outdoor and dungeon tiles in the same set.

**Option 3, placeholder tiles:** Open any image editor (GIMP, Paint.NET, Piskel, or even a browser-based pixel editor) and create a 64x16 PNG with four 16x16 colored squares side by side: dark grey for walls (`#404050`), lighter grey for walkable floor (`#737380`), blue-purple for crystal decorations (`#664DB3`), and black for void/pits (`#1A1A1A`). Save it as `res://assets/tilesets/cave_tiles.png`.

**Recommended:** Use Option 3 (placeholder tiles) to keep moving without interruption. You can swap in real art later. Options 1-2 look better but require downloading and importing external assets.

Whichever approach you use, the TileSet creation workflow is the same as Module 5:

1. Create a TileSet resource: right-click `res://scenes/crystal_cavern/` → New Resource → TileSet
2. Set the **Tile Size** to `16x16` (must be done before adding an atlas)
3. In the TileSet panel, click **+** → Atlas → drag your cave tile sheet into the Texture slot
4. Click **Yes** when prompted to create tiles automatically
5. Switch to the Paint tab, select **Physics Layer 0**, and paint collision on wall tiles
6. Save the TileSet as `res://scenes/crystal_cavern/cave_tileset.tres`
7. Assign it to each TileMapLayer in the Inspector

If any of these steps feel unclear, revisit Module 5's "Creating the TileSet" section for the full walkthrough.

## Building the Cave Tilemap

Create `res://scenes/crystal_cavern/crystal_cavern.tscn` with the familiar layer structure, but using cave-themed tiles:

```
CrystalCavern (Node2D)
├── Ground (TileMapLayer)      : stone floors, cave ground
├── Detail (TileMapLayer)      : cracks, rubble, small crystals
├── YSortGroup (Node2D, y_sort_enabled)
│   ├── Objects (TileMapLayer) : large crystal formations, stalagmites
│   ├── Player (instance)
│   └── ... (treasure chests, save crystal)
├── AbovePlayer (TileMapLayer) : cave ceiling overhangs, arches
├── Exits (Node2D)
│   ├── ExitToWhisperwood (Area2D + exit_zone.gd)
│   └── ... (spawn points)
├── EncounterZones (Node2D)
│   ├── MainCorridor (Area2D + CollisionShape2D)
│   └── DeepCavern (Area2D + CollisionShape2D)
├── EncounterSystem (Node)
├── DialogueBox (instance)
└── InventoryScreen (instance)
```

Instance the DialogueBox and InventoryScreen the same way as in Willowbrook: drag `dialogue_box.tscn` and `inventory_screen.tscn` from the FileSystem dock into the CrystalCavern root node. These are needed for treasure chest messages and the pause menu inventory.

### Room-Based Layout

Design the dungeon as connected rooms:

```
[Entrance] → [Main Corridor] → [Fork]
                                  ├→ [Dead End, Treasure]
                                  └→ [Deep Cavern] → [Boss Room]
                                       ↑
                                  [Save Crystal]
```

Each "room" is a region of the tilemap. Passages connect them. The fork creates a simple decision: explore the dead end for treasure, or push ahead toward the boss.

### Design Tips

- **Walls on all sides.** Unlike overworld areas with natural boundaries (trees, water), dungeon rooms need explicit walls. Fill everything with wall tiles, then carve out rooms and corridors.
- **Varied room shapes.** Rectangles are fine, but an L-shaped room or a round cavern adds visual interest.
- **Visual landmarks.** Place unique crystal formations or broken pillars at decision points so the player can orient themselves.
- **Width variety.** Tight corridors create tension. Open rooms offer relief. Alternate between them.

> **Spiral:** All the TileMapLayer skills from Module 5 apply here: multiple layers, physics on wall tiles, pixel-perfect settings. The only difference is the tile palette.

## Treasure Chests

Treasure chests are the oldest reward mechanism in RPGs. In the original Dragon Quest, finding a chest in a dungeon was a moment of genuine excitement, because the player risked death to explore a dead end and the chest validated that risk. Chests serve two design purposes: they reward exploration (players who check every corner find better gear) and they pace the dungeon (a Potion in a mid-dungeon chest might be the difference between reaching the boss and having to retreat).

A chest is an interactable that gives the player an item. It's a reusable scene.

Create `res://entities/interactable/treasure_chest.tscn`:

```
TreasureChest (StaticBody2D)
├── Sprite (Sprite2D)          : closed/open chest image
├── CollisionShape2D           : blocks walking through
├── InteractionZone (Area2D)
│   └── CollisionShape2D
└── InteractionPrompt (Label, hidden)  : text "!", font_size 12
```

> **Note:** We use a `Label` for the interaction prompt (just like the NPC prompt in Module 10) because it works without any art assets. If you prefer, you can swap it for a `Sprite2D` with a custom icon later.

Script `res://entities/interactable/treasure_chest.gd`:

```gdscript
extends StaticBody2D
## A treasure chest that gives the player an item when opened.

signal opened

@export var item: ItemData
@export var item_count: int = 1
@export var chest_id: String = ""  # Stable ID; Module 22 uses this for save tracking

var is_opened: bool = false

@onready var _sprite: Sprite2D = $Sprite
@onready var _prompt: Label = $InteractionPrompt
@onready var _zone: Area2D = $InteractionZone

var _player_in_range: bool = false


func _ready() -> void:
    _zone.body_entered.connect(_on_body_entered)
    _zone.body_exited.connect(_on_body_exited)
    _prompt.visible = false
    add_to_group("interactables")


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range or is_opened:
        return
    if event.is_action_pressed("interact"):
        _open()
        get_viewport().set_input_as_handled()


func _open() -> void:
    is_opened = true
    _prompt.visible = false
    # Change sprite to open chest (if you have one)
    # _sprite.frame = 1  # or swap texture

    if item:
        InventoryManager.add_item(item, item_count)
        print("Found: " + item.display_name + " x" + str(item_count))

    opened.emit()


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and not is_opened:
        _player_in_range = true
        _prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _prompt.visible = false
```

For this module, `is_opened` is scene-local runtime state. The `chest_id` export is a stable identifier we will use in Module 22 when save/load starts persisting opened chests through `GameManager` world flags.

Place chests in the dungeon using the editor:
- **Dead End room:** A Potion and an Ether
- **Before boss room:** An Iron Sword (if the player hasn't bought one)

Set the `@export var item` in the Inspector by dragging the `.tres` file into the slot.

## The Save Crystal

The save crystal before a boss room is one of the most recognizable design patterns in JRPGs. In every Final Fantasy game, seeing that glowing crystal means two things: "danger is ahead" and "you won't lose your progress." Save points are as much a narrative device as a mechanical one; they build anticipation. The absence of save points in a long corridor creates anxiety; their appearance after a tough fight creates relief.

A classic JRPG save point, a glowing crystal the player interacts with. For now, it just prints "Game saved!". We'll wire it to the actual save system in Module 22.

Create `res://entities/interactable/save_crystal.tscn`:

```
SaveCrystal (StaticBody2D)
├── Sprite (Sprite2D)          : crystal image (use any placeholder sprite)
├── CollisionShape2D           : blocks walking through (RectangleShape2D, 16x16)
├── InteractionZone (Area2D)
│   └── CollisionShape2D       : interaction radius (CircleShape2D, radius ~24)
└── InteractionPrompt (Label, visible = false)  : text "!", font_size 12
```

Script `res://entities/interactable/save_crystal.gd`:

```gdscript
extends StaticBody2D
## A save crystal. Lets the player save their game.

var _player_in_range: bool = false

@onready var _prompt: Label = $InteractionPrompt
@onready var _zone: Area2D = $InteractionZone


func _ready() -> void:
    _zone.body_entered.connect(_on_body_entered)
    _zone.body_exited.connect(_on_body_exited)
    _prompt.visible = false
    add_to_group("save_points")


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range:
        return
    if event.is_action_pressed("interact"):
        _activate()
        get_viewport().set_input_as_handled()


func _activate() -> void:
    # Module 22 will add actual saving here
    print("Your progress has been saved!")
    # Optional: heal the party at save points (common JRPG pattern)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _prompt.visible = false
```

Place the save crystal in the room before the boss, the classic "save point before the big fight" pattern.

## Encounter Zones

Encounter zones define where random battles can happen and which enemies appear. We'll set up the zones now and wire them to the encounter system in Module 17.

Add `Area2D` nodes to mark the encounter regions. For now, just create the Area2D nodes with CollisionShape2D children, but **don't attach scripts yet**. We'll create the encounter system and encounter zone scripts in Module 17.

For each encounter zone:
1. Create an **Area2D** node (e.g., `MainCorridor`) as a child of `EncounterZones`.
2. Add a **CollisionShape2D** child with a **RectangleShape2D**.
3. Size the rectangle to cover the room or corridor where encounters should happen (e.g., 200x100 pixels for a corridor).

Also add an **EncounterSystem** node (plain `Node`) as a direct child of the `CrystalCavern` root, **not** inside `EncounterZones`. We'll attach a script to this in Module 17.

Place two zones:
- **MainCorridor** covers the entrance corridor (easy enemies)
- **DeepCavern** covers the deeper rooms (harder enemies)

## The Boss Room Door

A locked passage that requires a key item or a quest flag. Create `res://entities/interactable/boss_door.tscn`:

```
BossDoor (StaticBody2D)
├── Sprite (Sprite2D)
├── CollisionShape2D
├── InteractionZone (Area2D)
│   └── InteractionShape (CollisionShape2D, larger radius)
└── InteractionPrompt (Label, text "!", visible = false)
```

Save the script as `res://entities/interactable/boss_door.gd`:

```gdscript
extends StaticBody2D
## A locked door that opens when the player has the right item or flag.

@export var required_item_id: String = ""
@export var unlock_message: String = "The door is locked."
@export var open_message: String = "The door opens!"

var is_unlocked: bool = false
var _player_in_range: bool = false

@onready var _interaction_zone: Area2D = $InteractionZone
@onready var _interaction_prompt: Label = $InteractionPrompt


func _ready() -> void:
    _interaction_zone.body_entered.connect(_on_body_entered)
    _interaction_zone.body_exited.connect(_on_body_exited)
    _interaction_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range or is_unlocked:
        return
    if event.is_action_pressed("interact"):
        _try_open()
        get_viewport().set_input_as_handled()


func _try_open() -> void:
    if required_item_id.is_empty() or InventoryManager.has_item(required_item_id):
        is_unlocked = true
        print(open_message)
        queue_free()
    else:
        print(unlock_message)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _interaction_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _interaction_prompt.visible = false
```

For Crystal Saga, the boss room door could require a "Crystal Key" found in the treasure room, creating a simple puzzle: explore the dead end before you can face the boss.

## Connecting the Scenes

Wire the scene transitions using the same exit zone pattern from Module 7:

1. **Crystal Cavern entrance exit:** Add an Area2D child inside the `Exits` node. Attach `exit_zone.gd` (from `res://scenes/exit_zone.gd` or wherever you saved it in Module 7). Set the exports: `target_scene` = `res://scenes/whisperwood/whisperwood.tscn`, `target_spawn` = `from_cavern`. Add a CollisionShape2D covering the cave entrance.
2. **Whisperwood south exit:** Open `whisperwood.tscn` and add a new exit zone Area2D. Set `target_scene` = `res://scenes/crystal_cavern/crystal_cavern.tscn`, `target_spawn` = `from_whisperwood`.

Add spawn points (Marker2D nodes as children of Exits, added to the `spawn_points` group):
- In Crystal Cavern: `from_whisperwood` at the cave entrance, `default` at the same position
- In Whisperwood: `from_cavern` near the south exit

> **See:** [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html), the node used for each tile layer. Same class as Module 5, now with a cave tileset.

> **See:** [StaticBody2D](https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html), used for treasure chests, save crystals, and boss doors (solid, non-moving objects).

> **See:** [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html), used for interaction zones and encounter regions. The `body_entered`/`body_exited` signals detect when the player enters.

## Engineering Contract

- **Global state:** None in this module; save crystal and chest persistence are wired in Module 22.
- **Public surface:** Dungeon scenes expose encounter zones, boss triggers, save crystals, exits, and stable object IDs.
- **Invariant:** Treasure chest IDs are stable strings even before save/load uses them.
- **Failure behavior:** Missing chest items or IDs should warn during testing rather than silently corrupt progression.
- **Copy semantics:** Scene-local `is_opened` state resets on reload until Module 22 stores it in GameManager flags.

## Engine Gotcha

Area2D triggers do not block movement by themselves. Use StaticBody2D or TileMapLayer collision for walls/objects, and Area2D only for interaction or trigger volumes.

## What We've Learned

- **Dungeon design** uses tight corridors, connected rooms, and controlled flow, different from open overworld areas.
- **Treasure chests** are interactable StaticBody2D nodes with `@export var item: ItemData`.
- **Save crystals** mark locations where the player can save (wired in Module 22).
- **Encounter zones** (Area2D) define regions where random battles trigger.
- **Locked doors** check for key items before opening, a simple puzzle design.
- **Room-based layout** with forks, dead ends, and a boss room creates exploration incentive.

## What You Should See

When you enter Crystal Cavern from Whisperwood:
- A distinct cave tilemap with stone floors and crystal walls
- Multiple connected rooms with corridors between them
- Treasure chests that give items when opened
- A save crystal that responds to interaction
- A boss room door at the far end
- Encounter zones marked (we'll add random battles next module)

## Next Module

The dungeon exists but is quiet, with no monsters. In **Module 17: Enemies and AI**, we'll create enemy types, build an encounter system that triggers random battles as you walk, design basic enemy AI, and create the Crystal Guardian boss.


---

<!-- Source: 17_enemies_and_ai.md -->

# Module 17: Enemies and AI

## What We Have So Far

Three connected areas (town, forest, dungeon), a battle system with interactive menus, and encounter zones in the Crystal Cavern waiting for enemies.

## What We're Building This Module

Enemy data types, three enemy species with basic AI, a random encounter system that triggers battles while walking, encounter groups, and the Crystal Guardian boss fight.

## EnemyData Resource

Enemies need different data than party members. A Slime doesn't have equipment slots or growth rates, but it does have XP rewards, gold drops, and an AI personality. In Pokemon, every species has a catch rate, habitat, and evolution chain, data that makes no sense on a trainer's character sheet. By giving enemies their own Resource type, we can tailor the Inspector to show exactly what matters for enemy design.

Enemies need their own data. Create `res://resources/enemy_data.gd`:

```gdscript
extends Resource
class_name EnemyData
## Data definition for an enemy combatant.

enum AIType { AGGRESSIVE, CAUTIOUS, BALANCED }

@export var id: String = ""
@export var display_name: String = ""
@export var sprite: Texture2D
@export var ai_type: AIType = AIType.BALANCED

@export_group("Stats")
@export var max_hp: int = 30
@export var max_mp: int = 0
@export var attack: int = 8
@export var defense: int = 3
@export var speed: int = 5

@export_group("Rewards")
@export var xp_reward: int = 10
@export var gold_reward: int = 5
@export var drop_item: ItemData
@export_range(0.0, 1.0) var drop_chance: float = 0.25  # Shows a slider in the Inspector clamped to 0-1
```

> `@export_range(min, max)` constrains the Inspector widget to a slider within the given range. Useful for probabilities, percentages, and any value with natural bounds.

> Notice AIController (below) has `class_name` but no `extends` line. When omitted, GDScript scripts extend `RefCounted` by default. Since AIController only has static methods and is never instanced as a node, that's fine.

Create three enemies as `.tres` files in `res://data/enemies/`. Follow the same workflow from Module 9: right-click the folder in the FileSystem dock, choose **New Resource**, search for `EnemyData`, click **Create**, name the file, then fill in the exported fields in the Inspector.

**`cave_bat.tres`**, fast, weak, aggressive
- display_name: "Cave Bat", ai_type: AGGRESSIVE
- HP: 20, attack: 6, defense: 2, speed: 12
- XP: 8, gold: 3
- sprite: assign a small bat image or `res://icon.svg` as a placeholder

**`crystal_slime.tres`**, moderate, balanced
- display_name: "Crystal Slime", ai_type: BALANCED
- HP: 35, attack: 8, defense: 5, speed: 4
- XP: 12, gold: 6, drop: Potion (25%)
- sprite: assign a slime image or `res://icon.svg`

**`stone_golem.tres`**, tanky, cautious
- display_name: "Stone Golem", ai_type: CAUTIOUS
- HP: 60, attack: 12, defense: 10, speed: 2
- XP: 25, gold: 15, drop: Ether (20%)
- sprite: assign a golem image or `res://icon.svg`

## Enemy AI

Enemy AI is what makes each monster feel like a distinct creature rather than a bag of hit points. In Final Fantasy VI, the Behemoth counters every physical attack with a claw swipe, teaching players to use magic instead. Cactuars always flee, making them exciting to encounter. These behaviors come from simple AI rules, not complex neural networks, just "if HP is low, heal; otherwise, attack the weakest target." Three or four personality types are enough to make combat feel varied.

Each enemy needs to decide what to do on its turn. Create `res://systems/battle/ai_controller.gd` for the AI logic:

```gdscript
class_name AIController
## Enemy AI decision-making. Static methods, no instance needed.

static func choose_enemy_action(
    battler: BattlerData,
    enemy_data: EnemyData,
    party: Array[BattlerData],
    allies: Array[BattlerData],
) -> Dictionary:
    match enemy_data.ai_type:
        EnemyData.AIType.AGGRESSIVE:
            return _ai_aggressive(battler, party)
        EnemyData.AIType.CAUTIOUS:
            return _ai_cautious(battler, party)
        EnemyData.AIType.BALANCED:
            return _ai_balanced(battler, party)
        _:
            return _ai_balanced(battler, party)


static func _ai_aggressive(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    # Always attack the target with the lowest HP
    var weakest: BattlerData = targets[0]
    for t in targets:
        if t.current_hp < weakest.current_hp:
            weakest = t
    return {action = "attack", battler = battler, target = weakest}


static func _ai_cautious(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    # Defend when HP is below 30%, otherwise attack randomly
    var hp_ratio: float = float(battler.current_hp) / float(battler.character_data.max_hp)
    if hp_ratio < 0.3:
        return {action = "defend", battler = battler, target = battler}
    var target: BattlerData = targets[randi() % targets.size()]
    return {action = "attack", battler = battler, target = target}


static func _ai_balanced(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    # 70% attack, 30% defend
    var target: BattlerData = targets[randi() % targets.size()]
    if randf() < 0.3:
        return {action = "defend", battler = battler, target = battler}
    return {action = "attack", battler = battler, target = target}
```

## The Encounter System

### EncounterData Resource

Define which enemies appear together. Save as `res://resources/encounter_data.gd`:

```gdscript
extends Resource
class_name EncounterData
## Defines a possible random encounter: which enemies appear as a group.

@export var enemies: Array[EnemyData] = []
@export_range(0.0, 1.0) var weight: float = 1.0  # Relative probability
```

Create encounter groups as `.tres` files in `res://data/encounters/` (same workflow: right-click folder → New Resource → search `EncounterData` → Create):

**`cave_bats.tres`:** 3 Cave Bats (weight: 1.0, common)
**`slime_pair.tres`:** 2 Crystal Slimes (weight: 0.6, uncommon)
**`golem.tres`:** 1 Stone Golem (weight: 0.3, rare)

#### The Oddment Table Pattern

The weighted selection we're using here has a name: the **oddment table** (also called a weighted random table or loot table). It's one of the most reusable patterns in RPG development. The weights don't need to sum to 1.0 or 100; they're *relative*. Cave Bats at 1.0 are roughly 3x more likely than a Stone Golem at 0.3. The actual probabilities are:

| Encounter | Weight | Probability |
|-----------|--------|-------------|
| Cave Bats | 1.0 | 1.0 / 1.9 = 53% |
| Crystal Slimes | 0.6 | 0.6 / 1.9 = 32% |
| Stone Golem | 0.3 | 0.3 / 1.9 = 16% |

The power of this pattern: you can add or remove entries without recalculating the others. If you add a new "Crystal Spider" encounter at weight 0.4, all existing probabilities shift proportionally. No manual rebalancing needed. You'll see this same pattern used for item drops, shop stock, NPC dialogue variety, and AI decision-making in commercial RPGs.

### The Step Counter System

Random encounters trigger based on a step counter. Create `res://systems/encounter_system.gd` and attach it to the `EncounterSystem` node in `crystal_cavern.tscn`:

```gdscript
extends Node
## Tracks player movement and triggers random encounters in encounter zones.

signal encounter_triggered(encounter: EncounterData)

var _step_count: int = 0
var _threshold: int = 0
var _in_encounter_zone: bool = false
var _current_encounters: Array[EncounterData] = []
var _encounter_rate: float = 0.6  # 60% chance per threshold hit; tune this for your dungeon
var _last_player_position: Vector2 = Vector2.ZERO

const STEP_DISTANCE: float = 16.0  # One tile = one step


func _process(_delta: float) -> void:
    if not _in_encounter_zone:
        return

    var player := get_tree().get_first_node_in_group("player")
    if not player:
        return

    var distance: float = player.global_position.distance_to(_last_player_position)
    if distance >= STEP_DISTANCE:
        _last_player_position = player.global_position
        _step_count += 1
        _check_encounter()


func _check_encounter() -> void:
    if _step_count >= _threshold:
        _step_count = 0
        _threshold = randi_range(8, 20)  # Next threshold in 8-20 steps

        if randf() < _encounter_rate and not _current_encounters.is_empty():
            var encounter: EncounterData = _pick_weighted_encounter()
            if encounter:
                encounter_triggered.emit(encounter)


func _pick_weighted_encounter() -> EncounterData:
    if _current_encounters.is_empty():
        push_warning("EncounterSystem: no encounters configured.")
        return null

    var total_weight: float = 0.0
    for enc in _current_encounters:
        total_weight += max(0.0, enc.weight)

    if total_weight <= 0.0:
        push_warning("EncounterSystem: encounter weights must be greater than 0.")
        return null

    var roll: float = randf() * total_weight
    var cumulative: float = 0.0
    for enc in _current_encounters:
        cumulative += max(0.0, enc.weight)
        if roll <= cumulative:
            return enc

    return null


func enter_zone(encounters: Array[EncounterData], rate: float) -> void:
    _in_encounter_zone = true
    _current_encounters = encounters
    _encounter_rate = rate
    _threshold = randi_range(10, 25)
    _step_count = 0
    var player := get_tree().get_first_node_in_group("player")
    if player:
        _last_player_position = player.global_position


func exit_zone() -> void:
    _in_encounter_zone = false
    _current_encounters.clear()
```

> **See:** [Random number generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html), covering `randi_range()`, `randf()`, and weighted random selection.

### Tuning Encounter Rates

The encounter system has two knobs: the **step threshold** (how far you walk before a check) and the **encounter rate** (chance of a fight when the check fires). Getting these right is critical to how your game feels.

**Too frequent** (fight every 5 steps): the player feels trapped. Exploration becomes a chore. They'll dread every hallway.

**Too rare** (fight every 50 steps): the dungeon feels empty. The player reaches the boss under-leveled because they didn't fight enough.

**The sweet spot** for a JRPG dungeon is roughly one encounter every 15-25 steps. Our system achieves this through the combination of `randi_range(8, 20)` for the threshold and a 60% encounter rate. Here's the math:

- Average threshold: ~14 steps
- Average checks before a fight: 1 / 0.6 = ~1.7 checks
- Expected steps between encounters: 14 * 1.7 = ~24 steps

For different zones, vary the rate rather than the threshold:
- **Safe corridors near save points:** 10% rate (rare encounters, the player can breathe)
- **Main dungeon rooms:** 40-60% rate (steady pressure)
- **Deep/dangerous areas:** 80% rate (tense, limited exploration time)

One more trick real JRPGs use: no encounters within a few steps of entering a zone. Our threshold starts at `randi_range(10, 25)` on `enter_zone()`, which naturally gives the player a grace period when entering a new area.

### Wiring Encounter Zones

Create a new script for the encounter zones we placed in Module 16. Save as `res://systems/encounter_zone.gd`, then attach it to each encounter zone Area2D node (MainCorridor, DeepCavern):

```gdscript
extends Area2D
## Marks a region where random encounters can happen.

@export var encounters: Array[EncounterData] = []
@export var encounter_rate: float = 0.1

# ../../EncounterSystem means: go up two levels in the scene tree (from
# MainCorridor → EncounterZones → CrystalCavern), then down to EncounterSystem.
# We've used $ for child access before; ../ navigates to the parent.
@onready var _encounter_system: Node = $"../../EncounterSystem"


func _ready() -> void:
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and _encounter_system:
        _encounter_system.enter_zone(encounters, encounter_rate)


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player") and _encounter_system:
        _encounter_system.exit_zone()
```

### Adding enemy_data to BattlerData

Before wiring encounters to battles, we need a way for the victory flow (Module 18) to access enemy rewards. Open `res://resources/battler_data.gd` and add this property:

```gdscript
# Add to battler_data.gd, stores the EnemyData for reward calculation
var enemy_data: EnemyData = null
```

### Connecting Encounters to Battles

The EncounterSystem emits `encounter_triggered`, but nothing starts a battle yet. Create the Crystal Cavern scene script. Save as `res://scenes/crystal_cavern/crystal_cavern.gd` and attach to the CrystalCavern root node:

```gdscript
extends Node2D
## Crystal Cavern dungeon scene.

@onready var _encounter_system: Node = $EncounterSystem


func _ready() -> void:
    _encounter_system.encounter_triggered.connect(_on_encounter_triggered)


func _on_encounter_triggered(encounter: EncounterData) -> void:
    # Convert EnemyData to BattlerData for the battle system
    var enemy_battlers: Array[BattlerData] = []
    for ed in encounter.enemies:
        enemy_battlers.append(_enemy_to_battler(ed))

    # Build party (temporary, Module 21 adds a proper PartyManager)
    var hero := BattlerData.new()
    hero.character_data = load("res://data/characters/aiden.tres")
    hero.is_player_controlled = true

    # Must use Dictionary format, matches SceneManager.start_battle() from Module 14
    SceneManager.start_battle({party = [hero], enemies = enemy_battlers})


func _enemy_to_battler(enemy_data: EnemyData) -> BattlerData:
    var battler := BattlerData.new()
    var char_data := CharacterData.new()
    char_data.display_name = enemy_data.display_name
    char_data.portrait = enemy_data.sprite if enemy_data.sprite else preload("res://icon.svg")
    char_data.max_hp = enemy_data.max_hp
    char_data.max_mp = enemy_data.max_mp
    char_data.attack = enemy_data.attack
    char_data.defense = enemy_data.defense
    char_data.speed = enemy_data.speed
    battler.character_data = char_data
    battler.is_player_controlled = false
    battler.enemy_data = enemy_data
    return battler
```

That `char_data.portrait = ed.sprite` line is the bridge between your enemy data and the battle presentation. `BattlerSprite` already knows how to read `character_data.portrait`, so once you fill in the `sprite` field on each `EnemyData` resource, those visuals now appear in battle automatically.

### Using AI in Battle

Now update the `_execute_enemy_turn` method in `res://systems/battle/states/action_execute_state.gd` to use the AI controller instead of random targeting:

```gdscript
func _execute_enemy_turn(battler: BattlerData) -> void:
    var targets := battle_manager.get_alive_party()
    if targets.is_empty():
        return

    # Use AI controller if enemy has EnemyData, otherwise random
    if battler.enemy_data:
        var command: Dictionary = AIController.choose_enemy_action(
            battler, battler.enemy_data, targets, battle_manager.get_alive_enemies(),
        )
        var target: BattlerData = command.get("target", targets[0])
        match command.get("action", "attack"):
            "attack":
                await _execute_attack(battler, target)
            "defend":
                _execute_defend(battler)
    else:
        var target: BattlerData = targets[randi() % targets.size()]
        await _execute_attack(battler, target)
```

## The Boss: Crystal Guardian

The Crystal Guardian is a stronger enemy with a pre-battle dialogue.

**`crystal_guardian.tres`** (EnemyData) in `res://data/enemies/`:
- display_name: "Crystal Guardian"
- ai_type: AGGRESSIVE
- HP: 200, attack: 15, defense: 8, speed: 6
- XP: 100, gold: 50

The boss room trigger starts dialogue, then transitions to battle. Save as `res://entities/interactable/boss_trigger.gd` and attach to an Area2D node in the boss room:

```gdscript
extends Area2D
## Triggers the boss fight with a pre-battle cutscene.

@export var boss_data: EnemyData
var _triggered: bool = false


func _ready() -> void:
    body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and not _triggered:
        _triggered = true
        _start_boss_sequence()


func _start_boss_sequence() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("set_disabled"):
        player.set_disabled(true)

    # Pre-boss dialogue
    var line := DialogueLine.new()
    line.speaker_name = "Crystal Guardian"
    line.text = "You dare disturb the crystals? Prepare yourself!"

    var dialogue_box = get_tree().current_scene.get_node_or_null("DialogueBox")
    if dialogue_box:
        dialogue_box.start_dialogue([line])
        await dialogue_box.dialogue_finished

    # Start the boss battle
    _start_boss_battle()


func _start_boss_battle() -> void:
    var hero := BattlerData.new()
    hero.character_data = load("res://data/characters/aiden.tres")
    hero.is_player_controlled = true

    var boss := _enemy_to_battler(boss_data)

    SceneManager.start_battle({
        party = [hero],
        enemies = [boss],
    })
```

## Flee Mechanic

The Flee command is a pressure valve. In Dragon Quest, when you're deep in a dungeon with 10 HP and no Potions, the ability to run from a random encounter is the difference between a tense retreat to the save point and a frustrating game over. Flee also makes Speed matter outside of turn order: a fast party escapes easily, while slow characters are trapped.

Add a "Flee" option. First, add the flee logic to `res://systems/battle/ai_controller.gd`:

```gdscript
static func attempt_flee(party: Array[BattlerData], enemies: Array[BattlerData]) -> bool:
    var party_speed: float = 0.0
    for b in party:
        party_speed += b.current_speed
    party_speed /= party.size()

    var enemy_speed: float = 0.0
    for b in enemies:
        enemy_speed += b.current_speed
    enemy_speed /= enemies.size()

    # Base 50% chance, modified by speed ratio
    var chance: float = 0.5 + (party_speed - enemy_speed) * 0.05
    chance = clampf(chance, 0.1, 0.9)  # Always 10-90% chance

    return randf() < chance
```

Then add a Flee button to `res://ui/battle/battle_menu.tscn` (add a 5th Button node named `FleeButton` in the ActionList) and wire it in `battle_menu.gd`:

```gdscript
@onready var _flee_btn: Button = $MarginContainer/ActionList/FleeButton

# Add in _ready():
_flee_btn.pressed.connect(func() -> void: action_chosen.emit("flee"))
```

Handle flee in the PlayerChoice state (`player_choice_state.gd`), inside the `_on_action_chosen` match block:

```gdscript
        "flee":
            var success := AIController.attempt_flee(
                battle_manager.get_alive_party(),
                battle_manager.get_alive_enemies(),
            )
            if success:
                print("Escaped!")
                SceneManager.return_from_battle()
            else:
                print("Couldn't escape!")
                # Wasted turn, go to next battler
                battle_manager.transition_to_state("CheckResult")
```

> **JRPG Pattern:** Most JRPGs don't let you flee from boss battles. Add a `can_flee: bool` to your EncounterData and disable the Flee button when it's false.

> **See:** [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html). EnemyData and EncounterData both extend Resource. The `@export_group` and `@export_range` annotations organize the Inspector.

> **See:** [Random number generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html), covering `randi_range()`, `randf()`, and weighted random selection used throughout the encounter and AI systems.

## Engineering Contract

- **Global state:** Encounter logic starts battles through SceneManager but encounter counters are scene-local.
- **Public surface:** `EncounterData`, `EnemyData`, enemy-to-battler conversion, encounter zones, and AI action selection.
- **Invariant:** Encounter pools must contain enemies and have positive total weight before a battle can be rolled.
- **Failure behavior:** Empty pools or non-positive weights return no encounter and log a warning instead of crashing.
- **Copy semantics:** EnemyData is static content; BattlerData is the mutable runtime copy used in combat.

## Engine Gotcha

Random encounter systems often fail at boundaries: empty arrays, zero weights, and missing Resources. Guard those cases before calling `randf_range()` or indexing into an encounter pool.

## What We've Learned

- **EnemyData** Resource defines enemy stats, AI type, rewards, and loot drops.
- **Three AI types** (aggressive, cautious, balanced) create varied combat encounters with simple weighted logic.
- **The step counter** triggers encounters after a semi-random number of movement steps, with tunable frequency per zone.
- **Oddment tables** (weighted random selection) are a reusable pattern for encounters, loot drops, AI decisions, and more. Weights are relative, so adding entries doesn't require rebalancing existing ones.
- **Encounter rate tuning** combines step thresholds with probability checks. Different zones should feel different (safe corridors vs. dangerous depths).
- **Boss fights** use pre-battle dialogue sequences and stronger enemy data.
- **Flee mechanic** uses speed-based probability with bounded randomness.

## What You Should See

When exploring the Crystal Cavern:
- Random battles trigger after walking a number of steps
- Different enemies appear (bats, slimes, golems)
- Each enemy behaves differently based on AI type
- Entering the boss room triggers dialogue, then a boss battle
- The Flee option sometimes works, sometimes doesn't

## Next Module

We can fight, but nothing happens after winning. In **Module 18: Victory, Rewards, and Leveling**, we'll add XP distribution, a leveling system, gold and item drops, the victory fanfare, and the game-over flow.


---

<!-- Source: 18_victory_and_leveling.md -->

# Module 18: Victory, Rewards, and Leveling

## What We Have So Far

Interactive combat with enemies, AI, random encounters, and a boss fight. But winning a battle does nothing: no rewards, no progression.

## What We're Building This Module

Post-battle rewards (XP, gold, item drops), a leveling system with stat growth curves, the victory fanfare screen, and the game-over/defeat flow.

## Preparing the Data Layer

Before building the victory and leveling flows, make sure `CharacterData` still has the runtime properties we introduced in Module 9. We are finally going to put them to work here.

### CharacterData Runtime State

If your `res://resources/character_data.gd` does not already include these plain variables, add them now:

```gdscript
# Add to character_data.gd, runtime state (below the @export vars)
var current_xp: int = 0
var current_hp: int = 0  # Tracks HP between battles
var current_mp: int = 0  # Tracks MP between battles
```

> **Why both CharacterData and BattlerData have HP/MP:** BattlerData holds HP/MP *during* a battle (it's temporary, created fresh each fight). CharacterData holds HP/MP *between* battles (persistent across scenes). At battle start, `BattlerData.initialize_from_character()` copies from CharacterData. At battle end, we sync back.

### The XP Curve

We need a formula for "how much XP to reach the next level." This is one of the most important tuning knobs in your RPG. The curve shape determines the pacing of the entire game.

#### Why Levels Matter (Beyond Numbers)

Levels serve four purposes in a JRPG:

1. **Reward feedback.** The number going up *is* the reward. It's Pavlovian: fight → XP → level up → dopamine. Fast early levels hook the player.
2. **Narrative pacing.** Level roughly tracks where the player is in the story. A level 5 party is in the early game; a level 30 party is near the end. Designers use this to gate content.
3. **Complexity drip-feed.** New abilities unlock at specific levels, introducing mechanics gradually instead of dumping everything on the player at once.
4. **Content gating.** An area with level 15 enemies is implicitly locked until the party reaches that range. No locked doors needed.

#### Real RPG XP Formulas

Different curves produce very different game feel. Here are formulas reverse-engineered from real games:

| Game | Formula | Feel |
|------|---------|------|
| D&D 3.5 | `500 * level^2 - 500 * level` | Very steep. High levels are rare achievements. |
| Pokemon (fast group) | `round(0.8 * level^3)` | Moderate curve. Grinding is possible but not required. |
| Disgaea | `round(0.04 * level^3 + 0.8 * level^2 + 2 * level)` | Shallow. Levels come fast because *everything* levels. |

The general formula is:

```
xp_for_level = base_xp * level ^ exponent
```

- `base_xp` controls the overall cost of leveling. Higher = slower progression.
- `exponent` controls how much harder each successive level gets. At 1.0, every level costs the same XP. At 2.0 (quadratic), costs increase rapidly. At 3.0 (cubic), later levels take dramatically longer.

#### Our Curve

A simple quadratic curve works well for Crystal Saga's scope. Add this static function to `res://resources/character_data.gd`:

```gdscript
# A static func belongs to the class itself, not an instance. Call it as
# CharacterData.xp_for_level(5) without needing a CharacterData object.
# Useful for utility calculations that don't depend on instance data.
static func xp_for_level(level: int) -> int:
    return level * level * 10
```

| Level | XP to Next Level | Total XP |
|-------|-----------------|----------|
| 1 → 2 | 10 | 10 |
| 2 → 3 | 40 | 50 |
| 3 → 4 | 90 | 140 |
| 4 → 5 | 160 | 300 |
| 5 → 6 | 250 | 550 |
| 10 → 11 | 1,000 | 3,850 |

This is `base_xp=10, exponent=2`. Early levels come fast (10 XP for level 2), later levels take real effort (1,000 XP for level 11). If playtesting reveals that leveling feels too slow or too fast, change the `10` multiplier first, then consider adjusting the exponent.

> **Tuning tip:** Print the XP table for your expected level range (1-15 for Crystal Saga) and compare it against enemy XP rewards. If a single battle gives enough XP to level up, your curve is too shallow. If the player needs 50+ fights to level, it's too steep. Aim for 4-8 fights per level in the mid-game.

### Stat Growth

When a character levels up, their stats increase based on **growth rates** defined in CharacterData.

> **Spiral:** These growth rate fields (`hp_growth`, `mp_growth`, `attack_growth`, `defense_growth`, `speed_growth`) were defined in Module 9's CharacterData class. Verify your `aiden.tres` has non-zero values for all growth fields (e.g., hp_growth: 12, attack_growth: 3). If they default to 0, Aiden won't gain stats on level-up.

#### The Importance of Variance

If every level-up gives exactly +3 Attack, the progression feels mechanical. Real JRPGs add randomness: sometimes you get +2, sometimes +4. This makes each level-up a micro-event. The player watches the numbers and thinks "nice, +4 Strength this time!"

Some RPGs use dice notation for this. A growth rate of "3d2" means "roll three 2-sided dice" (range 3-6, weighted toward the middle). Faster-growing stats use more dice with higher sides; slower stats use fewer dice. We'll keep it simpler with `randi_range`, but the principle is the same: **growth rate = base value + bounded randomness**.

Different characters should grow differently. A warrior gains more HP and Attack per level; a mage gains more MP and Magic. These growth rate differences, compounded over 15-20 levels, make characters feel distinct even if they start similar.

#### The Calculate-Before-Apply Pattern

Notice that `level_up()` returns a `gains` dictionary *and* applies the gains in the same call. This is a simplification. In a polished RPG, you'd split this into two steps:

1. **Calculate** the level-up (what stats *would* increase), returning a preview
2. **Apply** the level-up (actually modify the character), called after the UI finishes displaying

This separation lets you show an animated victory screen where stats tick up one by one, HP bars extend, and "Level Up!" flashes before the numbers are committed. For Crystal Saga, combining both steps is fine. But if you build a victory screen with animated stat bars later, refactor `level_up()` into `create_level_up() -> Dictionary` and `apply_level_up(gains: Dictionary)`.

#### Implementation

Add this method to `res://resources/character_data.gd`:

> **Note:** `level_up()` modifies the Resource's properties at runtime. These changes persist in memory (because Resources are shared by reference) but do NOT modify the `.tres` file on disk. This is the correct behavior; runtime progression should not overwrite base data.

```gdscript
func level_up() -> Dictionary:
    level += 1
    var gains: Dictionary = {
        hp = hp_growth + randi_range(0, 2),
        mp = mp_growth + randi_range(0, 1),
        attack = attack_growth + randi_range(0, 1),
        defense = defense_growth + randi_range(0, 1),
        speed = speed_growth,
    }
    var old_max_hp: int = max_hp
    var old_max_mp: int = max_mp
    max_hp += gains.hp
    max_mp += gains.mp
    current_hp = min(current_hp + (max_hp - old_max_hp), max_hp)
    current_mp = min(current_mp + (max_mp - old_max_mp), max_mp)
    attack += gains.attack
    defense += gains.defense
    speed += gains.speed
    return gains
```

The small random variance (`randi_range(0, 1)` or `(0, 2)`) makes each level-up feel slightly different. HP gets the widest variance because it's the largest number and small fluctuations are less noticeable.

Crystal Saga uses the **gain the delta** rule for HP and MP: if max HP increases by 10, current HP also increases by 10, without exceeding the new max. This feels better than "max increases but current HP stays the same" and is less generous than a full heal on every level-up.

### Centralizing XP Awards

Battles are awarding XP now, and quests will start awarding XP once PartyManager exists in Module 21. Rather than duplicate the level-up loop in multiple systems, give `CharacterData` one helper that owns the "gain XP, maybe level up several times" flow.

Add this below `level_up()` in `res://resources/character_data.gd`:

```gdscript
func grant_xp(xp: int) -> Array[Dictionary]:
    current_xp += xp

    var level_ups: Array[Dictionary] = []
    var required: int = CharacterData.xp_for_level(level)
    while current_xp >= required:
        current_xp -= required
        var gains: Dictionary = level_up()
        level_ups.append({
            level = level,
            gains = gains,
        })
        required = CharacterData.xp_for_level(level)

    return level_ups
```

This helper returns a small summary for each level-up so the caller can print messages or build UI around it without owning the math itself.

## The Victory Flow

Now that the data layer is ready, update the Victory battle state (`res://systems/battle/states/victory_state.gd`) to show rewards:

```gdscript
extends BattleState
## Battle won. Calculate and display rewards.


func enter(_context: Dictionary = {}) -> void:
    print("VICTORY")

    var total_xp: int = 0
    var total_gold: int = 0
    var dropped_items: Array[ItemData] = []

    # Calculate rewards from all enemies
    for enemy in battle_manager.enemies:
        if enemy.enemy_data:
            total_xp += enemy.enemy_data.xp_reward
            total_gold += enemy.enemy_data.gold_reward
            if enemy.enemy_data.drop_item and randf() < enemy.enemy_data.drop_chance:
                dropped_items.append(enemy.enemy_data.drop_item)

    # Distribute XP to party members
    var xp_per_member: int = total_xp / max(1, battle_manager.get_alive_party().size())
    for battler in battle_manager.get_alive_party():
        _apply_xp(battler, xp_per_member)

    # Sync battle HP/MP back to CharacterData for persistence
    for battler in battle_manager.party:
        if battler.character_data:
            battler.character_data.current_hp = battler.current_hp
            battler.character_data.current_mp = battler.current_mp

    # Grant gold
    InventoryManager.add_gold(total_gold)
    print("Gained " + str(total_gold) + " gold!")

    # Grant dropped items
    for item in dropped_items:
        InventoryManager.add_item(item)
        print("Found: " + item.display_name + "!")

    battle_manager.battle_won.emit()

    # Wait for player to acknowledge
    await get_tree().create_timer(2.0).timeout
    # Return to overworld
    SceneManager.return_from_battle()


func _apply_xp(battler: BattlerData, xp: int) -> void:
    if not battler.character_data:
        return

    var char_data: CharacterData = battler.character_data
    print(char_data.display_name + " gained " + str(xp) + " XP!")
    for result in char_data.grant_xp(xp):
        var gains: Dictionary = result.gains
        print(char_data.display_name + " reached level " + str(result.level) + "!")
        print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
              ", DEF +" + str(gains.defense))
```

Item drops turn every battle into a small gamble. In Pokemon, rare wild encounters might hold rare items; in Final Fantasy, stealing from bosses yields unique equipment. The probability doesn't need to be high; even a 10% chance of a rare drop creates a "did I get it?" moment after every fight. Drops should complement shop inventory, not replace it: shops sell reliable basics, drops reward persistence with something special.

## The Defeat Flow

When the party is wiped:

```gdscript
extends BattleState
## Party wiped. Show game over screen.


func enter(_context: Dictionary = {}) -> void:
    print("DEFEAT")
    print("The party has fallen...")
    battle_manager.battle_lost.emit()

    await get_tree().create_timer(2.0).timeout

    # Return to title screen (or last save point)
    # For now, just reload the main scene
    SceneManager.change_scene("res://scenes/willowbrook/willowbrook.tscn", "default")
```

Module 25 replaces this with a proper Game Over screen with options (load save, return to title).

## Post-Battle State Restoration

HP carry-over is the hidden engine of dungeon tension. In every classic Final Fantasy, the real challenge isn't any single battle. It's surviving the entire dungeon with limited healing. Each random encounter chips away at your HP and MP, and the question becomes: "Do I use my last Ether now, or save it for the boss?" This resource attrition is what makes save crystals feel like oases and inns feel like home.

After a victorious battle, the party returns to the overworld with their current HP/MP intact. Two things make this work:

1. **HP/MP sync**: the Victory state writes `battler.current_hp` and `battler.current_mp` back to `battler.character_data` (see the sync code above). Without this, the party would return to full HP after every fight.
2. **Resource sharing**: CharacterData resources are shared by reference. When the battle modifies stats via `level_up()`, that change persists across scenes automatically.

For now, since we don't have a formal PartyManager yet (Module 21), the CharacterData resource at `res://data/characters/aiden.tres` is loaded via `load()`, which caches it. All code that loads the same path gets the same object during the current run, which is what lets battle results persist across scenes. In Module 22 and Module 25, we'll start loading **fresh runtime copies** for save/load and New Game so a brand-new run always starts from pristine base data on disk.

> **JRPG Pattern:** After normal battles, HP/MP carry over (no free heals). Save points and inns restore them. This creates a resource management game: do you use that Potion now or save it for the boss?

> **See:** [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html). Resources loaded with `load()` are cached and shared by reference. Runtime changes to exported properties persist in memory but don't write back to the `.tres` file.

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html). For future enhancements, Tweens can animate the victory screen (stat bars filling, XP counters incrementing).

## Engineering Contract

- **Global state:** Victory writes rewards into PartyManager and InventoryManager through their public APIs.
- **Public surface:** XP gain, level-up, reward calculation, loot rolls, and post-battle HP/MP sync.
- **Invariant:** Level-up max HP/MP gains also increase current HP/MP by the same delta, capped at the new max.
- **Failure behavior:** Dead party members do not receive XP in the base tutorial flow.
- **Copy semantics:** Battle HP/MP lives on BattlerData until victory syncs it back to CharacterData.

## Engine Gotcha

Resource mutation is now intentional: party CharacterData is runtime state. New Game and load flows must avoid reusing mutated cached Resources when they need pristine base data.

## What We've Learned

- **XP distribution** divides total XP among alive party members.
- **Levels serve four purposes:** reward feedback, narrative pacing, complexity drip-feed, and content gating. They're not just a number.
- **XP curve shape** (`base_xp * level ^ exponent`) determines game pacing. A quadratic curve (exponent 2) starts fast and ramps up. Compare your curve against enemy XP rewards to check pacing.
- **Stat growth** per level uses base growth rates plus bounded randomness. Variance makes each level-up feel like a micro-event. Different characters should grow differently to feel distinct.
- **Calculate before apply:** for a polished victory screen, separate `create_level_up()` (returns preview data) from `apply_level_up()` (commits changes). This enables animated stat displays.
- **Loot drops** use probability (`randf() < drop_chance`) on each defeated enemy.
- **Victory flow:** calculate rewards → distribute XP → check level ups → grant gold/items → return to overworld.
- **Defeat flow:** display game over → return to title or last save.
- Character progression is centralized through `CharacterData.grant_xp()`, so battles and later quest rewards can use the same level-up path.
- Runtime CharacterData changes persist during the current play session because systems share the same active character resources.

## What You Should See

After winning a battle:
- "VICTORY" appears in the output panel
- XP, gold, and item drops are listed (e.g., "Aiden gained 12 XP!", "Gained 6 gold!")
- Characters may level up: "Aiden reached level 2!" with stat increases
- After 2 seconds, the game returns to the overworld at the player's previous position
- HP/MP carry over from the battle (if you took damage, your HP stays reduced)

After losing a battle:
- "DEFEAT" appears in the output panel
- The game reloads Willowbrook (placeholder for proper Game Over screen in Module 25)

**Concrete example:** If Aiden (level 1, 0 XP) defeats 2 Crystal Slimes (12 XP each), he gains 24 XP total. Since level 1→2 requires only 10 XP, he levels up to level 2 with 14 XP remaining.

## Next Module

Next up, **Module 19** reviews everything from Part IV with cheat sheets and common mistakes. Then in **Module 20: The Quest System and Game Flags**, we'll add a game-wide flag system for tracking world state, quest data with objectives, a quest log UI, and make NPCs react differently based on what the player has accomplished.


---

<!-- Source: 19_part_iv_review.md -->

# Module 19: Part IV Review and Cheat Sheet

Part IV built the combat core of Crystal Saga. This module is your reference for everything covered in Modules 14 through 18: the battle system architecture, player actions, dungeon design, enemy AI, and the victory/leveling loop.

## Part IV in Review

Before Part IV, Crystal Saga had a connected world with no conflict. After it, we had a fully playable combat loop. We started in Module 14 by confronting the limits of the enum-based state machine from Module 6 and replacing it with a node-based architecture that could handle the complexity of a battle system with seven distinct states. That architecture (one Node per state, each with `enter()`, `process()`, and `exit()`) is what the rest of the battle system sits on.

With the state machine running, Module 15 filled in the player's side: a battle menu, target selection, the damage formula, and Tween-based animations. The battle went from auto-playing print statements to interactive combat with floating damage numbers. Module 16 then gave us somewhere to fight by building the Crystal Cavern, introducing dungeon design principles, treasure chests, save crystals, and encounter zones. The dungeon was a natural application of TileMapLayer skills from Part II, but with cave tiles and a tighter, more controlled layout.

Module 17 populated the dungeon with enemies. EnemyData resources defined stats and rewards, three AI strategies gave each creature personality, and the encounter system tied walking to random battles using a step counter with weighted encounter pools. The Crystal Guardian boss capped the dungeon with a scripted fight. Finally, Module 18 closed the loop: XP distribution, a quadratic leveling curve, stat growth, gold and item drops, and the flows for both victory and defeat. After Module 18, winning a battle means something. Characters get stronger, and the party returns to the overworld with their battle scars intact.

### Module 14: Battle Foundations

- Upgraded from the enum-based state machine (Module 6) to a **node-based state machine** where each state is a Node child with `enter()`, `process()`, and `exit()` methods.
- Created **BattlerData**, a Resource that combines CharacterData stats with runtime battle state (current HP/MP, temporary defense boosts).
- Built the **battle scene** with Marker2D slots for party (right side) and enemies (left side), battler sprites, and a StateMachine node with seven child states.
- Implemented **speed-based turn ordering** using `Array.sort_custom()` to build a turn queue each round.
- Added `start_battle()` and `return_from_battle()` to SceneManager, storing the previous scene path and player position for seamless transitions.

### Module 15: Player Actions

- Built the **battle menu** (Attack/Magic/Defend/Item) as a PanelContainer with VBoxContainer and Buttons. Attack, Defend, and Item emit `action_chosen`; Magic stays disabled for future ability work.
- Implemented the **command pattern** using dictionaries (`{action, battler, target, item}`) to keep action execution generic.
- Created **target selection** UI that dynamically spawns buttons for each alive enemy, with cancel support to return to the menu.
- Defined the **damage formula**: `max(1, attack - effective_defense + randi_range(-2, 2))`, which is simple, transparent, and always deals at least 1 damage.
- Added **Tween animations** for attacks (slide forward, pause, slide back) and **floating damage numbers** (parallel tweens for rising position and fading opacity).

### Module 16: The Crystal Cavern

- Designed a **dungeon layout** with connected rooms, corridors, a fork (dead end with treasure vs. path to boss), and a save crystal room before the boss.
- Built reusable **treasure chest** and **save crystal** interactable scenes using StaticBody2D with Area2D interaction zones, following the same body_entered/exited pattern from Module 10's NPCs.
- Created a **boss door** that checks for a key item before opening, introducing simple puzzle design.
- Placed **encounter zone** Area2D nodes to mark where random battles will trigger (wired in Module 17).
- Applied the same multi-layer TileMapLayer structure from Module 5 (Ground, Detail, Objects in YSortGroup, AbovePlayer) but with cave-themed tiles.

### Module 17: Enemies and AI

- Created **EnemyData** Resource with stats, an AI type enum (AGGRESSIVE, CAUTIOUS, BALANCED), a battle sprite, reward values (XP, gold), and a loot drop with probability.
- Built three **AI strategies** in a static AIController class: aggressive (targets lowest HP), cautious (defends below 30% HP), and balanced (70% attack, 30% defend).
- Implemented the **encounter system** with a step counter that tracks player movement distance, a randomized step threshold, and weighted encounter selection.
- Wired **encounter zones** to the encounter system using Area2D body_entered/exited signals, passing different encounter pools and rates per zone.
- Added a **flee mechanic** with speed-based probability (base 50%, modified by average party speed vs. enemy speed, clamped to 10-90%).

### Module 18: Victory, Rewards, and Leveling

- Implemented **XP distribution** that divides total enemy XP equally among alive party members.
- Defined the **XP curve** as `level * level * 10`, a quadratic formula where early levels come fast and later levels require progressively more XP.
- Added **stat growth** on level-up using base growth rates plus small random variance (`randi_range(0, 1)` or `(0, 2)`), making each level-up feel slightly different.
- Built the **victory flow**: calculate rewards from all enemies, distribute XP (with multi-level-up support), sync battle HP/MP back to CharacterData, grant gold and rolled item drops, then return to the overworld.
- Built the **defeat flow**: display game over message and return to Willowbrook (placeholder for proper Game Over screen in Module 25).

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|---------------|------------|
| Node-based state machine | Each state is a Node child with `enter()`/`process()`/`exit()`, managed by a state machine parent | Scales to complex state flows without monolithic `match` blocks | Module 14 |
| BattlerData | Runtime Resource wrapping CharacterData with battle-specific state (current HP, defense boost) | Separates persistent character data from temporary battle state | Module 14 |
| Turn queue | Array of alive BattlerData sorted by speed, processed front-to-back each round | Determines action order; speed stat becomes strategically meaningful | Module 14 |
| Command pattern | Dictionary `{action, battler, target, item}` representing a battle action | Decouples action selection (menu) from action execution (state) | Module 15 |
| Damage formula | `max(1, attack - effective_defense + variance)` | Predictable, transparent combat math players can reason about | Module 15 |
| Tween animation | Procedural animation using `tween_property()`, `tween_interval()`, and `set_parallel()` | Makes combat feel impactful without sprite animation frames | Module 15 |
| Dungeon design | Room-based layout with corridors, forks, dead ends, and a boss room | Controlled pacing: tension in corridors, relief in open rooms | Module 16 |
| Encounter zones | Area2D regions that activate the encounter system with specific enemy pools | Different areas of a dungeon can have different enemy types and rates | Module 17 |
| EnemyData | Resource defining enemy stats, battle sprite, AI type, rewards, and loot drops | Single source of truth for each enemy species, reusable across encounters and battle presentation | Module 17 |
| Weighted random selection | Cumulative weight algorithm for picking from a pool of options | Common encounters happen often; rare encounters feel special | Module 17 |
| Step counter | Tracks player movement distance against a randomized threshold | Random encounters triggered by exploration, not timers | Module 17 |
| XP curve | `level * level * 10`: quadratic growth formula | Early levels reward quickly; later levels extend gameplay | Module 18 |
| Post-battle sync | Writing battle HP/MP back to CharacterData after victory | HP/MP carry over between battles, creating resource management tension | Module 18 |

## Cheat Sheet

### Node-Based State Machine

The BattleState base class defines the interface every state must implement. Each state is a child Node of the BattleStateMachine, which auto-registers them by name.

```gdscript
# battle_state.gd: base class for all battle states
extends Node
class_name BattleState

var battle_manager: Node  # Set by BattleManager during _ready()

func enter(_context: Dictionary = {}) -> void:
    pass

func process(_delta: float) -> void:
    pass

func exit() -> void:
    pass
```

The machine manages transitions, calling `exit()` on the current state and `enter()` on the new one:

```gdscript
# battle_state_machine.gd
extends Node
class_name BattleStateMachine

signal state_changed(old_state: String, new_state: String)

var current_state: BattleState
var states: Dictionary = {}


func _ready() -> void:
    for child in get_children():
        if child is BattleState:
            states[child.name] = child


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

States transition by calling the BattleManager facade: `battle_manager.transition_to_state("StateName", context)`. The context dictionary passes data between states (active battler, chosen target, action type), while the root battle script keeps ownership of the private state machine node.

### Turn Order System

Each round, all alive combatants are sorted by speed (highest first) into a queue. The queue is processed one battler at a time until empty, then a new round begins.

```gdscript
# In BattleManager
func build_turn_queue() -> void:
    turn_queue.clear()
    var all_battlers: Array[BattlerData] = []
    for b in party:
        if b.is_alive():
            all_battlers.append(b)
    for b in enemies:
        if b.is_alive():
            all_battlers.append(b)
    all_battlers.sort_custom(func(a: BattlerData, b: BattlerData) -> bool:
        return a.current_speed > b.current_speed
    )
    turn_queue = all_battlers


func get_next_battler() -> BattlerData:
    if turn_queue.is_empty():
        return null
    return turn_queue.pop_front()
```

BattlerData wraps CharacterData with runtime state. It initializes from the character's base stats at battle start:

```gdscript
# battler_data.gd
extends Resource
class_name BattlerData

@export var character_data: CharacterData
@export var is_player_controlled: bool = true

var current_hp: int = 0
var current_mp: int = 0
var current_attack: int = 0
var current_defense: int = 0
var current_speed: int = 0
var defense_boost: int = 0
var enemy_data: EnemyData = null  # For reward calculation


func initialize_from_character() -> void:
    if not character_data:
        return
    current_hp = character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp
    current_mp = character_data.current_mp if character_data.current_mp > 0 else character_data.max_mp
    current_attack = character_data.attack
    current_defense = character_data.defense
    current_speed = character_data.speed


func get_effective_defense() -> int:
    return current_defense + defense_boost


func is_alive() -> bool:
    return current_hp > 0
```

### Battle Scene Architecture

The full scene tree wires the state machine, battler positions, and UI together:

```
Battle (Node2D, script: battle_manager.gd)
├── Background (ColorRect)
├── PartyPositions (Node2D)
│   ├── PartySlot0 (Marker2D, pos: 240, 60)
│   ├── PartySlot1 (Marker2D, pos: 240, 120)
│   └── PartySlot2 (Marker2D, pos: 240, 180)
├── EnemyPositions (Node2D)
│   ├── EnemySlot0 (Marker2D, pos: 80, 60)
│   ├── EnemySlot1 (Marker2D, pos: 80, 120)
│   └── EnemySlot2 (Marker2D, pos: 80, 180)
├── BattleUI (CanvasLayer, layer = 10)
│   ├── BattleMenu (instance of battle_menu.tscn)
│   └── TargetSelect (instance of target_select.tscn)
└── StateMachine (BattleStateMachine)
    ├── Intro (BattleState)
    ├── TurnStart (BattleState)
    ├── PlayerChoice (BattleState)
    ├── ActionExecute (BattleState)
    ├── CheckResult (BattleState)
    ├── Victory (BattleState)
    └── Defeat (BattleState)
```

BattleManager is the root script (NOT an autoload). It only exists while a battle is running. In `_ready()`, it passes `self` to every state as `battle_manager`, then waits for `initialize_battle()` to be called with party and enemy data.

The complete state flow:

```
Intro -> TurnStart
TurnStart -> PlayerChoice for player battlers
TurnStart -> ActionExecute for enemy battlers
PlayerChoice -> ActionExecute after the player chooses a command
ActionExecute -> CheckResult
CheckResult -> Victory if all enemies are defeated
CheckResult -> Defeat if all party members are defeated
CheckResult -> TurnStart for the next battler or next round
```

### The Command Pattern

Actions are represented as dictionaries. The PlayerChoice state builds the command; ActionExecute reads and runs it.

```gdscript
# Built in PlayerChoice when the player picks Attack and selects a target:
var command: Dictionary = {
    action = "attack",
    battler = active_battler,
    target = selected_enemy,
    item = null,
}

# Built when the player picks Defend (no target needed):
var command: Dictionary = {
    action = "defend",
    battler = active_battler,
}

# Built when an enemy acts (AI decides action and target):
var command: Dictionary = {
    action = "attack",
    battler = enemy_battler,
    target = chosen_party_member,
}
```

ActionExecute uses `match` on the action string to dispatch:

```gdscript
match action:
    "attack":
        await _execute_attack(battler, target)
    "defend":
        _execute_defend(battler)
    "item":
        _execute_item(battler, target, item)
    "enemy_turn":
        await _execute_enemy_turn(battler)
```

### Battle Menu UI

The menu emits an `action_chosen` signal. The PlayerChoice state connects to it on `enter()` and disconnects on `exit()` to avoid duplicate connections.

```gdscript
# battle_menu.gd
extends PanelContainer

signal action_chosen(action: String)

@onready var _attack_btn: Button = $MarginContainer/ActionList/AttackButton
@onready var _magic_btn: Button = $MarginContainer/ActionList/MagicButton
@onready var _defend_btn: Button = $MarginContainer/ActionList/DefendButton
@onready var _item_btn: Button = $MarginContainer/ActionList/ItemButton


func _ready() -> void:
    _attack_btn.pressed.connect(func() -> void: action_chosen.emit("attack"))
    _magic_btn.disabled = true
    _magic_btn.tooltip_text = "Magic is a future extension."
    _defend_btn.pressed.connect(func() -> void: action_chosen.emit("defend"))
    _item_btn.pressed.connect(func() -> void: action_chosen.emit("item"))


func show_menu() -> void:
    visible = true
    _attack_btn.grab_focus()


func hide_menu() -> void:
    visible = false
```

`grab_focus()` on the Attack button ensures keyboard/gamepad navigation works immediately when the menu appears. The VBoxContainer handles vertical navigation between buttons automatically.

### Damage Formula

Simple, transparent, and always deals at least 1 damage:

```gdscript
static func calculate_damage(attacker: BattlerData, target: BattlerData) -> int:
    var raw: int = attacker.current_attack - target.get_effective_defense()
    var variance: int = randi_range(-2, 2)
    return max(1, raw + variance)
```

The Defend action doubles defense for one turn by setting `defense_boost` equal to `current_defense`. The boost is reset to 0 at the start of the defender's next turn.

```gdscript
# Defend: double effective defense until next turn
func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense

# Reset at the start of each battler's turn (in turn processing):
battler.defense_boost = 0
```

### Tween Animations

Attack slide: the attacker moves toward the enemy, pauses, then returns. Sequential by default, each `tween_property()` call queues after the previous one finishes.

```gdscript
func _play_attack_animation(attacker: BattlerData) -> void:
    var sprite := _find_battler_sprite(attacker)
    if not sprite:
        return
    var direction := -1.0 if attacker.is_player_controlled else 1.0
    var original_pos: Vector2 = sprite.position

    var tween := create_tween()
    tween.tween_property(sprite, "position:x", original_pos.x + 30.0 * direction, 0.15)
    tween.tween_interval(0.1)
    tween.tween_property(sprite, "position:x", original_pos.x, 0.15)
    await tween.finished
```

Floating damage numbers: position and opacity animate simultaneously using `set_parallel(true)`, then `chain()` returns to sequential mode for cleanup.

```gdscript
func _spawn_damage_number(target: BattlerData, amount: int, is_heal: bool = false) -> void:
    var sprite_node := _find_battler_sprite(target)
    if not sprite_node:
        return

    var label := Label.new()
    label.text = str(amount)
    label.add_theme_color_override("font_color", Color.GREEN if is_heal else Color.WHITE)
    label.z_index = 100
    sprite_node.add_child(label)
    label.position = Vector2(0, -20)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", -50.0, 0.8)
    tween.tween_property(label, "modulate:a", 0.0, 0.8)
    tween.chain().tween_callback(label.queue_free)
```

Key Tween methods:
- `tween_property(node, property_path, final_value, duration)`: animates a property over time
- `tween_interval(duration)`: inserts a pause between tweens
- `set_parallel(true)`: subsequent tweens run simultaneously
- `chain()`: returns to sequential mode after parallel tweens
- `await tween.finished`: pauses the calling function until the tween completes

### Dungeon Design

Dungeons use the same multi-layer TileMapLayer structure as overworld scenes, but with different design principles:

```
CrystalCavern (Node2D)
├── Ground (TileMapLayer)         : stone floors
├── Detail (TileMapLayer)         : cracks, rubble, small crystals
├── YSortGroup (Node2D, y_sort_enabled)
│   ├── Objects (TileMapLayer)    : stalagmites, large formations
│   ├── Player (instance)
│   ├── TreasureChests
│   └── SaveCrystal
├── AbovePlayer (TileMapLayer)    : ceiling overhangs
├── Exits (Node2D)                : exit zones and spawn points
├── EncounterZones (Node2D)       : Area2D regions for random battles
└── EncounterSystem (Node)        : step counter logic
```

Design rules:
- **Fill with walls first, then carve rooms and corridors** (opposite of overworld, where you fill with grass and add obstacles)
- **Alternate tight corridors and open rooms** for pacing
- **Place visual landmarks at decision points** so the player can orient
- **Forks with rewards**: dead ends should contain treasure to reward exploration
- **Save crystal before the boss**: the classic JRPG courtesy

Treasure chests, save crystals, and boss doors all follow the same interactable pattern: StaticBody2D (blocks movement) with an Area2D child (detects the player), connected via `body_entered`/`body_exited` signals:

```gdscript
# Shared pattern across all interactables
@onready var _zone: Area2D = $InteractionZone
var _player_in_range: bool = false

func _ready() -> void:
    _zone.body_entered.connect(_on_body_entered)
    _zone.body_exited.connect(_on_body_exited)

func _unhandled_input(event: InputEvent) -> void:
    if _player_in_range and event.is_action_pressed("interact"):
        _activate()
        get_viewport().set_input_as_handled()

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
```

### Enemy AI Patterns

Three AI strategies are implemented as static methods in AIController. Each returns a command dictionary.

```gdscript
# ai_controller.gd
class_name AIController

static func choose_enemy_action(
    battler: BattlerData,
    enemy_data: EnemyData,
    party: Array[BattlerData],
    allies: Array[BattlerData],
) -> Dictionary:
    match enemy_data.ai_type:
        EnemyData.AIType.AGGRESSIVE:
            return _ai_aggressive(battler, party)
        EnemyData.AIType.CAUTIOUS:
            return _ai_cautious(battler, party)
        EnemyData.AIType.BALANCED:
            return _ai_balanced(battler, party)
        _:
            return _ai_balanced(battler, party)
```

**Aggressive:** always targets the weakest (lowest HP) party member:

```gdscript
static func _ai_aggressive(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    var weakest: BattlerData = targets[0]
    for t in targets:
        if t.current_hp < weakest.current_hp:
            weakest = t
    return {action = "attack", battler = battler, target = weakest}
```

**Cautious:** defends when HP drops below 30%, otherwise attacks randomly:

```gdscript
static func _ai_cautious(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    var hp_ratio: float = float(battler.current_hp) / float(battler.character_data.max_hp)
    if hp_ratio < 0.3:
        return {action = "defend", battler = battler, target = battler}
    var target: BattlerData = targets[randi() % targets.size()]
    return {action = "attack", battler = battler, target = target}
```

**Balanced:** 70% attack, 30% defend:

```gdscript
static func _ai_balanced(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
    var target: BattlerData = targets[randi() % targets.size()]
    if randf() < 0.3:
        return {action = "defend", battler = battler, target = battler}
    return {action = "attack", battler = battler, target = target}
```

### EnemyData and Encounter Groups

EnemyData is a Resource that defines everything about an enemy species:

```gdscript
# enemy_data.gd
extends Resource
class_name EnemyData

enum AIType { AGGRESSIVE, CAUTIOUS, BALANCED }

@export var id: String = ""
@export var display_name: String = ""
@export var sprite: Texture2D
@export var ai_type: AIType = AIType.BALANCED

@export_group("Stats")
@export var max_hp: int = 30
@export var attack: int = 8
@export var defense: int = 3
@export var speed: int = 5

@export_group("Rewards")
@export var xp_reward: int = 10
@export var gold_reward: int = 5
@export var drop_item: ItemData
@export_range(0.0, 1.0) var drop_chance: float = 0.25
```

EncounterData groups enemies together with a weight for probability:

```gdscript
# encounter_data.gd
extends Resource
class_name EncounterData

@export var enemies: Array[EnemyData] = []
@export_range(0.0, 1.0) var weight: float = 1.0
```

Encounter zones are Area2D nodes that tell the encounter system which pool to use:

```gdscript
# encounter_zone.gd
extends Area2D

@export var encounters: Array[EncounterData] = []
@export var encounter_rate: float = 0.1

@onready var _encounter_system: Node = $"../../EncounterSystem"

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and _encounter_system:
        _encounter_system.enter_zone(encounters, encounter_rate)

func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player") and _encounter_system:
        _encounter_system.exit_zone()
```

Weighted selection picks an encounter from the pool (higher weight means more common):

```gdscript
func _pick_weighted_encounter() -> EncounterData:
    var total_weight: float = 0.0
    for enc in _current_encounters:
        total_weight += enc.weight
    var roll: float = randf() * total_weight
    var cumulative: float = 0.0
    for enc in _current_encounters:
        cumulative += enc.weight
        if roll <= cumulative:
            return enc
    return _current_encounters[0]
```

### Experience and Leveling

The XP curve uses a simple quadratic formula. The `while` loop handles cases where a single battle awards enough XP for multiple level-ups.

```gdscript
# In character_data.gd
static func xp_for_level(level: int) -> int:
    return level * level * 10

func level_up() -> Dictionary:
    level += 1
    var gains: Dictionary = {
        hp = hp_growth + randi_range(0, 2),
        mp = mp_growth + randi_range(0, 1),
        attack = attack_growth + randi_range(0, 1),
        defense = defense_growth + randi_range(0, 1),
        speed = speed_growth,
    }
    max_hp += gains.hp
    max_mp += gains.mp
    attack += gains.attack
    defense += gains.defense
    speed += gains.speed
    return gains

func grant_xp(xp: int) -> Array[Dictionary]:
    current_xp += xp

    var level_ups: Array[Dictionary] = []
    var required: int = CharacterData.xp_for_level(level)
    while current_xp >= required:
        current_xp -= required
        var gains: Dictionary = level_up()
        level_ups.append({
            level = level,
            gains = gains,
        })
        required = CharacterData.xp_for_level(level)

    return level_ups
```

XP distribution in the victory state:

```gdscript
func _apply_xp(battler: BattlerData, xp: int) -> void:
    var char_data: CharacterData = battler.character_data
    for result in char_data.grant_xp(xp):
        print(char_data.display_name + " reached level " + str(result.level) + "!")
```

The XP curve at a glance:

| Level | XP Required | Total XP to Reach |
|-------|------------|-------------------|
| 1 to 2 | 10 | 10 |
| 2 to 3 | 40 | 50 |
| 3 to 4 | 90 | 140 |
| 4 to 5 | 160 | 300 |
| 5 to 6 | 250 | 550 |

### Battle-to-Overworld Transitions

SceneManager stores the previous scene and player position before entering battle. After victory, it restores both.

```gdscript
# In scene_manager.gd
var _previous_scene_path: String = ""
var _previous_player_position: Vector2 = Vector2.ZERO


func start_battle(encounter_data: Dictionary) -> void:
    if _is_transitioning:
        return
    _is_transitioning = true

    var player := get_tree().get_first_node_in_group("player")
    if player:
        _previous_player_position = player.global_position
    _previous_scene_path = get_tree().current_scene.scene_file_path

    transition_started.emit()
    _anim_player.play("fade_out")
    await _anim_player.animation_finished

    get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
    await get_tree().scene_changed

    var battle_scene := get_tree().current_scene
    if battle_scene.has_method("initialize_battle"):
        battle_scene.initialize_battle(
            encounter_data.get("party", []),
            encounter_data.get("enemies", []),
        )

    _anim_player.play("fade_in")
    await _anim_player.animation_finished
    _is_transitioning = false


func return_from_battle() -> void:
    if _previous_scene_path.is_empty():
        return
    change_scene(_previous_scene_path, "default")
    await transition_finished
    var player := get_tree().get_first_node_in_group("player")
    if player:
        player.global_position = _previous_player_position
```

After victory, HP/MP are synced from BattlerData back to CharacterData so damage carries over between fights:

```gdscript
# In victory_state.gd
for battler in battle_manager.party:
    if battler.character_data:
        battler.character_data.current_hp = battler.current_hp
        battler.character_data.current_mp = battler.current_mp
```

Resources loaded with `load()` are cached and shared by reference. When the victory state modifies `aiden.tres`'s CharacterData in memory, those changes persist across scenes without any manual save step.

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Accessing `battle_manager` in a state's `_ready()` | Null reference error at battle start | `battle_manager` is set by the parent's `_ready()`, which runs after children. Use `enter()` instead of `_ready()` for initialization that needs the manager. |
| Not disconnecting signals in PlayerChoice `exit()` | Duplicate signal connections cause actions to fire multiple times | Always disconnect `action_chosen`, `target_selected`, and `cancelled` in `exit()`. Check `is_connected()` first to be safe. |
| Forgetting `get_viewport().set_input_as_handled()` after processing input | Input bleeds through to other nodes (e.g., opening inventory during battle) | Call `set_input_as_handled()` after handling `interact`, `ui_cancel`, or any action in `_unhandled_input()`. |
| Setting `defense_boost` but never resetting it | Defend stacks permanently, making the character invincible | Reset `battler.defense_boost = 0` at the start of each battler's turn, before they act. |
| Not syncing HP/MP back to CharacterData after battle | Party returns to full HP after every fight, removing resource management | In the victory state, copy `battler.current_hp` and `battler.current_mp` back to `battler.character_data`. |
| Treasure chest opens again after re-entering the scene | Chest gives infinite items | The `is_opened` flag is per-instance and resets when the scene reloads. Module 22 (Save/Load) will persist chest state using the `chest_id` field. |
| Enemy turn crashes with "Invalid get index" | Enemy targets array is empty because all party members died this turn | Always check `targets.is_empty()` before indexing into the array in `_execute_enemy_turn()`. |
| Encounter zone fires immediately on scene load | Battle starts the instant the player spawns | Set the initial step threshold high enough (`randi_range(10, 25)`) in `enter_zone()` so the player gets a few steps of grace. |

## Official Godot Documentation

### Core Classes

- [Node](https://docs.godotengine.org/en/stable/classes/class_node.html): base class for scene tree nodes; the state machine pattern uses `get_children()` and polymorphism
- [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html): base class for BattlerData, EnemyData, EncounterData, CharacterData
- [Node2D](https://docs.godotengine.org/en/stable/classes/class_node2d.html): base class for BattlerSprite and the Battle scene root
- [Marker2D](https://docs.godotengine.org/en/stable/classes/class_marker2d.html): position markers for party and enemy slots

### Physics and Collision

- [StaticBody2D](https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html): used for treasure chests, save crystals, and boss doors
- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html): interaction zones, encounter regions, exit zones, boss trigger
- [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html): defines collision regions for StaticBody2D and Area2D
- [RectangleShape2D](https://docs.godotengine.org/en/stable/classes/class_rectangleshape2d.html): rectangular collision shapes for zones and chests
- [CircleShape2D](https://docs.godotengine.org/en/stable/classes/class_circleshape2d.html): circular interaction radius for save crystals

### UI

- [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html): wraps battle menu and target selection
- [VBoxContainer](https://docs.godotengine.org/en/stable/classes/class_vboxcontainer.html): vertical layout for action buttons and target lists
- [MarginContainer](https://docs.godotengine.org/en/stable/classes/class_margincontainer.html): adds padding inside panels
- [Button](https://docs.godotengine.org/en/stable/classes/class_button.html): menu buttons; `pressed` signal and `grab_focus()` for keyboard navigation
- [Label](https://docs.godotengine.org/en/stable/classes/class_label.html): floating damage numbers and interaction prompts
- [ColorRect](https://docs.godotengine.org/en/stable/classes/class_colorrect.html): battle background placeholder
- [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html): renders BattleUI above the battle scene

### Animation

- [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html): procedural animations for attack slides and damage numbers; `tween_property()`, `tween_interval()`, `set_parallel()`, `chain()`
- [Sprite2D](https://docs.godotengine.org/en/stable/classes/class_sprite2d.html): visual representation of battlers, chests, crystals

### Tilemaps

- [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html): each layer of the dungeon tilemap (Ground, Detail, Objects, AbovePlayer)
- [TileSet](https://docs.godotengine.org/en/stable/classes/class_tileset.html): the cave tileset resource with physics layers for wall collision

### Scene Management

- [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html): `change_scene_to_file()`, `get_first_node_in_group()`, `create_timer()`
- [SceneTree.create_timer()](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-method-create-timer): one-shot timers used with `await` for pacing in battle states

### Signals and Input

- [Signal](https://docs.godotengine.org/en/stable/classes/class_signal.html): `connect()`, `disconnect()`, `is_connected()`, `emit()` used throughout
- [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html): focus-based keyboard/gamepad navigation between buttons

### Math and Randomness

- [Random number generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html): `randi_range()`, `randf()`, weighted random selection
- [Array.sort_custom()](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-sort-custom): custom sorting with a callable for turn ordering
- [Array.filter()](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-filter): filtering alive battlers with `is_alive()`
- [Array.any()](https://docs.godotengine.org/en/stable/classes/class_array.html#class-array-method-any): checking if any battler in a group is alive
- [@GDScript.max()](https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-max): clamping damage to a minimum of 1
- [@GDScript.clampf()](https://docs.godotengine.org/en/stable/classes/class_@gdscript.html#class-gdscript-method-clampf): bounding flee probability to 10-90%

### Export Annotations

- [@export](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html): exposes variables to the Inspector
- [@export_group](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#export-group): groups exported variables in the Inspector (used in EnemyData)
- [@export_range](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#export-range): constrains numeric values (used for drop_chance 0.0-1.0)

## What's Next

Part V shifts from combat to progression and persistence. In **Module 20: The Quest System and Game Flags**, we build a game-wide boolean flag system for tracking world state and a quest system on top of it, so the game has forward momentum beyond just leveling up.

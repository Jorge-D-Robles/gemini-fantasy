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

- Built the **battle menu** (Attack/Magic/Defend/Item) as a PanelContainer with VBoxContainer and Buttons, wired through an `action_chosen` signal.
- Implemented the **command pattern** using dictionaries (`{action, battler, target, ability, item}`) to keep action execution generic.
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

- Created **EnemyData** Resource with stats, an AI type enum (AGGRESSIVE, CAUTIOUS, BALANCED), reward values (XP, gold), and a loot drop with probability.
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
| Command pattern | Dictionary `{action, battler, target, ability, item}` representing a battle action | Decouples action selection (menu) from action execution (state) | Module 15 |
| Damage formula | `max(1, attack - effective_defense + variance)` | Predictable, transparent combat math players can reason about | Module 15 |
| Tween animation | Procedural animation using `tween_property()`, `tween_interval()`, and `set_parallel()` | Makes combat feel impactful without sprite animation frames | Module 15 |
| Dungeon design | Room-based layout with corridors, forks, dead ends, and a boss room | Controlled pacing: tension in corridors, relief in open rooms | Module 16 |
| Encounter zones | Area2D regions that activate the encounter system with specific enemy pools | Different areas of a dungeon can have different enemy types and rates | Module 17 |
| EnemyData | Resource defining enemy stats, AI type, rewards, and loot drops | Single source of truth for each enemy species, reusable across encounters | Module 17 |
| Weighted random selection | Cumulative weight algorithm for picking from a pool of options | Common encounters happen often; rare encounters feel special | Module 17 |
| Step counter | Tracks player movement distance against a randomized threshold | Random encounters triggered by exploration, not timers | Module 17 |
| XP curve | `level * level * 10`: quadratic growth formula | Early levels reward quickly; later levels extend gameplay | Module 18 |
| Post-battle sync | Writing battle HP/MP back to CharacterData after victory | HP/MP carry over between battles, creating resource management tension | Module 18 |

## Cheat Sheet

### Node-Based State Machine

The BattleState base class defines the interface every state must implement. Each state is a child Node of the BattleStateMachine, which auto-registers them by name.

```gdscript
# battle_state.gd -- base class for all battle states
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

States transition by calling `battle_manager._state_machine.transition_to("StateName", context)`. The context dictionary passes data between states (active battler, chosen target, action type).

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
var current_attack: int = 0
var current_defense: int = 0
var current_speed: int = 0
var defense_boost: int = 0
var enemy_data: EnemyData = null  # For reward calculation


func initialize_from_character() -> void:
    if not character_data:
        return
    current_hp = character_data.max_hp
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
+-- Background (ColorRect)
+-- PartyPositions (Node2D)
|   +-- PartySlot0 (Marker2D, pos: 240, 60)
|   +-- PartySlot1 (Marker2D, pos: 240, 120)
|   +-- PartySlot2 (Marker2D, pos: 240, 180)
+-- EnemyPositions (Node2D)
|   +-- EnemySlot0 (Marker2D, pos: 80, 60)
|   +-- EnemySlot1 (Marker2D, pos: 80, 120)
|   +-- EnemySlot2 (Marker2D, pos: 80, 180)
+-- BattleUI (CanvasLayer, layer = 10)
|   +-- BattleMenu (instance of battle_menu.tscn)
|   +-- TargetSelect (instance of target_select.tscn)
+-- StateMachine (BattleStateMachine)
    +-- Intro (BattleState)
    +-- TurnStart (BattleState)
    +-- PlayerChoice (BattleState)
    +-- ActionExecute (BattleState)
    +-- CheckResult (BattleState)
    +-- Victory (BattleState)
    +-- Defeat (BattleState)
```

BattleManager is the root script (NOT an autoload). It only exists while a battle is running. In `_ready()`, it passes `self` to every state as `battle_manager`, then waits for `initialize_battle()` to be called with party and enemy data.

The complete state flow:

```
[INTRO] --> [TURN_START] --> player? --> [PLAYER_CHOICE] --> [ACTION_EXECUTE]
                                |                                  |
                                +--> enemy? --> [ACTION_EXECUTE] --+
                                                                   |
                                                            [CHECK_RESULT]
                                                                   |
                                       +------ all enemies dead ---+----- all party dead -----+
                                       |                           |                          |
                                  [VICTORY]                  next battler               [DEFEAT]
                                                        (or new round if
                                                         queue is empty)
```

### The Command Pattern

Actions are represented as dictionaries. The PlayerChoice state builds the command; ActionExecute reads and runs it.

```gdscript
# Built in PlayerChoice when the player picks Attack and selects a target:
var command: Dictionary = {
    action = "attack",
    battler = active_battler,
    target = selected_enemy,
    ability = null,
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
    "magic":
        await _execute_magic(battler, target, ability)
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
    _magic_btn.pressed.connect(func() -> void: action_chosen.emit("magic"))
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
+-- Ground (TileMapLayer)         -- stone floors
+-- Detail (TileMapLayer)         -- cracks, rubble, small crystals
+-- YSortGroup (Node2D, y_sort_enabled)
|   +-- Objects (TileMapLayer)    -- stalagmites, large formations
|   +-- Player (instance)
|   +-- TreasureChests
|   +-- SaveCrystal
+-- AbovePlayer (TileMapLayer)    -- ceiling overhangs
+-- Exits (Node2D)                -- exit zones and spawn points
+-- EncounterZones (Node2D)       -- Area2D regions for random battles
+-- EncounterSystem (Node)        -- step counter logic
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
```

XP distribution in the victory state:

```gdscript
func _apply_xp(battler: BattlerData, xp: int) -> void:
    var char_data: CharacterData = battler.character_data
    char_data.current_xp += xp

    var required: int = CharacterData.xp_for_level(char_data.level)
    while char_data.current_xp >= required:
        char_data.current_xp -= required
        var gains: Dictionary = char_data.level_up()
        print(char_data.display_name + " reached level " + str(char_data.level) + "!")
        required = CharacterData.xp_for_level(char_data.level)
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
    await get_tree().tree_changed

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

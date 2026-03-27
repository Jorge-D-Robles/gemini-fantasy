# Module 14: Enemies and AI

## What We Have So Far

Three connected areas (town, forest, dungeon), a battle system with interactive menus, and encounter zones in the Crystal Cavern waiting for enemies.

## What We're Building This Module

Enemy data types, three enemy species with basic AI, a random encounter system that triggers battles while walking, encounter groups, and the Crystal Guardian boss fight.

## EnemyData Resource

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
@export_range(0.0, 1.0) var drop_chance: float = 0.25
```

Create three enemies as `.tres` files in `res://data/enemies/`:

**`cave_bat.tres`**, fast, weak, aggressive
- display_name: "Cave Bat", ai_type: AGGRESSIVE
- HP: 20, attack: 6, defense: 2, speed: 12
- XP: 8, gold: 3

**`crystal_slime.tres`**, moderate, balanced
- display_name: "Crystal Slime", ai_type: BALANCED
- HP: 35, attack: 8, defense: 5, speed: 4
- XP: 12, gold: 6, drop: Potion (25%)

**`stone_golem.tres`**, tanky, cautious
- display_name: "Stone Golem", ai_type: CAUTIOUS
- HP: 60, attack: 12, defense: 10, speed: 2
- XP: 25, gold: 15, drop: Ether (20%)

## Enemy AI

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

Create some encounter groups as `.tres` files in `res://data/encounters/`:

**`cave_bats.tres`:** 3 Cave Bats (weight: 1.0, common)
**`slime_pair.tres`:** 2 Crystal Slimes (weight: 0.6, uncommon)
**`golem.tres`:** 1 Stone Golem (weight: 0.3, rare)

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
            var encounter := _pick_weighted_encounter()
            encounter_triggered.emit(encounter)


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

### Wiring Encounter Zones

Create a new script for the encounter zones we placed in Module 13. Save as `res://systems/encounter_zone.gd`, then attach it to each encounter zone Area2D node (MainCorridor, DeepCavern):

```gdscript
extends Area2D
## Marks a region where random encounters can happen.

@export var encounters: Array[EncounterData] = []
@export var encounter_rate: float = 0.1

# Path from EncounterZones/MainCorridor up to CrystalCavern, then down to EncounterSystem
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

Before wiring encounters to battles, we need a way for the victory flow (Module 15) to access enemy rewards. Open `res://resources/battler_data.gd` and add this property:

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
        var battler := BattlerData.new()
        var char_data := CharacterData.new()
        char_data.display_name = ed.display_name
        char_data.max_hp = ed.max_hp
        char_data.attack = ed.attack
        char_data.defense = ed.defense
        char_data.speed = ed.speed
        battler.character_data = char_data
        battler.is_player_controlled = false
        battler.enemy_data = ed  # Store for victory rewards (Module 15)
        enemy_battlers.append(battler)

    # Build party (temporary, Module 17 adds a proper PartyManager)
    var hero := BattlerData.new()
    hero.character_data = load("res://data/characters/aiden.tres")
    hero.is_player_controlled = true

    # Must use Dictionary format, matches SceneManager.start_battle() from Module 11
    SceneManager.start_battle({party = [hero], enemies = enemy_battlers})
```

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

    var boss_char := CharacterData.new()
    boss_char.display_name = boss_data.display_name
    boss_char.max_hp = boss_data.max_hp
    boss_char.attack = boss_data.attack
    boss_char.defense = boss_data.defense
    boss_char.speed = boss_data.speed

    var boss := BattlerData.new()
    boss.character_data = boss_char
    boss.is_player_controlled = false
    boss.enemy_data = boss_data  # Required for Module 15's victory rewards

    SceneManager.start_battle({
        party = [hero],
        enemies = [boss],
    })
```

## Flee Mechanic

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
                battle_manager._state_machine.transition_to("CheckResult")
```

> **JRPG Pattern:** Most JRPGs don't let you flee from boss battles. Add a `can_flee: bool` to your EncounterData and disable the Flee button when it's false.

> **See:** [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html). EnemyData and EncounterData both extend Resource. The `@export_group` and `@export_range` annotations organize the Inspector.

> **See:** [Random number generation](https://docs.godotengine.org/en/stable/tutorials/math/random_number_generation.html), covering `randi_range()`, `randf()`, and weighted random selection used throughout the encounter and AI systems.

## What We've Learned

- **EnemyData** Resource defines enemy stats, AI type, rewards, and loot drops.
- **Three AI types** (aggressive, cautious, balanced) create varied combat encounters with simple weighted logic.
- **The step counter** triggers encounters after a semi-random number of movement steps.
- **Encounter groups** (EncounterData) define which enemies appear together, with weighted random selection.
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

We can fight, but nothing happens after winning. In **Module 15: Victory, Rewards, and Leveling**, we'll add XP distribution, a leveling system, gold and item drops, the victory fanfare, and the game-over flow.

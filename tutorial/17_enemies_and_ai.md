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
- id: "cave_bat", display_name: "Cave Bat", ai_type: AGGRESSIVE
- HP: 20, attack: 6, defense: 2, speed: 12
- XP: 8, gold: 3
- sprite: assign a small bat image or `res://icon.svg` as a placeholder

**`crystal_slime.tres`**, moderate, balanced
- id: "crystal_slime", display_name: "Crystal Slime", ai_type: BALANCED
- HP: 35, attack: 8, defense: 5, speed: 4
- XP: 12, gold: 6, drop: Potion (25%)
- sprite: assign a slime image or `res://icon.svg`

**`stone_golem.tres`**, tanky, cautious
- id: "stone_golem", display_name: "Stone Golem", ai_type: CAUTIOUS
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

Before wiring encounters to battles, we need a way for the victory flow (Module 18) to access enemy rewards and a shared conversion path for both random encounters and scripted bosses. Open `res://resources/battler_data.gd` and add this property plus static factory:

```gdscript
# Add to battler_data.gd, stores the EnemyData for reward calculation
var enemy_data: EnemyData = null


static func from_enemy(enemy: EnemyData) -> BattlerData:
    var battler := BattlerData.new()
    var char_data := CharacterData.new()
    char_data.display_name = enemy.display_name
    char_data.portrait = enemy.sprite if enemy.sprite else preload("res://icon.svg")
    char_data.max_hp = enemy.max_hp
    char_data.max_mp = enemy.max_mp
    char_data.attack = enemy.attack
    char_data.defense = enemy.defense
    char_data.speed = enemy.speed
    battler.character_data = char_data
    battler.is_player_controlled = false
    battler.enemy_data = enemy
    return battler
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
        enemy_battlers.append(BattlerData.from_enemy(ed))

    # Build party (temporary, Module 21 adds a proper PartyManager)
    var hero := BattlerData.new()
    hero.character_data = load("res://data/characters/aiden.tres")
    hero.is_player_controlled = true

    # Must use Dictionary format, matches SceneManager.start_battle() from Module 14
    SceneManager.start_battle({party = [hero], enemies = enemy_battlers})
```

That `char_data.portrait = enemy.sprite` line inside `BattlerData.from_enemy()` is the bridge between your enemy data and the battle presentation. `BattlerSprite` already knows how to read `character_data.portrait`, so once you fill in the `sprite` field on each `EnemyData` resource, those visuals now appear in battle automatically.

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
- id: "crystal_guardian"
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

    var boss := BattlerData.from_enemy(boss_data)

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

Before handling flee, add one shared exit helper to `res://systems/battle/battle_manager.gd`. Victory, defeat, flee, and any scripted escape should all preserve current battle HP/MP before leaving:

```gdscript
func sync_party_to_character_data() -> void:
    for battler in party:
        if battler.character_data:
            battler.character_data.current_hp = battler.current_hp
            battler.character_data.current_mp = battler.current_mp
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
                battle_manager.sync_party_to_character_data()
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

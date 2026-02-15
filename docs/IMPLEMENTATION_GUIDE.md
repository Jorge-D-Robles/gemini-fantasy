# Godot Implementation Guide

## Project Setup

### Recommended Godot Version
- **Godot 4.x** (Latest stable)
- Advantages: Better performance, improved 2D rendering, enhanced scripting

### Project Structure

```
gemini-fantasy/
├── assets/
│   ├── sprites/
│   │   ├── characters/
│   │   ├── enemies/
│   │   ├── items/
│   │   └── effects/
│   ├── tilesets/
│   │   ├── cindral_wastes/
│   │   ├── verdant_tangle/
│   │   ├── crystalline_steppes/
│   │   ├── ironcoast/
│   │   └── hollows/
│   ├── ui/
│   │   ├── battle/
│   │   ├── menus/
│   │   └── icons/
│   ├── audio/
│   │   ├── music/
│   │   ├── sfx/
│   │   └── ambient/
│   └── fonts/
├── scenes/
│   ├── battle/
│   │   ├── BattleScene.tscn
│   │   ├── BattleUI.tscn
│   │   └── combatants/
│   ├── overworld/
│   │   ├── regions/
│   │   ├── towns/
│   │   └── dungeons/
│   ├── ui/
│   │   ├── MainMenu.tscn
│   │   ├── PauseMenu.tscn
│   │   ├── InventoryMenu.tscn
│   │   └── CharacterMenu.tscn
│   └── characters/
│       ├── Kael.tscn
│       ├── Iris.tscn
│       └── [others].tscn
├── scripts/
│   ├── autoload/ (singletons)
│   │   ├── GameManager.gd
│   │   ├── BattleManager.gd
│   │   ├── PartyManager.gd
│   │   ├── InventoryManager.gd
│   │   ├── SaveManager.gd
│   │   └── AudioManager.gd
│   ├── battle/
│   │   ├── BattleSystem.gd
│   │   ├── TurnQueue.gd
│   │   ├── Combatant.gd
│   │   └── abilities/
│   ├── characters/
│   │   ├── Character.gd
│   │   ├── Stats.gd
│   │   ├── SkillTree.gd
│   │   └── individual/
│   ├── items/
│   │   ├── Item.gd
│   │   ├── Equipment.gd
│   │   └── Consumable.gd
│   ├── enemies/
│   │   ├── Enemy.gd
│   │   └── EnemyAI.gd
│   └── systems/
│       ├── Echo.gd
│       ├── Resonance.gd
│       └── StatusEffect.gd
├── data/ (JSON/Resource files)
│   ├── characters/
│   ├── enemies/
│   ├── items/
│   ├── abilities/
│   ├── echoes/
│   └── dialogues/
└── docs/ (this documentation)
```

---

## Core Systems Implementation

### 1. Battle System

#### BattleManager (Autoload Singleton)

```gdscript
# scripts/autoload/BattleManager.gd
extends Node

signal battle_started
signal battle_ended(result: bool) # true = victory, false = defeat
signal turn_started(combatant: Combatant)
signal turn_ended(combatant: Combatant)

var current_battle: BattleScene = null
var turn_queue: TurnQueue = TurnQueue.new()
var active_combatants: Array[Combatant] = []

func start_battle(enemy_group: Array[Enemy], can_escape: bool = true) -> void:
    battle_started.emit()
    # Load battle scene
    current_battle = load("res://scenes/battle/BattleScene.tscn").instantiate()
    get_tree().root.add_child(current_battle)

    # Setup combatants
    setup_party()
    setup_enemies(enemy_group)

    # Initialize turn queue
    turn_queue.initialize(active_combatants)

    # Start first turn
    process_next_turn()

func process_next_turn() -> void:
    if check_battle_end():
        return

    var next_combatant = turn_queue.get_next()
    turn_started.emit(next_combatant)

    if next_combatant.is_ai_controlled():
        await next_combatant.ai_take_turn()
    else:
        await next_combatant.player_take_turn()

    turn_ended.emit(next_combatant)
    process_next_turn()

func check_battle_end() -> bool:
    var party_alive = active_combatants.filter(func(c): return c.is_party and c.is_alive()).size() > 0
    var enemies_alive = active_combatants.filter(func(c): return !c.is_party and c.is_alive()).size() > 0

    if !party_alive:
        end_battle(false)
        return true
    elif !enemies_alive:
        end_battle(true)
        return true

    return false

func end_battle(victory: bool) -> void:
    if victory:
        handle_victory()
    else:
        handle_defeat()

    battle_ended.emit(victory)
    current_battle.queue_free()
    current_battle = null
```

#### TurnQueue System

```gdscript
# scripts/battle/TurnQueue.gd
class_name TurnQueue

var queue: Array[Combatant] = []
var time: float = 0.0

func initialize(combatants: Array[Combatant]) -> void:
    queue.clear()
    time = 0.0

    # Sort by speed stat
    var sorted = combatants.duplicate()
    sorted.sort_custom(func(a, b): return a.stats.speed > b.stats.speed)

    # Initialize with time offsets based on speed
    for i in range(sorted.size()):
        var combatant = sorted[i]
        combatant.turn_time = i * 10.0 # Stagger initial turns
        queue.append(combatant)

func get_next() -> Combatant:
    # Get combatant with lowest turn_time
    var next = queue[0]
    for combatant in queue:
        if combatant.is_alive() and combatant.turn_time < next.turn_time:
            next = combatant

    # Advance time
    time = next.turn_time

    # Calculate next turn time
    next.turn_time += calculate_turn_delay(next)

    return next

func calculate_turn_delay(combatant: Combatant) -> float:
    # Base delay inversely proportional to speed
    var base_delay = 100.0 / combatant.stats.speed

    # Apply status effect modifiers
    if combatant.has_status("Haste"):
        base_delay *= 0.5
    elif combatant.has_status("Slow"):
        base_delay *= 2.0

    return base_delay

func get_upcoming(count: int = 10) -> Array[Combatant]:
    # Return next 'count' turns for UI display
    var upcoming = queue.duplicate()
    upcoming.sort_custom(func(a, b): return a.turn_time < b.turn_time)
    return upcoming.slice(0, count)
```

#### Combatant Base Class

```gdscript
# scripts/battle/Combatant.gd
class_name Combatant
extends Node2D

signal hp_changed(old_value: int, new_value: int)
signal ee_changed(old_value: int, new_value: int)
signal resonance_changed(old_value: float, new_value: float)
signal status_applied(status: StatusEffect)
signal status_removed(status: String)
signal ko

@export var stats: Stats
@export var is_party: bool = false

var current_hp: int
var current_ee: int
var resonance_gauge: float = 0.0 # 0-100+
var status_effects: Dictionary = {} # {status_name: StatusEffect}
var turn_time: float = 0.0

func _ready() -> void:
    current_hp = stats.max_hp
    current_ee = stats.max_ee

func take_damage(amount: int, is_magical: bool = false) -> void:
    var defense = stats.defense if !is_magical else stats.resistance
    var actual_damage = max(1, amount - defense)

    var old_hp = current_hp
    current_hp = max(0, current_hp - actual_damage)
    hp_changed.emit(old_hp, current_hp)

    # Build resonance from taking damage
    add_resonance(actual_damage * 0.5)

    if current_hp == 0:
        die()

func heal(amount: int) -> void:
    var old_hp = current_hp
    current_hp = min(stats.max_hp, current_hp + amount)
    hp_changed.emit(old_hp, current_hp)

func add_resonance(amount: float) -> void:
    var old_resonance = resonance_gauge
    resonance_gauge = clamp(resonance_gauge + amount, 0, 150) # Can exceed 100 with skills
    resonance_changed.emit(old_resonance, resonance_gauge)

    # Check for state changes
    if resonance_gauge >= 100 and old_resonance < 100:
        enter_overload()

func use_ee(amount: int) -> bool:
    if current_ee >= amount:
        var old_ee = current_ee
        current_ee -= amount
        ee_changed.emit(old_ee, current_ee)
        return true
    return false

func apply_status(effect: StatusEffect) -> void:
    if status_effects.has(effect.name):
        # Refresh or stack existing status
        status_effects[effect.name].refresh()
    else:
        status_effects[effect.name] = effect
        effect.apply(self)
        status_applied.emit(effect)

func remove_status(status_name: String) -> void:
    if status_effects.has(status_name):
        status_effects[status_name].remove(self)
        status_effects.erase(status_name)
        status_removed.emit(status_name)

func is_alive() -> bool:
    return current_hp > 0

func die() -> void:
    ko.emit()
    # Handle death state
    if resonance_gauge >= 100:
        # Died in Overload - become Hollow
        become_hollow()
```

---

### 2. Resonance System

```gdscript
# scripts/systems/Resonance.gd
class_name ResonanceSystem

static func calculate_resonance_gain(combatant: Combatant, source: String, amount: float) -> float:
    var base_gain = amount

    # Apply modifiers based on source
    match source:
        "damage_taken":
            base_gain *= 1.0
        "damage_dealt":
            base_gain *= 0.6
        "defending":
            base_gain *= 1.5
        "ally_threshold":
            base_gain *= 0.5

    # Apply character-specific modifiers
    if combatant.has_skill("Resonance Overflow"):
        base_gain *= 1.2

    return base_gain

static func check_overload(combatant: Combatant) -> bool:
    return combatant.resonance_gauge >= 100

static func apply_overload_effects(combatant: Combatant) -> void:
    # Double damage dealt and taken
    combatant.stats.add_modifier("overload_offense", Stats.ATTACK, 2.0, Stats.MULTIPLY)
    combatant.stats.add_modifier("overload_defense", Stats.DEFENSE, 0.5, Stats.MULTIPLY)

    # Visual effects
    combatant.set_overload_visual(true)

static func apply_hollow_state(combatant: Combatant) -> void:
    # Reduce all stats by 50%
    combatant.stats.add_modifier("hollow", Stats.ALL_STATS, 0.5, Stats.MULTIPLY)

    # Disable Resonance abilities
    combatant.can_use_resonance = false

    # Visual effects
    combatant.set_hollow_visual(true)

static func cure_hollow(combatant: Combatant) -> void:
    combatant.stats.remove_modifier("hollow")
    combatant.can_use_resonance = true
    combatant.set_hollow_visual(false)
```

---

### 3. Echo System

```gdscript
# scripts/systems/Echo.gd
class_name Echo
extends Resource

enum Rarity { COMMON, UNCOMMON, RARE, LEGENDARY, UNIQUE }
enum Type { ATTACK, SUPPORT, DEBUFF, UNIQUE }

@export var id: String
@export var name: String
@export var description: String
@export var rarity: Rarity
@export var type: Type
@export var lore_text: String # For Story Echoes

# For combat echoes
@export var effect_script: String # Path to effect script
@export var can_use_in_battle: bool = true

# For tuning echoes
@export var tuning_properties: Dictionary = {}

# For story echoes
@export var story_data: Dictionary = {}

func use_in_battle(user: Combatant, targets: Array[Combatant]) -> void:
    if !can_use_in_battle:
        return

    # Load and execute effect
    var effect = load(effect_script).new()
    effect.execute(user, targets, self)

func get_tuning_bonuses() -> Dictionary:
    return tuning_properties
```

#### Echo Collection Manager

```gdscript
# scripts/autoload/EchoManager.gd
extends Node

signal echo_collected(echo: Echo)

var collected_echoes: Dictionary = {} # {echo_id: Echo}
var equipped_echoes: Array[Echo] = []
var max_equipped: int = 6

func collect_echo(echo: Echo) -> void:
    if !collected_echoes.has(echo.id):
        collected_echoes[echo.id] = echo
        echo_collected.emit(echo)

func equip_echo(echo: Echo, slot: int) -> bool:
    if slot < 0 or slot >= max_equipped:
        return false

    if equipped_echoes.size() <= slot:
        equipped_echoes.resize(slot + 1)

    equipped_echoes[slot] = echo
    return true

func unequip_echo(slot: int) -> void:
    if slot >= 0 and slot < equipped_echoes.size():
        equipped_echoes[slot] = null

func get_equipped() -> Array[Echo]:
    return equipped_echoes.filter(func(e): return e != null)

func reset_echo_uses() -> void:
    # Called after each battle
    pass # Echoes auto-recharge
```

---

### 4. Character & Party System

```gdscript
# scripts/autoload/PartyManager.gd
extends Node

const MAX_ACTIVE_PARTY = 4
const MAX_TOTAL_PARTY = 8

var all_characters: Dictionary = {} # {character_id: Character}
var active_party: Array[Character] = []

func add_character(character: Character) -> void:
    all_characters[character.id] = character

    if active_party.size() < MAX_ACTIVE_PARTY:
        add_to_active_party(character)

func add_to_active_party(character: Character) -> bool:
    if active_party.size() >= MAX_ACTIVE_PARTY:
        return false

    active_party.append(character)
    return true

func remove_from_active_party(character: Character) -> void:
    active_party.erase(character)

func swap_party_members(index1: int, index2: int) -> void:
    if index1 < active_party.size() and index2 < active_party.size():
        var temp = active_party[index1]
        active_party[index1] = active_party[index2]
        active_party[index2] = temp

func get_active_party() -> Array[Character]:
    return active_party
```

#### Character Stats System

```gdscript
# scripts/characters/Stats.gd
class_name Stats
extends Resource

enum StatType { HP, EE, ATTACK, MAGIC, DEFENSE, RESISTANCE, SPEED, LUCK, ALL_STATS }
enum ModifierType { ADD, MULTIPLY }

@export var base_stats: Dictionary = {
    StatType.HP: 100,
    StatType.EE: 50,
    StatType.ATTACK: 10,
    StatType.MAGIC: 10,
    StatType.DEFENSE: 5,
    StatType.RESISTANCE: 5,
    StatType.SPEED: 10,
    StatType.LUCK: 5
}

var modifiers: Array = [] # {name, stat, value, type}

func get_stat(stat: StatType) -> int:
    var base = base_stats.get(stat, 0)
    var final_value = base

    # Apply modifiers
    var additive = 0
    var multiplicative = 1.0

    for mod in modifiers:
        if mod.stat == stat or mod.stat == StatType.ALL_STATS:
            if mod.type == ModifierType.ADD:
                additive += mod.value
            else:
                multiplicative *= mod.value

    final_value = (base + additive) * multiplicative
    return int(final_value)

func add_modifier(name: String, stat: StatType, value: float, type: ModifierType) -> void:
    modifiers.append({
        "name": name,
        "stat": stat,
        "value": value,
        "type": type
    })

func remove_modifier(name: String) -> void:
    modifiers = modifiers.filter(func(m): return m.name != name)

# Convenience getters
var max_hp: int:
    get: return get_stat(StatType.HP)

var max_ee: int:
    get: return get_stat(StatType.EE)

var attack: int:
    get: return get_stat(StatType.ATTACK)

var magic: int:
    get: return get_stat(StatType.MAGIC)

var defense: int:
    get: return get_stat(StatType.DEFENSE)

var resistance: int:
    get: return get_stat(StatType.RESISTANCE)

var speed: int:
    get: return get_stat(StatType.SPEED)

var luck: int:
    get: return get_stat(StatType.LUCK)
```

---

### 5. Save System

```gdscript
# scripts/autoload/SaveManager.gd
extends Node

const SAVE_PATH = "user://saves/"
const MAX_SAVES = 10

func save_game(slot: int) -> bool:
    var save_data = {
        "version": "1.0",
        "timestamp": Time.get_unix_time_from_system(),
        "playtime": GameManager.playtime,
        "location": GameManager.current_location,

        # Party data
        "party": serialize_party(),

        # Inventory
        "inventory": serialize_inventory(),

        # Story flags
        "story_flags": GameManager.story_flags,

        # Echo collection
        "echoes": serialize_echoes(),

        # World state
        "world_state": serialize_world_state()
    }

    var file = FileAccess.open(get_save_path(slot), FileAccess.WRITE)
    if file:
        file.store_var(save_data)
        file.close()
        return true
    return false

func load_game(slot: int) -> bool:
    var file = FileAccess.open(get_save_path(slot), FileAccess.READ)
    if !file:
        return false

    var save_data = file.get_var()
    file.close()

    # Restore game state
    deserialize_party(save_data.party)
    deserialize_inventory(save_data.inventory)
    deserialize_echoes(save_data.echoes)
    deserialize_world_state(save_data.world_state)

    GameManager.story_flags = save_data.story_flags
    GameManager.playtime = save_data.playtime
    GameManager.current_location = save_data.location

    return true

func get_save_path(slot: int) -> String:
    return SAVE_PATH + "save_" + str(slot) + ".sav"

func serialize_party() -> Array:
    var party_data = []
    for character in PartyManager.active_party:
        party_data.append({
            "id": character.id,
            "level": character.level,
            "exp": character.exp,
            "current_hp": character.current_hp,
            "current_ee": character.current_ee,
            "equipment": serialize_equipment(character),
            "skill_tree": character.skill_tree.get_unlocked()
        })
    return party_data

# Additional serialization methods...
```

---

## UI Implementation Tips

### Battle UI Layout

```
┌─────────────────────────────────────────────────┐
│  [Enemy 1]  [Enemy 2]  [Enemy 3]                │
│                                                  │
│                 [Battle Area]                    │
│                                                  │
│  [Char 1]    [Char 2]   [Char 3]   [Char 4]    │
├─────────────────────────────────────────────────┤
│ Turn Order: [C1][E1][C2][E2][C3]...             │
├─────────────────────────────────────────────────┤
│ [Attack] [Resonance] [Item] [Echo] [Defend]    │
│                                                  │
│ Character: Kael     HP: 450/500  EE: 30/80      │
│ Resonance: ████████░░ 80%                       │
└─────────────────────────────────────────────────┘
```

### Control Remapping

Store controls in a configuration that can be easily modified:

```gdscript
# Autoload: InputManager.gd
var actions = {
    "ui_accept": [KEY_ENTER, JOY_BUTTON_A],
    "ui_cancel": [KEY_ESCAPE, JOY_BUTTON_B],
    "menu_open": [KEY_X, JOY_BUTTON_Y],
    # etc...
}

func remap_action(action_name: String, new_keys: Array) -> void:
    InputMap.action_erase_events(action_name)
    for key in new_keys:
        var event
        if key is int and key < 256: # Keyboard
            event = InputEventKey.new()
            event.keycode = key
        else: # Joypad
            event = InputEventJoypadButton.new()
            event.button_index = key
        InputMap.action_add_event(action_name, event)
```

---

## Performance Optimization

### Object Pooling for Effects

```gdscript
# Autoload: EffectPool.gd
var pools: Dictionary = {}

func get_effect(effect_scene: PackedScene) -> Node:
    var path = effect_scene.resource_path

    if !pools.has(path):
        pools[path] = []

    var pool = pools[path]

    # Find inactive effect in pool
    for effect in pool:
        if !effect.is_active:
            effect.reset()
            return effect

    # Create new if pool empty
    var new_effect = effect_scene.instantiate()
    pool.append(new_effect)
    return new_effect

func return_effect(effect: Node) -> void:
    effect.is_active = false
    effect.hide()
```

### Lazy Loading for Regions

Only load regions when player enters them:

```gdscript
func change_region(region_name: String) -> void:
    # Unload current region
    if current_region:
        current_region.queue_free()

    # Load new region
    var region_path = "res://scenes/overworld/regions/" + region_name + ".tscn"
    current_region = load(region_path).instantiate()
    add_child(current_region)
```

---

## Testing & Debug Tools

### Debug Console

```gdscript
# Debug commands for testing
func process_debug_command(command: String) -> void:
    var parts = command.split(" ")
    match parts[0]:
        "add_item":
            InventoryManager.add_item(parts[1], int(parts[2]))
        "set_level":
            PartyManager.active_party[0].level = int(parts[1])
        "unlock_echo":
            EchoManager.collect_echo(load("res://data/echoes/" + parts[1] + ".tres"))
        "heal_all":
            for char in PartyManager.active_party:
                char.current_hp = char.stats.max_hp
                char.current_ee = char.stats.max_ee
        "battle":
            start_test_battle(parts[1])
```

---

## Next Implementation Steps

1. **Week 1-2**: Basic battle system
   - Combatant class
   - Turn queue
   - Basic attack/defend

2. **Week 3-4**: Resonance system
   - Gauge mechanics
   - Overload states
   - Basic Resonance abilities

3. **Week 5-6**: Character system
   - Stats and leveling
   - Equipment
   - Basic skill trees

4. **Week 7-8**: Echo system
   - Collection mechanics
   - Battle integration
   - Basic Echo effects

5. **Week 9-10**: UI
   - Battle interface
   - Menus
   - Inventory

6. **Week 11-12**: Overworld
   - Basic movement
   - Region loading
   - NPC interaction

This forms the foundation for a vertical slice demonstration.

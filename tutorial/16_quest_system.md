# Module 16: The Quest System and Game Flags

## What We Have So Far

Combat with rewards and leveling, a dungeon, NPCs with dialogue. The game has systems — but it doesn't have a *story*. Nothing connects the player's actions into a progression.

## What We're Building This Module

Two things: a **game flags** system for tracking boolean world state, and a **quest system** built on top of it. Together, they make the world react to what the player does — NPCs say different things, doors open, new areas unlock.

## Game Flags: The Boolean Backbone

Game flags are the simplest and most universal state tracking in JRPGs. A flag is a boolean: something either has or hasn't happened.

```
"talked_to_lira" = true
"crystal_cavern_unlocked" = false
"boss_defeated" = false
"pendant_found" = false
```

Create `res://autoloads/game_manager.gd`:

```gdscript
extends Node
## Tracks global game state via boolean flags. Autoload as GameManager.

signal flag_changed(flag_name: String, value: bool)

var _flags: Dictionary = {}


func set_flag(flag_name: String, value: bool = true) -> void:
    var old_value: bool = _flags.get(flag_name, false)
    _flags[flag_name] = value
    if old_value != value:
        flag_changed.emit(flag_name, value)


func get_flag(flag_name: String) -> bool:
    return _flags.get(flag_name, false)


func has_flag(flag_name: String) -> bool:
    return _flags.get(flag_name, false)


func clear_flag(flag_name: String) -> void:
    set_flag(flag_name, false)


func get_all_flags() -> Dictionary:
    return _flags.duplicate()


func load_flags(data: Dictionary) -> void:
    _flags = data.duplicate()
```

Register as autoload `GameManager`.

Flags are used everywhere:
- NPCs check flags to choose dialogue
- Doors check flags to decide if they're locked
- Quest objectives check flags to track completion
- The save system saves and loads flags

## QuestData Resource

```gdscript
extends Resource
class_name QuestData
## Defines a quest with objectives, rewards, and state.

enum QuestState { NOT_STARTED, ACTIVE, COMPLETE, TURNED_IN }

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export_group("Objectives")
@export var objectives: Array[String] = []         # Human-readable descriptions
@export var objective_flags: Array[String] = []     # Flag names that mark completion

@export_group("Rewards")
@export var xp_reward: int = 0
@export var gold_reward: int = 0
@export var reward_items: Array[ItemData] = []
@export var completion_flag: String = ""  # Flag set when quest is turned in
```

## QuestManager Autoload

```gdscript
extends Node
## Tracks active quests and checks objectives. Autoload as QuestManager.

signal quest_started(quest: QuestData)
signal quest_completed(quest: QuestData)
signal quest_turned_in(quest: QuestData)

var _active_quests: Array[QuestData] = []
var _completed_quests: Array[QuestData] = []
var _turned_in_quests: Array[QuestData] = []


func _ready() -> void:
    GameManager.flag_changed.connect(_on_flag_changed)


func start_quest(quest: QuestData) -> void:
    if _is_quest_active(quest.id) or _is_quest_done(quest.id):
        return
    _active_quests.append(quest)
    quest_started.emit(quest)


func is_quest_active(quest_id: String) -> bool:
    return _is_quest_active(quest_id)


func is_quest_complete(quest_id: String) -> bool:
    for q in _completed_quests:
        if q.id == quest_id:
            return true
    return false


func turn_in_quest(quest: QuestData) -> void:
    _completed_quests.erase(quest)
    _turned_in_quests.append(quest)

    # Grant rewards
    if quest.gold_reward > 0:
        InventoryManager.add_gold(quest.gold_reward)
    for item in quest.reward_items:
        InventoryManager.add_item(item)
    if not quest.completion_flag.is_empty():
        GameManager.set_flag(quest.completion_flag)

    quest_turned_in.emit(quest)


func get_active_quests() -> Array[QuestData]:
    return _active_quests


func get_completed_quests() -> Array[QuestData]:
    return _turned_in_quests


func _on_flag_changed(flag_name: String, _value: bool) -> void:
    # Check if any active quest's objectives are now all met
    # Collect completed quests first — don't modify the array during iteration
    var newly_completed: Array[QuestData] = []
    for quest in _active_quests:
        if _all_objectives_met(quest):
            newly_completed.append(quest)
    for quest in newly_completed:
        _active_quests.erase(quest)
        _completed_quests.append(quest)
        quest_completed.emit(quest)


func _all_objectives_met(quest: QuestData) -> bool:
    for flag in quest.objective_flags:
        if not GameManager.has_flag(flag):
            return false
    return true


func _is_quest_active(quest_id: String) -> bool:
    return _active_quests.any(func(q: QuestData) -> bool: return q.id == quest_id)


func _is_quest_done(quest_id: String) -> bool:
    return _turned_in_quests.any(func(q: QuestData) -> bool: return q.id == quest_id)
```

## Crystal Saga Quests

### Main Quest: "The Crystal Resonance"

```
Objectives:
1. Talk to Elder Maren in Willowbrook → flag: "talked_to_elder"
2. Explore Whisperwood → flag: "reached_whisperwood"
3. Find the Crystal Cavern → flag: "entered_crystal_cavern"
4. Defeat the Crystal Guardian → flag: "boss_defeated"

Reward: 200 XP, 100 gold
```

### Side Quest: "The Lost Pendant"

```
Objectives:
1. Talk to Wandering Fynn → flag: "talked_to_fynn" (starts quest)
2. Find the pendant in Whisperwood → flag: "pendant_found"
3. Return pendant to Fynn → flag: "pendant_returned"

Reward: 50 XP, 30 gold, Ether x2
```

## Reactive Dialogue

NPCs should say different things based on quest state and flags. Update NPC dialogue to check flags:

```gdscript
# In the scene script that handles NPC interaction:
func _get_dialogue_for_npc(npc: CharacterBody2D) -> Array[DialogueLine]:
    match npc.npc_data.id:
        "traveler_fynn":
            return _get_fynn_dialogue()
        _:
            return npc.npc_data.dialogue


func _get_fynn_dialogue() -> Array[DialogueLine]:
    if GameManager.has_flag("pendant_returned"):
        return _make_lines("Fynn", ["Thank you again for finding my pendant!"])
    elif GameManager.has_flag("pendant_found"):
        return _make_lines("Fynn", [
            "You found it! My pendant! Thank you so much!",
            "Please, take this as a reward.",
        ])
    elif GameManager.has_flag("talked_to_fynn"):
        return _make_lines("Fynn", ["Any luck finding my pendant in the Whisperwood?"])
    else:
        GameManager.set_flag("talked_to_fynn")
        var quest: QuestData = load("res://data/quests/lost_pendant.tres")
        if quest:
            QuestManager.start_quest(quest)
        return _make_lines("Fynn", [
            "I lost something precious in the Whisperwood...",
            "A pendant, silver with a blue stone.",
            "If you find it, I'd be forever grateful.",
        ])


func _make_lines(speaker: String, texts: Array[String]) -> Array[DialogueLine]:
    var lines: Array[DialogueLine] = []
    for text in texts:
        var line := DialogueLine.new()
        line.speaker_name = speaker
        line.text = text
        lines.append(line)
    return lines
```

## Quest Log UI

A simple quest log accessible from the pause menu. Create `res://ui/quest_log/quest_log.tscn`:

### Scene Tree

```
QuestLog (PanelContainer)
└── MarginContainer
    └── VBoxContainer
        ├── QuestList (VBoxContainer)
        └── DetailLabel (RichTextLabel, bbcode_enabled)
```

### Script

Save as `res://ui/quest_log/quest_log.gd`:

```gdscript
extends PanelContainer
## Displays active and completed quests.

@onready var _quest_list: VBoxContainer = $MarginContainer/VBoxContainer/QuestList
@onready var _detail_label: RichTextLabel = $MarginContainer/VBoxContainer/DetailLabel


func refresh() -> void:
    for child in _quest_list.get_children():
        child.queue_free()

    await get_tree().process_frame

    var active := QuestManager.get_active_quests()
    for quest in active:
        var button := Button.new()
        button.text = quest.title
        button.pressed.connect(_show_detail.bind(quest))
        _quest_list.add_child(button)

    if _quest_list.get_child_count() > 0:
        await get_tree().process_frame
        _quest_list.get_child(0).grab_focus()


func _show_detail(quest: QuestData) -> void:
    var text := "[b]" + quest.title + "[/b]\n\n"
    text += quest.description + "\n\n[b]Objectives:[/b]\n"
    for i in quest.objectives.size():
        var done: bool = false
        if i < quest.objective_flags.size():
            done = GameManager.has_flag(quest.objective_flags[i])
        var marker: String = "[x]" if done else "[ ]"
        text += marker + " " + quest.objectives[i] + "\n"
    _detail_label.text = text
```

**Autoload reference card:**

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 6 | Scene transitions with fade effects |
| InventoryManager | 10 | Item storage, add/remove, signals |
| BattleManager | 11 | Battle state machine, turn queue |
| **GameManager** | **16** | **Game flags, world state tracking** |
| **QuestManager** | **16** | **Quest tracking, objective checking** |

## What We've Learned

- **Game flags** are boolean key-value pairs tracking world state (`flag_name → bool`).
- **`GameManager.flag_changed` signal** lets any system react when the world state changes.
- **QuestData** defines objectives as flag names — a quest completes when all its flags are set.
- **Reactive dialogue** checks flags to choose what an NPC says — creating the illusion of a living world.
- **Quest rewards** are granted on turn-in: gold, items, and a completion flag.
- The quest log shows objectives with checkmarks based on current flag state.

## What You Should See

- Talking to Fynn starts the "Lost Pendant" quest
- The quest log shows active quests with checkable objectives
- Finding the pendant in Whisperwood marks the objective
- Returning to Fynn triggers different dialogue and grants rewards
- NPCs react to your progress throughout the game

## Next Module

In **Module 17: Party Management, Equipment, and Shops**, we'll recruit Lira the mage, add equipment that modifies stats, and build the shop system — the final progression systems before save/load.

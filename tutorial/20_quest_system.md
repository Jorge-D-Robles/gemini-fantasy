# Module 20: The Quest System and Game Flags

## What We Have So Far

Combat with rewards and leveling, a dungeon, NPCs with dialogue. The game has systems, but nothing connecting the player's actions into a progression.

## What We're Building This Module

Two things: a **game flags** system for tracking boolean world state, and a **quest system** built on top of it. Together, they make the world react to what the player does: NPCs say different things, doors open, new areas unlock.

## Game Flags: The Boolean Backbone

Think about what happens in Final Fantasy VI when you first meet Shadow in the bar at South Figaro. The game remembers whether you talked to him, whether you recruited him, and whether he ran away in your last battle. Dozens of tiny yes-or-no questions like these are tracked behind the scenes. Without them, every NPC would repeat the same line forever and the world would feel frozen. Game flags are how a JRPG makes the world remember what you did.

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

Dragon Quest has hundreds of quests, and each one tracks the same things: a description, a list of objectives, and a reward. If each quest were a unique script with custom logic, the codebase would be unmanageable. Defining quests as data (a Resource with fields for title, objectives, and rewards) means adding a new quest is filling out a form, not writing new code.

Save as `res://resources/quest_data.gd`:

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

Save as `res://autoloads/quest_manager.gd` and register as autoload `QuestManager` (Project -> Project Settings -> Autoload tab -> add the script path, name it `QuestManager`).

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
    if quest.xp_reward > 0:
        # Distribute XP to all party members (once PartyManager exists in Module 21)
        # PartyManager is added in Module 21. Guard against it not existing yet.
        if get_node_or_null("/root/PartyManager"):
            for member in PartyManager.get_members():
                member.current_xp += quest.xp_reward
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
    # Collect completed quests first; don't modify the array during iteration
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

### Creating Quest `.tres` Files

Create the `res://data/quests/` folder (right-click `res://data/` → New Folder → `quests`).

**Main Quest: "The Crystal Resonance"**

1. Right-click `res://data/quests/` → New Resource → select **QuestData**
2. Save as `crystal_resonance.tres`
3. In the Inspector, set these fields:
   - `id`: "crystal_resonance"
   - `title`: "The Crystal Resonance"
   - `description`: "Investigate the crystal disturbances in the cave."
   - **Objectives:** Click the array, add 4 entries:
     - "Talk to Elder Maren in Willowbrook"
     - "Explore Whisperwood"
     - "Find the Crystal Cavern"
     - "Defeat the Crystal Guardian"
   - **Objective Flags:** Click the array, add 4 matching entries:
     - "talked_to_elder"
     - "reached_whisperwood"
     - "entered_crystal_cavern"
     - "boss_defeated"
   - `xp_reward`: 200
   - `gold_reward`: 100

**Side Quest: "The Lost Pendant"**

1. Right-click `res://data/quests/` → New Resource → **QuestData**
2. Save as `lost_pendant.tres`
3. Set fields:
   - `id`: "lost_pendant"
   - `title`: "The Lost Pendant"
   - `description`: "Find Fynn's pendant in the Whisperwood."
   - **Objectives:** "Talk to Wandering Fynn", "Find the pendant in Whisperwood", "Return pendant to Fynn"
   - **Objective Flags:** "talked_to_fynn", "pendant_found", "pendant_returned"
   - `xp_reward`: 50
   - `gold_reward`: 30
   - **Reward Items:** Drag `ether.tres` into the array, set count to 2

## Setting Quest Flags from Gameplay

The quest objectives rely on flags being set when things happen. Here's where to add flag-setting calls:

**In `res://scenes/willowbrook/willowbrook.gd`** (the elder NPC interaction):
```gdscript
# When the player talks to Elder Maren, set the flag:
func _on_elder_interacted() -> void:
    GameManager.set_flag("talked_to_elder")
    # ... existing dialogue code ...
```

**In `res://scenes/whisperwood/whisperwood.gd`** (scene entry):
```gdscript
func _ready() -> void:
    GameManager.set_flag("reached_whisperwood")
    # ... existing setup code ...
```

**In `res://scenes/crystal_cavern/crystal_cavern.gd`** (scene entry):
```gdscript
func _ready() -> void:
    GameManager.set_flag("entered_crystal_cavern")
    # ... existing setup code ...
```

The `boss_defeated` flag is set in Module 25's ending trigger. The `talked_to_fynn` flag is set in the reactive dialogue below.

**Starting the main quest:** Add this to the elder's dialogue handler in `willowbrook.gd`:
```gdscript
if not QuestManager.is_quest_active("crystal_resonance"):
    var quest: QuestData = load("res://data/quests/crystal_resonance.tres")
    if quest:
        QuestManager.start_quest(quest)
```

### The Pendant Pickup

The side quest needs a pendant object in Whisperwood. Use the treasure chest pattern from Module 16 to create a pickup:

1. Create `res://data/items/pendant.tres` (ItemData, type: KEY_ITEM, display_name: "Silver Pendant")
2. Place a treasure chest instance in the Whisperwood scene near a memorable landmark
3. Set the chest's `item` export to `pendant.tres` in the Inspector
4. In `whisperwood.gd`, connect to the chest's `opened` signal to set the flag:

```gdscript
func _on_pendant_chest_opened() -> void:
    GameManager.set_flag("pendant_found")
```

For Fynn's turn-in, add this to the `pendant_found` dialogue path in `willowbrook.gd`:
```gdscript
# After the "You found it!" dialogue finishes:
GameManager.set_flag("pendant_returned")
var quest: QuestData = load("res://data/quests/lost_pendant.tres")
if quest:
    QuestManager.turn_in_quest(quest)
```

## Reactive Dialogue

In Chrono Trigger, every NPC in every town updates their dialogue after each major story event. After you rescue Queen Leene, the castle guards stop asking for help and start thanking you. This is what makes the world feel alive; characters acknowledge what you have done. Without reactive dialogue, NPCs are just repeating billboards, and the player never feels like their actions matter.

NPCs should say different things based on quest state and flags. Update NPC dialogue to check flags.

Add the following to `res://scenes/willowbrook/willowbrook.gd`. Then update your existing `_on_npc_interacted()` handler to call this function instead of reading `npc.npc_data.dialogue` directly:

```gdscript
# In _on_npc_interacted(), replace:
#   _dialogue_box.start_dialogue(npc.npc_data.dialogue)
# with:
#   _dialogue_box.start_dialogue(_get_dialogue_for_npc(npc))

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

The moment a JRPG has more than one quest, players start forgetting what they were doing. Earthbound lets you call your dad to get a hint, but most RPGs solve this with a quest journal. Even a simple log with checkable objectives prevents the frustration of wandering aimlessly because you forgot which NPC to talk to next.

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
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| **GameManager** | **20** | **Game flags, world state tracking** |
| **QuestManager** | **20** | **Quest tracking, objective checking** |

> **See:** [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html). GameManager and QuestManager are both autoloads. This tutorial covers when and why to use the autoload pattern.

> **See:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). QuestData extends Resource. This guide covers custom Resources, `@export` properties, and `.tres` file creation.

## What We've Learned

- **Game flags** are boolean key-value pairs tracking world state (`flag_name → bool`).
- **`GameManager.flag_changed` signal** lets any system react when the world state changes.
- **QuestData** defines objectives as flag names; a quest completes when all its flags are set.
- **Reactive dialogue** checks flags to choose what an NPC says, creating the illusion of a living world.
- **Quest rewards** are granted on turn-in: gold, items, and a completion flag.
- The quest log shows objectives with checkmarks based on current flag state.

## What You Should See

- Talking to Fynn starts the "Lost Pendant" quest
- The quest log shows active quests with checkable objectives
- Finding the pendant in Whisperwood marks the objective
- Returning to Fynn triggers different dialogue and grants rewards
- NPCs react to your progress throughout the game

## Next Module

In **Module 21: Party Management, Equipment, and Shops**, we'll recruit Lira the mage, add equipment that modifies stats, and build the shop system, the final progression systems before save/load.

# Merged Tutorial Part V: Progression and Persistence

This generated file combines the tutorial Markdown files for this tutorial part.

## Included Files

- `20_quest_system.md`
- `21_party_and_equipment.md`
- `22_save_and_load.md`
- `23_part_v_review.md`

---

<!-- Source: 20_quest_system.md -->

# Module 20: The Quest System and Game Flags

## What We Have So Far

Combat with rewards and leveling, a dungeon, NPCs with dialogue. The game has systems, but nothing connecting the player's actions into a progression.

## What We're Building This Module

Two things: a **game flags** system for tracking boolean world state, and a **quest system** built on top of it. Together, they make the world react to what the player does: NPCs say different things, doors open, new areas unlock.

## Game Flags: The Boolean Backbone

Think about what happens in Final Fantasy VI when you first meet Shadow in the bar at South Figaro. The game remembers whether you talked to him, whether you recruited him, and whether he ran away in your last battle. Dozens of tiny yes-or-no questions like these are tracked behind the scenes. Without them, every NPC would repeat the same line forever and the world would feel frozen. Game flags are how a JRPG makes the world remember what you did.

Game flags are the simplest and most universal state tracking in JRPGs. A flag is a boolean: something either has or hasn't happened.

```
"lira_intro_seen" = true
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


func make_world_flag(scene_key: String, object_id: String, state: String) -> String:
    return "world.%s.%s.%s" % [scene_key, object_id, state]


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
    if _is_quest_active(quest.id) or is_quest_complete(quest.id) or _is_quest_done(quest.id):
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


func get_quest_state(quest_id: String) -> QuestData.QuestState:
    if _is_quest_done(quest_id):
        return QuestData.QuestState.TURNED_IN
    if is_quest_complete(quest_id):
        return QuestData.QuestState.COMPLETE
    if is_quest_active(quest_id):
        return QuestData.QuestState.ACTIVE
    return QuestData.QuestState.NOT_STARTED


func turn_in_quest(quest: QuestData) -> bool:
    if not quest:
        return false
    return turn_in_quest_by_id(quest.id)


func turn_in_quest_by_id(quest_id: String) -> bool:
    var quest: QuestData = null
    for candidate in _completed_quests:
        if candidate.id == quest_id:
            quest = candidate
            break

    if not quest:
        return false

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
    return true


func get_active_quests() -> Array[QuestData]:
    return _active_quests.duplicate()


func get_completed_quests() -> Array[QuestData]:
    return _completed_quests.duplicate()


func get_turned_in_quests() -> Array[QuestData]:
    return _turned_in_quests.duplicate()


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

Notice what `turn_in_quest()` does **not** do yet: it does not award quest XP. That is intentional. Module 20 happens before PartyManager exists, so this version stays self-contained and safe to paste into the project at this point in the series. In Module 21, once the party roster exists, we'll revisit `turn_in_quest()` and route quest XP through the same leveling helper battles already use.

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
   - **Objectives:** "Talk to Wandering Fynn", "Find the pendant in Whisperwood"
   - **Objective Flags:** "talked_to_fynn", "pendant_found"
   - `completion_flag`: "pendant_returned"
   - `xp_reward`: 50
   - `gold_reward`: 30
   - **Reward Items:** Click **Add Element** twice and drag `ether.tres` into both slots. In this tutorial, `reward_items` is a plain `Array[ItemData]`, so duplicate entries represent multiple copies.

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

For Fynn's turn-in, add this to the `pendant_found` dialogue path in `willowbrook.gd`. Finding the pendant completes the objective; returning it is the turn-in action:
```gdscript
# After the "You found it!" dialogue finishes:
if QuestManager.turn_in_quest_by_id("lost_pendant"):
    var pendant := load("res://data/items/pendant.tres") as ItemData
    if pendant:
        InventoryManager.remove_item(pendant)
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
        var lines := _make_lines("Fynn", [
            "You found it! My pendant! Thank you so much!",
            "Please, take this as a reward.",
        ])
        if QuestManager.turn_in_quest_by_id("lost_pendant"):
            var pendant := load("res://data/items/pendant.tres") as ItemData
            if pendant:
                InventoryManager.remove_item(pendant)
        return lines
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
## Displays quest objectives and current progress.

var _is_open: bool = false

@onready var _quest_list: VBoxContainer = $MarginContainer/VBoxContainer/QuestList
@onready var _detail_label: RichTextLabel = $MarginContainer/VBoxContainer/DetailLabel


func _ready() -> void:
    visible = false
    process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") and _is_open:
        close()
        get_viewport().set_input_as_handled()


func open_from_pause() -> void:
    _is_open = true
    visible = true
    get_tree().paused = true
    refresh()


func close() -> void:
    _is_open = false
    visible = false
    get_tree().paused = false


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

After creating the scene, instance `quest_log.tscn` into each gameplay scene you currently have (`Willowbrook`, `Whisperwood`, and `CrystalCavern`) as a direct child of the scene root, alongside your other UI nodes. Leave it hidden by default. Module 25's PauseMenu will open these scene-local quest logs through `open_from_pause()`, just like it opens the inventory through Module 12's public API.

This first quest log keeps the presentation simple: it only lists **active** quests. `QuestManager` still tracks completed and turned-in quests separately for reward handling, save/load, and future journal tabs, but we are not surfacing those lists in the UI yet.

**Autoload reference card:**

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| **GameManager** | **20** | **Game flags, world state tracking** |
| **QuestManager** | **20** | **Quest tracking, objective checking** |

> **See:** [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html). GameManager and QuestManager are both autoloads. This tutorial covers when and why to use the autoload pattern.

> **See:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). QuestData extends Resource. This guide covers custom Resources, `@export` properties, and `.tres` file creation.

## Engineering Contract

- **Global state:** GameManager owns flags; QuestManager owns quest lifecycle arrays.
- **Public surface:** `set_flag()`, `make_world_flag()`, `start_quest()`, `get_quest_state()`, and `turn_in_quest_by_id()`.
- **Invariant:** Quest completion and quest turn-in are separate states; rewards are granted only from the completed state.
- **Failure behavior:** Turning in an unknown, active, or already turned-in quest returns `false`.
- **Copy semantics:** Quest list getters return defensive copies of manager arrays; QuestData Resources remain shared definitions.

## Engine Gotcha

Custom autoloads are not the same thing as engine singletons. `GameManager` and `QuestManager` are project nodes under `/root`, while `Input` and `AudioServer` are engine-provided singletons.

## What We've Learned

- **Game flags** are boolean key-value pairs tracking world state (`flag_name → bool`).
- **`GameManager.flag_changed` signal** lets any system react when the world state changes.
- **QuestData** defines objectives as flag names; a quest completes when all its flags are set.
- **Reactive dialogue** checks flags to choose what an NPC says, creating the illusion of a living world.
- **Quest rewards** are granted on turn-in: gold, items, and a completion flag. The `xp_reward` field is defined now and gets wired into PartyManager in Module 21.
- The first quest log shows **active** quests with objectives and checkmarks based on current flag state.

## What You Should See

- Talking to Fynn starts the "Lost Pendant" quest
- The quest log shows active quests with checkable objectives
- Finding the pendant in Whisperwood marks the objective
- Returning to Fynn triggers different dialogue and grants rewards
- NPCs react to your progress throughout the game

## Next Module

In **Module 21: Party Management, Equipment, and Shops**, we'll recruit Lira the mage, add equipment that modifies stats, and build the shop system, the final progression systems before save/load.


---

<!-- Source: 21_party_and_equipment.md -->

# Module 21: Party Management, Equipment, and Shops

## What We Have So Far

Quests, game flags, reactive dialogue, a dungeon with a boss, a battle system with leveling. The hero has been fighting alone.

## What We're Building This Module

Three major systems: **party management** (recruiting Lira the mage), **equipment** (weapons and armor that modify stats), and **shops** (buying and selling). These are the final progression systems.

## PartyManager Autoload

In Pokemon, your party of six travels with you everywhere. They appear in battle, they need healing at the Pokemon Center, and the PC storage system swaps them in and out. All of that requires one central place that knows who is in your party right now. Without a PartyManager, every system that cares about the roster (battle, save/load, equipment, healing) would need its own copy of the party list, and they would inevitably get out of sync.

Create `res://autoloads/party_manager.gd`:

```gdscript
extends Node
## Manages the party roster. Autoload as PartyManager.

signal party_member_joined(character: CharacterData)
signal party_member_removed(character: CharacterData)

var members: Array[CharacterData] = []


func _ready() -> void:
    # Start with the hero
    var aiden: CharacterData = load("res://data/characters/aiden.tres")
    if aiden:
        add_member(aiden)


func add_member(character: CharacterData) -> void:
    if not members.has(character):
        members.append(character)
        party_member_joined.emit(character)


func remove_member(character: CharacterData) -> void:
    if members.has(character):
        members.erase(character)
        party_member_removed.emit(character)


func get_members() -> Array[CharacterData]:
    return members.duplicate()


func get_member_by_id(id: String) -> CharacterData:
    for member in members:
        if member.id == id:
            return member
    return null


func award_xp_to_party(xp_per_member: int) -> void:
    if xp_per_member <= 0:
        return

    for member in members:
        print(member.display_name + " gained " + str(xp_per_member) + " XP!")
        for result in member.grant_xp(xp_per_member):
            var gains: Dictionary = result.gains
            print(member.display_name + " reached level " + str(result.level) + "!")
            print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
                  ", DEF +" + str(gains.defense))
```

Register as autoload `PartyManager`.

### Finishing Quest XP Integration

In Module 20, `QuestData` already had an `xp_reward` field, but `QuestManager.turn_in_quest_by_id()` intentionally left it unused because PartyManager did not exist yet. Now that the roster is in place, reopen `res://autoloads/quest_manager.gd` and update the reward section inside `turn_in_quest_by_id()`:

```gdscript
func turn_in_quest_by_id(quest_id: String) -> bool:
    var quest: QuestData = null
    for candidate in _completed_quests:
        if candidate.id == quest_id:
            quest = candidate
            break

    if not quest:
        return false

    _completed_quests.erase(quest)
    _turned_in_quests.append(quest)

    if quest.xp_reward > 0:
        PartyManager.award_xp_to_party(quest.xp_reward)
    if quest.gold_reward > 0:
        InventoryManager.add_gold(quest.gold_reward)
    for item in quest.reward_items:
        InventoryManager.add_item(item)
    if not quest.completion_flag.is_empty():
        GameManager.set_flag(quest.completion_flag)

    quest_turned_in.emit(quest)
    return true
```

This keeps quest turn-ins on the same leveling path as battle rewards. `PartyManager` owns "who gets XP," while `CharacterData.grant_xp()` still owns the actual leveling math from Module 18.

## Recruiting Lira

Create Lira's character data: right-click `res://data/characters/` → **New Resource** → search `CharacterData` → **Create** → name it `lira.tres`. Set ALL of these fields in the Inspector:
- `id`: "lira"
- `display_name`: "Lira"
- `max_hp`: 80, `max_mp`: 40
- `attack`: 6, `defense`: 5, `speed`: 9
- `hp_growth`: 8, `mp_growth`: 8, `attack_growth`: 1, `defense_growth`: 1, `speed_growth`: 2

> **Important:** The `id` field must be `"lira"` exactly. `PartyManager.get_member_by_id("lira")` uses this to find her. All growth rate fields must be non-zero or she won't gain stats on level-up (see Module 18).

Lira is a mage: lower HP and attack, higher MP and speed.

### The Recruitment Scene

In Willowbrook, add a new NPC: Lira. She joins the party after a dialogue exchange, gated by a game flag:

```gdscript
func _get_lira_dialogue() -> Array[DialogueLine]:
    if GameManager.has_flag("lira_joined"):
        return _make_lines("Lira", ["Ready to go when you are!"])

    if GameManager.has_flag("lira_ready_to_join"):
        return _make_lines("Lira", [
            "I've been studying the crystal formations nearby.",
            "They resonate with a strange energy...",
            "If you're heading to the Crystal Cavern, I'd like to come along.",
            "My magic could be useful!",
        ])

    if GameManager.has_flag("lira_intro_seen"):
        GameManager.set_flag("lira_ready_to_join")
        return _make_lines("Lira", [
            "I've been studying the crystal formations nearby.",
            "They resonate with a strange energy...",
            "If you're heading to the Crystal Cavern, I'd like to come along.",
            "My magic could be useful!",
        ])

    # First meeting
    GameManager.set_flag("lira_intro_seen")
    return _make_lines("Lira", [
        "Oh, hello! I'm Lira, a scholar from the capital.",
        "I came to Willowbrook to study the ancient crystals.",
        "Talk to me again if you're interested in what I've found.",
    ])
```

After the second conversation, trigger recruitment. This code goes in `willowbrook.gd`, which should have `@onready` references for the UI nodes (from Module 11 and this module):

```gdscript
@onready var _dialogue_box: Control = $DialogueBox  # From Module 11
@onready var _shop_ui: CanvasLayer = $ShopUI         # Instance of shop_ui.tscn (add to scene)
```

Add the recruitment wiring to the existing interaction handler:

```gdscript
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    # ... existing dialogue logic ...

    # Check for Lira recruitment after the second conversation
    if npc.npc_data.id == "lira" and GameManager.has_flag("lira_ready_to_join") and not GameManager.has_flag("lira_joined"):
        _dialogue_box.dialogue_finished.connect(_recruit_lira, CONNECT_ONE_SHOT)


func _recruit_lira() -> void:
    GameManager.set_flag("lira_joined")
    var lira: CharacterData = load("res://data/characters/lira.tres")
    if lira:
        PartyManager.add_member(lira)
        print("Lira joined the party!")
```

Update the battle initialization to use PartyManager instead of a hardcoded hero. In each area scene script that triggers battles (e.g., `crystal_cavern.gd` from Module 17), find the code that creates `var hero := BattlerData.new()` and replace the hero creation + `start_battle` call with:

```gdscript
# Build party BattlerData from PartyManager
var party_battlers: Array[BattlerData] = []
for char_data in PartyManager.get_members():
    var battler := BattlerData.new()
    battler.character_data = char_data
    battler.is_player_controlled = true
    party_battlers.append(battler)

# Use the full party instead of just [hero]
SceneManager.start_battle({party = party_battlers, enemies = enemy_battlers})
```

Apply this same change to the boss trigger (`boss_trigger.gd`) and any other script that calls `SceneManager.start_battle()`.

## Equipment System

In Final Fantasy IV, Cecil starts as a Dark Knight with heavy armor and a cursed sword. When he becomes a Paladin, his equipment changes completely and so does how he plays. Equipment is the most tangible form of character progression: the player can see their attack number go up and feel the difference in battle. It also drives the core economic loop: fight enemies, earn gold, buy better gear, fight harder enemies.

### Extending CharacterData

Add equipment slots to `character_data.gd`:

```gdscript
# Add to CharacterData
var equipped_weapon: ItemData = null
var equipped_armor: ItemData = null
var equipped_accessory: ItemData = null
# current_xp/current_hp/current_mp were introduced in Module 9 and used heavily in Module 18


func get_effective_attack() -> int:
    var bonus: int = equipped_weapon.attack_bonus if equipped_weapon else 0
    return attack + bonus


func get_effective_defense() -> int:
    var bonus: int = equipped_armor.defense_bonus if equipped_armor else 0
    bonus += equipped_accessory.defense_bonus if equipped_accessory else 0
    return defense + bonus


func get_effective_speed() -> int:
    var bonus: int = 0
    if equipped_accessory:
        bonus += equipped_accessory.speed_bonus
    return speed + bonus


func equip(item: ItemData) -> ItemData:
    ## Equips an item, returning the previously equipped item (or null).
    var previous: ItemData = null
    match item.equip_slot:
        ItemData.EquipSlot.WEAPON:
            previous = equipped_weapon
            equipped_weapon = item
        ItemData.EquipSlot.ARMOR:
            previous = equipped_armor
            equipped_armor = item
        ItemData.EquipSlot.ACCESSORY:
            previous = equipped_accessory
            equipped_accessory = item
    return previous


func unequip(slot: ItemData.EquipSlot) -> ItemData:
    var item: ItemData = null
    match slot:
        ItemData.EquipSlot.WEAPON:
            item = equipped_weapon
            equipped_weapon = null
        ItemData.EquipSlot.ARMOR:
            item = equipped_armor
            equipped_armor = null
        ItemData.EquipSlot.ACCESSORY:
            item = equipped_accessory
            equipped_accessory = null
    return item
```

### Creating Equipment Items

We need equipment the player can actually wear. If you created `iron_sword.tres` and `leather_armor.tres` back in Module 9, open them now and verify the equipment-specific fields match the values below. If you don't have them yet, create them now (right-click `res://data/items/` → New Resource → ItemData):

**Iron Sword** (`res://data/items/iron_sword.tres`):
- `id`: "iron_sword", `display_name`: "Iron Sword", `item_type`: EQUIPMENT, `equip_slot`: WEAPON, `attack_bonus`: 5, `buy_price`: 50, `sell_price`: 25

**Leather Armor** (`res://data/items/leather_armor.tres`):
- `id`: "leather_armor", `display_name`: "Leather Armor", `item_type`: EQUIPMENT, `equip_slot`: ARMOR, `defense_bonus`: 4, `buy_price`: 40, `sell_price`: 20

### The Complete Equip Flow

When equipping an item, the old item must return to inventory:

```gdscript
# Example: equipping from inventory (add to your equipment UI handler)
func _equip_item_on_character(character: CharacterData, item: ItemData) -> void:
    if not InventoryManager.remove_item(item):
        return

    var previous: ItemData = character.equip(item)
    if previous:
        InventoryManager.add_item(previous)
```

This three-step pattern (remove new item from inventory, equip it, add the old item back) prevents item duplication. The `equip()` method returns the old item so you always have a reference to it. If `remove_item()` returns `false`, stop before changing equipment.

### The Modifier Pattern (Looking Ahead)

Our equipment system uses simple addition: `effective_attack = base_attack + weapon.attack_bonus`. This works for Crystal Saga, but real RPGs need something more flexible. Consider: a spell that doubles your Attack for 3 turns, a poison that halves Speed, or a ring that adds +10% to all stats. Flat bonuses can't express percentages, and they don't stack cleanly with temporary buffs.

The standard solution is a **modifier system** where each modifier has two components:

- **add**: a flat bonus (e.g., +5 Attack from a sword)
- **mult**: a percentage multiplier (e.g., +0.25 for a 25% buff, -0.50 for a 50% debuff)

The formula: `final = (base + sum_of_adds) * (1.0 + sum_of_mults)`

All flat bonuses are summed first, then all percentage multipliers are applied together. This order matters: it makes percentage buffs more powerful (they multiply the total, not just the base), which is a deliberate design choice.

Each modifier gets a **unique ID**. This solves the stacking problem: two different +5 ATK swords stack (different IDs), but casting the same buff spell twice doesn't (same ID overwrites the previous instance).

We won't build this system for Crystal Saga; the simple `get_effective_*()` approach is sufficient. But if you later add status effects (Module 26 roadmap), buff/debuff spells, or set bonuses, the modifier system is the right abstraction. It lets equipment, spells, status effects, and passive abilities all feed into the same stat calculation through one unified mechanism.

### Battle Integration

Update BattlerData to use effective stats:

```gdscript
func initialize_from_character() -> void:
    if not character_data:
        return
    # Use current_hp/current_mp if set (carries over between battles)
    # Fall back to max values for the first battle or after a full heal
    current_hp = character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp
    current_mp = character_data.current_mp if character_data.current_mp > 0 else character_data.max_mp
    current_attack = character_data.get_effective_attack()
    current_defense = character_data.get_effective_defense()
    current_speed = character_data.get_effective_speed()
```

> **Important:** This ensures HP/MP carries over between battles. Module 18's Victory state syncs `battler.current_hp` back to `character_data.current_hp` after each fight. Without this check, the party would heal to full after every battle.

Now equipping a better sword directly increases damage in battle.

### Equipment UI

Create `res://ui/equipment/equipment_panel.tscn`:

```
EquipmentPanel (PanelContainer)
└── VBox (VBoxContainer)
    ├── NameLabel (Label)
    ├── StatsLabel (RichTextLabel)
    └── Slots (VBoxContainer)
        ├── WeaponButton (Button: "Weapon: None")
        ├── ArmorButton (Button: "Armor: None")
        └── AccessoryButton (Button: "Accessory: None")
```

Save the script as `res://ui/equipment/equipment_panel.gd`:

```gdscript
extends PanelContainer
## Equipment management for a party member.

signal equipment_changed

var _character: CharacterData

@onready var _name_label: Label = $VBox/NameLabel
@onready var _stats_label: RichTextLabel = $VBox/StatsLabel
@onready var _weapon_button: Button = $VBox/Slots/WeaponButton
@onready var _armor_button: Button = $VBox/Slots/ArmorButton
@onready var _accessory_button: Button = $VBox/Slots/AccessoryButton


func show_character(character: CharacterData) -> void:
    _character = character
    _refresh()


func _refresh() -> void:
    _name_label.text = _character.display_name + " (Lv. " + str(_character.level) + ")"
    _stats_label.text = (
        "HP: " + str(_character.max_hp) +
        "  ATK: " + str(_character.get_effective_attack()) +
        "  DEF: " + str(_character.get_effective_defense()) +
        "  SPD: " + str(_character.get_effective_speed())
    )
    _weapon_button.text = "Weapon: " + (_character.equipped_weapon.display_name if _character.equipped_weapon else "(none)")
    _armor_button.text = "Armor: " + (_character.equipped_armor.display_name if _character.equipped_armor else "(none)")
    _accessory_button.text = "Accessory: " + (_character.equipped_accessory.display_name if _character.equipped_accessory else "(none)")
```

### Slot Selection and Item Swapping

When the player clicks a slot button, show equipable items from inventory and allow swapping. Connect the button signals and add the selection logic:

```gdscript
func _ready() -> void:
    _weapon_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.WEAPON))
    _armor_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.ARMOR))
    _accessory_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.ACCESSORY))


func _on_slot_pressed(slot: ItemData.EquipSlot) -> void:
    # Get equipable items for this slot from inventory
    var equipable: Array = []
    for entry in InventoryManager.get_all_items():
        var item: ItemData = entry.item
        if item.item_type == ItemData.ItemType.EQUIPMENT and item.equip_slot == slot:
            equipable.append(item)

    if equipable.is_empty():
        print("No equipment for this slot in inventory.")
        return

    # Simple approach: equip the first matching item.
    # A full UI would show a selection list with stat comparisons.
    var item: ItemData = equipable[0]
    if not InventoryManager.remove_item(item):
        print("Could not equip " + item.display_name + ": item is no longer in inventory.")
        return

    var previous: ItemData = _character.equip(item)
    if previous:
        InventoryManager.add_item(previous)

    _refresh()
    equipment_changed.emit()
```

> **Exercise:** For a more polished experience, replace the "equip first item" logic with a popup list showing all matching items, their stats, and the stat difference compared to the current equipment. The inventory grid pattern from Module 12 works well for this.

We are not creating an accessory item in this module, so the new Accessory button will usually show `(none)` for now. That is expected. The point is to keep the teaching UI aligned with the `CharacterData` slot model you just added.

### Equipment Comparison: The PredictStats Pattern

Every JRPG shop and equipment screen answers the same question: "would this item make me stronger or weaker?" Showing red/green arrows next to stats is standard UX. The pattern for computing this is called **PredictStats**: calculate what the character's stats *would be* if they equipped a candidate item, without actually equipping it.

```gdscript
func predict_equip(candidate: ItemData) -> Dictionary:
    ## Returns a stat diff: positive values = improvement, negative = worse.
    ## Does NOT modify the character.
    var current_atk := get_effective_attack()
    var current_def := get_effective_defense()
    var current_spd := get_effective_speed()

    # Temporarily swap
    var slot := candidate.equip_slot
    var old_item: ItemData = null
    match slot:
        ItemData.EquipSlot.WEAPON:
            old_item = equipped_weapon
            equipped_weapon = candidate
        ItemData.EquipSlot.ARMOR:
            old_item = equipped_armor
            equipped_armor = candidate
        ItemData.EquipSlot.ACCESSORY:
            old_item = equipped_accessory
            equipped_accessory = candidate

    var diff := {
        attack = get_effective_attack() - current_atk,
        defense = get_effective_defense() - current_def,
        speed = get_effective_speed() - current_spd,
    }

    # Restore original equipment
    match slot:
        ItemData.EquipSlot.WEAPON:
            equipped_weapon = old_item
        ItemData.EquipSlot.ARMOR:
            equipped_armor = old_item
        ItemData.EquipSlot.ACCESSORY:
            equipped_accessory = old_item

    return diff
```

Usage in a shop or equipment UI:

```gdscript
var diff := character.predict_equip(iron_sword)
# diff = { attack = 5, defense = 0, speed = -1 }
# Display: ATK +5 (green arrow), DEF no change, SPD -1 (red arrow)
```

The key insight is the **temporarily swap, measure, restore** pattern. It reuses your existing `get_effective_*()` methods rather than duplicating the calculation logic. This means if you later add modifier stacking or set bonuses, the prediction stays accurate automatically.

## The Shop System

Secret of Mana's weapon shops in each town are progression gates disguised as stores. The player earns gold from battles and spends it on the next tier of weapons, creating a satisfying loop where exploration and combat feed back into power growth. Shops give the player agency over their build (do you buy a better sword for your fighter or a magic robe for your mage first?) and they anchor towns as meaningful destinations.

### ShopData Resource

Save as `res://resources/shop_data.gd`:

```gdscript
extends Resource
class_name ShopData
## Defines what a shop sells.

@export var shop_name: String = ""
@export var items_for_sale: Array[ItemData] = []
```

Create `res://data/shops/willowbrook_shop.tres`:
- Items: Potion, Ether, Iron Sword, Leather Armor

### Shop UI

Create `res://ui/shop/shop_ui.tscn`:

```
ShopUI (CanvasLayer, layer = 15)
└── Panel (PanelContainer, centered)
    └── Margin (MarginContainer)
        └── VBox (VBoxContainer)
            ├── ItemList (VBoxContainer)
            └── GoldLabel (Label: "Gold: 0")
```

Save the script as `res://ui/shop/shop_ui.gd`:

```gdscript
extends CanvasLayer
## Shop interface for buying items.

signal shop_closed

var _shop_data: ShopData

@onready var _item_list: VBoxContainer = $Panel/Margin/VBox/ItemList
@onready var _gold_label: Label = $Panel/Margin/VBox/GoldLabel


func _ready() -> void:
    # Must process while paused so the shop can receive input
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false


func _unhandled_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        close_shop()
        get_viewport().set_input_as_handled()


func open_shop(shop_data: ShopData) -> void:
    _shop_data = shop_data
    visible = true
    get_tree().paused = true
    _refresh()


func close_shop() -> void:
    visible = false
    get_tree().paused = false
    shop_closed.emit()


func _refresh() -> void:
    for child in _item_list.get_children():
        child.queue_free()

    await get_tree().process_frame

    _gold_label.text = "Gold: " + str(InventoryManager.gold)

    for item in _shop_data.items_for_sale:
        var button := Button.new()
        button.text = item.display_name + " - " + str(item.buy_price) + "g"
        if InventoryManager.gold < item.buy_price:
            button.disabled = true
        button.pressed.connect(_buy_item.bind(item))
        _item_list.add_child(button)

    if _item_list.get_child_count() > 0:
        await get_tree().process_frame
        _item_list.get_child(0).grab_focus()


func _buy_item(item: ItemData) -> void:
    if InventoryManager.spend_gold(item.buy_price):
        InventoryManager.add_item(item)
        print("Bought " + item.display_name + "!")
        _refresh()
```

### Connecting the Shopkeeper

When the player interacts with the shopkeeper NPC, open the shop instead of regular dialogue:

```gdscript
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    if npc.npc_data.id == "shopkeeper":
        var shop_data: ShopData = load("res://data/shops/willowbrook_shop.tres")
        if shop_data:
            _shop_ui.open_shop(shop_data)
            return
    # ... normal dialogue handling ...
```

### The Innkeeper

The innkeeper is simpler, just a dialogue choice that costs gold and heals the party:

```gdscript
func _handle_inn(npc: CharacterBody2D) -> void:
    var lines := _make_lines("Old Brennan", [
        "Rest for the night? That'll be 10 gold.",
    ])
    # Add a choice to the last line
    lines[0].choices = ["Yes (10g)", "No thanks"]
    _dialogue_box.start_dialogue(lines)
    var choice: int = await _dialogue_box.choice_made

    if choice == 0:  # Yes
        if InventoryManager.spend_gold(10):
            for member in PartyManager.get_members():
                member.current_hp = member.max_hp
                member.current_mp = member.max_mp
            _dialogue_box.start_dialogue(_make_lines("Old Brennan", ["Rest well, traveler."]))
        else:
            _dialogue_box.start_dialogue(_make_lines("Old Brennan", ["Seems you're a bit short."]))
```

> **See:** [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html). PartyManager is a new autoload. This guide covers the autoload pattern.

> **See:** [GUI containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html). VBoxContainer and PanelContainer are used for the equipment and shop UIs.

> **See:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). ShopData and CharacterData equipment slots both use the Resource pattern.

> **Note:** Selling items is left as an exercise. The pattern mirrors buying: show the player's inventory, select an item, add gold equal to half `buy_price`, remove the item from inventory.

## Autoload Reference Card (Updated)

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| GameManager | 20 | Game flags, world state tracking |
| QuestManager | 20 | Quest tracking, objective checking |
| **PartyManager** | **21** | **Party roster, recruitment, stats** |

## Engineering Contract

- **Global state:** PartyManager owns the runtime party roster.
- **Public surface:** `add_member()`, `remove_member()`, `get_members()`, `get_member_by_id()`, equipment APIs, shop open/buy flows.
- **Invariant:** Equipping consumes the new item before mutating the character, then returns the old item to inventory.
- **Failure behavior:** Failed inventory removal aborts equip instead of granting free gear.
- **Copy semantics:** `get_members()` returns a defensive array copy; CharacterData members inside it are live runtime objects.

## Engine Gotcha

Pausing with `get_tree().paused = true` pauses most nodes. Shop and equipment UI that must keep responding while paused need `process_mode = Node.PROCESS_MODE_ALWAYS`.

## What We've Learned

- **PartyManager** autoload tracks the roster of party members.
- **PartyManager.award_xp_to_party()** lets quest rewards reuse the same level-up path battles already use.
- **Recruitment** is triggered by dialogue + game flags, and the NPC becomes a party member.
- **Equipment** modifies effective stats. `get_effective_attack()` = base + weapon bonus.
- **PredictStats pattern:** temporarily swap equipment, measure the difference, restore the original. This lets shop and equipment UIs show green/red stat comparison arrows without committing the change.
- **The modifier pattern** (looking ahead): equipment bonuses, spell buffs, and status effects can all feed into stats through a unified `add`/`mult` modifier system. Not needed for Crystal Saga's scope, but essential for larger RPGs.
- **Equip/unequip** removes the new item from inventory first, then equips it, then returns the old item. If removal fails, equipment does not change.
- **Shops** use a ShopData resource listing items with prices.
- **The inn** is a dialogue choice that costs gold and restores HP/MP.
- All these systems build on previous modules: Resources (Module 9), dialogue (Module 11), inventory (Module 12), flags (Module 20).

## What You Should See

- Talking to Lira once introduces her, and the second conversation recruits her into the party
- The equipment panel shows the selected character's stats plus weapon, armor, and accessory slots. The accessory slot will stay `(none)` until you add an accessory item later
- Equipping a sword increases ATK in the stats display and in battle
- The shopkeeper opens a buy menu with prices
- The innkeeper offers rest for 10 gold and heals the party
- Lira appears in battle as a second party member once she joins

## Next Module

All game systems are in place. In **Module 22: Save and Load**, we'll persist everything (position, inventory, quests, party, equipment, flags) to JSON files, with save crystals in the world and multiple save slots.


---

<!-- Source: 22_save_and_load.md -->

# Module 22: Save and Load

## What We Have So Far

Every game system is functional: exploration, dialogue, combat, inventory, quests, party, equipment, shops. But if the player closes the game, everything is lost.

## What We're Building This Module

A save system that writes all game state to JSON files, with three save slots, save crystals in the world, and a load flow.

## What Needs Saving?

Every autoload holds state that must persist:

| Autoload | Data to Save |
|----------|-------------|
| GameManager | All flags (Dictionary) |
| InventoryManager | Items array, gold |
| QuestManager | Active, completed, turned-in quest IDs |
| PartyManager | Member IDs, levels, XP, stats, equipment |
| SceneManager | Current scene path, player position |

## Why JSON?

We use JSON for saves because:
- **Human-readable:** you can open a save file in a text editor and debug it
- **No class coupling:** JSON doesn't care about your Resource class definitions
- **Universally understood:** every language and tool can read JSON
- **Simple API:** Godot's `JSON.stringify()` and `JSON.parse()` handle everything

The alternative (Godot's `ResourceSaver` with `.tres` files) provides type safety but couples your saves to your class hierarchy. If you rename a Resource class, old saves break. JSON is more resilient for a tutorial scope.

> **See:** [Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html), the official guide covering multiple save approaches.

## The `to_save_data()` / `from_save_data()` Pattern

Early Pokemon games infamously had save corruption bugs because the save and load code paths were not symmetric: the game would save data in one order and try to read it back in a different order. The `to_save_data()` / `from_save_data()` pattern prevents this by making each system responsible for its own round-trip. If one method writes three fields, the other reads those same three fields. The symmetry makes it almost impossible to accidentally lose data.

Each autoload gets two methods: one to export its state as a Dictionary, one to restore it.

### GameManager

```gdscript
func to_save_data() -> Dictionary:
    return _flags.duplicate()

func from_save_data(data: Dictionary) -> void:
    _flags = data.duplicate()
```

### InventoryManager

```gdscript
func to_save_data() -> Dictionary:
    var items_data: Array[Dictionary] = []
    for entry in _items:
        items_data.append({
            item_id = entry.item.id,
            item_path = entry.item.resource_path,
            count = entry.count,
        })
    return {gold = gold, items = items_data}

func from_save_data(data: Dictionary) -> void:
    gold = data.get("gold", 0)
    _items.clear()
    for entry in data.get("items", []):
        var item: ItemData = load(entry.item_path) as ItemData
        if item:
            _items.append({item = item, count = entry.count})
    inventory_changed.emit()
    gold_changed.emit(gold)
```

### PartyManager

```gdscript
func to_save_data() -> Dictionary:
    var members_data: Array[Dictionary] = []
    for member in members:
        members_data.append({
            id = member.id,
            path = member.resource_path,
            level = member.level,
            current_xp = member.current_xp,
            max_hp = member.max_hp,
            max_mp = member.max_mp,
            attack = member.attack,
            defense = member.defense,
            speed = member.speed,
            current_hp = member.current_hp,
            current_mp = member.current_mp,
            weapon_path = member.equipped_weapon.resource_path if member.equipped_weapon else "",
            armor_path = member.equipped_armor.resource_path if member.equipped_armor else "",
            accessory_path = member.equipped_accessory.resource_path if member.equipped_accessory else "",
        })
    return {members = members_data}

func from_save_data(data: Dictionary) -> void:
    members.clear()
    for entry in data.get("members", []):
        var character := ResourceLoader.load(
            entry.path, "", ResourceLoader.CACHE_MODE_IGNORE,
        ) as CharacterData
        if character:
            character.level = entry.get("level", 1)
            character.current_xp = entry.get("current_xp", 0)
            character.max_hp = entry.get("max_hp", character.max_hp)
            character.max_mp = entry.get("max_mp", character.max_mp)
            character.attack = entry.get("attack", character.attack)
            character.defense = entry.get("defense", character.defense)
            character.speed = entry.get("speed", character.speed)
            character.current_hp = entry.get("current_hp", character.max_hp)
            character.current_mp = entry.get("current_mp", character.max_mp)
            var weapon_path: String = entry.get("weapon_path", "")
            if weapon_path:
                character.equipped_weapon = load(weapon_path) as ItemData
            var armor_path: String = entry.get("armor_path", "")
            if armor_path:
                character.equipped_armor = load(armor_path) as ItemData
            var accessory_path: String = entry.get("accessory_path", "")
            if accessory_path:
                character.equipped_accessory = load(accessory_path) as ItemData
            members.append(character)
```

This is our first use of `ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)`. The third argument tells Godot to bypass the usual cached copy and read a fresh `CharacterData` resource from disk. That matters because party members are mutable runtime objects now: they level up, change equipment, and lose HP. Loading a fresh base definition and then applying the saved state on top keeps the save/load boundary clean.

### QuestManager

```gdscript
func to_save_data() -> Dictionary:
    return {
        active = _active_quests.map(func(q: QuestData) -> String: return q.resource_path),
        completed = _completed_quests.map(func(q: QuestData) -> String: return q.resource_path),
        turned_in = _turned_in_quests.map(func(q: QuestData) -> String: return q.resource_path),
    }

func from_save_data(data: Dictionary) -> void:
    _active_quests.clear()
    _completed_quests.clear()
    _turned_in_quests.clear()
    for path in data.get("active", []):
        var q: QuestData = load(path) as QuestData
        if q: _active_quests.append(q)
    for path in data.get("completed", []):
        var q: QuestData = load(path) as QuestData
        if q: _completed_quests.append(q)
    for path in data.get("turned_in", []):
        var q: QuestData = load(path) as QuestData
        if q: _turned_in_quests.append(q)
```

### Persistent World Objects

Module 16 introduced `chest_id` on treasure chests. Now we make that ID meaningful. Small one-shot world state can live in `GameManager` flags because flags are already saved and loaded.

Use stable scene keys and object IDs:

```gdscript
const SCENE_KEY := "crystal_cavern"


func _world_flag(object_id: String, state: String) -> String:
    return GameManager.make_world_flag(SCENE_KEY, object_id, state)
```

For a chest:

```gdscript
@export var chest_id: String = ""
@export var item: ItemData
@export var amount: int = 1

var _opened: bool = false


func _ready() -> void:
    if chest_id.is_empty():
        push_warning("TreasureChest needs a stable chest_id for save/load.")
    _opened = GameManager.has_flag(_world_flag(chest_id, "opened"))
    _refresh_sprite()


func open() -> void:
    if _opened:
        return

    _opened = true
    InventoryManager.add_item(item, amount)
    GameManager.set_flag(_world_flag(chest_id, "opened"))
    _refresh_sprite()
```

Use the same pattern for other one-shot objects:

| Object | Suggested flag |
|--------|----------------|
| Opened chest | `world.crystal_cavern.<chest_id>.opened` |
| Defeated boss trigger | `world.crystal_cavern.crystal_guardian.defeated` |
| Unlocked boss door | `world.crystal_cavern.boss_door.unlocked` |
| Removed pickup | `world.whisperwood.pendant_chest.opened` |

> **Engine Gotcha:** String IDs are part of your save format. Renaming a scene key or `chest_id` after players have saves makes the old save look like the object was never opened. For a small tutorial game, stable IDs are enough. Larger games usually add migration code.

## The SaveManager

Create `res://autoloads/save_manager.gd` and register it as an autoload (**Project → Project Settings → Autoload** → add `save_manager.gd` as `SaveManager`). Unlike the other autoloads, SaveManager has no visible nodes; it's pure logic. We make it an autoload because save/load needs a stable runtime owner that survives scene changes, coordinates other autoloads, and can restore the scene after `change_scene_to_file()` completes:

> **Note:** `await` is a GDScript coroutine feature. The reason SaveManager is an autoload is architectural: it owns persistent save-slot behavior and orchestrates scene changes from a node that is not freed when gameplay scenes are replaced.

```gdscript
extends Node
## Handles saving and loading game state to JSON files.
## Registered as autoload, accessible as SaveManager.

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 3


func save_game(slot: int) -> bool:
    # Creates the save directory (and any parent directories) if it doesn't
    # exist yet. Safe to call even if the directory already exists.
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)

    var save_data: Dictionary = {
        version = 1,
        timestamp = Time.get_datetime_string_from_system(),
        scene_path = "",
        player_position = {x = 0.0, y = 0.0},
        game_flags = {},
        inventory = {},
        party = {},
        quests = {},
    }

    # Gather state from autoloads
    save_data.game_flags = GameManager.to_save_data()
    save_data.inventory = InventoryManager.to_save_data()
    save_data.party = PartyManager.to_save_data()
    save_data.quests = QuestManager.to_save_data()

    # Scene and player position
    var tree := Engine.get_main_loop() as SceneTree
    if tree and tree.current_scene:
        save_data.scene_path = tree.current_scene.scene_file_path
    var player := tree.get_first_node_in_group("player") if tree else null
    if player:
        save_data.player_position = {
            x = player.global_position.x,
            y = player.global_position.y,
        }

    # Write to file
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    var file := FileAccess.open(path, FileAccess.WRITE)
    if not file:
        push_error("SaveManager: failed to open " + path + " for writing")
        return false

    var json_string := JSON.stringify(save_data, "\t")
    file.store_string(json_string)
    file.close()
    print("Game saved to slot " + str(slot))
    return true


func load_game(slot: int) -> bool:
    var path := SAVE_DIR + "save_" + str(slot) + ".json"

    if not FileAccess.file_exists(path):
        push_error("SaveManager: save file not found: " + path)
        return false

    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        push_error("SaveManager: failed to open " + path)
        return false

    var json_string := file.get_as_text()
    file.close()

    # Godot's JSON class works in two steps: json.parse() attempts to parse
    # the string (returns OK on success), then json.data holds the result as
    # a Variant. A valid JSON root can be an array, number, string, bool, null,
    # or object, so check that it is a Dictionary before using it as save data.
    var json := JSON.new()
    var error := json.parse(json_string)
    if error != OK:
        push_error("SaveManager: JSON parse error: " + json.get_error_message())
        return false

    var parsed: Variant = json.data
    if not parsed is Dictionary:
        push_error("SaveManager: save root must be a Dictionary.")
        return false

    var save_data: Dictionary = parsed

    # Restore state to autoloads
    GameManager.from_save_data(save_data.get("game_flags", {}))
    InventoryManager.from_save_data(save_data.get("inventory", {}))
    PartyManager.from_save_data(save_data.get("party", {}))
    QuestManager.from_save_data(save_data.get("quests", {}))

    # Load the saved scene
    var scene_path: String = save_data.get("scene_path", "")
    if scene_path:
        var tree := Engine.get_main_loop() as SceneTree
        tree.change_scene_to_file(scene_path)
        # change_scene_to_file() is deferred. Wait for the tree to update.
        await tree.scene_changed

        # Restore player position
        var pos_data: Dictionary = save_data.get("player_position", {})
        var player := tree.get_first_node_in_group("player")
        if player:
            player.global_position = Vector2(
                pos_data.get("x", 0.0),
                pos_data.get("y", 0.0),
            )

    print("Game loaded from slot " + str(slot))
    return true


func get_slot_info(slot: int) -> Dictionary:
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    if not FileAccess.file_exists(path):
        return {}

    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return {}

    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK:
        return {}
    file.close()

    var parsed: Variant = json.data
    if not parsed is Dictionary:
        return {}

    var data: Dictionary = parsed
    return {
        timestamp = data.get("timestamp", ""),
        scene_path = data.get("scene_path", ""),
    }


func slot_exists(slot: int) -> bool:
    return FileAccess.file_exists(SAVE_DIR + "save_" + str(slot) + ".json")
```

> **See:** [FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html), for reading and writing files.

> **See:** [Data paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html). `user://` is the platform-specific writable directory for save data.

> **See:** [JSON](https://docs.godotengine.org/en/stable/classes/class_json.html), for parsing and generating JSON.

## Wiring the Save Crystal

Module 16's save crystal only printed a message. Once SaveManager exists, update that placeholder to open the slot dialog below. A direct `SaveManager.save_game(1)` call is fine as a temporary smoke test while wiring the autoload, but it should not be the final tutorial flow.

### Save Slot Selection UI

Final Fantasy games have used three save slots since the original NES cartridge, and the reason hasn't changed: players want to save before a risky boss fight without losing their earlier progress, and families sharing a console need separate saves. Multiple slots also let the player experiment: save before a branching choice, try one path, reload, try the other.

Rather than hardcoding slot 1, build a simple selection dialog. Create `res://ui/save_slot_dialog/save_slot_dialog.tscn`:

```
SaveSlotDialog (PanelContainer)
└── VBox (VBoxContainer)
    ├── TitleLabel (Label: "Choose a Slot")
    ├── Slot1Button (Button)
    ├── Slot2Button (Button)
    ├── Slot3Button (Button)
    └── CancelButton (Button: "Cancel")
```

```gdscript
extends PanelContainer
## A 3-slot save/load selection dialog.

signal slot_selected(slot: int)

@onready var _buttons: Array[Button] = [
    $VBox/Slot1Button,
    $VBox/Slot2Button,
    $VBox/Slot3Button,
]
@onready var _cancel_btn: Button = $VBox/CancelButton


func _ready() -> void:
    for i in range(_buttons.size()):
        _buttons[i].pressed.connect(_on_slot_pressed.bind(i + 1))
    _cancel_btn.pressed.connect(func() -> void: slot_selected.emit(0))
    refresh()
    _buttons[0].grab_focus()


func _on_slot_pressed(slot: int) -> void:
    slot_selected.emit(slot)


func refresh() -> void:
    for i in range(_buttons.size()):
        var slot_num: int = i + 1
        var info: Dictionary = SaveManager.get_slot_info(slot_num)
        if info.is_empty():
            _buttons[i].text = "Slot " + str(slot_num) + ": Empty"
        else:
            var scene_label: String = info.get("scene_path", "").get_file().get_basename().capitalize()
            _buttons[i].text = "Slot " + str(slot_num) + ": " + scene_label
```

Wire this into the save crystal:

```gdscript
func _activate() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    get_tree().current_scene.add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.save_game(slot)
    print("Saved to slot " + str(slot) + "!")
```

And the title screen's Continue button:

```gdscript
func _on_continue() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.load_game(slot)
```

## Error Handling

JSON files can be corrupted (incomplete write, manual editing). Always validate:

```gdscript
if json.parse(json_string) != OK:
    push_error("Corrupt save file: " + json.get_error_message())
    return false

var parsed: Variant = json.data
if not parsed is Dictionary:
    push_error("Save data is not a Dictionary")
    return false

var save_data: Dictionary = parsed
if not save_data.has("version"):
    push_error("Save data missing version field")
    return false
```

**Autoload reference card** (updated):

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| GameManager | 20 | Game flags, world state tracking |
| QuestManager | 20 | Quest tracking, objective checking |
| PartyManager | 21 | Party roster, recruitment, stats |
| **SaveManager** | **22** | **Save/load game state to JSON** |

> **Note:** `load_game()` uses `tree.change_scene_to_file()` directly instead of `SceneManager.change_scene()`. This is intentional. The save system needs to bypass SceneManager's spawn point logic and instead restore the exact player position from the save file. If you want the fade effect, you could call `SceneManager._anim_player.play("fade_out")` before loading and `fade_in` after.

### On Save Schema Design

As your game grows, you'll add new things that need saving (new autoloads, new systems, new character fields). Each addition means updating `to_save_data()` and `from_save_data()` for the affected objects. This works, but it's worth knowing the alternative.

Some RPG architectures use a **declarative save schema**, a single data structure that describes *what* to save, separate from *how* to save it. Instead of each autoload knowing how to serialize itself, a central schema says "from PartyManager, save these fields; from InventoryManager, save these fields." The save system walks the schema, extracts the data, and writes it. Loading walks the same schema in reverse.

The advantage: adding a new saveable field means adding one line to the schema, not editing the autoload. The disadvantage: more upfront complexity.

Our approach (`to_save_data()` per autoload) is the right call for Crystal Saga's scope. Each autoload owns its own serialization, which is easy to understand and debug. But if you build a larger RPG with 15+ autoloads and hundreds of saveable fields, consider consolidating into a schema.

Another thing to plan for: **save migration**. When you add a new field (say, a `reputation` system), old save files won't have it. Your `from_save_data()` methods should always use `.get("key", default_value)` rather than direct dictionary access. This way, loading an old save that lacks the `reputation` key gracefully falls back to the default instead of crashing.

## Engineering Contract

- **Global state:** SaveManager orchestrates serialization; each autoload owns its own save fragment.
- **Public surface:** `save_game(slot)`, `load_game(slot)`, `slot_exists(slot)`, `get_slot_info(slot)`, and SaveSlotDialog's `slot_selected`.
- **Invariant:** Save and load schemas are symmetric, versioned, and validated before restore.
- **Failure behavior:** Missing/corrupt files, non-Dictionary JSON roots, and slot cancel return cleanly.
- **Copy semantics:** Save data is plain Dictionaries/Arrays; mutable Resources are restored from paths, with cache bypass where fresh runtime copies matter.

## Engine Gotcha

JSON parsing returns a Variant root. Even valid JSON might be an array or string, so check `parsed is Dictionary` before treating it as a save file.

## What We've Learned

- **JSON** is the save format: human-readable, no class coupling, simple API.
- **`to_save_data()` / `from_save_data()`** on each autoload exports/imports state as Dictionaries.
- **`user://`** is the writable save directory; `FileAccess` handles file I/O.
- **Save crystals** trigger the save flow; `load_game()` is designed to be reused by UI flows like the title screen's Continue button in Module 25.
- **Save slot cancellation** returns slot `0`, so callers can `return` cleanly instead of waiting forever on a separate cancel signal.
- **World-object state** such as opened chests and one-shot bosses can live in saved `GameManager` flags when each object has a stable scene key and object ID.
- Resources are referenced by **path** in saves (`resource_path`), not by value. For mutable party members, `ResourceLoader.CACHE_MODE_IGNORE` rebuilds a fresh runtime copy from the `.tres` definition before saved state is applied.
- Always validate JSON before using it. Corrupt saves shouldn't crash the game.
- Use `.get("key", default)` for future-proof save loading; old saves missing new fields won't crash.

## What You Should See

- Interacting with the save crystal writes a JSON file to `user://saves/`
- Loading restores the player's position, inventory, quests, party, flags, and one-shot world-object state stored in `GameManager`
- The game continues exactly where you left off

## Next Module

The game is fully playable and saveable. In **Module 24: Audio**, we'll add background music, sound effects, and a volume settings system, bringing sound to Crystal Saga.


---

<!-- Source: 23_part_v_review.md -->

# Module 23: Part V Review and Cheat Sheet

This module is your reference for everything covered in Part V: Progression and Persistence (Modules 20-22). Use it to review what you built, look up syntax you have forgotten, or sanity-check your implementation before moving on.

## Part V in Review

Part V connected Crystal Saga's isolated systems into a game with actual progression. Before these three modules, the player could explore, fight, and collect items, but nothing tied those actions together into a story arc, and nothing survived closing the game.

Module 20 introduced two foundational concepts: game flags and quests. Game flags gave every system in the project a shared language for tracking what has happened in the world, while the quest system built on top of those flags to create structured objectives with rewards. The trick was a reactive signal (`flag_changed`) that lets quest completion happen automatically when the world state changes, rather than through manual checking. This also made NPCs responsive: Fynn remembers whether you have spoken to him, whether you found his pendant, and whether you already returned it.

Module 21 added the remaining progression systems. PartyManager gave us a roster (and Lira, the first companion), the equipment system made gear meaningful by modifying effective stats, and the shop system let the player spend their hard-earned gold. It also completed the quest XP loop by routing turn-in rewards through the same leveling helper battles already use. Finally, Module 22 closed the loop by persisting every piece of game state to JSON files. The `to_save_data()` / `from_save_data()` pattern gave each autoload a clean serialization boundary, and the save slot UI gave players the classic three-slot experience. With save and load in place, Crystal Saga became a game you can actually put down and come back to.

### Module 20: The Quest System and Game Flags
- Built the **GameManager** autoload: a dictionary of boolean flags (`flag_name -> true/false`) with a `flag_changed` signal that lets any system react when the world state changes.
- Created the **QuestData** Resource class with objectives defined as flag names, so a quest completes automatically when all its objective flags are set.
- Built the **QuestManager** autoload to track active, completed, and turned-in quests, grant gold/items on turn-in, and emit signals for quest state transitions.
- Implemented **reactive NPC dialogue** where characters like Fynn say different things depending on flags and quest progress, creating the illusion of a living world.
- Added a **quest log UI** that lists active quests and shows per-objective checkmarks based on current flag state.

### Module 21: Party Management, Equipment, and Shops
- Built the **PartyManager** autoload to manage the party roster, with signals for join/leave events and a lookup-by-ID method.
- Implemented **Lira's recruitment** as a flag-gated dialogue sequence: first meeting sets `lira_intro_seen`, second conversation sets `lira_ready_to_join`, and dialogue completion triggers `add_member()` exactly once.
- Added **party-wide quest XP routing** via `PartyManager.award_xp_to_party()`, so quest rewards and battle rewards both flow through `CharacterData.grant_xp()`.
- Extended **CharacterData** with equipment slots (weapon, armor, accessory) and `get_effective_*()` methods that add equipment bonuses to base stats, wired directly into battle through BattlerData.
- Created the **ShopData** Resource and **shop UI**: a CanvasLayer that pauses the game, lists items with prices, validates gold, and handles purchases through InventoryManager.
- Added the **innkeeper pattern**: a dialogue choice that costs gold and restores HP/MP for the entire party via PartyManager.

### Module 22: Save and Load
- Identified **what needs saving** by auditing every autoload for mutable state: flags, inventory, party members (including levels, stats, and equipment), quest arrays, scene path, and player position.
- Implemented the **`to_save_data()` / `from_save_data()` pattern** on each autoload: export state as a plain Dictionary, import it back from one. Resources are referenced by file path, not serialized by value.
- Built the **SaveManager** autoload with `save_game(slot)` and `load_game(slot)`: writes JSON to `user://saves/`, reads it back, restores all autoload state, and changes to the saved scene with the correct player position.
- Created a **save slot selection UI** with three slots that display the saved location and wire into both save crystals and the title screen's Continue button.
- Added **error handling guidance** for corrupt or missing save files: JSON parse validation in the main flow, plus recommended Dictionary type checks and version verification.

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|----------------|------------|
| Game flag | A boolean key-value pair in GameManager (`"pendant_found" = true`) | Universal state tracking that every system can read and react to | Module 20 |
| `flag_changed` signal | Emitted by GameManager when any flag value changes | Enables reactive systems: quests auto-complete, NPCs update dialogue, doors unlock, without polling | Module 20 |
| QuestData | A Resource class defining a quest's objectives, descriptions, and rewards | Data-driven quest definitions that live in `.tres` files and can be created in the editor | Module 20 |
| Quest state machine | Manager-inferred lifecycle: NOT_STARTED -> ACTIVE -> COMPLETE -> TURNED_IN | Prevents invalid transitions like turning in a quest that was never completed | Module 20 |
| Objective flags | An array of flag names on QuestData that map 1:1 to objectives | Quests complete automatically when all objective flags are set, no manual checking needed | Module 20 |
| Reactive dialogue | NPC dialogue functions that branch on flag/quest state | Makes the world feel responsive to the player's actions without complex scripting | Module 20 |
| PartyManager | An autoload holding the array of CharacterData for current party members | Centralized roster that battle, UI, save, and equipment systems all reference | Module 21 |
| Equipment slots | `equipped_weapon`, `equipped_armor`, `equipped_accessory` vars on CharacterData | Gear modifies effective stats, creating meaningful progression from shops and loot | Module 21 |
| Effective stats | `get_effective_attack()` = base stat + equipment bonus | Separates permanent character growth from temporary equipment bonuses | Module 21 |
| ShopData | A Resource class listing items available for purchase | Data-driven shops: change inventory by editing a `.tres` file, no code changes | Module 21 |
| `to_save_data()` | A method on each autoload that exports its state as a Dictionary | Clean serialization boundary: each system owns its own save format | Module 22 |
| `from_save_data()` | A method on each autoload that restores state from a Dictionary | Symmetric with `to_save_data()`, making save/load a simple round-trip | Module 22 |
| `user://` path | Godot's platform-specific writable directory for user data | Save files go here because `res://` is read-only in exported builds | Module 22 |
| Save slot | A numbered JSON file (`save_1.json`, `save_2.json`, `save_3.json`) | The classic JRPG pattern: players maintain multiple save states | Module 22 |
| Resource path referencing | Saving `resource_path` strings instead of serializing entire Resources | Keeps save files small and resilient; the `.tres` file is the source of truth | Module 22 |

## Cheat Sheet

### Game Flags System

The GameManager autoload stores boolean flags that any system can set and check. The `flag_changed` signal makes the system reactive rather than poll-based.

```gdscript
# Setting flags
GameManager.set_flag("talked_to_elder")          # Sets to true
GameManager.set_flag("door_locked", false)        # Explicitly set to false
GameManager.clear_flag("temporary_buff")          # Same as set_flag(..., false)

# Checking flags
if GameManager.has_flag("pendant_found"):
    # Player found the pendant
    pass

var is_unlocked: bool = GameManager.get_flag("crystal_cavern_unlocked")

# Reacting to flag changes from anywhere
GameManager.flag_changed.connect(_on_flag_changed)

func _on_flag_changed(flag_name: String, value: bool) -> void:
    if flag_name == "boss_defeated" and value:
        # The boss was just defeated, update the world
        pass

# Bulk operations (used by save/load)
var all_flags: Dictionary = GameManager.get_all_flags()
GameManager.load_flags(saved_flags_dictionary)        # direct reset/helper
GameManager.from_save_data(saved_flags_dictionary)    # Module 22 save/load path

# Stable world-object flags saved through GameManager
var chest_flag := GameManager.make_world_flag("crystal_cavern", "potion_chest", "opened")
GameManager.set_flag(chest_flag)
```

Register GameManager as an autoload at **Project -> Project Settings -> Autoload -> add `res://autoloads/game_manager.gd` as `GameManager`**.

### Quest Architecture

Quests are data-driven: a [QuestData](https://docs.godotengine.org/en/stable/classes/class_resource.html) Resource defines what a quest is, and QuestManager tracks its lifecycle.

```gdscript
# QuestData Resource (res://resources/quest_data.gd)
extends Resource
class_name QuestData

enum QuestState { NOT_STARTED, ACTIVE, COMPLETE, TURNED_IN }

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""

@export_group("Objectives")
@export var objectives: Array[String] = []         # Human-readable text
@export var objective_flags: Array[String] = []     # Flag names for completion

@export_group("Rewards")
@export var xp_reward: int = 0
@export var gold_reward: int = 0
@export var reward_items: Array[ItemData] = []   # Add the same item twice for two copies
@export var completion_flag: String = ""  # Flag set on turn-in
```

```gdscript
# Starting a quest
var quest: QuestData = load("res://data/quests/crystal_resonance.tres")
if quest:
    QuestManager.start_quest(quest)

# Checking quest state
if QuestManager.is_quest_active("lost_pendant"):
    pass
if QuestManager.is_quest_complete("lost_pendant"):
    pass
if QuestManager.get_quest_state("lost_pendant") == QuestData.QuestState.TURNED_IN:
    pass

# Turning in a quest (grants rewards automatically)
QuestManager.turn_in_quest_by_id("lost_pendant")

# Listing quests
var active: Array[QuestData] = QuestManager.get_active_quests()
var completed: Array[QuestData] = QuestManager.get_completed_quests()
var turned_in: Array[QuestData] = QuestManager.get_turned_in_quests()

# Quest signals
QuestManager.quest_started.connect(_on_quest_started)
QuestManager.quest_completed.connect(_on_quest_completed)
QuestManager.quest_turned_in.connect(_on_quest_turned_in)
```

Quest completion is automatic: QuestManager listens for `GameManager.flag_changed` and checks whether all `objective_flags` for each active quest are now set. When they are, it moves the quest to the completed list and emits `quest_completed`. Turn-in is a separate guarded transition: `turn_in_quest_by_id()` only grants rewards when the ID is currently in the completed list.

This first quest log stays focused on **active** quests. Completed and turned-in quests are still tracked separately in `QuestManager` for reward handling, save/load, and future UI expansion, but they are not shown in this starter journal.

### Quest Log UI

The quest log is a [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html) with a list of quest buttons and a detail label.

```
QuestLog (PanelContainer)
└── MarginContainer
    └── VBoxContainer
        ├── QuestList (VBoxContainer)       # Buttons, one per active quest
        └── DetailLabel (RichTextLabel)      # Quest description + objectives
```

```gdscript
func open_from_pause() -> void:
    _is_open = true
    visible = true
    get_tree().paused = true
    refresh()

# Refreshing the quest list
func refresh() -> void:
    for child in _quest_list.get_children():
        child.queue_free()
    await get_tree().process_frame

    for quest in QuestManager.get_active_quests():
        var button := Button.new()
        button.text = quest.title
        button.pressed.connect(_show_detail.bind(quest))
        _quest_list.add_child(button)

# Showing objectives with checkmarks
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

### Reactive NPC Dialogue

NPCs check flags and quest state to choose which dialogue lines to show. The pattern is a function that returns different `Array[DialogueLine]` based on the current world state, checking from most-progressed to least-progressed.

```gdscript
func _get_fynn_dialogue() -> Array[DialogueLine]:
    # Check most-progressed state first
    if GameManager.has_flag("pendant_returned"):
        return _make_lines("Fynn", ["Thank you again for finding my pendant!"])
    elif GameManager.has_flag("pendant_found"):
        var lines := _make_lines("Fynn", [
            "You found it! My pendant! Thank you so much!",
            "Please, take this as a reward.",
        ])
        if QuestManager.turn_in_quest_by_id("lost_pendant"):
            var pendant := load("res://data/items/pendant.tres") as ItemData
            if pendant:
                InventoryManager.remove_item(pendant)
        return lines
    elif GameManager.has_flag("talked_to_fynn"):
        return _make_lines("Fynn", ["Any luck finding my pendant in the Whisperwood?"])
    else:
        # First meeting: set the flag and start the quest
        GameManager.set_flag("talked_to_fynn")
        var quest: QuestData = load("res://data/quests/lost_pendant.tres")
        if quest:
            QuestManager.start_quest(quest)
        return _make_lines("Fynn", [
            "I lost something precious in the Whisperwood...",
            "A pendant, silver with a blue stone.",
            "If you find it, I'd be forever grateful.",
        ])

# Helper to create dialogue line arrays
func _make_lines(speaker: String, texts: Array[String]) -> Array[DialogueLine]:
    var lines: Array[DialogueLine] = []
    for text in texts:
        var line := DialogueLine.new()
        line.speaker_name = speaker
        line.text = text
        lines.append(line)
    return lines
```

The key pattern: check flags from **most progressed to least progressed** (post-quest, mid-quest, pre-quest, first meeting). The first branch that matches wins.

### PartyManager

The [PartyManager](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) autoload manages who is in the party. It starts with the hero and grows through recruitment events.

```gdscript
# Core API
PartyManager.add_member(character)          # CharacterData
PartyManager.remove_member(character)
var members: Array[CharacterData] = PartyManager.get_members()
var lira: CharacterData = PartyManager.get_member_by_id("lira")

# Signals
PartyManager.party_member_joined.connect(_on_member_joined)
PartyManager.party_member_removed.connect(_on_member_removed)
```

Recruitment is triggered by dialogue and gated by flags:

```gdscript
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    # ... dialogue logic ...
    # After Lira's second conversation:
    if npc.npc_data.id == "lira" and GameManager.has_flag("lira_ready_to_join") \
            and not GameManager.has_flag("lira_joined"):
        _dialogue_box.dialogue_finished.connect(_recruit_lira, CONNECT_ONE_SHOT)

func _recruit_lira() -> void:
    GameManager.set_flag("lira_joined")
    var lira: CharacterData = load("res://data/characters/lira.tres")
    if lira:
        PartyManager.add_member(lira)
```

Building party battler data for combat:

```gdscript
var party_battlers: Array[BattlerData] = []
for char_data in PartyManager.get_members():
    var battler := BattlerData.new()
    battler.character_data = char_data
    battler.is_player_controlled = true
    party_battlers.append(battler)
SceneManager.start_battle({party = party_battlers, enemies = enemy_battlers})
```

### Equipment System

Equipment is stored directly on [CharacterData](https://docs.godotengine.org/en/stable/classes/class_resource.html) and modifies effective stats.

```gdscript
# Equipment slots on CharacterData
var equipped_weapon: ItemData = null
var equipped_armor: ItemData = null
var equipped_accessory: ItemData = null

# Effective stat calculation
func get_effective_attack() -> int:
    var bonus: int = equipped_weapon.attack_bonus if equipped_weapon else 0
    return attack + bonus

func get_effective_defense() -> int:
    var bonus: int = equipped_armor.defense_bonus if equipped_armor else 0
    bonus += equipped_accessory.defense_bonus if equipped_accessory else 0
    return defense + bonus

func get_effective_speed() -> int:
    var bonus: int = 0
    if equipped_accessory:
        bonus += equipped_accessory.speed_bonus
    return speed + bonus
```

The equip/unequip flow always returns the previous item so you can put it back in inventory:

```gdscript
# Equip returns the item that was in that slot (or null)
func equip(item: ItemData) -> ItemData:
    var previous: ItemData = null
    match item.equip_slot:
        ItemData.EquipSlot.WEAPON:
            previous = equipped_weapon
            equipped_weapon = item
        ItemData.EquipSlot.ARMOR:
            previous = equipped_armor
            equipped_armor = item
        ItemData.EquipSlot.ACCESSORY:
            previous = equipped_accessory
            equipped_accessory = item
    return previous

# Full equip flow: remove new item first, equip, then return old item to inventory
func _equip_item_on_character(character: CharacterData, item: ItemData) -> void:
    if not InventoryManager.remove_item(item):
        return
    var previous: ItemData = character.equip(item)
    if previous:
        InventoryManager.add_item(previous)
```

Battle integration uses effective stats:

```gdscript
func initialize_from_character() -> void:
    if not character_data:
        return
    current_hp = character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp
    current_mp = character_data.current_mp if character_data.current_mp > 0 else character_data.max_mp
    current_attack = character_data.get_effective_attack()
    current_defense = character_data.get_effective_defense()
    current_speed = character_data.get_effective_speed()
```

### Shop System

Shops use a [ShopData](https://docs.godotengine.org/en/stable/classes/class_resource.html) Resource and a [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html)-based UI.

```gdscript
# ShopData Resource (res://resources/shop_data.gd)
extends Resource
class_name ShopData

@export var shop_name: String = ""
@export var items_for_sale: Array[ItemData] = []
```

Create `.tres` files in `res://data/shops/` via the editor: right-click, New Resource, select ShopData, and drag item resources into the `items_for_sale` array.

```gdscript
# Opening the shop from an NPC interaction
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    if npc.npc_data.id == "shopkeeper":
        var shop_data: ShopData = load("res://data/shops/willowbrook_shop.tres")
        if shop_data:
            _shop_ui.open_shop(shop_data)
            return
    # ... normal dialogue ...
```

```gdscript
# Shop UI core logic
func open_shop(shop_data: ShopData) -> void:
    _shop_data = shop_data
    visible = true
    get_tree().paused = true       # Pause the game behind the shop
    _refresh()

func close_shop() -> void:
    visible = false
    get_tree().paused = false
    shop_closed.emit()

func _buy_item(item: ItemData) -> void:
    if InventoryManager.spend_gold(item.buy_price):
        InventoryManager.add_item(item)
        _refresh()                  # Update gold display and button states
```

The shop UI sets `process_mode = Node.PROCESS_MODE_ALWAYS` so it can receive input while the game is paused. Buttons are disabled when the player cannot afford an item.

The innkeeper is a simpler variant that uses dialogue choices instead of a full shop UI:

```gdscript
func _handle_inn(npc: CharacterBody2D) -> void:
    var lines := _make_lines("Old Brennan", ["Rest for the night? That'll be 10 gold."])
    lines[0].choices = ["Yes (10g)", "No thanks"]
    _dialogue_box.start_dialogue(lines)
    var choice: int = await _dialogue_box.choice_made

    if choice == 0 and InventoryManager.spend_gold(10):
        for member in PartyManager.get_members():
            member.current_hp = member.max_hp
            member.current_mp = member.max_mp
```

### Save System Architecture

SaveManager gathers state from every autoload, serializes it as JSON, and writes it to disk. Loading reverses the process.

**What gets saved:**

| Autoload | Saved Data |
|----------|-----------|
| GameManager | All flags (Dictionary of String -> bool), including world-object flags such as opened chests and defeated one-shot bosses |
| InventoryManager | Items array (id, resource path, count) + gold |
| QuestManager | Active/completed/turned-in quest resource paths |
| PartyManager | Member paths, levels, XP, all stats, equipment paths |
| SceneManager | Current scene file path |
| (Player node) | Global position (x, y) |

**Save file structure (`user://saves/save_1.json`):**

```gdscript
{
    "version": 1,
    "timestamp": "2025-03-15T14:30:00",
    "scene_path": "res://scenes/willowbrook/willowbrook.tscn",
    "player_position": {"x": 128.0, "y": 256.0},
    "game_flags": {
        "talked_to_elder": true,
        "pendant_found": true,
        "world.crystal_cavern.potion_chest.opened": true
    },
    "inventory": {"gold": 150, "items": [{"item_id": "potion", "item_path": "res://data/items/potion.tres", "count": 3}]},
    "party": {"members": [{"id": "aiden", "path": "res://data/characters/aiden.tres", "level": 5, ...}]},
    "quests": {"active": ["res://data/quests/crystal_resonance.tres"], "completed": [], "turned_in": []}
}
```

**The save flow:**

```gdscript
# SaveManager.save_game(slot)
func save_game(slot: int) -> bool:
    DirAccess.make_dir_recursive_absolute(SAVE_DIR)

    var save_data: Dictionary = {
        version = 1,
        timestamp = Time.get_datetime_string_from_system(),
        scene_path = "",
        player_position = {x = 0.0, y = 0.0},
        game_flags = {},
        inventory = {},
        party = {},
        quests = {},
    }

    # Gather state from each autoload
    save_data.game_flags = GameManager.to_save_data()
    save_data.inventory = InventoryManager.to_save_data()
    save_data.party = PartyManager.to_save_data()
    save_data.quests = QuestManager.to_save_data()

    # Scene and player position
    var tree := Engine.get_main_loop() as SceneTree
    if tree and tree.current_scene:
        save_data.scene_path = tree.current_scene.scene_file_path
    var player := tree.get_first_node_in_group("player") if tree else null
    if player:
        save_data.player_position = {
            x = player.global_position.x,
            y = player.global_position.y,
        }

    # Write JSON to file
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    var file := FileAccess.open(path, FileAccess.WRITE)
    if not file:
        push_error("SaveManager: failed to open " + path + " for writing")
        return false
    file.store_string(JSON.stringify(save_data, "\t"))
    file.close()
    return true
```

**The load flow:**

```gdscript
# SaveManager.load_game(slot)
func load_game(slot: int) -> bool:
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    if not FileAccess.file_exists(path):
        return false

    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return false

    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK:
        push_error("Corrupt save: " + json.get_error_message())
        return false
    file.close()

    var parsed: Variant = json.data
    if not parsed is Dictionary:
        return false

    var save_data: Dictionary = parsed

    # Restore each autoload's state
    GameManager.from_save_data(save_data.get("game_flags", {}))
    InventoryManager.from_save_data(save_data.get("inventory", {}))
    PartyManager.from_save_data(save_data.get("party", {}))
    QuestManager.from_save_data(save_data.get("quests", {}))

    # Change to the saved scene and restore player position
    var scene_path: String = save_data.get("scene_path", "")
    if scene_path:
        var tree := Engine.get_main_loop() as SceneTree
        tree.change_scene_to_file(scene_path)
        await tree.scene_changed
        var pos_data: Dictionary = save_data.get("player_position", {})
        var player := tree.get_first_node_in_group("player")
        if player:
            player.global_position = Vector2(pos_data.get("x", 0.0), pos_data.get("y", 0.0))
    return true
```

### The Saveable Pattern

Each autoload implements a symmetric pair of methods: `to_save_data()` exports state as a plain Dictionary, and `from_save_data()` restores it.

```gdscript
# GameManager: simplest case, flags are already a Dictionary
func to_save_data() -> Dictionary:
    return _flags.duplicate()

func from_save_data(data: Dictionary) -> void:
    _flags = data.duplicate()
```

```gdscript
# InventoryManager: items are serialized by resource path + count
func to_save_data() -> Dictionary:
    var items_data: Array[Dictionary] = []
    for entry in _items:
        items_data.append({
            item_id = entry.item.id,
            item_path = entry.item.resource_path,
            count = entry.count,
        })
    return {gold = gold, items = items_data}

func from_save_data(data: Dictionary) -> void:
    gold = data.get("gold", 0)
    _items.clear()
    for entry in data.get("items", []):
        var item: ItemData = load(entry.item_path) as ItemData
        if item:
            _items.append({item = item, count = entry.count})
    inventory_changed.emit()
    gold_changed.emit(gold)
```

```gdscript
# QuestManager: quests are serialized as resource path arrays
func to_save_data() -> Dictionary:
    return {
        active = _active_quests.map(func(q: QuestData) -> String: return q.resource_path),
        completed = _completed_quests.map(func(q: QuestData) -> String: return q.resource_path),
        turned_in = _turned_in_quests.map(func(q: QuestData) -> String: return q.resource_path),
    }

func from_save_data(data: Dictionary) -> void:
    _active_quests.clear()
    _completed_quests.clear()
    _turned_in_quests.clear()
    for path in data.get("active", []):
        var q: QuestData = load(path) as QuestData
        if q: _active_quests.append(q)
    # ... same for completed and turned_in
```

```gdscript
# PartyManager: members are serialized with all mutable stats + equipment paths
func to_save_data() -> Dictionary:
    var members_data: Array[Dictionary] = []
    for member in members:
        members_data.append({
            id = member.id,
            path = member.resource_path,
            level = member.level,
            current_xp = member.current_xp,
            max_hp = member.max_hp,
            max_mp = member.max_mp,
            attack = member.attack,
            defense = member.defense,
            speed = member.speed,
            current_hp = member.current_hp,
            current_mp = member.current_mp,
            weapon_path = member.equipped_weapon.resource_path if member.equipped_weapon else "",
            armor_path = member.equipped_armor.resource_path if member.equipped_armor else "",
            accessory_path = member.equipped_accessory.resource_path if member.equipped_accessory else "",
        })
    return {members = members_data}
```

The pattern principle: Resources are referenced by path, not serialized by value. `ResourceLoader.load(entry.path, "", ResourceLoader.CACHE_MODE_IGNORE) as CharacterData` reloads a fresh `.tres` base definition, then saved values (level, stats, equipment) are applied on top. This keeps save files small, preserves pristine New Game data, and means editing a `.tres` file updates the base values for all future loads.

### Save Slots

Three save slots stored at `user://saves/save_1.json` through `save_3.json`.

```gdscript
# Constants in SaveManager
const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 3

# Check if a slot has a save
func slot_exists(slot: int) -> bool:
    return FileAccess.file_exists(SAVE_DIR + "save_" + str(slot) + ".json")

# Get metadata for display
func get_slot_info(slot: int) -> Dictionary:
    var path := SAVE_DIR + "save_" + str(slot) + ".json"
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if not file:
        return {}
    var json := JSON.new()
    if json.parse(file.get_as_text()) != OK:
        return {}
    file.close()
    var parsed: Variant = json.data
    if not parsed is Dictionary:
        return {}
    var data: Dictionary = parsed
    return {
        timestamp = data.get("timestamp", ""),
        scene_path = data.get("scene_path", ""),
    }
```

The save slot dialog uses `await` to pause execution until the player picks a slot:

```gdscript
# In the save crystal
func _activate() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    get_tree().current_scene.add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.save_game(slot)

# On the title screen
func _on_continue() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
    if slot == 0:
        return
    SaveManager.load_game(slot)
```

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Forgetting to register an autoload in Project Settings | `Identifier "GameManager" not declared in the current scope` error | Open **Project -> Project Settings -> Autoload** and add the script path with the correct name |
| Checking flags in the wrong order in reactive dialogue | NPC always says the first-meeting line, or skips to the end | Check from most-progressed state to least-progressed: `pendant_returned` before `pendant_found` before `talked_to_fynn` before the `else` |
| Not setting `process_mode = PROCESS_MODE_ALWAYS` on shop UI | Shop opens but buttons do not respond to input | The shop pauses the game with `get_tree().paused = true`, so the shop node itself must set `process_mode = Node.PROCESS_MODE_ALWAYS` in `_ready()` |
| Equipping an item without removing it from inventory first | Item duplicated: it appears both equipped and in the inventory | First require `InventoryManager.remove_item(item)` to return true, then equip, then return the previous item to inventory |
| Saving Resource objects directly to JSON instead of their paths | JSON contains nested object data that cannot be parsed back into typed Resources | Save `resource_path` strings. On load, call `load(path) as ResourceType` to get the actual Resource |
| Modifying `_active_quests` array while iterating over it | Quest completion skips entries or throws errors | Collect newly completed quests into a separate array first, then process them after the iteration (as QuestManager does with `newly_completed`) |
| Missing `await tree.scene_changed` after `change_scene_to_file()` | Player position restoration fails because the new scene has not loaded yet | `change_scene_to_file()` is deferred. `await tree.scene_changed` waits for the new scene to be fully loaded before restoring position |
| Not emitting signals after `from_save_data()` in InventoryManager | UI displays stale data after loading a save | Call `inventory_changed.emit()` and `gold_changed.emit(gold)` at the end of `from_save_data()` so listeners update |

## Official Godot Documentation

### Core Classes

- [Node](https://docs.godotengine.org/en/stable/classes/class_node.html): base class for all autoloads (GameManager, QuestManager, PartyManager, SaveManager)
- [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html): base class for QuestData, ShopData, CharacterData, ItemData
- [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html): `change_scene_to_file()`, `paused`, `get_first_node_in_group()`, `scene_changed` signal
- [Engine](https://docs.godotengine.org/en/stable/classes/class_engine.html): `get_main_loop()` used in SaveManager to access the SceneTree

### File I/O and Serialization

- [FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html): `open()`, `store_string()`, `get_as_text()`, `file_exists()`, `close()`
- [DirAccess](https://docs.godotengine.org/en/stable/classes/class_diraccess.html): `make_dir_recursive_absolute()` for creating save directories
- [JSON](https://docs.godotengine.org/en/stable/classes/class_json.html): `stringify()`, `parse()`, `get_error_message()`
- [Time](https://docs.godotengine.org/en/stable/classes/class_time.html): `get_datetime_string_from_system()` for save timestamps

### UI Classes

- [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html): used for quest log, equipment panel, save slot dialog
- [VBoxContainer](https://docs.godotengine.org/en/stable/classes/class_vboxcontainer.html): vertical layout for item lists, quest lists, slot buttons
- [MarginContainer](https://docs.godotengine.org/en/stable/classes/class_margincontainer.html): interior padding for panels
- [Button](https://docs.godotengine.org/en/stable/classes/class_button.html): quest selection, shop items, equipment slots, save slots
- [Label](https://docs.godotengine.org/en/stable/classes/class_label.html): gold display, character names, slot labels
- [RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html): quest detail view with BBCode formatting (`[b]`, `[/b]`)
- [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html): shop UI rendered above the game world
- [Control](https://docs.godotengine.org/en/stable/classes/class_control.html): base class for all UI nodes, `grab_focus()`, `visible`

### Signals and Input

- [Signal](https://docs.godotengine.org/en/stable/classes/class_signal.html): `connect()`, `emit()`, `CONNECT_ONE_SHOT`
- [InputEvent](https://docs.godotengine.org/en/stable/classes/class_inputevent.html): `is_action_pressed()` for shop cancel input handling

### Key Tutorials

- [Saving Games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html): the official guide to save system approaches
- [Data Paths](https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html): explains `user://` and `res://` paths
- [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html): the autoload pattern used by all managers
- [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html): custom Resource classes, `@export`, `.tres` files
- [GUI Containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html): layout for shop, equipment, and quest UIs

### GDScript

- [GDScript Basics](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html): `match`, `Dictionary`, `Array`, typed arrays, lambdas
- [GDScript Exports](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html): `@export`, `@export_group`, `@export_multiline`
- [Awaiting Signals](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-for-signals-or-coroutines): `await` used in shop cancel, slot selection, scene loading

## What's Next

All the core systems are built and game state persists across sessions. In **Part VI: Polish and Integration**, we add music and sound effects, build the title screen with new game and continue flows, and tie everything together into a playable demo.

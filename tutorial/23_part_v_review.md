# Module 23: Part V Review and Cheat Sheet

This module is your reference for everything covered in Part V: Progression and Persistence (Modules 20-22). Use it to review what you built, look up syntax you have forgotten, or sanity-check your implementation before moving on.

## Part V in Review

Part V connected Crystal Saga's isolated systems into a game with actual progression. Before these three modules, the player could explore, fight, and collect items, but nothing tied those actions together into a story arc, and nothing survived closing the game.

Module 20 introduced two foundational concepts: game flags and quests. Game flags gave every system in the project a shared language for tracking what has happened in the world, while the quest system built on top of those flags to create structured objectives with rewards. The trick was a reactive signal (`flag_changed`) that lets quest completion happen automatically when the world state changes, rather than through manual checking. This also made NPCs responsive: Fynn remembers whether you have spoken to him, whether you found his pendant, and whether you already returned it.

Module 21 added the remaining progression systems. PartyManager gave us a roster (and Lira, the first companion), the equipment system made gear meaningful by modifying effective stats, and the shop system let the player buy upgrades or sell extras. It also completed the quest XP loop by routing turn-in rewards through the same leveling helper battles already use. Finally, Module 22 closed the loop by persisting every piece of game state to JSON files. The `to_save_data()` / `from_save_data()` pattern gave each autoload a clean serialization boundary, and the save slot UI gave players the classic three-slot experience. With save and load in place, Crystal Saga became a game you can actually put down and come back to.

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
- Created the **ShopData** Resource and **shop UI**: a CanvasLayer that pauses the game, lists buy/sell entries with prices, validates gold, and routes transactions through InventoryManager.
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
        return _make_lines("Fynn", [
            "You found it! My pendant! Thank you so much!",
            "Please, take this as a reward.",
        ])
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


func _on_fynn_turn_in_dialogue_finished() -> void:
    if QuestManager.turn_in_quest_by_id("lost_pendant"):
        var pendant := load("res://data/items/pendant.tres") as ItemData
        if pendant:
            InventoryManager.remove_item(pendant)

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

The EquipmentPanel is scene-local UI, but it is opened through the global PauseMenu in Module 25. Each gameplay scene adds its EquipmentPanel instance to the `equipment_panels` group, and the panel exposes `open_from_pause()` so PauseMenu can call the public API instead of toggling visibility directly.

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
            _open_shop(shop_data)
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

func _sell_item(item: ItemData) -> void:
    if InventoryManager.remove_item(item):
        InventoryManager.add_gold(item.sell_price)
        _refresh()
```

The shop UI sets `process_mode = Node.PROCESS_MODE_ALWAYS` so it can receive input while the game is paused. Buttons are disabled when the player cannot afford an item. Selling uses the same transaction shape in reverse: remove one inventory item, then add `sell_price` gold.

```gdscript
func _open_shop(shop_data: ShopData) -> void:
    _shop_ui.open_shop(shop_data)
    if not _shop_ui.shop_closed.is_connected(_on_shop_closed):
        _shop_ui.shop_closed.connect(_on_shop_closed, CONNECT_ONE_SHOT)


func _on_shop_closed() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("end_interaction"):
        player.end_interaction()
```

Closing a shop is the end of the NPC interaction. Without this signal cleanup, the player can remain stuck in the interaction state after the modal closes.

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

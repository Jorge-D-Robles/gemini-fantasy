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
- **Simple API:** Godot's `JSON.stringify()` and `JSON.parse_string()` handle everything

The alternative (Godot's `ResourceSaver` with `.tres` files) provides type safety but couples your saves to your class hierarchy. If you rename a Resource class, old saves break. JSON is more resilient for a tutorial scope.

> **See:** [Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html), the official guide covering multiple save approaches.

## The `to_save_data()` / `from_save_data()` Pattern

Early Pokemon games infamously had save corruption bugs because the save and load code paths were not symmetric -- the game would save data in one order and try to read it back in a different order. The `to_save_data()` / `from_save_data()` pattern prevents this by making each system responsible for its own round-trip. If one method writes three fields, the other reads those same three fields. The symmetry makes it almost impossible to accidentally lose data.

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
        var character: CharacterData = load(entry.path) as CharacterData
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

## The SaveManager

Create `res://autoloads/save_manager.gd` and register it as an autoload (**Project → Project Settings → Autoload** → add `save_manager.gd` as `SaveManager`). Unlike the other autoloads, SaveManager has no visible nodes; it's pure logic. We make it an autoload so it can use `await` for scene loading:

> **Note:** Static functions in GDScript cannot use `await` (they have no node context). Since `load_game()` needs to await a scene change, SaveManager must be an autoload instance, not a static utility.

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
    # the string (returns OK on success), then json.data holds the result
    # as a Dictionary. Always check the error before using .data.
    var json := JSON.new()
    var error := json.parse(json_string)
    if error != OK:
        push_error("SaveManager: JSON parse error: " + json.get_error_message())
        return false

    var save_data: Dictionary = json.data

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
        await tree.tree_changed

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

    var data: Dictionary = json.data
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

Update the save crystal from Module 16:

```gdscript
func _activate() -> void:
    # Show save slot selection
    # For simplicity, save to slot 1 directly
    SaveManager.save_game(1)
    print("Your progress has been saved!")
```

### Save Slot Selection UI

Final Fantasy games have used three save slots since the original NES cartridge, and the reason hasn't changed: players want to save before a risky boss fight without losing their earlier progress, and families sharing a console need separate saves. Multiple slots also let the player experiment -- save before a branching choice, try one path, reload, try the other.

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
signal cancelled

@onready var _buttons: Array[Button] = [
    $VBox/Slot1Button,
    $VBox/Slot2Button,
    $VBox/Slot3Button,
]
@onready var _cancel_btn: Button = $VBox/CancelButton


func _ready() -> void:
    for i in range(_buttons.size()):
        var slot_num: int = i + 1
        _buttons[i].pressed.connect(func() -> void: slot_selected.emit(slot_num))
    _cancel_btn.pressed.connect(func() -> void: cancelled.emit())
    refresh()
    _buttons[0].grab_focus()


func refresh() -> void:
    for i in range(_buttons.size()):
        var slot_num: int = i + 1
        var info: Dictionary = SaveManager.get_slot_info(slot_num)
        if info.is_empty():
            _buttons[i].text = "Slot " + str(slot_num) + ": Empty"
        else:
            _buttons[i].text = "Slot " + str(slot_num) + ": " + info.get("scene_name", "Unknown")
```

Wire this into the save crystal:

```gdscript
func _activate() -> void:
    var dialog: PanelContainer = preload("res://ui/save_slot_dialog/save_slot_dialog.tscn").instantiate()
    get_tree().current_scene.add_child(dialog)
    var slot: int = await dialog.slot_selected
    dialog.queue_free()
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
    SaveManager.load_game(slot)
```

## Error Handling

JSON files can be corrupted (incomplete write, manual editing). Always validate:

```gdscript
if json.parse(json_string) != OK:
    push_error("Corrupt save file: " + json.get_error_message())
    return false

if not save_data is Dictionary:
    push_error("Save data is not a Dictionary")
    return false

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

Some RPG architectures use a **declarative save schema** -- a single data structure that describes *what* to save, separate from *how* to save it. Instead of each autoload knowing how to serialize itself, a central schema says "from PartyManager, save these fields; from InventoryManager, save these fields." The save system walks the schema, extracts the data, and writes it. Loading walks the same schema in reverse.

The advantage: adding a new saveable field means adding one line to the schema, not editing the autoload. The disadvantage: more upfront complexity.

Our approach (`to_save_data()` per autoload) is the right call for Crystal Saga's scope. Each autoload owns its own serialization, which is easy to understand and debug. But if you build a larger RPG with 15+ autoloads and hundreds of saveable fields, consider consolidating into a schema.

Another thing to plan for: **save migration**. When you add a new field (say, a `reputation` system), old save files won't have it. Your `from_save_data()` methods should always use `.get("key", default_value)` rather than direct dictionary access. This way, loading an old save that lacks the `reputation` key gracefully falls back to the default instead of crashing.

## What We've Learned

- **JSON** is the save format: human-readable, no class coupling, simple API.
- **`to_save_data()` / `from_save_data()`** on each autoload exports/imports state as Dictionaries.
- **`user://`** is the writable save directory; `FileAccess` handles file I/O.
- **Save crystals** trigger the save flow; **load** happens from the title screen or pause menu.
- Resources are referenced by **path** in saves (`resource_path`), not by value. The `.tres` file is the source of truth; the save just points to it.
- Always validate JSON before using it. Corrupt saves shouldn't crash the game.
- Use `.get("key", default)` for future-proof save loading -- old saves missing new fields won't crash.

## What You Should See

- Interacting with the save crystal writes a JSON file to `user://saves/`
- Loading restores the player's position, inventory, quests, party, and flags
- The game continues exactly where you left off

## Next Module

The game is fully playable and saveable. In **Module 24: Audio**, we'll add background music, sound effects, and a volume settings system, bringing sound to Crystal Saga.

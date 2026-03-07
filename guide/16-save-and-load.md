# Chapter 16 — Save and Load

If you have built a web application with client-side state, you have solved this problem before. Redux Persist captures `store.getState()` to localStorage and rehydrates it with `store.dispatch(RESTORE_STATE)`. The save/load system in a JRPG is the same pattern with higher stakes — the player's 40-hour playthrough depends on it working correctly.

This chapter builds the `SaveManager` autoload, which gathers state from every game system into a single Dictionary, serializes it to JSON, writes it to disk, and reverses the process on load.

## What We Are Building

- **Save file format** — a JSON structure capturing all game state
- **SaveManager** — an autoload with `save_game()` and `load_save_data()` / `apply_save_data()`
- **The serialize/deserialize protocol** — how each manager contributes its state
- **Save slots** — slot 0 for autosave, slots 1–3 for manual saves
- **Position restoration** — loading a save returns the player to the right spot
- **Slot metadata** — location name, playtime, and timestamp for the save slot UI

## Step 1: The Save File Format

Every save file is a JSON object with a fixed top-level schema. Here is what a typical save looks like on disk:

```json
{
	"version": 1,
	"timestamp": 1709740800,
	"playtime_seconds": 3847.5,
	"scene_path": "res://scenes/roothollow/roothollow.tscn",
	"player_position": {
		"x": 256.0,
		"y": 192.0
	},
	"party": {
		"active": ["kael", "lyra", "garrick"],
		"reserve": ["iris"]
	},
	"character_state": {
		"kael": {
			"current_hp": 145,
			"current_ee": 30,
			"level": 8,
			"current_xp": 2340
		},
		"lyra": {
			"current_hp": 98,
			"current_ee": 55,
			"level": 7,
			"current_xp": 1850
		}
	},
	"event_flags": {
		"lyra_discovered": true,
		"garrick_recruited": true,
		"iris_recruited": true,
		"boss_defeated": true
	},
	"inventory": {
		"gold": 1250,
		"items": {
			"potion": 5,
			"antidote": 2,
			"crystal_fragment": 3
		}
	},
	"equipment": {
		"kael": {
			"weapon": "iron_sword",
			"helmet": "",
			"chest": "leather_armor",
			"accessory_0": "",
			"accessory_1": ""
		}
	},
	"quests": {
		"active": {
			"crystal_hunt": {
				"objectives": [true, false]
			}
		},
		"completed": ["village_intro"],
		"failed": []
	}
}
```

### Why JSON

JSON is human-readable, git-diffable, and debuggable. When a save file is corrupted or a bug produces wrong state, you can open the file in any text editor and inspect every field. Compare this to binary save formats — Godot's built-in `ConfigFile` or `ResourceSaver` — where debugging requires custom tooling.

The trade-off is file size. A JSON save for this game is typically 2–5 KB. Binary would be smaller, but disk space is not a constraint for JRPG save files. If you were saving replay data or procedural world state (hundreds of MB), binary would be worth the debugging cost. For dozens of numbers and strings, JSON wins.

### The Version Field

```json
"version": 1
```

This is a schema version, not a game version. If you change the save format — adding a new system, renaming a field, restructuring the party data — increment this number and add migration logic:

```gdscript
func apply_save_data(data: Dictionary, ...) -> void:
	var version: int = data.get("version", 0)
	if version < 1:
		# Migrate from v0 format
		data = _migrate_v0_to_v1(data)
	# ... apply v1 data ...
```

You may never need to migrate, but the version field costs nothing and saves you from having to guess "is this an old save or a new save?" if you ever change the format.

## Step 2: The SaveManager

The `SaveManager` autoload coordinates saving and loading. It does not own any game state — it asks other managers for their state and tells them to restore it:

```gdscript
# res://autoloads/save_manager.gd
extends Node

## Manages saving and loading game state to JSON files.

const SAVE_DIR: String = "user://saves/"
const SAVE_VERSION: int = 1
const AUTOSAVE_SLOT: int = 0
const MAX_MANUAL_SLOTS: int = 3
const TOTAL_SLOTS: int = 4
```

Register it as an autoload named `SaveManager`.

### The Save Path

Save files live at `user://saves/save_N.json`. Godot's `user://` path resolves to a platform-specific location:

| Platform | Path |
|----------|------|
| Windows | `%APPDATA%/godot/app_userdata/<project>/` |
| macOS | `~/Library/Application Support/Godot/app_userdata/<project>/` |
| Linux | `~/.local/share/godot/app_userdata/<project>/` |

You never need to think about the actual path — Godot handles the platform abstraction. `FileAccess.open("user://saves/save_1.json", FileAccess.WRITE)` works identically on every platform.

### Gathering Save Data

The `gather_save_data()` method collects state from every manager into one Dictionary:

```gdscript
func gather_save_data(
	party: Node,
	inventory: Node,
	flags: Node,
	scene_path: String,
	player_position: Vector2,
	equipment: Node = null,
	quests: Node = null,
	playtime: float = 0.0,
) -> Dictionary:
	var data := {
		"version": SAVE_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"playtime_seconds": playtime,
		"scene_path": scene_path,
		"player_position": {
			"x": player_position.x,
			"y": player_position.y,
		},
		"party": _serialize_party(party),
		"character_state": _serialize_character_state(party),
		"event_flags": flags.get_all_flags(),
		"inventory": _serialize_inventory(inventory),
	}
	if equipment:
		data["equipment"] = equipment.serialize()
	if quests:
		data["quests"] = quests.serialize()
	return data
```

Notice that managers are passed as `Node` parameters, not accessed as globals. This is dependency injection — the same pattern you use in Angular services with constructor injection. It makes the save manager testable: in tests, you can pass mock nodes instead of real autoloads.

In practice, the caller (a save slot UI or an autosave trigger) resolves the autoloads and passes them in:

```gdscript
# Triggered by the save menu
func _save_to_slot(slot: int) -> void:
	var player := get_tree().get_first_node_in_group("player")
	var scene := get_tree().current_scene
	SaveManager.save_game(
		slot,
		PartyManager,
		InventoryManager,
		EventFlags,
		scene.scene_file_path,
		player.global_position,
		EquipmentManager,
		QuestManager,
		GameManager.playtime_seconds,
	)
```

### Serializing Party State

The party serialization captures two things: the roster composition (who is active vs. reserve) and the runtime state (current HP, EE, level, XP):

```gdscript
func _serialize_party(party: Node) -> Dictionary:
	var active_ids: Array[String] = []
	var reserve_ids: Array[String] = []
	for member in party.active_party:
		var bd := member as BattlerData
		if bd:
			active_ids.append(String(bd.id))
	for member in party.reserve_party:
		var bd := member as BattlerData
		if bd:
			reserve_ids.append(String(bd.id))
	return {"active": active_ids, "reserve": reserve_ids}


func _serialize_character_state(
	party: Node,
) -> Dictionary:
	var state := {}
	for member in party.roster:
		var bd := member as BattlerData
		if not bd:
			continue
		var char_id := String(bd.id)
		var runtime: Dictionary = party.get_runtime_state(
			bd.id,
		)
		var entry := {
			"current_hp": runtime.get("current_hp", bd.max_hp),
			"current_ee": runtime.get("current_ee", bd.max_ee),
		}
		var cd := member as CharacterData
		if cd:
			entry["level"] = cd.level
			entry["current_xp"] = cd.current_xp
		else:
			entry["level"] = 1
			entry["current_xp"] = 0
		state[char_id] = entry
	return state
```

The roster is stored as string IDs, not full character data. On load, the system uses these IDs to reload the `.tres` files from disk. This means changing a character's base stats in their `.tres` file will affect existing save files — intentional, since you want balance changes to apply retroactively.

Runtime state (current HP, EE) is stored separately because it changes during gameplay, while base stats are defined by the Resource files.

### Serializing Inventory

```gdscript
func _serialize_inventory(
	inventory: Node,
) -> Dictionary:
	var items := {}
	for key: StringName in inventory.get_all_items():
		items[String(key)] = inventory.get_item_count(key)
	return {
		"gold": inventory.gold,
		"items": items,
	}
```

`StringName` keys are converted to `String` for JSON compatibility. Gold is stored alongside items for organizational clarity.

## Step 3: Writing to Disk

```gdscript
func save_game(
	slot: int,
	party: Node,
	inventory: Node,
	flags: Node,
	scene_path: String,
	player_position: Vector2,
	equipment: Node = null,
	quests: Node = null,
	playtime: float = 0.0,
) -> bool:
	var data := gather_save_data(
		party, inventory, flags,
		scene_path, player_position, equipment, quests,
		playtime,
	)
	return _write_save_file(slot, data)


func _write_save_file(
	slot: int,
	data: Dictionary,
) -> bool:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var path := get_save_path(slot)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error(
			"SaveManager: cannot write '%s' — %s"
			% [path, error_string(FileAccess.get_open_error())]
		)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


func get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_%d.json" % slot
```

### File I/O Breakdown

**`DirAccess.make_dir_recursive_absolute(SAVE_DIR)`** — creates the `saves/` directory if it does not exist. This is called every time, which is safe — creating an already-existing directory is a no-op. The alternative — checking if the directory exists first — is a TOCTOU race condition (the directory could be deleted between the check and the write).

**`FileAccess.open(path, FileAccess.WRITE)`** — opens the file for writing. If the file already exists, it is overwritten. `FileAccess.WRITE` creates the file if it does not exist.

**`FileAccess.open()` returns `null` on failure.** This is Godot's convention — no exceptions, no error codes. Check for null, then use `FileAccess.get_open_error()` to get the specific error enum value and `error_string()` to convert it to a readable message.

**`JSON.stringify(data, "\t")`** — converts the Dictionary to a JSON string with tab indentation. The indentation makes the file human-readable at the cost of slightly larger file size. Pass `""` for minified output.

**`file.store_string(json)`** — writes the entire string to the file. For save files (a few KB), writing the whole string at once is fine. For larger files, you might use `store_line()` in a loop.

**`file.close()`** — flushes the buffer and closes the file handle. In Godot 4.x, `FileAccess` objects are reference-counted and will close automatically when they go out of scope, but explicit `close()` is good practice — it ensures the write is flushed before the function returns.

### Error Handling

The save function returns a `bool`: `true` on success, `false` on failure. Failures are logged with `push_error()`, which prints to the Godot console and the editor's output panel. The calling code can use the return value to show an error message in the UI:

```gdscript
func _on_save_pressed(slot: int) -> void:
	var ok := SaveManager.save_game(slot, ...)
	if not ok:
		_show_error("Save failed. Check disk space.")
```

## Step 4: Loading from Disk

Loading is the reverse: read the file, parse JSON, then hand the data to each manager for deserialization.

### Reading the File

```gdscript
func load_save_data(slot: int) -> Dictionary:
	var path := get_save_path(slot)
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error(
			"SaveManager: cannot open '%s' — %s"
			% [path, error_string(FileAccess.get_open_error())]
		)
		return {}
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error(
			"SaveManager: JSON parse error in '%s' — %s"
			% [path, json.get_error_message()]
		)
		return {}
	return json.data as Dictionary
```

**`FileAccess.file_exists(path)`** — a static method that checks file existence without opening it. Use this for the "has save" check in the save slot UI.

**`file.get_as_text()`** — reads the entire file contents as a UTF-8 string. For our small save files, this is simpler and faster than line-by-line reading.

**`JSON.new()` + `json.parse(text)`** — Godot's JSON parser is an instanced class, not a static utility. `parse()` returns an `Error` enum value (`OK` on success). The parsed result is accessible via `json.data` — a `Variant` that you cast to `Dictionary`.

The empty Dictionary `{}` return on failure is a deliberate choice. Callers check `if data.is_empty(): return` rather than checking for null. This avoids null-propagation bugs and makes the failure path explicit.

### Applying Save Data

```gdscript
func apply_save_data(
	data: Dictionary,
	party: Node,
	inventory: Node,
	flags: Node,
	equipment: Node = null,
	quests: Node = null,
) -> void:
	_apply_inventory(data.get("inventory", {}), inventory)
	_apply_flags(data.get("event_flags", {}), flags)
	_apply_character_state(
		data.get("character_state", {}), party,
	)
	if equipment:
		equipment.deserialize(data.get("equipment", {}))
	if quests:
		quests.deserialize(data.get("quests", {}), [])
```

Each subsystem is restored independently. The order matters slightly — flags should be restored before quests because quest prerequisites may check flags — but in practice, the restore happens in a single frame before any game logic runs, so ordering is rarely an issue.

### Restoring Inventory

```gdscript
func _apply_inventory(
	inv_data: Dictionary,
	inventory: Node,
) -> void:
	# Clear existing inventory first
	for item_id: StringName in inventory.get_all_items():
		var count: int = inventory.get_item_count(item_id)
		inventory.remove_item(item_id, count)
	inventory.gold = inv_data.get("gold", 0)
	var items: Dictionary = inv_data.get("items", {})
	for item_id: String in items:
		inventory.add_item(
			StringName(item_id), int(items[item_id]),
		)
```

The inventory is cleared before loading. This is important — without clearing, loaded items would *add* to whatever the player currently has, duplicating their inventory. The clear-then-restore pattern ensures the loaded state exactly matches the save file.

### Restoring Character State

```gdscript
func _apply_character_state(
	state_data: Dictionary,
	party: Node,
) -> void:
	for char_id: String in state_data:
		var entry: Dictionary = state_data[char_id]
		var sn := StringName(char_id)
		var hp: int = int(entry.get("current_hp", 0))
		var ee: int = int(entry.get("current_ee", 0))
		party.set_hp(sn, hp)
		party.set_ee(sn, ee)
		var level: int = int(entry.get("level", 1))
		var xp: int = int(entry.get("current_xp", 0))
		for member in party.roster:
			var cd := member as CharacterData
			if cd and cd.id == sn:
				cd.level = level
				cd.current_xp = xp
				break
```

Level and XP are restored by mutating the `CharacterData` resource directly. This works because `load()` returns a shared cache — the same resource instance is used everywhere that references it. Changing `cd.level` here means the battle system, the status screen, and the save system all see the updated value.

## Step 5: Position Restoration

After loading, the player must appear in the correct scene at the correct position. This requires two steps: changing the scene and then moving the player.

The challenge is timing. `GameManager.change_scene()` is asynchronous — the new scene is not available until the next frame (or after the fade transition). You cannot set the player's position until the scene has loaded and the player node exists in the tree.

The solution: store the pending position and apply it when the scene change completes:

```gdscript
var _pending_position: Vector2 = Vector2.ZERO
var _has_pending_position: bool = false


func set_pending_position(pos: Vector2) -> void:
	_pending_position = pos
	_has_pending_position = true
	if not GameManager.scene_changed.is_connected(
		_on_scene_changed_restore_position,
	):
		GameManager.scene_changed.connect(
			_on_scene_changed_restore_position,
			CONNECT_ONE_SHOT,
		)


func _on_scene_changed_restore_position(
	_scene_path: String,
) -> void:
	if not _has_pending_position:
		return
	_has_pending_position = false
	var player := get_tree().get_first_node_in_group(
		"player",
	)
	if player:
		player.global_position = _pending_position
```

The caller triggers the load sequence:

```gdscript
# In the load menu UI
func _on_load_slot(slot: int) -> void:
	var data := SaveManager.load_save_data(slot)
	if data.is_empty():
		return

	# Restore all manager state
	SaveManager.apply_save_data(
		data,
		PartyManager,
		InventoryManager,
		EventFlags,
		EquipmentManager,
		QuestManager,
	)

	# Queue position restoration for after scene change
	var pos_data: Dictionary = data.get("player_position", {})
	var pos := Vector2(
		float(pos_data.get("x", 0.0)),
		float(pos_data.get("y", 0.0)),
	)
	SaveManager.set_pending_position(pos)

	# Change to the saved scene
	var scene_path: String = data.get("scene_path", "")
	GameManager.change_scene(scene_path)
```

The `CONNECT_ONE_SHOT` flag ensures the position callback fires exactly once and then disconnects. Without it, every subsequent scene change would reset the player's position to the saved location.

### Why Not Save the Spawn Point Name?

You might consider saving the spawn point group name (e.g., `"spawn_from_forest"`) instead of pixel coordinates. This would work for normal scene transitions, but fails when the player saves at an arbitrary position — standing in the middle of a field, not near any spawn point. Pixel coordinates handle both cases.

## Step 6: Save Slots and Metadata

Four save slots provide a good balance: one autosave and three manual saves.

```gdscript
const AUTOSAVE_SLOT: int = 0
const MAX_MANUAL_SLOTS: int = 3
const TOTAL_SLOTS: int = 4


func has_save(slot: int) -> bool:
	return FileAccess.file_exists(get_save_path(slot))
```

### Slot Summaries for the UI

The save/load screen needs to display information about each slot without loading the full save data. The `get_slot_summary()` method extracts just what the UI needs:

```gdscript
func get_slot_summary(slot: int) -> Dictionary:
	if not has_save(slot):
		return {
			"empty": true,
			"location": "",
			"playtime_str": "",
			"time_str": "",
			"timestamp": 0,
		}
	var data := load_save_data(slot)
	if data.is_empty():
		return {
			"empty": true,
			"location": "",
			"playtime_str": "",
			"time_str": "",
			"timestamp": 0,
		}
	var scene_path: String = data.get("scene_path", "")
	var location: String = _get_area_name(scene_path)
	var playtime: float = float(
		data.get("playtime_seconds", 0.0),
	)
	var playtime_str := _format_playtime(playtime)
	var timestamp: int = int(data.get("timestamp", 0))
	var time_str := _format_timestamp(timestamp)
	return {
		"empty": false,
		"location": location,
		"playtime_str": playtime_str,
		"time_str": time_str,
		"timestamp": timestamp,
	}
```

The UI displays something like:

```
Slot 1: Roothollow — 02:34 — 06 Mar, 14:30
Slot 2: Verdant Forest — 01:12 — 05 Mar, 22:15
Slot 3: (empty)
```

### Formatting Helpers

```gdscript
static func _format_playtime(
	playtime_seconds: float,
) -> String:
	if playtime_seconds < 60.0:
		return ""
	var total_minutes: int = int(playtime_seconds) / 60
	var hours: int = total_minutes / 60
	var minutes: int = total_minutes % 60
	return "%02d:%02d" % [hours, minutes]


static func _format_timestamp(unix_time: int) -> String:
	if unix_time <= 0:
		return ""
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(
		unix_time,
	)
	const MONTHS: Array[String] = [
		"", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
		"Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
	]
	var month_idx: int = dt.get("month", 0)
	var month_str: String = MONTHS[month_idx]
	return "%02d %s, %02d:%02d" % [
		dt.get("day", 0),
		month_str,
		dt.get("hour", 0),
		dt.get("minute", 0),
	]
```

`Time.get_datetime_dict_from_unix_time()` converts a Unix timestamp to a Dictionary with keys like `"year"`, `"month"`, `"day"`, `"hour"`, `"minute"`. This is Godot's equivalent of `new Date(timestamp)` in JavaScript.

### Area Name Mapping

Scene paths like `"res://scenes/roothollow/roothollow.tscn"` are not user-friendly. A lookup table maps paths to display names:

```gdscript
const _AREA_NAMES: Dictionary = {
	"res://scenes/roothollow/roothollow.tscn": "Roothollow",
	"res://scenes/verdant_forest/verdant_forest.tscn": "Verdant Forest",
	"res://scenes/overgrown_ruins/overgrown_ruins.tscn": "Overgrown Ruins",
}


func _get_area_name(scene_path: String) -> String:
	if _AREA_NAMES.has(scene_path):
		return _AREA_NAMES[scene_path]
	# Fallback: extract the file name
	return scene_path.get_file().get_basename()
```

The fallback extracts the file name and strips the extension — `"overgrown_ruins"` is better than a raw path, even if it is not perfectly formatted.

## Step 7: Autosave

Autosave triggers on scene changes — when the player walks through a door or transition zone, the game automatically saves to slot 0:

```gdscript
func _ready() -> void:
	GameManager.scene_changed.connect(
		_on_scene_changed_for_autosave,
	)


func _on_scene_changed_for_autosave(
	scene_path: String,
) -> void:
	if _is_autosave_excluded(scene_path):
		return
	call_deferred("autosave")


func autosave() -> void:
	var player := get_tree().get_first_node_in_group(
		"player",
	)
	if not player:
		return
	var scene := get_tree().current_scene
	if not scene:
		return
	var scene_path: String = scene.scene_file_path
	var party := get_node_or_null("/root/PartyManager")
	var inventory := get_node_or_null("/root/InventoryManager")
	var flags := get_node_or_null("/root/EventFlags")
	var equipment := get_node_or_null("/root/EquipmentManager")
	var quests := get_node_or_null("/root/QuestManager")
	if not party or not inventory or not flags:
		return
	save_game(
		AUTOSAVE_SLOT, party, inventory, flags,
		scene_path, player.global_position,
		equipment, quests,
	)
```

**`call_deferred("autosave")`** — the autosave runs at the end of the frame, after the scene change is fully complete. Without deferral, the player node might not exist yet in the new scene.

**Excluded scenes** — title screens, game-over screens, and credits should not trigger autosave. A list of excluded paths prevents overwriting a good save with a menu state:

```gdscript
const _AUTOSAVE_EXCLUDED_SCENES: Array[String] = [
	"res://ui/title_screen/title_screen.tscn",
]


func _is_autosave_excluded(scene_path: String) -> bool:
	return scene_path in _AUTOSAVE_EXCLUDED_SCENES
```

## Step 8: The Serialize/Deserialize Protocol

Each manager that has persistent state implements a pair of methods:

```gdscript
# Pattern every manager follows
func serialize() -> Dictionary:
	# Convert internal state to a plain Dictionary
	# All values must be JSON-compatible (no Resources, no Nodes)
	return {"key": value, ...}


func deserialize(data: Dictionary) -> void:
	# Restore internal state from the Dictionary
	# Clear existing state first, then populate from data
	_state.clear()
	for key in data:
		_state[key] = data[key]
```

This protocol is the JRPG equivalent of Redux's `getState()` / `dispatch(RESTORE)`. Each manager is responsible for its own serialization — the SaveManager just collects and distributes the dictionaries.

### Adding Save Support for a New System

When you build a new system (Chapter 17's AudioManager, Chapter 18's UI state), adding save support takes three steps:

1. **Implement `serialize()` and `deserialize()` on the manager:**

```gdscript
# In the new manager
func serialize() -> Dictionary:
	return {
		"setting_a": _setting_a,
		"setting_b": _setting_b,
	}


func deserialize(data: Dictionary) -> void:
	_setting_a = data.get("setting_a", default_a)
	_setting_b = data.get("setting_b", default_b)
```

2. **Add the new data to `gather_save_data()`:**

```gdscript
# In SaveManager.gather_save_data()
if new_manager:
	data["new_system"] = new_manager.serialize()
```

3. **Add the restore call to `apply_save_data()`:**

```gdscript
# In SaveManager.apply_save_data()
if new_manager:
	new_manager.deserialize(data.get("new_system", {}))
```

The `data.get("new_system", {})` pattern handles backward compatibility. Old save files that do not have the `"new_system"` key will pass an empty dictionary, and `deserialize()` will use default values. No migration needed.

### Serialization Rules

Every value in the save dictionary must be JSON-compatible:

| GDScript Type | JSON Representation |
|---------------|---------------------|
| `int`, `float` | number |
| `String` | string |
| `bool` | true/false |
| `Dictionary` | object |
| `Array` | array |
| `StringName` | convert to `String` with `String(sn)` |
| `Vector2` | `{"x": float, "y": float}` |
| `Resource` | store `id: StringName` → reload from path |
| `Node` | **not serializable** — store identifying data instead |

Resources and Nodes cannot be serialized directly. Store their IDs and reload them from disk on deserialize. This is why every Resource has an `id: StringName` field — it serves as both a primary key and a file path component.

## Step 9: Deleting Saves

```gdscript
func delete_save(slot: int) -> void:
	var path := get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
```

`DirAccess.remove_absolute()` deletes a single file. Despite the class name suggesting "directory access," this static method works on files too. The existence check prevents a warning on deleting a non-existent file.

The save slot UI should confirm before deleting — "Are you sure you want to delete this save?" — since deletion is irreversible.

## How It Connects

```
SaveManager (autoload)
  ├── gather_save_data()
  │   ├── PartyManager  → roster IDs + runtime HP/EE/level/XP
  │   ├── InventoryManager → items + gold
  │   ├── EventFlags → all flag names
  │   ├── EquipmentManager.serialize() → per-character gear IDs
  │   └── QuestManager.serialize() → active/completed/failed
  │
  ├── _write_save_file() → JSON to user://saves/save_N.json
  │
  ├── load_save_data() → JSON from disk → Dictionary
  │
  ├── apply_save_data()
  │   ├── InventoryManager ← clear + restore items/gold
  │   ├── EventFlags ← load_flags()
  │   ├── PartyManager ← set HP/EE, level/XP per character
  │   ├── EquipmentManager.deserialize() ← reload gear
  │   └── QuestManager.deserialize() ← restore quest states
  │
  └── set_pending_position() → deferred player placement
      └── GameManager.scene_changed → apply position
```

The save system touches every manager but depends on none of them structurally. Each manager implements `serialize()` / `deserialize()` independently. The SaveManager is just the orchestrator — it calls the methods and moves data between managers and disk.

## Common Mistakes

**Not clearing state before restoring.** If `apply_save_data()` does not clear the inventory first, loaded items add to existing items. Every `deserialize()` method must start with a clear/reset of its internal state.

**Saving during transitions.** If the autosave fires while a scene transition is mid-fade, the saved position might be in the old scene or a transitional state. The `call_deferred("autosave")` pattern ensures the save happens after the transition completes.

**Storing Resource references in save data.** Resources are live objects — they cannot be serialized to JSON. Store the `id: StringName` (converted to `String`) and reload the `.tres` file from disk on deserialize. If the file does not exist (renamed, deleted), degrade gracefully with a `push_warning`.

**Forgetting `Vector2` decomposition.** JSON has no `Vector2` type. Store `{"x": v.x, "y": v.y}` and reconstruct with `Vector2(data.x, data.y)`. This applies to any Godot type without a direct JSON equivalent — `Color`, `Rect2`, `Transform2D`, etc.

**Not handling missing keys.** Old save files will not have keys added in newer versions. Always use `data.get("key", default_value)` instead of `data["key"]`. The default value ensures the game works even with save files from older versions.

**Testing only the happy path.** Test loading a save with missing keys, corrupted JSON, and old version numbers. The system should degrade gracefully — `push_error`, return empty dictionary, use defaults — rather than crashing.

## What is Next

The game now saves and loads player progress. But the world is silent — no music during exploration, no sound effects in battle, no audio feedback when opening chests. Chapter 17 builds the `AudioManager` with BGM crossfading and a pooled SFX system.

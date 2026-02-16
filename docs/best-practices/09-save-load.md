# Save/Load Best Practices

Distilled from `docs/godot-docs/tutorials/io/saving_games.rst`.

## Save Data Architecture

### Serializable Data Layer

Keep all saveable state in **Resources** or **Dictionaries**, separate from
node logic:

```gdscript
class_name SaveData
extends Resource

@export var player_name: String = ""
@export var play_time_seconds: float = 0.0
@export var current_scene: String = ""
@export var player_position: Vector2 = Vector2.ZERO
@export var party_data: Array[CharacterSaveData] = []
@export var inventory_data: Dictionary = {}
@export var quest_states: Dictionary = {}
@export var flags: Dictionary = {}
@export var echo_collection: Array[StringName] = []
```

### Saveable Interface Pattern

Nodes that need to persist state implement a consistent interface:

```gdscript
## Add to "saveable" group and implement these methods.

func get_save_data() -> Dictionary:
	return {
		"position": position,
		"health": health,
		"state": current_state,
	}


func load_save_data(data: Dictionary) -> void:
	position = data.get("position", Vector2.ZERO)
	health = data.get("health", max_health)
	current_state = data.get("state", State.IDLE)
```

## Save Manager Pattern

```gdscript
class_name SaveManager
extends Node

const SAVE_DIR := "user://saves/"
const SAVE_EXT := ".tres"

signal save_completed(slot: int)
signal load_completed(slot: int, success: bool)


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func save_game(slot: int) -> void:
	var save_data := SaveData.new()
	save_data.current_scene = get_tree().current_scene.scene_file_path

	# Collect data from all saveable nodes
	for node in get_tree().get_nodes_in_group("saveable"):
		save_data.node_data[node.scene_file_path] = node.get_save_data()

	var path := _get_save_path(slot)
	ResourceSaver.save(save_data, path)
	save_completed.emit(slot)


func load_game(slot: int) -> bool:
	var path := _get_save_path(slot)
	if not ResourceLoader.exists(path):
		load_completed.emit(slot, false)
		return false

	var save_data: SaveData = ResourceLoader.load(path)
	# Restore scene and data...
	load_completed.emit(slot, true)
	return true


func has_save(slot: int) -> bool:
	return ResourceLoader.exists(_get_save_path(slot))


func _get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_%d%s" % [slot, SAVE_EXT]
```

## Save File Formats

| Format | Pros | Cons |
|--------|------|------|
| `.tres` (text Resource) | Human-readable, git-friendly, type-safe | Larger file size |
| `.res` (binary Resource) | Smaller, faster | Not readable |
| JSON | Universal, portable | No type safety, manual parsing |

**Recommendation**: Use `.tres` for development, `.res` for release builds.

## Data Paths

- `res://` -- Read-only project files (shipped with game)
- `user://` -- Read-write user data (saves, settings, logs)

`user://` maps to:
- Windows: `%APPDATA%/Godot/app_userdata/ProjectName/`
- macOS: `~/Library/Application Support/Godot/app_userdata/ProjectName/`
- Linux: `~/.local/share/godot/app_userdata/ProjectName/`

## Save Slot UI Data

```gdscript
func get_slot_preview(slot: int) -> Dictionary:
	var path := _get_save_path(slot)
	if not ResourceLoader.exists(path):
		return {"empty": true}
	var data: SaveData = ResourceLoader.load(path)
	return {
		"empty": false,
		"player_name": data.player_name,
		"play_time": data.play_time_seconds,
		"level": data.party_data[0].level if data.party_data.size() > 0 else 1,
		"location": data.current_scene.get_file().get_basename(),
	}
```

## Anti-Patterns

- Saving node references (they become invalid after load)
- Saving entire scene trees (save data, reconstruct scenes)
- Using `var_to_str()` / `str_to_var()` for untrusted data (security risk)
- Not versioning save format (breaks old saves on updates)
- Saving in `_process()` (save on explicit trigger only)
- Large autosave files blocking the main thread (use background thread)

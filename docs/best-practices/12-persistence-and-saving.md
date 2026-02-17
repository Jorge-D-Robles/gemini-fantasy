# Persistence & Saving Best Practices

## Core Concept: The Saveable Interface

To ensure consistency and prevent data loss, any entity that needs its state preserved across game sessions (chests, NPCs, quest triggers, player position) must implement a standardized persistence pattern.

## 1. Unique Identification (persistence_id)

Every persistent object MUST have a unique identifier.
- **Rule:** Use a string property named `persistence_id`.
- **Format:** `[Region]_[Scene]_[EntityName]_[Number]` (e.g., `Root_Village_Chest_01`).
- **Why:** This prevents state collisions when loading data into a dictionary.

```gdscript
@export var persistence_id: String
```

## 2. The Saveable Interface Pattern

Objects requiring persistence should implement `get_save_data()` and `load_save_data(data: Dictionary)` methods.

### Example: Persistent Chest

```gdscript
extends Interactable

@export var persistence_id: String
var is_opened: bool = false

func get_save_data() -> Dictionary:
	return {
		"is_opened": is_opened
	}

func load_save_data(data: Dictionary) -> void:
	is_opened = data.get("is_opened", false)
	if is_opened:
		_set_visual_to_opened()
```

## 3. Global State Registration

The `SaveManager` does not search the tree for objects. Instead, objects register themselves when they enter the scene.

```gdscript
func _ready() -> void:
	if persistence_id.is_empty():
		push_warning("Persistent object %s missing persistence_id" % name)
		return
	
	SaveManager.register_object(self)

func _exit_tree() -> void:
	SaveManager.unregister_object(self)
```

## 4. What to Save (and What Not To)

- **SAVE:** Booleans (opened, triggered), Integers (counts, current stage), Strings (custom names).
- **DO NOT SAVE:** Node references, Texture resources, or temporary timers.
- **NEVER SAVE:** Raw positional data for moving NPCs unless they are "parked" at a destination.

## 5. Directory Structure

All save files must be stored in `user://saves/` using the `.sav` extension. 
- **Slot naming:** `save_01.sav`, `save_02.sav`, etc.
- **Metadata:** Every save file should contain a `metadata` header with playtime, location, and party level for the "Load Game" UI.

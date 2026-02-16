# Autoloads and Singletons Best Practices

Distilled from `docs/godot-docs/tutorials/best_practices/`.

## When Autoloads ARE Appropriate

Use autoloaded nodes ONLY for systems that:

1. **Track all data internally** (manage their own state)
2. **Are globally accessible** (legitimately needed everywhere)
3. **Exist in isolation** (don't interfere with other objects)

### Good Autoload Candidates (for this JRPG)

| System | Why Global |
|--------|-----------|
| SaveManager | Any system may trigger save |
| AudioManager | Music/SFX needed everywhere |
| DialogueManager | Dialogue triggers from any scene |
| SceneManager | Scene transitions from anywhere |
| InventoryManager | Items accessed from many contexts |
| QuestManager | Quest state checked broadly |
| PartyManager | Party data needed in combat, menus, world |
| EventBus | Global signal relay |

### Bad Autoload Candidates

| System | Why NOT Global |
|--------|---------------|
| CombatManager | Only exists during battles |
| CameraController | Belongs to the active scene |
| EnemySpawner | Scene-specific |
| UIManager | UI lives in the scene tree |

## The Global State Problem

**Anti-pattern**: A global `SoundManager` that owns all audio.

- **Global state**: Single point of failure
- **Global access**: Any code can call it, hard to debug
- **Resource allocation**: Pre-allocate too many or too few

**Better**: Each scene manages its own `AudioStreamPlayer` nodes.
The `AudioManager` autoload only handles crossfading BGM and bus levels.

## Static Variables as Autoload Alternative

GDScript 4.x provides `static var` with `class_name`, eliminating some autoload needs:

```gdscript
# game_data.gd
class_name GameData
extends RefCounted

static var player_name: String = ""
static var difficulty: int = 1
static var flags: Dictionary = {}
```

Use this for **pure data** that doesn't need lifecycle callbacks.

## Autoload Script Pattern

```gdscript
class_name SaveManager
extends Node

## Manages save/load operations globally.

signal save_completed
signal load_completed(success: bool)

const SAVE_DIR := "user://saves/"
const MAX_SLOTS := 3

var current_slot: int = 0


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func save_game(slot: int) -> void:
	# ...implementation
	save_completed.emit()


func load_game(slot: int) -> bool:
	# ...implementation
	load_completed.emit(true)
	return true
```

## Autoload Registration

In `project.godot`:
```ini
[autoload]
SaveManager="*res://game/autoloads/save_manager.gd"
AudioManager="*res://game/autoloads/audio_manager.gd"
```

The `*` prefix means it's loaded as a node (not just a script).

## Anti-Patterns

- Autoload that references specific scene nodes (tight coupling)
- Using autoload for scene-local state
- Autoload with `_process()` that runs when not needed
- Multiple autoloads that depend on each other's load order
- Storing large data (textures, audio) in autoloads permanently

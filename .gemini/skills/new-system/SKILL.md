---
name: new-system
description: Scaffold a new game system (combat, inventory, dialogue, saveload, audio, camera, quest, etc.) with manager script, resources, and autoload setup.
argument-hint: <system-name> [details...]
disable-model-invocation: true
---

# Create New Game System

Scaffold a complete game system for: **$ARGUMENTS**

## Step 1 — Identify the System

Parse arguments to determine which system to create. Common JRPG systems:

| System | Manager Script | Resources | Autoload? | Key Docs |
|--------|---------------|-----------|-----------|----------|
| `combat` | `combat_manager.gd` | Skill, StatusEffect | No | physics, animation, signals |
| `inventory` | `inventory_manager.gd` | Item | Yes | resources, autoloads, saving |
| `dialogue` | `dialogue_manager.gd` | DialogueLine, DialogueTree | Yes | resources, UI, RichTextLabel |
| `save` / `save-load` | `save_manager.gd` | — | Yes | iosaving_games, data_paths |
| `audio` | `audio_manager.gd` | — | Yes | audio_buses, audio_streams |
| `camera` | `camera_controller.gd` | — | No | Camera2D class |
| `quest` | `quest_manager.gd` | Quest, QuestObjective | Yes | resources, signals, saving |
| `stats` / `progression` | `stats_manager.gd` | CharacterStats | No | resources, signals |
| `state-machine` | `state_machine.gd` | — | No | scripting, best_practices |
| `input` | `input_manager.gd` | — | Yes | inputs, InputEvent |
| `scene-transition` | `scene_manager.gd` | — | Yes | change_scenes_manually, scene_tree |
| `party` | `party_manager.gd` | PartyMember | Yes | resources, autoloads |

## Step 2 — Look Up Documentation (MANDATORY — do not skip)

**You MUST complete ALL of these before writing any code:**

1. **Call the `godot-docs` skill** for the key classes this system uses:
   ```
   activate_skill("godot-docs") # Look up [Node type], [Resource type], and [related classes] for building a [SYSTEM] system. I need properties, methods, signals, and patterns.
   ```
2. **Read the relevant best practices files**:
   - `docsbest-practices/03-autoloads-and-singletons.md` (if autoload system)
   - `docsbest-practices/02-signals-and-communication.md` (for signal design)
   - `docsbest-practices/04-resources-and-data.md` (if system uses Resources)
   - `docsbest-practices/07-state-machines.md` (if state machine based)
3. **Read the relevant design doc** from `docs/game-design/` for game-specific requirements

## Step 3 — Create Directory Structure

```
game/systems/<system_name>/
├── <system_name>_manager.gd    # Main manager script
├── resources/                   # Custom Resource scripts
│   ├── <resource_type>.gd      # Resource class definitions
│   └── ...
└── data/                        # Data files (optional)
    └── ...
```

## Step 4 — Create the Manager Script

The manager is the central coordinator for the system. It should follow this pattern:

```gdscript
class_name <SystemName>Manager
extends Node
## Manages the <system_name> system.
##
## <Extended description of what this system handles.>


# --- Signals ---

signal <system_event_happened>(params)


# --- Constants ---

const <RELEVANT_CONSTANT>: <type> = <value>


# --- Exports ---

@export var <config_property>: <type> = <default>


# --- State ---

var <internal_state>: <type> = <default>


# --- Lifecycle ---

func _ready() -> void:
	pass


# --- Public API ---

## <Description of what this method does.>
func <public_method>(params) -> <ReturnType>:
	pass


# --- Private Methods ---

func _<helper_method>(params) -> <ReturnType>:
	pass
```

## Step 5 — Create Resource Scripts (if needed)

Custom Resource classes for system data:

```gdscript
class_name <ResourceName>
extends Resource
## <Description of this resource type.>


@export var <property>: <type> = <default>
```

## Step 6 — Register Autoload (if needed)

If the system should be an autoload singleton, tell the user to add it:

```
Project > Project Settings > Globals > Autoload
Path: res:/systems/<system_name>/<system_name>_manager.gd
Name: <SystemName>Manager
```

Or instruct them to add it to `project.godot`:

```ini
[autoload]

<SystemName>Manager="*res:/systems/<system_name>/<system_name>_manager.gd"
```

## Step 7 — Report

After creating files, report:
1. Files created (with full paths)
2. Public API surface (signals, public methods)
3. Resources defined
4. Whether autoload registration is needed
5. Integration points (how other scripts should interact with this system)
6. Suggested next steps

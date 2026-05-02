---
name: build-level
description: Create a new level/map scene with proper layer structure, entity placement, transitions, and encounter zones. Use when building overworld areas, dungeons, towns, or interior maps.
argument-hint: <level-name> <level-type> [details...]
disable-model-invocation: true
---

# Build Level

Create a level scene for: **$ARGUMENTS**

ultrathink

## Step 1 — Identify Level Type

| Type | Root Node | Layers | Design Source |
|------|-----------|--------|---------------|
| `overworld` | Node2D | Ground, GroundDetail, Trees, Paths, Objects, AbovePlayer, Entities | `docs/game-design/03-world-map-and-locations.md` |
| `town` / `settlement` | Node2D | Ground, GroundDetail, Paths, Objects, AbovePlayer, Entities | `docs/game-design/03-world-map-and-locations.md` |
| `dungeon` | Node2D | Ground, Walls, GroundDetail, Objects, Entities, Triggers | `docs/game-design/05-dungeon-designs.md` |
| `interior` | Node2D | Ground, Walls, Objects, Entities | N/A (simple) |
| `battle-arena` | Node2D | Background, Platforms, Effects | `docs/game-design/01-core-mechanics.md` |

## Step 2 — Research (MANDATORY — do not skip)

**You MUST complete ALL of these before writing any code:**

1. **Call the `godot-docs` subagent** for level-related classes:
   ```
   Task(subagent_type="godot-docs", prompt="Look up TileMapLayer, Camera2D, Area2D, and Marker2D. I need properties, methods, signals for building a [LEVEL_TYPE] level scene. Include tilemap tutorials.")
   ```
2. **Read scene architecture best practices**:
   ```
   Read("docs/best-practices/01-scene-architecture.md")
   ```
3. **Read the relevant design document** for this location's description, NPCs, events, and encounters
4. **Read `docs/lore/01-world-overview.md`** for region context

## Step 3 — Create Level Scene Structure

### Overworld / Town Template

```
<LevelName> (Node2D) -- level_name.gd
  ├── Ground (TileMapLayer)             # Base terrain (organic multi-terrain patches)
  ├── GroundDetail (TileMapLayer)       # Ground decorations (15-30% coverage)
  ├── Trees (TileMapLayer)              # Forest borders (B-sheet, collision)
  ├── Paths (TileMapLayer)              # Walkway overlay
  ├── Objects (TileMapLayer)            # Rocks, buildings (B-sheet, collision)
  ├── AbovePlayer (TileMapLayer)        # Tree canopy, rooftops (no collision)
  ├── Entities (Node2D)                 # Y-sorted container
  │     ├── Player (spawn point marker)
  │     ├── NPCs (Node2D)
  │     │     ├── NPC_<name> (CharacterBody2D or Area2D)
  │     │     └── ...
  │     └── Interactables (Node2D)
  │           ├── Chest_<id> (Area2D)
  │           ├── SavePoint (Area2D)
  │           └── ...
  ├── Triggers (Node2D)
  │     ├── SceneTransition_<target> (Area2D)
  │     ├── BattleZone_<id> (Area2D)
  │     ├── CutsceneTrigger_<id> (Area2D)
  │     └── EventTrigger_<id> (Area2D)
  ├── Parallax (ParallaxBackground)     # Optional background layers
  │     └── ParallaxLayer
  │           └── Sprite2D
  └── LevelCamera (Camera2D)
        # Set limits to level bounds
```

### Dungeon Template

```
<DungeonName> (Node2D) -- dungeon_name.gd
  ├── Ground (TileMapLayer)
  ├── Walls (TileMapLayer)
  ├── GroundDetail (TileMapLayer)
  ├── Objects (TileMapLayer)
  ├── Entities (Node2D)
  │     ├── SpawnPoint (Marker2D)
  │     ├── Enemies (Node2D)
  │     │     └── EnemySpawn_<id> (Marker2D + metadata)
  │     ├── NPCs (Node2D)
  │     └── Interactables (Node2D)
  │           ├── Chest_<id> (Area2D)
  │           ├── Switch_<id> (Area2D)
  │           ├── LockedDoor_<id> (Area2D)
  │           └── Puzzle_<id> (Node2D)
  ├── Triggers (Node2D)
  │     ├── RoomTransition_<id> (Area2D)
  │     ├── BossZone (Area2D)
  │     ├── TrapTrigger_<id> (Area2D)
  │     └── CheckpointTrigger_<id> (Area2D)
  ├── Fog (CanvasLayer)                  # Optional fog of war
  └── DungeonCamera (Camera2D)
```

## Step 4 — Create Level Script

```gdscript
class_name <LevelName>Level
extends Node2D

## <Description from design doc.>

signal level_entered
signal level_exited

@export var level_id: StringName = &"<level_id>"
@export var level_name: String = "<Display Name>"
@export var bgm: AudioStream
@export var encounter_rate: float = 0.05
@export var enemy_groups: Array[Resource] = []  # EnemyGroupData


func _ready() -> void:
	_setup_transitions()
	_setup_encounters()
	if bgm:
		AudioManager.play_bgm(bgm)
	level_entered.emit()


func _setup_transitions() -> void:
	for trigger in $Triggers.get_children():
		if trigger.has_method("setup"):
			trigger.setup()


func _setup_encounters() -> void:
	for zone in $Triggers.get_children():
		if zone is Area2D and zone.name.begins_with("BattleZone"):
			zone.body_entered.connect(
				func(_body: Node2D) -> void:
					# Random encounter logic handled by encounter system
					pass
			)
```

## Step 5 — Create Scene Transition Areas

For each exit/entrance, create an `Area2D` trigger:

```gdscript
class_name SceneTransitionTrigger
extends Area2D

## Triggers a scene transition when the player enters.

@export_file("*.tscn") var target_scene: String
@export var target_spawn_point: String = "default"
@export var transition_type: String = "fade"

var _triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if body.is_in_group("player"):
		_triggered = true
		SceneManager.change_scene(target_scene, target_spawn_point)
```

## Step 6 — Create Spawn Points

Add `Marker2D` nodes for player spawn positions:

```
SpawnPoint_default (Marker2D)   # Default entrance
SpawnPoint_north (Marker2D)     # From northern map
SpawnPoint_south (Marker2D)     # From southern map
```

## Step 7 — Report

1. Scene file path and structure
2. Script file path
3. All NPC, interactable, and trigger nodes (what the user needs to configure)
4. Tilemap layers created (user must paint in editor)
5. Scene transitions and their target scenes
6. Encounter zones and assigned enemy groups
7. **Editor tasks** — things only the user can do:
   - Paint tilemaps
   - Assign TileSet resources
   - Position entities on the map
   - Set Camera2D limits
   - Assign NPC sprites and dialogue
   - Configure collision shapes

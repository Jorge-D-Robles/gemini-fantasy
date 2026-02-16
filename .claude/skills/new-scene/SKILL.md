---
name: new-scene
description: Create a new Godot scene with script and proper node hierarchy. Use for creating characters, enemies, NPCs, items, levels, or any game object.
argument-hint: <scene-type> <name> [details...]
disable-model-invocation: true
---

# Create New Godot Scene

Create a new scene and accompanying GDScript for: **$ARGUMENTS**

## Step 1 — Determine Scene Type

Parse the arguments to determine the scene type. Common types:

| Type | Root Node | Typical Children | Directory |
|------|-----------|-----------------|-----------|
| `character` / `player` | CharacterBody2D | AnimatedSprite2D, CollisionShape2D | `game/scenes/characters/` |
| `enemy` | CharacterBody2D | AnimatedSprite2D, CollisionShape2D, NavigationAgent2D | `game/scenes/enemies/` |
| `npc` | CharacterBody2D or Area2D | AnimatedSprite2D, CollisionShape2D, Area2D (interaction zone) | `game/scenes/npcs/` |
| `item` / `pickup` | Area2D | Sprite2D, CollisionShape2D | `game/scenes/items/` |
| `projectile` | Area2D | Sprite2D, CollisionShape2D | `game/scenes/projectiles/` |
| `level` / `map` | Node2D | TileMapLayer, Camera2D, spawn markers | `game/scenes/levels/` |
| `effect` | Node2D | AnimatedSprite2D or GPUParticles2D | `game/scenes/effects/` |

If the type is ambiguous, ask the user.

## Step 2 — Look Up Documentation

Before writing any code, look up the relevant Godot class references:

```
Use the godot-doc-lookup skill or read docs/godot-docs/classes/class_<rootnode>.rst directly.
Also consult docs/godot-docs-index.md for related tutorials.
```

## Step 3 — Create Directory Structure

Ensure the target directory exists under `game/scenes/`.

## Step 4 — Create the Scene (.tscn)

Create a `.tscn` file with the proper Godot scene format. Use `[gd_scene]` header, `[ext_resource]` for external assets, `[sub_resource]` for inline resources, and `[node]` entries.

### Scene File Template

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scenes/<category>/<name>.gd" id="1"]

[node name="<RootName>" type="<RootType>"]
script = ExtResource("1")

[node name="<ChildName>" type="<ChildType>" parent="."]
```

## Step 5 — Create the Script (.gd)

Generate a GDScript file following these conventions from CLAUDE.md:

### Script Template

```gdscript
class_name <PascalCaseName>
extends <RootNodeType>
## <Brief description of what this scene/entity does.>


signal <relevant_signal>


enum <RelevantEnum> {
	VALUE_ONE,
	VALUE_TWO,
}


const <RELEVANT_CONSTANT>: <type> = <value>


@export var <exported_property>: <type> = <default>


var <internal_property>: <type> = <default>


@onready var <child_ref>: <Type> = $<ChildNodeName>


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	pass
```

### Code Style Rules (from CLAUDE.md)

- Use **tabs** for indentation
- Use **static typing** everywhere
- Use **double quotes** for strings
- Use `@export` for inspector-exposed variables
- Use `@onready` for child node references
- Use `and`/`or`/`not` over `&&`/`||`/`!`
- **Trailing commas** in multiline arrays, dicts, enums
- **Two blank lines** between functions
- Lines under 100 characters (prefer 80)
- Signals in **past tense** (e.g., `health_changed`, `died`)
- Private members prefixed with `_`

## Step 6 — Report

After creating files, report:
1. Files created (with full paths)
2. Node hierarchy of the scene
3. Signals and exports defined
4. Suggested next steps (e.g., "Add sprite frames", "Set collision shape", "Connect signals")

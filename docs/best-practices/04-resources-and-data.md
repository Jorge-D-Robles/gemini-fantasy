# Resources and Data Best Practices

Distilled from `docs/godot-docs/tutorials/best_practices/` and `tutorials/scripting/resources.rst`.

## Nodes vs Resources

- **Nodes**: Functionality (draw sprites, handle input, simulate physics)
- **Resources**: Data containers (don't do anything themselves)

## When to Use Custom Resources

- **Game data definitions**: Items, skills, enemies, quests
- **Configuration**: Difficulty settings, balance tuning
- **Shared data**: Data used across multiple scenes
- **Serializable state**: Anything that needs saving/loading

## Resource Pattern for JRPG Data

```gdscript
@icon("res://game/assets/icons/item.png")
class_name ItemData
extends Resource

## Defines an item's properties for the inventory system.

enum Type {
	CONSUMABLE,
	EQUIPMENT,
	KEY_ITEM,
	MATERIAL,
}

enum TargetType {
	SELF,
	SINGLE_ALLY,
	ALL_ALLIES,
	SINGLE_ENEMY,
	ALL_ENEMIES,
}

@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var item_type: Type = Type.CONSUMABLE
@export var target_type: TargetType = TargetType.SELF
@export var value: int = 0
@export var max_stack: int = 99
@export var is_sellable: bool = true
@export var use_effect: PackedScene  ## Scene containing effect logic
```

## External vs Built-in Resources

| Type | When | Benefit |
|------|------|---------|
| **External** (`.tres` files) | Reuse across scenes | Edit independently, version control friendly |
| **Built-in** (inside `.tscn`) | Scene-specific data | Keep scene self-contained |

**Rule**: Game data (items, enemies, skills) should ALWAYS be external `.tres` files.

## Resource Loading

```gdscript
# Preload -- at script load time (use for known, static resources)
const SlashEffect := preload("res://game/scenes/effects/slash.tscn")

# Load -- at runtime (use for dynamic/variable paths)
var item_data: ItemData = load("res://game/data/items/potion.tres")
```

### Loading Rules

- `preload()` for constants and static references
- `load()` for runtime-determined paths
- Don't `preload()` `@export` properties (inspector overrides them)
- Engine caches loaded resources -- subsequent `load()` calls return the same instance

### Null-Check `load()` for Asset Files

`load()` returns `null` when a file exists on disk but Godot hasn't imported it yet
(no `.import` sidecar file). This commonly happens with PNGs and audio files that are
gitignored and must be copied manually into the project.

**Always guard `load()` results for asset-dependent resources:**

```gdscript
# BAD — crashes if texture not imported
var tex: Texture2D = load(path)
var size := tex.get_size()  # null access crash

# GOOD — graceful failure with clear error
var tex: Texture2D = load(path) as Texture2D
if tex == null:
    push_error("Failed to load '%s' — ensure file exists and reopen editor to import" % path)
    return
var size := tex.get_size()
```

This applies to any `load()` call for: textures, audio streams, fonts, or other
binary assets that live in `game/assets/` (which is gitignored for PNGs/audio).
Script and scene resources (`*.gd`, `*.tscn`, `*.tres`) are tracked in git and
generally safe to load without null checks.

## Resource Organization

```
game/data/
  ├── items/
  │   ├── consumables/
  │   │   ├── potion.tres
  │   │   └── ether.tres
  │   ├── equipment/
  │   │   ├── iron_sword.tres
  │   │   └── leather_armor.tres
  │   └── key_items/
  ├── skills/
  │   ├── fire.tres
  │   └── heal.tres
  ├── enemies/
  │   ├── goblin.tres
  │   └── dragon.tres
  ├── echoes/
  │   ├── combat/
  │   ├── tuning/
  │   └── story/
  └── quests/
      ├── main/
      └── side/
```

## Resource Duplication

```gdscript
# Resources are shared by default -- modifying one modifies all references
var original: ItemData = load("res://game/data/items/potion.tres")
var copy: ItemData = original.duplicate()  # Independent copy
copy.value = 999  # Only affects this copy
```

**Important for runtime state**: Always `.duplicate()` resource data before
modifying it at runtime (e.g., equipment with temporary buffs).

## Anti-Patterns

- Storing game data in script constants instead of Resources
- Using Dictionaries when a typed Resource would be clearer
- Loading resources in `_process()` (load once, cache reference)
- Modifying shared resources without duplicating first
- Putting resource scripts in a different directory than their `.tres` files

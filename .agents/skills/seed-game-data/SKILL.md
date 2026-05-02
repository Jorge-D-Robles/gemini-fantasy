---
name: seed-game-data
description: Populate game data by creating .tres resource files from design documents. Use when you need to create items, enemies, skills, echoes, quests, or other game data in bulk from the design docs.
argument-hint: <data-type> [count-or-range] [details...]
disable-model-invocation: true
---

# Seed Game Data

Create game data resources for: **$ARGUMENTS**

ultrathink

## Step 1 — Identify Data Type and Source

Determine what data to create and where the design specs live:

| Data Type | Resource Class | Design Source | Output Directory |
|-----------|---------------|---------------|-----------------|
| `items` | ItemData | `docs/game-design/01-core-mechanics.md` | `game/data/items/` |
| `skills` / `abilities` | SkillData | `docs/mechanics/character-abilities.md` | `game/data/skills/` |
| `enemies` | EnemyData | `docs/game-design/02-enemy-design.md` | `game/data/enemies/` |
| `echoes` | EchoData | `docs/lore/04-echo-catalog.md` | `game/data/echoes/` |
| `quests` | QuestData | `docs/game-design/04-side-quests.md` | `game/data/quests/` |
| `characters` | CharacterStats | `docs/lore/03-characters.md` | `game/data/characters/` |
| `equipment` | EquipmentData | `docs/game-design/01-core-mechanics.md` | `game/data/equipment/` |
| `status-effects` | StatusEffectData | `docs/game-design/01-core-mechanics.md` | `game/data/status_effects/` |
| `loot-tables` | LootTableData | `docs/game-design/02-enemy-design.md` | `game/data/loot_tables/` |
| `dialogue` | DialogueData | `docs/lore/02-main-story.md` | `game/data/dialogue/` |

## Step 2 — Read Design Documents

1. Read the relevant design document(s) to extract specific data
2. Read the relevant Resource class script at `game/systems/*/resources/` or `game/data/`
3. If the Resource class doesn't exist yet, create it first (see `/new-resource`)

## Step 3 — Verify Resource Class Exists

Check that the Resource class for this data type exists:

```
Glob: game/**/<resource_name>.gd
```

If it doesn't exist, create it based on the design document fields.
Every Resource class must have:
- `class_name` declaration
- `@export` properties for all data fields
- `## doc comments` on the class and key properties
- An `id: StringName` field for lookups

## Step 4 — Create .tres Files

For each data entry, create a `.tres` file:

```ini
[gd_resource type="Resource" script_class="ItemData" load_steps=2 format=3]

[ext_resource type="Script" path="res://game/data/resources/item_data.gd" id="1"]

[resource]
script = ExtResource("1")
id = &"potion"
display_name = "Potion"
description = "Restores 50 HP to one ally."
item_type = 0
value = 50
max_stack = 99
```

### Naming Convention

- File name: `snake_case.tres` matching the `id` field
- Example: `fire_sword.tres` with `id = &"fire_sword"`

## Step 5 — Create Data Index (optional but recommended)

If creating 10+ entries, create an index resource or script:

```gdscript
class_name ItemDatabase
extends Node

## Preloaded database of all items. Register as autoload or access statically.

var _items: Dictionary = {}  # StringName -> ItemData


func _ready() -> void:
	_load_all("res://game/data/items/")


func get_item(id: StringName) -> ItemData:
	return _items.get(id)


func _load_all(directory_path: String) -> void:
	var dir := DirAccess.open(directory_path)
	if not dir:
		return
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tres"):
			var item: ItemData = load(directory_path + file_name)
			if item:
				_items[item.id] = item
		file_name = dir.get_next()
```

## Step 6 — Report

1. Number of `.tres` files created
2. Full file paths
3. Resource class used (and whether it was created or already existed)
4. Any data gaps where design doc was ambiguous (flag for user review)
5. Whether a database/index was created
6. Suggested next steps (connect to inventory system, battle system, etc.)

## Data Consistency Rules

- Every `id` must be unique within its type
- Every `display_name` must be non-empty
- Numeric values must match design doc ranges (HP 1-9999, MP 0-999, etc.)
- Enum values must match the Resource class's enum definitions
- Reference other resources by `id`, not file path, when possible

---
name: new-resource
description: Create a new custom Godot Resource class for game data (items, skills, character stats, quests, enemy definitions, etc.). Use when you need a reusable data container.
argument-hint: <resource-name> [properties...]
disable-model-invocation: true
---

# Create New Custom Resource

Create a custom Resource class for: **$ARGUMENTS**

## Background

Custom Resources in Godot are the standard way to define reusable data containers. They can be:
- Created as `.tres` files in the editor inspector
- Loaded with `preload()` or `load()`
- Used as `@export` types on other scripts
- Saved and loaded as part of the game state

Before creating the resource, read:
- `docs/godot-docs/tutorials/scripting/resources.rst` — Custom Resources guide
- `docs/godot-docs/classes/class_resource.rst` — Resource class API

## Step 1 — Determine Resource Properties

Parse the arguments to identify what properties this resource needs. Common JRPG resource patterns:

| Resource Type | Typical Properties |
|---------------|-------------------|
| Item | name, description, icon, item_type, value, stack_size, effect |
| Skill / Ability | name, description, icon, mp_cost, damage, element, target_type, animation |
| CharacterStats | max_hp, max_mp, attack, defense, speed, luck, element_resist |
| EnemyDefinition | name, stats, sprite_frames, loot_table, ai_type, exp_reward, gold_reward |
| Quest | id, title, description, objectives, rewards, prerequisites |
| QuestObjective | description, type, target, required_count, current_count |
| DialogueLine | speaker, text, portrait, choices, next_line_id |
| StatusEffect | name, type, duration, strength, tick_damage, stat_modifiers |
| LootEntry | item, drop_chance, min_count, max_count |
| Equipment | name, slot, stats_bonus, required_level, sprite |

## Step 2 — Create the Resource Script

Create at `game/systems/<system>/resources/<name>.gd` or `game/data/<category>/<name>.gd`.

### Template

```gdscript
@icon("res://assets/icons/<resource_type>.svg")
class_name <PascalCaseName>
extends Resource
## <Brief description of what this resource represents.>
##
## <Extended description. How to create instances, what they're used for.>


## <Property description.>
@export var name: String = ""

## <Property description.>
@export var description: String = ""

## <Property description.>
@export var icon: Texture2D

## <Property description — use enum for categorical types.>
@export var <property>: <Type> = <default>
```

### Resource Design Rules

- Use `@export` on ALL properties so they're editable in the inspector
- Use `##` doc comments above every property
- Use enums for categorical types (item type, element, target type, etc.)
- Use other Resources as property types for composition (e.g., `@export var stats: CharacterStats`)
- Use `Array[<Type>]` for typed arrays (e.g., `@export var loot_table: Array[LootEntry]`)
- Provide sensible defaults for all properties
- Add `@icon` if you have a relevant icon

### Enum Definitions

If the resource needs enums, define them in the resource script:

```gdscript
class_name Item
extends Resource

enum Type {
	CONSUMABLE,
	EQUIPMENT,
	KEY_ITEM,
	MATERIAL,
}

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
}

@export var item_type: Type = Type.CONSUMABLE
@export var rarity: Rarity = Rarity.COMMON
```

## Step 3 — Create Example Data (optional)

If the user wants sample data, create `.tres` files:

```
[gd_resource type="Resource" script_class="<ClassName>" load_steps=2 format=3]

[ext_resource type="Script" path="res://data/<category>/<name>.gd" id="1"]

[resource]
script = ExtResource("1")
name = "Example"
description = "An example resource."
```

## Step 4 — Report

After creating files, report:
1. Files created (with full paths)
2. All properties with types and defaults
3. Enums defined
4. How to create instances in the editor (right-click in FileSystem > New Resource > select class)
5. How to use from scripts (`@export var item: Item`, `preload("res://data/items/potion.tres")`)
6. Suggested next steps

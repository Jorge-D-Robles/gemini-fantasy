# Module 9: Resources, the Data Layer

## What We Have So Far

A connected two-area game world (Willowbrook and Whisperwood) with scene transitions, a SceneManager autoload, and a player character with animation and a state machine.

## What We're Building This Module

The data architecture that powers everything from here forward. We'll learn Godot's **Resource** system and create custom data types for items, characters, and NPC information, all editable in the Inspector, all saved as `.tres` files, all type-safe.

This might seem like a detour from "making the game," but it's not. Every system we build after this (dialogue, inventory, combat, quests) will use Resources as their data backbone. Getting this right now saves us from painful refactors later.

## What is a Resource?

Every RPG you have ever played runs on a hidden spreadsheet. When the original Final Fantasy team designed their game in 1987, they kept binders full of handwritten tables: which weapon gives +5 attack, which spell costs 8 MP, which enemy has 120 HP. The game code didn't contain those numbers directly; it read them from data tables. This separation of data from code is what let the designers tune balance without rewriting programs. Godot's Resource system is the modern version of those binders: a structured, editor-friendly way to define game data that your code reads at runtime.

A **Resource** is Godot's universal data container. You've already used several:

- The `SpriteFrames` you created in Module 6 is a Resource
- The `TileSet` from Module 5 is a Resource
- The `RectangleShape2D` on your CollisionShape2D is a Resource
- Even GDScript files (`.gd`) are Resources

Resources are **data objects**: they hold information but don't have behavior tied to the scene tree. Unlike Nodes, they:

- Are not part of the scene tree
- Can be shared across multiple nodes (the same TileSet used by four TileMapLayers)
- Can be saved to disk as `.tres` files (text) or `.res` files (binary)
- Can be loaded and unloaded at any time
- Can be created and edited in the Inspector

> **See:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html), the official guide to Godot's Resource system.

> **See:** [Resource class](https://docs.godotengine.org/en/stable/classes/class_resource.html), the full API reference.

## Custom Resource Classes

Godot lets you define your own Resource types. This is very useful for game data. Instead of using raw dictionaries, you define structured data types with named, typed fields that the editor understands.

### Defining a Resource Class

First, create two new folders for our data architecture: `res://resources/` (for Resource class definitions) and `res://data/` with subdirectories `items/` and `characters/` (for data instances). Right-click in the FileSystem dock → **New Folder** to create each.

Create a new file at `res://resources/item_data.gd`:

```gdscript
extends Resource
class_name ItemData
## Data definition for an inventory item.

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM }
enum EquipSlot { NONE, WEAPON, ARMOR, ACCESSORY }

@export var id: String = ""  ## Unique identifier; match the .tres filename (e.g., "potion")
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D  ## Leave empty for now; we'll add item icons later
@export var item_type: ItemType = ItemType.CONSUMABLE
@export var equip_slot: EquipSlot = EquipSlot.NONE

@export_group("Consumable Effects")
@export var hp_restore: int = 0
@export var mp_restore: int = 0

@export_group("Equipment Stats")
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var speed_bonus: int = 0

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0
```

Here's what's going on:

### `class_name ItemData`

This registers the class globally. After saving this file, `ItemData` becomes a recognized type everywhere in the project: in other scripts, in the Inspector, in the "Create New Resource" dialog.

### `@export` Properties

Every `@export` property appears as an editable field in the Inspector when you select a `.tres` file of this type. This is the key advantage over dictionaries: your data is **self-documenting and validated by the editor**.

### `@export_group("...")`

Groups `@export` properties under collapsible headers in the Inspector. Purely organizational, no runtime effect.

### `@export_multiline`

Shows a multiline text editor in the Inspector instead of a single-line field. Perfect for descriptions.

### Enums as Export Types

When you `@export` an enum variable, the Inspector shows a dropdown menu with the enum values. No typos, no invalid values.

## A Warning About Resources and Shared References

Resources are **shared by reference**. If you load the same `.tres` file in two places, both get the **same object in memory**. If one script modifies a field (e.g., `item.hp_restore = 99`), the other script sees the change too.

This is powerful for data that should be consistent everywhere (like item definitions). But it's dangerous for data that should be independent (like two characters each equipping the same sword). If you need an independent copy, call `resource.duplicate()`:

```gdscript
var my_copy: ItemData = shared_item.duplicate()
my_copy.hp_restore = 99  # Only affects my_copy, not the original
```

At runtime, never modify a Resource you loaded from a `.tres` unless you want the change to be visible everywhere. We'll revisit this pattern in Module 25 when we need a fresh copy of CharacterData for new games.

## Creating `.tres` Files

Now that we have the `ItemData` class, we'll create actual items.

### Method 1: In the Inspector

1. In the FileSystem dock, right-click on a folder (e.g., `res://data/items/`).
2. Choose **New Resource**.
3. Search for `ItemData` in the type list.
4. Click **Create**.
5. A new `.tres` file appears. Name it `potion.tres`.
6. Select it. The Inspector shows all the `@export` fields.
7. Fill in the values.

### Method 2: In Code (for testing)

```gdscript
var potion := ItemData.new()
potion.id = "potion"
potion.display_name = "Potion"
potion.description = "Restores 50 HP."
potion.item_type = ItemData.ItemType.CONSUMABLE
potion.hp_restore = 50
potion.buy_price = 25
potion.sell_price = 10
```

### Crystal Saga Items

Create these `.tres` files in `res://data/items/`:

**`potion.tres`** (ItemData)
- id: "potion"
- display_name: "Potion"
- description: "Restores 50 HP to one ally."
- item_type: CONSUMABLE
- hp_restore: 50
- buy_price: 25, sell_price: 10

**`ether.tres`** (ItemData)
- id: "ether"
- display_name: "Ether"
- description: "Restores 20 MP to one ally."
- item_type: CONSUMABLE
- mp_restore: 20
- buy_price: 50, sell_price: 20

**`iron_sword.tres`** (ItemData)
- id: "iron_sword"
- display_name: "Iron Sword"
- description: "A sturdy blade forged in Willowbrook."
- item_type: EQUIPMENT
- equip_slot: WEAPON
- attack_bonus: 5
- buy_price: 100, sell_price: 40

**`leather_armor.tres`** (ItemData)
- id: "leather_armor"
- display_name: "Leather Armor"
- description: "Light protection for the road ahead."
- item_type: EQUIPMENT
- equip_slot: ARMOR
- defense_bonus: 3
- buy_price: 80, sell_price: 30

## `preload()` vs `load()`, and When to Use Each

There are two ways to load resources in code:

### `preload()`

```gdscript
const POTION := preload("res://data/items/potion.tres")
```

- Loads at **compile time**: the resource is embedded in the script.
- The path must be a **string literal** (no variables).
- **Fast** at runtime because it's already loaded.
- Use for resources you always need: UI textures, commonly used items, sound effects.

### `load()`

```gdscript
var item: ItemData = load("res://data/items/" + item_id + ".tres") as ItemData
```

- Loads at **runtime**: the resource is read from disk when the line executes.
- The path can be a **variable** (dynamic paths).
- Slightly slower the first time (Godot caches after the first load).
- Use for resources loaded dynamically: items based on player inventory, enemies based on encounter data.

### The Null-Check Pattern

`load()` can fail if the path is wrong. Always check:

```gdscript
var item: ItemData = load(path) as ItemData
if item == null:
    push_error("Failed to load item: " + path)
    return
```

This pattern prevents crashes from typos in file paths. Get in the habit of checking `load()` results. You'll thank yourself when a missing file doesn't crash the game but instead prints a clear error message.

> **Note:** `preload()` will cause a compile-time error if the path is wrong, so it doesn't need a null check. `load()` fails silently (returns `null`), so always check.

## CharacterData Resource

Next, a Resource for character stats:

```gdscript
extends Resource
class_name CharacterData
## Base data for a party member or NPC.

@export var id: String = ""
@export var display_name: String = ""
@export var portrait: Texture2D
@export var overworld_sprite: SpriteFrames

@export_group("Base Stats")
@export var max_hp: int = 100
@export var max_mp: int = 20
@export var attack: int = 10
@export var defense: int = 8
@export var speed: int = 10
@export var level: int = 1

@export_group("Growth per Level")
@export var hp_growth: int = 12
@export var mp_growth: int = 4
@export var attack_growth: int = 2
@export var defense_growth: int = 1
@export var speed_growth: int = 1

# Runtime state (set in code, not in the Inspector)
var current_xp: int = 0
var current_hp: int = 0
var current_mp: int = 0
```

Save this as `res://resources/character_data.gd`.

These last three variables are intentionally **not** `@export` values. They are runtime state, not authoring data. You still set Aiden's starting stats in the Inspector, but the game tracks "how much HP does Aiden have right now?" and "how much XP has he earned toward the next level?" in these plain variables while the game is running. A value of `0` means "not initialized yet"; later modules will treat that as "start at max HP/MP" for a fresh run.

> **Important:** Always set the `id` field on every `.tres` file. The inventory system (Module 12) uses `id` to match and stack items. If two items have the same `id` (or both are left empty), they'll be treated as identical.

Create the hero's data at `res://data/characters/aiden.tres`:
- id: "aiden"
- display_name: "Aiden"
- max_hp: 120, max_mp: 15
- attack: 12, defense: 8, speed: 10
- hp_growth: 15, attack_growth: 3

We'll create Lira's data (the mage companion) in Module 21 when we implement party recruitment.

## NPCData Resource

NPCs need data too: their name, sprite, and what they say.

```gdscript
extends Resource
class_name NPCData
## Data for a non-player character in the overworld.

@export var id: String = ""
@export var display_name: String = ""
@export var sprite_frames: SpriteFrames
@export var facing_direction: Vector2 = Vector2.DOWN

@export_group("Dialogue")
@export var dialogue_lines: Array[String] = []
```

Save as `res://resources/npc_data.gd`.

This is a simple version. We'll replace `dialogue_lines: Array[String]` with a proper `DialogueLine` Resource in Module 11. When we do, you'll need to re-edit the NPC `.tres` files to use the new dialogue format, so keep your text values handy. But even this simple version is better than hardcoding NPC names and text in each scene.

## The Three-File Pattern

This pattern exists because RPGs are content-heavy games. Dragon Quest XI has over 300 items, 200 monsters, and dozens of characters, all sharing the same underlying structure but with different values. If every Potion required its own function and every Slime required its own script, the codebase would be unmanageable. By separating structure, data, and consumer, a designer can add a new healing herb by creating one data file. No code changes needed.

Resources follow a consistent pattern across the project:

```
1. Resource Class (.gd)     →  defines the structure
2. Data Instance (.tres)    →  holds specific values
3. Consumer Script (.gd)    →  uses the data at runtime
```

For items:
```
resources/item_data.gd     →  defines what an item IS (name, type, stats)
data/items/potion.tres     →  a specific item (Potion, 50 HP, 25 gold)
autoloads/inventory.gd     →  manages the player's collection of items
```

For characters:
```
resources/character_data.gd  →  defines what a character IS (stats, growth)
data/characters/aiden.tres   →  a specific character (Aiden, 120 HP, sword user)
player/player.gd             →  uses the data for movement speed, battle stats
```

This separation keeps your code clean:
- **Resource classes** change rarely (only when you add new fields)
- **Data instances** change often (tuning balance, adding content)
- **Consumer scripts** don't care about specific data values (they work with any ItemData, any CharacterData)

## Why Resources Over Dictionaries

You might be thinking: "I could just use a Dictionary for all this." You're right, and many tutorials do. But Resources have clear advantages:

| Feature | Dictionary | Resource |
|---------|-----------|----------|
| Editor integration | None (must edit in code) | Full Inspector UI |
| Type safety | None (any key, any value) | Typed `@export` properties |
| Autocompletion | None | Full IDE support |
| Sharing | Copy by reference (dangerous) | Explicit sharing via `.tres` files |
| Saving to disk | Manual JSON serialization | Built-in `.tres`/`.res` format |
| Validation | Manual checking | Editor validates types and enum values |

The editor integration alone is worth it. Game designers (including future you) can tweak item stats, enemy HP, and quest rewards without touching code.

### The Data-Driven Mindset

Resources aren't just a convenience. They represent a fundamental design philosophy: **separate your data from your logic.** This is the single most important architectural pattern in RPG development.

Consider two ways to define a Potion:

```gdscript
# Logic-driven (data baked into code):
func use_potion(target: CharacterData) -> void:
    target.current_hp = min(target.current_hp + 50, target.max_hp)
    print("Restored 50 HP!")

# Data-driven (code reads data):
func use_item(item: ItemData, target: CharacterData) -> void:
    target.current_hp = min(target.current_hp + item.hp_restore, target.max_hp)
    print("Restored " + str(item.hp_restore) + " HP!")
```

The first version requires a new function for every item. The second version works for *any* healing item: Potion (50 HP), Hi-Potion (150 HP), Elixir (full HP). One function, infinite items. The data (`hp_restore`) drives the behavior. Note that `current_hp` is runtime state on `CharacterData`, not part of the `.tres` file. We will start using it heavily in Module 18 when battles begin carrying HP and MP forward between scenes.

This pattern scales across your entire RPG. Enemies, abilities, quests, dialogue, shops, encounter tables: all of them should be **data that code acts upon**, not **code that contains data**. When you find yourself writing a `match` statement with dozens of cases for specific item names or enemy types, that's a signal to push the differences into data.

Every system we build from here on will follow this principle. The three-file pattern (class → data → consumer) is how we enforce it.

## Project Organization

Here's our growing file structure:

```
CrystalSaga/
├── autoloads/
│   ├── scene_manager.tscn
│   └── scene_manager.gd
├── data/
│   ├── characters/
│   │   └── aiden.tres
│   └── items/
│       ├── potion.tres
│       ├── ether.tres
│       ├── iron_sword.tres
│       └── leather_armor.tres
├── player/
│   ├── player.tscn
│   └── player.gd
├── resources/
│   ├── item_data.gd
│   ├── character_data.gd
│   └── npc_data.gd
├── scenes/
│   ├── willowbrook/
│   │   └── willowbrook.tscn
│   ├── whisperwood/
│   │   └── whisperwood.tscn
│   └── exit_zone.gd
└── tilesets/
    └── town_tileset.tres
```

Notice the pattern: `resources/` holds class definitions, `data/` holds instances. This keeps things clean as the project grows to dozens of items and characters.

## What We've Learned

- **Resources** are Godot's data containers: type-safe, editor-friendly, saveable to disk.
- **Custom Resource classes** use `class_name` and `@export` to define structured data types.
- **`.tres` files** are Resource instances you create and edit in the Inspector.
- **`preload()`** loads at compile time (fast, constant paths only). **`load()`** loads at runtime (dynamic paths, must null-check).
- The **null-check pattern** (`if resource == null: push_error(...)`) prevents crashes from missing files.
- The **three-file pattern** separates structure (`.gd`), data (`.tres`), and behavior (consumer `.gd`).
- Resources are superior to dictionaries for game data: type safety, editor integration, autocompletion, and validation.
- **`@export_group()`** organizes Inspector fields. **`@export_multiline`** provides multiline text editing. Enum exports create dropdown menus.

## What You Should See

After this module:
- `ItemData`, `CharacterData`, and `NPCData` appear in the "Create New Resource" dialog
- Selecting a `.tres` file shows its typed properties in the Inspector
- Properties have appropriate editors: dropdowns for enums, texture pickers for `Texture2D`, multiline for descriptions
- No visual changes to the game yet. This module builds the foundation for everything that follows

## Next Module

We have data types. In **Module 10: NPCs and Interaction**, we'll use `NPCData` to populate Willowbrook with characters the player can approach and talk to. We'll build the interaction system: detecting nearby NPCs, showing a prompt, and handling the interaction input.

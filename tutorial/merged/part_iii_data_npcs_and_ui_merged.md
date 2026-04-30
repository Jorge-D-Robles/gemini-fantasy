# Merged Tutorial Part III: Data, NPCs, and UI

This generated file combines the tutorial Markdown files for this tutorial part.

## Included Files

- `09_resources_data_layer.md`
- `10_npcs_and_interaction.md`
- `11_dialogue_system.md`
- `12_inventory_system.md`
- `13_part_iii_review.md`

---

<!-- Source: 09_resources_data_layer.md -->

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

## Engineering Contract

- **Global state:** None yet; Resources are data definitions loaded by later systems.
- **Public surface:** `ItemData`, `CharacterData`, and `NPCData` classes plus `.tres` instances under `res://data/`.
- **Invariant:** IDs and resource paths are stable because later inventory, party, quest, and save systems reference them.
- **Failure behavior:** A failed `load()` should be treated as missing content and handled before dereferencing.
- **Copy semantics:** Resource instances loaded normally are cached and shared; mutable runtime copies need explicit duplication or cache-bypass loading later.

## Engine Gotcha

Godot Resources are reference types. If you mutate a cached Resource at runtime, every holder of that same loaded instance can observe the mutation.

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


---

<!-- Source: 10_npcs_and_interaction.md -->

# Module 10: NPCs and Interaction

## What We Have So Far

A two-area game world with scene transitions, a data layer with Resource classes for items, characters, and NPCs, and an animated player with a state machine.

## What We're Building This Module

NPCs that stand in Willowbrook, face the player when approached, and respond to an interaction button press. We'll build a reusable NPC scene driven by `NPCData` resources, and create the interaction detection system.

## The Interaction Pattern

NPCs are how an RPG world comes alive. In Chrono Trigger, talking to the people of Guardia Castle tells you about the Millennial Fair, hints at the kingdom's history, and sets up plot points that pay off 20 hours later. Without NPCs, the player is just walking through empty geometry. The interaction system we're building here is the foundation for everything social in the game: shops, inns, quest-givers, lore-keepers, and story-critical characters all start with "walk up and press a button."

Most JRPGs use the same interaction flow:

1. Player walks near an NPC
2. A visual prompt appears (a floating "!" or "A" icon)
3. Player presses the interact button
4. The NPC faces the player
5. Something happens (dialogue starts, shop opens, quest updates)

We need three things to make this work:
- A way to **detect** nearby interactable objects
- A way to **signal** "the player wants to interact"
- A way for each interactable to **respond** differently

## Setting Up the Interact Input Action

First, define a custom input action for interaction.

1. Go to **Project → Project Settings → Input Map**.
2. At the top, type `interact` in the "Add New Action" field and click **Add**.
3. Click the **+** button next to the new `interact` action.
4. Press the key you want to use. **Z** is traditional for JRPGs, or use **Enter/Space**.
5. Add a second binding for gamepad: click **+** again, choose **Joypad Button**, and select the **A/Cross** button.

Now `Input.is_action_just_pressed("interact")` works for both keyboard and gamepad.

> **See:** [Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html), setting up and using custom input actions.

## The NPC Scene

Create a reusable NPC scene that can represent any character (a shopkeeper, an innkeeper, a traveler) by swapping out data.

### Scene Structure

Create a `res://npcs/` folder (this holds reusable entity scenes, separate from the area scenes in `scenes/`). Create `res://npcs/npc.tscn`:

```
NPC (CharacterBody2D)
├── Sprite (AnimatedSprite2D)
├── CollisionShape2D
├── InteractionZone (Area2D)
│   └── InteractionShape (CollisionShape2D)
└── InteractionPrompt (Label)
```

**Why CharacterBody2D?** Even though NPCs don't move, using CharacterBody2D makes them solid. The player collides with them and can't walk through them. StaticBody2D would also work, but CharacterBody2D is more flexible if we later want NPCs to wander.

### Node Configuration

**Sprite (AnimatedSprite2D):** The NPC's visual. For now, if you don't have NPC sprite sheets, set up single-frame animations using the Godot icon, just like we did for the player fallback in Module 6. Create `idle_down`, `idle_up`, `idle_left`, `idle_right` animations with the icon as the single frame. You can replace these with real NPC sprites later.

**CollisionShape2D:** The NPC's physical body. Same "feet-only" approach as the player.
- Shape: `RectangleShape2D`, small (e.g., 12x8)
- Offset downward to align with the sprite's feet

**InteractionZone (Area2D):** A larger area around the NPC that detects when the player is nearby.
- Its CollisionShape should be **larger** than the body. A circle with radius ~24px works well.
- This is the "can interact" range.

**InteractionPrompt (Label):** A text label showing "!" that appears above the NPC when the player is in range. Using a Label instead of a Sprite2D means we don't need any art assets.
- Set **Text** to `!`
- Set **Horizontal Alignment** to `Center`
- Position it above the sprite (e.g., `Vector2(-4, -20)`)
- Set **Visible** to `false` initially
- Optionally increase the font size in Theme Overrides

### The NPC Script

Create `res://npcs/npc.gd`:

```gdscript
extends CharacterBody2D
## A non-player character that can be interacted with.

signal interacted(npc: CharacterBody2D)

@export var npc_data: NPCData

var _player_in_range: bool = false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _interaction_prompt: Label = $InteractionPrompt
@onready var _interaction_zone: Area2D = $InteractionZone


func _ready() -> void:
    _interaction_zone.body_entered.connect(_on_player_entered)
    _interaction_zone.body_exited.connect(_on_player_exited)
    _interaction_prompt.visible = false

    if npc_data:
        _apply_npc_data()


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range:
        return

    if event.is_action_pressed("interact"):
        _face_player()
        get_viewport().set_input_as_handled()
        interacted.emit(self)


func _apply_npc_data() -> void:
    if npc_data.sprite_frames:
        _sprite.sprite_frames = npc_data.sprite_frames

    # Set initial facing direction
    var dir_name := _direction_to_string(npc_data.facing_direction)
    var idle_anim := "idle_" + dir_name
    if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
        _sprite.play(idle_anim)


func _face_player() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if not player:
        return

    var direction: Vector2 = (player.global_position - global_position).normalized()
    var dir_name := _direction_to_string(direction)
    var idle_anim := "idle_" + dir_name
    if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
        _sprite.play(idle_anim)


func _direction_to_string(direction: Vector2) -> String:
    if abs(direction.x) > abs(direction.y):
        return "right" if direction.x > 0 else "left"
    else:
        return "down" if direction.y >= 0 else "up"


func _on_player_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _interaction_prompt.visible = true


func _on_player_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _interaction_prompt.visible = false
```

Here's why we made these choices:

### `_unhandled_input()` vs `_input()` vs `_process()`

We use **`_unhandled_input()`** instead of checking input in `_process()`. There are three input callbacks:

Imagine you're playing Secret of Mana and you open the ring menu. You press a button to select an item, but that same press also swings your sword at the NPC behind you. That's what happens when game-world input doesn't respect UI focus. Choosing the right input callback prevents this class of bug entirely.

| Callback | When It Runs |
|----------|-------------|
| `_input(event)` | Every input event, before anything else processes it |
| `_unhandled_input(event)` | Only if no UI element or other node has consumed the event |
| `_process()` + `Input.is_action_pressed()` | Every frame, checks current input state |

`_unhandled_input()` is ideal for game-world interactions because:
- It doesn't fire when a UI menu is consuming input
- We can call `get_viewport().set_input_as_handled()` to prevent other nodes from also responding to the same press
- It's event-driven (fires once on press), not polled (checked every frame)

### The `interacted` Signal

The NPC emits `interacted(self)` when the player presses interact. It doesn't know or care what happens next: dialogue, a shop, a quest update. That's the responsibility of whatever system connects to this signal.

This is the **separation of concerns** principle. The NPC knows about proximity detection and facing. The dialogue system knows about displaying text. They communicate through signals.

### `@export var npc_data: NPCData`

Each NPC instance in the editor gets an `NPCData` resource assigned through the Inspector. Different data = different NPC. Same scene, different behavior.

## Placing NPCs in Willowbrook

Open `willowbrook.tscn` and instance the NPC scene three times:

1. Drag `npc.tscn` into the **YSortGroup** node in the scene tree (or use Instance Child Scene with YSortGroup selected). NPCs must be inside YSortGroup alongside the Player and Objects layer so they sort correctly by Y position.
2. Rename each instance: `Shopkeeper`, `Innkeeper`, `Traveler`.
3. Position them in appropriate spots: shopkeeper near a market stall, innkeeper by a house, traveler on the path.

**Important:** Add each NPC instance to the `npcs` group (select the NPC → **Node** tab → **Groups** → type `npcs` → click **Add**). The scene script below uses this group to find all NPCs.

For each NPC, create an NPCData `.tres` file in `res://data/npcs/` (create the folder first). Follow the same Inspector workflow from Module 9: right-click the folder → **New Resource** → search for `NPCData` → **Create**. Assign each to the corresponding NPC's `npc_data` export in the Inspector.

**`res://data/npcs/shopkeeper.tres`:**
- id: "shopkeeper"
- display_name: "Merchant Hilda"
- facing_direction: Vector2.DOWN
- dialogue_lines: ["Welcome to my shop!", "I have potions and gear for sale.", "Be careful in those woods."]

**`res://data/npcs/innkeeper.tres`:**
- id: "innkeeper"
- display_name: "Old Brennan"
- facing_direction: Vector2.DOWN
- dialogue_lines: ["Need a rest? 10 gold for a night.", "You look like you've seen some trouble."]

**`res://data/npcs/traveler.tres`:**
- id: "traveler"
- display_name: "Wandering Fynn"
- facing_direction: Vector2.LEFT
- dialogue_lines: ["I lost something precious in the Whisperwood...", "A pendant, silver with a blue stone.", "If you find it, I'd be forever grateful."]

> **JRPG Pattern:** Notice how the traveler's dialogue sets up a side quest. We're not implementing the quest system yet (that's Module 20), but the dialogue seeds the idea in the player's mind. Classic JRPGs do this constantly. NPCs hint at things that become important later.

### Using the Player's INTERACT State

When the player interacts with an NPC, we should transition the player to the INTERACT state (Module 6). For now, we'll connect this in the Willowbrook scene script.

Create `res://scenes/willowbrook/willowbrook.gd` and attach it to the root `Willowbrook` node (if you already have a script attached from a previous module, replace its contents):

```gdscript
extends Node2D
## The town of Willowbrook, Crystal Saga's starting village.


func _ready() -> void:
    # Connect NPC interaction signals
    for npc in get_tree().get_nodes_in_group("npcs"):
        npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: CharacterBody2D) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("start_interaction"):
        player.start_interaction()

    # For now, just print the dialogue. Module 11 will add the real dialogue UI.
    if npc.npc_data:
        for line in npc.npc_data.dialogue_lines:
            print(npc.npc_data.display_name + ": " + line)

    # End interaction after a short delay (placeholder)
    await get_tree().create_timer(0.5).timeout
    if player and player.has_method("end_interaction"):
        player.end_interaction()
```

This is a temporary placeholder. In Module 11, we'll replace the `print()` calls with a proper dialogue box. But it demonstrates the flow: NPC detects interaction → emits signal → scene script handles it → player enters INTERACT state → interaction completes → player returns to IDLE.

## Interaction Detection: RayCast2D Alternative

We used Area2D on the NPC for detection. There's an alternative approach: a **RayCast2D** on the player that points in the facing direction.

```
Player (CharacterBody2D)
├── Sprite
├── CollisionShape2D
├── Camera2D
└── InteractRay (RayCast2D)   ← points forward, detects NPCs
```

The RayCast approach:
- Points in the player's facing direction
- Checks if it hits an interactable
- The interact button only works if the ray is hitting something

**Pros:** More precise, since you can only interact with what you're facing. No "interacting with the NPC behind you" situations.
**Cons:** More setup, requires updating the ray direction when the player turns.

Both approaches are valid. We're using the Area2D approach because it's simpler to set up and understand. If you want to switch later, the NPC's `interacted` signal works the same either way.

> **See:** [RayCast2D](https://docs.godotengine.org/en/stable/classes/class_raycast2d.html), for the ray-based detection approach.

## Engineering Contract

- **Global state:** None; interaction range and prompts are local to each NPC instance.
- **Public surface:** NPC scenes expose an interaction signal or method and carry `NPCData`.
- **Invariant:** Only the player group can trigger interaction prompts and dialogue starts.
- **Failure behavior:** Missing `NPCData` should disable interaction or show a safe fallback line.
- **Copy semantics:** NPCData is shared content data; per-NPC runtime flags should not be written into the Resource.

## Engine Gotcha

Area2D overlap signals depend on collision layers and masks. If the prompt never appears, inspect the Area2D and player collision setup before changing dialogue code.

## What We've Learned

- **Custom input actions** (`interact`) work with both keyboard and gamepad. Define them in Project Settings → Input Map.
- The **interaction pattern**: Area2D detection zone → prompt appears → player presses interact → NPC responds via signal.
- **`_unhandled_input()`** is the right callback for game-world interactions. It respects UI focus and can mark events as handled.
- **`get_viewport().set_input_as_handled()`** prevents multiple nodes from responding to the same input.
- **`@export var npc_data: NPCData`** lets each NPC instance use different data without a separate script.
- The `interacted` signal keeps NPCs decoupled from dialogue, shops, and quests.
- **Scene scripts** (like `willowbrook.gd`) wire NPCs to game systems. The NPC doesn't know about dialogue; the scene connects them.
- **Triggers vs actions**: the NPC's Area2D + input detection is the *trigger* (when and where something happens). The response (dialogue, shop, quest update) is the *action* (what happens). This separation is deliberate; the same NPC scene works for shopkeepers, quest-givers, and flavor characters because the trigger mechanism is identical. Only the action wired up in the scene script differs.
- The player's **INTERACT state** (Module 6) freezes movement during interactions.

## What You Should See

When you press F6 (running Willowbrook):
- Three NPCs stand in town
- Walking near an NPC shows an interaction prompt icon
- Walking away hides the prompt
- Pressing the interact key near an NPC:
  - The NPC faces the player
  - Dialogue lines print to the Output panel
  - The player stops moving for a moment
  - The player resumes normal movement after the interaction

## Next Module

We can interact with NPCs, but the dialogue is just `print()` output. In **Module 11: The Dialogue System**, we'll build a proper dialogue box UI with a typewriter text effect, speaker names, multi-page conversations, and choice/branching dialogue. The NPCs will finally talk like real JRPG characters.


---

<!-- Source: 11_dialogue_system.md -->

# Module 11: The Dialogue System

## What We Have So Far

NPCs in Willowbrook that detect the player and emit interaction signals. But dialogue is just `print()` output. Time to fix that.

## What We're Building This Module

A full dialogue box UI: text appears with a typewriter effect, the speaker's name is displayed, conversations span multiple pages, and the player can make choices during branching dialogue. Players spend more time reading dialogue than doing almost anything else in a JRPG, so getting the textbox right matters.

The dialogue box is arguably the most important UI element in any JRPG. In Undertale, every character has a distinct voice expressed through text speed, font, and box style. Sans speaks in lowercase, Papyrus in all-caps, and Flowey's text box literally breaks apart during intense moments. Even without going that far, the difference between a raw `print()` dump and a proper typewriter textbox is the difference between reading a script and experiencing a conversation.

## UI Fundamentals: Control Nodes

Game UI needs to work at any screen size. When a player resizes the window or plays on a phone, the dialogue box should still be at the bottom, the health bar should still be in the corner, and menus should still be centered. Node2D nodes use fixed pixel coordinates that break when the resolution changes. Godot's Control nodes solve this with anchors and containers, the same layout system that powers every web browser and phone app, adapted for games.

Godot's UI system is built on **Control** nodes, a family of nodes designed specifically for user interfaces. Unlike Node2D (which uses pixel coordinates), Control nodes use **anchors**, **margins**, and **containers** to create responsive layouts.

Key Control nodes we'll use:

| Node | Purpose |
|------|---------|
| `PanelContainer` | A styled rectangle (background for our dialogue box) |
| `MarginContainer` | Adds padding around its child |
| `VBoxContainer` | Stacks children vertically |
| `HBoxContainer` | Stacks children horizontally |
| `Label` | Displays plain text |
| `RichTextLabel` | Displays text with BBCode formatting |
| `TextureRect` | Displays an image |

Control nodes automatically size and position themselves based on their parent container. **Anchors** define where a node pins itself relative to its parent (e.g., "Bottom Wide" means "stick to the bottom edge and stretch the full width"). **Containers** like VBoxContainer handle child arrangement automatically: you add children and the container lays them out. This means our dialogue box will work correctly regardless of screen resolution.

> **See:** [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html), how Control nodes position themselves.

> **See:** [GUI containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html), automatic layout with VBox, HBox, Grid, and Margin containers.

> **See:** [Control node gallery](https://docs.godotengine.org/en/stable/tutorials/ui/control_node_gallery.html), visual catalog of all Control nodes.

## The DialogueLine Resource

Before building the UI, we need to define the data format for dialogue. We created a basic `NPCData` with `dialogue_lines: Array[String]` in Module 9. Now we'll make a proper dialogue line resource.

Create `res://resources/dialogue_line.gd`:

```gdscript
extends Resource
class_name DialogueLine
## A single line of dialogue with speaker information.

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
```

Now update `NPCData` in `res://resources/npc_data.gd` to use it:

```gdscript
extends Resource
class_name NPCData
## Data for a non-player character in the overworld.

@export var id: String = ""
@export var display_name: String = ""
@export var sprite_frames: SpriteFrames
@export var facing_direction: Vector2 = Vector2.DOWN

@export_group("Dialogue")
@export var dialogue: Array[DialogueLine] = []
```

The `dialogue` array replaces the old `dialogue_lines`. Update each NPC `.tres` file to use the new format:

1. Open the `.tres` file (e.g., `shopkeeper.tres`) in the Inspector.
2. The old `dialogue_lines` field will be gone (replaced by `dialogue`). Click the `dialogue` array.
3. Click **Add Element**. An empty slot appears.
4. Click the empty slot and choose **New DialogueLine**.
5. Expand the new DialogueLine and fill in `speaker_name` (e.g., "Merchant Hilda") and `text` (the dialogue line). Leave `portrait` empty for now.
6. Repeat for each line of dialogue.

> **Tip:** Creating sub-resources inside arrays can feel clunky at first. Each array element needs to be clicked, then "New DialogueLine" selected, then expanded to fill in fields. It's tedious but straightforward.

> **Spiral:** This is the Resource pattern from Module 9 in action. We define a data type (`DialogueLine`), use it in another Resource (`NPCData`), and the editor gives us a clean UI for editing dialogue without touching code.

## Building the Dialogue Box Scene

Create `res://ui/dialogue_box/dialogue_box.tscn`:

### Scene Tree

```
DialogueBox (CanvasLayer, layer = 10)
└── PanelContainer
    └── MarginContainer
        └── VBoxContainer
            ├── SpeakerLabel (Label)
            └── TextLabel (RichTextLabel)
```

### Node Configuration

**DialogueBox (CanvasLayer)**
- Layer: `10` (draws above the game world but below the SceneManager's transition overlay at layer 100)

**PanelContainer**
- Layout → **Anchor Preset**: choose "Bottom Wide" from the preset dropdown (at the top of the 2D viewport when a Control node is selected)
- "Bottom Wide" sets all anchors to 1.0, which pins the panel to the very bottom edge. We want it to take up the bottom 25% of the screen, so manually change the **Top** anchor from `1.0` to `0.75` in the Inspector under **Layout → Anchor Points**
- Final anchors: left=0, right=1, bottom=1, top=0.75

**MarginContainer**
- Under Theme Overrides → Constants, set margins: left=16, right=16, top=12, bottom=12

**SpeakerLabel (Label)**
- Text: "" (empty, filled at runtime)
- Horizontal Alignment: Left
- Add a bold font or increase font size to distinguish the speaker name

**TextLabel (RichTextLabel)**
- BBCode Enabled: `true`
- Fit Content: `true`
- Scroll Active: `false`
- Text: "" (empty, filled at runtime)

The result is a dark panel at the bottom of the screen with a speaker name on top and dialogue text below, the classic JRPG textbox.

## The Typewriter Effect

The typewriter effect reveals text character by character, as if being typed. This is a staple of JRPG dialogue and gives the player time to read along.

We achieve this by tweening `visible_ratio` on the RichTextLabel:

```gdscript
# visible_ratio goes from 0.0 (no text visible) to 1.0 (all text visible)
var tween := create_tween()
tween.tween_property(text_label, "visible_ratio", 1.0, duration)
```

Why `visible_ratio` and not `visible_characters`?

- **`visible_characters`** is an `int`, the number of characters shown. Tweening it produces discrete jumps (0 chars, 1 char, 2 chars). For short lines, this looks choppy.
- **`visible_ratio`** is a `float` from 0.0 to 1.0. Tweening it produces smooth character-by-character reveal at a consistent rate regardless of line length.

> **See:** [RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html), the `visible_ratio` and `visible_characters` properties.

> **See:** [BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html), formatting text with colors, bold, italics, and more.

## The Dialogue Box Script

Create `res://ui/dialogue_box/dialogue_box.gd`:

```gdscript
extends CanvasLayer
## Displays dialogue with a typewriter effect.

signal dialogue_started
signal dialogue_finished
signal line_advanced

@export var characters_per_second: float = 30.0

var _lines: Array[DialogueLine] = []
var _current_line_index: int = 0
var _is_typing: bool = false
var _current_tween: Tween = null

@onready var _panel: PanelContainer = $PanelContainer
@onready var _speaker_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerLabel
@onready var _text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/TextLabel


func _ready() -> void:
    _panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
    if not _panel.visible:
        return

    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
        get_viewport().set_input_as_handled()

        if _is_typing:
            # Skip the typewriter effect: show all text immediately
            _skip_typing()
        else:
            # Advance to the next line
            _advance()


func start_dialogue(lines: Array[DialogueLine]) -> void:
    if lines.is_empty():
        return

    _lines = lines
    _current_line_index = 0
    _panel.visible = true
    dialogue_started.emit()
    _show_current_line()


func _show_current_line() -> void:
    var line: DialogueLine = _lines[_current_line_index]

    _speaker_label.text = line.speaker_name
    _speaker_label.visible = line.speaker_name != ""
    _text_label.text = line.text
    _text_label.visible_ratio = 0.0

    _start_typing()


func _start_typing() -> void:
    _is_typing = true

    # Calculate duration based on text length and speed
    var char_count: int = _text_label.get_total_character_count()
    var duration: float = char_count / characters_per_second

    # Kill any existing tween before creating a new one
    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()

    _current_tween = create_tween()
    _current_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
    _current_tween.finished.connect(_on_typing_finished)


func _skip_typing() -> void:
    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()
    _text_label.visible_ratio = 1.0
    _is_typing = false


func _on_typing_finished() -> void:
    _is_typing = false


func _advance() -> void:
    _current_line_index += 1
    line_advanced.emit()

    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _close() -> void:
    _panel.visible = false
    _lines.clear()
    _current_line_index = 0
    dialogue_finished.emit()
```

### Key Design Points

**Two-press interaction:**
- First press while text is typing: **skip** to show all text immediately.
- Press when text is fully shown: **advance** to the next line or close.

This is the standard JRPG dialogue control. Players who read fast can skip ahead, while slow readers have time.

**Tween lifecycle management:**
```gdscript
if _current_tween and _current_tween.is_valid():
    _current_tween.kill()
```

Before creating a new tween, we kill any existing one. This prevents overlapping tweens if the player advances quickly. `create_tween()` tweens are automatically cleaned up when the creating node is freed, but we might create multiple tweens during a single dialogue sequence.

> **Warning:** A Tween stored in a variable can outlive its creating node if the variable is held elsewhere. In our case, `_current_tween` is a member of the dialogue box itself, so it's cleaned up when the box is freed. But be careful with Tweens passed between objects.

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html), the Tween API, including `kill()`, `is_valid()`, and chaining methods.

## Connecting Dialogue to NPCs

Now we'll wire the dialogue system into the game. Add the dialogue box to the scene.

### Option A: Instance in Each Scene

Add an instance of `dialogue_box.tscn` to each scene that needs dialogue (Willowbrook, Whisperwood, etc.).

### Option B: Make It an Autoload (Better)

Since dialogue can happen anywhere, it's a good candidate for global access. But instead of a full autoload, we can instance it in the SceneManager (which is already an autoload and has a CanvasLayer).

For simplicity, we'll use **Option A** for now: instance the dialogue box in Willowbrook. We can refactor to a global approach later.

Instance `dialogue_box.tscn` as a **direct child of the `Willowbrook` root node** (not inside YSortGroup). The scene script below references it as `$DialogueBox`, so the name must match exactly.

Replace the contents of `willowbrook.gd` (the Module 10 version with `print()` dialogue is now obsolete):

```gdscript
extends Node2D
## The town of Willowbrook, Crystal Saga's starting village.

@onready var _dialogue_box: CanvasLayer = $DialogueBox


func _ready() -> void:
    _dialogue_box.dialogue_finished.connect(_on_dialogue_finished)

    for npc in get_tree().get_nodes_in_group("npcs"):
        npc.interacted.connect(_on_npc_interacted)


func _on_npc_interacted(npc: CharacterBody2D) -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("start_interaction"):
        player.start_interaction()

    if npc.npc_data and not npc.npc_data.dialogue.is_empty():
        _dialogue_box.start_dialogue(npc.npc_data.dialogue)


func _on_dialogue_finished() -> void:
    var player := get_tree().get_first_node_in_group("player")
    if player and player.has_method("end_interaction"):
        player.end_interaction()
```

The flow:
1. Player presses interact near an NPC
2. NPC emits `interacted`
3. `willowbrook.gd` receives the signal
4. Player enters INTERACT state (frozen)
5. Dialogue box starts displaying lines
6. Player presses interact to advance through lines
7. When all lines are shown, `dialogue_finished` emits
8. Player returns to IDLE state

## Choice Dialogue (Branching)

Player choice is what separates a cutscene from a conversation. In Dragon Quest V, the game asks whether you want to marry Bianca or Nera, a choice that changes your party composition, your children's hair color, and NPC dialogue for the rest of the game. Even simple yes/no prompts like "Stay at the inn for 10 gold?" give the player agency.

Some dialogue needs player choices: "Yes/No" questions, multiple response options. We'll extend the system to support this.

First, **replace the entire contents of `res://resources/dialogue_line.gd`** with this updated version that adds a `choices` field:

```gdscript
extends Resource
class_name DialogueLine
## A single line of dialogue with speaker information and optional choices.

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var choices: Array[String] = []  # Empty = no choice, just advance
```

When `choices` is non-empty, instead of advancing on press, we show choice buttons.

Add a ChoiceContainer node to the dialogue box scene:

1. Open `dialogue_box.tscn`.
2. Select the **VBoxContainer** (the one containing SpeakerLabel and TextLabel).
3. Add a **VBoxContainer** child to it. Rename it to `ChoiceContainer`.
4. This is where choice buttons will appear dynamically.

Your updated scene tree:

```
DialogueBox (CanvasLayer)
└── PanelContainer
    └── MarginContainer
        └── VBoxContainer
            ├── SpeakerLabel (Label)
            ├── TextLabel (RichTextLabel)
            └── ChoiceContainer (VBoxContainer)
                # Buttons are added dynamically
```

Add the following to `dialogue_box.gd`: a new signal, a new `@onready` variable, and **replace** the existing `_show_current_line()` and `_advance()` methods with these updated versions. Also add the new `_show_choices()` and `_on_choice_pressed()` methods:

```gdscript
signal choice_made(choice_index: int)

@onready var _choice_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ChoiceContainer


func _show_current_line() -> void:
    var line: DialogueLine = _lines[_current_line_index]

    _speaker_label.text = line.speaker_name
    _speaker_label.visible = line.speaker_name != ""
    _text_label.text = line.text
    _text_label.visible_ratio = 0.0

    # Clear old choices
    for child in _choice_container.get_children():
        child.queue_free()
    _choice_container.visible = false

    _start_typing()


func _advance() -> void:
    var current_line: DialogueLine = _lines[_current_line_index]

    # If this line has choices, show them instead of advancing
    if not current_line.choices.is_empty() and _choice_container.get_child_count() == 0:
        _show_choices(current_line.choices)
        return

    _current_line_index += 1
    line_advanced.emit()

    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _show_choices(choices: Array[String]) -> void:
    _choice_container.visible = true

    for i in choices.size():
        var button := Button.new()
        button.text = choices[i]
        # .bind(i) attaches the value of i to the callback. When this button
        # is pressed, _on_choice_pressed receives i as its argument. Without
        # .bind(), we'd have no way to know which button was pressed.
        button.pressed.connect(_on_choice_pressed.bind(i))
        _choice_container.add_child(button)

    # Focus the first button for keyboard/gamepad navigation
    await get_tree().process_frame
    if _choice_container.get_child_count() > 0:
        _choice_container.get_child(0).grab_focus()


func _on_choice_pressed(index: int) -> void:
    choice_made.emit(index)
    _choice_container.visible = false

    # Clear choices and advance
    for child in _choice_container.get_children():
        child.queue_free()

    _current_line_index += 1
    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()
```

### The Complete `dialogue_box.gd`

After merging the base script with the choice additions, your complete file should look like this:

```gdscript
extends CanvasLayer
## Displays dialogue with a typewriter effect and optional choices.

signal dialogue_started
signal dialogue_finished
signal line_advanced
signal choice_made(choice_index: int)

@export var characters_per_second: float = 30.0

var _lines: Array[DialogueLine] = []
var _current_line_index: int = 0
var _is_typing: bool = false
var _current_tween: Tween = null

@onready var _panel: PanelContainer = $PanelContainer
@onready var _speaker_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerLabel
@onready var _text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/TextLabel
@onready var _choice_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ChoiceContainer


func _ready() -> void:
    _panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
    if not _panel.visible:
        return
    if _choice_container.visible:
        return  # Let the Button nodes handle input during choices

    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
        get_viewport().set_input_as_handled()

        if _is_typing:
            _skip_typing()
        else:
            _advance()


func start_dialogue(lines: Array[DialogueLine]) -> void:
    if lines.is_empty():
        return

    _lines = lines
    _current_line_index = 0
    _panel.visible = true
    dialogue_started.emit()
    _show_current_line()


func _show_current_line() -> void:
    var line: DialogueLine = _lines[_current_line_index]

    _speaker_label.text = line.speaker_name
    _speaker_label.visible = line.speaker_name != ""
    _text_label.text = line.text
    _text_label.visible_ratio = 0.0

    # Clear old choices
    for child in _choice_container.get_children():
        child.queue_free()
    _choice_container.visible = false

    _start_typing()


func _start_typing() -> void:
    _is_typing = true

    var char_count: int = _text_label.get_total_character_count()
    var duration: float = char_count / characters_per_second

    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()

    _current_tween = create_tween()
    _current_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
    _current_tween.finished.connect(_on_typing_finished)


func _skip_typing() -> void:
    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()
    _text_label.visible_ratio = 1.0
    _is_typing = false


func _on_typing_finished() -> void:
    _is_typing = false


func _advance() -> void:
    var current_line: DialogueLine = _lines[_current_line_index]

    if not current_line.choices.is_empty() and _choice_container.get_child_count() == 0:
        _show_choices(current_line.choices)
        return

    _current_line_index += 1
    line_advanced.emit()

    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _show_choices(choices: Array[String]) -> void:
    _choice_container.visible = true

    for i in choices.size():
        var button := Button.new()
        button.text = choices[i]
        button.pressed.connect(_on_choice_pressed.bind(i))
        _choice_container.add_child(button)

    await get_tree().process_frame
    if _choice_container.get_child_count() > 0:
        _choice_container.get_child(0).grab_focus()


func _on_choice_pressed(index: int) -> void:
    choice_made.emit(index)
    _choice_container.visible = false

    for child in _choice_container.get_children():
        child.queue_free()

    _current_line_index += 1
    if _current_line_index >= _lines.size():
        _close()
    else:
        _show_current_line()


func _close() -> void:
    _panel.visible = false
    _lines.clear()
    _current_line_index = 0
    dialogue_finished.emit()
```

> **Note:** In this basic implementation, choices don't affect what happens next; the dialogue continues linearly. In Module 20 (Quests), we'll connect choices to game flags that change story outcomes.

> **Note:** `grab_focus()` on the first button enables keyboard/gamepad navigation. Players can use up/down arrows to select and Enter/interact to confirm, no mouse needed. This is critical for JRPGs.

> **See:** [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html), how focus works for keyboard/gamepad UI navigation.

## Styling the Dialogue Box

The default PanelContainer looks plain. You can style it with a theme:

1. Select the PanelContainer.
2. In the Inspector, find **Theme Override → Styles → Panel**.
3. Create a **New StyleBoxFlat**.
4. Set:
   - **BG Color:** A dark blue or dark gray (e.g., `Color(0.1, 0.1, 0.2, 0.9)`)
   - **Border Width:** 2px on all sides
   - **Border Color:** White or light blue
   - **Corner Radius:** 4px for slightly rounded corners

This gives you the classic JRPG text box look. You can refine it later with custom fonts and themes.

## Freezing the Player During Dialogue

This is already handled by our state machine (Module 6). When `start_interaction()` is called, the player enters INTERACT state and stops processing input. When `end_interaction()` is called, the player returns to IDLE.

The dialogue box's `_unhandled_input` handles the interact/accept buttons for advancing text. Since the player's INTERACT state doesn't consume input events, the dialogue box can receive them normally.

## Engineering Contract

- **Global state:** None; the dialogue box is a UI scene controlled by its caller.
- **Public surface:** `start_dialogue(lines)`, `dialogue_finished`, and `choice_made`.
- **Invariant:** Input advances text only when the dialogue panel is visible and choices are not currently owning focus.
- **Failure behavior:** Empty dialogue arrays close cleanly instead of indexing past the end.
- **Copy semantics:** DialogueLine resources are read by the UI; transient UI state such as current line index stays inside the dialogue box.

## Engine Gotcha

Use `_unhandled_input()` for dialogue advance so UI buttons and focused choices get first chance to consume events. Otherwise the same accept press can both choose an option and advance the next line.

## What We've Learned

- **Control nodes** (PanelContainer, MarginContainer, VBoxContainer, Label, RichTextLabel) create responsive UI layouts.
- **CanvasLayer** renders UI on top of the game world at a specified layer.
- The **typewriter effect** uses `visible_ratio` (a float, tweened from 0.0 to 1.0) for smooth character reveal.
- **Two-press interaction:** first press skips typing, second press advances to the next line.
- **Choice dialogue** uses dynamically created Buttons with `grab_focus()` for keyboard navigation.
- **`DialogueLine`** is a Resource with speaker name, text, and optional choices, giving you clean data separation.
- **Tween lifecycle:** kill existing tweens before creating new ones. `create_tween()` tweens are auto-cleaned when the node is freed.
- `_unhandled_input()` respects UI focus: the dialogue box gets input events after UI buttons have had their chance.

## What You Should See

When you press F6 (running Willowbrook):
- Walk up to an NPC and press interact
- A dialogue box appears at the bottom of the screen
- The speaker's name is shown above the text
- Text appears character by character (typewriter effect)
- Press interact to skip the typing (text appears instantly)
- Press interact again to advance to the next line
- After the last line, the dialogue box disappears
- The player can move again

To test the choice system, edit one of your NPC `.tres` files (e.g., the innkeeper) and add `["Yes", "No"]` to the `choices` array on the last `DialogueLine`. When that line appears, two buttons should show up instead of auto-advancing. Selecting a choice dismisses the buttons and continues.

## Next Module

We have NPCs who talk. In **Module 12: The Inventory System**, we'll build an inventory the player can open with a menu key, display items in a grid, and use consumable items like potions. This is the first game system that requires both data (Resources from Module 9) and UI (patterns from this module) working together.


---

<!-- Source: 12_inventory_system.md -->

# Module 12: The Inventory System

## What We Have So Far

NPCs with a dialogue system, custom Resources for items and characters, scene transitions, and a connected two-area world. We've defined items like Potion and Iron Sword as `.tres` files, but the player can't actually carry or use them yet.

## What We're Building This Module

An inventory system with a global autoload for tracking items, a UI screen the player can open with a key, and the ability to use consumable items. We'll keep this focused; equipment and shops come in Module 21.

Inventory management is one of the defining verbs of the RPG genre. In Pokemon, deciding which six Pokemon to carry and which four moves each one knows is the core strategic layer. In Final Fantasy, choosing whether to spend your last Elixir on a random battle or save it for the boss creates tension that persists between fights. An inventory isn't just a list of stuff. It's a resource management puzzle that runs throughout the entire game.

## InventoryManager Autoload

The inventory needs to persist across scene changes, so it's an autoload.

Create `res://autoloads/inventory_manager.gd`:

```gdscript
extends Node
## Manages the player's inventory. Autoload, accessible as InventoryManager.

signal item_added(item: ItemData, new_count: int)
signal item_removed(item: ItemData, new_count: int)
signal inventory_changed
signal gold_changed(new_amount: int)

var gold: int = 100  # Starting gold
var _items: Array[Dictionary] = []  # [{item: ItemData, count: int}]


func add_item(item: ItemData, amount: int = 1) -> void:
    if amount <= 0:
        return

    for entry in _items:
        if entry.item.id == item.id:
            entry.count += amount
            item_added.emit(item, entry.count)
            inventory_changed.emit()
            return

    _items.append({item = item, count = amount})
    item_added.emit(item, amount)
    inventory_changed.emit()


func remove_item(item: ItemData, amount: int = 1) -> bool:
    if amount <= 0:
        return false

    for i in _items.size():
        if _items[i].item.id == item.id:
            var entry: Dictionary = _items[i]
            if entry.count < amount:
                return false

            entry.count -= amount
            var remaining: int = entry.count
            if remaining <= 0:
                _items.remove_at(i)
                remaining = 0
            else:
                _items[i] = entry
            item_removed.emit(item, remaining)
            inventory_changed.emit()
            return true
    return false


func has_item(item_id: String, amount: int = 1) -> bool:
    for entry in _items:
        if entry.item.id == item_id and entry.count >= amount:
            return true
    return false


func get_item_count(item_id: String) -> int:
    for entry in _items:
        if entry.item.id == item_id:
            return entry.count
    return 0


func get_all_items() -> Array[Dictionary]:
    return _items.duplicate(true)


func get_consumables() -> Array[Dictionary]:
    return _items.filter(
        func(entry: Dictionary) -> bool:
            return entry.item.item_type == ItemData.ItemType.CONSUMABLE
    ).duplicate(true)


func add_gold(amount: int) -> void:
    gold += amount
    gold_changed.emit(gold)


func spend_gold(amount: int) -> bool:
    if gold >= amount:
        gold -= amount
        gold_changed.emit(gold)
        return true
    return false
```

Register it as an autoload: **Project → Project Settings → Autoload** → add `inventory_manager.gd` as `InventoryManager`.

### Design Notes

**Signal-driven updates:** Every change emits a signal (`item_added`, `item_removed`, `inventory_changed`, `gold_changed`). The UI listens to these signals and updates itself. The InventoryManager never touches UI directly.

**ID-based matching:** Items are matched by their `id` string (`item.id == item_id`), not by object reference. This means two different `ItemData` instances with the same `id` are treated as the same item, which is important when loading from saves.

**`remove_item` returns bool:** Callers can check if the removal succeeded. Trying to remove an item the player doesn't have returns `false`.

**Autoload reference card:**

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| **InventoryManager** | **12** | **Item storage, add/remove, signals** |

## Adding a Menu Input Action

Before building the UI, define a `menu` action for opening the inventory:

1. **Project → Project Settings → Input Map**
2. Add a new action: `menu`
3. Bind it to **Tab** (or **I**) and the **Start/Menu** gamepad button

> **Note:** Avoid binding `menu` to Escape. Escape is already mapped to `ui_cancel`, which we'll use to *close* the inventory. Using the same key for both open and close works thanks to our `elif` structure in the script, but using different keys (Tab to open, Escape to close) is clearer and avoids confusion.

## The Inventory UI

Create `res://ui/inventory/inventory_screen.tscn`:

### Scene Tree

```
InventoryScreen (CanvasLayer, layer = 20)
└── PanelContainer (full screen, semi-transparent background)
    └── MarginContainer
        └── VBoxContainer
            ├── Header (HBoxContainer)
            │   ├── TitleLabel (Label: "Inventory")
            │   └── GoldLabel (Label: "Gold: 100")
            ├── ItemGrid (GridContainer, columns = 5)
            │   # ItemSlot scenes instanced here dynamically
            └── DescriptionLabel (RichTextLabel)
```

### The Item Slot Scene

Each slot in the grid is its own small scene. Create `res://ui/inventory/item_slot.tscn`:

```
ItemSlot (PanelContainer)
├── MarginContainer
│   └── VBoxContainer
│       ├── Icon (TextureRect)
│       └── CountLabel (Label)
```

Select the `Icon` (TextureRect) node and set **Custom Minimum Size** to `Vector2(32, 32)` so each slot has a reasonable size even without an icon texture.

> **Note:** Since we haven't set item icons in our `.tres` files yet, the inventory slots will show blank icon areas. That's expected. You'll see the count label (e.g., "3" for potions). To add placeholder icons, drag `res://icon.svg` into the `icon` field of each item `.tres` file.

Create `res://ui/inventory/item_slot.gd`:

```gdscript
extends PanelContainer
## A single item slot in the inventory grid.

signal slot_selected(item: ItemData)
signal slot_activated(item: ItemData)

var item_data: ItemData
var count: int = 0

@onready var _icon: TextureRect = $MarginContainer/VBoxContainer/Icon
@onready var _count_label: Label = $MarginContainer/VBoxContainer/CountLabel


func setup(item: ItemData, item_count: int) -> void:
    item_data = item
    count = item_count
    _icon.texture = item.icon
    _count_label.text = str(item_count) if item_count > 1 else ""

    # Make the slot focusable for keyboard/gamepad navigation
    focus_mode = Control.FOCUS_ALL


func _gui_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
        slot_activated.emit(item_data)
        accept_event()


func _notification(what: int) -> void:
    if what == NOTIFICATION_FOCUS_ENTER:
        slot_selected.emit(item_data)
```

> **See:** [TextureRect](https://docs.godotengine.org/en/stable/classes/class_texturerect.html): displaying images in UI.

> **See:** [GridContainer](https://docs.godotengine.org/en/stable/classes/class_gridcontainer.html): automatic grid layout for child nodes.

### The Inventory Screen Script

Create `res://ui/inventory/inventory_screen.gd`:

```gdscript
extends CanvasLayer
## The inventory screen. Opens/closes with the menu key.

const ItemSlotScene := preload("res://ui/inventory/item_slot.tscn")

@onready var _panel: PanelContainer = $PanelContainer
@onready var _item_grid: GridContainer = $PanelContainer/MarginContainer/VBoxContainer/ItemGrid
@onready var _gold_label: Label = $PanelContainer/MarginContainer/VBoxContainer/Header/GoldLabel
@onready var _description_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel

var _is_open: bool = false


func _ready() -> void:
    _panel.visible = false
    InventoryManager.inventory_changed.connect(_refresh)
    InventoryManager.gold_changed.connect(_on_gold_changed)
    _update_gold_display()


func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel") and _is_open:
        close()
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("menu") and not _is_open:
        open()
        get_viewport().set_input_as_handled()


func open() -> void:
    _show()


func open_from_pause() -> void:
    _show()


func _show() -> void:
    _is_open = true
    _panel.visible = true
    get_tree().paused = true
    _refresh()


func close() -> void:
    _is_open = false
    _panel.visible = false
    get_tree().paused = false


func _refresh() -> void:
    # free() removes nodes immediately this frame. queue_free() defers removal
    # to the end of the frame. When repopulating a container, free() prevents
    # old and new children from briefly coexisting and causing layout flicker.
    for child in _item_grid.get_children():
        child.free()

    # Create slots for each item
    var items := InventoryManager.get_all_items()
    for entry in items:
        var slot: PanelContainer = ItemSlotScene.instantiate()
        _item_grid.add_child(slot)
        slot.setup(entry.item, entry.count)
        slot.slot_selected.connect(_on_slot_selected)
        slot.slot_activated.connect(_on_slot_activated)

    # Focus the first slot (deferred so the slot is ready)
    if _item_grid.get_child_count() > 0:
        _item_grid.get_child(0).call_deferred("grab_focus")


func _on_slot_selected(item: ItemData) -> void:
    _description_label.text = item.description


func _on_slot_activated(item: ItemData) -> void:
    if item.item_type == ItemData.ItemType.CONSUMABLE:
        _use_consumable(item)


func _use_consumable(item: ItemData) -> void:
    # For now, apply directly to a placeholder HP value
    # In Module 21, this will apply to the selected party member
    if item.hp_restore > 0:
        print("Restored ", item.hp_restore, " HP!")
    if item.mp_restore > 0:
        print("Restored ", item.mp_restore, " MP!")
    InventoryManager.remove_item(item)


func _update_gold_display() -> void:
    _gold_label.text = "Gold: " + str(InventoryManager.gold)


func _on_gold_changed(_amount: int) -> void:
    _update_gold_display()
```

`open()` and `open_from_pause()` intentionally go through the same `_show()` helper. Module 25's PauseMenu will call the public API instead of toggling `visible` directly, so the inventory always refreshes its slots, tracks `_is_open`, and owns the pause state the same way no matter how it was opened.

## Pausing the Game

When you open the menu in any Final Fantasy game, the world freezes. Enemies stop moving, timers stop counting, and the music continues. This isn't just a convenience; it's a promise to the player: "You are safe while making decisions." Without pausing, an enemy could kill you while you're scrolling through your item list.

When the inventory opens, we **pause the game** so enemies, NPCs, and the player don't move while the menu is up.

```gdscript
get_tree().paused = true   # Pause everything
get_tree().paused = false  # Resume everything
```

But wait: if everything is paused, how does the inventory UI itself continue to work? Through **`process_mode`**.

Every node has a `process_mode` property that controls whether it runs while paused:

| Mode | Behavior |
|------|----------|
| `PROCESS_MODE_INHERIT` | Same as parent (default) |
| `PROCESS_MODE_PAUSABLE` | Pauses when tree is paused |
| `PROCESS_MODE_WHEN_PAUSED` | Only runs when tree is paused |
| `PROCESS_MODE_ALWAYS` | Always runs, regardless of pause state |
| `PROCESS_MODE_DISABLED` | Never runs |

> **IMPORTANT:** Select the `InventoryScreen` (CanvasLayer) root node in the editor and set **Process → Mode** to **`Always`** in the Inspector. Without this, the inventory will open but immediately freeze because the paused game prevents it from processing input. The only way to recover would be to force-quit.

The SceneManager should also be `PROCESS_MODE_ALWAYS`. Go back to `scene_manager.tscn` and set its root node's **Process → Mode** to **`Always`** too. It needs to work during transitions regardless of pause state.

> **See:** [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html): the official guide to pausing and `process_mode`.

## Giving the Player Starting Items

To test the inventory, give the player some starting items. In `InventoryManager._ready()`:

```gdscript
func _ready() -> void:
    # Starting inventory for testing
    var potion: ItemData = load("res://data/items/potion.tres")
    if potion:
        add_item(potion, 3)
```

Or better, add items through game events. For now, the starting items are fine for testing.

## Integration: Adding the Inventory to Scenes

Add the inventory screen to each scene:

1. Open `willowbrook.tscn`. Right-click the root `Willowbrook` node → **Instance Child Scene** → select `res://ui/inventory/inventory_screen.tscn`.
2. Repeat for `whisperwood.tscn`.

Your scene tree should look like:

```
Willowbrook (Node2D)
├── Ground (TileMapLayer)
├── Detail (TileMapLayer)
├── YSortGroup (Node2D)
│   ├── Objects (TileMapLayer)
│   ├── Player
│   ├── Shopkeeper (NPC)
│   ├── Innkeeper (NPC)
│   └── Traveler (NPC)
├── AbovePlayer (TileMapLayer)
├── DialogueBox (CanvasLayer)
└── InventoryScreen (CanvasLayer)
```

## Engineering Contract

- **Global state:** `InventoryManager` owns item stacks and gold as an autoload.
- **Public surface:** `add_item()`, `remove_item()`, `use_item()`, `get_all_items()`, `get_consumables()`, and inventory/gold signals.
- **Invariant:** Stack counts never go below zero; removal fails before mutation when the amount is invalid or unavailable.
- **Failure behavior:** Missing items, insufficient quantities, and non-positive amounts return `false`.
- **Copy semantics:** List getters return defensive array/dictionary copies; `ItemData` Resources inside entries remain shared definitions.

## Engine Gotcha

Autoload arrays are just normal mutable arrays. Returning the live array would let UI code accidentally mutate inventory internals, so read APIs return copies.

## What We've Learned

- **InventoryManager** autoload tracks items as `{item: ItemData, count: int}` entries with signal-driven updates.
- **Pausing** (`get_tree().paused = true`) freezes game logic. **`process_mode = ALWAYS`** lets UI continue during pause.
- **ItemSlot** scenes are instantiated dynamically in a **GridContainer** to form the inventory grid.
- **Focus-based navigation** (`focus_mode`, `grab_focus()`) makes UI work with keyboard and gamepad.
- **Signal pattern:** InventoryManager emits `inventory_changed` → UI refreshes. Manager never touches UI directly.
- **`_gui_input()`** handles input events on Control nodes. **`accept_event()`** prevents propagation (like `set_input_as_handled()` for UI).
- Items are consumed with `remove_item()`, and the grid refreshes automatically via the `inventory_changed` signal.

### Troubleshooting

| Problem | Likely Cause |
|---------|-------------|
| Inventory doesn't open when pressing Tab | `menu` input action not defined, or key not bound |
| Game freezes when inventory opens | `process_mode` not set to `Always` on the InventoryScreen CanvasLayer |
| Items stacking incorrectly or showing wrong item | Missing or duplicate `id` fields in `.tres` files (see Module 9) |
| Slots appear too small or empty | No icon set on items (expected; use Godot icon as placeholder), or TextureRect missing minimum size |
| Escape doesn't close inventory | `ui_cancel` not mapped to Escape (it is by default) |

## What You Should See

When you press F6 (running Willowbrook):
- Press Tab (or your menu key). The inventory screen opens
- The game world freezes behind the menu
- Items appear in a grid (3 Potions from starting inventory). Icons may be blank if you haven't set them
- Navigating slots with arrow keys highlights them and shows descriptions
- Pressing accept on a Potion uses it and decrements the count
- Pressing Escape closes the inventory and resumes the game

## Next Module

We have items and NPCs and dialogue. Now it's time for the biggest system in any JRPG: **combat**. In **Module 14: Battle Foundations**, we'll build the battle scene, implement a node-based state machine for battle flow, and create the turn order system. Combat is next.


---

<!-- Source: 13_part_iii_review.md -->

# Module 13: Part III Review and Cheat Sheet

This module is a review and quick-reference for everything covered in Part III (Modules 9-12). No new code here. Just a consolidated reference you can come back to when you need to remember how something works.

## Part III in Review

Part III is where Crystal Saga went from a world you walk through to a world you interact with. The central change was separating **data from logic** using Godot's Resource system. Instead of hardcoding item stats, NPC names, and dialogue text inside scripts, we defined structured data types (Resource classes), created instances of those types (`.tres` files), and wrote systems that consume the data without caring about specific values. This pattern (define a Resource class, populate `.tres` files, wire them into scripts) will repeat in every system we build from here forward.

With the data layer in place, we built three interconnected systems on top of it. NPCs use `NPCData` resources to configure their appearance and dialogue. The dialogue system reads `DialogueLine` resources and renders them in a typewriter-style textbox. The inventory system tracks `ItemData` resources and displays them in a navigable grid. Each system is decoupled from the others through signals: the NPC does not know about the dialogue box, the dialogue box does not know about the inventory, and the inventory does not know about either. They communicate through emit-and-connect wiring in the scene scripts.

The result is a working game architecture. Resources for data, signals for communication, autoloads for persistence, Control nodes for UI. These same patterns show up in the battle system, quest system, save/load, and everything else we build in the remaining parts. If any of these concepts feel shaky, this is a good place to review before moving into Part IV.

### Module 9: Resources, the Data Layer

- Learned that **Resources** are Godot's universal data container: type-safe, editor-friendly objects that can be saved as `.tres` files and shared across the project.
- Defined three custom Resource classes (`ItemData`, `CharacterData`, `NPCData`) using `class_name`, `@export`, `@export_group()`, `@export_multiline`, and enum-typed exports.
- Created `.tres` data files in the Inspector for potions, equipment, and the hero's stats, filling in typed fields through dropdown menus and text editors instead of writing raw data.
- Established the **three-file pattern**: a Resource class (`.gd`) defines the structure, a `.tres` file holds specific values, and a consumer script uses the data at runtime.
- Learned when to use `preload()` (compile-time, constant paths, no null check needed) versus `load()` (runtime, dynamic paths, always null-check the result).

### Module 10: NPCs and Interaction

- Built a reusable NPC scene (`CharacterBody2D` + `AnimatedSprite2D` + `Area2D` + `Label`) driven by an `@export var npc_data: NPCData`. Swapping the resource changes the NPC's identity without changing the script.
- Implemented the **Area2D interaction pattern**: the NPC's `InteractionZone` detects the player via `body_entered`/`body_exited` signals, toggles an interaction prompt, and listens for the `interact` input action.
- Used `_unhandled_input()` instead of `_input()` or `_process()` polling, so the NPC only responds to input that UI elements have not already consumed, and called `set_input_as_handled()` to prevent other nodes from double-processing the same press.
- Connected NPC signals to scene scripts (`willowbrook.gd`) to demonstrate **separation of concerns**: the NPC detects interaction and emits a signal; the scene script decides what to do with it.
- Defined a custom `interact` input action in Project Settings so the same code works for keyboard and gamepad.

### Module 11: The Dialogue System

- Created the `DialogueLine` Resource (speaker name, text, optional portrait, optional choices) and upgraded `NPCData` from `Array[String]` to `Array[DialogueLine]` for structured dialogue data.
- Built a dialogue box UI scene using **Control nodes** (`CanvasLayer` > `PanelContainer` > `MarginContainer` > `VBoxContainer` > `Label` + `RichTextLabel`) with anchors and containers for responsive layout.
- Implemented the **typewriter effect** by tweening `RichTextLabel.visible_ratio` from `0.0` to `1.0`, with proper tween lifecycle management (kill before creating a new one).
- Added the **two-press interaction** pattern (first press skips typing, second press advances or closes), the standard JRPG dialogue control.
- Extended dialogue with **branching choices**: dynamically creating `Button` nodes in a `ChoiceContainer`, using `grab_focus()` for keyboard navigation, and emitting `choice_made` signals.

### Module 12: The Inventory System

- Created the **InventoryManager autoload** to persist items across scene changes, tracking items as `{item: ItemData, count: int}` dictionaries matched by `item.id`.
- Built a signal-driven architecture: InventoryManager emits `item_added`, `item_removed`, `inventory_changed`, and `gold_changed`. The UI listens and refreshes, and the manager never touches UI directly.
- Constructed the inventory UI with dynamically instanced `ItemSlot` scenes in a `GridContainer`, each slot emitting `slot_selected` and `slot_activated` signals for description display and item use.
- Learned how **pausing** works: `get_tree().paused = true` freezes the game world, while `process_mode = PROCESS_MODE_ALWAYS` on the inventory's CanvasLayer lets the menu continue to function.
- Used `_gui_input()` and `accept_event()` for Control-node input handling, and `focus_mode = FOCUS_ALL` with `grab_focus()` for keyboard/gamepad-navigable item slots.

## Key Concepts

| Concept | What It Is | Why It Matters | First Seen |
|---------|-----------|---------------|------------|
| Custom Resource class | A GDScript file extending `Resource` with `class_name` and `@export` properties | Defines a reusable, type-safe data structure editable in the Inspector | Module 9 |
| `.tres` file | A text-based Resource instance saved to disk | Holds specific data values (one potion, one sword) separate from code | Module 9 |
| Three-file pattern | Resource class `.gd` + data `.tres` + consumer `.gd` | Separates structure, data, and behavior so each can change independently | Module 9 |
| `preload()` vs `load()` | Compile-time vs runtime resource loading | `preload` for known assets, `load` for dynamic paths (with null check) | Module 9 |
| Null-check pattern | `if resource == null: push_error(...)` after `load()` | Prevents silent crashes from missing or mistyped file paths | Module 9 |
| Area2D interaction zone | A collision area larger than the NPC body | Detects when the player is close enough to interact | Module 10 |
| `_unhandled_input()` | Input callback that fires only if no other node consumed the event | Respects UI focus; prevents game-world input from firing during menus | Module 10 |
| `set_input_as_handled()` | Marks an input event as consumed | Prevents multiple nodes from responding to the same button press | Module 10 |
| Custom input actions | Named actions (e.g., `interact`, `menu`) defined in Project Settings | Decouples game logic from specific keys; supports keyboard and gamepad | Module 10 |
| CanvasLayer | A node that renders its children on a separate drawing layer | Draws UI on top of the game world regardless of camera position | Module 11 |
| `visible_ratio` | A float (0.0 to 1.0) controlling how much of a RichTextLabel's text is shown | Powers the typewriter effect via tweening | Module 11 |
| Tween lifecycle | Creating, chaining, killing, and checking validity of Tweens | Prevents overlapping animations when the player advances dialogue quickly | Module 11 |
| `grab_focus()` | Programmatically gives keyboard/gamepad focus to a Control node | Makes UI navigable without a mouse, which is critical for JRPGs | Module 11 |
| Autoload | A node auto-instanced at startup, accessible globally by name | Persists data (inventory, gold) across scene changes | Module 12 |
| `process_mode` | Controls whether a node runs during pause | Lets the inventory UI function while the game world is frozen | Module 12 |
| `_gui_input()` | Input callback specific to Control nodes | Handles button presses, focus changes, and mouse events on UI elements | Module 12 |
| Signal-driven UI updates | Manager emits signals; UI listens and refreshes itself | Keeps the data layer and presentation layer fully decoupled | Module 12 |

## Cheat Sheet

### Custom Resource Classes

Define a class:

```gdscript
# res://resources/item_data.gd
extends Resource
class_name ItemData
## Data definition for an inventory item.

enum ItemType { CONSUMABLE, EQUIPMENT, KEY_ITEM }

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.CONSUMABLE

@export_group("Consumable Effects")
@export var hp_restore: int = 0
@export var mp_restore: int = 0
```

Create an instance in code (for testing):

```gdscript
var potion := ItemData.new()
potion.id = "potion"
potion.display_name = "Potion"
potion.hp_restore = 50
```

Create an instance in the editor: right-click a folder in the FileSystem dock, select **New Resource**, search for `ItemData`, click **Create**, name the file, and fill in the exported fields in the Inspector.

Load a `.tres` file at compile time:

```gdscript
const POTION := preload("res://data/items/potion.tres")
```

Load a `.tres` file at runtime (dynamic path):

```gdscript
var item: ItemData = load("res://data/items/" + item_id + ".tres") as ItemData
if item == null:
    push_error("Failed to load item: " + item_id)
    return
```

Duplicate to avoid shared-reference mutations:

```gdscript
var my_copy: ItemData = shared_item.duplicate()
my_copy.hp_restore = 99  # Only affects the copy
```

### The Resource Pattern (Data vs Logic)

The point: separate **what the data is** from **what the code does with it**.

```
resources/item_data.gd        : defines the shape (fields, types, enums)
data/items/potion.tres        : holds specific values (Potion, 50 HP, 25 gold)
autoloads/inventory_manager.gd: manages a collection of items at runtime
```

This separation means:
- **Game designers** (or future you) can tweak values in the Inspector without touching code.
- **Consumer scripts** work with any `ItemData`; they do not care whether it is a potion or a sword.
- **Resource classes** change rarely; data instances change often. Changes to data never break code.

The same pattern applies everywhere: `CharacterData` for stats, `NPCData` for NPC configuration, `DialogueLine` for dialogue content.

### Area2D Interaction Pattern

The NPC's `InteractionZone` (an `Area2D` with a `CollisionShape2D` larger than the NPC's body) detects proximity:

```gdscript
# In the NPC script
@onready var _interaction_zone: Area2D = $InteractionZone
@onready var _interaction_prompt: Label = $InteractionPrompt

var _player_in_range: bool = false


func _ready() -> void:
    _interaction_zone.body_entered.connect(_on_player_entered)
    _interaction_zone.body_exited.connect(_on_player_exited)
    _interaction_prompt.visible = false


func _on_player_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _interaction_prompt.visible = true


func _on_player_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _interaction_prompt.visible = false
```

Then handle input only when in range:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range:
        return

    if event.is_action_pressed("interact"):
        _face_player()
        get_viewport().set_input_as_handled()
        interacted.emit(self)
```

The key points: use `_unhandled_input()` (not `_input()` or `_process()` polling), check the `_player_in_range` flag, call `set_input_as_handled()` to prevent other nodes from also reacting, and emit a signal instead of performing the action directly.

### NPC Architecture

The NPC scene tree:

```
NPC (CharacterBody2D)
├── Sprite (AnimatedSprite2D)
├── CollisionShape2D           : small, feet-only (makes the NPC solid)
├── InteractionZone (Area2D)
│   └── InteractionShape       : large circle (~24px radius, detection range)
└── InteractionPrompt (Label)  : "!" text, hidden by default
```

The NPC is driven by data, not hardcoded values:

```gdscript
@export var npc_data: NPCData

func _apply_npc_data() -> void:
    if npc_data.sprite_frames:
        _sprite.sprite_frames = npc_data.sprite_frames

    var dir_name := _direction_to_string(npc_data.facing_direction)
    var idle_anim := "idle_" + dir_name
    if _sprite.sprite_frames and _sprite.sprite_frames.has_animation(idle_anim):
        _sprite.play(idle_anim)
```

Different `NPCData` `.tres` files produce different NPCs from the same scene. The scene script (`willowbrook.gd`) wires the NPC's `interacted` signal to game systems like dialogue.

### The Dialogue System

**Data format:** a `DialogueLine` Resource per line of conversation:

```gdscript
extends Resource
class_name DialogueLine

@export var speaker_name: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var choices: Array[String] = []
```

**Starting dialogue:** pass an array of `DialogueLine` resources:

```gdscript
_dialogue_box.start_dialogue(npc.npc_data.dialogue)
```

**Typewriter effect:** tween `visible_ratio` on a `RichTextLabel`:

```gdscript
func _start_typing() -> void:
    _is_typing = true
    var char_count: int = _text_label.get_total_character_count()
    var duration: float = char_count / characters_per_second

    if _current_tween and _current_tween.is_valid():
        _current_tween.kill()

    _current_tween = create_tween()
    _current_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
    _current_tween.finished.connect(_on_typing_finished)
```

**Two-press input:** skip typing on first press, advance on second:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if not _panel.visible:
        return
    if _choice_container.visible:
        return
    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
        get_viewport().set_input_as_handled()
        if _is_typing:
            _skip_typing()
        else:
            _advance()
```

**Branching choices:** dynamically create buttons when a `DialogueLine` has choices:

```gdscript
func _show_choices(choices: Array[String]) -> void:
    _choice_container.visible = true
    for i in choices.size():
        var button := Button.new()
        button.text = choices[i]
        button.pressed.connect(_on_choice_pressed.bind(i))
        _choice_container.add_child(button)

    await get_tree().process_frame
    if _choice_container.get_child_count() > 0:
        _choice_container.get_child(0).grab_focus()
```

**Signal flow** for a complete dialogue interaction:

```
Player presses interact near NPC
  -> NPC emits interacted(self)
  -> Scene script calls player.start_interaction() and dialogue_box.start_dialogue()
  -> DialogueBox emits dialogue_started
  -> [Player advances through lines]
  -> DialogueBox emits dialogue_finished
  -> Scene script calls player.end_interaction()
```

### RichTextLabel and BBCode

[`RichTextLabel`](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html) is a text display node that supports BBCode formatting. Enable it by setting `bbcode_enabled = true` in the Inspector.

Common tags for dialogue:

| BBCode | Effect | Example |
|--------|--------|---------|
| `[b]...[/b]` | Bold | `[b]Important[/b]` |
| `[i]...[/i]` | Italic | `[i]whispers[/i]` |
| `[color=red]...[/color]` | Text color | `[color=red]Danger![/color]` |
| `[wave]...[/wave]` | Wavy text animation | `[wave]magical energy[/wave]` |
| `[shake]...[/shake]` | Shaking text | `[shake]earthquake![/shake]` |

These tags work inside `DialogueLine.text` and render correctly with the typewriter effect because `visible_ratio` reveals already-formatted text.

Key `RichTextLabel` properties:

- `bbcode_enabled`: must be `true` for tags to render
- `visible_ratio`: float 0.0 to 1.0, controls how much text is visible (used for typewriter)
- `visible_characters`: int, same idea but discrete (we use `visible_ratio` for smoother tweening)
- `fit_content`: auto-sizes the node to fit the text
- `scroll_active`: set to `false` for dialogue boxes (we handle paging manually)

### Inventory System Architecture

**InventoryManager** (autoload), which tracks items and emits signals:

```gdscript
signal item_added(item: ItemData, new_count: int)
signal item_removed(item: ItemData, new_count: int)
signal inventory_changed
signal gold_changed(new_amount: int)

var gold: int = 100
var _items: Array[Dictionary] = []  # [{item: ItemData, count: int}]
```

**Core operations:**

```gdscript
# Add items
InventoryManager.add_item(potion, 3)

# Remove items (returns false if player doesn't have enough)
var success: bool = InventoryManager.remove_item(potion, 1)

# Check for items
if InventoryManager.has_item("potion", 2):
    print("Player has at least 2 potions")

# Get count
var count: int = InventoryManager.get_item_count("potion")

# Get filtered lists
var consumables: Array[Dictionary] = InventoryManager.get_consumables()

# Gold management
InventoryManager.add_gold(50)
var could_afford: bool = InventoryManager.spend_gold(100)
```

**ID-based matching:** items are matched by their `id` string, not by object reference. Two different `ItemData` objects with `id = "potion"` are treated as the same item. Always set unique `id` values on `.tres` files.

### UI Patterns for Lists

The inventory uses a common pattern for displaying dynamic lists of data in Godot UI:

**Container hierarchy:**

```
PanelContainer (background)
└── MarginContainer (padding)
    └── VBoxContainer (vertical stack)
        ├── Header (HBoxContainer)
        │   ├── TitleLabel
        │   └── GoldLabel
        ├── ItemGrid (GridContainer, columns = 5)
        │   # Slots instanced dynamically
        └── DescriptionLabel (RichTextLabel)
```

**Dynamic slot creation:** clear old slots, create new ones from data:

```gdscript
const ItemSlotScene := preload("res://ui/inventory/item_slot.tscn")

func _refresh() -> void:
    # Clear existing slots immediately (free, not queue_free)
    for child in _item_grid.get_children():
        child.free()

    # Create a slot for each inventory entry
    var items := InventoryManager.get_all_items()
    for entry in items:
        var slot: PanelContainer = ItemSlotScene.instantiate()
        _item_grid.add_child(slot)
        slot.setup(entry.item, entry.count)
        slot.slot_selected.connect(_on_slot_selected)
        slot.slot_activated.connect(_on_slot_activated)

    # Focus the first slot for keyboard navigation
    if _item_grid.get_child_count() > 0:
        _item_grid.get_child(0).call_deferred("grab_focus")
```

Why `free()` instead of `queue_free()`: when refreshing a list, you want the old children gone immediately so the new children appear in a clean container. `queue_free()` defers removal to the end of the frame, which can cause brief visual glitches where old and new slots overlap.

**Pausing the game while the menu is open:**

```gdscript
func open() -> void:
    _is_open = true
    _panel.visible = true
    get_tree().paused = true   # Freeze the game world
    _refresh()

func close() -> void:
    _is_open = false
    _panel.visible = false
    get_tree().paused = false  # Resume the game world
```

Set `process_mode = PROCESS_MODE_ALWAYS` on the InventoryScreen's root `CanvasLayer` node in the Inspector. Without this, the menu itself will freeze along with everything else.

### Signal Patterns Recap

Part III introduced several signal patterns. Here is every signal connection used across Modules 9-12:

**NPC interaction (Module 10):**

```gdscript
# NPC detects player proximity
_interaction_zone.body_entered.connect(_on_player_entered)
_interaction_zone.body_exited.connect(_on_player_exited)

# NPC emits when player presses interact
signal interacted(npc: CharacterBody2D)

# Scene script connects all NPCs in a group
for npc in get_tree().get_nodes_in_group("npcs"):
    npc.interacted.connect(_on_npc_interacted)
```

**Dialogue events (Module 11):**

```gdscript
# Dialogue box lifecycle signals
signal dialogue_started
signal dialogue_finished
signal line_advanced
signal choice_made(choice_index: int)

# Scene script connects to dialogue_finished for cleanup
_dialogue_box.dialogue_finished.connect(_on_dialogue_finished)
```

**Inventory changes (Module 12):**

```gdscript
# InventoryManager emits on every change
signal item_added(item: ItemData, new_count: int)
signal item_removed(item: ItemData, new_count: int)
signal inventory_changed
signal gold_changed(new_amount: int)

# UI subscribes in _ready()
InventoryManager.inventory_changed.connect(_refresh)
InventoryManager.gold_changed.connect(_on_gold_changed)
```

**Item slot UI (Module 12):**

```gdscript
# Each slot emits when focused or activated
signal slot_selected(item: ItemData)
signal slot_activated(item: ItemData)

# Inventory screen connects after instancing each slot
slot.slot_selected.connect(_on_slot_selected)
slot.slot_activated.connect(_on_slot_activated)
```

The consistent pattern: the object that **knows something happened** emits a signal. The object that **needs to respond** connects to that signal. Neither needs a reference to the other's internals.

## Common Mistakes and Fixes

| Mistake | Symptom | Fix |
|---------|---------|-----|
| Forgetting `class_name` on a Resource class | The type does not appear in "New Resource" dialog or `@export` type hints | Add `class_name YourType` on the second line of the `.gd` file, then re-save |
| Using `load()` without a null check | Game crashes with a null-reference error when a path is wrong | Always check: `var res = load(path) as Type` then `if res == null: push_error(...)` |
| Duplicate or empty `id` fields on `.tres` files | Items stack incorrectly in inventory; wrong item gets removed | Give every `.tres` file a unique `id` that matches the filename (e.g., `"potion"` for `potion.tres`) |
| Not setting `process_mode` to `Always` on the inventory CanvasLayer | Game freezes permanently when the inventory opens (pause locks the menu too) | Select the InventoryScreen root node in the editor, set **Process > Mode** to **Always** |
| Using `_input()` instead of `_unhandled_input()` for NPC interaction | Interact button fires even when a UI menu is open | Switch to `_unhandled_input()` and call `get_viewport().set_input_as_handled()` |
| Not killing the previous tween before creating a new one | Text glitches when the player advances dialogue rapidly, causing overlapping animations | Check `if _current_tween and _current_tween.is_valid(): _current_tween.kill()` before `create_tween()` |
| Using `queue_free()` when refreshing the item grid | Old and new item slots briefly overlap on screen | Use `free()` instead of `queue_free()` when clearing a container before immediately repopulating it |
| Forgetting to add the player to the `"player"` group | NPC interaction zone never detects the player; `body_entered` fires but `is_in_group("player")` is false | Select the Player node, go to Node tab > Groups, add `player` |

## Official Godot Documentation

### Core Classes

- [Resource](https://docs.godotengine.org/en/stable/classes/class_resource.html): base class for all resources; `duplicate()`, `resource_path`
- [Node](https://docs.godotengine.org/en/stable/classes/class_node.html): `_ready()`, `_process()`, `_unhandled_input()`, `process_mode`, `get_tree()`
- [SceneTree](https://docs.godotengine.org/en/stable/classes/class_scenetree.html): `paused`, `get_nodes_in_group()`, `get_first_node_in_group()`, `create_timer()`
- [Viewport](https://docs.godotengine.org/en/stable/classes/class_viewport.html): `set_input_as_handled()`
- [InputEvent](https://docs.godotengine.org/en/stable/classes/class_inputevent.html): `is_action_pressed()`, `is_action_just_pressed()`

### Physics and Detection

- [CharacterBody2D](https://docs.godotengine.org/en/stable/classes/class_characterbody2d.html): solid body used for NPCs (and the player)
- [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html): `body_entered`, `body_exited` signals for proximity detection
- [CollisionShape2D](https://docs.godotengine.org/en/stable/classes/class_collisionshape2d.html): defines collision geometry
- [RectangleShape2D](https://docs.godotengine.org/en/stable/classes/class_rectangleshape2d.html): rectangular collision shape
- [CircleShape2D](https://docs.godotengine.org/en/stable/classes/class_circleshape2d.html): circular collision shape (used for interaction zones)
- [RayCast2D](https://docs.godotengine.org/en/stable/classes/class_raycast2d.html): alternative to Area2D for directional interaction detection

### Sprites and Animation

- [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html): sprite with named animations; `play()`, `sprite_frames`
- [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html): the resource that holds animation data; `has_animation()`

### UI and Control Nodes

- [Control](https://docs.godotengine.org/en/stable/classes/class_control.html): base UI node; `focus_mode`, `grab_focus()`, `_gui_input()`, anchors, margins
- [CanvasLayer](https://docs.godotengine.org/en/stable/classes/class_canvaslayer.html): renders children on a separate layer; `layer` property
- [PanelContainer](https://docs.godotengine.org/en/stable/classes/class_panelcontainer.html): styled background panel
- [MarginContainer](https://docs.godotengine.org/en/stable/classes/class_margincontainer.html): adds padding around its child
- [VBoxContainer](https://docs.godotengine.org/en/stable/classes/class_vboxcontainer.html): stacks children vertically
- [HBoxContainer](https://docs.godotengine.org/en/stable/classes/class_hboxcontainer.html): stacks children horizontally
- [GridContainer](https://docs.godotengine.org/en/stable/classes/class_gridcontainer.html): lays out children in a grid; `columns` property
- [Label](https://docs.godotengine.org/en/stable/classes/class_label.html): plain text display
- [RichTextLabel](https://docs.godotengine.org/en/stable/classes/class_richtextlabel.html): BBCode-formatted text; `visible_ratio`, `visible_characters`, `bbcode_enabled`, `fit_content`, `get_total_character_count()`
- [TextureRect](https://docs.godotengine.org/en/stable/classes/class_texturerect.html): displays an image in UI
- [Button](https://docs.godotengine.org/en/stable/classes/class_button.html): clickable button; `pressed` signal, `text`
- [StyleBoxFlat](https://docs.godotengine.org/en/stable/classes/class_styleboxflat.html): custom panel styles (bg color, border, corner radius)

### Animation and Tweening

- [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html): `tween_property()`, `kill()`, `is_valid()`, `finished` signal
- [Node.create_tween()](https://docs.godotengine.org/en/stable/classes/class_node.html#class-node-method-create-tween): creates a Tween bound to the node's lifetime

### Tutorials and Guides

- [Resources (tutorial)](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html): creating and using Resources
- [GDScript exports](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html): `@export`, `@export_group`, `@export_multiline`, enum exports
- [Input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html): setting up custom input actions
- [Size and anchors](https://docs.godotengine.org/en/stable/tutorials/ui/size_and_anchors.html): positioning Control nodes
- [GUI containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html): automatic layout with VBox, HBox, Grid, Margin containers
- [Control node gallery](https://docs.godotengine.org/en/stable/tutorials/ui/control_node_gallery.html): visual catalog of all Control nodes
- [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html): keyboard/gamepad focus navigation
- [BBCode in RichTextLabel](https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html): text formatting with BBCode tags
- [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html): `SceneTree.paused` and `process_mode`

## What's Next

Part IV is combat. In Module 14 we build the battle scene, implement a node-based state machine for battle flow, and create the turn order system. Modules 15-18 add player actions, a dungeon, enemy AI, and a victory/leveling loop. Everything from Part III (Resources, signals, UI patterns) carries directly into it.

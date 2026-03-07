# Chapter 6 — Resources and Data-Driven Design

Every system you have built so far — player movement, tilemap worlds, scene transitions — is *behavior*. The player moves. The camera follows. Scenes fade in and out. But a JRPG is not just behavior. It is content: hundreds of enemies, dozens of abilities, stacks of items, each with unique stats, descriptions, and icons.

If you hardcode this content into scripts, you will drown in constants. You need a data layer: something that separates *what things are* from *how things behave*. In web terms, you need a CMS — but one that lives inside the engine, produces typed objects, and is editable in a visual inspector.

Godot provides this through **Resources**.

## What We Are Building

By the end of this chapter you will have:

- A `BattlerData` base Resource class that defines combat stats shared by all combatants
- A `CharacterData` class extending `BattlerData` for playable characters (growth rates, portraits, equipment)
- An `EnemyData` class extending `BattlerData` for enemies (AI type, rewards, elemental affinities)
- An `AbilityData` class for skills and spells (cost, damage, targeting, element)
- An `ItemData` class for consumables and key items (effect, pricing, targeting)
- An `EquipmentData` class for gear (slot, stat bonuses, element)
- A `DialogueLine` class with a factory method for runtime construction
- A `BattleAction` RefCounted class for ephemeral runtime data
- Concrete `.tres` files you can edit in the Godot inspector
- A loading pattern with null checks that prevents crashes from missing assets

This is the foundation every later chapter depends on. Battle math reads `BattlerData`. The inventory system manages `ItemData`. Dialogue flows through `DialogueLine`. Get this right and the rest of the game assembles cleanly. Get it wrong and you are patching data bugs for the rest of development.

## The Engineering Parallel

If you come from Angular/TypeScript, think of Resources as the intersection of several things you already know:

| Godot Concept | Your World |
|--------------|------------|
| Custom Resource class (`.gd`) | TypeScript `interface` + `class` — defines the shape of your data |
| `.tres` file | JSON data file — a serialized instance, editable in the Godot inspector |
| `@export` annotation | Angular's `@Input()` — exposes a property to the visual editor |
| `load("res://...")` | `HttpClient.get()` — loads a file from a path, but synchronous and local |
| Resource inheritance | `extends` in TypeScript — `CharacterData` extends `BattlerData` |
| `class_name` | Angular's DI token — registers the type globally so you can reference it by name |

The Godot inspector is your CMS. You define the schema in code, then fill in content through a visual form. Designers edit `.tres` files in the inspector without touching GDScript.

## Resources: Godot's Data Layer

A **Resource** is Godot's serializable data object. Unlike Nodes (which live in the scene tree), Resources are pure data containers. They have no `_process()`, no `_ready()`, no position in the world. They are loaded from disk, passed between systems, and optionally shared across multiple nodes.

Key properties of Resources:

- **Serializable** — Godot saves and loads them as `.tres` (text) or `.res` (binary) files
- **Reusable** — Multiple nodes can reference the same Resource instance
- **Exportable** — `@export` vars appear in the inspector for visual editing
- **Typed** — `class_name` registers them as a type you can use in annotations
- **Inheritable** — Custom Resource classes can extend other Resource classes

### When to Use Resource vs Node vs RefCounted

| Use | When |
|-----|------|
| **Resource** | Persistent game data — stats, items, abilities, quests. Anything you want to save as a `.tres` file and edit in the inspector. |
| **Node** | Runtime objects that live in the scene tree — players, enemies, UI elements. Things with position, visibility, or frame-based behavior. |
| **RefCounted** | Ephemeral runtime data — objects created during gameplay that are never saved to disk. Battle actions, computed results, temporary state. Garbage collected when no references remain. |

The rule of thumb: if a game designer should be able to edit it in the inspector, make it a Resource. If it only exists at runtime, make it a RefCounted. If it needs to be in the scene tree, make it a Node.

## Your First Resource: BattlerData

Every combatant in a JRPG — party members and enemies alike — has the same fundamental stats: hit points, attack power, defense, speed. Rather than defining these separately for characters and enemies, you define them once in a base class.

```gdscript
# battler_data.gd
class_name BattlerData
extends Resource

## Base data resource for all combatants in battle.
## Extended by CharacterData (party members) and EnemyData (enemies).

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Base Stats")
@export var max_hp: int = 100
@export var max_ee: int = 50
@export var attack: int = 10
@export var magic: int = 10
@export var defense: int = 10
@export var resistance: int = 10
@export var speed: int = 10
@export var luck: int = 10

@export_group("Abilities")
@export var abilities: Array[Resource] = []
```

This is dense. Let's unpack it.

### class_name and extends

```gdscript
class_name BattlerData
extends Resource
```

`class_name` registers this script as a named type throughout the engine. Once registered, you can use `BattlerData` in type annotations, the inspector dropdown, and `is` checks. `extends Resource` means this class inherits from Godot's built-in `Resource`, gaining serialization, duplication, and inspector support.

Think of `class_name` as both a TypeScript `export` and an Angular DI `provide` in one line. The type is globally available — no imports needed.

### @export and @export_group

```gdscript
@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
```

`@export` exposes a property to the Godot inspector. When you create a `.tres` file using this Resource class, these properties appear as editable fields in a visual form.

`@export_group("Identity")` creates a collapsible section header in the inspector. All `@export` vars after it (until the next group) appear under that heading. Use groups to organize Resources with many fields — without them, the inspector becomes an unreadable wall of properties.

You can also nest groups with `@export_subgroup()`:

```gdscript
@export_group("Combat")
@export_subgroup("Offense")
@export var attack: int = 10
@export var magic: int = 10

@export_subgroup("Defense")
@export var defense: int = 10
@export var resistance: int = 10
```

### The id Pattern

```gdscript
@export var id: StringName = &""
```

Every Resource in our game has an `id` field of type `StringName`. This is the primary key — the unique identifier that other systems use to look up this resource.

`StringName` is Godot's interned string type. The `&""` syntax creates a StringName literal. StringNames are compared by pointer rather than character-by-character, making dictionary lookups and equality checks faster. For a game that might check "does the player have item X?" dozens of times per frame, this matters.

Convention: the `id` matches the filename. A file at `data/enemies/ember_hound.tres` has `id = &"ember_hound"`.

### @export_multiline

```gdscript
@export_multiline var description: String = ""
```

`@export_multiline` gives you a multi-line text area in the inspector instead of a single-line field. Use it for descriptions, dialogue text, or any string that benefits from line breaks.

## Extending the Base: CharacterData

Party members share BattlerData's combat stats but add progression, equipment restrictions, and visual metadata:

```gdscript
# character_data.gd
class_name CharacterData
extends BattlerData

## Defines a playable character's growth rates and visual metadata.

@export_group("Equipment")
@export var allowed_weapon_types: Array[int] = []

@export_group("Progression")
@export var level: int = 1
@export var current_xp: int = 0
@export var skill_points: int = 0

@export_group("Growth Rates")
@export var hp_growth: float = 10.0
@export var ee_growth: float = 5.0
@export var attack_growth: float = 1.5
@export var magic_growth: float = 1.5
@export var defense_growth: float = 1.5
@export var resistance_growth: float = 1.5
@export var speed_growth: float = 1.0
@export var luck_growth: float = 1.0

@export_group("Visuals")
@export var portrait_path: String = ""
@export var sprite_path: String = ""
@export var battle_sprite_path: String = ""
```

Because `CharacterData extends BattlerData`, it inherits all the base stats (`max_hp`, `attack`, `defense`, etc.) and the identity fields (`id`, `display_name`, `description`). In the inspector, you see both the inherited fields and the new ones, neatly organized by export groups.

**Growth rates** define how much each stat increases per level. When a character levels up, the battle system reads `hp_growth` and adds it to `max_hp`. This keeps progression data in the Resource rather than buried in level-up logic.

**Visual paths** are strings, not preloaded textures. This is intentional — portraits and sprites are loaded at runtime with null checks (covered later in this chapter). Storing paths instead of texture references avoids circular dependencies and lets you handle missing assets gracefully.

## EnemyData: The Other Side of BattlerData

Enemies extend the same base but add AI behavior, rewards, and elemental properties:

```gdscript
# enemy_data.gd
class_name EnemyData
extends BattlerData

## Defines an enemy's AI behavior, elemental affinities, rewards, and loot.

enum AiType {
	BASIC,
	AGGRESSIVE,
	DEFENSIVE,
	SUPPORT,
	BOSS,
}

enum Element {
	NONE,
	FIRE,
	ICE,
	WATER,
	WIND,
	EARTH,
	LIGHT,
	DARK,
}

@export_group("Behavior")
@export var ai_type: AiType = AiType.BASIC

@export_group("Rewards")
@export var exp_reward: int = 10
@export var gold_reward: int = 5

@export_group("Elemental Affinities")
@export var weaknesses: Array[Element] = []
@export var resistances: Array[Element] = []

@export_group("Visuals")
@export var sprite_path: String = ""
@export var sprite_columns: int = 1
@export var sprite_rows: int = 1
@export var battle_scale: float = 1.0

@export_group("Loot")
@export var loot_table: Array[Dictionary] = []
```

### Enums in Resources

Enums defined inside a Resource class appear as dropdown menus in the inspector. `AiType` controls how the battle system picks enemy actions. `Element` categorizes damage types for the weakness/resistance system.

When a `.tres` file is saved to disk, enum values are stored as integers:

```
ai_type = 1        # AGGRESSIVE
weaknesses = [3, 2] # WATER, ICE
resistances = [1]   # FIRE
```

This is fine for serialization, but means you need the enum definition to interpret the raw file. Always define enums inside the Resource class they belong to, so the mapping is self-documenting.

### The Loot Table Pattern

```gdscript
@export var loot_table: Array[Dictionary] = []
```

Each entry is a dictionary with `"item_id"` (String) and `"drop_chance"` (float). In the `.tres` file:

```
loot_table = [{"item_id": "ember_fang", "drop_chance": 0.35}, {"item_id": "potion", "drop_chance": 0.5}]
```

This uses Godot's Dictionary type because it maps directly to JSON-like structures. For a more type-safe approach, you could create a `LootEntry` Resource class, but for simple key-value pairs, Dictionary works well enough and keeps the data layer flat.

## AbilityData: Skills and Spells

Abilities are independent Resources, not nested inside characters or enemies:

```gdscript
# ability_data.gd
class_name AbilityData
extends Resource

## Defines an ability's cost, damage, targeting, and effects.

enum DamageStat {
	ATTACK,
	MAGIC,
}

enum TargetType {
	SINGLE_ENEMY,
	ALL_ENEMIES,
	SINGLE_ALLY,
	ALL_ALLIES,
	SELF,
}

enum Element {
	NONE,
	FIRE,
	ICE,
	WATER,
	WIND,
	EARTH,
	LIGHT,
	DARK,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Cost")
@export var ee_cost: int = 0
@export var resonance_cost: float = 0.0

@export_group("Damage")
@export var damage_base: int = 0
@export var damage_stat: DamageStat = DamageStat.ATTACK

@export_group("Targeting")
@export var target_type: TargetType = TargetType.SINGLE_ENEMY
@export var element: Element = Element.NONE

@export_group("Status Effect")
@export var status_effect: String = ""
@export var status_chance: float = 0.0
@export var status_effect_duration: int = 3

@export_group("Visuals")
@export var animation_name: String = ""
```

The `TargetType` enum is critical — it drives the entire targeting UI in battle. When a player selects "Heavy Strike," the battle system reads `target_type` and shows either the enemy list (SINGLE_ENEMY), highlights all enemies (ALL_ENEMIES), or auto-targets (SELF). One enum value controls all of that behavior.

`damage_stat` determines whether the damage formula uses the caster's `attack` or `magic` stat. Physical abilities use ATTACK, spells use MAGIC. The battle math chapter will use this to calculate damage.

## ItemData: Consumables and Key Items

```gdscript
# item_data.gd
class_name ItemData
extends Resource

## Defines an item's type, effect, targeting, and shop pricing.

enum ItemType {
	CONSUMABLE,
	KEY_ITEM,
	MATERIAL,
}

enum EffectType {
	HEAL_HP,
	HEAL_EE,
	CURE_STATUS,
	REVIVE,
	BUFF,
	DAMAGE,
}

enum TargetType {
	SINGLE_ALLY,
	ALL_ALLIES,
	SINGLE_ENEMY,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Type")
@export var item_type: ItemType = ItemType.CONSUMABLE

@export_group("Effect")
@export var effect_type: EffectType = EffectType.HEAL_HP
@export var effect_value: int = 0
@export var target_type: TargetType = TargetType.SINGLE_ALLY

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0
@export var max_stack: int = 99

@export_group("Usage")
@export var usable_in_battle: bool = true
```

Items share the `id` + `display_name` + `description` pattern with every other Resource. They add economy fields (`buy_price`, `sell_price`) that the shop system reads, and a `usable_in_battle` flag that the battle item menu checks.

## EquipmentData: Weapons and Armor

Equipment is the most field-heavy Resource. Each piece modifies multiple stats, belongs to a slot, and may have an elemental affinity:

```gdscript
# equipment_data.gd
class_name EquipmentData
extends Resource

## Defines an equipment piece's stats, slot, and type restrictions.

enum SlotType {
	WEAPON,
	HELMET,
	CHEST,
	ACCESSORY,
}

enum WeaponType {
	NONE,
	SWORD,
	DAGGER,
	HAMMER,
	RIFLE,
	SHIELD,
	MACE,
	STAFF,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Slot")
@export var slot_type: SlotType = SlotType.WEAPON
@export var weapon_type: WeaponType = WeaponType.NONE

@export_group("Stat Bonuses")
@export var attack_bonus: int = 0
@export var magic_bonus: int = 0
@export var defense_bonus: int = 0
@export var resistance_bonus: int = 0
@export var speed_bonus: int = 0
@export var luck_bonus: int = 0
@export var max_hp_bonus: int = 0
@export var max_ee_bonus: int = 0

@export_group("Properties")
@export var element: AbilityData.Element = AbilityData.Element.NONE
@export var crit_rate_bonus: float = 0.0

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0
```

Notice that `element` references `AbilityData.Element` rather than defining its own Element enum. This keeps the Element type consistent across the codebase — abilities, enemies, and equipment all use the same enum values.

The `EquipmentManager` autoload (built in a later chapter) reads these stat bonuses and adds them to a character's effective stats during battle. The base stats come from `CharacterData`, the bonuses come from `EquipmentData`, and the battle system sums them.

## Creating .tres Files: Your Data Content

The Resource classes above are schemas. The actual content lives in `.tres` files. Here is what the Ember Hound enemy looks like serialized:

```
[gd_resource type="Resource" script_class="EnemyData" load_steps=2 format=3]

[ext_resource type="Script" path="res://resources/enemy_data.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
id = &"ember_hound"
display_name = "Ember Hound"
description = "A beast prowling the forest's volcanic vents."
max_hp = 70
attack = 22
magic = 8
defense = 12
resistance = 6
speed = 14
exp_reward = 32
gold_reward = 22
weaknesses = [3, 2]
resistances = [1]
ai_type = 1
sprite_path = "res://assets/sprites/enemies/cerberus_1.png"
sprite_columns = 3
sprite_rows = 4
battle_scale = 1.5
loot_table = [{"item_id": "ember_fang", "drop_chance": 0.35}]
```

You do not write `.tres` files by hand in a real workflow. Instead:

1. In Godot's FileSystem dock, right-click and select **New Resource**
2. Search for your custom class name (e.g., "EnemyData")
3. Click Create — Godot opens the inspector with all your `@export` fields visible
4. Fill in the values using the visual form
5. Save as `data/enemies/ember_hound.tres`

The inspector shows your `@export_group` headings as collapsible sections. Enums appear as dropdowns. Arrays have add/remove buttons. The experience is closer to a CMS admin panel than a code editor.

### Organization

Keep `.tres` files organized by type:

```
data/
  abilities/     # AbilityData instances
  characters/    # CharacterData instances
  enemies/       # EnemyData instances
  equipment/     # EquipmentData instances
  items/         # ItemData instances
```

Filename matches `id`. The file `data/enemies/ember_hound.tres` has `id = &"ember_hound"`. This convention makes debugging trivial — if the battle log says "ember_hound dealt 22 damage," you know exactly which file to open.

## Loading Resources at Runtime

Resources are loaded with Godot's `load()` function, which takes a `res://` path and returns the Resource (or `null` if the file does not exist):

```gdscript
var enemy: EnemyData = load("res://data/enemies/ember_hound.tres") as EnemyData
```

### The Null-Check Pattern

Assets can fail to load — the file might be missing, the path might be wrong, or Godot might not have imported it yet. Always guard `load()` calls:

```gdscript
var enemy: EnemyData = load("res://data/enemies/ember_hound.tres") as EnemyData
if enemy == null:
	push_error("Failed to load enemy: ember_hound")
	return
```

This is the equivalent of checking an HTTP response status before using the body. Without it, a missing `.tres` file causes a null reference crash instead of a useful error message.

For textures referenced by path inside a Resource:

```gdscript
func _load_portrait(character: CharacterData) -> Texture2D:
	if character.portrait_path.is_empty():
		return null
	var texture: Texture2D = load(character.portrait_path) as Texture2D
	if texture == null:
		push_warning("Portrait failed to load: %s" % character.portrait_path)
	return texture
```

`push_error()` for critical failures (game cannot continue). `push_warning()` for non-fatal issues (portrait is missing but gameplay can proceed).

### load() vs preload()

Godot offers two loading functions:

```gdscript
# Resolved at parse time — path must be a string literal
const SCENE := preload("res://ui/dialogue/dialogue_box.tscn")

# Resolved at runtime — path can be a variable
var data: Resource = load("res://data/enemies/" + enemy_id + ".tres")
```

`preload()` is like a static import — the engine loads the resource when the script is first parsed. Use it for things you always need (scene references, shared scripts). `load()` is like a dynamic import — it loads on demand, and the path can be constructed at runtime. Use it for data that varies (loading enemies based on area, loading portraits based on character).

For data-driven systems, `load()` is your primary tool because the path depends on runtime data.

## Factory Methods: Runtime Construction

Not all Resources come from `.tres` files. Sometimes you construct them in code during gameplay. The `DialogueLine` class demonstrates this with a static factory method:

```gdscript
# dialogue_line.gd
class_name DialogueLine
extends Resource

## A single line of dialogue with optional speaker, portrait, and choices.

@export var speaker: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var choices: Array[String] = []


func has_choices() -> bool:
	return not choices.is_empty()


static func create(
	p_speaker: String,
	p_text: String,
	p_portrait: Texture2D = null,
	p_choices: Array[String] = [],
) -> DialogueLine:
	var line := DialogueLine.new()
	line.speaker = p_speaker
	line.text = p_text
	line.portrait = p_portrait
	line.choices = p_choices
	return line
```

The `create()` static method is a factory — it constructs a `DialogueLine` with all fields set in one call, rather than requiring callers to set properties one by one:

```gdscript
# Without factory — verbose and error-prone
var line := DialogueLine.new()
line.speaker = "Elder Maren"
line.text = "The forest remembers what we have forgotten."

# With factory — one clean call
var line := DialogueLine.create("Elder Maren", "The forest remembers what we have forgotten.")
```

Factory methods are especially useful when a Resource is always constructed programmatically (like dialogue lines generated from NPC data) rather than loaded from a `.tres` file.

### Batch Construction

`DialogueLine` also provides a batch factory for converting raw string pairs into dialogue sequences:

```gdscript
static func build_from_pairs(
	raw_lines: Array[String],
	source_name: String = "",
) -> Array[DialogueLine]:
	if raw_lines.size() % 2 != 0:
		var label: String = source_name if not source_name.is_empty() else "DialogueLine"
		push_warning(
			"%s: raw_lines has odd count (%d); last entry ignored."
			% [label, raw_lines.size()]
		)
	var result: Array[DialogueLine] = []
	var i := 0
	while i + 1 < raw_lines.size():
		result.append(DialogueLine.create(raw_lines[i], raw_lines[i + 1]))
		i += 2
	return result
```

This converts `["Elder Maren", "Welcome to the village.", "Elder Maren", "Rest here tonight."]` into two `DialogueLine` objects. The pattern is useful when dialogue is defined inline in scene scripts rather than loaded from files.

## RefCounted: Ephemeral Runtime Data

Some data objects exist only during gameplay and are never saved to disk. The `BattleAction` class demonstrates this:

```gdscript
# battle_action.gd
class_name BattleAction
extends RefCounted

## Encapsulates a battle action chosen by a battler.

enum Type {
	ATTACK,
	ABILITY,
	DEFEND,
	WAIT,
	ITEM,
}

var type: Type = Type.WAIT
var target: Node = null
var ability: AbilityData = null
var item: ItemData = null


static func create_attack(p_target: Node) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ATTACK
	action.target = p_target
	return action


static func create_ability(
	p_ability: AbilityData,
	p_target: Node,
) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ABILITY
	action.ability = p_ability
	action.target = p_target
	return action


static func create_defend() -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.DEFEND
	return action


static func create_item(
	p_item: ItemData,
	p_target: Node,
) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ITEM
	action.item = p_item
	action.target = p_target
	return action


static func create_wait() -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.WAIT
	return action
```

`BattleAction extends RefCounted`, not `Resource`. It will never be saved to a `.tres` file. It exists for one battle turn, gets processed, and is garbage collected when no references remain.

Each static factory creates a specific action type with the correct payload. This is the Builder or Factory pattern — instead of a constructor with a dozen optional parameters, you have named constructors that make intent explicit:

```gdscript
# Clear intent — "the warrior attacks the goblin"
var action := BattleAction.create_attack(goblin)

# Clear intent — "the mage casts Fireball on the goblin"
var action := BattleAction.create_ability(fireball_data, goblin)
```

### When to Use RefCounted vs Resource

| Use RefCounted | Use Resource |
|---------------|-------------|
| Created and consumed within one system | Shared across multiple systems |
| Never needs inspector editing | Editable in the Godot inspector |
| Never saved to disk | Saved as `.tres` files |
| Short-lived (one frame, one turn, one function) | Long-lived (entire game session or permanent) |

`BattleAction` is a perfect RefCounted candidate — it is created when a combatant chooses an action, consumed when the action resolves, and discarded immediately after. Making it a Resource would add serialization overhead for something that never touches disk.

## Resource Duplication

Resources are reference types. When you assign a Resource to a variable or pass it to a function, you are passing a reference, not a copy:

```gdscript
var enemy_a: EnemyData = load("res://data/enemies/ember_hound.tres")
var enemy_b: EnemyData = enemy_a
enemy_b.max_hp = 999  # This ALSO changes enemy_a.max_hp
```

This catches web developers off guard because JavaScript objects work the same way, but TypeScript interfaces *feel* like value types because you rarely mutate them after creation. In Godot, mutating a shared Resource changes it everywhere — including in the original `.tres` file if it was loaded from disk.

To create an independent copy, use `duplicate()`:

```gdscript
var enemy_a: EnemyData = load("res://data/enemies/ember_hound.tres")
var enemy_b: EnemyData = enemy_a.duplicate() as EnemyData
enemy_b.max_hp = 999  # Only enemy_b is changed
```

`duplicate()` creates a **shallow copy** — primitive fields (int, float, String) are copied, but nested Resources and Arrays still share references with the original. If your Resource contains a sub-Resource (like an ability array), modifying the sub-Resource in the copy also modifies it in the original.

For a **deep copy** that recursively duplicates all nested resources, pass `true`:

```gdscript
var deep_copy: EnemyData = enemy_a.duplicate(true) as EnemyData
```

Use deep copies when you need truly independent instances — for example, giving each spawned enemy its own mutable copy of its data so HP changes during battle do not affect the template.

## The Inheritance Hierarchy

Here is the full picture of how the data layer fits together:

```
Resource
├── BattlerData              ← base combat stats (shared by all combatants)
│   ├── CharacterData        ← party members (growth, equipment, visuals)
│   └── EnemyData            ← enemies (AI, rewards, elements, loot)
├── AbilityData              ← skills and spells
├── ItemData                 ← consumables and key items
├── EquipmentData            ← weapons and armor
├── StatusEffectData         ← poison, stun, buffs
├── QuestData                ← quest definitions
├── DialogueLine             ← dialogue with factory methods
└── EncounterPoolEntry       ← weighted enemy groups for random battles

RefCounted
└── BattleAction             ← ephemeral: one turn, then garbage collected
```

This hierarchy is deliberately shallow. `BattlerData → CharacterData/EnemyData` is the only inheritance chain. Everything else extends `Resource` directly. Deep inheritance hierarchies in game data lead to the same problems they cause in web code — tight coupling, unclear overrides, and the fragile base class problem. Keep it flat.

## Connecting Resources to Systems

Resources are inert data. They do nothing on their own. Systems read them and act:

| System | Reads | Does |
|--------|-------|------|
| BattleManager | `BattlerData`, `AbilityData` | Runs combat with stats and abilities |
| InventoryManager | `ItemData` | Tracks item quantities and gold |
| EquipmentManager | `EquipmentData`, `CharacterData` | Applies stat bonuses per equipment slot |
| DialogueManager | `DialogueLine` | Drives the dialogue UI sequence |
| QuestManager | `QuestData` | Tracks quest state and objectives |
| Encounter system | `EncounterPoolEntry`, `EnemyData` | Picks random enemy groups by weight |

This separation is the core architectural principle: **data defines what, systems define how, scenes define where**. An `EnemyData` resource says "this enemy has 70 HP, is weak to water, and drops ember fangs." The battle system decides what those numbers mean in combat. The scene decides where the enemy appears in the world.

## Common Mistakes

**Storing runtime state in Resource data.** Resources loaded from `.tres` files are shared by default. If you decrease an enemy's `max_hp` during battle, you are modifying the template — every future encounter loads the damaged version. Always `duplicate()` before mutating.

**Forgetting null checks on load().** A missing `.tres` file returns `null`. Without a guard, you get a null reference error deep in battle math, far from the actual problem (a missing data file).

**Deep inheritance hierarchies.** Do not create `BattlerData → CharacterData → MageCharacterData → HealerMageCharacterData`. Use composition — give characters ability arrays and equipment slots instead of subclassing per archetype.

**Hardcoding data in scripts.** If you find yourself writing `var enemy_hp := 70` in a battle script, that value belongs in a `.tres` file. The whole point of the data layer is that game designers can change numbers without touching code.

**Using Resource when you need RefCounted.** If an object is created during gameplay and never saved, extending `Resource` adds unnecessary serialization overhead. Use `RefCounted` for throwaway runtime objects.

**Skipping @export_group.** A Resource with 20 ungrouped exports is painful to edit in the inspector. Always organize with groups. Future-you (and any designer on your team) will thank you.

## What Is Next

You have a complete data layer — Resource classes that define every entity in your JRPG, `.tres` files that hold the content, and loading patterns that handle missing data gracefully. In the next chapter, you will use `DialogueLine` and the `DialogueManager` to build a full NPC dialogue system, connecting data to behavior for the first time.

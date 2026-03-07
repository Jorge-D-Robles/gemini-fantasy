# Chapter 14 — Inventory and Equipment

Every application has a data store. In a web app, it might be Redux, NgRx, or a simple reactive service. In a JRPG, the player carries two stores: an **inventory** (items and gold) and an **equipment loadout** (gear slotted onto each character). Both are global state that persists across scenes, battles, and save files.

This chapter builds two autoloads: `InventoryManager` for items and gold, and `EquipmentManager` for per-character equipment slots. Together they define what the player *has* and how it affects combat stats.

## What We Are Building

- **ItemData** — a Resource defining an item's type, effect, targeting, and economy values
- **EquipmentData** — a Resource defining a piece of gear's slot, stat bonuses, and restrictions
- **InventoryManager** — an autoload that tracks item quantities and gold
- **EquipmentManager** — an autoload that tracks equipped gear per character and computes stat bonuses
- **Integration** with the battle system — equipment bonuses applied when battlers initialize

## Step 1: The ItemData Resource

Items are data. Each item type — potions, keys, crafting materials — is described by a Resource class with fields for its identity, effect, and economy:

```gdscript
# res://resources/item_data.gd
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

### Design Decisions

**`id` is a `StringName`, not an `int`.** String IDs like `&"potion"` and `&"iron_sword"` are human-readable in save files, debuggable in the console, and do not require a central registry to prevent collisions. `StringName` specifically gives you interned string comparison — as fast as integer comparison, but readable.

**`@export_group` organizes the inspector.** When you select a `.tres` file in Godot's editor, grouped exports appear under collapsible headers. This is not just cosmetic — it prevents the "wall of 15 ungrouped fields" problem that makes data entry error-prone.

**`usable_in_battle` is a simple flag.** In a more complex system you might add `usable_in_field` too, but a boolean is enough for the common case: potions work in battle, key items do not.

### Creating Item Data Files

Each item is a `.tres` file in `res://data/items/`:

```
# res://data/items/potion.tres
[gd_resource type="Resource" script_class="ItemData" ...]

[resource]
script = ExtResource("...")
id = &"potion"
display_name = "Potion"
description = "Restores 50 HP to one ally."
item_type = 0
effect_type = 0
effect_value = 50
target_type = 0
buy_price = 50
sell_price = 25
max_stack = 99
usable_in_battle = true
```

You will typically create these in Godot's editor (right-click in FileSystem → New Resource → ItemData), but the `.tres` format is just an INI-style text file that you can also generate from scripts or copy-paste.

## Step 2: The InventoryManager

The `InventoryManager` is an autoload — a global singleton that exists for the entire game lifetime. It stores item quantities as a flat dictionary and manages gold as a separate integer:

```gdscript
# res://autoloads/inventory_manager.gd
extends Node

## Manages the player's inventory of items and gold.

signal inventory_changed
signal gold_changed

var gold: int = 0
var _items: Dictionary = {}


func add_item(id: StringName, count: int = 1) -> void:
	if count <= 0:
		return
	if _items.has(id):
		_items[id] += count
	else:
		_items[id] = count
	inventory_changed.emit()


func remove_item(id: StringName, count: int = 1) -> bool:
	if count <= 0:
		return false
	if not _items.has(id) or _items[id] < count:
		return false
	_items[id] -= count
	if _items[id] <= 0:
		_items.erase(id)
	inventory_changed.emit()
	return true


func has_item(id: StringName) -> bool:
	return _items.has(id) and _items[id] > 0


func get_item_count(id: StringName) -> int:
	return _items.get(id, 0)


func get_all_items() -> Dictionary:
	return _items.duplicate()


func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	gold_changed.emit()


func remove_gold(amount: int) -> bool:
	if amount <= 0:
		return false
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit()
	return true
```

Register it as an autoload in Project Settings → Globals → Autoload, with the name `InventoryManager`.

### The Dictionary as a Store

The `_items` dictionary uses `StringName` keys and `int` values: `{&"potion": 3, &"antidote": 1}`. This is the simplest possible inventory model — no item instances, no unique IDs per stack, no slot positions. Each item type either exists in some quantity or does not.

If you have worked with Redux, think of `_items` as a slice of normalized state: the key is the entity ID, the value is the only field you need (quantity). Adding an item is an upsert. Removing an item decrements the count and erases the key when it hits zero to prevent phantom entries.

### Signals as Change Notifications

`inventory_changed` fires on every add or remove. UI components (inventory screen, HUD item counter) connect to this signal and refresh when it fires. This is the Observer pattern — the same as Angular's `EventEmitter` or React's state change triggering a re-render.

`gold_changed` is separate because gold changes more frequently (shop transactions, battle rewards) and some UI elements care about gold but not items.

Both signals carry no payload — they simply notify "something changed." The listener calls `get_all_items()` or reads `gold` directly to get the new state. This keeps the signal interface simple and avoids stale-data bugs where a listener caches the payload instead of reading current state.

### Loading Item Data

When you need the full `ItemData` resource for an item in the inventory (to display its description, or apply its effect), load it by convention path:

```gdscript
func get_item_data(id: StringName) -> ItemData:
	var path := "res://data/items/%s.tres" % id
	if not ResourceLoader.exists(path):
		push_warning(
			"InventoryManager: item file not found '%s'" % path
		)
		return null
	return load(path) as ItemData
```

This convention — `res://data/items/{id}.tres` — means you never need a registry mapping IDs to paths. The ID *is* the path. This works because `StringName` IDs like `&"potion"` map directly to file names like `potion.tres`.

### Battle-Usable Items

The battle system needs to know which items the player can use during combat. A helper method filters the inventory:

```gdscript
func get_usable_items() -> Array[ItemData]:
	var result: Array[ItemData] = []
	for id: StringName in _items:
		if _items[id] <= 0:
			continue
		var data := get_item_data(id)
		if data and data.usable_in_battle:
			result.append(data)
	return result
```

The battle UI calls this to populate the item submenu. Only items with `usable_in_battle = true` appear.

## Step 3: The EquipmentData Resource

Equipment is more complex than consumable items. Each piece of gear has a slot (where it goes on the character), stat bonuses (how it affects combat), and potentially a weapon type (which characters can wield it):

```gdscript
# res://resources/equipment_data.gd
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
	STAFF,
	ORB,
	BOW,
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

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0
```

### Slot Design

Five equipment slots per character: weapon, helmet, chest, and two accessories. The `SlotType` enum has four values because both accessory slots use the same type — the `EquipmentManager` handles the two-slot distinction at runtime.

This is a deliberate simplification. Some JRPGs have 8+ slots (boots, gloves, cape, ring, etc.). Five slots keep the equipment screen manageable and the stat math straightforward. You can always add slots later — the manager's dictionary structure makes this a data change, not an architecture change.

### Stat Bonuses as Flat Integers

Each bonus is a plain integer: `attack_bonus = 12` means "add 12 to the character's attack stat." No percentages, no multiplicative stacking, no diminishing returns. The final stat is simply `base_stat + sum_of_equipment_bonuses`.

Flat bonuses are easy to reason about. When the player compares a +10 sword to a +15 sword, the answer is obvious. Percentage-based systems create confusing interactions ("does this 10% bonus apply before or after the other 10% bonus?") that you do not want to debug.

## Step 4: The EquipmentManager

The `EquipmentManager` autoload tracks which gear is equipped on each character and computes aggregate stat bonuses:

```gdscript
# res://autoloads/equipment_manager.gd
extends Node

## Manages equipped items per character. Tracks weapon, helmet, chest,
## and two accessory slots for each party member.

signal equipment_changed(character_id: StringName, slot: String)

const SLOT_KEYS: Array[String] = [
	"weapon", "helmet", "chest", "accessory_0", "accessory_1",
]

## Per-character equipment: { StringName -> { slot_key -> EquipmentData } }
var _equipment: Dictionary = {}


func equip(
	character_id: StringName,
	equipment: EquipmentData,
) -> EquipmentData:
	if equipment == null:
		return null
	var slot_key := _slot_type_to_key(equipment.slot_type)
	if slot_key == "accessory":
		return equip_accessory(character_id, equipment, 0)
	var slots := _get_or_create_slots(character_id)
	var old: EquipmentData = slots.get(slot_key)
	slots[slot_key] = equipment
	equipment_changed.emit(character_id, slot_key)
	return old


func unequip(
	character_id: StringName,
	slot_type: EquipmentData.SlotType,
) -> EquipmentData:
	var slot_key := _slot_type_to_key(slot_type)
	if slot_key == "accessory":
		return unequip_accessory(character_id, 0)
	var slots := _get_or_create_slots(character_id)
	var old: EquipmentData = slots.get(slot_key)
	slots[slot_key] = null
	if old:
		equipment_changed.emit(character_id, slot_key)
	return old


func equip_accessory(
	character_id: StringName,
	equipment: EquipmentData,
	index: int,
) -> EquipmentData:
	if equipment == null or index < 0 or index > 1:
		return null
	var slots := _get_or_create_slots(character_id)
	var key := "accessory_%d" % index
	var old: EquipmentData = slots.get(key)
	slots[key] = equipment
	equipment_changed.emit(character_id, key)
	return old


func unequip_accessory(
	character_id: StringName,
	index: int,
) -> EquipmentData:
	if index < 0 or index > 1:
		return null
	var slots := _get_or_create_slots(character_id)
	var key := "accessory_%d" % index
	var old: EquipmentData = slots.get(key)
	slots[key] = null
	if old:
		equipment_changed.emit(character_id, key)
	return old


func get_stat_bonuses(character_id: StringName) -> Dictionary:
	var bonuses := {
		"attack": 0,
		"magic": 0,
		"defense": 0,
		"resistance": 0,
		"speed": 0,
		"luck": 0,
		"max_hp": 0,
		"max_ee": 0,
	}
	var slots := _get_or_create_slots(character_id)
	for key: String in slots:
		var item: EquipmentData = slots[key]
		if item == null:
			continue
		bonuses["attack"] += item.attack_bonus
		bonuses["magic"] += item.magic_bonus
		bonuses["defense"] += item.defense_bonus
		bonuses["resistance"] += item.resistance_bonus
		bonuses["speed"] += item.speed_bonus
		bonuses["luck"] += item.luck_bonus
		bonuses["max_hp"] += item.max_hp_bonus
		bonuses["max_ee"] += item.max_ee_bonus
	return bonuses


func get_all_equipment(
	character_id: StringName,
) -> Dictionary:
	var slots := _get_or_create_slots(character_id)
	return {
		"weapon": slots.get("weapon"),
		"helmet": slots.get("helmet"),
		"chest": slots.get("chest"),
		"accessory_0": slots.get("accessory_0"),
		"accessory_1": slots.get("accessory_1"),
	}


func _get_or_create_slots(
	character_id: StringName,
) -> Dictionary:
	if character_id not in _equipment:
		_equipment[character_id] = {
			"weapon": null,
			"helmet": null,
			"chest": null,
			"accessory_0": null,
			"accessory_1": null,
		}
	return _equipment[character_id]


func _slot_type_to_key(
	slot_type: EquipmentData.SlotType,
) -> String:
	match slot_type:
		EquipmentData.SlotType.WEAPON:
			return "weapon"
		EquipmentData.SlotType.HELMET:
			return "helmet"
		EquipmentData.SlotType.CHEST:
			return "chest"
		EquipmentData.SlotType.ACCESSORY:
			return "accessory"
		_:
			return "weapon"
```

### The Equip/Unequip Swap Pattern

`equip()` returns the previously equipped item (or `null`). This enables the common JRPG pattern of swapping gear:

```gdscript
# Player equips a new sword
var old_sword: EquipmentData = EquipmentManager.equip(
	&"kael", iron_sword,
)
# Return the old sword to inventory
if old_sword:
	InventoryManager.add_item(old_sword.id)
# Remove the new sword from inventory
InventoryManager.remove_item(iron_sword.id)
```

The equip screen UI handles this swap automatically. The important thing is that `equip()` is atomic — it replaces and returns in a single call, so you never end up in a state where a slot is empty but the old item is also missing from inventory.

### Computing Stat Bonuses

`get_stat_bonuses()` iterates over all five slots and sums their bonuses into a flat dictionary. The battle system calls this when initializing a battler:

```gdscript
# Inside Battler.initialize_from_data()
func initialize_from_data(
	equip_manager: Node = null,
) -> void:
	# Start with base stats from CharacterData
	hp = data.max_hp
	attack = data.attack
	defense = data.defense
	# ...

	# Add equipment bonuses
	if equip_manager:
		var bonuses: Dictionary = equip_manager.get_stat_bonuses(
			data.id,
		)
		attack += bonuses.get("attack", 0)
		defense += bonuses.get("defense", 0)
		speed += bonuses.get("speed", 0)
		max_hp += bonuses.get("max_hp", 0)
		# ...
```

This is the single integration point between equipment and combat. The battler does not know about slots, weapons, or armor types — it just receives a dictionary of bonus numbers.

### Lazy Slot Initialization

`_get_or_create_slots()` creates the five-slot dictionary on first access for each character. This means you never need to explicitly "register" a character with the equipment system — equipping their first item creates their slot dictionary automatically.

This pattern is borrowed from autovivification in Perl/Ruby hashes, or `defaultdict` in Python. It eliminates an entire class of "character not registered" errors.

### Accessory Slots

Accessories are special because there are two slots sharing the same `SlotType.ACCESSORY` enum value. The manager resolves this with an explicit `index` parameter:

```gdscript
# Equip a ring in the first accessory slot
EquipmentManager.equip_accessory(&"kael", fire_ring, 0)
# Equip a pendant in the second slot
EquipmentManager.equip_accessory(&"kael", wind_pendant, 1)
```

The base `equip()` method defaults to slot 0 when it detects an accessory. The equipment UI provides explicit slot selection.

## Step 5: Serialization for Save/Load

Both managers need to serialize their state for the save system (Chapter 16). The pattern is the same: convert internal state to a plain Dictionary that `JSON.stringify()` can handle.

### InventoryManager Serialization

The inventory is already a dictionary of StringNames to ints — almost JSON-ready. The only wrinkle is that `StringName` must be converted to `String` for JSON:

```gdscript
# In InventoryManager — called by SaveManager
func to_save_data() -> Dictionary:
	var items := {}
	for id: StringName in _items:
		items[String(id)] = _items[id]
	return {
		"gold": gold,
		"items": items,
	}


func from_save_data(data: Dictionary) -> void:
	# Clear existing inventory
	_items.clear()
	gold = data.get("gold", 0)
	var items: Dictionary = data.get("items", {})
	for id_str: String in items:
		_items[StringName(id_str)] = int(items[id_str])
	inventory_changed.emit()
	gold_changed.emit()
```

### EquipmentManager Serialization

Equipment is trickier because you are storing Resource references, not simple values. The save file stores equipment IDs, and deserialization reloads the `.tres` files:

```gdscript
# In EquipmentManager — called by SaveManager
func serialize() -> Dictionary:
	var data := {}
	for character_id: StringName in _equipment:
		var slots: Dictionary = _equipment[character_id]
		var entry := {}
		for key: String in SLOT_KEYS:
			var item: EquipmentData = slots.get(key)
			entry[key] = String(item.id) if item else ""
		data[String(character_id)] = entry
	return data


func deserialize(data: Dictionary) -> void:
	_equipment.clear()
	for char_id_str: String in data:
		var char_id := StringName(char_id_str)
		var entry: Dictionary = data[char_id_str]
		var slots := _get_or_create_slots(char_id)
		for key: String in SLOT_KEYS:
			var equip_id: String = entry.get(key, "")
			if equip_id.is_empty():
				continue
			var path := "res://data/equipment/%s.tres" % equip_id
			if not ResourceLoader.exists(path):
				push_warning(
					"EquipmentManager: equipment not found "
					+ "'%s'" % path
				)
				continue
			var loaded := load(path) as EquipmentData
			if loaded:
				slots[key] = loaded
```

The same convention-based path pattern applies: `res://data/equipment/{id}.tres`. Equipment IDs like `&"iron_sword"` map to `iron_sword.tres`.

## Step 6: Connecting Inventory to the Battle System

Items can be used during battle. The integration requires two pieces:

**1. The battle UI queries usable items:**

```gdscript
# In the battle item submenu
func _populate_item_list() -> void:
	var items: Array[ItemData] = InventoryManager.get_usable_items()
	for item: ItemData in items:
		var count: int = InventoryManager.get_item_count(item.id)
		_add_menu_entry(item.display_name, count, item)
```

**2. The battle action executor applies the item effect and removes it from inventory:**

```gdscript
# In ActionExecuteState — when executing an ITEM action
func _execute_item(
	user: Battler,
	target: Battler,
	item: ItemData,
) -> void:
	match item.effect_type:
		ItemData.EffectType.HEAL_HP:
			target.heal(item.effect_value)
		ItemData.EffectType.HEAL_EE:
			target.restore_ee(item.effect_value)
		ItemData.EffectType.REVIVE:
			if not target.is_alive:
				target.revive(item.effect_value)
		ItemData.EffectType.CURE_STATUS:
			target.clear_status_effects()

	# Consume the item
	InventoryManager.remove_item(item.id)
```

The key insight: `InventoryManager.remove_item()` is called during battle, and the inventory change persists after battle ends. Items are consumed permanently, not just for the current fight. This matches JRPG convention — using a potion in battle means you no longer have that potion.

## How It Connects

```
InventoryManager (autoload)
  ├── add_item / remove_item ← shops, chests, quest rewards, battle loot
  ├── inventory_changed signal → inventory UI, HUD
  ├── get_usable_items() → battle item submenu
  └── gold → shop transactions, battle rewards

EquipmentManager (autoload)
  ├── equip / unequip ← equipment screen UI
  ├── equipment_changed signal → equipment UI, stat display
  ├── get_stat_bonuses() → Battler.initialize_from_data()
  └── serialize / deserialize ← SaveManager
```

**Who calls these managers:**
- **Shops** — buy: `remove_gold()` + `add_item()`; sell: `remove_item()` + `add_gold()`
- **Chests** — `add_item()` on interact
- **Battle rewards** — `add_gold()` + `add_item()` on victory
- **Quest rewards** — `add_item()` + `add_gold()` on quest completion
- **Equipment screen** — `equip()` / `unequip()` + inventory item management
- **Battle system** — `get_stat_bonuses()` at battle start, `get_usable_items()` for item menu

## Common Mistakes

**Storing item instances instead of quantities.** Beginners sometimes create an `Array[ItemData]` where each element is a separate item instance. This wastes memory, complicates stacking, and breaks when comparing items (two `load()` calls to the same `.tres` return the same cached Resource, but `duplicate()` does not). Use IDs and quantities.

**Forgetting to return the old equipment on equip.** If `equip()` does not return the displaced item, the swap logic in the UI becomes a three-step dance (unequip old, add to inventory, equip new, remove from inventory). Returning the old item makes it a two-step operation: equip returns old, handle the swap.

**Mixing inventory and equipment concepts.** Equipment items exist in one of two places: the inventory (not equipped) or a character's slot (equipped). They should never exist in both simultaneously. The `equip()` call moves an item from inventory to slot; the UI must call `InventoryManager.remove_item()` on equip and `InventoryManager.add_item()` on unequip.

**Emitting signals with stale data.** Signals should carry minimal payloads (or none at all). The `inventory_changed` signal carries no data — listeners read the current state directly. This prevents race conditions where a listener processes a stale payload from a queued signal.

**Not handling missing `.tres` files during deserialization.** Save files reference equipment IDs. If you rename or delete a `.tres` file between game versions, deserialization will fail for that item. The `push_warning` + `continue` pattern degrades gracefully — the slot stays empty rather than crashing.

## What is Next

Items sit in the inventory, equipment boosts stats, and battles consume resources. But none of this has *purpose* yet — the player needs goals. Chapter 15 builds the `QuestManager` and `EventFlags` systems that give the player objectives, track story progress, and gate content behind prerequisites.

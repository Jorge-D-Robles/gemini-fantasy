# Module 10: The Inventory System

## What We Have So Far

NPCs with a dialogue system, custom Resources for items and characters, scene transitions, and a connected two-area world. We've defined items like Potion and Iron Sword as `.tres` files — but the player can't actually carry or use them yet.

## What We're Building This Module

An inventory system with a global autoload for tracking items, a UI screen the player can open with a key, and the ability to use consumable items. We'll keep this focused — equipment and shops come in Module 17.

## InventoryManager Autoload

The inventory needs to persist across scene changes, so it's an autoload.

Create `res://autoloads/inventory_manager.gd`:

```gdscript
extends Node
## Manages the player's inventory. Autoload — accessible as InventoryManager.

signal item_added(item: ItemData, new_count: int)
signal item_removed(item: ItemData, new_count: int)
signal inventory_changed
signal gold_changed(new_amount: int)

var gold: int = 100  # Starting gold
var _items: Array[Dictionary] = []  # [{item: ItemData, count: int}]


func add_item(item: ItemData, amount: int = 1) -> void:
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
    for i in _items.size():
        if _items[i].item.id == item.id:
            _items[i].count -= amount
            var remaining: int = _items[i].count
            if remaining <= 0:
                _items.remove_at(i)
                remaining = 0
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
    return _items


func get_consumables() -> Array[Dictionary]:
    return _items.filter(
        func(entry: Dictionary) -> bool:
            return entry.item.item_type == ItemData.ItemType.CONSUMABLE
    )


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

**Signal-driven updates:** Every change emits a signal (`item_added`, `item_removed`, `inventory_changed`, `gold_changed`). The UI listens to these signals and updates itself — the InventoryManager never touches UI directly.

**ID-based matching:** Items are matched by their `id` string (`item.id == item_id`), not by object reference. This means two different `ItemData` instances with the same `id` are treated as the same item — important when loading from saves.

**`remove_item` returns bool:** Callers can check if the removal succeeded. Trying to remove an item the player doesn't have returns `false`.

**Autoload reference card:**

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 6 | Scene transitions with fade effects |
| **InventoryManager** | **10** | **Item storage, add/remove, signals** |

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

And `res://ui/inventory/item_slot.gd`:

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
    if what == NOTIFICATION_FOCUS_ENTERED:
        slot_selected.emit(item_data)
```

> **See:** [TextureRect](https://docs.godotengine.org/en/stable/classes/class_texturerect.html) — displaying images in UI.

> **See:** [GridContainer](https://docs.godotengine.org/en/stable/classes/class_gridcontainer.html) — automatic grid layout for child nodes.

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
    _is_open = true
    _panel.visible = true
    get_tree().paused = true
    _refresh()


func close() -> void:
    _is_open = false
    _panel.visible = false
    get_tree().paused = false


func _refresh() -> void:
    # Clear existing slots
    for child in _item_grid.get_children():
        child.queue_free()

    # Wait a frame for queue_free to process
    await get_tree().process_frame

    # Create slots for each item
    var items := InventoryManager.get_all_items()
    for entry in items:
        var slot: PanelContainer = ItemSlotScene.instantiate()
        _item_grid.add_child(slot)
        slot.setup(entry.item, entry.count)
        slot.slot_selected.connect(_on_slot_selected)
        slot.slot_activated.connect(_on_slot_activated)

    # Focus the first slot
    if _item_grid.get_child_count() > 0:
        await get_tree().process_frame
        _item_grid.get_child(0).grab_focus()


func _on_slot_selected(item: ItemData) -> void:
    _description_label.text = item.description


func _on_slot_activated(item: ItemData) -> void:
    if item.item_type == ItemData.ItemType.CONSUMABLE:
        _use_consumable(item)


func _use_consumable(item: ItemData) -> void:
    # For now, apply directly to a placeholder HP value
    # In Module 17, this will apply to the selected party member
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

## Pausing the Game

When the inventory opens, we **pause the game** so enemies, NPCs, and the player don't move while the menu is up.

```gdscript
get_tree().paused = true   # Pause everything
get_tree().paused = false  # Resume everything
```

But wait — if everything is paused, how does the inventory UI itself continue to work? Through **`process_mode`**.

Every node has a `process_mode` property that controls whether it runs while paused:

| Mode | Behavior |
|------|----------|
| `PROCESS_MODE_INHERIT` | Same as parent (default) |
| `PROCESS_MODE_PAUSABLE` | Pauses when tree is paused |
| `PROCESS_MODE_WHEN_PAUSED` | Only runs when tree is paused |
| `PROCESS_MODE_ALWAYS` | Always runs, regardless of pause state |
| `PROCESS_MODE_DISABLED` | Never runs |

Set the inventory screen's CanvasLayer `process_mode` to **`PROCESS_MODE_ALWAYS`** in the Inspector. This lets it receive input and update even when the game is paused.

The SceneManager should also be `PROCESS_MODE_ALWAYS` — it needs to work during transitions regardless of pause state.

> **See:** [Pausing games](https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html) — the official guide to pausing and `process_mode`.

## Adding a Menu Input Action

Define a `menu` action for opening the inventory:

1. **Project → Project Settings → Input Map**
2. Add a new action: `menu`
3. Bind it to **Escape** (or **I** for inventory) and the **Start/Menu** gamepad button

## Giving the Player Starting Items

To test the inventory, give the player some starting items. In `InventoryManager._ready()`:

```gdscript
func _ready() -> void:
    # Starting inventory for testing
    var potion: ItemData = load("res://data/items/potion.tres")
    if potion:
        add_item(potion, 3)
```

Or better — add items through game events. For now, the starting items are fine for testing.

## Integration: Adding the Inventory to Scenes

Instance `inventory_screen.tscn` in each scene that needs it, or add it as a child of the SceneManager autoload so it's always available.

For a quick setup, add it to each scene:

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

## What We've Learned

- **InventoryManager** autoload tracks items as `{item: ItemData, count: int}` entries with signal-driven updates.
- **Pausing** (`get_tree().paused = true`) freezes game logic. **`process_mode = ALWAYS`** lets UI continue during pause.
- **ItemSlot** scenes are instantiated dynamically in a **GridContainer** to form the inventory grid.
- **Focus-based navigation** (`focus_mode`, `grab_focus()`) makes UI work with keyboard and gamepad.
- **Signal pattern:** InventoryManager emits `inventory_changed` → UI refreshes. Manager never touches UI directly.
- **`_gui_input()`** handles input events on Control nodes. **`accept_event()`** prevents propagation (like `set_input_as_handled()` for UI).
- Items are consumed with `remove_item()` — the grid refreshes automatically via the `inventory_changed` signal.

## What You Should See

When you press F6 (running Willowbrook):
- Press Escape (or your menu key) — the inventory screen opens
- The game world freezes behind the menu
- Items appear as icons in a grid (3 Potions from starting inventory)
- Navigating slots with arrow keys highlights them and shows descriptions
- Pressing accept on a Potion uses it and decrements the count
- Pressing Escape again closes the inventory and resumes the game

## Next Module

We have items and NPCs and dialogue. Now it's time for the biggest system in any JRPG: **combat**. In **Module 11: Battle Foundations**, we'll build the battle scene, implement a node-based state machine for battle flow, and create the turn order system. The journey from idle exploration to heart-pounding boss fights starts here.

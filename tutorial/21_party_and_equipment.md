# Module 21: Party Management, Equipment, and Shops

## What We Have So Far

Quests, game flags, reactive dialogue, a dungeon with a boss, a battle system with leveling. The hero has been fighting alone.

## What We're Building This Module

Three major systems: **party management** (recruiting Lira the mage), **equipment** (weapons and armor that modify stats), and **shops** (buying and selling). These are the final progression systems.

## PartyManager Autoload

In Pokemon, your party of six travels with you everywhere. They appear in battle, they need healing at the Pokemon Center, and the PC storage system swaps them in and out. All of that requires one central place that knows who is in your party right now. Without a PartyManager, every system that cares about the roster (battle, save/load, equipment, healing) would need its own copy of the party list, and they would inevitably get out of sync.

Create `res://autoloads/party_manager.gd`:

```gdscript
extends Node
## Manages the party roster. Autoload as PartyManager.

signal party_member_joined(character: CharacterData)
signal party_member_removed(character: CharacterData)

var members: Array[CharacterData] = []


func _ready() -> void:
    # Start with the hero
    var aiden: CharacterData = load("res://data/characters/aiden.tres")
    if aiden:
        add_member(aiden)


func add_member(character: CharacterData) -> void:
    if not members.has(character):
        members.append(character)
        party_member_joined.emit(character)


func remove_member(character: CharacterData) -> void:
    if members.has(character):
        members.erase(character)
        party_member_removed.emit(character)


func get_members() -> Array[CharacterData]:
    return members.duplicate()


func get_member_by_id(id: String) -> CharacterData:
    for member in members:
        if member.id == id:
            return member
    return null


func award_xp_to_party(xp_per_member: int) -> void:
    if xp_per_member <= 0:
        return

    for member in members:
        print(member.display_name + " gained " + str(xp_per_member) + " XP!")
        for result in member.grant_xp(xp_per_member):
            var gains: Dictionary = result.gains
            print(member.display_name + " reached level " + str(result.level) + "!")
            print("  HP +" + str(gains.hp) + ", ATK +" + str(gains.attack) +
                  ", DEF +" + str(gains.defense))
```

Register as autoload `PartyManager`.

### Finishing Quest XP Integration

In Module 20, `QuestData` already had an `xp_reward` field, but `QuestManager.turn_in_quest_by_id()` intentionally left it unused because PartyManager did not exist yet. Now that the roster is in place, reopen `res://autoloads/quest_manager.gd` and update the reward section inside `turn_in_quest_by_id()`:

```gdscript
func turn_in_quest_by_id(quest_id: String) -> bool:
    var quest: QuestData = null
    for candidate in _completed_quests:
        if candidate.id == quest_id:
            quest = candidate
            break

    if not quest:
        return false

    _completed_quests.erase(quest)
    _turned_in_quests.append(quest)

    if quest.xp_reward > 0:
        PartyManager.award_xp_to_party(quest.xp_reward)
    if quest.gold_reward > 0:
        InventoryManager.add_gold(quest.gold_reward)
    for item in quest.reward_items:
        InventoryManager.add_item(item)
    if not quest.completion_flag.is_empty():
        GameManager.set_flag(quest.completion_flag)

    quest_turned_in.emit(quest)
    return true
```

This keeps quest turn-ins on the same leveling path as battle rewards. `PartyManager` owns "who gets XP," while `CharacterData.grant_xp()` still owns the actual leveling math from Module 18.

## Recruiting Lira

Create Lira's character data: right-click `res://data/characters/` → **New Resource** → search `CharacterData` → **Create** → name it `lira.tres`. Set ALL of these fields in the Inspector:
- `id`: "lira"
- `display_name`: "Lira"
- `max_hp`: 80, `max_mp`: 40
- `attack`: 6, `defense`: 5, `speed`: 9
- `hp_growth`: 8, `mp_growth`: 8, `attack_growth`: 1, `defense_growth`: 1, `speed_growth`: 2

> **Important:** The `id` field must be `"lira"` exactly. `PartyManager.get_member_by_id("lira")` uses this to find her. All growth rate fields must be non-zero or she won't gain stats on level-up (see Module 18).

Lira is a mage: lower HP and attack, higher MP and speed.

### The Recruitment Scene

In Willowbrook, add a new NPC: Lira. She joins the party after a dialogue exchange, gated by a game flag:

```gdscript
func _get_lira_dialogue() -> Array[DialogueLine]:
    if GameManager.has_flag("lira_joined"):
        return _make_lines("Lira", ["Ready to go when you are!"])

    if GameManager.has_flag("lira_ready_to_join"):
        return _make_lines("Lira", [
            "I've been studying the crystal formations nearby.",
            "They resonate with a strange energy...",
            "If you're heading to the Crystal Cavern, I'd like to come along.",
            "My magic could be useful!",
        ])

    if GameManager.has_flag("lira_intro_seen"):
        GameManager.set_flag("lira_ready_to_join")
        return _make_lines("Lira", [
            "I've been studying the crystal formations nearby.",
            "They resonate with a strange energy...",
            "If you're heading to the Crystal Cavern, I'd like to come along.",
            "My magic could be useful!",
        ])

    # First meeting
    GameManager.set_flag("lira_intro_seen")
    return _make_lines("Lira", [
        "Oh, hello! I'm Lira, a scholar from the capital.",
        "I came to Willowbrook to study the ancient crystals.",
        "Talk to me again if you're interested in what I've found.",
    ])
```

After the second conversation, trigger recruitment. This code goes in `willowbrook.gd`, which should have `@onready` references for the UI nodes (from Module 11 and this module):

```gdscript
@onready var _dialogue_box: Control = $DialogueBox  # From Module 11
@onready var _shop_ui: CanvasLayer = $ShopUI         # Instance of shop_ui.tscn (add to scene)
```

Add the recruitment wiring to the existing interaction handler:

```gdscript
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    # ... existing dialogue logic ...

    # Check for Lira recruitment after the second conversation
    if npc.npc_data.id == "lira" and GameManager.has_flag("lira_ready_to_join") and not GameManager.has_flag("lira_joined"):
        _dialogue_box.dialogue_finished.connect(_recruit_lira, CONNECT_ONE_SHOT)


func _recruit_lira() -> void:
    GameManager.set_flag("lira_joined")
    var lira: CharacterData = load("res://data/characters/lira.tres")
    if lira:
        PartyManager.add_member(lira)
        print("Lira joined the party!")
```

Update the battle initialization to use PartyManager instead of a hardcoded hero. In each area scene script that triggers battles (e.g., `crystal_cavern.gd` from Module 17), find the code that creates `var hero := BattlerData.new()` and replace the hero creation + `start_battle` call with:

```gdscript
# Build party BattlerData from PartyManager
var party_battlers: Array[BattlerData] = []
for char_data in PartyManager.get_members():
    var battler := BattlerData.new()
    battler.character_data = char_data
    battler.is_player_controlled = true
    party_battlers.append(battler)

# Use the full party instead of just [hero]
SceneManager.start_battle({party = party_battlers, enemies = enemy_battlers})
```

Apply this same change to the boss trigger (`boss_trigger.gd`) and any other script that calls `SceneManager.start_battle()`.

## Equipment System

In Final Fantasy IV, Cecil starts as a Dark Knight with heavy armor and a cursed sword. When he becomes a Paladin, his equipment changes completely and so does how he plays. Equipment is the most tangible form of character progression: the player can see their attack number go up and feel the difference in battle. It also drives the core economic loop: fight enemies, earn gold, buy better gear, fight harder enemies.

### Extending CharacterData

Add equipment slots to `character_data.gd`:

```gdscript
# Add to CharacterData
var equipped_weapon: ItemData = null
var equipped_armor: ItemData = null
var equipped_accessory: ItemData = null
# current_xp/current_hp/current_mp were introduced in Module 9 and used heavily in Module 18


func get_effective_attack() -> int:
    var bonus: int = equipped_weapon.attack_bonus if equipped_weapon else 0
    return attack + bonus


func get_effective_defense() -> int:
    var bonus: int = equipped_armor.defense_bonus if equipped_armor else 0
    bonus += equipped_accessory.defense_bonus if equipped_accessory else 0
    return defense + bonus


func get_effective_speed() -> int:
    var bonus: int = 0
    if equipped_accessory:
        bonus += equipped_accessory.speed_bonus
    return speed + bonus


func equip(item: ItemData) -> ItemData:
    ## Equips an item, returning the previously equipped item (or null).
    var previous: ItemData = null
    match item.equip_slot:
        ItemData.EquipSlot.WEAPON:
            previous = equipped_weapon
            equipped_weapon = item
        ItemData.EquipSlot.ARMOR:
            previous = equipped_armor
            equipped_armor = item
        ItemData.EquipSlot.ACCESSORY:
            previous = equipped_accessory
            equipped_accessory = item
    return previous


func unequip(slot: ItemData.EquipSlot) -> ItemData:
    var item: ItemData = null
    match slot:
        ItemData.EquipSlot.WEAPON:
            item = equipped_weapon
            equipped_weapon = null
        ItemData.EquipSlot.ARMOR:
            item = equipped_armor
            equipped_armor = null
        ItemData.EquipSlot.ACCESSORY:
            item = equipped_accessory
            equipped_accessory = null
    return item
```

### Creating Equipment Items

We need equipment the player can actually wear. If you created `iron_sword.tres` and `leather_armor.tres` back in Module 9, open them now and verify the equipment-specific fields match the values below. If you don't have them yet, create them now (right-click `res://data/items/` → New Resource → ItemData):

**Iron Sword** (`res://data/items/iron_sword.tres`):
- `id`: "iron_sword", `display_name`: "Iron Sword", `item_type`: EQUIPMENT, `equip_slot`: WEAPON, `attack_bonus`: 5, `buy_price`: 50, `sell_price`: 25

**Leather Armor** (`res://data/items/leather_armor.tres`):
- `id`: "leather_armor", `display_name`: "Leather Armor", `item_type`: EQUIPMENT, `equip_slot`: ARMOR, `defense_bonus`: 4, `buy_price`: 40, `sell_price`: 20

### The Complete Equip Flow

When equipping an item, the old item must return to inventory:

```gdscript
# Example: equipping from inventory (add to your equipment UI handler)
func _equip_item_on_character(character: CharacterData, item: ItemData) -> void:
    if not InventoryManager.remove_item(item):
        return

    var previous: ItemData = character.equip(item)
    if previous:
        InventoryManager.add_item(previous)
```

This three-step pattern (remove new item from inventory, equip it, add the old item back) prevents item duplication. The `equip()` method returns the old item so you always have a reference to it. If `remove_item()` returns `false`, stop before changing equipment.

### The Modifier Pattern (Looking Ahead)

Our equipment system uses simple addition: `effective_attack = base_attack + weapon.attack_bonus`. This works for Crystal Saga, but real RPGs need something more flexible. Consider: a spell that doubles your Attack for 3 turns, a poison that halves Speed, or a ring that adds +10% to all stats. Flat bonuses can't express percentages, and they don't stack cleanly with temporary buffs.

The standard solution is a **modifier system** where each modifier has two components:

- **add**: a flat bonus (e.g., +5 Attack from a sword)
- **mult**: a percentage multiplier (e.g., +0.25 for a 25% buff, -0.50 for a 50% debuff)

The formula: `final = (base + sum_of_adds) * (1.0 + sum_of_mults)`

All flat bonuses are summed first, then all percentage multipliers are applied together. This order matters: it makes percentage buffs more powerful (they multiply the total, not just the base), which is a deliberate design choice.

Each modifier gets a **unique ID**. This solves the stacking problem: two different +5 ATK swords stack (different IDs), but casting the same buff spell twice doesn't (same ID overwrites the previous instance).

We won't build this system for Crystal Saga; the simple `get_effective_*()` approach is sufficient. But if you later add status effects (Module 26 roadmap), buff/debuff spells, or set bonuses, the modifier system is the right abstraction. It lets equipment, spells, status effects, and passive abilities all feed into the same stat calculation through one unified mechanism.

### Battle Integration

Update BattlerData to use effective stats:

```gdscript
func initialize_from_character() -> void:
    if not character_data:
        return
    # Use current_hp/current_mp if set (carries over between battles)
    # Fall back to max values for the first battle or after a full heal
    current_hp = character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp
    current_mp = character_data.current_mp if character_data.current_mp > 0 else character_data.max_mp
    current_attack = character_data.get_effective_attack()
    current_defense = character_data.get_effective_defense()
    current_speed = character_data.get_effective_speed()
```

> **Important:** This ensures HP/MP carries over between battles. Module 18's Victory state syncs `battler.current_hp` back to `character_data.current_hp` after each fight. Without this check, the party would heal to full after every battle.

Now equipping a better sword directly increases damage in battle.

### Equipment UI

Create `res://ui/equipment/equipment_panel.tscn`:

```
EquipmentPanel (PanelContainer)
└── VBox (VBoxContainer)
    ├── NameLabel (Label)
    ├── StatsLabel (RichTextLabel)
    └── Slots (VBoxContainer)
        ├── WeaponButton (Button: "Weapon: None")
        ├── ArmorButton (Button: "Armor: None")
        └── AccessoryButton (Button: "Accessory: None")
```

Save the script as `res://ui/equipment/equipment_panel.gd`:

```gdscript
extends PanelContainer
## Equipment management for a party member.

signal equipment_changed

var _character: CharacterData

@onready var _name_label: Label = $VBox/NameLabel
@onready var _stats_label: RichTextLabel = $VBox/StatsLabel
@onready var _weapon_button: Button = $VBox/Slots/WeaponButton
@onready var _armor_button: Button = $VBox/Slots/ArmorButton
@onready var _accessory_button: Button = $VBox/Slots/AccessoryButton


func show_character(character: CharacterData) -> void:
    _character = character
    _refresh()


func _refresh() -> void:
    _name_label.text = _character.display_name + " (Lv. " + str(_character.level) + ")"
    _stats_label.text = (
        "HP: " + str(_character.max_hp) +
        "  ATK: " + str(_character.get_effective_attack()) +
        "  DEF: " + str(_character.get_effective_defense()) +
        "  SPD: " + str(_character.get_effective_speed())
    )
    _weapon_button.text = "Weapon: " + (_character.equipped_weapon.display_name if _character.equipped_weapon else "(none)")
    _armor_button.text = "Armor: " + (_character.equipped_armor.display_name if _character.equipped_armor else "(none)")
    _accessory_button.text = "Accessory: " + (_character.equipped_accessory.display_name if _character.equipped_accessory else "(none)")
```

### Slot Selection and Item Swapping

When the player clicks a slot button, show equipable items from inventory and allow swapping. Connect the button signals and add the selection logic:

```gdscript
func _ready() -> void:
    _weapon_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.WEAPON))
    _armor_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.ARMOR))
    _accessory_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.ACCESSORY))


func _on_slot_pressed(slot: ItemData.EquipSlot) -> void:
    # Get equipable items for this slot from inventory
    var equipable: Array = []
    for entry in InventoryManager.get_all_items():
        var item: ItemData = entry.item
        if item.item_type == ItemData.ItemType.EQUIPMENT and item.equip_slot == slot:
            equipable.append(item)

    if equipable.is_empty():
        print("No equipment for this slot in inventory.")
        return

    # Simple approach: equip the first matching item.
    # A full UI would show a selection list with stat comparisons.
    var item: ItemData = equipable[0]
    if not InventoryManager.remove_item(item):
        print("Could not equip " + item.display_name + ": item is no longer in inventory.")
        return

    var previous: ItemData = _character.equip(item)
    if previous:
        InventoryManager.add_item(previous)

    _refresh()
    equipment_changed.emit()
```

> **Exercise:** For a more polished experience, replace the "equip first item" logic with a popup list showing all matching items, their stats, and the stat difference compared to the current equipment. The inventory grid pattern from Module 12 works well for this.

We are not creating an accessory item in this module, so the new Accessory button will usually show `(none)` for now. That is expected. The point is to keep the teaching UI aligned with the `CharacterData` slot model you just added.

### Equipment Comparison: The PredictStats Pattern

Every JRPG shop and equipment screen answers the same question: "would this item make me stronger or weaker?" Showing red/green arrows next to stats is standard UX. The pattern for computing this is called **PredictStats**: calculate what the character's stats *would be* if they equipped a candidate item, without actually equipping it.

```gdscript
func predict_equip(candidate: ItemData) -> Dictionary:
    ## Returns a stat diff: positive values = improvement, negative = worse.
    ## Does NOT modify the character.
    var current_atk := get_effective_attack()
    var current_def := get_effective_defense()
    var current_spd := get_effective_speed()

    # Temporarily swap
    var slot := candidate.equip_slot
    var old_item: ItemData = null
    match slot:
        ItemData.EquipSlot.WEAPON:
            old_item = equipped_weapon
            equipped_weapon = candidate
        ItemData.EquipSlot.ARMOR:
            old_item = equipped_armor
            equipped_armor = candidate
        ItemData.EquipSlot.ACCESSORY:
            old_item = equipped_accessory
            equipped_accessory = candidate

    var diff := {
        attack = get_effective_attack() - current_atk,
        defense = get_effective_defense() - current_def,
        speed = get_effective_speed() - current_spd,
    }

    # Restore original equipment
    match slot:
        ItemData.EquipSlot.WEAPON:
            equipped_weapon = old_item
        ItemData.EquipSlot.ARMOR:
            equipped_armor = old_item
        ItemData.EquipSlot.ACCESSORY:
            equipped_accessory = old_item

    return diff
```

Usage in a shop or equipment UI:

```gdscript
var diff := character.predict_equip(iron_sword)
# diff = { attack = 5, defense = 0, speed = -1 }
# Display: ATK +5 (green arrow), DEF no change, SPD -1 (red arrow)
```

The key insight is the **temporarily swap, measure, restore** pattern. It reuses your existing `get_effective_*()` methods rather than duplicating the calculation logic. This means if you later add modifier stacking or set bonuses, the prediction stays accurate automatically.

## The Shop System

Secret of Mana's weapon shops in each town are progression gates disguised as stores. The player earns gold from battles and spends it on the next tier of weapons, creating a satisfying loop where exploration and combat feed back into power growth. Shops give the player agency over their build (do you buy a better sword for your fighter or a magic robe for your mage first?) and they anchor towns as meaningful destinations.

### ShopData Resource

Save as `res://resources/shop_data.gd`:

```gdscript
extends Resource
class_name ShopData
## Defines what a shop sells.

@export var shop_name: String = ""
@export var items_for_sale: Array[ItemData] = []
```

Create `res://data/shops/willowbrook_shop.tres`:
- Items: Potion, Ether, Iron Sword, Leather Armor

### Shop UI

Create `res://ui/shop/shop_ui.tscn`:

```
ShopUI (CanvasLayer, layer = 15)
└── Panel (PanelContainer, centered)
    └── Margin (MarginContainer)
        └── VBox (VBoxContainer)
            ├── ItemList (VBoxContainer)
            └── GoldLabel (Label: "Gold: 0")
```

Save the script as `res://ui/shop/shop_ui.gd`:

```gdscript
extends CanvasLayer
## Shop interface for buying items.

signal shop_closed

var _shop_data: ShopData

@onready var _item_list: VBoxContainer = $Panel/Margin/VBox/ItemList
@onready var _gold_label: Label = $Panel/Margin/VBox/GoldLabel


func _ready() -> void:
    # Must process while paused so the shop can receive input
    process_mode = Node.PROCESS_MODE_ALWAYS
    visible = false


func _unhandled_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        close_shop()
        get_viewport().set_input_as_handled()


func open_shop(shop_data: ShopData) -> void:
    _shop_data = shop_data
    visible = true
    get_tree().paused = true
    _refresh()


func close_shop() -> void:
    visible = false
    get_tree().paused = false
    shop_closed.emit()


func _refresh() -> void:
    for child in _item_list.get_children():
        child.queue_free()

    await get_tree().process_frame

    _gold_label.text = "Gold: " + str(InventoryManager.gold)

    for item in _shop_data.items_for_sale:
        var button := Button.new()
        button.text = item.display_name + " - " + str(item.buy_price) + "g"
        if InventoryManager.gold < item.buy_price:
            button.disabled = true
        button.pressed.connect(_buy_item.bind(item))
        _item_list.add_child(button)

    if _item_list.get_child_count() > 0:
        await get_tree().process_frame
        _item_list.get_child(0).grab_focus()


func _buy_item(item: ItemData) -> void:
    if InventoryManager.spend_gold(item.buy_price):
        InventoryManager.add_item(item)
        print("Bought " + item.display_name + "!")
        _refresh()
```

### Connecting the Shopkeeper

When the player interacts with the shopkeeper NPC, open the shop instead of regular dialogue:

```gdscript
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    if npc.npc_data.id == "shopkeeper":
        var shop_data: ShopData = load("res://data/shops/willowbrook_shop.tres")
        if shop_data:
            _shop_ui.open_shop(shop_data)
            return
    # ... normal dialogue handling ...
```

### The Innkeeper

The innkeeper is simpler, just a dialogue choice that costs gold and heals the party:

```gdscript
func _handle_inn(npc: CharacterBody2D) -> void:
    var lines := _make_lines("Old Brennan", [
        "Rest for the night? That'll be 10 gold.",
    ])
    # Add a choice to the last line
    lines[0].choices = ["Yes (10g)", "No thanks"]
    _dialogue_box.start_dialogue(lines)
    var choice: int = await _dialogue_box.choice_made

    if choice == 0:  # Yes
        if InventoryManager.spend_gold(10):
            for member in PartyManager.get_members():
                member.current_hp = member.max_hp
                member.current_mp = member.max_mp
            _dialogue_box.start_dialogue(_make_lines("Old Brennan", ["Rest well, traveler."]))
        else:
            _dialogue_box.start_dialogue(_make_lines("Old Brennan", ["Seems you're a bit short."]))
```

> **See:** [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html). PartyManager is a new autoload. This guide covers the autoload pattern.

> **See:** [GUI containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html). VBoxContainer and PanelContainer are used for the equipment and shop UIs.

> **See:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html). ShopData and CharacterData equipment slots both use the Resource pattern.

> **Note:** Selling items is left as an exercise. The pattern mirrors buying: show the player's inventory, select an item, add gold equal to half `buy_price`, remove the item from inventory.

## Autoload Reference Card (Updated)

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| GameManager | 20 | Game flags, world state tracking |
| QuestManager | 20 | Quest tracking, objective checking |
| **PartyManager** | **21** | **Party roster, recruitment, stats** |

## Engineering Contract

- **Global state:** PartyManager owns the runtime party roster.
- **Public surface:** `add_member()`, `remove_member()`, `get_members()`, `get_member_by_id()`, equipment APIs, shop open/buy flows.
- **Invariant:** Equipping consumes the new item before mutating the character, then returns the old item to inventory.
- **Failure behavior:** Failed inventory removal aborts equip instead of granting free gear.
- **Copy semantics:** `get_members()` returns a defensive array copy; CharacterData members inside it are live runtime objects.

## Engine Gotcha

Pausing with `get_tree().paused = true` pauses most nodes. Shop and equipment UI that must keep responding while paused need `process_mode = Node.PROCESS_MODE_ALWAYS`.

## What We've Learned

- **PartyManager** autoload tracks the roster of party members.
- **PartyManager.award_xp_to_party()** lets quest rewards reuse the same level-up path battles already use.
- **Recruitment** is triggered by dialogue + game flags, and the NPC becomes a party member.
- **Equipment** modifies effective stats. `get_effective_attack()` = base + weapon bonus.
- **PredictStats pattern:** temporarily swap equipment, measure the difference, restore the original. This lets shop and equipment UIs show green/red stat comparison arrows without committing the change.
- **The modifier pattern** (looking ahead): equipment bonuses, spell buffs, and status effects can all feed into stats through a unified `add`/`mult` modifier system. Not needed for Crystal Saga's scope, but essential for larger RPGs.
- **Equip/unequip** removes the new item from inventory first, then equips it, then returns the old item. If removal fails, equipment does not change.
- **Shops** use a ShopData resource listing items with prices.
- **The inn** is a dialogue choice that costs gold and restores HP/MP.
- All these systems build on previous modules: Resources (Module 9), dialogue (Module 11), inventory (Module 12), flags (Module 20).

## What You Should See

- Talking to Lira once introduces her, and the second conversation recruits her into the party
- The equipment panel shows the selected character's stats plus weapon, armor, and accessory slots. The accessory slot will stay `(none)` until you add an accessory item later
- Equipping a sword increases ATK in the stats display and in battle
- The shopkeeper opens a buy menu with prices
- The innkeeper offers rest for 10 gold and heals the party
- Lira appears in battle as a second party member once she joins

## Next Module

All game systems are in place. In **Module 22: Save and Load**, we'll persist everything (position, inventory, quests, party, equipment, flags) to JSON files, with save crystals in the world and multiple save slots.

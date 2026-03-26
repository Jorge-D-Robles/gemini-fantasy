# Module 17: Party Management, Equipment, and Shops

## What We Have So Far

Quests, game flags, reactive dialogue, a dungeon with a boss, a battle system with leveling. The hero has been fighting alone.

## What We're Building This Module

Three major systems: **party management** (recruiting Lira the mage), **equipment** (weapons and armor that modify stats), and **shops** (buying and selling). These are the final progression systems.

## PartyManager Autoload

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
    return members


func get_member_by_id(id: String) -> CharacterData:
    for member in members:
        if member.id == id:
            return member
    return null
```

Register as autoload `PartyManager`.

## Recruiting Lira

Create Lira's character data at `res://data/characters/lira.tres`:
- display_name: "Lira"
- max_hp: 80, max_mp: 40
- attack: 6, defense: 5, speed: 9
- hp_growth: 8, mp_growth: 8, attack_growth: 1, defense_growth: 1

Lira is a mage — lower HP and attack, higher MP and speed.

### The Recruitment Scene

In Willowbrook, add a new NPC: Lira. She joins the party after a dialogue exchange, gated by a game flag:

```gdscript
func _get_lira_dialogue() -> Array[DialogueLine]:
    if GameManager.has_flag("lira_joined"):
        return _make_lines("Lira", ["Ready to go when you are!"])

    if GameManager.has_flag("talked_to_lira"):
        return _make_lines("Lira", [
            "I've been studying the crystal formations nearby.",
            "They resonate with a strange energy...",
            "If you're heading to the Crystal Cavern, I'd like to come along.",
            "My magic could be useful!",
        ])

    # First meeting
    GameManager.set_flag("talked_to_lira")
    return _make_lines("Lira", [
        "Oh, hello! I'm Lira, a scholar from the capital.",
        "I came to Willowbrook to study the ancient crystals.",
        "Talk to me again if you're interested in what I've found.",
    ])
```

After the second conversation, trigger recruitment. This code goes in `willowbrook.gd`, which should have `@onready` references for the UI nodes (from Modules 9 and this module):

```gdscript
@onready var _dialogue_box: Control = $DialogueBox  # From Module 9
@onready var _shop_ui: CanvasLayer = $ShopUI         # Instance of shop_ui.tscn (add to scene)
```

Add the recruitment wiring to the existing interaction handler:

```gdscript
func _on_npc_interacted(npc: CharacterBody2D) -> void:
    # ... existing dialogue logic ...

    # Check for Lira recruitment after dialogue
    if npc.npc_data.id == "lira" and GameManager.has_flag("talked_to_lira") and not GameManager.has_flag("lira_joined"):
        _dialogue_box.dialogue_finished.connect(_recruit_lira, CONNECT_ONE_SHOT)


func _recruit_lira() -> void:
    GameManager.set_flag("lira_joined")
    var lira: CharacterData = load("res://data/characters/lira.tres")
    if lira:
        PartyManager.add_member(lira)
        print("Lira joined the party!")
```

Update the battle initialization to use PartyManager instead of a hardcoded hero. In each area scene script that triggers battles (e.g., `crystal_cavern.gd` from Module 14), find the code that creates `var hero := BattlerData.new()` and replace the hero creation + `start_battle` call with:

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

### Extending CharacterData

Add equipment slots to `character_data.gd`:

```gdscript
# Add to CharacterData
var equipped_weapon: ItemData = null
var equipped_armor: ItemData = null
var equipped_accessory: ItemData = null
# current_xp was already added in Module 15


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

> **Important:** This ensures HP/MP carries over between battles. Module 15's Victory state syncs `battler.current_hp` back to `character_data.current_hp` after each fight. Without this check, the party would heal to full after every battle.

Now equipping a better sword directly increases damage in battle.

### Equipment UI

Create `res://ui/equipment/equipment_panel.tscn`:

```
EquipmentPanel (PanelContainer)
└── VBox (VBoxContainer)
    ├── NameLabel (Label)
    ├── StatsLabel (RichTextLabel)
    └── Slots (VBoxContainer)
        ├── WeaponButton (Button: "Weapon: ---")
        └── ArmorButton (Button: "Armor: ---")
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
```

When the player selects a slot, show equipable items from inventory and allow swapping.

## The Shop System

### ShopData Resource

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
        button.text = item.display_name + " — " + str(item.buy_price) + "g"
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

The innkeeper is simpler — a dialogue choice that costs gold and heals the party:

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

> **See:** [Singletons (Autoload)](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html) — PartyManager is a new autoload. This guide covers the autoload pattern.

> **See:** [GUI containers](https://docs.godotengine.org/en/stable/tutorials/ui/gui_containers.html) — VBoxContainer and PanelContainer used for the equipment and shop UIs.

> **See:** [Resources](https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html) — ShopData and CharacterData equipment slots both use the Resource pattern.

> **Note:** Selling items is left as an exercise. The pattern mirrors buying: show the player's inventory, select an item, add gold equal to half `buy_price`, remove the item from inventory.

## Autoload Reference Card (Updated)

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 6 | Scene transitions with fade effects |
| InventoryManager | 10 | Item storage, add/remove, signals |
| GameManager | 16 | Game flags, world state tracking |
| QuestManager | 16 | Quest tracking, objective checking |
| **PartyManager** | **17** | **Party roster, recruitment, stats** |

## What We've Learned

- **PartyManager** autoload tracks the roster of party members.
- **Recruitment** is triggered by dialogue + game flags — the NPC becomes a party member.
- **Equipment** modifies effective stats. `get_effective_attack()` = base + weapon bonus.
- **Equip/unequip** swaps items between the character and inventory.
- **Shops** use a ShopData resource listing items with prices.
- **The inn** is a dialogue choice that costs gold and restores HP/MP.
- All these systems build on previous modules: Resources (7), dialogue (9), inventory (10), flags (16).

## What You Should See

- Talking to Lira twice recruits her into the party
- The party menu shows both characters with stats and equipment
- Equipping a sword increases ATK in the stats display and in battle
- The shopkeeper opens a buy menu with prices
- The innkeeper offers rest for 10 gold and heals the party
- Lira appears in battle with her own abilities

## Next Module

All game systems are in place. In **Module 18: Save and Load**, we'll persist everything — position, inventory, quests, party, equipment, flags — to JSON files, with save crystals in the world and multiple save slots.

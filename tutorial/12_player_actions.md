# Module 12: Player Actions — Attack, Defend, Magic, Items

## What We Have So Far

A battle system with a node-based state machine, turn order, and automatic combat. But the player can't make choices — everything happens automatically.

## What We're Building This Module

The battle menu (Attack/Magic/Defend/Item), target selection, the damage formula, battle animations, and floating damage numbers. By the end, battles will be fully interactive.

## The Battle Menu UI

Create `res://ui/battle/battle_menu.tscn`:

```
BattleMenu (PanelContainer)
└── MarginContainer
    └── ActionList (VBoxContainer)
        ├── AttackButton (Button: "Attack")
        ├── MagicButton (Button: "Magic")
        ├── DefendButton (Button: "Defend")
        └── ItemButton (Button: "Item")
```

Script `res://ui/battle/battle_menu.gd`:

```gdscript
extends PanelContainer
## The main battle action menu.

signal action_chosen(action: String)

@onready var _attack_btn: Button = $MarginContainer/ActionList/AttackButton
@onready var _magic_btn: Button = $MarginContainer/ActionList/MagicButton
@onready var _defend_btn: Button = $MarginContainer/ActionList/DefendButton
@onready var _item_btn: Button = $MarginContainer/ActionList/ItemButton


func _ready() -> void:
    _attack_btn.pressed.connect(func() -> void: action_chosen.emit("attack"))
    _magic_btn.pressed.connect(func() -> void: action_chosen.emit("magic"))
    _defend_btn.pressed.connect(func() -> void: action_chosen.emit("defend"))
    _item_btn.pressed.connect(func() -> void: action_chosen.emit("item"))


func show_menu() -> void:
    visible = true
    _attack_btn.grab_focus()


func hide_menu() -> void:
    visible = false
```

> **See:** [GUI navigation](https://docs.godotengine.org/en/stable/tutorials/ui/gui_navigation.html) — focus navigation between buttons with keyboard/gamepad.

## The Command Pattern

Each battle action follows the same interface: an attacker does something to a target. We structure this as a dictionary command:

```gdscript
var command: Dictionary = {
    action = "attack",     # What to do
    battler = battler,     # Who does it
    target = target,       # Who receives it
    ability = null,        # Optional: which ability (for magic)
    item = null,           # Optional: which item (for item use)
}
```

This pattern keeps the action execution generic. The `ActionExecute` state doesn't need to know the details of every possible action — it just reads the command dictionary.

## Target Selection

When the player chooses Attack, they need to pick which enemy to target. Create a target selection sub-system:

```gdscript
extends PanelContainer
## Shows a list of targets for the player to select.

signal target_selected(target: BattlerData)
signal cancelled

@onready var _target_list: VBoxContainer = $MarginContainer/TargetList


func show_targets(targets: Array[BattlerData]) -> void:
    visible = true

    for child in _target_list.get_children():
        child.queue_free()

    await get_tree().process_frame

    for target in targets:
        var button := Button.new()
        button.text = target.character_data.display_name + " (HP: " + str(target.current_hp) + ")"
        button.pressed.connect(func() -> void: target_selected.emit(target))
        _target_list.add_child(button)

    await get_tree().process_frame
    if _target_list.get_child_count() > 0:
        _target_list.get_child(0).grab_focus()


func hide_targets() -> void:
    visible = false


func _unhandled_input(event: InputEvent) -> void:
    if visible and event.is_action_pressed("ui_cancel"):
        cancelled.emit()
        get_viewport().set_input_as_handled()
```

Save this as `res://ui/battle/target_select.gd`, and create `res://ui/battle/target_select.tscn` with this scene tree:

```
TargetSelect (PanelContainer)
└── MarginContainer
    └── TargetList (VBoxContainer)
```

## Integrating the Battle Menu into the Battle Scene

Open `battle.tscn` and instance both UI scenes under the `BattleUI` CanvasLayer:

```
BattleUI (CanvasLayer, layer = 10)
├── BattleMenu (instance of battle_menu.tscn)
└── TargetSelect (instance of target_select.tscn)
```

Set both to **visible = false** initially in the Inspector.

## Updating the PlayerChoice State

This is the critical wiring that connects the menu to the state machine. **Replace** the contents of `res://systems/battle/states/player_choice_state.gd` (the Module 11 placeholder that auto-attacked):

```gdscript
extends BattleState
## Waits for the player to choose an action from the battle menu.

var _active_battler: BattlerData
var _battle_menu: PanelContainer
var _target_select: PanelContainer


func enter(context: Dictionary = {}) -> void:
    _active_battler = context.get("battler")

    # Find UI nodes in the battle scene
    _battle_menu = get_tree().current_scene.get_node("BattleUI/BattleMenu")
    _target_select = get_tree().current_scene.get_node("BattleUI/TargetSelect")

    # Connect signals
    _battle_menu.action_chosen.connect(_on_action_chosen)
    _target_select.target_selected.connect(_on_target_selected)
    _target_select.cancelled.connect(_on_target_cancelled)

    _battle_menu.show_menu()


func exit() -> void:
    _battle_menu.hide_menu()
    _target_select.hide_targets()

    # Disconnect to avoid duplicate connections on re-entry
    if _battle_menu.action_chosen.is_connected(_on_action_chosen):
        _battle_menu.action_chosen.disconnect(_on_action_chosen)
    if _target_select.target_selected.is_connected(_on_target_selected):
        _target_select.target_selected.disconnect(_on_target_selected)
    if _target_select.cancelled.is_connected(_on_target_cancelled):
        _target_select.cancelled.disconnect(_on_target_cancelled)


func _on_action_chosen(action: String) -> void:
    match action:
        "attack":
            _battle_menu.hide_menu()
            _target_select.show_targets(battle_manager.get_alive_enemies())
        "defend":
            battle_manager._state_machine.transition_to("ActionExecute", {
                battler = _active_battler,
                action = "defend",
            })
        "magic":
            # Magic system not yet implemented — placeholder
            print("Magic not yet available!")
            _battle_menu.show_menu()
        "item":
            # Item use in battle — simplified for now
            var consumables := InventoryManager.get_consumables()
            if consumables.is_empty():
                print("No items!")
                _battle_menu.show_menu()
            else:
                # Use first consumable on self (simplified)
                var item: ItemData = consumables[0].item
                battle_manager._state_machine.transition_to("ActionExecute", {
                    battler = _active_battler,
                    action = "item",
                    target = _active_battler,
                    item = item,
                })


func _on_target_selected(target: BattlerData) -> void:
    _target_select.hide_targets()
    battle_manager._state_machine.transition_to("ActionExecute", {
        battler = _active_battler,
        action = "attack",
        target = target,
    })


func _on_target_cancelled() -> void:
    _target_select.hide_targets()
    _battle_menu.show_menu()
```

This wires the complete flow: menu appears → player picks action → target selection if needed → command passed to ActionExecute.

> **Note:** Magic and item selection are simplified placeholders. Magic is disabled until we define AbilityData (a stretch goal). Item use picks the first consumable automatically — in a full game, you'd show an item selection sub-menu.

## The Damage Formula

A damage formula should be simple to understand, produce meaningful numbers, and allow for strategic depth. Here's ours:

```gdscript
static func calculate_damage(attacker: BattlerData, target: BattlerData) -> int:
    var raw: int = attacker.current_attack - target.get_effective_defense()
    var variance: int = randi_range(-2, 2)
    return max(1, raw + variance)
```

This means:
- **Raw damage** = attacker's attack minus target's effective defense
- **Variance** adds ±2 randomness
- **Minimum damage** is always 1 (you always do at least something)

The Defend action increases `defense_boost`, making `get_effective_defense()` return a higher value, reducing incoming damage.

> **JRPG Pattern:** Most JRPGs keep their damage formula visible and understandable. Players should be able to reason about "if I equip this sword (+5 attack), I'll do roughly 5 more damage per hit." Complex formulas with hidden multipliers frustrate players.

## Implementing All Actions

Update the `ActionExecute` state to handle each action:

```gdscript
extends BattleState
## Executes the chosen action with animation.

func enter(context: Dictionary = {}) -> void:
    var battler: BattlerData = context.get("battler")
    var action: String = context.get("action", "attack")
    var target: BattlerData = context.get("target")
    var ability = context.get("ability")
    var item = context.get("item")

    match action:
        "attack":
            await _execute_attack(battler, target)
        "defend":
            _execute_defend(battler)
        "magic":
            await _execute_magic(battler, target, ability)
        "item":
            _execute_item(battler, target, item)
        "enemy_turn":
            await _execute_enemy_turn(battler)

    await get_tree().create_timer(0.3).timeout
    battle_manager._state_machine.transition_to("CheckResult")


func _execute_attack(attacker: BattlerData, target: BattlerData) -> void:
    var damage := max(1, attacker.current_attack - target.get_effective_defense() + randi_range(-2, 2))
    damage = max(1, damage)

    await _play_attack_animation(attacker)
    var actual := target.take_damage(damage)
    _spawn_damage_number(target, actual)
    battle_manager.action_executed.emit(attacker, target, actual)


func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense  # Double defense for one turn
    print(battler.character_data.display_name + " defends!")


func _execute_magic(caster: BattlerData, target: BattlerData, ability: Resource) -> void:
    if not ability:
        return
    # We'll flesh this out with AbilityData in a later module
    var damage: int = ability.power - target.get_effective_defense()
    damage = max(1, damage)
    var actual := target.take_damage(damage)
    caster.current_mp -= ability.mp_cost
    _spawn_damage_number(target, actual)


func _execute_item(user: BattlerData, target: BattlerData, item: ItemData) -> void:
    if not item:
        return
    if item.hp_restore > 0:
        var healed := target.heal(item.hp_restore)
        _spawn_damage_number(target, healed, true)
    InventoryManager.remove_item(item)


func _execute_enemy_turn(battler: BattlerData) -> void:
    var targets := battle_manager.get_alive_party()
    if targets.is_empty():
        return
    var target: BattlerData = targets[randi() % targets.size()]
    await _execute_attack(battler, target)
```

## Battle Animations with Tweens

Animations make combat feel impactful. The classic JRPG attack animation: the attacker slides forward, pauses, then slides back.

```gdscript
func _play_attack_animation(attacker: BattlerData) -> void:
    # Find the attacker's sprite node in the scene
    var sprite_node := _find_battler_sprite(attacker)
    if not sprite_node:
        return

    var original_pos: Vector2 = sprite_node.global_position
    var target_pos: Vector2 = original_pos + Vector2(-30, 0)  # Slide left toward enemies

    if not attacker.is_player_controlled:
        target_pos = original_pos + Vector2(30, 0)  # Enemies slide right

    var tween := create_tween()
    tween.tween_property(sprite_node, "global_position", target_pos, 0.15)
    tween.tween_interval(0.1)  # Brief pause at the target
    tween.tween_property(sprite_node, "global_position", original_pos, 0.15)
    await tween.finished


func _find_battler_sprite(battler: BattlerData) -> Node2D:
    for sprite in get_tree().get_nodes_in_group("battler_sprites"):
        if sprite.battler_data == battler:
            return sprite
    return null
```

> **See:** [Tween](https://docs.godotengine.org/en/stable/classes/class_tween.html) — `tween_property()`, `tween_interval()`, chaining, and `await finished`.

## Floating Damage Numbers

A small label that rises and fades when damage is dealt:

```gdscript
func _spawn_damage_number(target: BattlerData, amount: int, is_heal: bool = false) -> void:
    var sprite_node := _find_battler_sprite(target)
    if not sprite_node:
        return

    var label := Label.new()
    label.text = str(amount)
    label.add_theme_color_override("font_color", Color.GREEN if is_heal else Color.WHITE)
    label.global_position = sprite_node.global_position + Vector2(0, -20)
    label.z_index = 100
    get_tree().current_scene.add_child(label)

    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(label, "position:y", label.position.y - 30.0, 0.8)
    tween.tween_property(label, "modulate:a", 0.0, 0.8)
    tween.chain().tween_callback(label.queue_free)
```

This creates a label that floats upward and fades out over 0.8 seconds, then removes itself.

> **Note:** `set_parallel(true)` makes the next tweens run simultaneously (moving up AND fading at the same time). `chain()` returns to sequential mode for the cleanup callback.

## The Defend Action as a Temporary Buff

Defend doubles the battler's defense for one turn:

```gdscript
func _execute_defend(battler: BattlerData) -> void:
    battler.defense_boost = battler.current_defense
```

The boost is reset at the start of the battler's next turn (in the turn processing logic):

```gdscript
battler.defense_boost = 0  # Reset before the battler acts
```

This is the simplest form of a temporary status effect. In Module 21 (Next Steps), we'll discuss generalizing this into a full status effects system with poison, sleep, buffs, and debuffs.

## What We've Learned

- The **battle menu** uses VBoxContainer with Buttons and `grab_focus()` for keyboard navigation.
- **Target selection** presents enemy names as buttons; cancelling returns to the menu.
- The **command pattern** represents actions as dictionaries: `{action, battler, target, ability, item}`.
- **Damage formula:** `max(1, attack - defense + random_variance)` — simple, transparent, extensible.
- **Battle animations** use Tweens: slide forward → pause → slide back.
- **Floating damage numbers** rise and fade using parallel tweens.
- **Defend** is a temporary defense buff — the simplest status effect pattern.
- `set_parallel(true)` and `chain()` control Tween sequencing.

## What You Should See

When a battle starts:
- A menu appears: Attack / Magic / Defend / Item
- Selecting Attack shows enemy targets
- Choosing a target plays a slide animation and shows a damage number
- Defend doubles defense for one turn
- Using an Item consumes it from inventory
- The enemy takes its turn automatically
- Combat feels responsive and interactive

## Next Module

We have interactive battles, but we're fighting placeholder Slimes with a debug key. In **Module 13: The Crystal Cavern**, we'll build a dungeon with its own tilemap, encounter zones, treasure chests, and a boss room — giving the battle system a proper home.

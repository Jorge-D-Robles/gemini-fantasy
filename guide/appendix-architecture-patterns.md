# Appendix A: Architecture Patterns

Quick reference for every design pattern used throughout this guide. Each entry includes a one-paragraph description, when to use it, a minimal code skeleton, and which chapters cover it in detail.

---

## Signal Pattern

Decoupled, one-to-many communication between nodes. The emitter declares a signal and emits it when something happens. Listeners connect to the signal without the emitter knowing who they are. This is the Godot equivalent of DOM events, Angular EventEmitters, or RxJS Observables.

**When to use:** Whenever one system needs to notify others without depending on them. UI updates from data changes, quest tracking from gameplay events, audio triggers from game actions.

```gdscript
# Emitter
signal health_changed(new_hp: int, max_hp: int)

func take_damage(amount: int) -> void:
	current_hp -= amount
	health_changed.emit(current_hp, max_hp)


# Listener
func _ready() -> void:
	battler.health_changed.connect(_on_health_changed)

func _on_health_changed(new_hp: int, max_hp: int) -> void:
	health_bar.value = new_hp
```

**Chapters:** 1, 7, 10, 14, 16, 18

---

## Autoload Singleton

A script registered in Project Settings that Godot instantiates once at startup and makes globally accessible by name. Used for game-wide services that any script needs to reach — state management, audio, inventory, save/load.

**When to use:** When a service must persist across scene changes and be accessible from any script. Limit to true cross-cutting concerns — not every class needs to be an autoload.

```gdscript
# autoloads/inventory_manager.gd
extends Node
# No class_name — autoloads are global by registration name

signal inventory_changed

var _items: Dictionary = {}

func add_item(id: StringName, count: int = 1) -> void:
	_items[id] = _items.get(id, 0) + count
	inventory_changed.emit()


# Any script, anywhere:
InventoryManager.add_item(&"potion", 3)
```

**Chapters:** 3, 7, 9, 13, 14, 15, 17

---

## State Machine

A node-based pattern for managing mutually exclusive states with explicit transitions. A `StateMachine` parent holds `State` children. Only one state is active at a time. Transitions call `exit()` on the old state and `enter()` on the new one.

**When to use:** Whenever an entity can be in exactly one mode at a time — game states (overworld/battle/dialogue/menu), battle phases (player turn/enemy turn/animating), NPC behavior (idle/patrol/interact).

```gdscript
# systems/state_machine.gd
class_name StateMachine
extends Node

signal state_changed(old_state: State, new_state: State)

@export var initial_state: State
var current_state: State


func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			child.state_machine = self
	if initial_state:
		current_state = initial_state
		current_state.enter({})


func transition_to(state_name: StringName, data: Dictionary = {}) -> void:
	var new_state := get_node_or_null(NodePath(state_name)) as State
	if not new_state:
		push_error(str(state_name) + " not found")
		return
	if new_state == current_state:
		return
	var old := current_state
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(data)
	state_changed.emit(old, new_state)
```

**Chapters:** 10, 11, 16

---

## Strategy Pattern

Swappable behavior injected via a Resource property. The host node delegates a specific behavior to a strategy object, allowing different instances to behave differently without subclassing.

**When to use:** When multiple instances of the same node type need different behaviors — interactable objects (chest vs sign vs save point), enemy AI types, NPC interaction modes.

```gdscript
# resources/interaction_strategy.gd
class_name InteractionStrategy
extends Resource

func execute(interactable: Node, player: Node) -> void:
	pass  # Override in subclasses


# strategies/chest_strategy.gd
class_name ChestStrategy
extends InteractionStrategy

@export var item_id: StringName
@export var quantity: int = 1

func execute(interactable: Node, player: Node) -> void:
	InventoryManager.add_item(item_id, quantity)
	interactable.set_opened()


# Usage: assign strategy via @export in the editor or in code
interactable.strategy = ChestStrategy.new()
```

**Chapters:** 8

---

## Factory Methods

Static constructor functions on data classes that create instances with validated fields. Centralizes object creation, prevents invalid state, and provides a clean API for tests.

```gdscript
class_name DialogueLine
extends Resource

@export var speaker: String
@export var text: String
@export var portrait: Texture2D
@export var choices: Array[String]


static func create(
	speaker: String,
	text: String,
	portrait: Texture2D = null,
	choices: Array[String] = [],
) -> DialogueLine:
	var line := DialogueLine.new()
	line.speaker = speaker
	line.text = text
	line.portrait = portrait
	line.choices = choices
	return line
```

**Chapters:** 7, 20

---

## Static Utility Classes

Pure functions with no instance state, grouped by domain. Take inputs, return outputs, produce no side effects. The most testable pattern in the codebase.

**When to use:** Math formulas, damage calculations, status effect logic, any computation that does not depend on the scene tree or game state.

```gdscript
# systems/battle/battler_damage.gd
class_name BattlerDamage
extends RefCounted

static func calculate_outgoing(
	base: int,
	stat: int,
	resonance_state: int,
	is_ability: bool,
) -> int:
	var effective_stat := stat
	if resonance_state == 3:  # HOLLOW
		effective_stat = int(stat * 0.5)
	var damage: int = base + int(effective_stat * 0.5)
	if resonance_state == 2:  # OVERLOAD
		damage *= 2
	elif resonance_state == 1 and is_ability:  # RESONANT
		damage = int(damage * 1.2)
	return damage
```

**Chapters:** 11, 12, 20

---

## Resource Inheritance

GDScript's `extends` keyword works on custom Resource classes, creating a type hierarchy for related data. A base class defines shared fields; subclasses add specialized fields.

**When to use:** When you have a family of data types that share a common interface but have type-specific fields — BattlerData (base) → CharacterData (adds level, XP, growth rates) and EnemyData (adds AI type, loot table).

```gdscript
# resources/battler_data.gd
class_name BattlerData
extends Resource

@export var id: StringName
@export var display_name: String
@export var max_hp: int
@export var attack: int
@export var defense: int
@export var abilities: Array[Resource]


# resources/character_data.gd
class_name CharacterData
extends BattlerData

@export var level: int = 1
@export var current_xp: int = 0
@export var hp_growth: float = 10.0


# resources/enemy_data.gd
class_name EnemyData
extends BattlerData

@export var ai_type: AiType = AiType.BASIC
@export var exp_reward: int = 0
@export var gold_reward: int = 0
@export var loot_table: Array[Dictionary] = []

enum AiType { BASIC, AGGRESSIVE, DEFENSIVE, HEALER, BOSS }
```

**Chapters:** 6, 9, 12

---

## EventBus

A centralized signal relay autoload. Entities emit domain events through the bus instead of (or in addition to) their own signals. Decoupled systems connect to the bus to react to events without knowing the source.

**When to use:** When multiple unrelated systems need to react to the same gameplay event — quest tracking, achievement logging, analytics, UI notifications. Not for tight coupling between two specific systems (use direct signals for that).

```gdscript
# autoloads/event_bus.gd
extends Node

signal enemy_defeated(enemy_id: StringName)
signal item_acquired(item_id: StringName, quantity: int)
signal npc_interaction_ended(npc_name: String)
signal area_entered(area_name: String)

func emit_enemy_defeated(enemy_id: StringName) -> void:
	enemy_defeated.emit(enemy_id)


# In battle resolution:
EventBus.emit_enemy_defeated(&"creeping_vine")

# In quest manager:
func _ready() -> void:
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
```

**Chapters:** 14, 16

---

## State Stack

A push/pop stack for game states that enables nested state transitions with clean unwinding. When you enter dialogue during overworld, you push DIALOGUE. When dialogue ends, you pop back to OVERWORLD. If a cutscene triggers during dialogue, you push CUTSCENE on top.

**When to use:** When game states can nest — overworld → dialogue → choice, or overworld → battle → pause menu.

```gdscript
var current_state: GameState = GameState.OVERWORLD
var _state_stack: Array[GameState] = []

func push_state(new_state: GameState) -> void:
	_state_stack.push_back(current_state)
	var old_state := current_state
	current_state = new_state
	game_state_changed.emit(old_state, new_state)

func pop_state() -> void:
	if _state_stack.is_empty():
		push_warning("State stack is empty")
		return
	var old_state := current_state
	current_state = _state_stack.pop_back()
	game_state_changed.emit(old_state, current_state)
```

**Chapters:** 5, 10, 21

---

## Serialize / Deserialize Protocol

A convention where saveable objects implement `serialize() -> Dictionary` and `deserialize(data: Dictionary)` methods. SaveManager calls these to gather game state into JSON-compatible dictionaries and restore them later.

**When to use:** On every autoload or system that holds persistent state — party, inventory, equipment, quests, event flags, reputation, bonds.

```gdscript
# In EquipmentManager:
func serialize() -> Dictionary:
	var data: Dictionary = {}
	for character_id: StringName in _equipment:
		var slots: Dictionary = _equipment[character_id]
		data[str(character_id)] = {
			"weapon": str(slots.get("weapon", {}).get("id", "")),
			"helmet": str(slots.get("helmet", {}).get("id", "")),
			"chest": str(slots.get("chest", {}).get("id", "")),
			"accessory_0": str(slots.get("accessory_0", {}).get("id", "")),
			"accessory_1": str(slots.get("accessory_1", {}).get("id", "")),
		}
	return data

func deserialize(data: Dictionary) -> void:
	_equipment.clear()
	for character_id: String in data:
		var slots: Dictionary = data[character_id]
		for slot_name: String in slots:
			var item_id: String = slots[slot_name]
			if item_id.is_empty():
				continue
			var equipment := load("res://data/equipment/%s.tres" % item_id)
			if equipment:
				equip(StringName(character_id), equipment)
```

**Chapters:** 15

---

## Observer Pattern (via Signals)

Signals implement the Observer pattern natively. When data changes, the data owner emits a signal. UI elements and other systems observe the signal and react. This keeps data owners unaware of their observers.

**When to use:** Reactive UI updates — health bar reacts to HP changes, inventory screen reacts to item changes, quest tracker reacts to objective completion.

```gdscript
# Data owner:
signal inventory_changed

func add_item(id: StringName, count: int = 1) -> void:
	_items[id] = _items.get(id, 0) + count
	inventory_changed.emit()


# UI observer:
func _ready() -> void:
	InventoryManager.inventory_changed.connect(_refresh_display)

func _refresh_display() -> void:
	_rebuild_item_list()
```

**Chapters:** 13, 18

---

## Component Composition

Building game entities from reusable, focused child nodes rather than through inheritance. Each child handles one concern — collision, sprites, interaction detection, AI. The parent scene composes them into a complete entity.

**When to use:** Always. This is the default approach in Godot. A Player is a CharacterBody2D composed with a CollisionShape2D, AnimatedSprite2D, RayCast2D, and Camera2D. An NPC is a StaticBody2D composed with a CollisionShape2D, Sprite2D, and interaction Area2D.

```
Player (CharacterBody2D)
├── CollisionShape2D        # Physics
├── AnimatedSprite2D         # Visuals
├── InteractionRay (RayCast2D)  # Interaction detection
└── Camera2D                 # Camera follow

NPC (StaticBody2D)
├── CollisionShape2D        # Physics
├── Sprite2D                # Visuals
├── InteractionArea (Area2D)  # Detectable by player ray
│   └── CollisionShape2D
└── QuestIndicator (Sprite2D) # Visual indicator
```

**Chapters:** 3, 7, 8

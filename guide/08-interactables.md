# Chapter 8 — Interactables and the Strategy Pattern

Your game world has NPCs. But a JRPG world also has chests to open, signs to read, doors to enter, and save points to activate. Each of these needs an `interact()` method so the player's RayCast2D can trigger it — but each does something completely different when activated.

You could create separate scene classes: `Chest extends StaticBody2D`, `Sign extends StaticBody2D`, `Door extends StaticBody2D`, `SavePoint extends StaticBody2D`. But that is four classes with nearly identical scene trees (collision shape, sprite, interaction area) and only one method that differs. You would be duplicating structure to vary behavior.

The solution is the **Strategy pattern** — a single `Interactable` entity that delegates its behavior to a pluggable Resource. Swap the Resource, swap the behavior. One scene, many uses.

If you come from Angular, this is exactly like content projection combined with a service interface. The component (Interactable) handles the container concerns — collision, sprite, interaction detection. The strategy (a Resource subclass) handles the business logic. You inject the strategy via an `@export`, which is the Godot equivalent of Angular's `@Input()` accepting a service token.

## What We Are Building

By the end of this chapter you will have:

- An **InteractionStrategy** base Resource class with a single `execute()` method to override
- An **Interactable** entity (StaticBody2D) that holds an `@export var strategy`
- **SignStrategy** — displays text via DialogueManager
- **ChestStrategy** — grants an item and marks itself as opened
- **DoorStrategy** — transitions to another scene
- **SavePointStrategy** — saves the game and shows a confirmation
- A **one-time use** flag that prevents re-interaction (chests stay opened)
- **EventBus** integration for decoupled listeners

## InteractionStrategy: The Base Class

The strategy is a Resource — not a Node, not a RefCounted. Resources can be exported to the inspector and saved as `.tres` files, which means you can assign strategies visually in the editor.

```gdscript
# interaction_strategy.gd
class_name InteractionStrategy
extends Resource

## Base class for interaction strategies. Subclass this to define
## behavior for different interactable types (sign, chest, door, etc.).


func execute(_owner: Node) -> void:
	push_warning("InteractionStrategy.execute() not overridden.")
```

That is the entire base class. One method: `execute()`. The `_owner` parameter is the Interactable node that called the strategy — strategies can read the owner's properties (like `has_been_used`) or access the scene tree through it.

The `push_warning` in the base implementation catches the case where someone forgets to override `execute()` in a subclass. In TypeScript, you would use an abstract method. GDScript does not have abstract methods, so the base implementation logs a warning instead.

## The Interactable Entity

The Interactable is a generic StaticBody2D that delegates all interaction logic to its strategy:

```gdscript
# interactable.gd
class_name Interactable
extends StaticBody2D

## Generic interactable object. Delegates behavior to an InteractionStrategy
## resource (sign, chest, save point, item pickup, door, etc.).

signal interacted

@export var strategy: InteractionStrategy
@export var one_time: bool = true

var has_been_used: bool = false

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	add_to_group("interactables")
	if strategy == null:
		push_warning("Interactable '%s' has no strategy assigned." % name)


func interact() -> void:
	if one_time and has_been_used:
		return
	if strategy == null:
		return

	strategy.execute(self)
	interacted.emit()
	var bus := get_node_or_null("/root/EventBus")
	if bus:
		bus.emit_interactable_used(name)

	if one_time:
		has_been_used = true
```

### How It Works

The player's RayCast2D hits the Interactable's CollisionShape2D. The player calls `interact()` via duck typing (`has_method("interact")` — same as NPCs). The Interactable:

1. Checks if it has already been used (for one-time objects like chests)
2. Calls `strategy.execute(self)`, passing itself as the owner
3. Emits the `interacted` signal (for anything listening locally)
4. Notifies the `EventBus` (for anything listening globally)
5. Sets `has_been_used = true` if one-time

The Interactable knows nothing about what the strategy does. It does not know whether it is a chest, a sign, or a save point. It only knows that it has a strategy and that strategy has an `execute()` method.

### The @export Strategy Field

```gdscript
@export var strategy: InteractionStrategy
```

In the Godot inspector, this appears as a dropdown. You can create a new strategy resource inline (click the field, select "New SignStrategy"), or load an existing `.tres` file. This is how designers configure interactables without touching code — drag a `ChestStrategy` resource onto the field and fill in the item ID.

### One-Time Use

```gdscript
@export var one_time: bool = true

var has_been_used: bool = false
```

Most interactables are one-time use. A chest should only give its item once. A save point, however, should be reusable — set `one_time = false` in the inspector.

The `has_been_used` flag is a runtime variable, not an export. It resets when the scene reloads. For persistent one-time tracking (chests that stay open across save/load), the save system stores which interactables have been used, keyed by their node name.

### The Scene Tree

```
Interactable (StaticBody2D) — class_name Interactable
  CollisionShape2D          ← raycast target
  Sprite2D                  ← visual (chest, sign, crystal, etc.)
  InteractionArea (Area2D)  ← proximity detection (optional indicator)
    CollisionShape2D        ← larger detection radius
```

This is identical to the NPC scene tree. The Interactable can also display floating indicators (like the save point's star icon) using the same proximity pattern from the previous chapter.

## Concrete Strategies

Each strategy is a small Resource class that overrides `execute()`. They are deliberately simple — most are under 20 lines.

### SignStrategy

The simplest strategy: display a text message.

```gdscript
# sign_strategy.gd
class_name SignStrategy
extends InteractionStrategy

## Displays a text message when interacted with.

@export_multiline var text: String = ""


func execute(_owner: Node) -> void:
	if text.is_empty():
		return
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", text),
	]
	DialogueManager.start_dialogue(lines)
```

The speaker is an empty string (signs do not have names). The text comes from the `@export` field, configurable per instance in the inspector. The strategy accesses `DialogueManager` directly — autoloads are global, so strategies can use them without needing a node reference.

### ChestStrategy

Grants an item and marks the chest as opened:

```gdscript
# chest_strategy.gd
class_name ChestStrategy
extends InteractionStrategy

## Opens a chest and displays a message about the obtained item.

@export var item_id: String = ""
@export var text: String = ""


func execute(owner: Node) -> void:
	if "has_been_used" in owner:
		owner.has_been_used = true
	var message: String = text if not text.is_empty() else "Obtained %s!" % item_id
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", message),
	]
	DialogueManager.start_dialogue(lines)
```

The `if "has_been_used" in owner` check uses Godot's property existence check. This is defensive — the strategy works even if the owner is not an Interactable (useful for testing). In a real game, you would also call `InventoryManager.add_item()` here to actually grant the item.

The `text` export allows custom messages. If left empty, it falls back to a generic "Obtained [item]!" message. This is a common pattern — provide a default but allow override.

### DoorStrategy

Transitions to another scene:

```gdscript
# door_strategy.gd
class_name DoorStrategy
extends InteractionStrategy

## Transitions to another scene at an optional spawn point.

@export_file("*.tscn") var target_scene: String = ""
@export var spawn_point: String = ""


func execute(_owner: Node) -> void:
	if target_scene.is_empty():
		return
	GameManager.change_scene(
		target_scene, GameManager.FADE_DURATION, spawn_point
	)
```

`@export_file("*.tscn")` is a specialized export annotation that shows a file picker filtered to `.tscn` files. In the inspector, instead of typing a path manually, you browse to the target scene. The `spawn_point` string corresponds to a Marker2D group name in the target scene — the player appears at that marker after the transition.

This strategy does not start dialogue, does not play sounds, does not animate. It calls one method on one autoload. That simplicity is the point — each strategy does exactly one thing.

### SavePointStrategy

Saves the game and shows a confirmation:

```gdscript
# save_point_strategy.gd
class_name SavePointStrategy
extends InteractionStrategy

## Saves the game and displays a confirmation message.

@export var text: String = "Progress saved."
@export var fail_text: String = "Could not save."


func execute(owner: Node) -> void:
	var scene_path := _get_current_scene_path(owner)
	var player_pos := _get_player_position(owner)
	var ok: bool = SaveManager.save_game(
		0, PartyManager, InventoryManager, EventFlags,
		scene_path, player_pos,
	)
	var msg: String = text if ok else fail_text
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", msg),
	]
	DialogueManager.start_dialogue(lines)


func _get_current_scene_path(owner: Node) -> String:
	var scene := owner.get_tree().current_scene
	if scene:
		return scene.scene_file_path
	return ""


func _get_player_position(owner: Node) -> Vector2:
	var players := owner.get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		return players[0].global_position
	return Vector2.ZERO
```

This is the most complex strategy because saving requires gathering data from multiple systems. The strategy accesses the scene tree through `owner.get_tree()` — this is why `execute()` receives the owner node. Without it, a Resource (which is not in the scene tree) could not find the current scene or player position.

The `_get_current_scene_path` and `_get_player_position` helpers are private methods that isolate the scene tree access. If SaveManager's API changes, only these helpers need updating.

## EventBus Integration

When an Interactable is used, it notifies the EventBus:

```gdscript
# In interactable.gd
var bus := get_node_or_null("/root/EventBus")
if bus:
	bus.emit_interactable_used(name)
```

The EventBus is the central signal hub — a place where systems that need to react to gameplay events can listen without knowing about the source:

```gdscript
# In quest_manager.gd or any other system
func _ready() -> void:
	EventBus.interactable_used.connect(_on_interactable_used)


func _on_interactable_used(interactable_name: String) -> void:
	# Check if any quest objective requires this interactable
	_check_quest_progress(interactable_name)
```

This is the Observer pattern at scale. The Interactable does not know (or care) that the quest system is listening. The quest system does not know (or care) whether the event came from a chest, a sign, or a save point. They communicate through the EventBus's typed signals.

In Angular terms, the EventBus is a shared `Subject<T>` that multiple services subscribe to. The Interactable calls `next()` (emit), and any number of subscribers react independently.

## Creating Interactables in Scenes

In a scene script, you create and configure interactables by instantiating the scene and assigning a strategy:

```gdscript
func _setup_interactables() -> void:
	# A readable sign
	var sign := preload("res://entities/interactable/interactable.tscn").instantiate()
	var sign_strat := SignStrategy.new()
	sign_strat.text = "Welcome to Roothollow Village."
	sign.strategy = sign_strat
	sign.one_time = false
	sign.position = Vector2(144, 192)
	$Entities.add_child(sign)

	# A treasure chest
	var chest := preload("res://entities/interactable/interactable.tscn").instantiate()
	var chest_strat := ChestStrategy.new()
	chest_strat.item_id = "potion"
	chest_strat.text = "Found a Potion!"
	chest.strategy = chest_strat
	chest.one_time = true
	chest.position = Vector2(256, 128)
	$Entities.add_child(chest)

	# A door to another area
	var door := preload("res://entities/interactable/interactable.tscn").instantiate()
	var door_strat := DoorStrategy.new()
	door_strat.target_scene = "res://scenes/verdant_forest/verdant_forest.tscn"
	door_strat.spawn_point = "from_village"
	door.strategy = door_strat
	door.one_time = false
	door.position = Vector2(320, 64)
	$Entities.add_child(door)
```

Notice the pattern: instantiate the same scene, create a different strategy, assign it. The Interactable scene never changes — only the strategy varies. This is the power of composition: one reusable entity, infinite behaviors.

## Writing Your Own Strategy

Adding a new interactable type requires exactly one new file:

```gdscript
# item_pickup_strategy.gd
class_name ItemPickupStrategy
extends InteractionStrategy

## Picks up an item, shows a message, then removes the interactable from the scene.

@export var item_id: String = ""
@export var text: String = ""


func execute(owner: Node) -> void:
	var message: String = (
		text if not text.is_empty()
		else "Picked up %s!" % item_id
	)
	var lines: Array[DialogueLine] = [
		DialogueLine.create("", message),
	]
	DialogueManager.start_dialogue(lines)

	# Wait for dialogue to finish, then remove the pickup from the world
	await DialogueManager.dialogue_ended
	owner.queue_free()
```

This strategy shows a message and then removes the interactable from the scene tree (`queue_free()`). The `await` ensures the object is not freed while the player is still reading the message.

To use it: create an `ItemPickupStrategy`, set the `item_id`, and assign it to any Interactable. No changes to the Interactable class. No changes to the player. No changes to the DialogueManager. The new behavior plugs in through the existing architecture.

## The Strategy Pattern in Context

Here is the full picture of how the Strategy pattern connects everything:

```
Player presses "interact"
    ↓
RayCast2D hits Interactable's CollisionShape2D
    ↓
Player calls interactable.interact() via duck typing
    ↓
Interactable checks one_time + has_been_used
    ↓
Interactable calls strategy.execute(self)
    ↓
┌─────────────────────────────────────────┐
│ Strategy decides what happens:           │
│                                          │
│ SignStrategy    → DialogueManager        │
│ ChestStrategy   → DialogueManager + flag │
│ DoorStrategy    → GameManager            │
│ SavePointStrategy → SaveManager + msg    │
│ ItemPickupStrategy → msg + queue_free()  │
│ [YourStrategy]  → whatever you need      │
└─────────────────────────────────────────┘
    ↓
Interactable emits "interacted" signal
    ↓
EventBus.emit_interactable_used(name)
    ↓
QuestManager, tutorials, achievements react
```

The Interactable is the framework. The strategy is the plugin. The EventBus is the notification system. Each layer has a single responsibility, and adding new behavior never requires changing existing code — just adding new strategy classes.

## Common Mistakes

**Making strategies extend Node instead of Resource.** Strategies do not need to be in the scene tree. They are pure behavior — no position, no children, no frame updates. Extending Resource keeps them lightweight, serializable, and assignable via the inspector.

**Forgetting that Resources are shared references.** If you assign the same strategy `.tres` file to multiple interactables and mutate a property at runtime, all of them change. Use inline resources (created in the inspector per-instance) or `duplicate()` if you need independent copies.

**Not checking for null strategy.** If you forget to assign a strategy in the inspector, `strategy.execute(self)` crashes with a null reference. The `if strategy == null: return` guard in `interact()` prevents this.

**Using deep inheritance instead of Strategy.** Do not create `Chest extends Interactable extends StaticBody2D`. The Strategy pattern is explicitly designed to avoid inheritance hierarchies. One Interactable class, many strategy Resources.

**Putting scene tree logic in strategies without the owner reference.** Strategies extend Resource, so they are not in the scene tree. They cannot call `get_tree()` directly. Always access the scene tree through `owner.get_tree()` or `owner.get_node_or_null()`.

## What Is Next

You now have two complete entity types — NPCs for dialogue and Interactables for everything else — both driven by the player's RayCast2D interaction system. The data layer from Chapter 6 feeds both of them. In the next chapter, you will build the PartyManager autoload to track your team of characters: who is in the party, what their current HP is, and how active and reserve rosters work.

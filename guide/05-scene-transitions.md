# Chapter 5: Scene Transitions

In a JRPG, the player moves between dozens of interconnected areas — towns, dungeons, forests, battle arenas, menus. Each area is a separate Godot scene, and the game needs a system to switch between them smoothly, maintain state across transitions, and prevent invalid actions during the switch.

If you've used Angular Router, the mental model translates directly. Each scene is a route. Transitions are navigations. The game state stack works like Angular's router history with `NavigationExtras`. Guards prevent navigation during transitions. And the fade-to-black effect is analogous to route transition animations.

This chapter builds the `GameManager` autoload — the central hub that manages game states and scene transitions.

## The GameManager Autoload

An **autoload** (also called a singleton) is a node that Godot creates at startup and keeps alive for the entire application lifetime. It's accessible by name from any script, anywhere — no imports, no dependency injection, no passing references. You register autoloads in Project Settings > Autoload.

```gdscript
# Any script, anywhere in the project:
GameManager.push_state(GameManager.GameState.DIALOGUE)
GameManager.change_scene("res://scenes/town/town.tscn")
```

Think of autoloads as Angular services registered at the root level. They hold global state, provide shared functionality, and persist across "route changes" (scene switches).

**When to use an autoload:**
- State that persists across scenes (game state, party roster, inventory)
- Services used by many unrelated systems (audio, save/load)
- Cross-cutting concerns (scene transitions, event bus)

**When NOT to use an autoload:**
- Logic specific to one scene or feature (use a regular node)
- Data that only exists during a battle (use a scene-local manager)

### The Script

Here's the full `GameManager` — we'll break it down section by section:

```gdscript
extends Node

## Manages game state and scene transitions with fade effects.

signal game_state_changed(old_state: GameState, new_state: GameState)
signal scene_changed(scene_path: String)
signal transition_started
signal transition_midpoint
signal transition_finished

enum GameState {
	OVERWORLD,
	BATTLE,
	DIALOGUE,
	MENU,
	CUTSCENE,
}

const FADE_DURATION: float = 0.5

var current_state: GameState = GameState.OVERWORLD
var _state_stack: Array[GameState] = []
var _is_transitioning: bool = false
var _transition_layer: CanvasLayer = null
var _fade_rect: ColorRect = null
```

Note: **no `class_name`** on autoloads. Autoloads are already globally accessible by their registered name. Adding `class_name` would create a confusing situation where both the class name and the autoload name reference the same thing.

## Game States: The State Stack

A JRPG constantly shifts between modes:

| State | Player Can Move | UI Shown | What's Happening |
|-------|----------------|----------|------------------|
| `OVERWORLD` | Yes | HUD | Walking around, exploring |
| `BATTLE` | No | Battle UI | Turn-based combat |
| `DIALOGUE` | No | Dialogue box | NPC conversation |
| `MENU` | No | Pause/inventory | Pause screen or submenus |
| `CUTSCENE` | No | Varies | Scripted sequences |

At any moment, exactly one state is active. Other systems react to state changes — the player freezes when leaving `OVERWORLD`, the battle UI appears when entering `BATTLE`, the pause menu opens when entering `MENU`.

### Push/Pop: The Navigation Stack

States form a stack, like a browser's navigation history:

```
Initial:     [OVERWORLD]
Open menu:   [OVERWORLD, MENU]         ← pushed MENU
Close menu:  [OVERWORLD]               ← popped back to OVERWORLD
Start battle:[OVERWORLD, BATTLE]       ← pushed BATTLE
End battle:  [OVERWORLD]               ← popped back to OVERWORLD
```

The implementation:

```gdscript
func push_state(new_state: GameState) -> void:
	_state_stack.push_back(current_state)
	var old_state := current_state
	current_state = new_state
	game_state_changed.emit(old_state, new_state)


func pop_state() -> void:
	if _state_stack.is_empty():
		push_warning("GameManager: state stack is empty.")
		return
	var old_state := current_state
	current_state = _state_stack.pop_back()
	game_state_changed.emit(old_state, current_state)
```

**`push_state`** saves the current state on the stack and activates the new one. **`pop_state`** restores the previous state. Both emit `game_state_changed` so listeners can react.

This is directly analogous to Angular Router's navigation stack:

```typescript
// Angular equivalent (conceptual)
router.navigate(['/battle']);     // like push_state(BATTLE)
router.navigateBack();           // like pop_state()
```

The stack pattern handles nested states naturally. Opening a menu during a cutscene:

```
[OVERWORLD, CUTSCENE, MENU]
```

Closing the menu returns to the cutscene, not to the overworld. The stack preserves the correct return path.

### Listening to State Changes

Any node can react to state changes via the signal:

```gdscript
func _ready() -> void:
	GameManager.game_state_changed.connect(_on_game_state_changed)


func _on_game_state_changed(
	_old_state: GameManager.GameState,
	new_state: GameManager.GameState,
) -> void:
	# Only process input during overworld
	set_process_unhandled_input(new_state == GameManager.GameState.OVERWORLD)
```

The Player node uses this to freeze/unfreeze movement (as we saw in Chapter 3). The HUD uses it to show/hide elements. The encounter system uses it to pause random battle checks. Each system independently decides what a state change means for its behavior.

This is the Observer pattern — the same pattern that Angular's `EventEmitter` and RxJS `Subject` implement. The `GameManager` doesn't know or care who's listening. It just emits the signal. Listeners subscribe and handle it however they need.

## Scene Transitions

Changing scenes in Godot means unloading the current scene tree and loading a new one. The raw API is simple:

```gdscript
get_tree().change_scene_to_file("res://scenes/town/town.tscn")
```

But a raw scene change is jarring — one frame shows the forest, the next frame shows the town with no warning. JRPGs use fade transitions: the screen fades to black, the scene switches while the screen is dark, then the screen fades back in.

### The Transition Layer

The fade effect uses a `ColorRect` (a solid-color rectangle) on a `CanvasLayer`. The `CanvasLayer` renders independently of the game world — it stays in place even when the camera moves or the scene changes:

```gdscript
func _ready() -> void:
	_setup_transition_layer()


func _setup_transition_layer() -> void:
	_transition_layer = CanvasLayer.new()
	_transition_layer.layer = 100  # very high = on top of everything
	_transition_layer.name = "TransitionLayer"
	add_child(_transition_layer)

	_fade_rect = ColorRect.new()
	_fade_rect.color = Color.TRANSPARENT  # starts fully transparent
	_fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_layer.add_child(_fade_rect)
```

**`CanvasLayer.layer = 100`** ensures the fade overlay renders on top of everything — game world, UI, dialogue boxes, all of it. In CSS terms, it's like `z-index: 9999`.

**`PRESET_FULL_RECT`** makes the `ColorRect` cover the entire viewport, regardless of window size. It's the Godot equivalent of `position: fixed; inset: 0`.

**`MOUSE_FILTER_IGNORE`** ensures the overlay doesn't block mouse clicks. Even when fully opaque (during the fade), input still reaches the game beneath it.

**`Color.TRANSPARENT`** is `Color(0, 0, 0, 0)` — black with zero alpha. The overlay is invisible until we animate its alpha.

### The Fade Transition

Here's the complete scene change with fade:

```gdscript
func change_scene(
	scene_path: String,
	fade_duration: float = FADE_DURATION,
	spawn_point: String = "",
) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	transition_started.emit()

	# Fade to black
	var tween := create_tween()
	tween.tween_property(_fade_rect, "color:a", 1.0, fade_duration)
	await tween.finished

	transition_midpoint.emit()

	# Switch scene while screen is black
	get_tree().change_scene_to_file(scene_path)
	await get_tree().scene_changed

	# Move player to spawn point
	_apply_spawn_point(spawn_point)
	scene_changed.emit(scene_path)

	# Fade back in
	tween = create_tween()
	tween.tween_property(_fade_rect, "color:a", 0.0, fade_duration)
	await tween.finished

	_is_transitioning = false
	transition_finished.emit()
```

Let's break down each piece:

### Tweens: Animated Property Changes

A `Tween` smoothly interpolates a property over time. Think of it as a lightweight animation system — like CSS `transition` for Godot nodes:

```gdscript
var tween := create_tween()
tween.tween_property(_fade_rect, "color:a", 1.0, fade_duration)
```

This says: "Over `fade_duration` seconds, smoothly change `_fade_rect.color.a` (the alpha component of the color) from its current value to `1.0` (fully opaque)."

**`create_tween()`** creates a tween tied to the node's lifecycle. If the node is freed, the tween is automatically cleaned up. Always use `create_tween()` on a node rather than constructing `Tween.new()`.

**Property paths** use dot notation with a twist — sub-properties use colons. `"color:a"` means "the `a` (alpha) sub-property of the `color` property." Other examples: `"position:x"`, `"modulate:a"`, `"scale:y"`.

**Chaining** — Tweens support method chaining for sequencing:

```gdscript
var tween := create_tween()
tween.tween_property(node, "modulate:a", 0.0, 0.3)  # first: fade out
tween.tween_callback(node.queue_free)                 # then: delete node
tween.tween_interval(0.5)                             # or: wait 0.5 seconds
```

Chained operations run sequentially — each waits for the previous one to finish. For parallel animations, call `set_parallel()`:

```gdscript
var tween := create_tween()
tween.set_parallel()
tween.tween_property(node, "position:x", 100.0, 0.5)   # both happen
tween.tween_property(node, "modulate:a", 0.0, 0.5)     # simultaneously
```

**Easing and transitions** control the animation curve:

```gdscript
tween.set_trans(Tween.TRANS_CUBIC)    # acceleration curve shape
tween.set_ease(Tween.EASE_IN_OUT)     # ease in, ease out, or both
```

Common combinations:
- `TRANS_LINEAR` — constant speed (default)
- `TRANS_CUBIC` + `EASE_IN_OUT` — smooth acceleration and deceleration
- `TRANS_SINE` — gentle sinusoidal (good for pulsing effects)
- `TRANS_BOUNCE` — bouncy ending (rarely used in JRPGs)

### await: Asynchronous Flow

GDScript's `await` keyword works very similarly to TypeScript's `await`:

```gdscript
# GDScript
await tween.finished       # pause until the tween emits "finished"

# TypeScript equivalent (conceptual)
await tween.finished;      // almost identical syntax!
```

You can `await` any Godot signal. The function suspends at that point and resumes when the signal fires. This makes sequential async operations readable:

```gdscript
# Fade out
await tween.finished
# (screen is now black)

# Change scene
get_tree().change_scene_to_file(scene_path)
await get_tree().scene_changed
# (new scene is now loaded and ready)

# Fade in
await tween.finished
# (screen is now visible)
```

Without `await`, you'd need callbacks or signals to chain these operations — the same callback-hell problem that `async/await` solved in JavaScript.

**Key Godot signal for scene changes:** `get_tree().scene_changed` fires after the new scene is fully loaded and its `_ready()` has run on all nodes. This is the safe point to reference nodes in the new scene.

### The Transition Guard

```gdscript
if _is_transitioning:
	return
```

This guard prevents multiple scene changes from firing simultaneously. Without it, a player walking into a transition trigger while a transition is already in progress could cause corrupted state — two scenes loading on top of each other, or a fade that never completes.

The `is_transitioning()` method exposes this state:

```gdscript
func is_transitioning() -> bool:
	return _is_transitioning
```

Scene scripts check this before initiating transitions:

```gdscript
func _on_exit_to_forest_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	GameManager.change_scene(
		"res://scenes/forest/forest.tscn",
		GameManager.FADE_DURATION,
		"spawn_from_town",
	)
```

## Spawn Points: Where the Player Appears

When transitioning between scenes, the player needs to appear at the right location in the new scene. Walking out the east exit of the town should place the player at the west entrance of the forest.

Spawn points are `Marker2D` nodes added to named groups:

```gdscript
# In the forest scene's _ready():
$Entities/SpawnFromTown.add_to_group("spawn_from_town")
```

`Marker2D` is a node that exists solely to mark a position. It has no visual representation at runtime (it shows a cross icon in the editor for placement). It's like an HTML anchor element with no content — it just marks a spot.

When `GameManager.change_scene()` is called with a spawn point name, it finds the corresponding marker after the new scene loads:

```gdscript
func _apply_spawn_point(spawn_point: String) -> void:
	if spawn_point.is_empty():
		return
	var player := get_tree().get_first_node_in_group("player")
	var marker := get_tree().get_first_node_in_group(spawn_point)
	if player and marker:
		player.global_position = marker.global_position
```

The group system connects scenes loosely — the town scene doesn't reference the forest scene directly. It just says "go to the scene at this path, and place the player at the `spawn_from_town` group marker." Any scene that has a node in the `spawn_from_town` group will work.

### Setting Up Spawn Points in Practice

A typical scene has multiple spawn points — one per entrance:

```
Entities (Node2D)
├── Player
├── SpawnFromForest (Marker2D)    ← east entrance
├── SpawnFromDungeon (Marker2D)   ← north entrance
└── SpawnFromTown (Marker2D)      ← west entrance
```

In the scene script:

```gdscript
@onready var _spawn_from_forest: Marker2D = $Entities/SpawnFromForest

func _ready() -> void:
	_spawn_from_forest.add_to_group("spawn_from_forest")
```

The player's initial position in the scene (set in the editor) serves as the "default" spawn — used when no spawn point is specified (e.g., when starting a new game).

## Area2D Triggers: Zone Transitions

The player triggers scene transitions by walking into designated areas. `Area2D` nodes serve as invisible trigger zones:

```
Triggers (Node2D)
├── ExitToForest (Area2D)
│   └── CollisionShape2D
├── ExitToDungeon (Area2D)
│   └── CollisionShape2D
└── EventZone (Area2D)
    └── CollisionShape2D
```

An `Area2D` detects when physics bodies enter or exit its collision shape. It doesn't block movement — it just reports overlaps.

Key properties:
- **`monitoring = true`** — the area actively checks for overlaps
- **`monitorable = true`** — other areas can detect this one
- **`collision_layer`** — what layer this area exists on
- **`collision_mask`** — what layers this area detects

Key signals:
- **`body_entered(body: Node2D)`** — a `CharacterBody2D` or `RigidBody2D` entered the area
- **`body_exited(body: Node2D)`** — a body left the area

Wiring in the scene script:

```gdscript
@onready var _exit_to_forest: Area2D = $Triggers/ExitToForest

func _ready() -> void:
	_exit_to_forest.body_entered.connect(_on_exit_to_forest_entered)


func _on_exit_to_forest_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	GameManager.change_scene(
		"res://scenes/forest/forest.tscn",
		GameManager.FADE_DURATION,
		"spawn_from_town",
	)
```

The three-guard pattern:

1. **`body.is_in_group("player")`** — Only the player triggers transitions. NPCs and companions walking into the zone are ignored.
2. **`GameManager.is_transitioning()`** — Prevents double-triggers if the player's velocity carries them into the zone during an ongoing transition.
3. **(Optional) `DialogueManager.is_active()`** — Prevents transitions while a dialogue box is open. An NPC standing near an exit shouldn't cause a scene change when the player talks to them.

### Placing Trigger Zones in the Editor

Position your `Area2D` trigger zones at map edges, typically spanning the full width or height of the exit:

```
Map edge (west side):
┌────────────────────────────┐
│                            │
│  ▓▓  trigger zone          │
│  ▓▓  (2 tiles wide)        │
│  ▓▓                        │
│                            │
└────────────────────────────┘
```

Make the zone 1-2 tiles wide. Too narrow and fast-moving players might pass through it between physics frames. Too wide and players trigger it before they intend to. Set the collision shape in the editor using a `RectangleShape2D`.

## Putting It All Together: A Complete Scene

Here's how a scene script ties together everything from Chapters 3-5:

```gdscript
extends Node2D

## Forest area — connects town and dungeon.

@onready var _ground: TileMapLayer = $Ground
@onready var _objects: TileMapLayer = $Objects
@onready var _above_player: TileMapLayer = $AbovePlayer
@onready var _spawn_from_town: Marker2D = $Entities/SpawnFromTown
@onready var _spawn_from_dungeon: Marker2D = $Entities/SpawnFromDungeon
@onready var _exit_to_town: Area2D = $Triggers/ExitToTown
@onready var _exit_to_dungeon: Area2D = $Triggers/ExitToDungeon


func _ready() -> void:
	# Set up tilemap (Chapter 4)
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, 640, 384)

	# Register spawn points as groups
	_spawn_from_town.add_to_group("spawn_from_town")
	_spawn_from_dungeon.add_to_group("spawn_from_dungeon")

	# Connect transition triggers
	_exit_to_town.body_entered.connect(_on_exit_to_town_entered)
	_exit_to_dungeon.body_entered.connect(_on_exit_to_dungeon_entered)


func _setup_tilemap() -> void:
	var atlas_paths: Array[String] = [
		MapBuilder.TF_TERRAIN,
		MapBuilder.FOREST_OBJECTS,
	]
	MapBuilder.apply_tileset(
		[_ground, _objects, _above_player] as Array[TileMapLayer],
		atlas_paths,
		{1: [Vector2i(3, 2)]},  # tree trunks are solid
	)
	MapBuilder.disable_collision(_ground)
	MapBuilder.disable_collision(_above_player)


func _on_exit_to_town_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	GameManager.change_scene(
		"res://scenes/town/town.tscn",
		GameManager.FADE_DURATION,
		"spawn_from_forest",
	)


func _on_exit_to_dungeon_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	GameManager.change_scene(
		"res://scenes/dungeon/dungeon.tscn",
		GameManager.FADE_DURATION,
		"spawn_from_forest",
	)
```

This single script demonstrates:
- **Tilemap setup** with multi-layer architecture and boundary walls (Chapter 4)
- **Spawn point registration** via the group system
- **Area2D trigger wiring** with the three-guard pattern
- **Scene transitions** with fade and spawn point targeting
- **Loose coupling** — the forest doesn't import or reference the town or dungeon scenes. It just knows their file paths and spawn group names.

## Advanced: Transition Signals

The `GameManager` emits several signals during transitions that other systems hook into:

```gdscript
signal transition_started     # Fade-out begins
signal transition_midpoint    # Screen is fully black, scene about to switch
signal transition_finished    # Fade-in complete, player can move
```

Use cases:
- **`transition_started`** — Disable the encounter system to prevent random battles during transitions
- **`transition_midpoint`** — Save state from the old scene before it's destroyed
- **`transition_finished`** — Start area-specific music, show location name popup

## Advanced: Centralized Scene Paths

As your game grows, scene paths appear in multiple files. A typo in a path string causes a runtime crash when the scene loads. Centralizing paths prevents this:

```gdscript
class_name ScenePaths
extends RefCounted

const TOWN: String = "res://scenes/town/town.tscn"
const FOREST: String = "res://scenes/forest/forest.tscn"
const DUNGEON: String = "res://scenes/dungeon/dungeon.tscn"
const BATTLE: String = "res://systems/battle/battle_scene.tscn"
const TITLE_SCREEN: String = "res://ui/title_screen/title_screen.tscn"
```

Now scene scripts reference constants instead of string literals:

```gdscript
const SP = preload("res://systems/scene_paths.gd")

GameManager.change_scene(SP.TOWN, GameManager.FADE_DURATION, "spawn_from_forest")
```

If you rename a scene file, you update one constant and every reference updates with it. The `preload()` function loads the script at parse time, so typos in the path are caught when the scene loads — not at the moment the player hits a trigger.

## Advanced: DoorStrategy for Interactable Transitions

Not all transitions are triggered by walking into a zone. Doors, stairs, and portals trigger when the player interacts with them. Using the interactable strategy pattern (covered in Chapter 8), a door becomes a simple resource:

```gdscript
class_name DoorStrategy
extends InteractionStrategy

@export_file("*.tscn") var target_scene: String = ""
@export var spawn_point: String = ""


func execute(_owner: Node) -> void:
	if target_scene.is_empty():
		return
	GameManager.change_scene(
		target_scene,
		GameManager.FADE_DURATION,
		spawn_point,
	)
```

The `@export_file("*.tscn")` annotation creates a file picker in the Inspector that only shows `.tscn` files. Set the target scene and spawn point in the editor — no code needed per door.

## Common Mistakes

**Not guarding against double transitions.** If the player's velocity pushes them into a trigger zone twice before the first transition completes, you get two simultaneous scene loads. Always check `is_transitioning()`.

**Referencing nodes before `await get_tree().scene_changed`.** After calling `change_scene_to_file()`, the new scene isn't ready yet. Nodes from the old scene are being freed. Wait for `scene_changed` before accessing nodes in the new scene.

**Forgetting to add spawn points to groups.** Spawn points need `add_to_group()` in `_ready()` to be found by `get_first_node_in_group()`. A missing group means the player spawns at the default position instead of the intended entrance.

**Using `change_scene_to_file` directly.** Always go through `GameManager.change_scene()` so the fade effect, transition guards, and signals work correctly. Direct calls bypass all of this.

**Empty state stack on `pop_state`.** If something calls `pop_state` without a corresponding `push_state`, the stack is empty and the function logs a warning. Track your push/pop pairs. Every `push_state` must have a matching `pop_state`. Mismatched pairs leave the game stuck in the wrong state.

**State stack order matters.** Pushing `DIALOGUE` during `BATTLE` puts both on the stack: `[OVERWORLD, BATTLE, DIALOGUE]`. When dialogue ends (pop), we return to `BATTLE`, not `OVERWORLD`. This is correct behavior — but if you push states without thinking about the stack, you can end up in surprising states.

## How It Connects

The `GameManager` ties together everything we've built so far:
- **Chapter 3 (Player):** The player listens to `game_state_changed` to freeze/unfreeze. Spawn points set the player's position after transitions.
- **Chapter 4 (World):** Each world scene sets up tilemaps and registers spawn points in `_ready()`. Trigger zones at map edges fire `change_scene()`.
- **Forward:** The battle system (Chapter 10) uses `push_state(BATTLE)` to freeze the overworld and `pop_state()` to return. The dialogue system (Chapter 7) uses the same push/pop pattern. The save system (Chapter 16) captures the current scene path and player position.

With player movement, world building, and scene transitions in place, you have a playable game loop — the player can walk around a map, cross into another map, and navigate between areas. The next chapters add the content that makes this world worth exploring: data-driven resources, NPCs with dialogue, and interactive objects.

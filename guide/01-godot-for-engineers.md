# Chapter 1: Godot for Engineers

You already know how to build software. This chapter maps Godot's architecture onto concepts you use every day — component trees, event emitters, services, data models, and lifecycle hooks. By the end, you will understand the engine's mental model well enough to read any Godot project and know exactly what is happening.

## The Big Picture

Godot is a component-based engine. If you have worked with Angular, React, Vue, or any modern UI framework, the core idea is identical:

- Your application is a **tree of components** (Godot calls them **nodes**)
- Components have **lifecycle hooks** (`_ready()`, `_process()`, `_enter_tree()`)
- Components communicate through **events** (Godot calls them **signals**)
- Components expose **configurable properties** (`@export`, like Angular's `@Input()`)
- You compose small, focused components into larger ones — **composition over inheritance**

The key difference: instead of rendering DOM elements, Godot renders sprites, tiles, and UI controls at 60 frames per second. Instead of handling HTTP requests, you handle physics collisions and input events. The architecture is the same. The domain is different.

## The Scene Tree Is a Component Tree

Every Godot application has a single root tree — the **SceneTree** — that contains every active node. This is directly analogous to Angular's component tree or React's virtual DOM tree.

```
Angular Component Tree          Godot Scene Tree
─────────────────────           ─────────────────
AppComponent                    Root (Window)
├── HeaderComponent             └── Main (Node2D)
│   ├── LogoComponent               ├── Player (CharacterBody2D)
│   └── NavComponent                │   ├── Sprite2D
├── MainComponent                   │   ├── CollisionShape2D
│   ├── SidebarComponent            │   └── Camera2D
│   └── ContentComponent            ├── TileMapLayer
└── FooterComponent                 └── UI (CanvasLayer)
                                        ├── HUD (Control)
                                        └── DialogueBox (PanelContainer)
```

In Angular, you nest components inside components. In Godot, you nest nodes inside nodes. The parent-child relationship works the same way:

- Parents can access children: `get_node("Player")` or the shorthand `$Player`
- Children can access parents: `get_parent()`
- The tree has a global root: `get_tree()` returns the SceneTree (like Angular's root injector)
- You can find nodes by group membership: `get_tree().get_nodes_in_group("enemies")` (like querying by CSS class)

## Nodes vs Scenes

This is the first concept that trips up newcomers. In Angular terms:

- A **Node** is a component class — `Sprite2D`, `CharacterBody2D`, `Label`, `Timer`
- A **Scene** is a saved component tree — a `.tscn` file containing a node hierarchy with configured properties

```
Angular                              Godot
──────                               ─────
Component class (*.ts)               Node class (Sprite2D, CharacterBody2D, etc.)
Component template (*.html)          Scene file (*.tscn)
@Component({ template: '...' })      Saving a node tree as a scene
Dynamic component creation           scene.instantiate()
```

A scene is a reusable blueprint. You design a Player scene once — a `CharacterBody2D` with a `Sprite2D`, `CollisionShape2D`, and `Camera2D` as children — then instantiate it wherever you need a player. Exactly like defining a component template and using `<app-player>` in Angular, or calling `createElement(PlayerComponent)` in React.

Here is how you create a scene instance at runtime:

```gdscript
# Loading and instantiating a scene — like dynamic component creation
var player_scene: PackedScene = preload("res://entities/player/player.tscn")
var player: CharacterBody2D = player_scene.instantiate()
add_child(player)  # Adds to the tree, triggering _ready()
```

`preload()` loads the scene at compile time (like a static import). `load()` loads at runtime (like a dynamic import). `instantiate()` creates a new instance of the scene's node tree. `add_child()` inserts it into the live tree — this is when lifecycle hooks fire.

## GDScript Crash Course for TypeScript Developers

GDScript is Python-like in syntax but statically typed when you want it to be (and you always want it to be). Here is a side-by-side translation:

### Variables and Types

```typescript
// TypeScript
const MAX_SPEED: number = 200;
let velocity: Vector2 = new Vector2(0, 0);
let name: string = "Kael";
let isReady: boolean = false;
let items: string[] = ["potion", "elixir"];
let stats: Record<string, number> = { hp: 100, mp: 50 };
```

```gdscript
# GDScript
const MAX_SPEED: float = 200.0
var velocity: Vector2 = Vector2.ZERO
var character_name: String = "Kael"
var is_ready: bool = false
var items: Array[String] = ["potion", "elixir"]
var stats: Dictionary = {"hp": 100, "mp": 50}
```

Key differences:
- **No semicolons.** Line breaks end statements.
- **Indentation matters.** Tabs define blocks (like Python). The project convention is tabs, not spaces.
- **`const`** for compile-time constants, **`var`** for everything else (no `let`).
- **`snake_case`** for variables and functions (not `camelCase`).
- **Double quotes** by convention: `"hello"`, not `'hello'`.
- **Type annotations** use `:` after the name: `var speed: float = 80.0`.
- Use `and`, `or`, `not` instead of `&&`, `||`, `!`.

### Functions

```typescript
// TypeScript
function calculateDamage(attack: number, defense: number): number {
  const raw = attack - defense / 2;
  return Math.max(raw, 1);
}

// Arrow function
const double = (x: number): number => x * 2;
```

```gdscript
# GDScript
func calculate_damage(attack: int, defense: int) -> int:
    var raw: int = attack - defense / 2
    return maxi(raw, 1)


# Lambda (callable)
var double: Callable = func(x: int) -> int: return x * 2
```

Functions use `func`, return types use `->`, and two blank lines separate function definitions. GDScript has built-in math functions like `maxi()`, `maxf()`, `absf()`, `clampf()`, `clampi()` — no `Math.` prefix needed.

### Classes and Inheritance

```typescript
// TypeScript / Angular
@Component({ selector: 'app-player' })
export class PlayerComponent extends CharacterBody2D {
  @Input() moveSpeed: number = 80;

  ngOnInit(): void {
    console.log("Player ready");
  }
}
```

```gdscript
# GDScript
class_name Player
extends CharacterBody2D

@export var move_speed: float = 80.0


func _ready() -> void:
    print("Player ready")
```

- **`class_name`** registers the class globally (like Angular's `@Component` decorator making it available in templates).
- **`extends`** is single inheritance. Every script extends a Godot node class.
- **No `new` keyword** for nodes. Use `Node.new()` or `scene.instantiate()`.
- **No explicit constructors** for most nodes — use `_ready()` instead.

### Enums

```typescript
// TypeScript
enum GameState {
  OVERWORLD,
  BATTLE,
  DIALOGUE,
  MENU,
  CUTSCENE,
}
```

```gdscript
# GDScript
enum GameState {
    OVERWORLD,
    BATTLE,
    DIALOGUE,
    MENU,
    CUTSCENE,
}
```

Almost identical. GDScript enums are integer-based. Access with `GameState.BATTLE`. When defined inside a class, access from outside as `ClassName.GameState.BATTLE`.

### Null Safety

```typescript
// TypeScript
const node = this.getChild("Sprite");
if (node !== null) {
  node.visible = false;
}

// Optional chaining
this.player?.setVelocity(Vector2.ZERO);
```

```gdscript
# GDScript
var node: Node = get_node_or_null("Sprite")
if node:
    node.visible = false

# No optional chaining — guard explicitly
if player:
    player.velocity = Vector2.ZERO
```

GDScript has no optional chaining operator. Use explicit null checks. `get_node()` crashes if the path does not exist; `get_node_or_null()` returns `null` safely. Prefer `get_node_or_null()` when the child might not be present.

### String Formatting

```typescript
// TypeScript
const msg = `${name} deals ${damage} damage!`;
```

```gdscript
# GDScript
var msg: String = "%s deals %d damage!" % [character_name, damage]
```

GDScript uses `%` operator with format specifiers (`%s` for strings, `%d` for integers, `%f` for floats). No template literals.

## Signals = EventEmitter + RxJS Subject

Signals are Godot's built-in event system. If you have used Angular's `EventEmitter`, RxJS `Subject`, or DOM `CustomEvent`, you already understand signals. They are the primary mechanism for decoupled communication between nodes.

### Side-by-Side: Angular EventEmitter vs Godot Signal

```typescript
// Angular component — emitting events
@Component({ selector: 'app-button' })
export class ButtonComponent {
  @Output() clicked = new EventEmitter<string>();

  onClick(): void {
    this.clicked.emit("button_pressed");
  }
}

// Parent component — listening
@Component({
  template: '<app-button (clicked)="onButtonClicked($event)" />'
})
export class ParentComponent {
  onButtonClicked(value: string): void {
    console.log("Button said:", value);
  }
}
```

```gdscript
# GDScript node — emitting signals
class_name GameButton
extends Control

signal clicked(value: String)


func _on_pressed() -> void:
    clicked.emit("button_pressed")
```

```gdscript
# Parent node — listening
extends Node

@onready var button: GameButton = $GameButton


func _ready() -> void:
    button.clicked.connect(_on_button_clicked)


func _on_button_clicked(value: String) -> void:
    print("Button said: ", value)
```

### Declaring Signals

```gdscript
# No parameters
signal dialogue_ended

# With typed parameters
signal damage_taken(amount: int, source: Node)

# With complex parameters
signal battle_finished(victory: bool)
```

Signal declarations go at the top of the script, right after `extends`. They define the event's contract — what data flows through the signal.

### Emitting Signals

```gdscript
# Emit with no arguments
dialogue_ended.emit()

# Emit with arguments
damage_taken.emit(25, attacker_node)

# Emit with named context
battle_finished.emit(true)
```

Call `.emit()` on the signal itself. The arguments must match the signal's parameter types.

### Connecting Signals

```gdscript
# Connect in code — the recommended approach
func _ready() -> void:
    # Connect a child's signal to our method
    $Timer.timeout.connect(_on_timer_timeout)

    # Connect an autoload's signal
    GameManager.game_state_changed.connect(_on_game_state_changed)

    # One-shot connection (auto-disconnects after firing once)
    door.opened.connect(_on_door_opened, CONNECT_ONE_SHOT)


func _on_timer_timeout() -> void:
    print("Timer fired")


func _on_game_state_changed(
    old_state: GameManager.GameState,
    new_state: GameManager.GameState,
) -> void:
    print("State changed from %s to %s" % [old_state, new_state])
```

The pattern is always: `source_signal.connect(target_callable)`. The target callable is a method reference — no string-based connections, no magic method names. This is type-safe and refactoring-friendly.

### Awaiting Signals (Like RxJS firstValueFrom)

```gdscript
# Pause execution until a signal fires — like await firstValueFrom(observable$)
func show_dialogue(lines: Array[DialogueLine]) -> void:
    DialogueManager.start_dialogue(lines)
    await DialogueManager.dialogue_ended
    print("Dialogue finished, resuming gameplay")
```

`await signal_name` suspends the current function until that signal fires. This is GDScript's coroutine mechanism — the function becomes a coroutine when it uses `await`. The function must have no return type (or return `void`) to use `await`.

### Disconnecting Signals

```gdscript
# Disconnect when no longer needed
func _exit_tree() -> void:
    if GameManager.game_state_changed.is_connected(_on_game_state_changed):
        GameManager.game_state_changed.disconnect(_on_game_state_changed)
```

Always disconnect signals in `_exit_tree()` if the source node outlives the listener. Autoload signals persist for the entire application lifetime — if your listener node is freed while still connected, you get a dangling reference error.

## @export = @Input()

Angular's `@Input()` decorator exposes a property for parent components to set. Godot's `@export` does the same thing — it exposes a property in the editor's Inspector panel, and parent scenes can override it.

```typescript
// Angular
@Component({ selector: 'app-npc' })
export class NpcComponent {
  @Input() npcName: string = "Villager";
  @Input() dialogueLines: string[] = [];
  @Input() moveSpeed: number = 40;
}
```

```gdscript
# GDScript
class_name NPC
extends StaticBody2D

@export var npc_name: String = "Villager"
@export var dialogue_lines: PackedStringArray = []
@export var move_speed: float = 40.0
```

When you place an NPC node in a scene, you can set `npc_name`, `dialogue_lines`, and `move_speed` in the Inspector — just like binding `[npcName]="'Elder'"` in an Angular template.

### Export Groups

```gdscript
@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""

@export_group("Stats")
@export var max_hp: int = 100
@export var attack: int = 10
@export var defense: int = 10
```

`@export_group("name")` organizes exported properties into collapsible sections in the Inspector. It is purely visual organization — like grouping `@Input()` properties by category.

### Export Variants

```gdscript
# Enum dropdown in the Inspector
@export var element: Element = Element.NONE

# Range slider
@export_range(0.0, 1.0, 0.05) var encounter_rate: float = 0.1

# Multi-line text editor
@export_multiline var description: String = ""

# File picker filtered to .tres files
@export_file("*.tres") var data_path: String = ""

# Resource reference (like a typed @Input)
@export var ability: AbilityData
```

Each variant controls how the property appears in the Inspector. The underlying type is the same — these are editor hints, not runtime constraints.

## Autoloads = Root-Provided Services

Angular's `providedIn: 'root'` creates singleton services accessible anywhere in the application. Godot's **autoloads** are identical: scripts (or scenes) loaded once at startup and accessible globally by name.

```typescript
// Angular service
@Injectable({ providedIn: 'root' })
export class GameManagerService {
  private state: GameState = GameState.OVERWORLD;

  pushState(newState: GameState): void { /* ... */ }
  popState(): void { /* ... */ }
}

// Usage in any component
constructor(private gameManager: GameManagerService) {}
```

```gdscript
# GDScript autoload (game_manager.gd)
extends Node

signal game_state_changed(old_state: GameState, new_state: GameState)

enum GameState {
    OVERWORLD,
    BATTLE,
    DIALOGUE,
    MENU,
    CUTSCENE,
}

var current_state: GameState = GameState.OVERWORLD
var _state_stack: Array[GameState] = []


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

```gdscript
# Usage in any script — no import, no injection, just use the name
func _ready() -> void:
    GameManager.push_state(GameManager.GameState.DIALOGUE)

    # Connect to its signals
    GameManager.game_state_changed.connect(_on_state_changed)
```

Autoloads are registered in Project Settings > Autoload. You give the script a name (e.g., `GameManager`), and it becomes a globally accessible singleton. No imports, no dependency injection tokens — the name is the reference.

### When to Use Autoloads

Use autoloads the same way you would use root-provided services:

| Use Case | Autoload | Example |
|----------|----------|---------|
| Global game state | Yes | GameManager (state stack, scene transitions) |
| Cross-cutting event bus | Yes | EventBus (decoupled event relay) |
| Persistent data manager | Yes | PartyManager, InventoryManager, QuestManager |
| Audio playback | Yes | AudioManager (BGM + SFX) |
| Save/load coordination | Yes | SaveManager |
| Scene-specific logic | No | Battle calculations, encounter triggering |
| Utility functions | No | Use static functions or RefCounted classes |

A good rule of thumb: if you would make it `providedIn: 'root'` in Angular, make it an autoload in Godot. If you would make it a utility class or a component-scoped service, use a regular node or a `RefCounted` class.

## Resources = Data Models + JSON

In a web application, you define data with TypeScript interfaces and load it from JSON files or an API. In Godot, you define **Resource** classes (the schema) and save instances as `.tres` files (the data).

```typescript
// TypeScript — data model
interface BattlerData {
  id: string;
  displayName: string;
  maxHp: number;
  maxMp: number;
  attack: number;
  defense: number;
  speed: number;
}

// JSON data file
{
  "id": "goblin",
  "displayName": "Goblin",
  "maxHp": 45,
  "maxMp": 0,
  "attack": 12,
  "defense": 8,
  "speed": 10
}
```

```gdscript
# GDScript — Resource class (the schema)
class_name BattlerData
extends Resource

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""

@export_group("Base Stats")
@export var max_hp: int = 100
@export var max_ee: int = 50
@export var attack: int = 10
@export var defense: int = 10
@export var speed: int = 10
```

```ini
# .tres data file (Godot's "JSON")
[gd_resource type="Resource" script_class="BattlerData"]

[resource]
script = ExtResource("1")
id = &"goblin"
display_name = "Goblin"
max_hp = 45
max_ee = 0
attack = 12
defense = 8
speed = 10
```

Resources are Godot's data layer. They are:

- **Editable in the Inspector** — double-click a `.tres` file to edit its fields visually
- **Loaded at runtime** — `var data: BattlerData = load("res://data/enemies/goblin.tres") as BattlerData`
- **Passed by reference** — multiple nodes can share the same Resource instance
- **Extensible through inheritance** — `CharacterData extends BattlerData` adds growth rates and portraits, `EnemyData extends BattlerData` adds AI type and loot tables

This is the same pattern as defining a TypeScript interface, creating JSON fixtures, and loading them with a service — but with editor integration and type safety built in.

### Creating Resources in Code

```gdscript
# Create a resource instance at runtime (like new BattlerData())
var line := DialogueLine.new()
line.speaker = "Elder"
line.text = "Welcome to our village."

# Or use a static factory method
var line2 := DialogueLine.create("Elder", "Welcome to our village.")
```

### Resource Inheritance

```gdscript
# Base class
class_name BattlerData
extends Resource

@export var max_hp: int = 100
@export var attack: int = 10


# Child class — adds party member fields
class_name CharacterData
extends BattlerData

@export var level: int = 1
@export var hp_growth: float = 10.0
@export var portrait_path: String = ""


# Another child — adds enemy fields
class_name EnemyData
extends BattlerData

@export var ai_type: AiType = AiType.BASIC
@export var xp_reward: int = 10
@export var gold_reward: int = 5
```

This mirrors TypeScript interface extension: `interface CharacterData extends BattlerData { level: number; }`. The child `.tres` files include all parent fields plus their own.

## The Game Loop

This is the one concept with no direct web parallel. Web applications are event-driven — you respond to user actions and API responses. Games are **frame-driven** — the engine calls your code 60 times per second whether anything happened or not.

### _process(delta) — Your Render Loop

```gdscript
# Called every frame (~60 times/second)
func _process(delta: float) -> void:
    # delta is the time in seconds since the last frame
    # On a 60 FPS game, delta ≈ 0.0167
    position.x += speed * delta  # Frame-rate independent movement
```

The closest web analogy is `requestAnimationFrame`. The `delta` parameter ensures movement and animation are independent of frame rate — if a frame takes longer, `delta` is larger, and the movement compensates.

**Use `_process()` for:** visual updates, animation, UI updates, anything that should happen every rendered frame.

### _physics_process(delta) — Fixed Timestep

```gdscript
# Called at a fixed interval (default: 60 times/second, configurable)
func _physics_process(delta: float) -> void:
    var input_dir := Input.get_vector(
        "move_left", "move_right", "move_up", "move_down"
    )
    velocity = input_dir.normalized() * move_speed
    move_and_slide()
```

`_physics_process()` runs at a fixed timestep, independent of rendering frame rate. This is critical for physics calculations and movement — it ensures collision detection is deterministic.

**Use `_physics_process()` for:** movement, collision detection, raycasting, anything involving physics.

### The Frame Lifecycle

Each frame, Godot processes nodes in this order:

```
1. _input()              ← Raw input events (keyboard, mouse, gamepad)
2. _unhandled_input()    ← Input not consumed by UI or _input()
3. _process(delta)       ← Per-frame logic
4. _physics_process(delta) ← Fixed-step physics (may run 0, 1, or more times per frame)
5. Rendering             ← Draw everything to screen
```

In a typical JRPG, most gameplay logic lives in `_physics_process()` (movement, encounters) and `_unhandled_input()` (interaction, menu navigation). `_process()` handles visual-only updates like animation timers and UI tweens.

## No DOM, No CSS — Coordinates and Control Nodes

In web development, you have HTML for structure, CSS for layout, and the browser handles rendering. In Godot, there is no DOM and no CSS. Instead:

### 2D Coordinate System

```
(0, 0) ──────────────── X+
  │
  │     Screen
  │
  Y+
```

- **Origin (0, 0)** is the top-left corner
- **X increases rightward**, **Y increases downward** (opposite of math class, same as the web)
- Positions are in **pixels** (for 2D games)
- Every node has a `position: Vector2` relative to its parent
- `global_position: Vector2` is the absolute position in the world

### Control Nodes = HTML/CSS Elements

For UI, Godot provides `Control` nodes that handle layout, much like CSS flexbox and grid:

| Godot Control | Web Parallel |
|--------------|-------------|
| `VBoxContainer` | `display: flex; flex-direction: column` |
| `HBoxContainer` | `display: flex; flex-direction: row` |
| `GridContainer` | `display: grid` |
| `MarginContainer` | `padding` |
| `PanelContainer` | `<div>` with background |
| `Label` | `<span>` or `<p>` |
| `Button` | `<button>` |
| `TextureRect` | `<img>` |
| `ProgressBar` | `<progress>` |
| `ScrollContainer` | `overflow: scroll` |

Control nodes have **anchors** and **margins** (like CSS `position: absolute` with `top/right/bottom/left`), but they also support **container-based layout** that automatically arranges children — use containers whenever possible, just like you prefer flexbox over absolute positioning in CSS.

```gdscript
# Creating UI in code (you can also design it visually in the editor)
var hbox := HBoxContainer.new()
hbox.add_theme_constant_override("separation", 8)  # gap between children

var label := Label.new()
label.text = "HP:"
hbox.add_child(label)

var bar := ProgressBar.new()
bar.min_value = 0
bar.max_value = 100
bar.value = 75
bar.custom_minimum_size = Vector2(80, 8)
hbox.add_child(bar)
```

## Node Lifecycle

Like Angular components, Godot nodes have lifecycle hooks. The mapping is direct:

| Godot Hook | Angular/Web Parallel | When It Fires |
|-----------|---------------------|---------------|
| `_enter_tree()` | `constructor` | Node added to the scene tree |
| `_ready()` | `ngOnInit()` | Node and all children are in the tree |
| `_process(delta)` | `requestAnimationFrame` callback | Every rendered frame |
| `_physics_process(delta)` | `setInterval` at fixed rate | Every physics tick |
| `_unhandled_input(event)` | `document.addEventListener` | Unprocessed input events |
| `_exit_tree()` | `ngOnDestroy()` | Node removed from tree |

### Critical Detail: _ready() Fires Bottom-Up

This is the most important lifecycle rule in Godot, and it catches everyone:

```
Scene Tree:
  Parent
  ├── ChildA
  │   └── GrandchildA
  └── ChildB

_ready() order:
  1. GrandchildA._ready()
  2. ChildA._ready()
  3. ChildB._ready()
  4. Parent._ready()
```

**Children are ready before parents.** This means when `_ready()` fires on a parent node, all its children are guaranteed to be initialized. This is the opposite of Angular's `ngOnInit()`, which fires top-down.

Why does this matter? It means you can safely access children in `_ready()`:

```gdscript
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
    # Safe — children are already ready
    sprite.visible = true
    collision.disabled = false
```

### @onready — Lazy Initialization After _ready()

```gdscript
# These are evaluated when _ready() fires (children exist)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray: RayCast2D = $InteractionRay
@onready var camera: Camera2D = $Camera2D
```

`@onready` is syntactic sugar. The variable is assigned when `_ready()` is called — not when the script is loaded. Without it, `$Sprite2D` would fail because the child does not exist yet at script load time.

Think of `@onready` as `@ViewChild` in Angular — it resolves a reference to a child element once the view is initialized.

### _enter_tree() vs _ready()

```gdscript
func _enter_tree() -> void:
    # Fires when THIS node is added to the tree
    # Children may NOT be ready yet
    # Use for: registering with global systems, setting up physics layers
    pass


func _ready() -> void:
    # Fires after this node AND all children are in the tree
    # Use for: accessing children, connecting signals, initialization logic
    pass
```

Rule of thumb: use `_ready()` for 99% of initialization. Use `_enter_tree()` only when you need to act before children are available or when a node might be re-added to the tree after removal.

## Groups = CSS Class Selectors

Nodes can belong to **groups** — string-based tags that let you find and communicate with nodes without direct references.

```gdscript
# Adding to a group (like adding a CSS class)
func _ready() -> void:
    add_to_group("player")
    add_to_group("persist")  # Nodes to save on game save

# Finding nodes by group (like document.querySelectorAll('.enemy'))
var enemies: Array[Node] = get_tree().get_nodes_in_group("enemies")
var player: Node = get_tree().get_first_node_in_group("player")

# Calling a method on all nodes in a group (like broadcasting)
get_tree().call_group("enemies", "retreat")
```

Groups provide loose coupling. The player node adds itself to the `"player"` group in `_ready()`. Any system that needs the player — encounter triggers, camera setup, NPC facing — finds it via `get_tree().get_first_node_in_group("player")`. No hardcoded paths, no global variables.

## State Machines = State Management

If you have used NgRx, Redux, or any explicit state management pattern, Godot's state machine pattern will feel natural. The concept is the same: define discrete states, define transitions between them, and ensure only one state is active at a time.

In Godot, the standard pattern uses nodes:

```gdscript
# state.gd — Base state class
class_name State
extends Node

var state_machine: StateMachine


func enter() -> void:
    pass


func exit() -> void:
    pass


func process(_delta: float) -> void:
    pass


func handle_input(_event: InputEvent) -> void:
    pass
```

```gdscript
# state_machine.gd — The state manager
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
        _enter_state(initial_state)


func _process(delta: float) -> void:
    if current_state:
        current_state.process(delta)


func _unhandled_input(event: InputEvent) -> void:
    if current_state:
        current_state.handle_input(event)


func transition_to(state_name: StringName) -> void:
    var new_state: State = get_node_or_null(NodePath(state_name))
    if not new_state:
        push_error("StateMachine: state '%s' not found." % state_name)
        return
    if new_state == current_state:
        return
    var old_state := current_state
    if current_state:
        current_state.exit()
    _enter_state(new_state)
    state_changed.emit(old_state, new_state)


func _enter_state(new_state: State) -> void:
    current_state = new_state
    current_state.enter()
```

The scene tree for a battle state machine looks like this:

```
BattleStateMachine (StateMachine)
├── BattleStart (State)
├── TurnQueueState (State)
├── PlayerTurn (State)
├── ActionSelect (State)
├── TargetSelect (State)
├── EnemyTurn (State)
├── ActionExecute (State)
├── TurnEnd (State)
├── Victory (State)
└── Defeat (State)
```

Each state is a child node. The state machine delegates `_process()` and `_unhandled_input()` to the current state. Transitions happen via `state_machine.transition_to("PlayerTurn")`. States call `exit()` on the old state and `enter()` on the new one.

Compare this to an NgRx/Redux reducer:

```typescript
// Redux-style (conceptual parallel)
function battleReducer(state: BattleState, action: Action): BattleState {
  switch (action.type) {
    case 'TURN_READY':
      return { ...state, phase: 'PLAYER_TURN' };
    case 'ACTION_SELECTED':
      return { ...state, phase: 'TARGET_SELECT' };
    // ...
  }
}
```

The node-based approach is more object-oriented but serves the same purpose: explicit state transitions, clear entry/exit hooks, and a single source of truth for "what mode is the game in right now."

## Scene Instantiation = Dynamic Component Creation

In Angular, you sometimes need to create components at runtime — using `ViewContainerRef.createComponent()` or a component factory. In Godot, this is a first-class operation:

```gdscript
# Load the scene blueprint (like importing a component class)
var enemy_scene: PackedScene = preload("res://entities/battle/enemy_battler_scene.tscn")

# Create an instance (like creating a component)
var enemy: Node2D = enemy_scene.instantiate()

# Configure it (like setting @Input properties)
enemy.position = Vector2(200, 100)

# Add to the tree (like inserting into a ViewContainerRef)
$Entities.add_child(enemy)

# Later: remove and destroy
enemy.queue_free()  # Marks for deletion at end of frame (safe)
```

Key methods:
- `preload("path")` — compile-time load (like a static import)
- `load("path")` — runtime load (like a dynamic import)
- `PackedScene.instantiate()` — creates a new instance of the scene
- `Node.add_child(node)` — inserts a node into the tree, triggering `_enter_tree()` and `_ready()`
- `Node.queue_free()` — schedules the node for deletion at the end of the current frame (safe to call mid-frame)

## get_tree() = The Root Context

`get_tree()` returns the `SceneTree` — the global context for the running application. Think of it as Angular's root `Injector` or `ApplicationRef`.

```gdscript
# Scene management
get_tree().change_scene_to_file("res://scenes/battle/battle.tscn")
get_tree().reload_current_scene()

# Global queries
get_tree().get_nodes_in_group("enemies")
get_tree().get_first_node_in_group("player")

# Group broadcasting
get_tree().call_group("enemies", "retreat")

# Application control
get_tree().quit()
get_tree().paused = true   # Pauses all nodes (except those with process_mode = ALWAYS)

# Current scene reference
var current: Node = get_tree().current_scene
```

## GDScript Static Typing = TypeScript Strict Mode

GDScript supports optional static typing, and you should use it everywhere — just like enabling `strict: true` in TypeScript's `tsconfig.json`.

```gdscript
# Fully typed — the compiler catches type errors at write time
var name: String = "Kael"
var hp: int = 100
var speed: float = 80.0
var position: Vector2 = Vector2.ZERO
var items: Array[String] = ["potion"]
var party: Array[Resource] = []

# Type inference with :=
var direction := Vector2.UP     # Inferred as Vector2
var count := items.size()       # Inferred as int
var is_alive := hp > 0          # Inferred as bool

# Function signatures
func calculate_damage(attack: int, defense: int) -> int:
    return maxi(attack - defense / 2, 1)

# Return void explicitly
func apply_status(effect: StatusEffectData) -> void:
    pass
```

The `:=` operator infers the type from the right-hand side — it is the equivalent of TypeScript's `const x = 5` (where the type is inferred as `number`). Use `:=` for local variables where the type is obvious. Use explicit `: Type` for class-level variables and function parameters.

## .tscn Files = Component Templates

A `.tscn` file is a text-based serialization of a node tree. It is Godot's equivalent of an Angular component template — it defines the structure, hierarchy, and default property values of a scene.

```ini
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://entities/player/player.gd" id="1"]

[node name="Player" type="CharacterBody2D"]
script = ExtResource("1")
move_speed = 80.0

[node name="CollisionShape2D" type="CollisionShape2D" parent="."]
position = Vector2(0, 4)

[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]
position = Vector2(0, -14)

[node name="InteractionRay" type="RayCast2D" parent="."]
target_position = Vector2(0, 24)

[node name="Camera2D" type="Camera2D" parent="."]
```

You rarely edit `.tscn` files by hand — the Godot editor is the visual scene builder. But understanding the format helps with version control diffs and debugging.

## Concept Map Summary

| Godot | Angular / Web | Key Difference |
|-------|-------------|----------------|
| Scene tree | Component tree | Nodes are the framework; scenes are blueprints |
| Node | Component class | ~100 built-in node types vs build-your-own |
| Scene (.tscn) | Component template | Saved node tree, instantiatable |
| Signal | EventEmitter / Subject | Built into every node, type-safe parameters |
| `@export` | `@Input()` | Also editable in the visual Inspector |
| `@onready` | `@ViewChild` | Resolves child reference at _ready() time |
| Autoload | `providedIn: 'root'` service | Global by name, no injection token |
| Resource (.tres) | Interface + JSON data | Editor-integrated, inheritable, pass-by-reference |
| `_ready()` | `ngOnInit()` | Fires bottom-up (children first) |
| `_process(delta)` | `requestAnimationFrame` | Called every frame automatically |
| `_enter_tree()` / `_exit_tree()` | constructor / `ngOnDestroy()` | Tree insertion/removal lifecycle |
| `_unhandled_input()` | `document.addEventListener` | Input not consumed by UI |
| Groups | CSS class selectors | String tags for loose node queries |
| StateMachine + State | NgRx reducer / state management | Node-based, each state is a child node |
| `get_tree()` | Root injector / ApplicationRef | Global application context |
| `class_name` | `@Component` registration | Makes the class available globally |
| GDScript static typing | TypeScript strict mode | Optional but strongly recommended |
| `queue_free()` | Component destruction | Scheduled for end of frame (safe) |

## Common Mistakes When Coming from Web

1. **Forgetting `delta` in movement code.** Without `delta`, your game runs at different speeds on different hardware. Always multiply time-dependent values by `delta`.

2. **Using `_process()` for physics.** Movement and collision go in `_physics_process()`. Visual-only updates go in `_process()`. Mixing them causes jitter and missed collisions.

3. **Accessing children before `_ready()`.** `$Sprite2D` returns `null` if called before the node is in the tree. Use `@onready` or do it in `_ready()`.

4. **Forgetting to disconnect signals from autoloads.** Autoloads outlive scene nodes. If your node connects to `GameManager.some_signal` and gets freed, the connection becomes dangling. Disconnect in `_exit_tree()`.

5. **Using `get_node()` instead of `get_node_or_null()`.** `get_node()` crashes if the path does not exist. Use `get_node_or_null()` and check for null when the child might not be present.

6. **String-based signal connections.** Old Godot tutorials show `connect("signal_name", self, "_method")`. That syntax is deprecated. Use `signal.connect(callable)` — it is type-safe and refactoring-friendly.

7. **Deep inheritance hierarchies.** Godot favors composition. Instead of `Enemy extends Character extends Entity extends Node2D`, use a flat `CharacterBody2D` with child nodes for health, AI, and visuals.

## What is Next

You now have the mental model. In the next chapter, we will create the project, set up the folder structure, configure input actions, and establish the coding conventions that every subsequent chapter follows.

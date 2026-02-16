# Node Lifecycle Best Practices

Distilled from `docs/godot-docs/tutorials/best_practices/` and `tutorials/scripting/`.

## Callback Execution Order

### Scene Entry

```
_init()         # Property initialization (NO tree access)
    ↓
_enter_tree()   # Node added to tree (cascades DOWN from root)
    ↓
_ready()        # All children ready (cascades UP from leaves)
```

### Each Frame

```
_process(delta)         # Every frame (framerate-dependent)
_physics_process(delta) # Every physics tick (fixed timestep)
_input(event)           # On any input event
_unhandled_input(event) # Input not consumed by UI
```

### Scene Exit

```
_exit_tree()    # Node removed from tree
_notification(NOTIFICATION_PREDELETE)  # About to be freed
```

## _init vs _ready vs _enter_tree

| Method | Tree Available? | Children Ready? | Use Case |
|--------|----------------|-----------------|----------|
| `_init()` | No | No | Self-contained setup, property defaults |
| `_enter_tree()` | Yes | No | Tree-dependent setup, not child-dependent |
| `_ready()` | Yes | Yes | Full initialization, wire up references |

## Property Initialization Sequence

1. Property default value assigned (no setter triggered)
2. `_init()` assignments trigger setters
3. Inspector/exported values trigger setters
4. `_ready()` runs after all above complete

## Process Callback Selection

| Callback | When to Use |
|----------|-------------|
| `_process(delta)` | Visual updates, UI, non-physics logic |
| `_physics_process(delta)` | Movement, collision checks, physics |
| `_input(event)` | Global input (pause, screenshot) |
| `_unhandled_input(event)` | Gameplay input (movement, interact) |

### Performance Rule

**Never check input in `_process()` or `_physics_process()`** unless
you need continuous polling (e.g., held button for movement).

For one-shot actions, use `_unhandled_input()`:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_interact()
		get_viewport().set_input_as_handled()
```

## Timer Pattern for Infrequent Operations

```gdscript
func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(_on_tick)
	add_child(timer)


func _on_tick() -> void:
	# Runs every 0.5 seconds instead of every frame
	_update_minimap()
```

## Node Reference Caching (fastest to slowest)

### 1. @onready (preferred)

```gdscript
@onready var sprite: AnimatedSprite2D = $Sprite
```

### 2. @export node reference

```gdscript
@export var target: Node2D
```

### 3. Manual cache in _ready()

```gdscript
var sprite: AnimatedSprite2D

func _ready() -> void:
	sprite = $Sprite
```

### 4. Dynamic get_node() (avoid in hot paths)

```gdscript
# SLOW -- traverses tree every call
get_node("Path/To/Node")

# OK for one-time lookups, bad for _process()
```

## Property Setting Order

**Set properties BEFORE adding to tree**:

```gdscript
var enemy := EnemyScene.instantiate()
enemy.enemy_data = goblin_data    # Set data first
enemy.position = spawn_point      # Set position
add_child(enemy)                  # Add to tree LAST
```

**Why**: Property setters may trigger expensive updates. Setting before
tree entry avoids redundant recalculations.

## Anti-Patterns

- Accessing `$NodePath` in `_init()` (tree doesn't exist yet)
- Calling `get_node()` in `_process()` without caching
- Using `_notification()` when a named callback exists
- Forgetting to call `super()` in overridden virtual methods
- Adding nodes to tree before setting their properties
- Using `call_deferred("_ready")` to re-initialize (create new node instead)

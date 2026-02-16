# Performance Best Practices

Distilled from `docs/godot-docs/tutorials/best_practices/` and `tutorials/rendering/`.

## Data Structure Selection

| Structure | Insert/Erase | Get/Set | Find | Iterate | Use When |
|-----------|-------------|---------|------|---------|----------|
| **Array** | Slow (mid) | Fast (index) | Slow (linear) | Fastest | Ordered lists, indexed access |
| **Dictionary** | Fastest | Fastest (key) | Slow (linear) | Fast | Key-value lookup, sparse data |
| **Object** | N/A | Slower (ClassDB) | N/A | N/A | Structured, typed data |

### Array Tips

- Fast: iterate, get/set by index, add/remove at END
- Slow: insert/erase in middle, find by value
- Use `Dictionary` for frequent lookups by key

### Dictionary Tips

- O(1) insert, delete, and access by key
- Use `StringName` keys for engine-interop performance
- Prefer typed alternatives (Resource, Object) when structure is known

## Script Performance Rules

### Hot Path Optimization

```gdscript
# BAD -- get_node() in every frame
func _process(delta: float) -> void:
	get_node("UI/HealthBar").value = health

# GOOD -- cached reference
@onready var health_bar: ProgressBar = $UI/HealthBar

func _process(delta: float) -> void:
	health_bar.value = health
```

### Avoid load() in Hot Paths

```gdscript
# BAD -- loads resource every call
func spawn_effect() -> void:
	var effect := load("res://effects/hit.tscn").instantiate()

# GOOD -- preloaded constant
const HitEffect := preload("res://effects/hit.tscn")

func spawn_effect() -> void:
	var effect := HitEffect.instantiate()
```

### String Concatenation

```gdscript
# BAD -- creates temporary strings
var msg: String = name + " took " + str(damage) + " damage"

# GOOD -- format string
var msg: String = "%s took %d damage" % [name, damage]
```

### Minimize print() in Production

```gdscript
# Remove or guard debug prints
if OS.is_debug_build():
	print("Debug: ", data)
```

## Scene vs Script Creation

**Scenes are faster** for complex objects because they use serialized data
(engine-optimized batch creation). Scripts make individual API calls.

```gdscript
# SLOWER -- script creates nodes one by one
func _create_ui() -> void:
	var panel := Panel.new()
	var label := Label.new()
	panel.add_child(label)
	# ... many more nodes

# FASTER -- instantiate pre-built scene
const UIPanel := preload("res://ui/panel.tscn")
func _create_ui() -> void:
	var panel := UIPanel.instantiate()
```

## Node Count Management

When node count grows large, consider lighter alternatives:

| Type | Overhead | Use When |
|------|----------|----------|
| **Node** | Full (tree, notifications) | Interactive objects, visual entities |
| **Object** | Minimal | Custom data structures |
| **RefCounted** | Minimal + auto-cleanup | Temporary data, helper objects |
| **Resource** | Minimal + serialization | Persistent data, inspector editing |

## Animation Performance

| System | Cost | Use When |
|--------|------|----------|
| **AnimatedSprite2D** | Low | Simple frame-based sprites |
| **AnimationPlayer** | Medium | Property animations, sequences |
| **AnimationTree** | Higher | Blending, complex state machines |
| **Tween** | Lowest | One-shot procedural animations |

## Physics Performance

- Use `Area2D` for detection (cheaper than `CharacterBody2D`)
- Collision layers/masks to limit checks (don't collide everything with everything)
- Disable `_physics_process()` on inactive objects: `set_physics_process(false)`

## Memory Rules

- `free()` nodes when done (or use `queue_free()` for safe deferred deletion)
- `RefCounted` objects auto-free when no references remain
- Resources are cached by engine -- don't worry about duplicate `load()` calls
- `.duplicate()` resources only when you need independent copies at runtime

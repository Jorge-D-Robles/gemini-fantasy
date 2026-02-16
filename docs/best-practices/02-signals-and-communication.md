# Signals and Communication Best Practices

Distilled from `docs/godot-docs/tutorials/best_practices/` and `tutorials/scripting/`.

## When to Use Signals

- **Announcing state changes**: "I was hit", "I died", "door opened"
- **Decoupling systems**: Combat doesn't need to know about UI
- **Parent-child communication**: Child emits, parent listens
- **Cross-system events**: Inventory change triggers HUD update

## When to Use Direct Method Calls

- **Parent calling child**: Parent knows its children; direct calls are fine
- **Same-system internals**: Methods within a tightly coupled system
- **Performance-critical paths**: Signals have overhead vs direct calls

## Signal Naming

```gdscript
# Past tense -- describes what happened
signal health_changed(new_health: int)
signal item_collected(item: Resource)
signal door_opened
signal enemy_defeated(enemy: Node2D)
signal turn_ended(character: Node)

# NOT imperative -- signals announce, they don't command
# BAD: signal open_door, signal collect_item
```

## Connection Patterns

### Parent connects child signals (preferred)

```gdscript
func _ready() -> void:
	$Player.health_changed.connect(_on_player_health_changed)


func _on_player_health_changed(new_health: int) -> void:
	$UI/HealthBar.value = new_health
```

### Autoload connects global events

```gdscript
# event_bus.gd (autoload)
signal game_paused
signal game_resumed
signal scene_transition_requested(scene_path: String)
```

### Deferred connections for thread safety

```gdscript
signal.connect(method, CONNECT_DEFERRED)
```

## Signal vs Direct Call Decision Tree

```
Does the emitter need to know WHO is listening?
  YES -> Direct method call
  NO  -> Signal

Does the listener need to exist for the emitter to work?
  YES -> Direct method call (or dependency injection)
  NO  -> Signal

Are multiple listeners possible?
  YES -> Signal
  NO  -> Either works; prefer signal for decoupling
```

## Anti-Patterns

- Signals that pass `self` so the receiver can call methods back (circular)
- Connecting signals in `_process()` (connect once in `_ready()`)
- Using strings for signal names (`connect("name")` -- use typed references)
- Emitting signals in `_init()` (nothing is connected yet)
- Signal chains longer than 3 hops (refactor with an event bus)

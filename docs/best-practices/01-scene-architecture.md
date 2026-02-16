# Scene Architecture Best Practices

Distilled from `docs/godot-docs/tutorials/best_practices/`.

## Core Principle: Loose Coupling

Scenes should have **no hard dependencies** on their external environment.
If scenes must interact externally, use **Dependency Injection**.

## Dependency Injection Patterns (safest to most coupled)

### 1. Signals (safest -- for responding to behavior)

```gdscript
# parent.gd
$Child.something_happened.connect(_on_child_something_happened)

# child.gd
signal something_happened
something_happened.emit()
```

### 2. Callable Property (for injecting behavior)

```gdscript
# child.gd
var on_interact: Callable

func interact() -> void:
	if on_interact:
		on_interact.call()

# parent.gd
$Child.on_interact = _handle_interaction
```

### 3. Exported NodePath (for referencing siblings)

```gdscript
# child.gd
@export var target_path: NodePath
@onready var target: Node = get_node(target_path)
```

### 4. Direct Node Reference (most coupled)

```gdscript
# child.gd
var target: Node
```

## Scene Tree as Relational Structure

Think of the tree in **relational terms** (data dependencies), not spatial layout.

- **Parent-child**: Use only when children are elements OF the parent
- **Siblings**: Use when nodes are peers that don't depend on each other
- If removing the parent shouldn't remove the child, they should be siblings
- Use `RemoteTransform2D` when separated nodes must track each other's position

## Recommended Node Hierarchy

```
Main (main.gd)
  ├─ World (Node2D) (game_world.gd)
  └─ GUI (Control) (gui.gd)
```

## Scene Composition Rules

1. **One script per scene** (composition over inheritance)
2. **Break large scenes** into smaller reusable sub-scenes
3. **Scenes are reusable** -- design them to work in any context
4. **Set properties BEFORE adding to tree** (avoids redundant setter calls)
5. **Scene inheritance** -- use sparingly; prefer composition

## Anti-Patterns

- God scenes with dozens of direct children
- Hard-coded paths to nodes outside the scene
- Scenes that assume specific parent types
- Deeply nested hierarchies (flag >5 levels)
- Inline scripts attached to sub-nodes

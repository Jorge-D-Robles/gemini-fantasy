---
name: implement-feature
description: Plan and implement a complete game feature end-to-end. Looks up docs, creates scenes/scripts/resources, and wires everything together. Use for substantial features like combat, dialogue, inventory, or movement systems.
argument-hint: <feature-description>
disable-model-invocation: true
---

# Implement Game Feature

Plan and implement: **$ARGUMENTS**

ultrathink

## Phase 1 — Research

Before writing any code:

1. **Consult the documentation index** at `docs/godot-docs-index.md` to identify which topics and files are relevant
2. **Read class references** for every Godot class you plan to use — read the file at `docs/godot-docs/classes/class_<classname>.rst`
3. **Read tutorials** for the relevant systems — search `docs/godot-docs/tutorials/` using the topic directories listed in CLAUDE.md
4. **Review existing code** — use Glob to find `game/**/*.gd` and `game/**/*.tscn` to understand what already exists and how it's structured

## Phase 2 — Plan

Before creating files, plan the implementation:

1. **List all files** that need to be created or modified
2. **Define the node hierarchy** for each new scene
3. **Define the public API** (signals, exported vars, public methods) for each script
4. **Identify integration points** — how this feature connects to existing systems
5. **Identify resources** — what custom Resource types are needed for data

Present the plan to the user before proceeding.

## Phase 3 — Implement

Create files in this order:

1. **Resources first** — custom Resource classes that define data structures
2. **Core systems** — manager scripts, state machines, utility classes
3. **Scenes** — `.tscn` scene files with node hierarchies
4. **Scripts** — `.gd` scripts attached to scenes
5. **Integration** — wire the feature into existing scenes/scripts via signals

### Code Quality Requirements (from CLAUDE.md)

- Use **tabs** for indentation
- Use **static typing** everywhere: `var health: int = 0`, `func heal(amount: int) -> void:`
- Use `:=` only when type is obvious: `var direction := Vector3(1, 2, 3)`
- Use `@export` for inspector-exposed variables
- Use `@onready` for node references: `@onready var bar: ProgressBar = $UI/Bar`
- Use `and`/`or`/`not` over `&&`/`||`/`!`
- Use **double quotes** for strings
- **Trailing commas** in multiline arrays, dicts, enums
- **Two blank lines** between functions
- Lines under 100 characters
- Signals in **past tense** (`health_changed`, `died`, `item_collected`)
- Private members prefixed with `_`
- One script per scene node (composition over inheritance)
- Prefer signals over direct method calls for decoupled communication

### Script Code Order

```
01. @tool, @icon, @static_unload
02. class_name
03. extends
04. ## doc comment
05. signals
06. enums
07. constants
08. static variables
09. @export variables
10. remaining regular variables
11. @onready variables
12. _init() -> _ready() -> _process() -> _physics_process() -> other virtual methods
13. public methods
14. private methods (prefixed with _)
15. inner classes
```

## Phase 4 — Verify

After implementation:

1. **Check all file paths** — ensure scenes reference correct script paths
2. **Check signal connections** — ensure all signals are connected (either in code or noted for scene editor)
3. **Check autoload requirements** — note if any singletons need registration in project.godot
4. **Check for circular dependencies** — ensure no script directly references something that references it back
5. **List what can't be done in code** — some things (collision shapes, sprite assignment, tilemap painting) require the Godot editor

## Phase 5 — Report

Provide a comprehensive summary:

1. **Files created/modified** with full paths
2. **Architecture overview** — how the pieces connect
3. **Public APIs** — signals, methods, exports for each key script
4. **Editor tasks** — what the user needs to do in the Godot editor (assign sprites, configure collision shapes, paint tilemaps, etc.)
5. **Testing suggestions** — how to verify the feature works
6. **Future enhancements** — what could be improved or extended later

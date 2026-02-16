---
name: scene-audit
description: Audit the project's scene and script architecture for Godot best practices. Checks scene organization, dependency graph, signal patterns, and composition. Use periodically to catch architectural issues early.
argument-hint: [directory-or-file]
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob
---

# Scene Architecture Audit

Audit the project's scene and script architecture. Target: **$ARGUMENTS**

If no target specified, audit the entire `game/` directory.

Before auditing, consult:
- `docs/godot-docs/tutorials/best_practices/scene_organization.rst`
- `docs/godot-docs/tutorials/best_practices/scenes_versus_scripts.rst`
- `docs/godot-docs/tutorials/best_practices/node_alternatives.rst`
- `docs/godot-docs/tutorials/best_practices/project_organization.rst`

## Audit 1 — Project Organization

Check the directory structure against recommended patterns:

```
game/
├── scenes/              # All .tscn scene files
│   ├── characters/      # Player, party members
│   ├── enemies/         # Enemy scenes
│   ├── npcs/            # NPC scenes
│   ├── items/           # Pickups, interactables
│   ├── levels/          # Map/level scenes
│   └── effects/         # Visual effects
├── systems/             # Game system managers
│   ├── combat/
│   ├── inventory/
│   ├── dialogue/
│   ├── save/
│   └── ...
├── ui/                  # UI scenes and scripts
│   ├── hud/
│   ├── menus/
│   ├── dialogue/
│   └── ...
├── data/                # Game data resources (.tres)
│   ├── items/
│   ├── skills/
│   ├── enemies/
│   └── ...
├── assets/              # Art, audio, fonts
│   ├── sprites/
│   ├── audio/
│   ├── fonts/
│   └── tilesets/
└── autoloads/           # Global singleton scripts (if separate)
```

Flag files that are in unexpected locations.

## Audit 2 — Scene Composition

For each `.tscn` file:

1. **Root node type** — Is it appropriate? (CharacterBody2D for characters, Control for UI, Area2D for triggers, etc.)
2. **Script attachment** — Does every scene have exactly one script on the root?
3. **Node depth** — Flag scenes with nodes nested more than 5 levels deep (may need refactoring into sub-scenes)
4. **Inline scripts** — Flag any inline scripts (should be external files)
5. **Scene inheritance** — Check for deep inheritance chains (prefer composition)

## Audit 3 — Dependency Analysis

Build a dependency graph:

1. **Script dependencies** — Grep for `preload()`, `load()`, `class_name` references
2. **Scene dependencies** — Parse `[ext_resource]` entries in `.tscn` files
3. **Autoload dependencies** — Check which scripts reference autoload singletons
4. **Circular dependencies** — Flag any circular reference chains

## Audit 4 — Signal Health

1. **Declared signals** — Grep `signal ` declarations across all scripts
2. **Emitted signals** — Grep `.emit()` calls
3. **Connected signals** — Grep `.connect(` calls
4. **Orphan signals** — Signals declared but never emitted
5. **Unconnected signals** — Signals emitted but never connected (in code — may be connected in editor)
6. **Direct method calls across scenes** — Grep for `get_node("../"` or `get_parent().` patterns that should be signals instead

## Audit 5 — Resource Usage

1. **Custom Resources** — List all `extends Resource` scripts
2. **Resource instances** — Check `.tres` files reference valid script classes
3. **Unused resources** — `.tres` files not referenced by any scene or script
4. **Inline resources** — Resources defined inline in scenes that could be shared

## Audit 6 — Scalability Concerns

1. **God scripts** — Scripts over 300 lines that may need decomposition
2. **Tight coupling** — Scripts that directly reference many other scenes/scripts
3. **Missing abstractions** — Repeated patterns that should be extracted into a shared resource or base class
4. **Hardcoded data** — Game data (stats, item lists, dialogue) embedded in scripts instead of Resources

## Output Format

```
# Scene Architecture Audit Report

## Project Stats
- Scenes: X
- Scripts: Y
- Resources: Z
- Autoloads: N

## Overall Health: [Excellent / Good / Needs Attention / Critical]

## Organization Issues
1. ...

## Composition Issues
1. ...

## Dependency Issues
1. ...

## Signal Health
- Total signals declared: N
- Orphan signals: N
- Direct method calls that should be signals: N

## Scalability Concerns
1. ...

## Recommendations
1. [HIGH] ...
2. [MEDIUM] ...
3. [LOW] ...
```

---
name: godot-doc-lookup
description: Look up Godot documentation for a class, method, or topic. Use when you need API details, tutorial guidance, or code examples from the Godot docs.
argument-hint: <class-name, method, or topic>
context: fork
agent: Explore
allowed-tools: Read, Grep, Glob
---

# Godot Documentation Lookup

You are a Godot documentation retrieval agent. Your job is to find and return relevant documentation from `docsgodot-docs/` for the query: **$ARGUMENTS**

## Search Protocol

Follow this 3-tier system. Start at Tier 1, escalate as needed.

### Tier 1 — Class Reference (if query is a class or method name)

Read the class file directly:

```
docsgodot-docsclassesclass_<classname_lowercase>.rst
```

Examples:
- `CharacterBody2D` → `class_characterbody2d.rst`
- `AnimatedSprite2D` → `class_animatedsprite2d.rst`
- `@GDScript` → `class_@gdscript.rst`
- `@GlobalScope` → `class_@globalscope.rst`

For large files (1000+ lines): read the Description (lines 1-100) first, then Grep for specific methodsproperties.

### Tier 2 — Tutorial Search (if query is a how-to topic)

First, consult `docsgodot-docs-index.md` to identify relevant files.

Then Grep within the matching tutorial subdirectory:

| Directory | Covers |
|-----------|--------|
| `tutorials/2d/` | 2D rendering, tilemaps, sprites, movement, particles, parallax |
| `tutorialsscriptinggdscript/` | GDScript language, exports, typing, style guide |
| `tutorialsscripting/` | Signals, scenes, resources, autoloads, groups, scene tree |
| `tutorialsphysics/` | CharacterBody2D, collision shapes, raycasting, Area2D |
| `tutorialsanimation/` | AnimationPlayer, AnimationTree, cutout animation, 2D skeletons |
| `tutorialsui/` | Control nodes, themes, containers, fonts, GUI navigation |
| `tutorialsinputs/` | InputEvent, input examples, controllers, mouse coordinates |
| `tutorialsnavigation/` | Navigation2D, pathfinding, navigation agentsregions |
| `tutorialsaudio/` | Audio buses, effects, streams, sync |
| `tutorialsio/` | Saving games, data paths, background loading |
| `tutorialsrendering/` | Viewports, multiple resolutions, renderers |
| `tutorialsbest_practices/` | Scene organization, architecture, node alternatives |
| `getting_startedstep_by_step/` | Nodes, scenes, signals, first script |
| `getting_startedfirst_2d_game/` | Complete 2D game tutorial |

### Tier 3 — Broad Search (fallback)

Grep across the entire `docsgodot-docs/` with `glob: "*.rst"`.

## Output Format

Return a structured summary:

1. **Classes found**: List class names with inheritance chain
2. **Key properties**: Name, type, default value, description
3. **Key methods**: Signature, return type, description
4. **Key signals**: Name, parameters, when emitted
5. **Code examples**: Any GDScript snippets found in tutorials (include them verbatim)
6. **Related tutorials**: File paths to relevant tutorials for further reading
7. **Related classes**: Other classes the user might need alongside this one

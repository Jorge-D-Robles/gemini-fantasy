---
name: playtest-check
description: Pre-playtest validation that checks for common issues before running the game. Scans for broken references, missing resources, script errors, and integration problems.
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob, Bash
---

# Pre-Playtest Validation Check

Scan the project for common issues before running the game.

## Check 1 — File Structure Validation

Verify the expected directory structure exists:

```
game/
├── project.godot           # Must exist
├── scenes/                  # Scene files
├── systems/                 # Game system managers
├── ui/                      # UI screens
├── assets/                  # Art, audio, fonts
└── data/                    # Game data (items, skills, etc.)
```

Use `Glob` to scan `game/**/*.tscn` and `game/**/*.gd` and report what exists.

## Check 2 — Script Compilation Issues

For every `.gd` file found:

1. Check that `extends` matches a valid Godot class or custom class
2. Check that `class_name` is unique across all scripts
3. Check for obvious syntax issues:
   - Unmatched parentheses/brackets
   - Missing colons after `func`, `if`, `for`, `while`, `class`, `enum`
   - Missing `extends` declaration
4. Check that all `preload()` and `load()` paths start with `res://` and reference existing files

## Check 3 — Scene Reference Integrity

For every `.tscn` file found:

1. Check that all `[ext_resource]` paths reference existing files
2. Check that script paths in scenes match existing `.gd` files
3. Check that scene inheritance (if any) references existing base scenes
4. Check for nodes referencing missing resource files (textures, audio, etc.)

## Check 4 — Autoload Consistency

Read `game/project.godot` and check:

1. All autoload paths reference existing script files
2. Autoload names match the `class_name` in the script (if defined)
3. No duplicate autoload names

## Check 5 — Signal Connection Audit

Grep all `.gd` files for:

1. `signal <name>` declarations — catalog all defined signals
2. `.connect(` calls — check that referenced signals exist
3. `.emit()` calls — check that the signal is defined in the same class or parent

Report any disconnected signals (declared but never emitted, or connected but never declared).

## Check 6 — Common JRPG Issues

Check for:

1. **Missing input actions** — Grep for `Input.is_action_pressed` and `Input.get_axis` calls, verify the action names exist in project.godot
2. **Orphan scripts** — `.gd` files not referenced by any `.tscn` file and not autoloaded
3. **Orphan scenes** — `.tscn` files not referenced by any other scene or script
4. **Resource path typos** — `res://` paths that don't match actual file locations
5. **Z-index conflicts** — Multiple nodes at same z_index that might overlap incorrectly

## Check 7 — Performance Warnings

Grep for common performance anti-patterns:

1. `get_node()` or `$` inside `_process()` or `_physics_process()` (should be cached in `@onready`)
2. `load()` inside `_process()` or `_physics_process()` (should be preloaded or cached)
3. String concatenation with `+` in hot paths (prefer `%s` formatting)
4. `print()` calls that should be removed before release

## Output Format

```
# Pre-Playtest Check Results

## Summary
- Files scanned: X scenes, Y scripts
- ✅ Passed: N checks
- ⚠️ Warnings: N issues
- ❌ Errors: N critical issues

## Critical Issues (must fix)
1. ...

## Warnings (should fix)
1. ...

## Performance Notes
1. ...

## Suggestions
1. ...
```

Report issues with specific file paths and line numbers where possible.

---
name: integration-check
description: Verify that game systems are properly wired together. Checks signal connections, autoload references, resource paths, and cross-system dependencies. Use after building multiple systems to ensure they integrate correctly.
argument-hint: [system-name or "all"]
context: fork
agent: general-purpose
allowed-tools: Read, Grep, Glob
---

# Integration Check

Verify system integration for: **$ARGUMENTS**

If no specific system is given, check ALL systems.

## Check 1 — Autoload Registry

1. Read `gameproject.godot` and extract the `[autoload]` section
2. For each registered autoload:
   - Verify the script file exists at the registered path
   - Verify the class_name matches the autoload name
   - Verify the script extends Node (or appropriate base)
3. For each `game/autoloads/*.gd` or `game/systems/*/` manager script:
   - Check if it SHOULD be an autoload but ISN'T registered
4. **Report**: List all autoloads, their status, and any missing registrations

## Check 2 — Signal Wiring

For each system being checked:

1. **Find all signal declarations**: `Grep for "^signal " in game/**/*.gd`
2. **Find all signal emissions**: `Grep for "\.emit\(" in game/**/*.gd`
3. **Find all signal connections**: `Grep for "\.connect\(" in game/**/*.gd`
4. For each declared signal, verify:
   - It is emitted somewhere (orphan signal if not)
   - It is connected somewhere (dead signal if not)
   - The connection target method exists
   - The signal parameters match between declaration, emission, and connection
5. **Report**: List orphan signals, dead signals, and mismatched parameters

## Check 3 — Cross-System Dependencies

1. For each manager script, find all references to OTHER managers:
   - Direct references: `SaveManager.`, `AudioManager.`, etc.
   - Signal connections to other systems
2. Build a dependency graph
3. Check for:
   - **Circular dependencies**: System A depends on System B which depends on System A
   - **Missing dependencies**: Referenced system doesn't exist or isn't autoloaded
   - **Initialization order issues**: System A uses System B in `_ready()` but B isn't ready yet
4. **Report**: Dependency graph and any issues found

## Check 4 — Resource Path Integrity

1. Find all `preload()` and `load()` calls in `game/**/*.gd`
2. For each path:
   - Verify the file exists
   - Verify the file type matches usage (`.tscn` for scenes, `.tres` for resources, `.gd` for scripts)
3. Find all `[ext_resource]` entries in `game/**/*.tscn`
4. For each:
   - Verify the referenced file exists
   - Verify the type declaration matches
5. **Report**: List all broken paths and type mismatches

## Check 5 — Scene-System Integration

1. For each scene in `gamescenes/`:
   - Check if it references systems it should (e.g., does the battle scene reference combat system?)
   - Check if scene scripts properly emit signals that UI and systems listen to
2. For each UI scene in `gameui/`:
   - Check if it connects to the appropriate manager signals
   - Check if it calls manager public methods (not private)
3. **Report**: List integration gaps

## Check 6 — Data Layer Consistency

1. For each Resource class in the project:
   - Find all `.tres` files that use it
   - Verify all required `@export` fields are set in the `.tres` files
   - Check for duplicate `id` values
2. For each system that loads data:
   - Verify the data directory exists
   - Verify at least one `.tres` file exists (warn if empty)
3. **Report**: Data integrity issues

## Output Format

```markdown
# Integration Check Report

## Summary
- Systems checked: N
- Issues found: N (X critical, Y warnings)
- Integration score: X/100

## Critical Issues (must fix)
1. [CRITICAL] <description> — <file:line>

## Warnings (should fix)
1. [WARNING] <description> — <file:line>

## Info (nice to know)
1. [INFO] <description>

## Dependency Graph
```
SystemA -> SystemB (signals: event_a, event_b)
SystemB -> SystemC (direct reference)
SystemC -> SystemA (⚠️ CIRCULAR)
```

## Recommendations
1. ...
```

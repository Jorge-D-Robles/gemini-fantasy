---
name: debug-issue
description: Diagnose and fix a bug or runtime issue in the game. Analyzes error messages, traces code paths, checks Godot docs, and applies fixes. Use when something doesn't work as expected.
argument-hint: <error-message or behavior-description>
disable-model-invocation: true
---

# Debug Issue

Diagnose and fix: **$ARGUMENTS**


## Step 1 — Understand the Problem

1. **Parse the error** — Is it a GDScript error, scene loading error, logic bug, or visual issue?
2. **Identify the error type**:

| Error Type | Indicators | First Steps |
|-----------|------------|-------------|
| Parsesyntax error | `Parser Error`, line number | Read the file at the line |
| Runtime null reference | `Invalid get index`, `on null instance` | Trace the null variable |
| Scene loading error | `Failed to load`, `Resource not found` | Check file paths |
| Signal error | `Signal not found`, `Cannot connect` | Verify signal declarations |
| Type error | `Invalid type`, `Cannot convert` | Check static types |
| Logic bug | "Works but wrong behavior" | Trace the code path |
| Performance | Slow, stuttering, freezing | Profile hot paths |
| Visual | Z-order, positioning, missing sprites | Check layers and visibility |

## Step 2 — Gather Context

1. **Read the file** where the error occurs
2. **Read connected files** — scripts that reference or are referenced by the error file
3. **Check the scene** — read the `.tscn` file for node structure and connections
4. **Check autoloads** — verify required singletons are registered in `project.godot`
5. **Check resource paths** — verify all `preload()` and `load()` paths exist

## Step 3 — Diagnose Root Cause

### Common JRPG Bug Patterns

**Null reference on scene change:**
- Node was freed but reference wasn't cleared
- Autoload accessed before `_ready()` completed
- Signal connected to freed node
- Fix: Use `is_instance_valid()`, `weak_ref()`, or disconnect signals in `_exit_tree()`

**Wrong node found by get_node():**
- Path changed due to scene restructuring
- Node name has typo
- Fix: Use `@onready` with explicit type, or `@export` node references

**Signal not received:**
- Signal connected to wrong instance
- Signal emitted before connection
- Connection was deferred but timing matters
- Fix: Verify connection code runs before emission

**Resource not loading:**
- Path uses wrong case (Linux is case-sensitive)
- File moved but path not updated
- `.import` file missing or corrupted
- Fix: Verify path exists with Glob, check case sensitivity

**State machine stuck:**
- Transition condition never met
- Exit not called on previous state
- State entered but no process callback runs
- Fix: Add logging to state transitions, check process enabled

**Battle system bugs:**
- Turn queue empty after all enemies defeated
- Negative HP not clamped
- Status effect ticks after battle ends
- Fix: Add bounds checking, verify battle end conditions

## Step 4 — Look Up Docs (MANDATORY before applying any fix)

**Before writing ANY fix, you MUST verify the correct API usage:**

1. **Call the `godot-docs` skill** for the classes involved in the bug:
   ```
   activate_skill("godot-docs") # Look up [CLASS]. I need to verify the correct API for [methodpropertysignal] to fix a [ERROR_TYPE] issue.
   ```
2. **Read the relevant best practices file** to ensure the fix follows project patterns
3. Do NOT apply a fix based on assumptions — verify in the docs first

## Step 5 — Apply Fix

1. Make the minimal change that fixes the issue
2. Don't refactor surrounding code unless it caused the bug
3. Add a comment only if the fix is non-obvious
4. If the fix requires adding null checks, consider if the root cause is upstream

## Step 6 — Verify Fix

1. Check that the fix doesn't introduce new issues
2. Trace the code path mentally to verify correctness
3. Check for similar bugs in related code (same pattern might be wrong elsewhere)

## Step 7 — Report

1. **Root cause** — What caused the bug
2. **Fix applied** — What was changed and why
3. **Files modified** — Full paths with line numbers
4. **Related risks** — Could this pattern be wrong elsewhere?
5. **Prevention** — How to avoid this type of bug in the future

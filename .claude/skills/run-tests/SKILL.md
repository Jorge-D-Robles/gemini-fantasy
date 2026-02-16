---
description: Run the automated test suite (gdlint + GUT unit tests). Use before committing or pushing code to catch errors early.
---

# /run-tests — Automated Test Runner

Run the two-tier testing pipeline: static analysis (gdlint) then unit tests (GUT headless).

## Steps

### 1. Static Analysis with gdlint

Run gdlint on all GDScript files to catch style and syntax issues:

```bash
/Users/robles/Library/Python/3.10/bin/gdlint game/ 2>&1
```

Report any findings. If gdlint fails with errors, list them and note they should be fixed before pushing.

### 2. Unit Tests with GUT (Headless)

Run the GUT test suite headless via the Godot CLI. **IMPORTANT:** Use `--path` pointing to the **main repo** (not the worktree) because Godot's `.godot/` import cache lives there. The test `.gd` files are tracked in git and available at both paths.

**First, pull the latest into the main repo** so Godot sees the newest test files:

```bash
git -C /Users/robles/repos/games/gemini-fantasy pull 2>&1
```

**If GUT was recently added or updated**, run the import step first (only needed once after adding new GUT files):

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless \
  --path /Users/robles/repos/games/gemini-fantasy/game/ --import 2>&1
```

**Then run the tests:**

```bash
/Applications/Godot.app/Contents/MacOS/Godot --headless \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  -d -s res://addons/gut/gut_cmdln.gd \
  -gdir=res://tests/ -ginclude_subdirs -gexit -glog=2 2>&1
```

**Timeout:** Allow up to 120 seconds. GUT will auto-exit after tests complete.

**If you get "class_names not imported" error**, run the `--import` command above first.

### 3. Report Results

Summarize:
- **gdlint:** PASS / N issues found
- **GUT:** X tests passed, Y failed, Z pending
- **Overall:** PASS (safe to push) / FAIL (fix before pushing)

If any tests fail, show the failure details so the agent can fix them before committing.

## When to Use

- **Before every commit/push** (mandatory per project rules)
- After writing new test files to verify they pass
- After modifying game logic to catch regressions
- When debugging to verify a fix

## Exit Codes

- `0` from both gdlint and GUT = all clear, safe to push
- Non-zero from either = fix issues before pushing

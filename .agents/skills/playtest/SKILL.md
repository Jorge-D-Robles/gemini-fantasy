---
name: playtest
description: Run an automated playtest of the game with full state injection. Loads a scene with realistic game state (party, flags, items), executes a scripted action sequence, captures screenshots, and returns a structured JSON report. Use to verify that systems work together in context — player spawn, dialogue flow, battle sequences, UI state.
argument-hint: <preset|scene-path> [--party=kael,lyra] [--flags=flag1,flag2] [--gold=N] [--output=/tmp/playtest/] [--timeout=N] [--disable-encounters]
---

# Playtest Runner

Run a playtest for: **$ARGUMENTS**

## Step 1 — Parse Arguments

Extract from `$ARGUMENTS`:

**Preset names** (resolve to `game/tools/playtest_presets/<name>.json`):
- `new_game` or `new-game` — Kael only, Overgrown Ruins, no flags
- `mid_game` or `mid-game` — Kael+Lyra+Iris, Roothollow, mid-game flags/items
- `late_game` or `late-game` — Full party, Roothollow, all flags, full equipment
- `battle_test` or `battle-test` — Mid-game state, triggers battle immediately
- `boss_test` or `boss-test` — Late-game state, triggers boss encounter
- `dialogue_test` or `dialogue-test` — Roothollow, walks to NPC, captures dialogue
- `full_walkthrough` or `full-walkthrough` — Full demo walkthrough from ruins start

**Direct scene path** (e.g., `res://scenes/roothollow/roothollow.tscn`):
If a `res://` path is provided, build an inline config from CLI args.

**Inline CLI args** (override or supplement preset):
- `--party=kael,lyra,iris` — party member IDs
- `--flags=opening_lyra_discovered,iris_recruited` — event flags to set
- `--gold=N` — starting gold
- `--output=/tmp/playtest/` — output directory
- `--timeout=N` — timeout in seconds (default: 60)
- `--disable-encounters` — disable random encounters
- `--screenshot-after=N` — wait N seconds then capture (for quick one-off checks)
- `--spawn-point=name` — Marker2D group name for spawn

## Step 2 — Sync Main Repo

Pull the latest code so Godot sees current scripts and data files:

```bash
git -C /Users/robles/repos/games/gemini-fantasy pull 2>&1
```

## Step 3 — Prepare Config

**Preset mode**: use the preset JSON file directly:
```bash
PRESET_PATH="/Users/robles/repos/games/gemini-fantasy/game/tools/playtest_presets/<name>.json"
```

**Direct scene / inline mode**: write a temporary config to `/tmp/playtest_config.json`:
```json
{
  "scene": "<SCENE_PATH>",
  "state": { "party": [...], "flags": [...], "gold": N },
  "actions": [
    {"type": "wait", "seconds": 2},
    {"type": "screenshot", "label": "initial_state"}
  ],
  "options": {
    "timeout_seconds": 60,
    "disable_encounters": true,
    "disable_bgm": true,
    "output_dir": "/tmp/playtest/"
  }
}
```

## Step 4 — Run Playtest

**Preset mode**:
```bash
timeout <TIMEOUT> /Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  --rendering-driver opengl3 \
  --windowed --resolution 640x360 \
  res://tools/playtest_runner.tscn \
  -- --config=<PRESET_PATH> 2>&1 | tee /tmp/godot_run.log
```

**Inline mode**:
```bash
timeout <TIMEOUT> /Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  --rendering-driver opengl3 \
  --windowed --resolution 640x360 \
  res://tools/playtest_runner.tscn \
  -- --config=/tmp/playtest_config.json 2>&1 | tee /tmp/godot_run.log
```

**TIMEOUT** = preset's timeout_seconds + 15 seconds buffer (or 75 for simple runs).

**Notes:**
- Use `--path` pointing to the **main repo** (not the worktree) — it has the `.godot/` import cache
- Use `--rendering-driver opengl3` for reliable rendering
- The runner exits 0 on success, 1 on errors/timeout
- Screenshots and `report.json` land in the output directory (default: `/tmp/playtest/`)
- Pipe output through `tee /tmp/godot_run.log` to capture engine errors

## Step 4b — Check for Engine Errors

After the Godot run, scan the log for errors and warnings:

```bash
grep -iE "ERROR|SCRIPT ERROR|Failed|push_error|push_warning|Cannot|null" /tmp/godot_run.log | grep -v "^$" | head -30
```

Report any engine-level errors alongside the playtest results in Step 7.

## Step 5 — Read Report

Read the JSON report to check results:

```
Read("/tmp/playtest/report.json")
```

Parse the key fields:
- `success` — whether the run completed without errors
- `duration_seconds` — total runtime
- `actions_completed` / `actions_total` — how many actions ran
- `errors` — any errors detected
- `warnings` — non-fatal issues (missing assets, etc.)
- `screenshots` — list of captured screenshots

## Step 6 — Display Screenshots

Read each captured screenshot to visually verify the game state:

```
Read("/tmp/playtest/001_<label>.png")
Read("/tmp/playtest/002_<label>.png")
...
```

## Step 7 — Report Results

Summarize what you found:
- **Overall**: PASS or FAIL (based on `success` field and screenshot review)
- **Player spawn**: Did the player character appear correctly?
- **Party state**: Are the correct party members shown in the HUD?
- **Scene rendering**: Does the scene look correct?
- **Actions**: Did all scripted actions execute as expected?
- **Errors/warnings**: List any errors from the report
- **Screenshots**: Describe what each screenshot shows

If the report shows errors or screenshots reveal issues, describe them specifically so the agent can fix them.

## Preset Reference

| Preset | Scene | Party | Flags | Purpose |
|--------|-------|-------|-------|---------|
| `new_game` | overgrown_ruins | kael | none | Verify fresh game state |
| `mid_game` | roothollow | kael+lyra+iris | lyra+iris discovered | Mid-game HUD, shop, dialogue |
| `late_game` | roothollow | full party | all | Full party UI, equipment |
| `battle_test` | verdant_forest | kael+lyra+iris | lyra+iris | Battle system integration |
| `boss_test` | overgrown_ruins | full party | all | Boss battle (The Last Gardener) |
| `dialogue_test` | roothollow | kael+lyra | lyra | NPC dialogue flow |
| `full_walkthrough` | overgrown_ruins | kael | none | End-to-end demo opening |

## Examples

```
# Verify mid-game state renders correctly
/playtest mid_game

# Quick battle system check
/playtest battle_test

# One-off scene check with state
/playtest res://scenes/verdant_forest/verdant_forest.tscn --party=kael,lyra --screenshot-after=2

# Custom config file
/playtest --config=/tmp/my_test.json
```

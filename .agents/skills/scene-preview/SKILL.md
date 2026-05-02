---
name: scene-preview
description: Capture a screenshot of a Godot scene for visual verification. Runs the scene briefly in windowed mode, captures a frame, and displays the result. Use after building or modifying tilemaps, UI, or entity placement.
argument-hint: <scene-path> [--full-map] [--camera-x=N --camera-y=N] [--zoom=N] [--show-ui] [--wait-frames=N]
---

# Scene Preview

Capture a screenshot of: **$ARGUMENTS**

## Step 1 — Parse Arguments

Extract from `$ARGUMENTS`:
- **Scene path**: Required. A `res://` path to a `.tscn` file (e.g., `res://scenes/verdant_forest/verdant_forest.tscn`)
- **Flags**: Any combination of `--full-map`, `--camera-x=N`, `--camera-y=N`, `--zoom=N`, `--show-ui`, `--wait-frames=N`

If the user provides a short name (e.g., "verdant forest"), resolve it to the full `res://scenes/<name>/<name>.tscn` path.

Default output path: `/tmp/scene_preview.png`

## Step 2 — Sync Main Repo

Pull the latest code into the main repo so Godot sees current scripts and scenes:

```bash
git -C /Users/robles/repos/games/gemini-fantasy pull 2>&1
```

## Step 3 — Run Godot Preview

Run the scene preview tool. This opens a brief Godot window, captures a screenshot, and exits. Pipe output to a log file for error capture.

```bash
timeout 30 /Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  --rendering-driver opengl3 \
  res://tools/scene_preview.tscn \
  -- --preview-scene=<SCENE_PATH> --output=/tmp/scene_preview.png <FLAGS> 2>&1 | tee /tmp/godot_run.log
```

**Important:**
- Use `--path` pointing to the **main repo** (not the worktree) because Godot needs the `.godot/` import cache
- Use `--rendering-driver opengl3` for reliable screenshot capture
- The `timeout 30` prevents hangs — the tool should exit in under 5 seconds
- Check exit code: 0 = success, 1 = error (check stderr for details)

## Step 3b — Check for Errors

After the Godot run, scan the log for errors and warnings:

```bash
grep -iE "ERROR|SCRIPT ERROR|Failed|push_error|push_warning|Cannot|null" /tmp/godot_run.log | grep -v "^$" | head -30
```

Report any errors found alongside the screenshot analysis in Step 5.

## Step 4 — Display the Screenshot

Read the screenshot image so the agent can see it:

```
Read("/tmp/scene_preview.png")
```

## Step 5 — Report

Describe what you see in the screenshot:
- Overall layout and composition
- Tile variety and visual quality
- Entity placement (player, NPCs, objects)
- Any visible issues (gaps, misaligned tiles, missing textures, black areas)
- Suggestions for improvement if applicable

If the screenshot is a 1x1 red pixel, the capture failed — check the Godot error output from Step 3.

## Camera Modes

| Mode | Flags | Use When |
|------|-------|----------|
| Default | (none) | Scene has its own Camera2D (e.g., player camera) |
| Full-map | `--full-map` | View entire tilemap zoomed to fit viewport |
| Positioned | `--camera-x=N --camera-y=N` | Focus on a specific area |
| Custom zoom | `--zoom=N` | Override auto-zoom (0.5 = zoom out 2x, 2.0 = zoom in 2x) |

## Examples

```
# Full map view of Verdant Forest
/scene-preview res://scenes/verdant_forest/verdant_forest.tscn --full-map

# Default camera (player perspective)
/scene-preview res://scenes/roothollow/roothollow.tscn

# Custom position and zoom
/scene-preview res://scenes/verdant_forest/verdant_forest.tscn --camera-x=384 --camera-y=304 --zoom=0.8

# With HUD visible
/scene-preview res://scenes/roothollow/roothollow.tscn --full-map --show-ui
```

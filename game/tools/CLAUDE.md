# game/tools/

Developer tooling for visual verification and debugging. Not part of the shipped game.

## Files

| File | Purpose |
|------|---------|
| `scene_preview.tscn` | Entry-point scene — run this via Godot CLI to capture screenshots |
| `scene_preview.gd` | Script: loads a target scene, sets up camera, captures PNG, exits |

## scene_preview — Visual Verification Tool

Used by the `/scene-preview` skill to capture screenshots of any scene for visual QA. It:
1. Loads the target scene (`--preview-scene=`)
2. Optionally hides the UI layer (default) or shows it (`--show-ui`)
3. Sets up a Camera2D (default, positioned, or full-map auto-fit)
4. Waits N frames for rendering to settle
5. Captures the viewport as PNG and exits with code 0 (success) or 1 (error)

### CLI Arguments (pass after `--`)

| Argument | Default | Description |
|----------|---------|-------------|
| `--preview-scene=res://...` | required | Scene to load and capture |
| `--output=/path/to/file.png` | `/tmp/scene_preview.png` | Output PNG path |
| `--full-map` | false | Auto-fit camera to show all TileMapLayer cells |
| `--camera-x=N` | — | Position camera at X (use with `--camera-y`) |
| `--camera-y=N` | — | Position camera at Y |
| `--zoom=N` | `1.0` | Override zoom level (e.g. `0.5` = zoom out 2×) |
| `--show-ui` | false | Keep the UILayer visible in the screenshot |
| `--wait-frames=N` | `5` | Frames to wait before capturing |

### Manual Invocation

```bash
/Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  --rendering-driver opengl3 \
  res://tools/scene_preview.tscn \
  -- --preview-scene=res://scenes/<name>/<name>.tscn \
     --output=/tmp/scene_preview.png --full-map
```

### Usage via Skill

Prefer `/scene-preview` in most cases — see root CLAUDE.md "Visual Verification" section.

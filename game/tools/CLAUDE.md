# game/tools/

Developer tooling for visual verification and automated integration testing. Not part of the shipped game.

## Files

| File | Purpose |
|------|---------|
| `scene_preview.tscn` | Entry-point scene — run via Godot CLI to capture static screenshots |
| `scene_preview.gd` | Script: loads a target scene, sets up camera, captures PNG, exits |
| `playtest_runner.tscn` | Entry-point scene — run via Godot CLI for full-state integration testing |
| `playtest_runner.gd` | Script: config parsing, state injection, action execution, screenshot capture, JSON report |
| `playtest_config.gd` | Static utility: JSON config parsing, CLI arg parsing, defaults, validation |
| `playtest_capture.gd` | Static utility: screenshot capture, filename formatting, JSON report building |

---

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

---

## playtest_runner — Full-State Integration Testing Tool

Used by the `/playtest` skill to run the game with full autoload support, inject game state,
navigate to a target scene, execute a scripted input sequence, and capture screenshots + a
JSON report. Unlike scene_preview (static layout check), playtest_runner tests live gameplay.

### Key Differences from scene_preview

| Aspect | scene_preview | playtest_runner |
|--------|--------------|-----------------|
| Autoloads | Minimal | Fully initialized with injected state |
| Scene loading | Child of preview tool | Via `GameManager.change_scene()` |
| Player state | No party/flags | Full party, equipment, levels, flags |
| Input | None | Simulated movement, interact, menus |
| Screenshots | Single frame | Multiple labeled captures |
| Output | Single PNG | PNGs + JSON report |

### CLI Invocation

**Config file mode** (for complex multi-step sequences):
```bash
/Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  --rendering-driver opengl3 \
  --windowed --resolution 640x360 \
  res://tools/playtest_runner.tscn \
  -- --config=/tmp/playtest_config.json
```

**Inline arg mode** (for quick one-off checks):
```bash
/Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  --rendering-driver opengl3 \
  res://tools/playtest_runner.tscn \
  -- --scene=res://scenes/roothollow/roothollow.tscn \
     --party=kael,lyra,iris \
     --flags=opening_lyra_discovered,iris_recruited \
     --gold=500 \
     --screenshot-after=2 \
     --output=/tmp/playtest/
```

### Config Schema

```json
{
  "scene": "res://scenes/roothollow/roothollow.tscn",
  "spawn_point": "spawn_from_forest",
  "state": {
    "party": ["kael", "lyra", "iris"],
    "party_levels": {"kael": 5, "lyra": 4},
    "flags": ["opening_lyra_discovered", "iris_recruited"],
    "inventory": {"potion": 5, "hi_potion": 2},
    "gold": 1500,
    "equipment": {"kael": {"weapon": "steel_sword"}},
    "quests": []
  },
  "actions": [
    {"type": "wait", "seconds": 1.0},
    {"type": "screenshot", "label": "initial_spawn"},
    {"type": "move", "direction": "right", "seconds": 2.0},
    {"type": "screenshot", "label": "after_movement"},
    {"type": "interact"},
    {"type": "wait_dialogue"},
    {"type": "screenshot", "label": "post_dialogue"},
    {"type": "trigger_battle", "enemies": ["memory_bloom"]},
    {"type": "wait_battle", "timeout": 30.0},
    {"type": "screenshot", "label": "battle_ended"}
  ],
  "options": {
    "timeout_seconds": 60.0,
    "capture_on_error": true,
    "capture_interval_seconds": 0,
    "disable_encounters": true,
    "disable_bgm": true,
    "output_dir": "/tmp/playtest/",
    "viewport_width": 640,
    "viewport_height": 360
  }
}
```

### Action Types

| Type | Fields | Description |
|------|--------|-------------|
| `wait` | `seconds: float` | Wait N seconds |
| `screenshot` | `label: String` | Capture labeled screenshot |
| `move` | `direction: String, seconds: float` | Move player (up/down/left/right) |
| `interact` | — | Press interact action |
| `cancel` | — | Press cancel action |
| `menu` | — | Press menu action |
| `advance_dialogue` | — | Press interact to advance dialogue |
| `wait_dialogue` | `timeout: float = 10` | Wait until dialogue ends |
| `select_choice` | `index: int` | Select dialogue choice |
| `trigger_battle` | `enemies: Array[String]` | Force-start a battle |
| `wait_battle` | `timeout: float = 30` | Wait until battle ends |
| `auto_play_battle` | `enemies?: Array[String], can_escape?: bool, timeout?: float` | Auto-play a battle using attack-first AI; optionally triggers battle; logs outcome |
| `wait_state` | `state: String, timeout: float` | Wait for GameManager state |
| `set_flag` | `flag: String` | Set event flag mid-sequence |
| `log` | `message: String` | Write to playtest log |

### Output

```
/tmp/playtest/
  001_initial_spawn.png
  002_after_movement.png
  003_post_dialogue.png
  report.json          # structured JSON report
```

### report.json Structure

```json
{
  "success": true,
  "duration_seconds": 12.4,
  "scene": "res://scenes/roothollow/roothollow.tscn",
  "screenshots": [{"index": 1, "label": "initial_spawn", "file": "001_initial_spawn.png"}],
  "errors": [],
  "warnings": [],
  "actions_completed": 8,
  "actions_total": 8,
  "final_state": {
    "game_state": "OVERWORLD",
    "party_count": 3,
    "party_hp": {},
    "flags": [],
    "gold": 1500,
    "player_position": {"x": 0.0, "y": 0.0}
  }
}
```

### Usage via Skill

Prefer `/playtest` in most cases — see T-0146 for the skill wrapper and presets.

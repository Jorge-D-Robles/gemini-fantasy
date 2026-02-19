# Playtest Runner — Automated Full-State Game Testing

## Problem

The current `/scene-preview` tool captures a single screenshot of a scene loaded in isolation. It bypasses the game's normal startup path: it adds the scene as a child of the preview tool rather than loading it through `GameManager.change_scene()`. This means:

- **No game state** — PartyManager has no characters, InventoryManager is empty, EventFlags has no flags
- **No player context** — the Player entity may appear but has no party backing, no save data, no progression
- **No interaction** — a single frame is captured; you cannot observe movement, dialogue flow, battle sequences, or scene transitions
- **No autoload wiring** — UILayer's HUD, DialogueBox, and PauseMenu exist but have no game data to display
- **No encounter testing** — random encounters, boss fights, and event triggers cannot fire

As a result, agents building features like the battle system, dialogue sequences, NPC interactions, or UI overlays cannot verify that their code actually works in context. Bugs that only manifest when systems interact (e.g., battle UI locking up when the player has no party members, or dialogue failing when EventFlags are in a specific state) go undetected until a human playtests.

## Solution: Playtest Runner

A new tool scene (`game/tools/playtest_runner.tscn`) that runs the game with full autoload support, injects configurable game state, navigates to a target scene, executes a scripted sequence of simulated inputs, and captures screenshots + logs at key moments.

### Key Insight

When Godot starts, autoloads initialize first (in `project.godot` order), then the main scene loads. By passing `res://tools/playtest_runner.tscn` as the scene argument to the Godot CLI, we get the playtest runner as the main scene with **all 12 autoloads fully initialized**:

```
GameManager, AudioManager, PartyManager, BattleManager, DialogueManager,
EventFlags, EventBus, InventoryManager, EquipmentManager, SaveManager,
QuestManager, ShopManager, UILayer
```

This is identical to how the real game boots — the only difference is which scene loads first.

## Architecture

### Overview

```
┌─────────────────────────────────────────────────────────────────┐
│  Godot CLI                                                      │
│  godot --path game/ res://tools/playtest_runner.tscn            │
│         -- --config=/tmp/playtest_config.json                   │
├─────────────────────────────────────────────────────────────────┤
│  1. All autoloads initialize (GameManager, PartyManager, etc.)  │
│  2. PlaytestRunner._ready() reads config JSON                   │
│  3. State injection: party, flags, inventory, gold, equipment   │
│  4. Scene navigation via GameManager.change_scene()             │
│  5. Action executor runs scripted input sequence                │
│  6. Screenshot capture at specified moments                     │
│  7. Structured output: screenshots + JSON report + error log    │
│  8. Exit with code 0 (success) or 1 (errors detected)          │
└─────────────────────────────────────────────────────────────────┘
```

### Files

| File | Action | Purpose |
|------|--------|---------|
| `game/tools/playtest_runner.tscn` | create | Entry-point scene (minimal — just root Node2D + script) |
| `game/tools/playtest_runner.gd` | create | Main runner: config parsing, state injection, action execution, capture |
| `game/tools/playtest_actions.gd` | create | Action definitions and executor (static utility, no state) |
| `game/tools/playtest_capture.gd` | create | Screenshot capture + log collection + JSON report writer |
| `game/tools/CLAUDE.md` | modify | Add playtest runner documentation |

### Node Hierarchy

```
PlaytestRunner (Node2D)
  # No children — everything is done via autoloads and script logic
  # The target scene loads into the SceneTree normally via change_scene_to_file()
```

## Configuration

The runner reads a JSON config file passed via `--config=`. This defines what state to set up and what actions to perform.

### Config Schema

```json
{
  "scene": "res://scenes/roothollow/roothollow.tscn",
  "spawn_point": "spawn_from_forest",

  "state": {
    "party": ["kael", "lyra", "iris", "garrick"],
    "party_levels": {"kael": 5, "lyra": 4, "iris": 3, "garrick": 5},
    "flags": [
      "opening_lyra_discovered",
      "iris_recruited",
      "garrick_recruited"
    ],
    "inventory": {"potion": 5, "hi_potion": 2, "ether": 3},
    "gold": 1500,
    "equipment": {
      "kael": {"weapon": "steel_sword"},
      "iris": {"weapon": "precision_bow"}
    }
  },

  "actions": [
    {"type": "wait", "seconds": 1.0},
    {"type": "screenshot", "label": "initial_spawn"},
    {"type": "move", "direction": "right", "seconds": 2.0},
    {"type": "move", "direction": "up", "seconds": 1.5},
    {"type": "screenshot", "label": "after_movement"},
    {"type": "interact"},
    {"type": "wait_dialogue"},
    {"type": "screenshot", "label": "post_dialogue"},
    {"type": "trigger_battle", "enemies": ["memory_bloom", "memory_bloom"]},
    {"type": "wait", "seconds": 5.0},
    {"type": "screenshot", "label": "battle_in_progress"}
  ],

  "options": {
    "timeout_seconds": 30,
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

### Config Fields

#### Top Level

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `scene` | `String` | yes | Target scene `res://` path to load |
| `spawn_point` | `String` | no | Spawn group name (Marker2D group in target scene) |
| `state` | `Object` | no | Game state to inject before scene loads |
| `actions` | `Array` | no | Scripted input sequence to execute after scene loads |
| `options` | `Object` | no | Runner behavior configuration |

#### state

| Field | Type | Description |
|-------|------|-------------|
| `party` | `Array[String]` | Character IDs to add via `PartyManager.add_character()`. Loads from `res://data/characters/<id>.tres`. |
| `party_levels` | `Dict[String, int]` | Override character levels. Uses `LevelManager.add_xp()` to level characters up. |
| `flags` | `Array[String]` | Event flags to set via `EventFlags.set_flag()` |
| `inventory` | `Dict[String, int]` | Items to add via `InventoryManager.add_item()`. Loads from `res://data/items/<id>.tres`. |
| `gold` | `int` | Starting gold via `InventoryManager.add_gold()` |
| `equipment` | `Dict[String, Dict]` | Per-character equipment. Loads from `res://data/equipment/<id>.tres`. |
| `quests` | `Array[String]` | Quest IDs to accept via `QuestManager.accept_quest()`. Loads from `res://data/quests/<id>.tres`. |

#### actions

Each action is an object with a `type` field. Available action types:

| Type | Fields | Description |
|------|--------|-------------|
| `wait` | `seconds: float` | Wait for N seconds (process frames continue) |
| `screenshot` | `label: String` | Capture a labeled screenshot |
| `move` | `direction: String, seconds: float` | Simulate movement input (up/down/left/right) for N seconds |
| `interact` | — | Press and release the `interact` input action |
| `cancel` | — | Press and release the `cancel` input action |
| `menu` | — | Press and release the `menu` input action |
| `advance_dialogue` | — | Press `interact` to advance dialogue (alias for `interact` with dialogue context) |
| `wait_dialogue` | `timeout: float = 10.0` | Wait until `DialogueManager.is_active()` returns false |
| `select_choice` | `index: int` | Select a dialogue choice by index via `DialogueManager.select_choice()` |
| `trigger_battle` | `enemies: Array[String], can_escape: bool = true` | Force-start a battle. Loads enemies from `res://data/enemies/<id>.tres`. |
| `wait_battle` | `timeout: float = 30.0` | Wait until `BattleManager.is_in_battle()` returns false |
| `wait_state` | `state: String, timeout: float = 10.0` | Wait until `GameManager.current_state` matches the named state |
| `set_flag` | `flag: String` | Set an event flag mid-sequence |
| `log` | `message: String` | Write a message to the playtest log |

#### options

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `timeout_seconds` | `float` | `60.0` | Maximum runtime before force-exit |
| `capture_on_error` | `bool` | `true` | Auto-capture screenshot when errors are detected |
| `capture_interval_seconds` | `float` | `0` | If > 0, capture screenshots at this interval throughout |
| `disable_encounters` | `bool` | `false` | Disable random encounters during the playtest |
| `disable_bgm` | `bool` | `true` | Mute background music (reduces noise in headless runs) |
| `output_dir` | `String` | `"/tmp/playtest/"` | Directory for screenshots and report |
| `viewport_width` | `int` | `640` | Override viewport width |
| `viewport_height` | `int` | `360` | Override viewport height |

## State Injection

State injection happens after autoloads are ready but before the target scene loads. This ensures the scene's `_ready()` sees the correct game state (e.g., flag-gated dialogue, party-dependent UI).

### Injection Order

```
1. Characters → PartyManager.add_character() for each party member
2. Levels    → LevelManager.add_xp() to reach target levels
3. Equipment → EquipmentManager.equip() for each slot
4. Items     → InventoryManager.add_item() for each item
5. Gold      → InventoryManager.add_gold()
6. Flags     → EventFlags.set_flag() for each flag
7. Quests    → QuestManager.accept_quest() for each quest
8. Scene     → GameManager.change_scene(target, FADE_DURATION, spawn_point)
```

### Character Data Loading

Character `.tres` files live at `res://data/characters/<id>.tres`. The runner loads each one and calls `PartyManager.add_character()`. If a `.tres` file doesn't exist, the runner logs a warning and continues.

## Action Execution

After the scene loads and rendering settles (configurable wait), the action executor processes each action in sequence:

```gdscript
func _execute_actions(actions: Array) -> void:
    for action in actions:
        match action.type:
            "wait":
                await _wait_seconds(action.seconds)
            "screenshot":
                _capture_screenshot(action.label)
            "move":
                await _simulate_move(action.direction, action.seconds)
            "interact":
                _simulate_input_press("interact")
            # ... etc
```

### Input Simulation

Input is simulated by creating and dispatching `InputEventAction` events through `Input.parse_input_event()`:

```gdscript
func _simulate_input_press(action_name: String) -> void:
    var press := InputEventAction.new()
    press.action = action_name
    press.pressed = true
    Input.parse_input_event(press)
    await get_tree().process_frame
    var release := InputEventAction.new()
    release.action = action_name
    release.pressed = false
    Input.parse_input_event(release)
```

For movement, the press is held for the specified duration, then released:

```gdscript
func _simulate_move(direction: String, duration: float) -> void:
    var action_name := "move_%s" % direction
    var press := InputEventAction.new()
    press.action = action_name
    press.pressed = true
    Input.parse_input_event(press)
    await _wait_seconds(duration)
    var release := InputEventAction.new()
    release.action = action_name
    release.pressed = false
    Input.parse_input_event(release)
```

## Screenshot Capture

Screenshots are captured to the output directory with sequential numbering and labels:

```
/tmp/playtest/
  001_initial_spawn.png
  002_after_movement.png
  003_post_dialogue.png
  004_battle_in_progress.png
  005_error_autoshot.png        # auto-captured on error
  report.json                   # structured output
  playtest.log                  # console output
```

### Capture Implementation

```gdscript
func _capture_screenshot(label: String) -> void:
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    var filename := "%03d_%s.png" % [_capture_index, label]
    _capture_index += 1
    image.save_png(output_dir.path_join(filename))
    _report.screenshots.append({"index": _capture_index, "label": label, "file": filename})
```

## Structured Output

The runner writes a `report.json` with the full playtest results:

```json
{
  "success": true,
  "duration_seconds": 12.4,
  "scene": "res://scenes/roothollow/roothollow.tscn",
  "screenshots": [
    {"index": 1, "label": "initial_spawn", "file": "001_initial_spawn.png"},
    {"index": 2, "label": "after_movement", "file": "002_after_movement.png"}
  ],
  "errors": [],
  "warnings": ["EncounterSystem: no player found in group 'player'."],
  "actions_completed": 8,
  "actions_total": 8,
  "final_state": {
    "game_state": "OVERWORLD",
    "party_count": 3,
    "party_hp": {"kael": {"current": 45, "max": 50}, "lyra": {"current": 38, "max": 38}},
    "flags": ["opening_lyra_discovered", "iris_recruited"],
    "gold": 1500,
    "player_position": {"x": 384.0, "y": 256.0}
  }
}
```

### Error Collection

The runner hooks into Godot's error/warning output by monitoring `_process()` for logged errors. Errors are collected into the report. If `capture_on_error` is true, a screenshot is taken whenever an error is detected.

## CLI Invocation

### Direct CLI

```bash
/Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  --rendering-driver opengl3 \
  --windowed --resolution 640x360 \
  res://tools/playtest_runner.tscn \
  -- --config=/tmp/playtest_config.json
```

### Minimal CLI (Quick Screenshot)

For simple "load scene with state and capture" without a config file:

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

The runner supports both config-file mode (`--config=`) and inline-arg mode. Inline args are simpler for quick one-off checks. Config files are better for complex multi-step sequences.

### Agent Skill: `/playtest`

A new skill wrapping the CLI invocation. The skill:

1. Accepts scene path + optional state/action parameters
2. Writes a temporary config JSON to `/tmp/`
3. Invokes the Godot CLI
4. Reads the report JSON and screenshots
5. Returns the results to the agent

The skill should support common presets:

```
/playtest roothollow --preset=mid-game
/playtest battle --enemies=memory_bloom,memory_bloom --party=kael,lyra
/playtest new-game                          # starts from title screen, presses New Game
/playtest continue                          # loads save slot 0
```

### Presets

Presets are predefined state configurations stored in `game/tools/playtest_presets/`:

| Preset | Description |
|--------|-------------|
| `new_game` | Empty state, scene=overgrown_ruins, simulates New Game button |
| `early_game` | Kael only, no flags, overgrown_ruins |
| `mid_game` | Kael+Lyra+Iris, lyra_discovered+iris_recruited, roothollow, 500 gold |
| `late_game` | Full party, all flags, garrick quest complete, 2000 gold, equipment |
| `battle_test` | Mid-game state, triggers a battle immediately |
| `boss_test` | Late-game state, overgrown_ruins, triggers boss encounter |
| `dialogue_test` | Roothollow, walks to NPC, interacts, captures dialogue |
| `full_walkthrough` | Plays through the entire demo (title -> ruins -> forest -> town) |

## Use Cases

### 1. Verify Player Spawn

An agent just modified the player entity or a scene's spawn logic. Quick verification:

```json
{
  "scene": "res://scenes/overgrown_ruins/overgrown_ruins.tscn",
  "state": {"party": ["kael"]},
  "actions": [
    {"type": "wait", "seconds": 2},
    {"type": "screenshot", "label": "player_spawned"}
  ]
}
```

Produces a screenshot showing whether the player character appeared correctly with animations and collision.

### 2. Battle System Integration

An agent just changed the battle state machine. Full battle verification:

```json
{
  "scene": "res://scenes/verdant_forest/verdant_forest.tscn",
  "state": {
    "party": ["kael", "lyra", "iris"],
    "flags": ["opening_lyra_discovered", "iris_recruited"],
    "inventory": {"potion": 5}
  },
  "actions": [
    {"type": "wait", "seconds": 1},
    {"type": "screenshot", "label": "overworld_before_battle"},
    {"type": "trigger_battle", "enemies": ["memory_bloom", "creeping_vine"]},
    {"type": "wait", "seconds": 2},
    {"type": "screenshot", "label": "battle_started"},
    {"type": "wait", "seconds": 5},
    {"type": "screenshot", "label": "battle_midway"},
    {"type": "wait_battle", "timeout": 60},
    {"type": "screenshot", "label": "battle_ended"}
  ],
  "options": {"timeout_seconds": 90}
}
```

### 3. Dialogue and NPC Interaction

Test that NPC dialogue works correctly with specific flag states:

```json
{
  "scene": "res://scenes/roothollow/roothollow.tscn",
  "spawn_point": "spawn_from_forest",
  "state": {
    "party": ["kael", "lyra"],
    "flags": ["opening_lyra_discovered"]
  },
  "actions": [
    {"type": "wait", "seconds": 1},
    {"type": "move", "direction": "up", "seconds": 1.5},
    {"type": "move", "direction": "right", "seconds": 2.0},
    {"type": "interact"},
    {"type": "wait", "seconds": 0.5},
    {"type": "screenshot", "label": "dialogue_box_shown"},
    {"type": "advance_dialogue"},
    {"type": "wait", "seconds": 0.5},
    {"type": "screenshot", "label": "dialogue_line_2"},
    {"type": "wait_dialogue"}
  ]
}
```

### 4. UI Overlay Verification

Test that HUD, pause menu, and shop UI render correctly with game state:

```json
{
  "scene": "res://scenes/roothollow/roothollow.tscn",
  "state": {
    "party": ["kael", "lyra", "iris", "garrick"],
    "gold": 2000,
    "inventory": {"potion": 10, "hi_potion": 3, "ether": 5}
  },
  "actions": [
    {"type": "wait", "seconds": 1},
    {"type": "screenshot", "label": "hud_with_party"},
    {"type": "menu"},
    {"type": "wait", "seconds": 0.5},
    {"type": "screenshot", "label": "pause_menu_open"}
  ]
}
```

### 5. Scene Transition Verification

Test that zone transitions work between areas:

```json
{
  "scene": "res://scenes/overgrown_ruins/overgrown_ruins.tscn",
  "state": {
    "party": ["kael", "lyra"],
    "flags": ["opening_lyra_discovered"]
  },
  "actions": [
    {"type": "wait", "seconds": 1},
    {"type": "screenshot", "label": "ruins_start"},
    {"type": "move", "direction": "down", "seconds": 3},
    {"type": "move", "direction": "right", "seconds": 5},
    {"type": "wait", "seconds": 2},
    {"type": "screenshot", "label": "after_transition"}
  ],
  "options": {"timeout_seconds": 30}
}
```

### 6. Full Demo Walkthrough

Automated playthrough of the entire demo to catch integration bugs:

```json
{
  "scene": "res://ui/title_screen/title_screen.tscn",
  "actions": [
    {"type": "wait", "seconds": 3},
    {"type": "screenshot", "label": "title_screen"},
    {"type": "interact"},
    {"type": "wait", "seconds": 3},
    {"type": "screenshot", "label": "game_start_ruins"},
    {"type": "move", "direction": "up", "seconds": 2},
    {"type": "move", "direction": "right", "seconds": 3},
    {"type": "wait_dialogue"},
    {"type": "screenshot", "label": "lyra_discovered"},
    {"type": "log", "message": "Opening sequence complete"}
  ],
  "options": {
    "timeout_seconds": 120,
    "capture_interval_seconds": 5,
    "disable_encounters": true
  }
}
```

## Implementation Plan

### Phase 1: Core Runner (T-0111)

1. Create `playtest_runner.tscn` and `playtest_runner.gd`
2. JSON config parsing with CLI arg fallback
3. State injection (party, flags, inventory, gold)
4. Scene navigation via `GameManager.change_scene()`
5. Basic actions: `wait`, `screenshot`, `move`
6. Report JSON output
7. Timeout safety exit
8. Update `game/tools/CLAUDE.md`

### Phase 2: Full Action Set (T-0112)

1. Input simulation: `interact`, `cancel`, `menu`
2. Dialogue actions: `advance_dialogue`, `wait_dialogue`, `select_choice`
3. Battle actions: `trigger_battle`, `wait_battle`
4. State actions: `wait_state`, `set_flag`, `log`
5. Equipment injection
6. Quest injection
7. Error collection and `capture_on_error`
8. Periodic screenshot capture (`capture_interval_seconds`)

### Phase 3: Skill and Presets (T-0113)

1. Create `/playtest` skill
2. Create preset configs in `game/tools/playtest_presets/`
3. Inline CLI args support
4. Preset selection in skill
5. Update CLAUDE.md with usage documentation

### Phase 4: Battle Auto-Play (T-0114, optional)

1. AI-driven party actions during playtested battles (auto-attack)
2. Battle outcome logging (did the party win? how many turns? HP remaining?)
3. Battle balance data collection

## Differences from Scene Preview

| Aspect | Scene Preview | Playtest Runner |
|--------|--------------|-----------------|
| Autoloads | Partially loaded, no game data | Fully initialized with injected state |
| Scene loading | Added as child of preview tool | Loaded via `GameManager.change_scene()` |
| Player | Spawns but no party/state | Full party, equipment, levels, flags |
| Input | None | Simulated movement, interaction, menus |
| Screenshots | Single frame | Multiple labeled captures throughout |
| Battle | Not possible | Can trigger and observe battles |
| Dialogue | Not possible | Can trigger and advance dialogue |
| Output | Single PNG | PNG screenshots + JSON report + log |
| Duration | ~1 second | Configurable (seconds to minutes) |
| Use case | Visual verification of static layout | Full integration testing of live gameplay |

Scene Preview remains the right tool for quick tilemap and layout checks. Playtest Runner is for verifying that systems work together in context.

## Dependencies

- All 12 autoloads must be functional
- Character/enemy/item `.tres` data files must exist
- `GameManager.change_scene()` must work for scene navigation
- `Input.parse_input_event()` for input simulation (Godot built-in)
- File system access for writing screenshots and reports

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Godot hangs on scene load | Timeout safety exit (`timeout_seconds`) |
| Missing `.tres` files | Null-check all `load()` calls, log warnings, continue |
| Battle never ends (AI deadlock) | `wait_battle` has configurable timeout |
| Dialogue blocks forever | `wait_dialogue` has configurable timeout |
| Input simulation doesn't trigger actions | Test with simple move/interact first; fall back to direct method calls if `parse_input_event` is insufficient |
| Headless rendering issues | Use `--rendering-driver opengl3` (same as scene_preview); fallback to `--rendering-driver vulkan` if needed |
| Large output directory | Clean output dir at start of each run |

## Success Criteria

The playtest runner is successful when an agent can:

1. Load any game scene with realistic game state (party, flags, items)
2. See the player character spawned correctly with animations
3. Move the player around and observe the result
4. Trigger and observe a battle sequence from start to finish
5. Trigger and step through NPC dialogue
6. Detect errors that only manifest when systems interact
7. Get structured output that can be programmatically analyzed

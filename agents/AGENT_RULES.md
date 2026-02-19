# Gemini Fantasy

2D JRPG built with Godot 4.5, GDScript, mobile renderer. Licensed GPLv3.

## Git Workflow

**BEFORE starting any task**, rebase onto the latest `origin/main` to ensure you have up-to-date code and a clean history:

```bash
git fetch origin main
git rebase origin/main
```

After completing any task, **automatically commit, push, and merge** without asking:

1. Stage the changed files and commit with a clear message
2. Create a new branch if on main, or push to the current branch
3. Push to remote with `-u`
4. Create a PR via `gh pr create`
5. Merge the PR via `gh pr merge --merge`
6. Run `git pull` to sync the merge commit locally
7. **Pull main in the main repo** so Godot has the latest code immediately:
   `git -C /Users/robles/repos/games/gemini-fantasy pull`
   (Worktrees cannot checkout main — always pull from the main repo path.)

**MANDATORY:** "The issue tracker" refers to `agents/BACKLOG.md` (all tickets) and `agents/SPRINT.md` (current sprint). **DO NOT** use GitHub Issues or the `gh issue` command unless explicitly asked. Always check `agents/SPRINT.md` before starting work. New bugs go in `agents/BACKLOG.md`. Current work is tracked in `agents/SPRINT.md`.

Do not ask for confirmation at any step. This applies to all tasks — bug fixes, features, refactors, doc updates, etc.

### Agent Configuration (Single Source of Truth)

**MANDATORY:** `CLAUDE.md` is the single source of truth for all project rules, workflows, and agent instructions. `gemini.md` is a symbolic link to this file. Any change to project norms MUST be made in `agents/AGENT_RULES.md` (the real file behind both symlinks). This ensures both Claude and Gemini agents remain perfectly synchronized.

## Agent Task Workflow

Every session, before writing any code:

1. Read `agents/SPRINT.md`
2. If you have a task `Assigned: [your-name]` with `Status: in-progress`, resume it
3. Otherwise, pick the highest-priority `unassigned` task from Queue whose deps are met
4. Claim it: set `Assigned: [your-name]`, `Status: in-progress`, `Started: [date]`
5. **Research** — look up docs, read best practices, scan existing code (see below)
6. **RED** — write failing tests that define the expected behavior
7. **GREEN** — write the minimum implementation to make tests pass
8. **REFACTOR** — clean up while keeping tests green
9. Run `/run-tests` — all tests must pass before committing
10. **VERIFY VISUALLY** — if the task touched any visual content (tilemaps, UI, entity placement, scenes), run `/scene-preview` on every affected scene and fix issues before committing. See "MANDATORY: Visual Verification" below.
11. When done: move ticket to "Done This Sprint", set `Status: done`, `Completed: [date]`
12. Append one-line entry to `agents/COMPLETED.md`
13. If you discover new issues, add tickets to `agents/BACKLOG.md`
14. Pick the next task (go to step 3)

Agent names: Use `claude` or `gemini` as the assignee value.

## MANDATORY: Research Before Code

**DO NOT write or modify any GDScript, .tscn, or .tres file without first completing ALL of these steps:**

1.  **Check `agents/SPRINT.md`**: Read the current sprint. If you have an assigned task, work on it. If no task is assigned, pick the highest-priority unassigned task from Queue and claim it. If you discover new issues, add tickets to `agents/BACKLOG.md`.
2.  **Call the `godot-docs` sub-agent** for every Godot class you will use:
    - **Claude Code**: `Task(subagent_type="godot-docs", prompt="Look up [CLASS]...")`
    - **Gemini CLI**: `godot-docs(objective="Look up [CLASS]...")`
3.  **Read the relevant best practices file** from `docs/best-practices/`:
    - **Claude Code**: `Read("docs/best-practices/[file].md")`
    - **Gemini CLI**: `read_file("docs/best-practices/[file].md")`
4.  **Scan for related issues**: Use the available search tools to find existing implementations of similar logic to ensure consistency and avoid duplicating known bugs.
5.  **Write tests FIRST** (TDD): For any testable logic, write failing tests that define the expected behavior BEFORE writing the implementation. See the TDD section below for details.

This is not optional. Every code change must be grounded in documentation and the current state of the project. Do not rely on memory or assumptions — look it up, check the tracker, and write the tests first.

**Choosing what to look up:**
- Writing a new scene? → `godot-docs` subagent for root node class + `01-scene-architecture.md`
- Adding signals? → `godot-docs` subagent for the class + `02-signals-and-communication.md`
- Creating an autoload? → `03-autoloads-and-singletons.md`
- Defining a Resource? → `godot-docs` subagent for Resource class + `04-resources-and-data.md`
- Using _ready/_process? → `05-node-lifecycle.md`
- Worried about performance? → `06-performance.md`
- Building a state machine? → `07-state-machines.md`
- Creating UI? → `godot-docs` subagent for Control nodes + `08-ui-patterns.md`
- Implementing save/load? → `09-save-load.md`
- Building battle/overworld? → `10-jrpg-patterns.md`
- Adding art/audio assets? → Read the "Asset Workflow" section above + `04-resources-and-data.md`
- Building tilemaps? → `11-tilemaps-and-level-design.md` + `tilemap-builder` agent

## MANDATORY: Test-Driven Development (TDD)

**This project follows strict TDD. Tests come FIRST, implementation comes SECOND.**

### The TDD Cycle: Red-Green-Refactor

For every piece of testable logic (functions, data classes, state machines, autoloads, resources):

1. **RED — Write failing tests first.** Before writing any implementation code, create tests that define the expected behavior. These tests MUST fail initially (because the code doesn't exist yet) or MUST define the new behavior you're about to add. This forces you to think about the API, edge cases, and contracts before writing a single line of production code.

2. **GREEN — Write the minimum code to pass.** Implement only what is needed to make the failing tests pass. Do not add extra features, optimizations, or "nice to haves" at this stage. If a behavior isn't tested, don't build it yet.

3. **REFACTOR — Clean up while tests stay green.** Once tests pass, improve the code (remove duplication, rename for clarity, extract helpers) while running tests after each change to ensure nothing breaks.

4. **REPEAT** for the next behavior or requirement.

### When TDD Applies

**Always write tests first for:**
- New autoload scripts (pure logic, roster management, flag tracking)
- Custom Resource classes and their methods
- Battle system logic (damage formulas, status effects, resonance, turn order)
- State machines and state transitions
- Inventory, quest, save/load logic
- Any pure function or method with deterministic inputs/outputs
- Bug fixes — write a test that reproduces the bug BEFORE fixing it

**TDD is optional (but tests are still required after) for:**
- Scene tree wiring (`.tscn` files) — hard to unit test, use `/playtest-check` instead
- UI layout and visual polish — validated visually
- Asset loading and integration — depends on Godot import cache
- Signal connection plumbing between scenes — use `/integration-check`

Even when TDD doesn't apply, you must still run `/run-tests` before pushing and ensure existing tests stay green.

### Test Conventions

**Test file naming:** `test_<module_name>.gd` in the matching subdirectory under `game/tests/unit/`.

**Test pattern:** Each test file `extends GutTest`. Create fresh instances in `before_each()` via `load("res://path.gd").new()` + `add_child_autofree()` — never test against global autoload singletons.

**Test structure for a new feature:**
```
# 1. Create the test file FIRST
game/tests/unit/<subsystem>/test_<module>.gd

# 2. Write tests that define expected behavior
#    (these will fail — the code doesn't exist yet)

# 3. Create/modify the implementation file
game/<subsystem>/<module>.gd

# 4. Run tests — iterate until green
/run-tests

# 5. Refactor if needed, re-run tests
```

**Test helpers:** Use `game/tests/helpers/test_helpers.gd` for shared factories (`make_battler()`, `make_ability()`, `make_item()`). Add new factories there as needed.

### Running Tests

```bash
# Static analysis
/Users/robles/Library/Python/3.10/bin/gdlint game/

# Unit tests (headless)
/Applications/Godot.app/Contents/MacOS/Godot --headless \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  -d -s res://addons/gut/gut_cmdln.gd \
  -gdir=res://tests/ -ginclude_subdirs -gexit -glog=2
```

Or use `/run-tests` which runs both in sequence and reports results.

### Rules

1. **DO NOT push code without all tests passing** (exit code 0)
2. **DO NOT write implementation before tests** for testable logic
3. **Bug fixes MUST include a regression test** — prove the bug exists first, then fix it
4. **Refactors MUST NOT break existing tests** — if tests fail, the refactor is wrong
5. **New testable code without tests will not be merged** — tests are not optional

## Project Structure

```
game/              # Godot project (scenes, scripts, assets)
docs/              # All documentation
  godot-docs/      # Official Godot 4.5 documentation (git submodule)
  game-design/     # Game design documents (mechanics, enemies, world, quests, dungeons, audio)
  lore/            # Story, characters, world lore, echo catalog
  mechanics/       # Character abilities and system mechanics
  best-practices/  # Godot best practices summaries (quick reference)
agents/            # Project management (milestones, backlog, sprint, completed tasks)
.claude/           # Claude Code configuration (agents, skills)
.gemini/           # Gemini CLI configuration (agents, skills)
  settings.json    # Hooks and tool permissions
```

## Available Art Assets (Time Fantasy)

**ALWAYS search the asset packs before generating or creating placeholder art.** Professional Time Fantasy sprite packs are available at `../assets/` (relative to repo root).

### Asset Pack Index

| Pack | Path | Contains |
|------|------|----------|
| tf_fairyforest | `tf_fairyforest_12.28.20/1x/` | Forest tiles, mushroom village, stone ruins, dryad/fairy characters |
| tf_ruindungeons | `tf_ruindungeons/16/` | 3 ruin dungeon themes (ancient, overgrown, cave) |
| tf_giant-tree | `tf_giant-tree/RPGMAKER-100/` | Giant tree exterior + interior tilesets |
| tf_farmandfort | `tf_farmandfort/` | Medieval farm/fort tiles, 335 RPG icons |
| tf_steampunk_complete | `tf_steampunk_complete/` | Steampunk city, train, sewer tilesets |
| tf_final_tower | `tf_final_tower_12.24.22/` | Dark tower/villain lair dungeon |
| npc-animations | `npc-animations/rpgmaker/1/` | Animated NPCs: townsfolk, blacksmith, elder, farmer, etc. |
| tf_svbattle | `tf_svbattle/` | Side-view battle sprites (10 heroes x 8 colors) |
| tf_mythicalbosses | `tf_mythicalbosses/100/` | Boss/enemy sprites: chimera, dragon, hydra, etc. |
| icons_8.13.20 | `icons_8.13.20/fullcolor/` | 1023 RPG icons at 16/24/32px |
| pixel_animations_gfxpack | `pixel_animations_gfxpack/` | Battle VFX: fire, ice, lightning, heal, etc. |
| tf_animals | `tf_animals/sheets/` | Animal walk sprites (dogs, cats, horses, birds) |
| beast_tribes | `beast_tribes/100/` | Fantasy beast-race characters |
| tf_dwarfvelf | `tf_dwarfvelf_v1.2/regularsize/` | 16 dwarves + 16 elves |
| quirky_npcs | `quirky_npcs/fullcolor/` | 28 unique NPCs |
| tf-faces | `tf-faces-6.11.20/transparent/1x/` | Character face portraits for dialogue |
| TimeFantasy_Winter | `TimeFantasy_Winter/tiles/` | Winter/snow themed tileset |

### Asset Format Notes

- **Use 1x/16x16 base size** for Godot — look for folders named `1x`, `100`, `16`, `regularsize`, or `RPGMAKER-100`
- All assets use **RGBA transparency**
- **Character walk sprites**: 3 columns x 4 rows (down, left, right, up) — single character is 78x144px at 1x
- **TileA5 sheets** (128x256): Simple flat grids of 16x16 tiles — easiest for TileSet atlas import
- **TileB sheets** (256x256): Object tiles, can contain multi-tile objects
- Full asset index with detailed descriptions: `/Users/robles/repos/games/assets/CLAUDE.md`
### Tile Usage Rules

- **Only use A5 and B tile sheets.** A5 sheets (128x256) contain flat 16x16 terrain grids. B sheets (256x256) contain 16x16 object tiles. These are the only tile formats available in the project.
- **Use single-tile fills for ground layers.** Each column in an A5 tile sheet is a DIFFERENT tile variant — columns 0 and 1 are NOT left/right halves of a pair. Alternating columns creates visible checkerboard/stripe artifacts. Use ONE consistent tile (same `Vector2i(col, row)`) for the entire ground fill.
- **Use B-sheet objects for visual variety.** Trees, rocks, buildings, and decorative objects from B-format sheets provide all the visual interest. Do not try to create variety by mixing A5 columns.
- **Use large patches for terrain changes.** If you need different terrain types (grass + dirt), use tiles from different A5 ROWS in 8x8+ contiguous patches, never from different columns of the same row.
- **Pass `source_id` for B-sheet layers.** When calling `MapBuilder.build_layer()` for layers using B-sheet tiles, pass the correct source_id parameter (e.g., `1` if the B sheet is the second atlas path).
- **Match theme to location.** Ruins1 = blue/ancient, Ruins2 = gold/Egyptian, Ruins3 = brown/green overgrown. Fairy Forest A5_A row 8 = bright green (use for forests). Row 0 = dark green grass. Row 10 = gray stone (use for towns).
- **Read `docs/best-practices/11-tilemaps-and-level-design.md`** before any tilemap work. It contains the verified tile sheet reference, the single-tile fill rule, collision setup, and the theme-to-tileset mapping table.
- **Build complete multi-tile objects.** B-sheets contain multi-tile sprites — houses, fences, bridges, wells, signs. Use ALL tiles that form the object, not just one piece. A house needs walls, roof, door, and windows assembled from adjacent B-sheet tiles. Study the tile sheet to identify which tiles form a complete object before placing any of them.
- **Roads and paths need edge variation.** Paths should use distinct tiles for left edge, center, right edge, and corners. Do not fill an entire path with one tile — the center and borders should differ. Check the B-sheet or A5 rows for path edge/center tile variants.
- **Never repeat the same decorative object in a grid pattern.** Trees, rocks, flowers, and other decorative objects must be placed organically — vary spacing, mix different object types, leave irregular gaps. A row of identical trees evenly spaced looks artificial. Cluster 2-3 trees, leave a gap, place a rock, then another tree group.
- **Mix object variants.** If the B-sheet has multiple tree types (e.g., different canopy shapes, sizes), use several variants in the same area. Same for rocks, bushes, flowers. Repetition of a single asset is the biggest visual quality killer.
- **Create depth with layering.** Use the AbovePlayer layer for tree canopies, rooftop overhangs, and archways that the player walks behind. Use GroundDetail for small ground accents (pebbles, grass tufts, fallen leaves). Every scene should have at least 4 layers: Ground, Objects, AbovePlayer, and one detail layer.

## Asset Workflow

**PNGs and audio files are gitignored** (`game/assets/**/*.png`, `*.wav`, `*.ogg`, `*.mp3`). They must be managed manually outside of git. Follow this workflow whenever adding or using assets.

### Rules

1. **Never generate placeholder art** — always search the Time Fantasy packs first (see table above)
2. **Source assets live outside the project** at `/Users/robles/repos/games/assets/`
3. **Copy assets into `game/assets/`** under the appropriate subdirectory (see structure below)
4. **Assets must exist in the main repo**, not just the worktree — Godot runs from the main repo
5. **Godot must import new assets** — after adding PNGs, reopen the Godot editor so it generates `.import` files
6. **Always null-check `load()` results** for any resource that depends on local asset files

### Asset Directory Structure

```
game/assets/
  tilesets/          # Tile sheets (TileA5, TileB format PNGs)
  sprites/
    characters/      # Player + NPC walk sprites
    buildings/       # Building/structure sprites
    enemies/         # Enemy sprites (battle + overworld)
    effects/         # Battle VFX sprites
  portraits/         # Face portraits for dialogue
  icons/             # UI and item icons
  audio/
    bgm/             # Background music
    sfx/             # Sound effects
```

### Copying Assets

When you need an asset:

1. **Find it** in the Time Fantasy packs at `/Users/robles/repos/games/assets/`
2. **Copy to the main repo**: `cp <source> /Users/robles/repos/games/gemini-fantasy/game/assets/<subdir>/`
3. **Copy to the worktree** (if working in one): `cp <source> /Users/robles/repos/games/gemini-fantasy/.worktrees/<branch>/game/assets/<subdir>/`
4. **Verify Godot can load it** — the user must reopen the Godot editor to trigger import

Or use the `/copy-assets` skill which automates steps 2-3.

### Common Pitfall: `load()` Returns Null

`load()` returns `null` when a PNG exists on disk but Godot hasn't imported it yet (no `.import` file). **Always** guard against this:

```gdscript
var tex: Texture2D = load(path) as Texture2D
if tex == null:
    push_error("Failed to load '%s' — reopen Godot editor to import" % path)
    return
```

## MANDATORY: Visual Verification

**Every change to visual content MUST be verified with `/scene-preview` before committing.** This is not optional. Agents cannot see what they build — the screenshot is the only way to catch visual bugs, repetitive patterns, and broken layouts.

### What Triggers Visual Verification

Run `/scene-preview` on every affected scene after ANY of these changes:
- Tilemap creation or modification (`/build-tilemap`, legend changes, map arrays)
- Entity placement or repositioning (NPCs, enemies, transitions, markers)
- UI screen creation or layout changes (menus, HUD, dialogue)
- Scene composition changes (adding/removing nodes, z-index changes)
- Asset swaps (changing tile sheets, sprites, textures)

### The Edit-Preview-Iterate Loop

This is the required workflow for all visual work:

1. **Make changes** to the scene/script
2. **Run `/scene-preview`** on the affected scene (use `--full-map` for tilemaps)
3. **Inspect the screenshot** — check every item on the Visual Quality Checklist below
4. **Fix issues** found in the screenshot
5. **Run `/scene-preview` again** to confirm fixes
6. **Repeat** until the scene passes all checklist items
7. Only THEN proceed to `/run-tests` and committing

### Visual Quality Checklist

When reviewing a screenshot, check for ALL of these:

**Anti-repetition:**
- [ ] No grid patterns — decorative objects (trees, rocks, flowers) are spaced irregularly
- [ ] Multiple object variants used — not the same tree/rock sprite repeated everywhere
- [ ] Clusters and gaps — objects grouped in natural-looking clusters with empty space between
- [ ] No visible tiling artifacts — ground textures don't show obvious seams or checkerboard patterns

**Complete objects:**
- [ ] Multi-tile structures are fully assembled — houses have walls + roof + door + windows
- [ ] Fences, bridges, and paths have proper start/middle/end tiles
- [ ] Roads use edge tiles on the sides and center tiles in the middle, not one tile for everything
- [ ] No orphaned partial objects (half a house, one fence post floating alone)

**Depth and layering:**
- [ ] AbovePlayer layer exists for canopies, rooftops, and archways
- [ ] Ground detail layer adds small accents (pebbles, grass tufts, moss)
- [ ] At least 4 active layers visible in the scene
- [ ] Z-ordering looks correct (player would walk behind trees, under roofs)

**Composition:**
- [ ] Clear paths/walkways for player navigation
- [ ] Visual landmarks or focal points (a large tree, a building, a statue)
- [ ] Terrain transitions look natural (grass-to-dirt uses soft borders, not hard grid lines)
- [ ] Map edges are bounded (dense trees, walls, water — not abrupt tile cutoff)

**Consistency:**
- [ ] Art style is cohesive — all assets are from the same Time Fantasy pack/theme
- [ ] Scale is consistent — objects are proportional to each other and the player
- [ ] Color palette matches the location theme (forest = greens, ruins = stone grays, town = warm earth tones)

### Camera Modes

| Mode | Flags | Use When |
|------|-------|----------|
| Default | (none) | Scene has its own Camera2D (e.g., player camera) |
| Full-map | `--full-map` | View entire tilemap — **use this first for any tilemap work** |
| Positioned | `--camera-x=N --camera-y=N` | Zoom into a specific area for detail check |
| Custom zoom | `--zoom=N` | Override auto-zoom (0.5 = zoom out 2x) |

### Usage Examples

```
# Always start with full-map to see the whole picture
/scene-preview res://scenes/verdant_forest/verdant_forest.tscn --full-map

# Then zoom into areas that need detail inspection
/scene-preview res://scenes/roothollow/roothollow.tscn --camera-x=384 --camera-y=304 --zoom=1.5

# Check UI with HUD visible
/scene-preview res://scenes/roothollow/roothollow.tscn --show-ui
```

### Manual Invocation

```bash
/Applications/Godot.app/Contents/MacOS/Godot \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  --rendering-driver opengl3 \
  res://tools/scene_preview.tscn \
  -- --preview-scene=res://scenes/<name>/<name>.tscn \
     --output=/tmp/scene_preview.png --full-map
```

## Adding Monsters

Reproducible workflow for adding new enemy types to the game.

### Steps

1. **Find a sprite** in the Time Fantasy packs at `/Users/robles/repos/games/assets/`
   - Walk sheets (78x144 or 156x212): 3 columns x 4 rows, front-facing idle = row 0, center column
   - Boss sprites may be single-frame or larger sheets
2. **Copy sprite to both repos**:
   ```bash
   cp <source> /Users/robles/repos/games/gemini-fantasy/game/assets/sprites/enemies/<name>.png
   cp <source> /Users/robles/repos/games/gemini-fantasy/.worktrees/<branch>/game/assets/sprites/enemies/<name>.png
   ```
3. **Create a `.tres` file** at `game/data/enemies/<id>.tres` using this template:
   ```
   [gd_resource type="Resource" script_class="EnemyData" load_steps=2 format=3 uid="uid://b<id>"]
   [ext_resource type="Script" path="res://resources/enemy_data.gd" id="1_script"]
   [resource]
   script = ExtResource("1_script")
   id = &"<id>"
   display_name = "<Name>"
   description = "<lore description>"
   max_hp = <int>
   attack = <int>
   magic = <int>
   defense = <int>
   resistance = <int>
   speed = <int>
   exp_reward = <int>
   gold_reward = <int>
   abilities = []
   weaknesses = [<Element enum ints>]
   resistances = [<Element enum ints>]
   ai_type = <AiType enum int>
   sprite_path = "res://assets/sprites/enemies/<name>.png"
   sprite_columns = 3
   sprite_rows = 4
   battle_scale = <float: 2.5 for 78x144, 1.5 for 156x212>
   loot_table = [{"item_id": "<id>", "drop_chance": <float>}]
   ```
4. **Add to encounter pool** in the area's scene script (e.g., `verdant_forest.gd`):
   - Add `const <NAME>_PATH` at top
   - Load in `_ready()` with null check
   - Append weighted `EncounterPoolEntry` entries
5. **Reopen Godot editor** to trigger `.import` generation for new PNGs
6. **Test**: walk in the area until an encounter triggers, verify sprite displays correctly

### Sprite Sheet Reference

| Size | Columns | Rows | Frame Size | battle_scale | Source |
|------|---------|------|------------|-------------|--------|
| 78x144 | 3 | 4 | 26x36 | 2.5 | Small monsters (ghost, mummy) |
| 156x212 | 3 | 4 | 52x53 | 1.5 | Medium monsters (harpy, cerberus, hydra) |
| varies | 1 | 1 | full image | 1.0 | Boss/single-frame sprites |

### Element Enum Values

`NONE=0, FIRE=1, ICE=2, WATER=3, WIND=4, EARTH=5, LIGHT=6, DARK=7`

### AiType Enum Values

`BASIC=0, AGGRESSIVE=1, DEFENSIVE=2, SUPPORT=3, BOSS=4`

## Agentic Development Workflow

This project is designed for fully automated agentic development. Use the skill system to orchestrate work.

### Skill Categories

**Orchestration** — Start here for large tasks:
- `/game-director <goal>` — Breaks down goals into ordered skill invocations
- `/sprint-planner <phase>` — Plans a development sprint from the implementation guide

**Creation** — Build game content:
- `/new-system <name>` — Scaffold a game system (combat, inventory, dialogue, etc.)
- `/new-scene <type> <name>` — Create scene with script and node hierarchy
- `/new-ui <type> <name>` — Create UI screen with focus navigation
- `/new-resource <name>` — Create custom Resource class
- `/build-level <name> <type>` — Create level with layers, transitions, encounters
- `/add-animation <scene> <type>` — Add animations (sprite, player, tree, tween)
- `/add-audio <type>` — Add BGM, SFX, or audio system
- `/setup-input <actions>` — Configure input actions and handlers
- `/implement-feature <desc>` — End-to-end feature implementation
- `/copy-assets <description>` — Copy assets from Time Fantasy packs into the project
- `/build-tilemap <scene> [goals]` — Design and build multi-layer tilemaps with visual variety
- `/scene-preview <scene> [flags]` — Capture a screenshot of a scene for visual verification

**Data** — Populate and tune game data:
- `/seed-game-data <type>` — Create .tres files from design docs
- `/balance-tuning <area>` — Analyze and adjust game balance

**Quality** — Validate and fix:
- `/run-tests` — Run gdlint + GUT unit tests (mandatory before pushing)
- `/gdscript-review [path]` — Code style and best practices review
- `/scene-audit [path]` — Scene architecture audit
- `/playtest-check` — Pre-playtest validation scan
- `/integration-check [system]` — Cross-system wiring verification
- `/debug-issue <error>` — Diagnose and fix bugs

**Reference** (auto-loaded, not user-invoked):
- `gdscript-conventions` — Loaded automatically when writing GDScript

### Specialized Agents

Six custom agents in `.claude/agents/` handle specialized tasks. **Use these instead of general-purpose agents** — they have domain-specific knowledge and produce structured output.

| Agent | Invocation | Purpose |
|-------|-----------|---------|
| `godot-docs` | `Task(subagent_type="godot-docs")` | Godot API lookup, tutorial search, best practices (haiku model) |
| `gdscript-reviewer` | `Task(subagent_type="gdscript-reviewer")` | Code quality, style guide, best practices review (sonnet model) |
| `scene-auditor` | `Task(subagent_type="scene-auditor")` | Scene architecture, dependencies, signal health audit (sonnet model) |
| `playtest-checker` | `Task(subagent_type="playtest-checker")` | Pre-playtest validation, broken refs, missing resources (sonnet model) |
| `integration-checker` | `Task(subagent_type="integration-checker")` | Cross-system wiring, autoloads, signal connections (sonnet model) |
| `debugger` | `Task(subagent_type="debugger")` | Bug diagnosis and fix with mandatory doc lookup (inherits model) |
| `tilemap-builder` | `Task(subagent_type="tilemap-builder")` | Tilemap design — multi-layer maps with Time Fantasy assets (opus model) |

```
# Look up Godot docs (fast, lightweight)
Task(subagent_type="godot-docs", prompt="Look up CharacterBody2D — I need velocity, move_and_slide(), movement tutorials.")

# Review code quality
Task(subagent_type="gdscript-reviewer", prompt="Review game/systems/combat/")

# Audit architecture
Task(subagent_type="scene-auditor", prompt="Audit the game/scenes/ directory for composition issues.")

# Pre-playtest validation
Task(subagent_type="playtest-checker", prompt="Run full pre-playtest check on the project.")

# Check system integration
Task(subagent_type="integration-checker", prompt="Check integration for the combat system.")

# Debug an issue
Task(subagent_type="debugger", prompt="Fix: 'Invalid get index on null instance' in battle_manager.gd line 42")

# Design/redesign a tilemap
Task(subagent_type="tilemap-builder", prompt="Redesign the Verdant Forest tilemap — add B-sheet trees, more ground variety, organic clearings, and an AbovePlayer canopy layer.")
```

### Agent Team Patterns

When building large features, use parallel agents:

```
# Research in parallel while planning
Task(subagent_type="godot-docs", prompt="Look up [CLASS] API and related tutorials...")
Task(subagent_type="Explore", prompt="Read design doc at docs/game-design/...")

# Quality checks in parallel after implementation
Task(subagent_type="gdscript-reviewer", prompt="Review game/systems/combat/...")
Task(subagent_type="integration-checker", prompt="Check integration of combat + UI...")

# Full quality sweep (run all review agents in parallel)
Task(subagent_type="gdscript-reviewer", prompt="Review all .gd files")
Task(subagent_type="scene-auditor", prompt="Audit all scenes")
Task(subagent_type="playtest-checker", prompt="Run pre-playtest check")
Task(subagent_type="integration-checker", prompt="Check all system integration")
```

### Development Order

When building from scratch, follow this order:
1. Core systems (state machine, scene transitions, input)
2. Data layer (Resource classes, game data .tres files)
3. Game systems (combat, inventory, dialogue, quest, save/load)
4. Scenes (player, enemies, NPCs, levels)
5. UI (HUD, menus, dialogue box, battle UI)
6. Audio and animation
7. Integration and polish

## Best Practices Reference

Quick-reference summaries are in `docs/best-practices/`. Consult BEFORE implementing:

| File | Topic |
|------|-------|
| `01-scene-architecture.md` | Loose coupling, dependency injection, composition |
| `02-signals-and-communication.md` | Signal patterns, when to use signals vs direct calls |
| `03-autoloads-and-singletons.md` | When to autoload, alternatives, global state risks |
| `04-resources-and-data.md` | Custom Resources, .tres files, loading patterns |
| `05-node-lifecycle.md` | _init/_ready/_process order, caching, property timing |
| `06-performance.md` | Data structures, hot paths, memory, scene vs script |
| `07-state-machines.md` | Node-based and enum patterns, JRPG state machines |
| `08-ui-patterns.md` | Container layout, menu pattern, dialogue, focus nav |
| `09-save-load.md` | Save architecture, saveable interface, file formats |
| `10-jrpg-patterns.md` | Battle system, turn queue, overworld, encounters |
| `11-tilemaps-and-level-design.md` | Multi-layer tilemaps, tile sheets, MapBuilder, level design |

## Godot Documentation Search Protocol

The full Godot docs are available at `docs/godot-docs/`. Use this 3-tier lookup system when writing or modifying GDScript code.

**NOTE: If `docs/godot-docs/` is empty or missing, you MUST reinitialize the submodule before proceeding:**
```bash
git submodule update --init --recursive docs/godot-docs
```

### Tier 1 -- Class Reference (API lookup)

Read the class file directly when you need properties, methods, or signals:

```
docs/godot-docs/classes/class_<classname_lowercase>.rst
```

Examples:
- `CharacterBody2D` -> `class_characterbody2d.rst`
- `AnimatedSprite2D` -> `class_animatedsprite2d.rst`
- `@GDScript` built-ins -> `class_@gdscript.rst`
- `@GlobalScope` -> `class_@globalscope.rst`

For large files (1000+ lines): read the Description section first (lines 1-100), then Grep within the file for specific methods/properties.

### Tier 2 -- Tutorial Search (how-to questions)

Grep within the relevant tutorial subdirectory. All paths relative to `docs/godot-docs/`:

| Directory | Covers |
|-----------|--------|
| `tutorials/2d/` | 2D rendering, tilemaps, sprites, movement, particles, parallax |
| `tutorials/scripting/gdscript/` | GDScript language, exports, typing, style guide |
| `tutorials/scripting/` | Signals, scenes, resources, autoloads, groups, scene tree |
| `tutorials/physics/` | CharacterBody2D, collision shapes, raycasting, Area2D |
| `tutorials/animation/` | AnimationPlayer, AnimationTree, cutout animation, 2D skeletons |
| `tutorials/ui/` | Control nodes, themes, containers, fonts, GUI navigation |
| `tutorials/inputs/` | InputEvent, input examples, controllers, mouse coordinates |
| `tutorials/navigation/` | Navigation2D, pathfinding, navigation agents/regions |
| `tutorials/audio/` | Audio buses, effects, streams, sync |
| `tutorials/io/` | Saving games, data paths, background loading |
| `tutorials/rendering/` | Viewports, multiple resolutions, renderers |
| `tutorials/best_practices/` | Scene organization, architecture, node alternatives |
| `getting_started/step_by_step/` | Nodes, scenes, signals, first script |
| `getting_started/first_2d_game/` | Complete 2D game tutorial (Dodge the Creeps) |

### Tier 3 -- Broad Search (fallback)

Grep across the entire `docs/godot-docs/` directory with `glob: "*.rst"`.

## When to Look Up Docs

**These are hard requirements, not suggestions. Violating them produces incorrect code.**

- **BEFORE writing ANY code**: Call the `godot-docs` subagent for every Godot class you will use. No exceptions.
- **BEFORE writing ANY code**: Read the relevant `docs/best-practices/*.md` file. No exceptions.
- **BEFORE implementing a system**: Read the relevant design doc from `docs/game-design/` or `docs/lore/`.
- **SKIP** lookup only for basic GDScript syntax (variables, loops, functions, conditionals) — NOT for Godot API calls.
- For complex questions spanning multiple docs, call the `godot-docs` subagent with a detailed prompt.

## Documentation Lookup

Use the `godot-docs` subagent for ALL Godot documentation lookups:

```
Task(subagent_type="godot-docs", prompt=
  "Look up [TOPIC]. I need [specific information needed].
   Include code examples and best practice notes if available.")
```

This subagent searches `docs/godot-docs/` (1071 class refs + tutorials) and `docs/best-practices/` (10 summary guides). It returns structured summaries, preserving your context window.

For non-Godot research (design docs, lore, existing code), use Explore:

```
Task(subagent_type="Explore", prompt=
  "Read docs/game-design/01-core-mechanics.md and extract the Resonance combat system details.")
```

## JRPG Core Classes

Classes most relevant to this project -- look these up first:

**Scene nodes**: Node2D, Sprite2D, AnimatedSprite2D, Camera2D, TileMapLayer, TileSet, Area2D, CharacterBody2D, CollisionShape2D, RayCast2D

**UI nodes**: Control, Label, RichTextLabel, TextureRect, NinePatchRect, Button, Panel, MarginContainer, VBoxContainer, HBoxContainer, GridContainer, ScrollContainer

**Systems**: AnimationPlayer, AnimationTree, AudioStreamPlayer, AudioStreamPlayer2D, Timer, Tween, SceneTree, PackedScene, Resource

**Input**: Input, InputEvent, InputMap

**Data**: @GDScript, @GlobalScope

## GDScript Code Style

Based on the official Godot style guide (`docs/godot-docs/tutorials/scripting/gdscript/gdscript_styleguide.rst`).

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| File names | snake_case | `yaml_parser.gd` |
| Class names | PascalCase | `class_name YAMLParser` |
| Node names | PascalCase | `Camera3D`, `Player` |
| Functions | snake_case | `func load_level():` |
| Variables | snake_case | `var particle_effect` |
| Signals | snake_case (past tense) | `signal door_opened` |
| Constants | CONSTANT_CASE | `const MAX_SPEED = 200` |
| Enum names | PascalCase (singular) | `enum Element` |
| Enum members | CONSTANT_CASE | `EARTH, WATER, AIR, FIRE` |

### Code Order in Scripts

```
01. @tool, @icon, @static_unload
02. class_name
03. extends
04. ## doc comment
05. signals
06. enums
07. constants
08. static variables
09. @export variables
10. remaining regular variables
11. @onready variables
12. _init() -> _ready() -> _process() -> _physics_process() -> other virtual methods
13. public methods
14. private methods (prefixed with _)
15. inner classes
```

### Key Rules

- Use **tabs** for indentation (Godot default)
- Use **static typing**: `var health: int = 0`, `func heal(amount: int) -> void:`
- Use `:=` for type inference when type is obvious: `var direction := Vector3(1, 2, 3)`
- Use explicit types when ambiguous: `var health: int = 0` (not `var health := 0`)
- Use `@export` for inspector-exposed variables
- Use `@onready` for node references: `@onready var health_bar: ProgressBar = get_node("UI/LifeBar")`
- Prefer `and`/`or`/`not` over `&&`/`||`/`!`
- Use **double quotes** for strings (single quotes only to avoid escapes)
- Use **trailing commas** in multiline arrays, dicts, enums
- Two blank lines between functions
- Lines under 100 characters (prefer 80)
- Prefer signals over direct method calls for decoupled communication
- One script per scene node (composition over inheritance)

## Game Design Reference

Design documents in `docs/` define all game mechanics, story, and content:

| Document | Contains |
|----------|----------|
| `docs/game-design/01-core-mechanics.md` | Combat (Resonance system), progression, economy |
| `docs/game-design/02-enemy-design.md` | Enemy types, AI patterns, boss mechanics |
| `docs/game-design/03-world-map-and-locations.md` | 5 regions, settlements, world layout |
| `docs/game-design/04-side-quests.md` | 60+ side quests, faction questlines |
| `docs/game-design/05-dungeon-designs.md` | 8 story + 6 optional dungeons |
| `docs/game-design/06-audio-design.md` | Music, SFX, adaptive audio |
| `docs/lore/01-world-overview.md` | World history, factions, The Severance |
| `docs/lore/02-main-story.md` | 3-act story, 4 endings |
| `docs/lore/03-characters.md` | 8 party members, NPCs, antagonists |
| `docs/lore/04-echo-catalog.md` | Echo Fragment system, collectibles |
| `docs/lore/05-cultural-details.md` | Regional cultures, languages, customs |
| `docs/mechanics/character-abilities.md` | Skill trees, abilities per character |
| `docs/IMPLEMENTATION_GUIDE.md` | Development roadmap, 6 phases, priorities |

**ALWAYS** consult design docs before inventing mechanics or story content.

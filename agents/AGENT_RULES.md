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
10. **VERIFY VISUALLY** — if the task touched any visual content (tilemaps, UI, entity placement, scenes), run `/scene-preview` on every affected scene and fix issues before committing
11. When done: move ticket to "Done This Sprint", set `Status: done`, `Completed: [date]`
12. Append one-line entry to `agents/COMPLETED.md`
13. If you discover new issues, add tickets to `agents/BACKLOG.md`
14. Pick the next task (go to step 3)

Agent names: Use `claude` or `gemini` as the assignee value.

## MANDATORY: Research Before Code

**DO NOT write or modify any GDScript, .tscn, or .tres file without first completing ALL of these steps:**

1. **Check `agents/SPRINT.md`** — claim or resume a task
2. **Call the `godot-docs` sub-agent** for every Godot class you will use
3. **Read the relevant best practices file** from `docs/best-practices/`
4. **Scan for related issues** — search existing code for similar logic
5. **Write tests FIRST** (TDD) — see `game/tests/CLAUDE.md`

**Choosing what to look up:**

| Task | Look Up |
|------|---------|
| New scene | `godot-docs` for root node + `01-scene-architecture.md` |
| Signals | `godot-docs` for the class + `02-signals-and-communication.md` |
| Autoload | `03-autoloads-and-singletons.md` |
| Resource class | `godot-docs` for Resource + `04-resources-and-data.md` |
| Node lifecycle | `05-node-lifecycle.md` |
| Performance | `06-performance.md` |
| State machine | `07-state-machines.md` |
| UI | `godot-docs` for Control nodes + `08-ui-patterns.md` |
| Save/load | `09-save-load.md` |
| Battle/overworld | `10-jrpg-patterns.md` |
| Assets | `game/assets/CLAUDE.md` + `04-resources-and-data.md` |
| Tilemaps | `11-tilemaps-and-level-design.md` + `tilemap-builder` agent |

## MANDATORY: Test-Driven Development (TDD)

**Tests come FIRST, implementation comes SECOND.** Full details in `game/tests/CLAUDE.md`.

1. **RED** — Write failing tests that define expected behavior before writing any implementation
2. **GREEN** — Write minimum code to make tests pass
3. **REFACTOR** — Clean up while tests stay green

**Always write tests first for:** autoloads, Resource classes, battle logic, state machines, inventory/quest/save logic, pure functions, bug fixes.

**TDD optional (but tests still required after):** scene wiring, UI layout, asset loading, signal plumbing.

**Running tests:** Use `/run-tests` (runs gdlint + GUT). All tests must pass before committing.

## Project Structure

```
game/              # Godot project — each subdirectory has its own CLAUDE.md
  autoloads/       # Global singletons (GameManager, PartyManager, etc.)
  data/            # .tres resource instances (enemies, items, abilities)
  entities/        # Reusable scene prefabs (player, NPC, interactable, battle)
  events/          # Story event scripts (cutscenes, recruitments)
  resources/       # Custom Resource class definitions (.gd)
  scenes/          # Overworld area scenes (ruins, forest, town)
  systems/         # Core systems (battle, encounter, state machine, MapBuilder)
  tests/           # GUT unit tests
  tools/           # Dev tools (scene_preview)
  ui/              # UI screens (battle, dialogue, HUD, pause, title)
  assets/          # Art + audio (gitignored PNGs/audio, see game/assets/CLAUDE.md)
docs/              # All documentation
  godot-docs/      # Official Godot 4.5 docs (git submodule)
  game-design/     # Mechanics, enemies, world, quests, dungeons, audio
  lore/            # Story, characters, world lore, echo catalog
  story/           # Implementation-ready scene scripts (acts 1-3, character quests)
  mechanics/       # Character abilities and system mechanics
  best-practices/  # Godot best practices (11 topic files)
agents/            # Sprint tracking (BACKLOG.md, SPRINT.md, COMPLETED.md)
assets/            # Asset index and sprite catalog (CLAUDE.md)
```

**Each `game/` subdirectory has its own `CLAUDE.md`** with file indexes, APIs, conventions, and usage patterns. Read the relevant subdirectory CLAUDE.md before modifying files in that directory.

## Art Assets

**ALWAYS search the Time Fantasy packs before generating placeholder art.** Packs are at `/Users/robles/repos/games/assets/`. Full pack index: `assets/CLAUDE.md`.

For asset copy workflow, gitignore rules, `load()` null-check patterns, and tile sheet reference: see `game/assets/CLAUDE.md`.

When importing tilesets, **copy ALL tile sheets from the pack** (not just the one you need). Use `/copy-assets` to automate.

## Tilemap Design

Read `docs/best-practices/11-tilemaps-and-level-design.md` before any tilemap work. Scene-specific tilemap details are in `game/scenes/CLAUDE.md`. Detailed visual-first workflow is in `.claude/agents/tilemap-builder.md`.

**Key rules:** View tile sheet PNGs before using coordinates. Search for pixel art reference images. Build one layer at a time with `/scene-preview` after each. Never parallelize tilemap work across agents. Place decorations sparingly and intentionally (no percentage-based spam).

## Visual Verification

**Every change to visual content MUST be verified with `/scene-preview` before committing.** Details in `game/tools/CLAUDE.md`.

Required workflow: make changes -> `/scene-preview` (use `--full-map` for tilemaps) -> Read screenshot -> evaluate -> fix issues -> repeat until clean -> `/run-tests` -> commit.

**Triggers:** tilemap changes, entity placement, UI layout, scene composition, asset swaps.

**Checklist:** anti-repetition (no grid patterns, mixed variants, organic clusters), complete multi-tile objects, depth/layering (4+ layers, AbovePlayer), clear navigation, visual landmarks, bounded edges, cohesive art style.

## Adding Monsters

See `game/data/CLAUDE.md` for the .tres template and `game/resources/CLAUDE.md` for the EnemyData schema. Workflow:

1. Find sprite in Time Fantasy packs
2. Copy to both main repo and worktree (`/copy-assets`)
3. Create `.tres` at `game/data/enemies/<id>.tres`
4. Add to encounter pool in area scene script
5. Reopen Godot editor for import
6. Test in-game

## Agentic Development Workflow

### Skills

| Category | Skills |
|----------|--------|
| **Orchestration** | `/game-director`, `/sprint-planner` |
| **Creation** | `/new-system`, `/new-scene`, `/new-ui`, `/new-resource`, `/build-level`, `/add-animation`, `/add-audio`, `/setup-input`, `/implement-feature`, `/copy-assets`, `/build-tilemap`, `/scene-preview` |
| **Data** | `/seed-game-data`, `/balance-tuning` |
| **Quality** | `/run-tests`, `/gdscript-review`, `/scene-audit`, `/playtest-check`, `/integration-check`, `/debug-issue` |
| **Auto-loaded** | `gdscript-conventions` (loaded when writing GDScript) |

### Specialized Agents

**Use these instead of general-purpose agents** — they have domain-specific knowledge.

| Agent | Invocation | Purpose |
|-------|-----------|---------|
| `godot-docs` | `Task(subagent_type="godot-docs")` | Godot API lookup (haiku) |
| `gdscript-reviewer` | `Task(subagent_type="gdscript-reviewer")` | Code quality review (sonnet) |
| `scene-auditor` | `Task(subagent_type="scene-auditor")` | Scene architecture audit (sonnet) |
| `playtest-checker` | `Task(subagent_type="playtest-checker")` | Pre-playtest validation (sonnet) |
| `integration-checker` | `Task(subagent_type="integration-checker")` | Cross-system wiring check (sonnet) |
| `debugger` | `Task(subagent_type="debugger")` | Bug diagnosis and fix |
| `tilemap-builder` | `Task(subagent_type="tilemap-builder")` | Tilemap design (opus) |

Use parallel agents for large features (e.g., `godot-docs` + `Explore` for research, then `gdscript-reviewer` + `integration-checker` for quality).

### Development Order

1. Core systems (state machine, scene transitions, input)
2. Data layer (Resource classes, .tres files)
3. Game systems (combat, inventory, dialogue, quest, save/load)
4. Scenes (player, enemies, NPCs, levels)
5. UI (HUD, menus, dialogue box, battle UI)
6. Audio and animation
7. Integration and polish

## Best Practices Reference

Consult `docs/best-practices/` BEFORE implementing:

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

## Godot Documentation

Full docs at `docs/godot-docs/` (git submodule — run `git submodule update --init --recursive docs/godot-docs` if empty).

Use the `godot-docs` subagent for all lookups. For manual search:

- **Tier 1 — Class API:** `docs/godot-docs/classes/class_<lowercase>.rst`
- **Tier 2 — Tutorials:** Grep in `tutorials/2d/`, `tutorials/scripting/`, `tutorials/physics/`, `tutorials/ui/`, `tutorials/animation/`, `tutorials/inputs/`, `tutorials/io/`, `tutorials/audio/`, `tutorials/navigation/`, `tutorials/rendering/`, `tutorials/best_practices/`
- **Tier 3 — Broad search:** Grep `docs/godot-docs/` with `glob: "*.rst"`

**BEFORE writing ANY code:** call `godot-docs` for every Godot class you will use, AND read the relevant `docs/best-practices/*.md` file. No exceptions.

## GDScript Code Style

The `gdscript-conventions` skill is auto-loaded when writing GDScript. Key rules:

- **Tabs** for indentation, **static typing** everywhere, **double quotes** for strings
- Prefer `and`/`or`/`not` over `&&`/`||`/`!`
- Two blank lines between functions, lines under 100 chars
- Trailing commas in multiline arrays/dicts/enums
- Signals over direct method calls for decoupled communication

**Naming:** files=`snake_case`, classes=`PascalCase`, functions/vars=`snake_case`, signals=`snake_case` (past tense), constants=`CONSTANT_CASE`, enums=`PascalCase`/`CONSTANT_CASE`

**Script order:** annotations -> class_name -> extends -> doc comment -> signals -> enums -> constants -> static vars -> @export -> vars -> @onready -> virtual methods -> public methods -> private methods -> inner classes

## Game Design Reference

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

Story scripts in `docs/story/` (acts 1-3, character quests, camp scenes, NPC dialogue). **Always reference the corresponding chapter when implementing dialogue.**

**ALWAYS** consult design docs before inventing mechanics or story content.

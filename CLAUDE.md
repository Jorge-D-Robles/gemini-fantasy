# Gemini Fantasy

2D JRPG built with Godot 4.5, GDScript, mobile renderer. Licensed GPLv3.

## Git Workflow

After completing any task, **automatically commit, push, and merge** without asking:

1. Stage the changed files and commit with a clear message
2. Create a new branch if on main, or push to the current branch
3. Push to remote with `-u`
4. Create a PR via `gh pr create`
5. Merge the PR via `gh pr merge --merge`
6. Switch back to main and pull

Do not ask for confirmation at any step. This applies to all tasks — bug fixes, features, refactors, doc updates, etc.

## MANDATORY: Research Before Code

**DO NOT write or modify any GDScript, .tscn, or .tres file without first completing BOTH of these steps:**

1. **Call the `godot-docs` subagent** for every Godot class you will use:
   ```
   Task(subagent_type="godot-docs", prompt="Look up [CLASS]. I need [properties/methods/signals].")
   ```
2. **Read the relevant best practices file** from `docs/best-practices/`:
   ```
   Read("docs/best-practices/[relevant-file].md")
   ```

This is not optional. Every code change must be grounded in documentation. Do not rely on memory or assumptions about the Godot API — look it up. If you are unsure which best practices file applies, read the topic mapping table in the "Best Practices Reference" section below.

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

## Project Structure

```
game/              # Godot project (scenes, scripts, assets)
docs/              # All documentation
  godot-docs/      # Official Godot 4.5 documentation (git submodule)
  game-design/     # Game design documents (mechanics, enemies, world, quests, dungeons, audio)
  lore/            # Story, characters, world lore, echo catalog
  mechanics/       # Character abilities and system mechanics
  best-practices/  # Godot best practices summaries (quick reference)
.claude/           # Claude Code configuration
  agents/          # 6 specialized agents (docs, review, audit, debug, validation)
  skills/          # 20 development skills (creation, data, quality, planning)
  settings.json    # Hooks and tool permissions
```

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

**Data** — Populate and tune game data:
- `/seed-game-data <type>` — Create .tres files from design docs
- `/balance-tuning <area>` — Analyze and adjust game balance

**Quality** — Validate and fix:
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

## Godot Documentation Search Protocol

The full Godot docs are available at `docs/godot-docs/`. Use this 3-tier lookup system when writing or modifying GDScript code.

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

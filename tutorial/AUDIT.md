# Crystal Saga Tutorial Series Audit

Date: 2026-04-28

Scope: the 27 numbered Markdown modules in `tutorial/`.

Audience assumption: an experienced software engineer learning Godot and the
JRPG-specific shape of a complete game project. The audit treats the tutorial as
a curriculum, not just a collection of recipes.

## Evidence Model

- `docs/best-practices/*` was deliberately ignored. The user identified those
  files as hallucinated, so this audit does not rely on them.
- Godot/API claims are checked against Godot RAG results from official Godot
  documentation, especially for `TileMapLayer`, scene changes, resources,
  pausing, input, save/load, audio buses, and tweens.
- `PLAN.md`, `CLAUDE.md`, and `REGRESSION.md` were used only as local continuity
  material, not as factual authority.
- JRPG claims are grounded in the tutorial text plus genre references:
  [Final Fantasy VI manual HTML](https://www.skyrender.net/ff6man.html),
  [Final Fantasy VI manual PDF](https://www.retrogames.cz/manualy/SNES/Final_Fantasy_VI_%28EN%29_-_SNES_-_Manual.pdf),
  [Chrono Trigger techs](https://chronotrigger.wiki.gg/wiki/Techs),
  and broadly established JRPG conventions: party growth, towns, dungeons,
  turn-based commands, shops, inns, save points, equipment, quests, encounters,
  bosses, and endings.

## Executive Summary

Overall curriculum health: strong, with a few concrete correctness and
continuity fixes needed before treating the series as polished.

The 27-module series has a coherent spiral: project setup -> scripting basics ->
tilemaps/movement -> interaction/dialogue/inventory -> battle -> quests/party/save
-> audio/title/game flow/final review. The best modules repeatedly connect a new
Godot concept to a JRPG job: resources become item/enemy/party data, autoloads
become cross-scene managers, state machines become battle flow, and scene changes
become dungeon/battle/title transitions.

The highest-value aspect for a Google software engineer is that the tutorial
does not stop at editor clicks. It introduces ownership boundaries, singleton
tradeoffs, runtime state versus source data, state machines, save schema versioning,
and full-game flow. That is the right level of abstraction for an experienced
engineer learning Godot.

Top risks:

1. Module 22 contains a misleading GDScript claim about `await` in static
   functions and a primary JSON load snippet that should validate the parsed
   type before assigning to `Dictionary`.
2. Module 27's final-review architecture summary diverges from the battle and
   scene structures actually built earlier.
3. Module 15 and Module 27 treat `AbilityData` inconsistently: Module 15 leaves
   abilities as a placeholder while its complete action script still touches
   `ability.power`/`ability.mp_cost`, and Module 27 lists `AbilityData` as an
   implemented resource.
4. Module 05 recommends editor scattering for sparse decoration, which conflicts
   with the project's "intentional and sparse" tilemap rule and can teach a bad
   habit even though Godot itself supports the editor feature.
5. Module 26 is a content module but lacks the same recap/handoff anatomy used
   elsewhere.
6. Review modules and a few snippets have style drift: double-dash punctuation,
   diagram-only shorthand, and occasional summaries that are less precise than
   the modules they review.

## Findings

| Severity | Location | Issue | Evidence | Recommended fix |
|---|---|---|---|---|
| High | `22_save_and_load.md:156-158` | Misleading claim: "Static functions in GDScript cannot use await (they have no node context)." | Godot RAG for GDScript says `await` is a language feature for waiting on signals/coroutines. Static functions lack instance member access and `self`, but the docs do not support a blanket "static cannot await" rule. | Rewrite the rationale: `SaveManager` should be an autoload because it owns persistent runtime save state, can coordinate scene changes from a stable node, and can access other autoloads. Do not claim `await` is forbidden in static functions. |
| High | `22_save_and_load.md:235-242` | Primary load snippet assigns `json.data` directly to a typed `Dictionary` before proving the JSON root is a dictionary. | Godot RAG for `JSON` says `JSON.data` is a `Variant`; valid JSON can be an array, number, string, boolean, or null. The module later discusses validation at `22_save_and_load.md:386-402`, but the main code path should be safe first. | Store `json.data` in a `Variant`, check `parsed is Dictionary`, then assign `var save_data: Dictionary = parsed`. Keep the later validation section as explanation. |
| High | `27_part_vi_review.md:520-534` | Final review summarizes a battle architecture that does not match the system introduced in Modules 14 and 19. | Module 14 builds `Battle (Node2D)` with a `StateMachine` and states such as `Intro`, `TurnStart`, `PlayerChoice`, `ActionExecute`, `CheckResult`, `Victory`, and `Defeat` (`14_battle_foundations.md:162-181`, `14_battle_foundations.md:663-680`). Module 19 repeats that architecture (`19_part_iv_review.md:197-225`). Module 27 instead lists `BattleManager (Node)`, states such as `SetupState`, `PlayerTurnState`, `EnemyTurnState`, and `FleeState`, and a `_change_state()` API that does not match the taught `transition_to()` state machine. | Replace the Module 27 battle summary with the actual node/state names and explicitly note that enemy/player behavior is coordinated through the state machine and battle scene root script. |
| High | `15_player_actions.md:462-516` | A block labeled as the complete `action_execute_state.gd` still contains unresolved `AbilityData` placeholder logic. | The module says magic is disabled until `AbilityData` exists (`15_player_actions.md:228`), but the complete file calls `_execute_magic()` and reads `ability.power` and `ability.mp_cost` from a parameter typed as `Resource` (`15_player_actions.md:508-516`). That is a copy/paste trap for a full-file listing. | Either remove the magic branch from the complete file until `AbilityData` is implemented, or implement `AbilityData` before Module 15 and type the parameter as `AbilityData`. If kept as design sketch, label it pseudocode instead of "complete". |
| High | `27_part_vi_review.md:508-515` | Final review lists `AbilityData` as a Module 15 implemented resource, but the series never implements it. | Module 15 says magic is disabled until `AbilityData` exists (`15_player_actions.md:228`), leaves `_execute_magic()` as future work (`15_player_actions.md:355-359`), and warns that magic requires `AbilityData` (`15_player_actions.md:510`). Module 27 presents `AbilityData` as completed in Module 15. | Remove `AbilityData` from the implemented-resource table, move it to future extensions, or add a real ability-data module before the final review. |
| Medium | `27_part_vi_review.md:536-550` | Scene structure summary is too simplified and contradicts the multi-layer TileMapLayer structure taught earlier. | Modules 5, 6, and 16 teach separate ground/detail/object/above-player layers. Module 16's dungeon tree uses multiple `TileMapLayer` nodes and a `YSortGroup` (`16_crystal_cavern.md:53-75`). Module 27 summarizes areas as a single `TileMapLayer`. | Update the final review to show the layered map pattern used throughout: `Ground`, `Detail`, `Objects`/`YSortGroup`, and `AbovePlayer` where needed. |
| Medium | `05_tilemaps_and_terrain.md:155-181`, `05_tilemaps_and_terrain.md:197-224` | Scattering is presented as a recommended sparse-decoration workflow. | The module correctly explains Godot editor painting features, but the project rule bans percentage/noise-driven decoration and requires intentional sparse placement. The current text says scattering at `0.3-0.5` can produce sparse decoration. | Keep Godot's feature explanation if desired, but change the curriculum recommendation to hand-place a few intentional clusters. If scattering is mentioned, label it as a temporary rough-in tool that must be hand-edited. |
| Medium | `26_finish_line.md:1-20`, `26_finish_line.md:280-310` | Module 26 does not follow the content-module anatomy used by the rest of the series. | It has "What We Have", "What You Should See", and "What You've Accomplished", but lacks a distinct "What We've Learned" recap and "Next Module" handoff into Module 27. | Add a short recap of game-flow concepts learned and a handoff to `27_part_vi_review.md`. |
| Medium | `07_scene_transitions.md:118`, `26_finish_line.md:296` | Stale continuity text points to the wrong module/count. | Module 7 says pause behavior will be used in Module 12, but pause menu behavior arrives in Module 25. Module 26 says "Twenty-one modules later" even though it is the 26th module. | Update future references and counts during the remediation pass so the curriculum's self-map remains trustworthy. |
| Medium | `02_gdscript_for_programmers.md` overall | Audience fit: too much generic programming explanation for the stated audience. | The module is useful for GDScript syntax, but an experienced software engineer does not need extended explanations of variables, conditionals, or loops. | Compress generic CS material into a GDScript syntax delta and spend more space on Godot-specific semantics: node ownership, typed exports, lifecycle timing, signals, and editor/runtime boundaries. |
| Low | `04_part_i_review.md:247-248`, `08_part_ii_review.md:88-91`, `13_part_iii_review.md:130-132`, `13_part_iii_review.md:194-197`, `18_victory_and_leveling.md:170`, `18_victory_and_leveling.md:237`, `18_victory_and_leveling.md:283-290`, `19_part_iv_review.md:232`, `21_party_and_equipment.md:452`, `23_part_v_review.md:525-576`, `25_title_screen_and_game_flow.md:303` | Style drift: double-dash or triple-dash punctuation appears in prose tables, diagrams, and debug strings. | These are not engine errors, and many are diagram/comment artifacts, but they are visible drift from the tutorial's polished style. | Replace with arrows, colons, "none", or clearer labels. Ignore Markdown table separators. |
| Low | Review modules `04`, `08`, `13`, `19`, `23`, `27` | Review modules use centralized official-docs sections rather than the per-concept "See" callouts used in content modules. | This is probably intentional, but automated quality checks could falsely flag them as missing doc grounding. | Either explicitly exempt review modules from per-section callout requirements or add a short "Doc grounding recap" table in each review module. |
| Low | Several code fences across the series | Code listings are not always labeled as full-file, patch fragment, or pseudocode. | The tutorial mixes full scripts, partial snippets, and diagrams. This is normal pedagogically, but compile-risk can be overstated if a reader copies fragments as complete files. | Add a small label before non-full-file snippets: "Patch this method", "Excerpt", or "Pseudocode". |

## Curriculum Flow Analysis

| Part | Modules | Flow health | Notes |
|---|---:|---|---|
| Part I: Foundations | 01-04 | Good | Establishes project/editor basics, GDScript, player scene, input, collision, camera, and a review checkpoint. Module 02 should be tightened for experienced engineers. |
| Part II: World and Movement | 05-08 | Good with one tilemap issue | Tilemaps, animated player movement, Y-sorting, scene transitions, and autoload-managed fades build naturally. Module 05 should revise scattering advice. |
| Part III: Interaction and Data | 09-13 | Strong | Resources -> NPC interaction -> dialogue -> inventory is a clean dependency chain. Module 13 review is useful but has diagram style drift. |
| Part IV: Battle Loop | 14-19 | Strong | Battle foundations, player commands, dungeon design, enemies/AI, victory/leveling, and review form the strongest architectural arc in the series. State machine rationale is particularly appropriate for the audience. |
| Part V: Progression Systems | 20-23 | Good with one correctness issue | Quest flags, party/equipment, save/load, and review are the right next layer. Module 22 needs the static/await and JSON-root fixes. |
| Part VI: Full Game Flow | 24-27 | Good but review mismatch | Audio, title screen, pause, endings, final polish, and capstone review are appropriate. Module 26 needs a handoff, and Module 27 must match the actual earlier architecture. |

## Module Coverage Map

| Module | Prerequisites | New concepts | Reused concepts | Checkpoint/handoff |
|---|---|---|---|---|
| 01 Project Setup | None | Godot project structure, 2D setup, first scene | None | Establishes runnable empty project and editor vocabulary for Module 02. |
| 02 GDScript for Programmers | Module 01 | GDScript syntax, typed variables, functions, scripts | Project/editor orientation | Should hand off as a GDScript delta for engineers rather than a full intro to programming. |
| 03 Thinking in Scenes | Modules 01-02 | Scene composition, `CharacterBody2D`, collision, camera | Scripts and scene tree | Provides the first reusable player scene and the core Godot composition model. |
| 04 Part I Review | 01-03 | Review and consolidation | Project, scripts, player scene | Good checkpoint, but style cleanup needed in input table. |
| 05 Tilemaps and Terrain | 01-04 | `TileMapLayer`, TileSet atlas, map layers, terrain painting | Scene organization | Good Godot topic. Revise scattering recommendation before downstream map-building habits form. |
| 06 Bringing the Player to Life | 03, 05 | `AnimatedSprite2D`, `SpriteFrames`, player state machine, Y-sort | Player scene, tilemap | Turns movement into a JRPG-feeling avatar and prepares depth sorting. |
| 07 Connecting Worlds | 05-06 | Scene transitions, `SceneManager` autoload, fade UI, spawn points | Player movement, scenes, autoloads | Connects locations into an explorable world. |
| 08 Part II Review | 05-07 | Review and consolidation | Tilemaps, animated player, scene transitions | Good checkpoint; diagram punctuation/style cleanup only. |
| 09 Resources and Data | 02-03 | Custom `Resource`, `.tres`, data-driven design | Typed GDScript | Excellent setup for JRPG data tables. |
| 10 NPCs and Interaction | 03, 07, 09 | Interact input, NPC scene, `Area2D` proximity, NPC data | Collision, signals, resources | Clean bridge from map traversal to social/story systems. |
| 11 Dialogue System | 10 | Dialogue UI, typewriter text, pages, choices, `DialogueLine` resources | NPC interaction, UI, signals | Strong JRPG fit; supports story delivery without overbuilding. |
| 12 Inventory System | 09-11 | `InventoryManager` autoload, item tracking, inventory UI, consumable use | Resources, UI, autoloads | Genre framing is strong: inventory as persistent RPG resource management. |
| 13 Part III Review | 09-12 | Review and consolidation | Resources, NPCs, dialogue, inventory | Good part review; mark snippets/diagrams more clearly. |
| 14 Battle Foundations | 09-12 | Battle scene, state machine, turn queue, battle transition | Resources, signals, UI | One of the best modules. The state-machine explanation is suited to experienced engineers. |
| 15 Player Actions | 12, 14 | Battle commands, target selection, damage formula, action commands; magic remains a placeholder | Inventory, battle state machine, UI | Turns automatic battle into player-controlled JRPG combat, but should not be summarized as a completed ability system. |
| 16 Crystal Cavern | 05-07, 14-15 | Dungeon scene, transitions, save point, encounter zones | Tilemaps, battle transition, NPC/dialogue | Strong JRPG dungeon framing: attrition, save point, boss lead-in. |
| 17 Enemies and AI | 14-16 | Enemy resources, AI personalities, encounter groups, boss setup | Battle states, dungeon zones, resources | Properly extends data-driven design into combat content and encounter pacing. |
| 18 Victory and Leveling | 14-17 | Rewards, XP, level-ups, victory/defeat states | Battle state machine, resources | Strong genre fit. Debug strings/style should be polished. |
| 19 Part IV Review | 14-18 | Review and consolidation | Battle loop, dungeons, rewards | Good conceptual review; diagrams should match exact architecture and style. |
| 20 Quest Flags | 11-12, 16 | Flags, quest state, conditional dialogue | Dialogue, NPCs, autoload-style managers | Correctly introduces persistent world state before party/save systems. |
| 21 Party and Equipment | 09-10, 18, 20 | Party member data, equipment, derived stats | Resources, inventory, leveling | Strong JRPG convention coverage. Minor display/style cleanup. |
| 22 Save and Load | 20-21 | Save slots, JSON, `FileAccess`, scene restore | Quest flags, party, inventory, scene changes | Structurally right module, but needs two correctness fixes in primary code/explanation. |
| 23 Part V Review | 20-22 | Review and consolidation | Quest, party, equipment, save/load | Useful checkpoint; comment separators and snippet labels need polish. |
| 24 Audio and Polish | 01-23 | Audio players, buses, volume, transitions | Scene/autoload structure | Good late-stage polish topic and good use of Godot audio model. |
| 25 Title Screen and Game Flow | 22-24 | Title flow, new/load game, pause menu, game over/endings | Save/load, scene changes, resources, pause | Strong capstone module. Correctly revisits resource cache and pause process modes. |
| 26 Finish Line | 01-25 | Final integration/polish checklist | All prior systems | Needs standard recap and handoff to Module 27. |
| 27 Part VI Review | 24-26 | Final review and architecture recap | Full series | Valuable endpoint, but must fix mismatched battle and scene summaries. |

## Anatomy Check

The series mostly follows a durable lesson shape:

- Prior state: "What We Have So Far" on content modules after Module 01.
- Deliverable: "What We're Building This Module" on most content modules.
- Concept motivation: a short explanation of why the concept exists in Godot or
  JRPGs before code.
- Godot grounding: inline "See" callouts for API/tutorial docs.
- Expected result: "What You Should See" near the end.
- Continuity: "What We've Learned" and "Next Module" handoff.

Exceptions:

- Module 01 correctly omits prior state because it starts the series.
- Review modules 04, 08, 13, 19, 23, and 27 intentionally use a cheat-sheet
  format and central "Official Godot Documentation" sections rather than the
  normal content-module anatomy.
- Module 26 is the only content module that breaks the established pattern in a
  way that affects curriculum flow: it has expected-result and accomplishment
  sections, but lacks a standard recap and handoff to Module 27.

Quality note: for automated checks, treat review modules as a separate template.
Otherwise they will appear to fail per-section doc-grounding checks even though
they are designed as consolidation modules.

## Godot Correctness

### GDScript `await`, Static Functions, and Autoload Rationale

Godot RAG evidence:

- `sources/godot-docs/tutorials/scripting/gdscript/gdscript_basics.rst`:
  `await` creates coroutines that wait for a signal or another coroutine before
  resuming.
- `sources/godot-docs/tutorials/scripting/gdscript/gdscript_basics.rst`: static
  functions have no access to instance member variables or `self`, and do have
  access to static variables.
- `sources/godot-docs/tutorials/scripting/singletons_autoload.rst`: autoloads
  can store information needed by more than one scene and can implement custom
  scene switching.

Assessment:

- Module 22 is right to choose an autoload for save/load coordination.
- The stated reason is wrong: the docs support `await` as a coroutine mechanism
  and define static-function limits in terms of instance access, not a blanket
  inability to await.
- The curriculum should teach the actual architectural reason: save/load needs a
  stable runtime owner for slot metadata, autoload state collection, scene
  switching, and restore orchestration.

### TileMapLayer, TileSet, Collision, and Y-Sort

Godot RAG evidence:

- `sources/godot-docs/classes/class_tilemap.rst`: `TileMap` is deprecated; use
  multiple `TileMapLayer` nodes instead.
- `sources/godot-docs/classes/class_tilemaplayer.rst`: `TileMapLayer` exposes
  tile-layer properties including collision behavior and `y_sort_origin`.
- `sources/godot-docs/classes/class_tileset.rst`: `TileSet` is the tile library
  used by `TileMapLayer`; atlas sources can carry physics/navigation metadata.
- `sources/godot-docs/tutorials/2d/using_tilemaps.rst`: multiple
  `TileMapLayer` nodes are appropriate for foreground/background separation and
  overlapping tiles.

Assessment:

- The series correctly uses `TileMapLayer` rather than deprecated `TileMap`.
- The multi-layer map approach in Modules 5, 6, and 16 is doc-aligned.
- Y-sort usage is broadly correct when framed as part of top-down overlap and
  foreground/background layering.
- The only major tilemap curriculum issue is not an API issue: Module 05's
  scattering advice should be replaced with intentional placement guidance.

### Scene Changes and Battle/Return Flow

Godot RAG evidence:

- `sources/godot-docs/classes/class_scenetree.rst` documents
  `SceneTree.change_scene_to_file(path)` and shows awaiting `scene_changed`
  before using `current_scene`.
- `sources/godot-docs/tutorials/scripting/scene_tree.rst` frames
  `change_scene_to_file` and `change_scene_to_packed` as quick scene-switching
  APIs.
- `sources/godot-docs/tutorials/scripting/singletons_autoload.rst` shows that an
  autoload scene switcher is useful when scene transitions need custom behavior.

Assessment:

- Module 14's scene-change flow is correct: call `change_scene_to_file`, await
  `scene_changed`, then initialize the new battle scene.
- Module 22's restore flow similarly uses `scene_changed` in the right place.
- The curriculum should emphasize that `current_scene` is only safe after the
  change signal, which it mostly does.
- Module 27's final review should mirror this actual scene-change architecture.

### Resources, ResourceLoader, Cache Behavior, and Runtime State

Godot RAG evidence:

- `sources/godot-docs/classes/class_resourceloader.rst`: `ResourceLoader.load`
  caches loaded resources for later access.
- `sources/godot-docs/engine_details/architecture/object_class.rst`: loading the
  same resource path again can return the same in-memory reference.
- `sources/godot-docs/classes/class_resource.rst`: `Resource.duplicate()` is
  shallow by default; deep duplication is needed for nested mutable structures.
- `sources/godot-docs/classes/class_resourceformatloader.rst`: `CACHE_MODE_IGNORE`
  does not retrieve the requested resource or its subresources from cache and
  does not store them there.

Assessment:

- The tutorial correctly identifies source data versus runtime state as a
  recurring Godot issue.
- Module 25's use of `ResourceLoader.CACHE_MODE_IGNORE` when starting a fresh
  game is well-grounded and important.
- The series should consistently warn that loaded `.tres` resources are shared
  mutable objects unless duplicated or loaded while bypassing cache where
  appropriate.

### Pause, Process Modes, and Input

Godot RAG evidence:

- `sources/godot-docs/classes/class_scenetree.rst`: `SceneTree.paused` stops
  physics/collision processing, while node callbacks depend on process mode.
- `sources/godot-docs/classes/class_node.rst`: `Node.process_mode` controls
  whether a node processes while paused; `_unhandled_input(event)` receives
  events not consumed by input or GUI controls.
- `sources/godot-docs/classes/class_viewport.rst`: `Viewport.set_input_as_handled`
  stops further propagation.
- `sources/godot-docs/classes/class_input.rst`: the `Input` singleton reports
  global input state and is not affected by consumed input events.

Assessment:

- Module 25's pause menu architecture is solid: the menu sets
  `process_mode = Node.PROCESS_MODE_ALWAYS`, checks whether the current scene can
  pause, and controls pause state centrally.
- The tutorial should keep distinguishing event handling (`_unhandled_input`) from
  global polling (`Input.is_action_just_pressed`) because this matters in menus.

### FileAccess, JSON, `user://`, and Save Slots

Godot RAG evidence:

- `sources/godot-docs/tutorials/io/saving_games.rst`: save files commonly live in
  `user://`, and JSON has limited data types; custom types need conversion.
- `sources/godot-docs/classes/class_json.rst`: `JSON.parse()` returns an error
  code; parsed data is available as `JSON.data`, a `Variant`.
- `sources/godot-docs/classes/class_fileaccess.rst`: file operations expose
  errors through `get_error()`.

Assessment:

- Module 22 chooses a correct high-level shape: `user://` save files, JSON,
  metadata, schema versioning, and restore semantics.
- The primary load snippet should validate the parsed root type before assigning
  it to `Dictionary`.
- The module should make custom-type conversion explicit whenever Vector2,
  resource references, or enum-like values cross the JSON boundary.

### AudioStreamPlayer, AudioServer, Buses, and Volume

Godot RAG evidence:

- `sources/godot-docs/classes/class_audiostreamplayer.rst`: `AudioStreamPlayer`
  routes playback to the named bus, falling back to Master if missing.
- `sources/godot-docs/classes/class_audioserver.rst`: `AudioServer` exposes
  `get_bus_index()` and `set_bus_volume_db()` for bus control.
- `sources/godot-docs/tutorials/audio/audio_buses.rst`: buses are routing channels
  and the leftmost bus is Master.
- `sources/godot-docs/classes/class_@globalscope.rst`: `linear_to_db()` is the
  intended conversion for sliders that express linear energy/volume.

Assessment:

- Module 24's audio bus and volume guidance is correct.
- Module 27's reminder to use `linear_to_db()` is worth keeping.
- If the tutorial uses an audio autoload, it should be explicit about which scene
  changes reset local `AudioStreamPlayer` nodes and which music/SFX should persist.

### Tweens

Godot RAG evidence:

- `sources/godot-docs/classes/class_node.rst`: `Node.create_tween()` creates a
  tween bound to that node.
- `sources/godot-docs/classes/class_scenetree.rst`: `SceneTree.create_tween()`
  creates an unbound tween; use node-bound tweens when lifetime should follow a
  node.

Assessment:

- Any UI or transition snippets should prefer `Node.create_tween()` when the tween
  should be killed with the node. This is especially relevant for battle UI,
  victory/defeat panels, and title-screen transitions.

## JRPG Consistency

The series supports core JRPG expectations well:

- Town/world interaction appears through NPCs, dialogue, and flags.
- Dungeon play appears through the Crystal Cavern, encounter zones, save point,
  resource pressure, and boss lead-in.
- Turn-based combat appears through battle commands, turn queue, enemy AI,
  victory, defeat, XP, and rewards.
- Party progression appears through party members, equipment, derived stats,
  leveling, and save/load.
- Full game framing appears through title screen, new/load game, pause, game over,
  endings, and final review.

The tutorial's structure aligns with examples from SNES-era JRPG manuals and
reference material. The Final Fantasy VI manual foregrounds commands, items,
magic, equipment, shops/inns, save points, character growth, and combat outcomes
as core player systems. Chrono Trigger's tech references reinforce party ability
composition through single, double, and triple techniques. The series covers the
shared expectations in a sensible order without needing to clone either game.

JRPG improvements:

- The equipment module should make derived-stat recomputation and previewing
  explicit, since RPG equipment UX is largely about before/after comparison.
- The dungeon module should continue emphasizing designed encounters and resource
  attrition rather than random decoration or arbitrary enemy placement.
- The final review should connect the implemented systems to a "vertical slice"
  checklist: start game, enter town/field, talk to NPC, accept/update quest, enter
  dungeon, fight, gain rewards, save/load, return to title, and reach an ending.

## Audience Fit for an Experienced Software Engineer

Strong fits:

- The Resource/autoload/state-machine/save-schema topics are well chosen.
- The tutorial often explains why a system boundary exists, not just how to type
  code.
- The battle modules provide a good software-architecture spine for the project.

Needs tightening:

- Generic programming explanations should be compressed, especially in Module 02.
  Assume the reader understands variables, conditionals, arrays, dictionaries, and
  functions. Spend the saved space on Godot-specific behavior.
- Use more precise labels for snippets. Engineers will copy code; they need to
  know whether a block is a complete file, a replacement method, an excerpt, or
  pseudocode.
- Where an architectural choice is made, state the tradeoff: autoload versus
  scene-local node, resource source data versus runtime instance, scene change
  versus overlay, state stack versus explicit state machine.

## Prioritized Remediation Plan

### Quick Fixes

1. Fix Module 22's static/await explanation at `22_save_and_load.md:156-158`.
2. Fix Module 22's JSON root validation in the primary load snippet at
   `22_save_and_load.md:235-242`.
3. Fix Module 15's complete `action_execute_state.gd` listing so magic is either
   implemented with a real `AbilityData` type or omitted until a later module.
4. Remove or relocate Module 27's unsupported `AbilityData` row at
   `27_part_vi_review.md:508-515`.
5. Correct Module 27's battle architecture table at `27_part_vi_review.md:520-534`.
6. Correct Module 27's scene structure table at `27_part_vi_review.md:536-550`.
7. Add "What We've Learned" and "Next Module" sections to Module 26.
8. Sweep visible double-dash/triple-dash style drift in review modules and debug
   labels, ignoring Markdown table separators.

### Structural Fixes

1. Rewrite Module 02 as "GDScript for experienced programmers": syntax delta,
   typed exports, node references, lifecycle, and signal/event semantics.
2. Add snippet labels throughout the series: full file, patch, excerpt, or
   pseudocode.
3. Add a dependency graph or "you now have" checklist at the start of each part.
4. Make review modules mirror exact implemented names and file/node structures.
5. Add a final vertical-slice checklist in Module 27 that maps every system to a
   player-visible JRPG behavior.

### Optional Polish

1. Add a lightweight audit script that checks every numbered module for required
   anatomy headings.
2. Add a style scan for unsupported promises, stale class names, and known wrong
   API names.
3. Add one "engine gotcha" box per module for the Godot-specific behavior most
   likely to surprise an experienced generalist engineer.
4. Add a glossary of recurring project terms: source data, runtime state, scene
   owner, autoload, signal, state, save schema, and vertical slice.

## Acceptance Check

- All 27 numbered modules are covered in the module coverage map.
- High-severity findings include file/line references and concrete fixes.
- Godot/API criticisms are backed by Godot RAG evidence from official docs.
- JRPG claims are tied to tutorial content and external genre references.
- The report separates factual errors, sequencing/continuity issues, audience-fit
  issues, and optional improvements.

# Crystal Saga Tutorial Plan

This is the canonical maintainer-facing map of the shipped tutorial series.

The numbered Markdown files in `tutorial/` are the learner-facing source of truth. This file exists to help editors reason about the full series shape, the part breakdown, and the cross-module contracts that must stay synchronized.

If the series structure changes, update all three of these together in the same edit pass:

- `tutorial/PLAN.md`
- `tutorial/CLAUDE.md`
- `tutorial/REGRESSION.md`

## Series Shape

- Audience: software engineers learning Godot
- Format: one project built start to finish
- Total modules: 27
- Review modules: 6
- Parts: 6
- Core promise: every lesson builds on the previous one without hidden forward dependencies

## Part I: Welcome to Godot

| Module | File | Focus | Runnable checkpoint |
|--------|------|-------|---------------------|
| 01 | `01_the_journey_begins.md` | Project setup, nodes, scenes, editor basics | A scene runs in Godot |
| 02 | `02_gdscript_for_programmers.md` | GDScript syntax and input | A scripted sprite moves |
| 03 | `03_thinking_in_scenes.md` | Scene composition, CharacterBody2D, signals | A reusable player scene exists |
| 04 | `04_part_i_review.md` | Review and cheat sheet for Modules 1-3 | Reference-only module |

## Part II: Building the World

| Module | File | Focus | Runnable checkpoint |
|--------|------|-------|---------------------|
| 05 | `05_tilemaps_and_terrain.md` | TileSet workflow, TileMapLayers, collision, camera | Willowbrook is walkable |
| 06 | `06_player_character.md` | AnimatedSprite2D, player state machine, Y-sort | The hero feels like a character |
| 07 | `07_scene_transitions.md` | SceneManager autoload, exits, spawn points | Willowbrook and Whisperwood connect |
| 08 | `08_part_ii_review.md` | Review and cheat sheet for Modules 5-7 | Reference-only module |

## Part III: Data, NPCs, and UI

| Module | File | Focus | Runnable checkpoint |
|--------|------|-------|---------------------|
| 09 | `09_resources_data_layer.md` | Resource classes, `.tres` workflow, data-driven design | Items and characters are data-defined |
| 10 | `10_npcs_and_interaction.md` | NPC scenes, interact prompts, reusable patterns | NPCs can be talked to |
| 11 | `11_dialogue_system.md` | DialogueLine resources, dialogue UI, branching choices | Conversations play in a box |
| 12 | `12_inventory_system.md` | InventoryManager, inventory UI, pause-safe menu flow | Items can be viewed and used |
| 13 | `13_part_iii_review.md` | Review and cheat sheet for Modules 9-12 | Reference-only module |

## Part IV: Combat and the Dungeon

| Module | File | Focus | Runnable checkpoint |
|--------|------|-------|---------------------|
| 14 | `14_battle_foundations.md` | Battle scene, BattlerData, node-based battle state machine | Battles start and cycle turns |
| 15 | `15_player_actions.md` | Menus, commands, targeting, damage, tweens | Battles are interactive |
| 16 | `16_crystal_cavern.md` | Dungeon building, chests, save crystal, boss door | Crystal Cavern is explorable |
| 17 | `17_enemies_and_ai.md` | EnemyData, EncounterData, encounter system, AI | The dungeon contains battles |
| 18 | `18_victory_and_leveling.md` | Victory flow, XP curve, stat growth, defeat flow | Battles reward progression |
| 19 | `19_part_iv_review.md` | Review and cheat sheet for Modules 14-18 | Reference-only module |

## Part V: Progression and Persistence

| Module | File | Focus | Runnable checkpoint |
|--------|------|-------|---------------------|
| 20 | `20_quest_system.md` | GameManager, QuestManager, quests, reactive dialogue, quest log | The world reacts to progress |
| 21 | `21_party_and_equipment.md` | PartyManager, Lira recruitment, equipment, shops, inns | The party can grow and gear up |
| 22 | `22_save_and_load.md` | Save schema, JSON saves, save slots, restoration flow | Progress survives restart |
| 23 | `23_part_v_review.md` | Review and cheat sheet for Modules 20-22 | Reference-only module |

## Part VI: Finishing the Game

| Module | File | Focus | Runnable checkpoint |
|--------|------|-------|---------------------|
| 24 | `24_audio.md` | MusicManager, audio buses, settings panel, SFX | The game has sound |
| 25 | `25_title_screen_and_game_flow.md` | Title screen, pause menu, game over, ending, credits | The full game loop closes |
| 26 | `26_finish_line.md` | Playtesting, troubleshooting, export, extension ideas | The project is shippable |
| 27 | `27_part_vi_review.md` | Final review and architecture cheat sheet | Reference-only module |

## Autoload Introduction Order

| Autoload | First module | Purpose |
|----------|--------------|---------|
| SceneManager | 07 | Scene transitions and spawn points |
| InventoryManager | 12 | Item storage, counts, gold |
| GameManager | 20 | Global flags and world state |
| QuestManager | 20 | Quest lifecycle and objectives |
| PartyManager | 21 | Party roster and shared progression hooks |
| SaveManager | 22 | Save/load orchestration |
| MusicManager | 24 | BGM crossfading and battle music |
| PauseMenu | 25 | Global pause overlay during gameplay |

## Continuity Contracts

These are the series-level rules maintainers should preserve:

- `CharacterData` runtime fields (`current_xp`, `current_hp`, `current_mp`) are introduced in Module 09 so battle lessons do not depend on future edits.
- Module 14's battle flow is a scene swap plus reconstruction, not an overworld-under-battle state stack.
- Module 20 must remain valid before PartyManager exists. Quest XP integration is explicitly upgraded in Module 21.
- `get_completed_quests()` and `get_turned_in_quests()` represent different quest states and must stay semantically distinct in tutorial text and review docs.
- The starter quest log lists active quests only. Completed and turned-in states remain tracked in data/save flow unless the UI is explicitly expanded.
- If `CharacterData` teaches weapon, armor, and accessory slots, the example equipment UI must expose all three or clearly mark any omission as future work.
- New Game and save reconstruction must use pristine character definitions, not duplicate a mutated cached runtime resource.
- PauseMenu must open Inventory and Quest Log through the public APIs taught earlier in Modules 12 and 20.
- Game Over is a decision point (load last save or return to title), not an automatic return-to-title path.
- "What You Should See" sections may only promise features the reader has already built by that point.
- Review modules must mirror the current main modules, not a previous draft.

## Synchronization Checklist for Editors

When editing a module, also review the following likely mirrors:

- Module 05 -> `08_part_ii_review.md`
- Modules 14-18 -> `19_part_iv_review.md`
- Modules 20-22 -> `23_part_v_review.md`
- Modules 24-26 -> `27_part_vi_review.md`
- Any structural change -> `CLAUDE.md`, `PLAN.md`, `REGRESSION.md`

## Maintenance Workflow

Use this when making non-trivial tutorial edits:

1. Read the affected main module and its matching review module.
2. Check `tutorial/REGRESSION.md` for known continuity traps in that area.
3. Make the smallest change that preserves sequential learning continuity.
4. Update mirrored review/support files in the same pass.
5. Do a short sequential reread around the touched modules to ensure no new forward dependency was introduced.

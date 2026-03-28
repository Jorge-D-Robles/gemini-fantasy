# Tutorial: JRPG in Godot 4

A 27-module tutorial series that takes a programmer with zero Godot experience through building a complete JRPG demo called **Crystal Saga**. The tutorial is rendered as a static website via `website/`.

## Design Principles

1. **One project, start to finish.** Every module adds to Crystal Saga. No throwaway examples.
2. **Show, then explain.** Code comes first, then we unpack what it does and why.
3. **Motivate before implementing.** Every new concept opens with a "why do we care?" paragraph featuring a real video game example (Final Fantasy, Chrono Trigger, Pokemon, etc.). The reader should understand the purpose before seeing the code.
4. **Cite everything.** Every Godot concept links to official documentation so readers can go deeper.
5. **Spiral learning.** Concepts appear simply at first, then return with more depth. Mark callbacks with `> **Spiral:**` notes.
6. **JRPG-specific.** Every example, pattern, and design decision is framed through the lens of "how does a JRPG do this?"
7. **Approachable but not patronizing.** Assume the reader can code. Don't assume they know Godot, game dev, or GDScript.
8. **Runnable checkpoints.** Each module ends with a "What You Should See" section so readers can verify they're on track.

## Writing Rules

- **No double dashes ("--") as punctuation.** Use em-dashes (sparingly), semicolons, colons, commas, or sentence breaks instead.
- **No AI writing patterns.** Avoid "delve," "tapestry," "landscape," "leverage," "robust," "crucial," "Furthermore," "Moreover," "It's worth noting," "In conclusion."
- **Explain new features on first use.** When a GDScript or Godot feature appears for the first time (enum, await, groups, static func, lambdas, .bind(), @export_range, etc.), add a brief inline explanation.
- **Remind workflows after long gaps.** If the reader last created a `.tres` file 5+ modules ago, add a one-sentence reminder of the steps (right-click folder, New Resource, search type, Create).
- **Use real game examples.** Background sections reference specific commercial games, not hypothetical scenarios.

## File Structure

```
tutorial/
├── CLAUDE.md              # This file
├── PLAN.md                # Full series plan with module outlines
├── 01_the_journey_begins.md
├── 02_gdscript_for_programmers.md
├── 03_thinking_in_scenes.md
├── 04_part_i_review.md     # Review/cheat sheet modules
├── 05_tilemaps_and_terrain.md
├── 06_player_character.md
├── 07_scene_transitions.md
├── 08_part_ii_review.md
├── 09_resources_data_layer.md
├── 10_npcs_and_interaction.md
├── 11_dialogue_system.md
├── 12_inventory_system.md
├── 13_part_iii_review.md
├── 14_battle_foundations.md
├── 15_player_actions.md
├── 16_crystal_cavern.md
├── 17_enemies_and_ai.md
├── 18_victory_and_leveling.md
├── 19_part_iv_review.md
├── 20_quest_system.md
├── 21_party_and_equipment.md
├── 22_save_and_load.md
├── 23_part_v_review.md
├── 24_audio.md
├── 25_title_screen_and_game_flow.md
├── 26_finish_line.md
└── 27_part_vi_review.md
```

## Module Anatomy

Each content module follows this structure:

1. **Title** (`# Module N: Name`)
2. **What We Have So Far** — one paragraph recapping the project state
3. **What We're Building This Module** — concrete deliverables
4. **Concept sections** — each new concept gets:
   - A motivational background paragraph (why it matters, real game example)
   - Implementation code
   - Explanation of the code
   - `> **See:**` links to Godot docs
   - `> **Spiral:**` callbacks to related concepts in other modules
5. **What We've Learned** — bullet-point summary of all concepts
6. **What You Should See** — testable description of expected game state
7. **Next Module** — teaser for the next module

Review modules (04, 08, 13, 19, 23, 27) follow a different format: cheat sheets, key concept tables, common mistakes, and consolidated doc references.

## Autoload Reference Card

Each module that introduces an autoload includes an updated reference card. The module numbers must match where the autoload is actually built:

| Autoload | Module | Purpose |
|----------|--------|---------|
| SceneManager | 7 | Scene transitions with fade effects |
| InventoryManager | 12 | Item storage, add/remove, signals |
| GameManager | 20 | Game flags, world state tracking |
| QuestManager | 20 | Quest tracking, objective checking |
| PartyManager | 21 | Party roster, recruitment, stats |
| SaveManager | 22 | Save/load game state to JSON |
| MusicManager | 24 | BGM crossfading, battle music |
| PauseMenu | 25 | Global pause menu (UI autoload) |

## Cross-References

- **Website:** The tutorial markdown is rendered by `website/build.js` into static HTML. See `website/CLAUDE.md` for the build system.
- **PLAN.md:** The full series outline with per-module topic lists and Godot doc references.
- **Game project:** The tutorial teaches patterns used in `game/`. The tutorial's Crystal Saga is a separate, simpler project from Gemini Fantasy, but follows the same architectural principles documented in `docs/best-practices/`.

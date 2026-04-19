# Codex Tutorial Audit

## Scope
- Reviewed every file under `tutorial/`:
  - Numbered modules `01` through `27`
  - `tutorial/CLAUDE.md`
  - `tutorial/PLAN.md`
  - `tutorial/REGRESSION.md`
- Audit criteria:
  - Technical accuracy
  - Cross-module consistency
  - Learning continuity
  - Maintainability for future editors
  - Suitability for a software engineer learning Godot by following the series in order

## Overall Assessment
- The tutorial has a strong foundation.
- The tone, pacing, and overall project arc are good.
- The broad structure is exactly what a programmer-friendly Godot tutorial should aim for: one project, real systems, strong motivation, repeated use of core patterns, and frequent "What You Should See" checkpoints.
- The main weakness is not prose quality; it is cross-module contract drift.
- Several later modules quietly revise or contradict earlier assumptions, which breaks the stated promise that every lesson builds on the previous one.
- As written, a diligent reader can learn a lot from this tutorial, but a reader who follows it literally is likely to hit avoidable breakage, false expectations, or confusing rewrites.

## Bottom-Line Verdict
- Pedagogical quality: high potential
- Structural reliability: currently mixed
- Recommendation: do a focused continuity pass before treating this as a canonical start-to-finish learning path

## What Is Already Working Well
- The audience targeting is strong. The material consistently speaks to someone who can already program but does not yet know Godot.
- The "What We Have So Far" and "What You Should See" sections are excellent scaffolding devices.
- The JRPG framing is unusually consistent and useful. Most concept introductions are motivated through recognizable genre patterns instead of abstract engine talk.
- Review modules are a good idea and, when synchronized, will be very valuable.
- The series teaches reusable patterns, not just one-off instructions:
  - scenes and composition
  - Resources and data-driven design
  - autoloads
  - state machines
  - signals
  - UI container patterns
- Local doc citation discipline is good. The tutorial usually points readers to the right official docs for deeper reference.

## Core Risk Theme
The highest-risk pattern is this:

1. A module introduces a data shape or system contract.
2. A later module silently depends on a newer version of that contract.
3. Review modules or support docs then mirror both versions at different times.

That creates exactly the kind of friction that hurts a sequential learner:
- "I followed the steps, why does this symbol not exist yet?"
- "Why does the review module say something different from the main lesson?"
- "Why does the pause menu use this UI differently than the original module taught?"

## Recommended Fix Order
Follow this order if another agent is going to repair the tutorial:

1. Fix the true sequence blockers.
   - Forward references that make an earlier module invalid
   - Compile/runtime issues caused by depending on future autoloads or fields

2. Fix the state/reset and integration issues.
   - New Game reset path
   - pause menu integration
   - recruitment flow

3. Fix the semantic contradictions.
   - wrong mental-model explanations
   - impossible editor instructions
   - mismatched review-module guidance

4. Synchronize the review and support files last.
   - `tutorial/08_part_ii_review.md`
   - `tutorial/19_part_iv_review.md`
   - `tutorial/23_part_v_review.md`
   - `tutorial/27_part_vi_review.md`
   - `tutorial/PLAN.md`
   - `tutorial/REGRESSION.md`

5. Do one final sequential read-through from Module 1 to Module 27.
   - Only after the main fixes land
   - Specifically verify that each module can be followed without future knowledge

## Findings Summary

| ID | Priority | Title | Primary Files |
|---|---|---|---|
| F01 | P0 | Battle foundations reference `CharacterData` fields before they exist | `tutorial/14_battle_foundations.md` |
| F02 | P0 | QuestManager depends on future PartyManager and mixes reward responsibilities | `tutorial/20_quest_system.md` |
| F03 | P1 | Quest completion API is semantically wrong | `tutorial/20_quest_system.md` |
| F04 | P1 | Quest reward item schema and instructions do not match | `tutorial/20_quest_system.md` |
| F05 | P0 | New Game reset path is not actually pristine | `tutorial/25_title_screen_and_game_flow.md`, `tutorial/18_victory_and_leveling.md`, `tutorial/22_save_and_load.md` |
| F06 | P0 | Pause menu bypasses the APIs taught earlier and likely fails in practice | `tutorial/25_title_screen_and_game_flow.md`, `tutorial/12_inventory_system.md`, `tutorial/20_quest_system.md` |
| F07 | P1 | Lira recruitment logic recruits on first conversation, not second | `tutorial/21_party_and_equipment.md` |
| F08 | P1 | Battle module teaches a state-stack mental model that the implementation does not use | `tutorial/14_battle_foundations.md` |
| F09 | P2 | Tilemap and area-building instructions contradict themselves across modules/reviews | `tutorial/05_tilemaps_and_terrain.md`, `tutorial/07_scene_transitions.md`, `tutorial/08_part_ii_review.md` |
| F10 | P2 | Enemy art data is defined but not consumed by the battle pipeline | `tutorial/17_enemies_and_ai.md` |
| F11 | P2 | Playtest/review docs overpromise features that the main series does not actually wire up | `tutorial/26_finish_line.md`, `tutorial/27_part_vi_review.md` |
| F12 | P2 | `tutorial/PLAN.md` is stale relative to the actual 27-module series | `tutorial/PLAN.md` |

## Detailed Findings

### F01 [P0] Battle foundations reference `CharacterData` fields before they exist
- Primary location:
  - `tutorial/14_battle_foundations.md:125-132`
- Mirrored locations:
  - Search for `current_hp = character_data.current_hp` in:
    - `tutorial/19_part_iv_review.md`
    - `tutorial/21_party_and_equipment.md`
    - `tutorial/23_part_v_review.md`
- Problem:
  - Module 14's `BattlerData.initialize_from_character()` reads `character_data.current_hp` and `character_data.current_mp`.
  - Those runtime fields are not introduced until Module 18.
- Why this matters:
  - A reader following the series in order hits a battle implementation that depends on fields they have not been told to add yet.
  - This breaks the tutorial's most important continuity promise.
- Recommended fix:
  - Preferred fix: introduce `current_hp`, `current_mp`, and `current_xp` on `CharacterData` no later than Module 9, when `CharacterData` itself is first defined.
  - Then update Module 18 so it no longer presents those fields as newly introduced; it should instead explain how they are now used for carry-over and leveling.
  - After that, synchronize all mirrored snippets in review modules.
- Downstream files to sync after fixing:
  - `tutorial/18_victory_and_leveling.md`
  - `tutorial/19_part_iv_review.md`
  - `tutorial/21_party_and_equipment.md`
  - `tutorial/23_part_v_review.md`
- Acceptance check:
  - Starting from a fresh sequential read, the reader can complete Module 14 without adding any undocumented fields.

### F02 [P0] QuestManager depends on future PartyManager and mixes reward responsibilities
- Primary location:
  - `tutorial/20_quest_system.md:137-147`
- Problem:
  - `QuestManager.turn_in_quest()` directly references `PartyManager` even though PartyManager is not introduced until Module 21.
  - The code tries to guard this at runtime with `get_node_or_null("/root/PartyManager")`, but the sample still names `PartyManager` directly.
  - The same block also awards XP by directly incrementing `member.current_xp`, bypassing the battle/level-up flow introduced in Module 18.
- Why this matters:
  - The module is no longer self-contained.
  - It teaches a future dependency instead of building strictly on what already exists.
  - It also creates two XP award paths with different behavior:
    - battles use level-up logic
    - quests just add XP numerically
- Recommended fix:
  - Preferred fix: in Module 20, remove party XP distribution entirely and state that quest XP integration is upgraded in Module 21 once PartyManager exists.
  - Alternative fix: resolve PartyManager dynamically without direct symbol usage, but this still leaves the sequencing problem.
  - Also centralize XP granting through one helper path so quest rewards can trigger level-ups correctly once PartyManager exists.
- Downstream files to sync after fixing:
  - `tutorial/21_party_and_equipment.md`
  - `tutorial/23_part_v_review.md`
  - Any review text that says quest rewards already fully integrate with party progression
- Acceptance check:
  - Module 20 code can be copied verbatim into a project that does not yet have PartyManager registered.

### F03 [P1] Quest completion API is semantically wrong
- Primary location:
  - `tutorial/20_quest_system.md:162-163`
- Problem:
  - `get_completed_quests()` returns `_turned_in_quests` instead of `_completed_quests`.
- Why this matters:
  - The method name and behavior disagree.
  - Any UI or follow-up code that wants "completed but not yet turned in" cannot trust the API.
- Recommended fix:
  - Change `get_completed_quests()` to return `_completed_quests`.
  - If the tutorial wants both concepts exposed, add a separate `get_turned_in_quests()` method.
  - Then update any quest-log text or examples to use the correct list.
- Downstream files to sync after fixing:
  - `tutorial/23_part_v_review.md`
  - Any future quest log or journal examples
- Acceptance check:
  - A completed quest appears in the completed list before turn-in, then moves to turned-in after reward collection.

### F04 [P1] Quest reward item schema and instructions do not match
- Primary locations:
  - `tutorial/20_quest_system.md:94`
  - `tutorial/20_quest_system.md:233`
- Problem:
  - `QuestData` defines `reward_items` as `Array[ItemData]`.
  - The tutorial later instructs the reader to "set count to 2" for a reward item.
  - That count field does not exist in the schema being taught.
- Why this matters:
  - The reader cannot literally perform the instructed editor action.
  - This is the kind of mismatch that immediately damages trust.
- Recommended fix:
  - Choose one of these approaches and apply it consistently:
    - Preferred: introduce a small `QuestRewardItem` Resource with `{ item: ItemData, count: int }`, then change `reward_items` to `Array[QuestRewardItem]`.
    - Simpler: keep `Array[ItemData]`, remove all mention of counts, and instruct the reader to add the same item twice if multiple copies are desired.
  - The preferred fix is better long-term because quantity is a legitimate quest-reward concern.
- Downstream files to sync after fixing:
  - `tutorial/23_part_v_review.md`
  - Any quest UI or reward explanation that describes reward item quantities
- Acceptance check:
  - A reader can create the Lost Pendant reward exactly as instructed without inventing a missing field.

### F05 [P0] New Game reset path is not actually pristine
- Primary location:
  - `tutorial/25_title_screen_and_game_flow.md:88-100`
- Supporting context:
  - `tutorial/18_victory_and_leveling.md:239`
  - `tutorial/27_part_vi_review.md:275-280`
- Problem:
  - The tutorial teaches mutating `CharacterData` Resources at runtime for level-ups and persisted stats.
  - `New Game` then does `load("...aiden.tres")`, immediately `duplicate()`s the loaded Resource, and resets only:
    - `current_hp`
    - `current_mp`
    - `current_xp`
    - `level`
  - It does not restore mutated combat stats or equipment.
- Why this matters:
  - If the cached Resource was mutated earlier in the session, `duplicate()` copies the mutated state.
  - A "fresh" new game can inherit old progression.
  - This is both a real bug and a dangerous architectural lesson for a software engineer.
- Recommended fix:
  - Preferred fix: stop treating the `.tres` character definition as both immutable base data and mutable runtime state.
  - Pick one of these tutorial-friendly approaches:
    1. Add an explicit "base stats" vs "runtime stats" split on CharacterData, or
    2. Use a separate runtime wrapper object for saveable character state, or
    3. At minimum, add a real reset helper that restores all mutable fields:
       - level
       - current_xp
       - current_hp/current_mp
       - max_hp/max_mp
       - attack/defense/speed
       - equipped weapon/armor/accessory
  - If staying with the current architecture, the reset helper must source values from a pristine definition, not from a possibly mutated cached instance.
- Downstream files to sync after fixing:
  - `tutorial/18_victory_and_leveling.md`
  - `tutorial/22_save_and_load.md`
  - `tutorial/27_part_vi_review.md`
- Acceptance check:
  - Start a game, level up, equip gear, return to title, choose New Game, and verify the hero starts with original base stats and no stale equipment.

### F06 [P0] Pause menu bypasses the APIs taught earlier and likely fails in practice
- Primary location:
  - `tutorial/25_title_screen_and_game_flow.md:188-200`
- Related earlier modules:
  - `tutorial/12_inventory_system.md` teaches `InventoryScreen.open()` / `close()`
  - `tutorial/20_quest_system.md` defines `QuestLog.refresh()` but does not fully establish a reusable open/close contract
- Problem:
  - PauseMenu's `_open_inventory()` only does:
    - `var inv := get_tree().get_first_node_in_group("inventory_screens")`
    - `inv.visible = true`
  - That bypasses the InventoryScreen API that actually:
    - sets `_is_open`
    - sets `_panel.visible`
    - refreshes slots
    - manages pause lifecycle
  - `_open_quest_log()` similarly assumes a QuestLog instance already exists and can just be made visible.
  - Because PauseMenu is an autoload, its `_unhandled_input()` is also globally active unless gated.
- Why this matters:
  - The pause menu integration does not build on the inventory lesson; it sidesteps it.
  - A reader learns one UI contract in Module 12, then sees a different, weaker pattern in Module 25.
  - This is a direct continuity failure.
- Recommended fix:
  - Add explicit public APIs for pause-menu-managed screens:
    - `InventoryScreen.open_from_pause()`
    - `QuestLog.open_from_pause()` or similar
  - Make PauseMenu call those APIs instead of toggling root `visible`.
  - Decide whether QuestLog is:
    - instanced into every gameplay scene, or
    - instantiated lazily by PauseMenu
  - Gate pause behavior so Escape does not open PauseMenu on title/game-over/ending/credits scenes.
- Downstream files to sync after fixing:
  - `tutorial/12_inventory_system.md`
  - `tutorial/20_quest_system.md`
  - `tutorial/25_title_screen_and_game_flow.md`
  - `tutorial/27_part_vi_review.md`
- Acceptance check:
  - In gameplay, Escape opens the pause menu.
  - Inventory opens correctly from pause with populated slots.
  - Quest log opens correctly from pause.
  - Escape on title screen does not open PauseMenu.

### F07 [P1] Lira recruitment logic recruits on first conversation, not second
- Primary location:
  - `tutorial/21_party_and_equipment.md:81-90`
  - `tutorial/21_party_and_equipment.md:111-113`
- Problem:
  - `_get_lira_dialogue()` sets `talked_to_lira` during the first meeting.
  - The later recruitment check uses `GameManager.has_flag("talked_to_lira")`.
  - If the reader follows the sample literally, that flag is already true by the time the interaction handler decides whether to connect `_recruit_lira`.
- Why this matters:
  - The prose says "talk to Lira twice" but the sample can recruit her after the first interaction.
  - This is a high-visibility trust problem because it directly contradicts what the tutorial tells the learner to expect.
- Recommended fix:
  - Preferred fix: separate the flags:
    - `lira_intro_seen`
    - `lira_ready_to_join`
    - `lira_joined`
  - Simpler fix: capture pre-dialogue state before generating dialogue and only connect recruitment if the NPC was already in the post-introduction state before this interaction began.
- Downstream files to sync after fixing:
  - `tutorial/23_part_v_review.md`
  - `tutorial/26_finish_line.md`
- Acceptance check:
  - First conversation only introduces Lira.
  - Second conversation recruits her after the dialogue finishes.

### F08 [P1] Battle module teaches a state-stack mental model that the implementation does not use
- Primary location:
  - `tutorial/14_battle_foundations.md:705-719`
- Problem:
  - The text claims the overworld is paused underneath battle and later resumed.
  - The implementation in the same module uses `change_scene_to_file()` and reconstructs the previous scene from path and player position.
  - That is not a state stack; it is a scene swap plus reconstruction.
- Why this matters:
  - This teaches the wrong architecture.
  - A software engineer reader will form an incorrect mental model of what the code is doing.
- Recommended fix:
  - Preferred fix: correct the explanation, not the implementation.
  - Say explicitly that:
    - menus are a layered/paused overlay example
    - the current battle implementation is a scene swap, not a preserved scene stack
    - a true scene stack is a different architecture the tutorial is not implementing here
- Downstream files to sync after fixing:
  - `tutorial/19_part_iv_review.md`
  - Any later text that says the overworld sits underneath battle
- Acceptance check:
  - The explanatory section and the actual code path describe the same architecture.

### F09 [P2] Tilemap and area-building instructions contradict themselves across modules/reviews
- Primary locations:
  - `tutorial/05_tilemaps_and_terrain.md:230`
  - `tutorial/08_part_ii_review.md:111`
  - `tutorial/07_scene_transitions.md:267-278`
- Problems:
  - Module 5 says right-click erases while painting.
  - Review module 8 says right-click eyedropper-picks from the viewport.
  - Module 7 tells the reader to paint dense trees on the Ground layer for Whisperwood, while the same module's checklist and earlier layering logic imply trees belong in Objects/YSortGroup.
- Why this matters:
  - Review modules stop being trustworthy as quick references.
  - Learners should not have to guess which instruction is canonical.
- Recommended fix:
  - Standardize one tile-painting instruction set and propagate it to:
    - Module 5
    - Review module 8
  - Rewrite Whisperwood placement steps so tree placement matches the tutorial's own layering model.
  - If the intended forest border uses multiple layers, say so explicitly:
    - trunks on Objects
    - canopy on AbovePlayer
    - only grass/path on Ground
- Downstream files to sync after fixing:
  - `tutorial/05_tilemaps_and_terrain.md`
  - `tutorial/07_scene_transitions.md`
  - `tutorial/08_part_ii_review.md`
- Acceptance check:
  - A reader can build Willowbrook and Whisperwood from the main module and use the review module without hitting contradictory controls or layer guidance.

### F10 [P2] Enemy art data is defined but not consumed by the battle pipeline
- Primary locations:
  - `tutorial/17_enemies_and_ai.md:24-27`
  - `tutorial/17_enemies_and_ai.md:305-320`
- Problem:
  - `EnemyData` defines `sprite: Texture2D`.
  - The conversion from `EnemyData` to `BattlerData`/`CharacterData` never uses that field.
  - Enemy battlers therefore fall back to placeholder art unless manually patched elsewhere.
- Why this matters:
  - It weakens the tutorial's data-driven design story.
  - The reader is asked to author enemy art data that the battle display ignores.
- Recommended fix:
  - Map `EnemyData.sprite` into the battle-visible data path.
  - Example:
    - assign `char_data.portrait = ed.sprite` during conversion, or
    - let `BattlerSprite` read `battler.enemy_data.sprite` directly for enemies
  - Then update the prose so the reader knows exactly where enemy art appears.
- Downstream files to sync after fixing:
  - `tutorial/19_part_iv_review.md`
  - Any "What You Should See" text that implies enemy-specific visuals
- Acceptance check:
  - If the reader assigns a unique sprite to each `EnemyData`, those sprites appear in battle without extra undocumented steps.

### F11 [P2] Playtest/review docs overpromise features that the main series does not actually wire up
- Primary locations:
  - `tutorial/26_finish_line.md:49-55`
  - `tutorial/27_part_vi_review.md:264-265`
- Problems:
  - Module 26's playtest checklist says Whisperwood should have random encounters, but the main encounter-system wiring is only taught for Crystal Cavern.
  - Review module 27 still shows `SaveManager.load_game(1)` for Continue, while Module 25 moved to the save-slot dialog.
- Why this matters:
  - The capstone documents are supposed to be authoritative.
  - If they drift, the learner cannot trust the final validation pass.
- Recommended fix:
  - Decide whether Whisperwood should actually have random encounters:
    - if yes, implement them in the main modules
    - if no, remove the playtest expectation
  - Update Review 27 so its title-screen cheat sheet matches Module 25's save-slot flow.
- Downstream files to sync after fixing:
  - `tutorial/26_finish_line.md`
  - `tutorial/27_part_vi_review.md`
  - `tutorial/REGRESSION.md`
- Acceptance check:
  - The capstone checklist only asks the learner to verify features that were actually taught and wired up.

### F12 [P2] `tutorial/PLAN.md` is stale relative to the actual 27-module series
- Primary locations:
  - `tutorial/PLAN.md:7`
  - Search examples:
    - `tutorial/PLAN.md:126`
    - `tutorial/PLAN.md:357`
    - `tutorial/PLAN.md:675`
    - `tutorial/PLAN.md:708`
- Problem:
  - `PLAN.md` still describes a 21-module structure with old file names and old numbering.
  - The numbered tutorial corpus has 27 modules, including six review modules.
- Why this matters:
  - This is not learner-facing if the website excludes it, but it is a serious maintenance problem.
  - Any future editor or agent using `PLAN.md` as source of truth will make bad changes.
- Recommended fix:
  - Update `PLAN.md` so it matches the actual series shape.
  - If it is intentionally archival, rename it to make that explicit and add a note that it is no longer canonical.
  - Prefer a single canonical support doc for maintainers.
- Downstream files to sync after fixing:
  - `tutorial/CLAUDE.md`
  - `tutorial/REGRESSION.md`
  - Any website/build docs that describe the module set
- Acceptance check:
  - A new maintainer can read `PLAN.md` and get the correct module count, numbering, and filenames.

## Additional Lower-Priority Gaps
These are worth fixing, but they are not the first things I would block on:

- `tutorial/21_party_and_equipment.md`
  - The equipment data model supports accessories, but the sample EquipmentPanel only exposes weapon and armor slots.
- `tutorial/21_party_and_equipment.md`
  - "Lira appears in battle with her own abilities" overpromises relative to what the lesson actually wires up.
- `tutorial/20_quest_system.md`
  - The quest log section creates the UI scene and script but does not make the instancing pattern as explicit as the later pause menu depends on.

## Recommended Repair Strategy for a Follow-Up Agent

### Phase 1: Make the sequence valid
1. Fix F01.
2. Fix F02.
3. Fix F03 and F04.

### Phase 2: Fix runtime/state integrity
4. Fix F05.
5. Fix F06.
6. Fix F07.

### Phase 3: Fix conceptual and documentation drift
7. Fix F08.
8. Fix F09.
9. Fix F10.
10. Fix F11.
11. Fix F12.

### Phase 4: Do a synchronization sweep
After each primary content change, immediately update:
- the matching review module
- any affected support docs
- any "What You Should See" expectations

## Acceptance Criteria for the Tutorial as a Whole
The tutorial should be considered repaired when all of these are true:

1. A reader can start at Module 1 and implement each module in order without needing a future module to make current code compile or make sense.
2. Review modules never contradict the main modules they summarize.
3. Support docs (`CLAUDE.md`, `PLAN.md`, `REGRESSION.md`) point to the same module structure and conventions as the numbered series.
4. "New Game" truly resets progress.
5. Pause-menu integration works through the same public APIs the tutorial taught earlier.
6. "What You Should See" sections only promise features the reader has actually built by that point.

## Final Assessment
This is already much closer to "excellent" than to "broken."

The core design is good:
- the right audience
- the right scope
- the right patterns
- the right amount of ambition

What it needs is not a rewrite. It needs a disciplined continuity pass so the tutorial can live up to its own best idea:

> every lesson should build on top of the previous one

That principle is the correct north star for the next editing pass.

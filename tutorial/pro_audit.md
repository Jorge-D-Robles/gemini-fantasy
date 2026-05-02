## Scope note

I did a **source-level curriculum audit** of the tutorial Markdown, `PLAN.md`, and `REGRESSION.md`, cross-checking the content against the current Godot stable docs and JRPG/RPG design conventions. I did **not** run the Godot project in-editor, so this audit is about tutorial correctness, sequencing, architecture, and consistency rather than runtime validation.

## Overall verdict

This is a **strong curriculum skeleton**. The six-part arc is right for building a JRPG incrementally: Godot fundamentals → world building → data/UI → combat/dungeon → progression/persistence → polish/game loop. The maintainer plan explicitly targets software engineers, one project built start-to-finish, 27 modules, and the promise that each lesson builds on prior work without hidden forward dependencies. That is exactly the right contract for your intended audience. ([GitHub][1])

The main issue is **not the high-level curriculum**. The main issue is that a handful of late-series modules and review modules drift away from the earlier architecture. The most serious examples are Module 27 describing a different battle state machine than Module 14 actually teaches, Module 27 listing `AbilityData` as if Module 15 implemented it, inventory removal allowing impossible states, quest completion/turn-in being semantically shaky in the pendant example, and save/load not preserving world object state despite earlier modules introducing `chest_id`.

My recommendation: **publishable after a P0 consistency pass**, but not before. The tutorial currently teaches many good patterns, yet a careful reader who follows all 27 modules will hit avoidable contradictions.

---

## Scorecard

| Area                                |     Grade | Audit                                                                                                                                                                                           |
| ----------------------------------- | --------: | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Curriculum progression              |    **A-** | The spiral is well designed. Early scenes/signals/resources/autoloads become real systems later.                                                                                                |
| Godot grounding                     |    **B+** | Mostly aligned with Godot 4 docs: `TileMapLayer`, autoloads, `scene_changed`, `user://`, Resources, pause process modes, JSON/FileAccess. Needs version pinning and a few wording fixes.        |
| JRPG grounding                      |    **B+** | The vertical slice covers the expected pillars: exploration, towns, NPCs, dialogue, dungeons, turn/menu combat, party growth, items, quests, save points, shops, audio, title/game-over/ending. |
| Internal consistency                | **B-/C+** | The maintainer regression checklist is excellent, but several review/capstone modules still reintroduce drift.                                                                                  |
| Fit for Jorge / senior SWE audience |    **B+** | The tone is good, but it should lean harder into invariants, contracts, testing, data schemas, migration, and typed boundaries instead of only tutorial-style wiring.                           |

Godot’s current stable line has moved past the tutorial’s “4.3+” baseline; as of April 2026, Godot 4.6.2 is the latest stable maintenance release, and the stable docs identify the 4.6 documentation branch. I would keep “Godot 4.3 or later” if the code is compatible, but add a clear “tested with Godot X.Y” statement near Module 01. ([Godot Engine][2])

---

## What is working especially well

The **core architecture is well chosen for a Godot JRPG**. The tutorial correctly leans on scenes/nodes, custom Resources, autoloads, signals, `TileMapLayer`, UI scenes, and JSON save data. Godot’s own docs support these choices: autoloads are suitable for data and behavior that must stay loaded across scenes, including global player data and scene switching; `SceneTree.scene_changed` is explicitly the reliable signal to await after scene changes; and `TileMapLayer` is the current 2D tilemap node while `TileMap` is deprecated. ([Godot Engine documentation][3])

The **JRPG scope is appropriate**. A role-playing video game is commonly characterized by story, character advancement, combat, party/control commands, levels/experience, quests, world exploration, and NPC interaction. JRPG combat can be turn-based, active-time, action, or strategy; this series wisely chooses the classic menu-driven turn-based path because it is easier to teach and maps cleanly to state machines. ([Wikipedia][4])

The **review modules are a good pedagogical device**. For a software engineer audience, periodic architecture consolidation is more valuable than yet another beginner syntax recap. The review modules make sense as “integration checkpoints,” especially after Parts II, III, IV, and V.

The **maintainer-facing regression checklist is excellent**. It captures exactly the kind of cross-module contract drift that can ruin a long tutorial: `scene_changed` vs. `tree_changed`, custom autoload lookup, `hp_restore` vs. `effect_value`, HP/MP runtime state starting in Module 09, enemy `max_mp`, enemy sprite-to-portrait propagation, `scene_path` in save slots, quest completion vs. turn-in, dialogue choice guards, pause menu APIs, and more. ([GitHub][5])

---

## P0 fixes before publishing

### 1. Module 27’s battle architecture is stale and contradicts Module 14

Module 14 teaches this battle flow:

`INTRO → TURN_START → PLAYER_CHOICE → ACTION_EXECUTE → CHECK_RESULT → VICTORY → DEFEAT`

It also teaches a `BattleStateMachine.transition_to()` API. ([GitHub][6])

Module 27 instead documents `SetupState`, `PlayerTurnState`, `EnemyTurnState`, `ActionState`, `FleeState`, and `_change_state(next_state)`. That is a different architecture. A final capstone module must mirror the implemented architecture, not a previous draft. ([GitHub][7])

**Fix:** Replace Module 27’s battle section with the actual state names and actual transition API:

```text
BattleManager
├── BattleStateMachine
│   ├── Intro
│   ├── TurnStart
│   ├── PlayerChoice
│   ├── ActionExecute
│   ├── CheckResult
│   ├── Victory
│   └── Defeat
```

Also state that flee is a command path, not a separate state, unless you actually add a `Flee` state in Module 17.

---

### 2. Module 27 says `AbilityData` exists in Module 15, but Module 15 says it does not

Module 27’s resource table lists `AbilityData | Module 15`, but Module 15 explicitly says magic is disabled until `AbilityData` is defined as a stretch goal. ([GitHub][7])

**Fix:** Choose one path:

| Option                     | Change                                                                                                     |
| -------------------------- | ---------------------------------------------------------------------------------------------------------- |
| Keep tutorial smaller      | Remove `AbilityData` from Module 27’s “complete architecture” table and list it under “future extensions.” |
| Make the architecture true | Add a real `AbilityData` Resource in Module 15 or 18, then wire a minimal spell into combat.               |

For this curriculum, I would **not** implement magic yet. Keep Module 15 focused on attack/defend/item/targeting and move `AbilityData` to a “Next Systems” section.

---

### 3. `InventoryManager.remove_item()` violates its own contract

Module 12 says `remove_item()` returns `false` when the player does not have the item, but the implementation subtracts `amount` immediately and returns `true` for any matching entry, even if the player has fewer than `amount`. That can create impossible item states and affects battle items, equipment, shops, key items, and save/load. ([GitHub][8])

**Fix the invariant immediately in Module 12:**

```gdscript
func remove_item(item: ItemData, amount: int = 1) -> bool:
    if amount <= 0:
        return false

    for i in range(_items.size()):
        var entry: Dictionary = _items[i]
        if entry.item.id != item.id:
            continue

        if entry.count < amount:
            return false

        entry.count -= amount
        var remaining: int = entry.count

        if remaining <= 0:
            _items.remove_at(i)
            remaining = 0
        else:
            _items[i] = entry

        item_removed.emit(item, remaining)
        inventory_changed.emit()
        return true

    return false
```

Also change `get_all_items()` and similar APIs to avoid returning mutable internals:

```gdscript
func get_all_items() -> Array[Dictionary]:
    return _items.duplicate(true)
```

That is the kind of defensive boundary a software engineer will expect.

---

### 4. Pendant quest completion and turn-in are not cleanly separated

The regression checklist correctly says quest completion and turn-in must remain separate. ([GitHub][5])

Module 20’s `QuestManager` does track `_active_quests`, `_completed_quests`, and `_turned_in_quests`, which is good. But the pendant example sets `pendant_returned` immediately before calling `QuestManager.turn_in_quest(load("lost_pendant.tres"))`. That risks two problems: the quest may not actually be in `_completed_quests` yet, and the newly loaded quest Resource may not be the same object instance stored in the completed list. ([GitHub][9])

**Better model:**

The quest objective should be “find the pendant,” not “return the pendant.” Returning is the turn-in action.

```text
lost_pendant.objective_flags = ["pendant_found"]
lost_pendant.completion_flag = "pendant_returned"
```

Then make turn-in ID-based:

```gdscript
func turn_in_quest_by_id(quest_id: String) -> bool:
    for quest in _completed_quests:
        if quest.id == quest_id:
            _completed_quests.erase(quest)
            _turned_in_quests.append(quest)

            if quest.gold_reward > 0:
                InventoryManager.add_gold(quest.gold_reward)

            for item in quest.reward_items:
                InventoryManager.add_item(item)

            if not quest.completion_flag.is_empty():
                GameManager.set_flag(quest.completion_flag)

            quest_turned_in.emit(quest)
            return true

    return false
```

Then Fynn can call:

```gdscript
QuestManager.turn_in_quest_by_id("lost_pendant")
```

This preserves the curriculum’s intended state machine:

`not started → active → completed → turned in`

---

### 5. Save/load omits persistent world-object state

Module 16 introduces `chest_id`; Module 22 saves autoload state, inventory, party, quest state, scene path, and player position; Module 26’s playtest expects treasure chests to behave correctly. But the save schema does **not** persist opened chests, boss trigger state, boss door unlock state, removed pickups, or other scene object state. ([GitHub][10])

For a JRPG tutorial, this is a big consistency gap. If I open a dungeon chest, save, quit, and reload, the chest should not refill unless the tutorial explicitly says world-object persistence is out of scope.

**Fix:** Since `GameManager` already stores boolean flags, use it for simple persistent world objects:

```gdscript
func _ready() -> void:
    var flag := "chest_opened_%s_%s" % [get_tree().current_scene.scene_file_path.md5_text(), chest_id]
    if GameManager.has_flag(flag):
        _opened = true
        _show_open_sprite()

func _open() -> void:
    if _opened:
        return

    _opened = true
    InventoryManager.add_item(item, amount)

    var flag := "chest_opened_%s_%s" % [get_tree().current_scene.scene_file_path.md5_text(), chest_id]
    GameManager.set_flag(flag)
    _show_open_sprite()
```

For a senior SWE audience, call this a **world-state persistence strategy** and name its limitations: string IDs are simple, but renaming scene paths or object IDs can invalidate old saves.

---

### 6. Save slot dialog cancellation can hang awaiting callers

Module 22’s save crystal and continue flow await `dialog.slot_selected`. The dialog also has a `cancelled` signal, but the caller does not await it. Pressing Cancel can therefore leave the caller awaiting forever. ([GitHub][10])

**Simple tutorial-friendly fix:** have Cancel emit slot `0`, and teach callers to treat `0` as cancellation.

```gdscript
func _ready() -> void:
    for i in range(_buttons.size()):
        _buttons[i].pressed.connect(_on_slot_pressed.bind(i + 1))

    _cancel_btn.pressed.connect(func() -> void:
        slot_selected.emit(0)
    )

    refresh()
    _buttons[0].grab_focus()

func _on_slot_pressed(slot: int) -> void:
    slot_selected.emit(slot)
```

Caller:

```gdscript
var slot: int = await dialog.slot_selected
dialog.queue_free()

if slot == 0:
    return

SaveManager.save_game(slot)
```

This also avoids any ambiguity around closure capture of `slot_num`.

---

## P1 fixes that would materially improve quality

### Clarify built-in singletons vs. custom autoloads

Module 02 reportedly calls `Input` an autoload-style global. The distinction matters later because the regression checklist explicitly warns not to use `Engine.has_singleton()` for custom autoloads. Godot autoloads are nodes/scripts added to the root scene tree and accessible globally, while engine-provided singletons like `Input` and `AudioServer` are a different category. ([Godot Engine documentation][3])

Suggested wording:

> `Input` is a Godot-provided global singleton. Later, we will create our own project autoloads, which are nodes/scripts Godot adds under `/root` for the lifetime of the game.

### Add a public battle transition facade

Several battle states call `battle_manager._state_machine.transition_to(...)`. It works, but the underscore communicates “private implementation detail.” For a software engineer audience, add a public method:

```gdscript
func transition_to_state(state_name: String, context: Dictionary = {}) -> void:
    _state_machine.transition_to(state_name, context)
```

Then states call:

```gdscript
battle_manager.transition_to_state("ActionExecute", command)
```

This teaches encapsulation without complicating the tutorial.

### Fix boss conversion parity in Module 17

Regular enemy conversion correctly copies `sprite` into `CharacterData.portrait` and copies `max_mp`; the boss conversion omits those fields. That contradicts the regression checklist’s enemy conversion requirements and can produce a boss with missing portrait/MP data. ([GitHub][11])

Patch:

```gdscript
boss_char.portrait = boss_data.sprite if boss_data.sprite else preload("res://icon.svg")
boss_char.max_mp = boss_data.max_mp
```

### Decide level-up HP/MP semantics

Module 18 increases max stats, but the curriculum should explicitly choose one JRPG rule:

| Rule                  | Behavior                                                     |
| --------------------- | ------------------------------------------------------------ |
| No heal on level-up   | `max_hp` increases, `current_hp` unchanged. More punishing.  |
| Gain only the delta   | If max HP +10, current HP +10. Common-feeling and intuitive. |
| Full heal on level-up | Current HP/MP set to max. Generous and beginner-friendly.    |

For this tutorial, I would use **gain the delta**. It is easy to explain and avoids the “I leveled up but got no practical HP benefit” confusion.

### Return defensive copies from manager APIs

`InventoryManager.get_all_items()`, `PartyManager.get_members()`, and `QuestManager.get_active_quests()` should avoid returning live internal arrays unless the tutorial explicitly wants callers to mutate them. This is especially important for you as the intended audience; mutable global manager internals are an architectural smell.

### Move simulation/testing earlier

Module 26’s balance simulation is excellent, but it arrives late. Bring a small “combat math sanity test” into Module 18 or 19. RPG design fundamentals revolve around player actions, progression, and narrative, and balance is the glue between action and progression. ([Game Design Skills][12])

Example:

```gdscript
func simulate_attack(attacker_atk: int, defender_def: int, trials: int = 1000) -> float:
    var total := 0
    for i in range(trials):
        total += max(1, attacker_atk - defender_def + randi_range(-2, 2))
    return float(total) / trials
```

---

## Module-by-module audit

| Module                              | Audit                                                                                                                                                                                                                                                                                                                                     |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **01 — The Journey Begins**         | Good opening. The project settings, viewport scale, pixel-art framing, and `res://`/future `user://` mention are appropriate. Add a “tested with Godot X.Y” line because stable docs now track Godot 4.6 and future readers may be on newer versions.                                                                                     |
| **02 — GDScript for Programmers**   | Good fit for you as a software engineer: typed GDScript, lifecycle methods, exports, `@onready`, input map. Clarify `Input` as a Godot-provided singleton, not a custom autoload.                                                                                                                                                         |
| **03 — Thinking in Scenes**         | Solid Godot mental model: reusable `Player` scene, `CharacterBody2D`, collision shape, signals, and scene composition. Optional note: stationary NPCs could be `StaticBody2D`, while `CharacterBody2D` is fine if they may move later.                                                                                                    |
| **04 — Part I Review**              | Useful consolidation. Fix style drift where review tables/comments use double-dash punctuation, since the regression checklist explicitly bans that style. ([GitHub][5])                                                                                                                                                                  |
| **05 — Tilemaps and Terrain**       | Strong module. `TileMapLayer`, shared `TileSet`, collision warnings, camera setup, and pixel-perfect checklist are exactly what a 2D JRPG needs. Godot docs confirm `TileMapLayer` is the current node and `TileMap` is deprecated. ([Godot Engine documentation][13])                                                                    |
| **06 — Player Character**           | Good escalation from movement to animation, facing, interaction direction, Y-sort, and an enum state machine. Add one explicit sentence saying this simple enum state machine will later be contrasted with the node-based battle state machine.                                                                                          |
| **07 — Scene Transitions**          | Strong. `SceneManager`, exits, spawn points, and awaiting `scene_changed` are correct. Godot docs explicitly say `scene_changed` fires after the new scene is added and initialized. ([Godot Engine documentation][14])                                                                                                                   |
| **08 — Part II Review**             | Good checkpoint. Same style issue: replace ASCII/comment double-dash punctuation with `—`, `:`, or `#` comments that do not violate the regression style rule.                                                                                                                                                                            |
| **09 — Resources Data Layer**       | One of the best modules. `ItemData`, `CharacterData`, `NPCData`, runtime fields, and Resource-sharing warnings are foundational. Godot docs state loaded Resources are cached and reused, so the tutorial is right to warn about mutable shared data. ([Godot Engine documentation][15])                                                  |
| **10 — NPCs and Interaction**       | Good bridge from data to world behavior. NPCs inside `YSortGroup`, interaction zones, and temporary printed dialogue are well sequenced before the real dialogue box.                                                                                                                                                                     |
| **11 — Dialogue System**            | Strong. `DialogueLine`, typewriter text, branching choices, direct scene-root `DialogueBox`, and choice guard are the right pieces. Make sure every review snippet preserves the `_choice_container.visible` bypass guard from the regression checklist. ([GitHub][5])                                                                    |
| **12 — Inventory System**           | Architecturally right: global manager plus scene-local UI. But `remove_item()` must be fixed before downstream modules depend on it. Also return defensive copies from read APIs. ([GitHub][8])                                                                                                                                           |
| **13 — Part III Review**            | Good consolidation of data/NPC/UI. Fix review snippets so they do not teach stale dialogue input handling or style-regressed scene-tree comments.                                                                                                                                                                                         |
| **14 — Battle Foundations**         | Strong conceptual leap. The enum-to-node-state-machine comparison is exactly the kind of architectural progression a programmer will appreciate. Add a public transition facade instead of states reaching into `_state_machine`. ([GitHub][6])                                                                                           |
| **15 — Player Actions**             | Good JRPG combat lesson: command menu, target selection, attack/defend/item, damage formula, tweens, damage numbers. The command dictionary is fine as a tutorial MVP, but mark it as a stepping stone toward typed commands or Resources. Also fix the Module 27 `AbilityData` contradiction. ([GitHub][16])                             |
| **16 — Crystal Cavern**             | Excellent “content synthesis” module. It turns abstract systems into a real dungeon: rooms, corridors, chests, save crystal, boss door, encounter zones. Add persistence guidance for `chest_id`; otherwise the ID looks important but is unused by save/load.                                                                            |
| **17 — Enemies and AI**             | Strong module. `EnemyData`, `EncounterData`, weighted encounters, AI strategies, and enemy-to-battler conversion are appropriate. Fix boss conversion to include portrait and `max_mp`; add a guard for total encounter weight ≤ 0. ([GitHub][11])                                                                                        |
| **18 — Victory and Leveling**       | Good progression module. XP, gold, loot, level curve, HP/MP carry-over, and post-battle synchronization belong here. Clarify whether defeated party members earn XP and what happens to current HP/MP on level-up.                                                                                                                        |
| **19 — Part IV Review**             | Good combat/dungeon checkpoint. However, it should avoid double-dash scene-tree comments and should mirror the exact Module 14 state names and APIs. The current review still contains ASCII `+--` plus `--` comments. ([GitHub][17])                                                                                                     |
| **20 — Quest System**               | Conceptually excellent: flags, quests as data, reactive dialogue, active/completed/turned-in states. The pendant turn-in flow needs the P0 fix above so completion and turn-in stay semantically separate. ([GitHub][9])                                                                                                                  |
| **21 — Party and Equipment**        | Good timing. PartyManager, recruitment, equipment, shops, and innkeeper are exactly the systems that should follow quests. Fix equipment transaction order: remove item first or roll back if removal fails. Also avoid returning live party arrays.                                                                                      |
| **22 — Save and Load**              | Strong save architecture for tutorial scope: JSON, `to_save_data()`/`from_save_data()`, `CACHE_MODE_IGNORE`, `user://`, slot metadata, and `scene_changed`. Godot docs support `user://` for writable persistent data in exported projects. Fix cancellation, possible slot closure capture, and world-object persistence. ([GitHub][10]) |
| **23 — Part V Review**              | Good persistence/progression checkpoint. Tighten language around quest states: either use `QuestData.QuestState` directly or describe state as manager-inferred from arrays, not both.                                                                                                                                                    |
| **24 — Audio**                      | Good polish module. MusicManager as an autoload scene, crossfade, battle music memory, SFX, buses, and volume settings are appropriate. Note that volume settings are session-only unless saved via ConfigFile or SaveManager extension.                                                                                                  |
| **25 — Title Screen and Game Flow** | Correct placement for title, continue, settings, pause, game over, ending, credits. Godot pause docs support using process modes so pause UI still processes while the tree is paused. Ensure every save/load dialog handles cancellation. ([Godot Engine documentation][18])                                                             |
| **26 — Finish Line**                | Good final playtest/export/troubleshooting module. Tone down “complete JRPG” to “complete small JRPG vertical slice” or “complete tutorial JRPG,” because content scope is still small and some persistence systems are intentionally minimal. ([GitHub][19])                                                                             |
| **27 — Part VI Review**             | Needs the biggest rewrite. It should be the canonical final architecture cheat sheet, but it currently documents stale battle states and a nonexistent `AbilityData` implementation. Fix before publishing. ([GitHub][7])                                                                                                                 |

---

## Godot documentation alignment

The tutorial is mostly well grounded in Godot’s intended architecture:

| Godot concept | Tutorial usage                                                                                                | Audit                                                                                                                                                                                                       |
| ------------- | ------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Nodes/scenes  | Player, NPCs, battle scene, UI screens, managers                                                              | Correct. This is the Godot-native mental model.                                                                                                                                                             |
| Autoloads     | SceneManager, InventoryManager, GameManager, QuestManager, PartyManager, SaveManager, MusicManager, PauseMenu | Correct, but clarify engine singleton vs. project autoload. Godot docs describe autoloads as always-loaded objects that can store global data and handle scene switching. ([Godot Engine documentation][3]) |
| Scene changes | `change_scene_to_file()` plus `await scene_changed`                                                           | Correct and explicitly supported by docs. ([Godot Engine documentation][14])                                                                                                                                |
| Tilemaps      | `TileMapLayer` instead of old `TileMap`                                                                       | Correct for Godot 4 stable. ([Godot Engine documentation][13])                                                                                                                                              |
| Resources     | `.tres` data for items, characters, NPCs, quests, enemies, encounters                                         | Correct. Add stronger warnings around shared mutable Resource instances. ([Godot Engine documentation][15])                                                                                                 |
| Pause         | PauseMenu and UI process modes                                                                                | Correct in principle. Godot docs state paused trees stop normal processing unless process mode allows it. ([Godot Engine documentation][18])                                                                |
| Saves         | JSON + `FileAccess` + `user://`                                                                               | Correct for tutorial scope. Add world-object persistence and cancellation handling. ([Godot Engine documentation][20])                                                                                      |

---

## JRPG grounding

The tutorial’s feature selection is genre-appropriate. A small JRPG vertical slice should teach:

| JRPG pillar                   | Tutorial coverage |
| ----------------------------- | ----------------- |
| Town/hub                      | Willowbrook       |
| Field/exploration connector   | Whisperwood       |
| Dungeon                       | Crystal Cavern    |
| NPC dialogue                  | Modules 10–11     |
| Reactive world state          | Module 20         |
| Inventory/resource management | Module 12         |
| Menu-driven combat            | Modules 14–15     |
| Enemies/encounters            | Module 17         |
| XP/leveling/rewards           | Module 18         |
| Quests                        | Module 20         |
| Party/recruitment/equipment   | Module 21         |
| Shops/inn                     | Module 21         |
| Save points/slots             | Module 22         |
| Music/SFX                     | Module 24         |
| Title/game over/ending        | Module 25         |

That is the right minimum set. I would be careful with claims like “complete JRPG,” because the tutorial builds a **complete small JRPG loop**, not the systemic/content breadth people associate with full commercial JRPGs. RPGs are generally tied to narrative, progression, character growth, quests, combat, and world exploration; this series hits those pillars, but at tutorial scale. ([Wikipedia][4])

---

## Tailoring improvements for you as the intended audience

For a software engineer at Google, I would add a small **“Engineering Contract” box** to the end of every non-review module:

```text
New artifacts:
- res://autoloads/inventory_manager.gd
- res://ui/inventory/inventory_screen.tscn

New global state:
- InventoryManager.gold
- InventoryManager._items

New signals:
- inventory_changed
- item_added
- item_removed
- gold_changed

New invariants:
- item counts are always positive
- remove_item() returns false if insufficient quantity
- UI never mutates _items directly

Regression checks:
- Can add 3 potions, remove 1, save/load, still have 2
- Cannot remove 99 potions if only 2 exist
```

That single pattern would make the curriculum feel much more professional and prevent most cross-module bugs.

I would also add a lightweight **tutorial lint checklist**:

```bash
grep -R "tree_changed" tutorial/
grep -R "Engine.has_singleton" tutorial/
grep -R "effect_value" tutorial/
grep -R "scene_name" tutorial/
grep -R "AbilityData" tutorial/
grep -R -- " -- " tutorial/
```

And a semantic checklist:

```text
- Every review module mirrors the implementation modules.
- Every Resource listed in Module 27 was actually implemented.
- Every exported ID introduced for persistence is saved or explicitly marked future.
- Every manager read API is either immutable-by-contract or returns a copy.
- Every awaitable dialog has a cancellation path.
- Every save schema field has a corresponding restore path.
```

---

## Recommended fix order

1. **Rewrite Module 27’s architecture section** to match Modules 14–25.
2. **Remove or implement `AbilityData`**, preferably remove from “complete architecture” and mark future.
3. **Patch `InventoryManager.remove_item()`** and defensive copy APIs in Module 12.
4. **Patch Module 20 quest turn-in** to be ID-based and completion/turn-in clean.
5. **Patch Module 22 save slot cancellation** and slot button binding.
6. **Add chest/world-object persistence** using `GameManager` flags or a small `WorldStateManager`.
7. **Fix Module 17 boss conversion** for portrait and `max_mp`.
8. **Sweep review modules for stale snippets and double-dash style regressions**.
9. **Add module-level engineering contracts** so future edits preserve continuity.

After those changes, the series will read as a coherent, cumulative JRPG curriculum rather than a collection of good modules with a few late-stage inconsistencies.

[1]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/PLAN.md "raw.githubusercontent.com"
[2]: https://godotengine.org/article/maintenance-release-godot-4-6-2/ "Maintenance release: Godot 4.6.2 – Godot Engine"
[3]: https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html "Singletons (Autoload) — Godot Engine (stable) documentation in English"
[4]: https://en.wikipedia.org/wiki/Role-playing_video_game "Role-playing video game - Wikipedia"
[5]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/REGRESSION.md "raw.githubusercontent.com"
[6]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/14_battle_foundations.md "raw.githubusercontent.com"
[7]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/27_part_vi_review.md "raw.githubusercontent.com"
[8]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/12_inventory_system.md "raw.githubusercontent.com"
[9]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/20_quest_system.md "raw.githubusercontent.com"
[10]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/22_save_and_load.md "raw.githubusercontent.com"
[11]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/17_enemies_and_ai.md "raw.githubusercontent.com"
[12]: https://gamedesignskills.com/game-design/rpg/ "RPG Game Design (Fundamentals, Patterns, Mechanics)"
[13]: https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html "TileMapLayer — Godot Engine (stable) documentation in English"
[14]: https://docs.godotengine.org/en/stable/classes/class_scenetree.html "SceneTree — Godot Engine (stable) documentation in English"
[15]: https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html?utm_source=chatgpt.com "Resources — Godot Engine (stable) documentation in English"
[16]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/15_player_actions.md "raw.githubusercontent.com"
[17]: https://github.com/Jorge-D-Robles/gemini-fantasy/blob/main/tutorial/19_part_iv_review.md "gemini-fantasy/tutorial/19_part_iv_review.md at main · Jorge-D-Robles/gemini-fantasy · GitHub"
[18]: https://docs.godotengine.org/en/stable/tutorials/scripting/pausing_games.html "Pausing games and process mode — Godot Engine (stable) documentation in English"
[19]: https://raw.githubusercontent.com/Jorge-D-Robles/gemini-fantasy/main/tutorial/26_finish_line.md "raw.githubusercontent.com"
[20]: https://docs.godotengine.org/en/stable/classes/class_fileaccess.html?utm_source=chatgpt.com "FileAccess — Godot Engine (stable) documentation in English"

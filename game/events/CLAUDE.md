# game/events/

Story event scripts — one-shot cutscenes, recruitments, and story triggers. Each script is instanced as a child node in the scene where it fires. Events are gated by `EventFlags` to prevent replaying.

## File Index

| File | Class | Trigger Location | Flag |
|------|-------|-----------------|------|
| `event_flags.gd` | *(autoload)* | — | — |
| `opening_sequence.gd` | `OpeningSequence` | Overgrown Ruins / LyraDiscoveryZone | `opening_lyra_discovered` |
| `garrick_recruitment.gd` | `GarrickRecruitment` | Roothollow / Garrick NPC | `garrick_recruited` |
| `iris_recruitment.gd` | `IrisRecruitment` | Verdant Forest | `iris_recruited` |
| `boss_encounter.gd` | `BossEncounter` | Overgrown Ruins / BossZone | `boss_defeated` |
| `garrick_meets_lyra.gd` | `GarrickMeetsLyra` | Overgrown Ruins / LyraDiscoveryZone | `garrick_met_lyra` |

> **Note:** `event_flags.gd` lives here but is registered as the `EventFlags` autoload in `project.godot`. See `game/autoloads/CLAUDE.md` for the autoload inventory.

## EventFlags API

```gdscript
EventFlags.set_flag("flag_name")
EventFlags.has_flag("flag_name") -> bool
EventFlags.clear_flag("flag_name")          # used to reset on defeat (see iris)
EventFlags.get_all_flags() -> Dictionary    # for serialization
EventFlags.load_flags(data: Dictionary)     # called by SaveManager on load
```

## Standard Event Pattern

All event scripts follow this structure — use it when adding new events:

```gdscript
class_name MyEvent
extends Node

signal sequence_completed

const FLAG_NAME: String = "my_event_flag"


func trigger() -> void:
    if EventFlags.has_flag(FLAG_NAME):
        return                              # 1. Guard — don't replay

    EventFlags.set_flag(FLAG_NAME)          # 2. Set flag immediately
    GameManager.push_state(GameManager.GameState.CUTSCENE)

    var lines: Array[DialogueLine] = [      # 3. Build dialogue
        DialogueLine.create("Speaker", "Line text."),
    ]
    DialogueManager.start_dialogue(lines)
    await DialogueManager.dialogue_ended    # 4. Wait for completion

    # 5. Optional: add to party, load resources, etc.

    GameManager.pop_state()                 # 6. Restore state
    sequence_completed.emit()              # 7. Notify parent scene
```

## Per-Event Notes

### OpeningSequence
- Kael discovers Lyra in the Overgrown Ruins
- 48-line dialogue compressing Chapter 1 Scene 5 + Chapter 2 Scene 2 (discovery, identity, structured fragmentation, sealed truth, fading urgency, emotional connection, fragment quest hook, resolve)
- After dialogue, Lyra joins the party via `PartyManager.add_character()`
- Loads `res://data/characters/lyra.tres` — null-check in script
- Scene disables `LyraDiscoveryZone.monitoring` after trigger and on revisit

### GarrickRecruitment
- Garrick joins the party after the dialogue ends
- Loads `res://data/characters/garrick.tres` — null-check in script
- Call `trigger()` from the Garrick NPC's interaction handler

### IrisRecruitment
- Most complex event: dialogue → party add → forced battle → post-battle dialogue
- Iris is added to the party **before** the battle so she participates
- Uses `CONNECT_ONE_SHOT` on `BattleManager.battle_ended` for post-battle callback
- Callback is `static` to survive scene changes (references only autoloads)
- On defeat: `EventFlags.clear_flag(FLAG_NAME)` so the event re-triggers next visit
- Loads `res://data/enemies/ash_stalker.tres` — falls back to skipping battle if null

### BossEncounter
- Scripted one-time boss fight against The Last Gardener
- Requires `opening_lyra_discovered` flag (Lyra must be discovered first)
- Pre-battle dialogue (4 lines), then forced battle with no escape
- Uses `CONNECT_ONE_SHOT` on `BattleManager.battle_ended` (same pattern as Iris)
- On victory: sets `boss_defeated` flag, awards 200 bonus gold, shows post-battle dialogue
- On defeat: flag is NOT set — player can retry on next visit
- Scene disables `BossZone.monitoring` on trigger and on revisit if flag is set

### GarrickMeetsLyra
- Garrick meets Lyra for the first time in the preserved room
- Compresses Chapter 4, Scene 5 from `docs/story/act1/04-old-iron.md`
- Emotional peak: Garrick asks "Are you in pain?" — connects his guilt to Lyra's fragmentation
- 14-line dialogue (Lyra, Garrick, Kael)
- Prerequisites: `opening_lyra_discovered` AND `garrick_recruited` (checked at scene level)
- Reuses `LyraDiscoveryZone` Area2D with three-state logic in `overgrown_ruins.gd`
- Sets `garrick_met_lyra` flag — downstream dependency for T-0086 (demo ending)

## Adding New Events

1. Create `game/events/my_event.gd` following the standard pattern above
2. Instance the node in the relevant scene `.tscn`
3. Connect the scene's trigger (Area2D, NPC signal, etc.) to `my_event.trigger()`
4. Connect `sequence_completed` to whatever the scene needs to do afterward
5. Add a unit test in `game/tests/unit/events/test_my_event.gd` that verifies:
   - Flag prevents re-trigger
   - `sequence_completed` is emitted
   - Side effects (party add, etc.) occur correctly

## Dependencies

Every event script uses:
- `EventFlags` — flag gating (autoload)
- `GameManager` — state push/pop (autoload)
- `DialogueManager` + `DialogueLine` — dialogue playback (autoload + resource)
- `PartyManager` — character recruitment (autoload, where applicable)
- `BattleManager` — forced battles (autoload, where applicable)

# game/events/

Story event scripts — one-shot cutscenes, recruitments, and story triggers. Each script is instanced as a child node in the scene where it fires. Events are gated by `EventFlags` to prevent replaying.

## File Index

| File | Class | Trigger Location | Flag |
|------|-------|-----------------|------|
| `event_flags.gd` | *(autoload)* | — | — |
| `opening_sequence.gd` | `OpeningSequence` | Overgrown Ruins / LyraDiscoveryZone | `opening_lyra_discovered` |
| `garrick_recruitment.gd` | `GarrickRecruitment` | Roothollow / Garrick NPC | `garrick_recruited` |
| `iris_recruitment.gd` | `IrisRecruitment` | Verdant Forest | `iris_recruited` |

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
- Pure dialogue only — no party changes, no battle
- Scene should listen to `sequence_completed` to dismiss the trigger zone

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

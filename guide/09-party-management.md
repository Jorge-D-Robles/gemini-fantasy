# Chapter 9 — Party Management

You have a roster of characters defined as Resources and a world full of scenes to explore. But who is actually *in the party* right now? Who is active in battle formation versus benched on reserve? When a character takes 30 damage in a fight, where does that damage live between battles?

This chapter builds the PartyManager autoload — the single source of truth for party composition and runtime character state. If you have worked with NgRx or Zustand, you already know this pattern: the Resource files are your type definitions, and the manager is the runtime store.

## What We Are Building

- **PartyManager** — an autoload that tracks the player's party roster
- **Active/reserve roster** — max 4 active members (in battle), max 4 reserve (benched)
- **Runtime state** — current HP and EE stored separately from Resource data
- **Roster operations** — add, remove, swap, and auto-promote members
- **`party_changed` signal** — notifies UI, followers, and other systems when the roster changes

## Why Runtime State Lives in the Manager, Not the Resource

This is the most important architectural decision in this chapter, so let us address it first.

A `CharacterData` Resource defines a character's *template*: base stats, growth rates, portrait path, abilities. It is a blueprint. In Angular terms, it is the interface definition — the shape of the data.

But current HP is not part of the blueprint. A character's HP changes every time they take damage or get healed. If you stored `current_hp` directly on the `CharacterData` Resource, you would be mutating your template data. That creates several problems:

1. **Save/load ambiguity** — Is the Resource file the "clean" template or the "dirty" runtime version?
2. **Multiple references** — If two systems hold a reference to the same Resource, mutations in one are visible in the other (Resources are reference types in Godot).
3. **Reset difficulty** — How do you restore a character to full HP at an inn? You need to know the original `max_hp`, but you already overwrote it with runtime data.

The solution: Resources store *what things are*. A separate Dictionary in the manager stores *how things are right now*.

```
CharacterData Resource          PartyManager._runtime_state
┌──────────────────────┐       ┌──────────────────────────┐
│ id: &"kael"          │       │ &"kael": {               │
│ max_hp: 120          │       │   "current_hp": 85,      │
│ max_ee: 50           │       │   "current_ee": 30,      │
│ attack: 15           │       │ }                        │
│ ...                  │       │ &"lyra": {               │
└──────────────────────┘       │   "current_hp": 100,     │
                               │   "current_ee": 45,      │
                               │ }                        │
                               └──────────────────────────┘
```

**Engineering parallel:** This is the same reason NgRx separates entity definitions (interfaces) from runtime state (the store). The interface says a `User` *has* an `email` field. The store says user #42's email *is* `"alice@example.com"` right now.

## The PartyManager Autoload

Create the script and register it as an autoload.

### Step 1: Create the Script

```gdscript
# game/autoloads/party_manager.gd
extends Node

## Manages the player's party roster and active party members.

signal party_changed
signal party_state_changed

const MAX_ACTIVE: int = 4
const MAX_RESERVE: int = 4

## All recruited party members (active + reserve).
var roster: Array[Resource] = []
## Currently active party (in battle formation).
var active_party: Array[Resource] = []
## Reserve party members (benched).
var reserve_party: Array[Resource] = []
## Runtime HP/EE state per character_id.
var _runtime_state: Dictionary = {}
```

Two signals serve different audiences:
- `party_changed` — roster composition changed (add, remove, swap). UI rebuilds the party list, follower system updates who walks behind the player.
- `party_state_changed` — HP or EE changed outside of battle (healing at an inn, poison tick on the overworld). The HUD updates health bars.

The `_runtime_state` Dictionary is keyed by `StringName` (the character's `id` from `BattlerData`). Each value is a small Dictionary with `"current_hp"` and `"current_ee"`.

### Step 2: Register as Autoload

In `project.godot`, under `[autoload]`, add:

```ini
PartyManager="*res://autoloads/party_manager.gd"
```

Or in the editor: **Project > Project Settings > Autoload** tab, add the script with name `PartyManager`.

Now any script in the project can access `PartyManager` by name — no imports, no dependency injection, no `get_node()`.

## Adding Characters to the Roster

When the player recruits a new party member (a story event, a quest reward), call `add_character()`:

```gdscript
func add_character(data: Resource) -> void:
	if data == null:
		push_warning("PartyManager: cannot add null character.")
		return
	if _find_in_roster(data) >= 0:
		push_warning("PartyManager: character already in roster.")
		return

	roster.append(data)
	_init_runtime_state(data)

	if active_party.size() < MAX_ACTIVE:
		active_party.append(data)
	else:
		reserve_party.append(data)

	party_changed.emit()
```

The logic is straightforward:

1. Guard against null and duplicates.
2. Add to the full roster.
3. Initialize runtime HP/EE to full (max values from the Resource).
4. If the active party has room, add there. Otherwise, bench to reserve.
5. Emit `party_changed` so listeners can react.

The runtime state initializer reads max values from the `BattlerData` base class:

```gdscript
func _init_runtime_state(data: Resource) -> void:
	var bd := data as BattlerData
	if not bd or bd.id == &"":
		return
	_runtime_state[bd.id] = {
		"current_hp": bd.max_hp,
		"current_ee": bd.max_ee,
	}
```

Notice the cast to `BattlerData`. The parameter is typed as `Resource` for flexibility (any Resource subclass works), but we need the `BattlerData` fields. The `as` keyword in GDScript performs a safe cast — if the object is not a `BattlerData`, `bd` will be `null`, and the guard catches it.

## Removing Characters

When a character leaves the party (story event, betrayal, temporary departure):

```gdscript
func remove_character(data: Resource) -> void:
	if data == null:
		push_warning("PartyManager: cannot remove null character.")
		return
	var index := _find_in_roster(data)
	if index < 0:
		push_warning("PartyManager: character not in roster.")
		return

	roster.remove_at(index)
	_clear_runtime_state(data)

	var active_idx := _find_in_array(active_party, data)
	if active_idx >= 0:
		active_party.remove_at(active_idx)
		_promote_from_reserve()
	else:
		var reserve_idx := _find_in_array(reserve_party, data)
		if reserve_idx >= 0:
			reserve_party.remove_at(reserve_idx)

	party_changed.emit()
```

The critical detail is `_promote_from_reserve()`. If you remove an active member and the reserve bench is not empty, the first reserve member is automatically promoted to active. This prevents the player from accidentally entering battle with only 2 of 4 slots filled.

```gdscript
func _promote_from_reserve() -> void:
	if reserve_party.is_empty():
		return
	if active_party.size() >= MAX_ACTIVE:
		return
	var promoted: Resource = reserve_party.pop_front()
	active_party.append(promoted)
```

`pop_front()` removes and returns the first element — the character who has been on the bench the longest gets promoted first.

## Swapping Active and Reserve Members

The party management UI lets the player swap an active member with a reserve member:

```gdscript
func swap_members(active_index: int, reserve_index: int) -> void:
	if active_index < 0 or active_index >= active_party.size():
		push_warning("PartyManager: invalid active index.")
		return
	if reserve_index < 0 or reserve_index >= reserve_party.size():
		push_warning("PartyManager: invalid reserve index.")
		return

	var temp := active_party[active_index]
	active_party[active_index] = reserve_party[reserve_index]
	reserve_party[reserve_index] = temp

	party_changed.emit()
```

Classic array swap — store one value in a temp variable, overwrite, then assign temp to the other slot. The signal fires so the UI rebuilds.

## Reading Runtime State

Other systems need to read HP and EE. The battle system reads it when spawning party battlers. The HUD reads it to draw health bars. The save system reads it to serialize.

```gdscript
func get_hp(character_id: StringName) -> int:
	if character_id in _runtime_state:
		return _runtime_state[character_id]["current_hp"]
	return 0


func get_ee(character_id: StringName) -> int:
	if character_id in _runtime_state:
		return _runtime_state[character_id]["current_ee"]
	return 0


func get_runtime_state(character_id: StringName) -> Dictionary:
	if character_id in _runtime_state:
		return _runtime_state[character_id].duplicate()
	return {}
```

`get_runtime_state()` returns a *duplicate* of the dictionary, not a reference. This prevents external code from accidentally mutating the manager's internal state. Defensive copies are a habit worth building.

## Writing Runtime State

The battle system writes HP/EE back to the manager when a battle ends:

```gdscript
func set_hp(character_id: StringName, value: int) -> void:
	if character_id not in _runtime_state:
		return
	var bd := _find_data_by_id(character_id)
	var max_val: int = bd.max_hp if bd else value
	_runtime_state[character_id]["current_hp"] = clampi(value, 0, max_val)
	party_state_changed.emit()


func set_ee(character_id: StringName, value: int) -> void:
	if character_id not in _runtime_state:
		return
	var bd := _find_data_by_id(character_id)
	var max_val: int = bd.max_ee if bd else value
	_runtime_state[character_id]["current_ee"] = clampi(value, 0, max_val)
	party_state_changed.emit()
```

`clampi()` ensures the value never goes below 0 or above the character's maximum. The `_find_data_by_id()` helper scans the roster to find the `BattlerData` Resource with a matching `id`:

```gdscript
func _find_data_by_id(character_id: StringName) -> BattlerData:
	for data in roster:
		var bd := data as BattlerData
		if bd and bd.id == character_id:
			return bd
	return null
```

## Full Heal (Inn / Save Point)

When the player rests at an inn or save point, restore everyone to full:

```gdscript
func heal_all() -> void:
	for data in roster:
		var bd := data as BattlerData
		if bd and bd.id in _runtime_state:
			_runtime_state[bd.id]["current_hp"] = bd.max_hp
			_runtime_state[bd.id]["current_ee"] = bd.max_ee
	party_state_changed.emit()
```

This iterates the full roster (active and reserve), reads each character's `max_hp` and `max_ee` from their Resource, and resets the runtime state. One signal emission at the end — not one per character.

## Query Helpers

A few convenience methods round out the API:

```gdscript
func get_active_party() -> Array[Resource]:
	return active_party.duplicate()


func get_roster() -> Array[Resource]:
	return roster.duplicate()


func get_party_size() -> int:
	return active_party.size()


func is_in_party(data: Resource) -> bool:
	return _find_in_array(active_party, data) >= 0
```

Again, `get_active_party()` and `get_roster()` return duplicates. The caller gets a snapshot, not a live reference.

The internal search helpers use simple linear scans — with a maximum of 8 characters, there is no need for hash maps or binary search:

```gdscript
func _find_in_roster(data: Resource) -> int:
	return _find_in_array(roster, data)


func _find_in_array(arr: Array[Resource], data: Resource) -> int:
	for i in arr.size():
		if arr[i] == data:
			return i
	return -1
```

## How the Battle System Uses PartyManager

The connection between PartyManager and the battle system flows in both directions:

**Before battle:** `BattleScene.setup_battle()` receives the active party data. For each member, it creates a `PartyBattler`, calls `initialize_from_data()` to load base stats from the Resource, then calls `_apply_persistent_state()` to overwrite HP/EE with the current runtime values from PartyManager.

```
PartyManager → BattleScene._apply_persistent_state() → PartyBattler.current_hp
```

**After battle:** `BattleScene._persist_party_state()` writes each party battler's final HP and EE back to PartyManager:

```
PartyBattler.current_hp → BattleScene._persist_party_state() → PartyManager.set_hp()
```

This two-way sync means the battle system can work with its own local state during combat (no constant autoload calls in tight loops), but the results persist across scenes.

## How It Connects

| System | Connection |
|--------|-----------|
| **BattleManager** | Reads `get_active_party()` to know who fights |
| **BattleScene** | Reads/writes HP/EE via `get_runtime_state()` / `set_hp()` / `set_ee()` |
| **HUD** | Connects to `party_state_changed` to update health bars |
| **Save/Load** | Serializes `roster`, `active_party`, `reserve_party`, `_runtime_state` |
| **Follower System** | Connects to `party_changed` to update who walks behind the player |
| **Equipment** | `EquipmentManager` is keyed by the same `character_id` as `_runtime_state` |

## Common Mistakes

**Storing HP on the Resource.** It works until you need to serialize. Then you realize you cannot distinguish "template data" from "current game state." Keep them separate from the start.

**Forgetting to emit signals.** Every mutation method must emit either `party_changed` or `party_state_changed`. If you add a new method that modifies the roster or runtime state and forget the signal, the UI will be stale.

**Not duplicating return values.** If `get_active_party()` returns the actual array (not a duplicate), a caller could `push_back()` to it and corrupt the manager's internal state. Always return copies of mutable collections.

**Using `class_name` on autoloads.** Autoload scripts should *not* have a `class_name` declaration. They are already globally accessible by their autoload name. Adding `class_name` creates a confusing dual identity.

## What Is Next

The party is assembled. Characters have stats. HP persists between scenes. In the next chapter, we build the system that actually uses all of this: the battle system. We will create a state machine that orchestrates turn-based combat, spawn battlers from party and enemy data, and build a turn queue that determines who acts first.

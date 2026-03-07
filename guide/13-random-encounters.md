# Chapter 13 — Random Encounters

In web applications, you schedule background work — polling intervals, retry timers, debounced inputs. Random encounters are the game equivalent: invisible background logic that watches the player move, counts steps, rolls dice, and occasionally interrupts exploration with combat. The player never sees the machinery. They just know that walking through a dungeon might trigger a fight.

This chapter builds the `EncounterSystem` — a self-contained node that any area scene can drop in to enable random battles. It tracks pixel distance as discrete "steps," enforces a minimum gap between encounters, selects enemy groups from a weighted pool, and provides a brief warning window before combat begins.

## What We Are Building

- **EncounterPoolEntry** — a Resource that pairs an enemy group with a probability weight
- **EncounterSystem** — a Node that counts steps, rolls for encounters, selects enemy groups, and fires signals
- **Area scene wiring** — connecting the encounter system to `BattleManager.start_battle()`

By the end of this chapter, walking through a dungeon or overworld route will trigger random battles drawn from configurable enemy pools.

## Step 1: The Encounter Pool Entry

Each entry in the encounter pool represents one possible enemy group. A "group" is an array of `EnemyData` resources — the enemies the player will face if this entry is selected. The "weight" controls how likely this group is relative to others.

```gdscript
# res://resources/encounter_pool_entry.gd
class_name EncounterPoolEntry
extends Resource

## Defines a weighted enemy group for the encounter system.

@export var enemies: Array[Resource] = []
@export var weight: float = 1.0


static func create(
	p_enemies: Array[Resource],
	p_weight: float = 1.0,
) -> EncounterPoolEntry:
	var entry := EncounterPoolEntry.new()
	entry.enemies = p_enemies
	entry.weight = p_weight
	return entry
```

The `enemies` array uses `Array[Resource]` rather than `Array[EnemyData]` because Godot's typed arrays in exports can be fragile across editor reloads. At runtime, every element will be an `EnemyData` instance.

The static `create()` factory is a convenience for building pools in code — you will use it extensively in area scene scripts rather than creating `.tres` files for every possible enemy combination.

### Designing a Pool

A typical area has 4–8 pool entries with weights that sum to any value — the system normalizes them. Higher weight means more frequent:

```gdscript
# Example pool for a forest area
var pool: Array[EncounterPoolEntry] = [
	EncounterPoolEntry.create([slime],               3.0),  # common: 1 slime
	EncounterPoolEntry.create([slime, slime],         2.0),  # uncommon: 2 slimes
	EncounterPoolEntry.create([wolf],                 2.0),  # uncommon: 1 wolf
	EncounterPoolEntry.create([slime, wolf],          1.5),  # rare: mixed group
	EncounterPoolEntry.create([wolf, wolf],           1.0),  # rare: 2 wolves
	EncounterPoolEntry.create([treant],               0.5),  # very rare: mini-boss
]
```

The total weight here is 10.0. A single slime has a 30% chance, while the treant has a 5% chance. Adjusting weights lets you tune difficulty curves per area without changing any code.

## Step 2: The Encounter System

The `EncounterSystem` is a Node you add as a child of any area scene. It runs in `_physics_process`, tracks the player's movement, converts pixel distance into discrete steps, and rolls for encounters after a minimum step gap.

```gdscript
# res://systems/encounter/encounter_system.gd
class_name EncounterSystem
extends Node

## Step-based random encounter trigger for overworld and dungeon areas.
## Add as a child node of a level scene. Connect to the player's movement
## to count steps, then rolls for encounters based on configurable rates.

signal encounter_triggered(enemy_group: Array[Resource])
signal encounter_warning

@export var encounter_rate: float = 0.1
@export var min_steps_between: int = 5
@export var step_distance: float = 16.0
@export var enabled: bool = true
@export var warning_delay: float = 0.8

## Array of weighted encounter group definitions.
var enemy_pool: Array[EncounterPoolEntry] = []

var _step_counter: int = 0
var _distance_accumulator: float = 0.0
var _player: CharacterBody2D = null
var _previous_position := Vector2.ZERO
var _warning_in_progress: bool = false
var _pending_group: Array[Resource] = []


func _ready() -> void:
	set_physics_process(false)
	_find_player.call_deferred()


func _physics_process(_delta: float) -> void:
	if not enabled or not _player:
		return
	if GameManager.current_state != GameManager.GameState.OVERWORLD:
		return
	if BattleManager.is_in_battle():
		return

	var current_pos := _player.global_position
	var distance := current_pos.distance_to(_previous_position)
	_previous_position = current_pos

	# Ignore tiny jitter and teleportation
	if distance < 0.1 or distance > 100.0:
		return

	_distance_accumulator += distance
	if _distance_accumulator >= step_distance:
		_distance_accumulator -= step_distance
		_on_step()


func setup(pool: Array[EncounterPoolEntry]) -> void:
	enemy_pool = pool


func reset_steps() -> void:
	_step_counter = 0
	_distance_accumulator = 0.0


func _on_step() -> void:
	if _warning_in_progress:
		return
	_step_counter += 1
	if _step_counter < min_steps_between:
		return
	if randf() < encounter_rate:
		_step_counter = 0
		var group := _select_enemy_group()
		if not group.is_empty():
			_pending_group = group
			_warning_in_progress = true
			encounter_warning.emit()
			get_tree().create_timer(warning_delay).timeout.connect(
				_on_warning_timeout, CONNECT_ONE_SHOT,
			)


func _on_warning_timeout() -> void:
	_warning_in_progress = false
	var group := _pending_group
	_pending_group = []
	if not group.is_empty():
		encounter_triggered.emit(group)


func _select_enemy_group() -> Array[Resource]:
	if enemy_pool.is_empty():
		return []

	var total_weight: float = 0.0
	for entry in enemy_pool:
		total_weight += entry.weight

	var roll := randf() * total_weight
	for entry in enemy_pool:
		roll -= entry.weight
		if roll <= 0.0:
			return entry.enemies

	return enemy_pool[-1].enemies


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group(
		"player",
	) as CharacterBody2D
	if _player:
		_previous_position = _player.global_position
		set_physics_process(true)
	else:
		push_warning(
			"EncounterSystem: no player found in group 'player'."
		)
```

That is a lot of code. Let us walk through the key decisions.

### Finding the Player

The system uses `get_tree().get_first_node_in_group("player")` to locate the player node. This avoids hardcoding a node path (which would break if the player lives at a different depth in different scenes). The player scene adds itself to the `"player"` group in its own `_ready()`.

The lookup is deferred with `call_deferred()` because child nodes may not have entered the tree yet when the parent's `_ready()` fires. This is a common Godot pattern — defer anything that depends on siblings or nodes in other subtrees.

Until the player is found, `set_physics_process(false)` keeps the system dormant. No wasted cycles.

### Converting Pixels to Steps

The player moves in pixels. The encounter system thinks in steps. The `step_distance` export (default: 16.0 pixels, one tile width) converts between the two:

```
_distance_accumulator += distance_moved_this_frame
if _distance_accumulator >= step_distance:
    _distance_accumulator -= step_distance
    _on_step()
```

This is accumulator-based, not threshold-based. If the player moves 20 pixels in one frame (overshooting the 16-pixel threshold), the leftover 4 pixels carry over to the next frame. No steps are lost.

The distance filter (`< 0.1` and `> 100.0`) handles two edge cases:
- **Jitter** — sub-pixel floating point noise when the player is stationary
- **Teleportation** — scene transitions or spawn point placement that would otherwise count as hundreds of steps

### The Minimum Step Gap

Without a minimum gap, the player could trigger an encounter on their very first step after entering an area (or immediately after a battle ends). This feels punishing. The `min_steps_between` export (default: 5) guarantees a grace period.

The step counter resets to zero after each encounter, so the player always gets at least 5 safe steps before the next roll begins. This is the same approach Final Fantasy uses — the counter resets after every battle.

### The Probability Roll

After the minimum gap, each step has a flat `encounter_rate` (default: 0.1 = 10%) chance of triggering a battle. This is a geometric distribution — the expected number of steps between encounters is `1 / encounter_rate + min_steps_between`.

With the defaults (rate=0.1, min=5), the expected encounter interval is 15 steps (5 guaranteed + 10 average from the rolls). You can tune these per area: a safe road might use rate=0.05 and min=10, while a dangerous dungeon might use rate=0.15 and min=3.

### The Warning Delay

When an encounter triggers, the system does not immediately start combat. Instead:

1. `encounter_warning` signal fires — the scene can play a visual flash or audio sting
2. A timer waits for `warning_delay` seconds (default: 0.8)
3. `encounter_triggered` signal fires with the selected enemy group

This delay gives the player a brief "oh no" moment before the screen transitions. It also prevents encounters from triggering during the fade animation — the flag `_warning_in_progress` blocks additional rolls.

### Weighted Random Selection

The `_select_enemy_group()` method implements a standard weighted random algorithm:

1. Sum all weights in the pool
2. Roll a random value between 0 and the total weight
3. Walk through entries, subtracting each weight from the roll
4. When the roll hits zero or below, return that entry's enemy group

```
Pool:  [slime: 3.0] [wolf: 2.0] [treant: 0.5]
Total: 5.5
Roll:  3.7

3.7 - 3.0 = 0.7  (slime: skip)
0.7 - 2.0 = -1.3 (wolf: MATCH — return wolf group)
```

This algorithm is `O(n)` where `n` is the pool size — perfectly fine for pools of 4–8 entries. The fallback `return enemy_pool[-1].enemies` handles floating-point edge cases where the roll never quite reaches zero.

### State Guards

Three guards in `_physics_process` prevent encounters from triggering at the wrong time:

```gdscript
if GameManager.current_state != GameManager.GameState.OVERWORLD:
    return
if BattleManager.is_in_battle():
    return
```

- **Not in OVERWORLD** — encounters should not trigger during dialogue, cutscenes, menus, or battles. Only when the player is freely exploring.
- **In battle** — double-check against `BattleManager` in case the state machine has a delayed transition.

The `enabled` flag provides a scene-level override. Disable it during story sequences or in safe zones.

## Step 3: Building a Pool in an Area Scene

Each area scene builds its encounter pool in a separate module file. This keeps the pool configuration testable without instantiating the full scene:

```gdscript
# res://scenes/dark_cave/dark_cave_encounters.gd
class_name DarkCaveEncounters
extends RefCounted

## Builds the weighted encounter pool for the Dark Cave area.


static func build_pool(
	bat: Resource,
	spider: Resource,
	golem: Resource,
) -> Array[EncounterPoolEntry]:
	var pool: Array[EncounterPoolEntry] = []

	if bat:
		pool.append(EncounterPoolEntry.create([bat], 3.0))
	if bat and spider:
		pool.append(EncounterPoolEntry.create([bat, spider], 2.0))
	if spider:
		pool.append(EncounterPoolEntry.create([spider, spider], 1.5))
	if golem:
		pool.append(EncounterPoolEntry.create([golem], 0.5))

	return pool
```

Each enemy resource is passed in as a parameter rather than loaded inside the function. This makes the module a pure data builder — no file system dependencies, no null-pointer surprises during tests.

The null checks (`if bat:`, `if bat and spider:`) handle missing enemy resources gracefully. If an enemy `.tres` file has not been created yet, the pool simply excludes groups that use it.

## Step 4: Wiring It All Together

In the area scene's `_ready()`, load the enemy data, build the pool, configure the encounter system, and connect its signals:

```gdscript
# res://scenes/dark_cave/dark_cave.gd
extends Node2D

const Enc = preload("dark_cave_encounters.gd")

const BAT_PATH: String = "res://data/enemies/cave_bat.tres"
const SPIDER_PATH: String = "res://data/enemies/cave_spider.tres"
const GOLEM_PATH: String = "res://data/enemies/stone_golem.tres"

@onready var _encounter_system: EncounterSystem = $EncounterSystem


func _ready() -> void:
	# ... tilemap setup, spawn points, triggers ...

	# Build encounter pool
	var pool := Enc.build_pool(
		load(BAT_PATH) as Resource,
		load(SPIDER_PATH) as Resource,
		load(GOLEM_PATH) as Resource,
	)
	_encounter_system.setup(pool)
	_encounter_system.encounter_triggered.connect(
		_on_encounter_triggered,
	)
	_encounter_system.encounter_warning.connect(
		_on_encounter_warning,
	)


func _on_encounter_warning() -> void:
	# Optional: play a warning sound, flash the screen
	pass


func _on_encounter_triggered(
	enemy_group: Array[Resource],
) -> void:
	BattleManager.start_battle(enemy_group, true)
```

The `true` argument to `start_battle()` means the player can attempt to flee. Pass `false` for boss encounters or story-driven forced battles.

### The Scene Tree

```
DarkCave (Node2D)
  Ground (TileMapLayer)
  Objects (TileMapLayer)
  Entities (Node2D)
    Player (CharacterBody2D)
    SpawnFromEntrance (Marker2D)
  Triggers (Node2D)
    ExitToOverworld (Area2D)
  EncounterSystem              ← our new node
```

The `EncounterSystem` is a direct child of the scene root. It has no visual representation — it is pure logic. In scenes that should not have encounters (towns, safe zones), simply omit the node.

## Step 5: Disabling Encounters During Events

Story events, boss cutscenes, and NPC dialogue should suppress random encounters. The `EncounterSystem.enabled` flag handles this:

```gdscript
# In an event script — disable encounters during the sequence
func trigger() -> void:
	var encounter_sys := get_node_or_null(
		"../EncounterSystem",
	) as EncounterSystem
	if encounter_sys:
		encounter_sys.enabled = false

	# ... run dialogue, cutscene, etc. ...

	if encounter_sys:
		encounter_sys.enabled = true
		encounter_sys.reset_steps()  # grace period after event
```

Calling `reset_steps()` after re-enabling gives the player a fresh minimum step gap. Without this, an encounter could trigger on the very first step after a cutscene ends — jarring and unfair.

The state guard (`GameManager.current_state != OVERWORLD`) already handles most cases, since cutscenes push the `CUTSCENE` state. The explicit `enabled` flag is a belt-and-suspenders safety net for edge cases where the state transitions might lag.

## How It Connects

The encounter system bridges exploration and combat:

```
Player moves → EncounterSystem._physics_process()
            → accumulates distance → counts steps
            → rolls probability → selects enemy group
            → encounter_triggered signal
            → area scene calls BattleManager.start_battle()
            → GameManager pushes BATTLE state
            → BattleScene loads, battle plays out
            → BattleManager.battle_ended signal
            → GameManager pops back to OVERWORLD
            → EncounterSystem resumes counting
```

**Dependencies:**
- `GameManager` — state checks (OVERWORLD guard)
- `BattleManager` — `start_battle()` and `is_in_battle()`
- `EncounterPoolEntry` — weighted enemy group data
- `EnemyData` — individual enemy definitions (Chapter 6)
- Player node must be in the `"player"` group

**No dependencies on:**
- Specific area scenes — the system is scene-agnostic
- Battle logic — it only triggers battles, never manages them
- UI — the warning signal lets each scene decide what visual feedback to show

## Common Mistakes

**Rolling on every step with no minimum gap.** This creates frustrating back-to-back encounters. The `min_steps_between` parameter exists specifically to prevent this. Five steps is a reasonable minimum — enough to feel like progress between fights.

**Hardcoding the player node path.** Using `$Entities/Player` works until someone reorganizes the scene tree. The group-based lookup (`get_first_node_in_group("player")`) is resilient to structural changes and works identically across all area scenes.

**Forgetting to reset steps after battle.** The step counter resets inside `_on_step()` when an encounter fires, so this is handled automatically. But if you manually disable and re-enable encounters, call `reset_steps()` to prevent immediate re-triggers.

**Loading enemy resources inside the pool builder.** This couples the builder to the file system and makes it untestable. Pass loaded resources as parameters and let the area scene handle loading. If a resource fails to load, the builder gracefully excludes it.

**Triggering encounters during scene transitions.** The `GameManager.current_state` guard handles this, but only if your scene transition properly pushes a non-OVERWORLD state. Make sure `GameManager.change_scene()` pushes a transition state before the fade begins.

## What is Next

The encounter system triggers battles with enemy groups, but the player has no way to prepare for those battles. Chapter 14 builds the `InventoryManager` and `EquipmentManager` — systems for collecting items, equipping gear, and applying stat bonuses that affect combat performance.

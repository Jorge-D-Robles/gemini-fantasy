# Chapter 15 — Quests and Events

In web applications, you manage user flows: onboarding sequences, multi-step forms, feature flags that gate access to premium content. A JRPG has the same patterns under different names. **Quests** are multi-step flows with objectives and completion criteria. **Event flags** are feature flags that gate story content. **Events** are scripted sequences that modify game state when triggered.

This chapter builds three systems: `QuestManager` for tracking objectives, `EventFlags` for boolean state gates, and the standard event pattern for scripted story sequences.

## What We Are Building

- **QuestData** — a Resource defining a quest's objectives, rewards, and prerequisites
- **QuestManager** — an autoload that tracks quest acceptance, objective progress, and completion
- **EventFlags** — an autoload that stores boolean flags for one-time story gates
- **The standard event pattern** — a Node-based script for cutscenes and recruitment sequences
- **Flag-reactive NPC dialogue** — NPCs that change their lines based on story progress

## Step 1: The QuestData Resource

Each quest is defined by a Resource that describes what the player needs to do, what they get for doing it, and what must be true before they can accept it:

```gdscript
# res://resources/quest_data.gd
class_name QuestData
extends Resource

## Defines a quest's objectives, rewards, and prerequisites.

enum QuestType {
	MAIN,
	SIDE,
	CHARACTER,
	BOUNTY,
	COLLECTION,
}

@export_group("Identity")
@export var id: StringName = &""
@export var title: String = ""
@export_multiline var description: String = ""

@export_group("Objectives")
@export var objectives: Array[String] = []

@export_group("Rewards")
@export var reward_gold: int = 0
@export var reward_exp: int = 0
@export var reward_item_ids: Array[StringName] = []

@export_group("Type")
@export var quest_type: QuestType = QuestType.MAIN

@export_group("Prerequisites")
@export var prerequisites: Array[String] = []
```

### Design Decisions

**Objectives are strings, not structured data.** Each objective is a human-readable description: `"Defeat 3 Memory Blooms"`, `"Speak to the Elder"`, `"Find the Crystal Fragment"`. The quest system tracks completion per objective index — it does not parse the text. This is intentional: the text is for the player's journal UI, while completion is triggered explicitly by game code.

An alternative design uses structured objectives with `type`, `target_id`, and `count` fields. This enables automatic progress tracking (the system counts kills automatically), but adds complexity for objectives like "reach location X" or "make a dialogue choice." The string-based approach handles all objective types uniformly and keeps the Resource class simple.

**Prerequisites are event flag names.** Each prerequisite is a string that must exist in `EventFlags` for the quest to become available. This creates a dependency graph: completing one quest sets flags that unlock others. The same flags also gate story events and NPC dialogue, creating a unified progression system.

**Rewards are declarative.** Gold, XP, and item IDs are stored on the quest data. The `QuestManager` does not apply rewards automatically — the code that completes the quest reads the reward fields and calls `InventoryManager.add_gold()`, `InventoryManager.add_item()`, etc. This separation keeps the quest system decoupled from the inventory and progression systems.

### Creating Quest Data Files

```
# res://data/quests/crystal_hunt.tres
[gd_resource type="Resource" script_class="QuestData" ...]

[resource]
script = ExtResource("...")
id = &"crystal_hunt"
title = "Crystal Hunt"
description = "The Elder needs crystal fragments from the ruins."
objectives = ["Find 3 Crystal Fragments", "Return to the Elder"]
reward_gold = 200
reward_exp = 50
reward_item_ids = [&"crystal_pendant"]
quest_type = 1
prerequisites = ["lyra_discovered"]
```

## Step 2: The QuestManager

The `QuestManager` autoload tracks which quests have been accepted, their objective completion status, and their final state (completed or failed):

```gdscript
# res://autoloads/quest_manager.gd
extends Node

## Tracks quest acceptance, objective progress, and completion state.

signal quest_accepted(quest_id: StringName)
signal quest_progressed(quest_id: StringName, objective_index: int)
signal quest_completed(quest_id: StringName)
signal quest_failed(quest_id: StringName)

enum State {
	ACTIVE,
	COMPLETED,
	FAILED,
}

## Stored QuestData resources keyed by id.
var _quest_data: Dictionary = {}

## Objective completion arrays keyed by quest id.
var _objectives: Dictionary = {}

## Quest state keyed by quest id.
var _states: Dictionary = {}

## Callable that checks event flags for prerequisites.
var _flag_checker: Callable = Callable()


func _ready() -> void:
	var flags := get_node_or_null("/root/EventFlags")
	if flags:
		_flag_checker = flags.has_flag
```

The manager stores three parallel dictionaries keyed by quest ID:
- `_quest_data` — the original QuestData resource (for displaying title, description, rewards)
- `_objectives` — an `Array[bool]` tracking which objectives are complete
- `_states` — the current `State` enum value

### Accepting a Quest

```gdscript
func accept_quest(quest: Resource) -> void:
	if quest == null or quest.id == &"":
		return
	if _states.has(quest.id):
		return
	_quest_data[quest.id] = quest
	var obj_count: int = quest.objectives.size()
	var completion: Array[bool] = []
	completion.resize(obj_count)
	completion.fill(false)
	_objectives[quest.id] = completion
	_states[quest.id] = State.ACTIVE
	quest_accepted.emit(quest.id)
```

The guard `if _states.has(quest.id): return` prevents accepting the same quest twice. Once a quest enters any state (active, completed, or failed), it cannot be re-accepted. This is a one-way state machine: there is no "reset" operation.

The `completion` array is pre-sized to match the number of objectives and filled with `false`. Each index corresponds to one objective string in the QuestData.

### Completing Objectives

```gdscript
func complete_objective(
	quest_id: StringName,
	objective_index: int,
) -> void:
	if not _states.has(quest_id):
		return
	if _states[quest_id] != State.ACTIVE:
		return
	var objectives: Array = _objectives[quest_id]
	if objective_index < 0 or objective_index >= objectives.size():
		return
	if objectives[objective_index]:
		return
	objectives[objective_index] = true
	quest_progressed.emit(quest_id, objective_index)

	# Auto-complete when all objectives are done
	var all_done := true
	for done: bool in objectives:
		if not done:
			all_done = false
			break
	if all_done:
		_states[quest_id] = State.COMPLETED
		quest_completed.emit(quest_id)
```

This is the key method. Game code calls it when the player achieves something: killing a specific enemy, reaching a location, talking to an NPC. The quest system checks if that action satisfies an objective, marks it complete, and auto-completes the quest when all objectives are done.

The auto-completion check runs after every objective update. In Angular terms, this is like a computed property that derives its value from the underlying state — you never need to manually call "complete quest."

### Checking Prerequisites

```gdscript
func can_accept_quest(quest: Resource) -> bool:
	if quest == null:
		return false
	if quest.prerequisites.is_empty():
		return true
	if not _flag_checker.is_valid():
		return false
	for flag: String in quest.prerequisites:
		if not _flag_checker.call(flag):
			return false
	return true
```

The `_flag_checker` callable is wired to `EventFlags.has_flag` in `_ready()`. This indirect reference avoids a hard dependency on EventFlags — the quest manager does not `get_node("/root/EventFlags")` directly. If EventFlags is not registered, the callable stays invalid and all prerequisite checks return `false` (safe default).

NPCs that offer quests check `can_accept_quest()` before showing the quest-offer dialogue. If prerequisites are not met, they show their default dialogue instead.

### Query Methods

```gdscript
func is_quest_active(quest_id: StringName) -> bool:
	return _states.get(quest_id, -1) == State.ACTIVE


func is_quest_completed(quest_id: StringName) -> bool:
	return _states.get(quest_id, -1) == State.COMPLETED


func get_objective_status(
	quest_id: StringName,
) -> Array:
	if not _objectives.has(quest_id):
		return []
	return _objectives[quest_id]


func get_active_quests() -> Array[StringName]:
	var result: Array[StringName] = []
	for qid: StringName in _states:
		if _states[qid] == State.ACTIVE:
			result.append(qid)
	return result
```

These are read-only accessors that UI and game logic use to check quest state. The journal screen calls `get_active_quests()` to list current quests. Dialogue scripts call `is_quest_completed()` to gate follow-up conversations.

## Step 3: EventFlags

Event flags are the simplest system in the game — and one of the most important. They are boolean values keyed by string names that track one-time story events:

```gdscript
# res://events/event_flags.gd
extends Node

## Global event flag tracker. Prevents story events from replaying.

var _flags: Dictionary = {}


func set_flag(flag_name: String) -> void:
	_flags[flag_name] = true


func has_flag(flag_name: String) -> bool:
	return _flags.has(flag_name)


func clear_flag(flag_name: String) -> void:
	_flags.erase(flag_name)


func get_all_flags() -> Dictionary:
	return _flags.duplicate()


func load_flags(data: Dictionary) -> void:
	_flags = data.duplicate()
```

Register this as an autoload named `EventFlags` in Project Settings.

### Why Flags, Not a Database

You might wonder why this is not a more sophisticated system — a typed enum, a relational store, a state machine. The answer is that boolean flags are the lingua franca of JRPG progression. Every system in the game speaks flags:

- **Events** check `has_flag()` before triggering and call `set_flag()` after completing
- **Quest prerequisites** are lists of flag names
- **NPC dialogue** branches on flag state
- **Area transitions** may gate on flags (e.g., "bridge is out until `bridge_repaired` flag is set")
- **Save/load** serializes the entire flag dictionary to JSON

A plain Dictionary with string keys and boolean values is trivially serializable, trivially debuggable (print the dictionary), and trivially extensible (add a new flag by using a new string). There is no schema to migrate, no enum to keep in sync, no database to query.

### Flag Naming Convention

Use descriptive, past-tense names that describe what happened:

```
lyra_discovered          — Kael found Lyra in the ruins
garrick_recruited        — Garrick joined the party
iris_recruited           — Iris joined the party
boss_defeated            — The Last Gardener was beaten
bridge_repaired          — The broken bridge was fixed
crystal_hunt_accepted    — The crystal hunt quest was started
```

This convention makes flag checks read like English: `if EventFlags.has_flag("garrick_recruited")` — "if Garrick has been recruited."

## Step 4: The Standard Event Pattern

Story events — cutscenes, recruitment sequences, scripted battles — follow a consistent pattern. Each event is a Node script attached to the scene where it fires:

```gdscript
# res://events/my_event.gd
class_name MyEvent
extends Node

signal sequence_completed

const FLAG_NAME: String = "my_event_flag"


func trigger() -> void:
	# 1. Guard — do not replay
	if EventFlags.has_flag(FLAG_NAME):
		return

	# 2. Set flag immediately
	EventFlags.set_flag(FLAG_NAME)

	# 3. Push cutscene state (disables player input)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# 4. Build and play dialogue
	var lines: Array[DialogueLine] = [
		DialogueLine.create("Speaker", "Dialogue line."),
		DialogueLine.create("Speaker", "Another line."),
	]
	DialogueManager.start_dialogue(lines)
	await DialogueManager.dialogue_ended

	# 5. Apply side effects
	# (add party member, give item, set more flags, etc.)

	# 6. Restore state
	GameManager.pop_state()

	# 7. Notify the parent scene
	sequence_completed.emit()
```

Every event follows these seven steps. Let us examine why each one matters.

### Step 1: The Flag Guard

```gdscript
if EventFlags.has_flag(FLAG_NAME):
    return
```

This is the most important line. Without it, the event replays every time the player enters the trigger zone. Set the flag, and the event becomes a one-shot — it fires once, ever, across the entire playthrough.

### Step 2: Set Flag Immediately

```gdscript
EventFlags.set_flag(FLAG_NAME)
```

Set the flag *before* the dialogue, not after. This prevents a race condition: if the player closes the game during the dialogue (ALT+F4, phone lock), the event has already been marked as seen. On reload, it will not replay, but the side effects (party add, etc.) may not have occurred. This is a trade-off — replaying is worse than missing a side effect, because replaying breaks the narrative flow.

For events where missing the side effect would be game-breaking (e.g., a character joining the party), add a fallback check:

```gdscript
# In the area scene's _ready(), check if the event flag is set
# but the character is not in the party
if EventFlags.has_flag("garrick_recruited"):
	if not PartyManager.has_character(&"garrick"):
		var data := load("res://data/characters/garrick.tres")
		if data:
			PartyManager.add_character(data)
```

### Step 3: Push Cutscene State

```gdscript
GameManager.push_state(GameManager.GameState.CUTSCENE)
```

This disables player movement and input. Without it, the player could walk away during the dialogue, trigger other events, or enter a transition zone mid-cutscene. The state stack (from Chapter 5) ensures that popping `CUTSCENE` returns to whatever state was active before — usually `OVERWORLD`.

### Step 4: Dialogue with Await

```gdscript
DialogueManager.start_dialogue(lines)
await DialogueManager.dialogue_ended
```

The `await` keyword pauses execution of this function until the `dialogue_ended` signal fires. This is equivalent to an `async/await` call in JavaScript — the function yields control to the engine, and resumes when the dialogue completes.

The `DialogueLine.create()` factory (from Chapter 7) builds each line with a speaker name and text. For lines with character portraits:

```gdscript
DialogueLine.create(
	"Garrick",
	"I will hold the line.",
	preload("res://assets/portraits/garrick_portrait.png"),
)
```

### Step 5: Side Effects

This is where events diverge from the template. Common side effects:

```gdscript
# Add a character to the party
var character := load("res://data/characters/iris.tres")
if character:
	PartyManager.add_character(character)

# Give the player items
InventoryManager.add_item(&"crystal_fragment", 3)
InventoryManager.add_gold(500)

# Set additional flags for downstream events
EventFlags.set_flag("chapter_2_started")

# Accept a quest automatically
var quest := load("res://data/quests/crystal_hunt.tres")
if quest:
	QuestManager.accept_quest(quest)
```

### Step 6: Restore State

```gdscript
GameManager.pop_state()
```

Pops the `CUTSCENE` state, returning to `OVERWORLD`. The player regains control.

### Step 7: Notify Parent Scene

```gdscript
sequence_completed.emit()
```

The parent scene connects to this signal to perform post-event cleanup: disabling the trigger zone, changing NPC positions, enabling new exits.

## Step 5: A Complete Recruitment Event

Here is a full example — a character recruitment that includes dialogue, a forced battle, and post-battle dialogue:

```gdscript
# res://events/iris_recruitment.gd
class_name IrisRecruitment
extends Node

signal sequence_completed

const FLAG_NAME: String = "iris_recruited"
const IRIS_PATH: String = "res://data/characters/iris.tres"
const ENEMY_PATH: String = "res://data/enemies/ash_stalker.tres"


func trigger() -> void:
	if EventFlags.has_flag(FLAG_NAME):
		return

	EventFlags.set_flag(FLAG_NAME)
	GameManager.push_state(GameManager.GameState.CUTSCENE)

	# Pre-battle dialogue
	var intro_lines: Array[DialogueLine] = [
		DialogueLine.create(
			"Iris",
			"You should not be here. This area is—",
		),
		DialogueLine.create(
			"Kael",
			"We are looking for crystal fragments.",
		),
		DialogueLine.create(
			"Iris",
			"Then you are fools. But brave fools."
			+ " Something is coming.",
		),
	]
	DialogueManager.start_dialogue(intro_lines)
	await DialogueManager.dialogue_ended

	# Add Iris to party BEFORE the battle so she participates
	var iris_data := load(IRIS_PATH) as CharacterData
	if iris_data:
		PartyManager.add_character(iris_data)

	# Start forced battle
	var enemy := load(ENEMY_PATH) as Resource
	if enemy:
		GameManager.pop_state()
		BattleManager.start_battle([enemy], false)
		var victory: bool = await BattleManager.battle_ended

		GameManager.push_state(GameManager.GameState.CUTSCENE)

		if victory:
			var post_lines: Array[DialogueLine] = [
				DialogueLine.create(
					"Iris",
					"You handle yourselves well."
					+ " I will travel with you.",
				),
			]
			DialogueManager.start_dialogue(post_lines)
			await DialogueManager.dialogue_ended
		else:
			# On defeat, clear the flag so the event retriggers
			EventFlags.clear_flag(FLAG_NAME)
	else:
		push_warning("IrisRecruitment: enemy not found")

	GameManager.pop_state()
	sequence_completed.emit()
```

Key details:
- Iris joins the party *before* the battle so she appears as a combatant
- The battle is not escapable (`false` argument to `start_battle()`)
- On defeat, `clear_flag()` allows the event to retrigger on the next visit
- The CUTSCENE state is popped before battle (battle pushes its own BATTLE state) and re-pushed after

## Step 6: Flag-Reactive NPC Dialogue

NPCs should respond to story progress. The Elder who gave you the quest should acknowledge completion. The guard who warned about the bridge should step aside after it is repaired. This is implemented by checking flags in the NPC's dialogue handler:

```gdscript
# In an NPC's interaction handler
func _get_dialogue_lines() -> Array[DialogueLine]:
	if EventFlags.has_flag("crystal_hunt_completed"):
		return [
			DialogueLine.create(
				"Elder",
				"Thank you for the crystals."
				+ " The village is in your debt.",
			),
		]
	elif QuestManager.is_quest_active(&"crystal_hunt"):
		var status := QuestManager.get_objective_status(
			&"crystal_hunt",
		)
		if status.size() > 0 and status[0]:
			return [
				DialogueLine.create(
					"Elder",
					"You found the fragments?"
					+ " Wonderful. Come, let me see them.",
				),
			]
		else:
			return [
				DialogueLine.create(
					"Elder",
					"The crystal fragments should be"
					+ " somewhere in the ruins to the east.",
				),
			]
	elif EventFlags.has_flag("lyra_discovered"):
		return [
			DialogueLine.create(
				"Elder",
				"I heard you found something unusual"
				+ " in the ruins. Can you help us with"
				+ " a task?",
			),
		]
	else:
		return [
			DialogueLine.create(
				"Elder",
				"Welcome to our village, traveler.",
			),
		]
```

The flag checks cascade from most specific to least specific: completed quest → active quest with progress → active quest without progress → quest prerequisite met → default. This creates the illusion of a living world that responds to player actions.

### Organizing Dialogue by Flag State

For scenes with many NPCs and many flag states, extract the dialogue into a separate module:

```gdscript
# res://scenes/village/village_dialogue.gd
class_name VillageDialogue
extends RefCounted

## All NPC dialogue for the village, organized by story state.


static func get_elder_lines() -> Array[DialogueLine]:
	if EventFlags.has_flag("crystal_hunt_completed"):
		return _elder_post_quest()
	elif EventFlags.has_flag("lyra_discovered"):
		return _elder_quest_offer()
	else:
		return _elder_default()


static func _elder_default() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Elder",
			"Welcome to our village, traveler.",
		),
	]


static func _elder_quest_offer() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Elder",
			"I heard you found something unusual"
			+ " in the ruins. Can you help us?",
		),
	]


static func _elder_post_quest() -> Array[DialogueLine]:
	return [
		DialogueLine.create(
			"Elder",
			"The village is peaceful again."
			+ " Thank you.",
		),
	]
```

This keeps the scene script focused on wiring and the dialogue module focused on content. The dialogue module is also testable without instantiating the full scene — you can verify that the correct lines are returned for each flag configuration.

## Step 7: Connecting Quests to Game Events

Quests do not track progress automatically. Game code must explicitly notify the quest manager when something relevant happens. Use the `EventBus` signals (from Chapter 7) to centralize this:

```gdscript
# In a quest progress tracker (could be a child of the area scene)
func _ready() -> void:
	EventBus.enemy_defeated.connect(_on_enemy_defeated)
	EventBus.npc_interaction_ended.connect(
		_on_npc_interaction,
	)


func _on_enemy_defeated(enemy_id: StringName) -> void:
	# Crystal Hunt objective 0: "Defeat 3 Memory Blooms"
	if enemy_id == &"memory_bloom":
		if QuestManager.is_quest_active(&"crystal_hunt"):
			# You need external tracking for counts
			_bloom_count += 1
			if _bloom_count >= 3:
				QuestManager.complete_objective(
					&"crystal_hunt", 0,
				)


func _on_npc_interaction(npc_name: String) -> void:
	if npc_name == "Elder":
		if QuestManager.is_quest_active(&"crystal_hunt"):
			var status := QuestManager.get_objective_status(
				&"crystal_hunt",
			)
			if status.size() > 1 and status[0] and not status[1]:
				QuestManager.complete_objective(
					&"crystal_hunt", 1,
				)
```

The kill counter (`_bloom_count`) is maintained outside the quest system. The quest system only knows about binary objective completion — it does not count anything. For quests with count-based objectives, the tracking logic sits in the area scene or a dedicated tracker node.

This is intentional. Count tracking logic varies wildly between quest types (kill X enemies, collect X items, visit X locations). Baking it into the quest system would either over-constrain the types of quests you can create or bloat the system with configuration for every possible tracking pattern.

## Step 8: Serialization

### QuestManager Serialization

```gdscript
func serialize() -> Dictionary:
	var active := {}
	var completed: Array[String] = []
	var failed: Array[String] = []
	for qid: StringName in _states:
		var state: int = _states[qid]
		match state:
			State.ACTIVE:
				var obj_bools: Array = _objectives.get(qid, [])
				active[String(qid)] = {
					"objectives": obj_bools,
				}
			State.COMPLETED:
				completed.append(String(qid))
			State.FAILED:
				failed.append(String(qid))
	return {
		"active": active,
		"completed": completed,
		"failed": failed,
	}
```

Active quests save their objective arrays so partially-completed quests resume correctly. Completed and failed quests only need their IDs.

### EventFlags Serialization

Flags are already a Dictionary — `get_all_flags()` returns a copy that `JSON.stringify()` handles directly. Loading is equally simple: `load_flags(data)` replaces the internal dictionary.

## How It Connects

```
EventFlags (autoload)
  ├── set_flag / has_flag ← event scripts, scene scripts
  ├── prerequisites check ← QuestManager.can_accept_quest()
  ├── dialogue branching ← NPC interaction handlers
  └── get_all_flags() → SaveManager serialization

QuestManager (autoload)
  ├── accept_quest() ← NPC dialogue, event scripts
  ├── complete_objective() ← EventBus listeners, scene scripts
  ├── quest signals → journal UI, HUD notifications
  └── serialize() → SaveManager

Event Scripts (per-scene nodes)
  ├── EventFlags — flag guard + set
  ├── GameManager — state push/pop
  ├── DialogueManager — cutscene dialogue
  ├── PartyManager — character recruitment
  ├── BattleManager — forced battles
  ├── InventoryManager — item/gold rewards
  └── QuestManager — quest acceptance
```

The event flag system is the glue that connects everything. A single flag like `"garrick_recruited"` is:
- Set by the recruitment event
- Checked by NPC dialogue to change their lines
- Listed as a prerequisite for downstream quests
- Saved and restored by the save system
- Read by area scenes to gate content

## Common Mistakes

**Setting flags after dialogue instead of before.** If the player quits during the dialogue, the flag is not set, and the event replays on next load. Always set the flag before any async operation.

**Not handling quest prerequisite failures.** If `can_accept_quest()` returns `false` but the NPC still shows quest-offer dialogue, the player is confused. Always check prerequisites before showing quest-related dialogue.

**Coupling quest completion to objective completion.** The `complete_objective()` method auto-completes the quest when all objectives are done. Do not also call a separate `complete_quest()` method — this leads to double-completion signals and confusing state.

**Forgetting to pop the cutscene state.** If an event pushes CUTSCENE and encounters an error before popping it, the player is permanently stuck. Use early returns carefully — make sure every code path that can exit the function also pops the state.

**Hardcoding flag names across multiple files.** Use constants:

```gdscript
const FLAG_NAME: String = "garrick_recruited"
```

When the flag name is defined in one place, renaming it does not require a project-wide search-and-replace. Other scripts that check the same flag should reference this constant or define their own copy — the string must match exactly.

**Over-engineering the quest system.** It is tempting to build automatic kill counters, location trackers, and item collection monitors. In practice, each quest has unique completion logic. A simple `complete_objective(quest_id, index)` call in the right place is more maintainable than a generic tracking framework.

## What is Next

Quests track progress, flags gate content, and events tell the story. But when the player closes the game, all of this state evaporates. Chapter 16 builds the `SaveManager` — a system that captures every manager's state into a JSON file and restores it on load, so the player's progress persists across sessions.

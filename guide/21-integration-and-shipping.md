# Chapter 21: Integration and Shipping

You have built every system in isolation — movement, battles, dialogue, inventory, quests, save/load, audio, UI. Each one works. Each one has tests. Now comes the part that web developers know well: wiring everything together into a working application and shipping it.

This chapter walks through the full game loop from title screen to credits, explains how autoloads depend on each other, covers the scene module pattern for keeping area scripts manageable, identifies common integration bugs, and gets your game exported to a playable build.

## The Signal Dependency Map

Your autoload singletons are not independent services. They form a dependency graph connected by signals and direct calls. Understanding this graph is essential for debugging integration issues.

```
GameManager
├── scene_changed ──────────► EventBus._on_scene_changed()
├── game_state_changed ────► (any listener)
└── transition signals ────► (UI fade effects)

EventBus
├── enemy_defeated ────────► QuestManager (objective tracking)
├── item_acquired ─────────► QuestManager (collection objectives)
├── npc_interaction_ended ─► QuestManager (talk objectives)
├── interactable_used ─────► QuestManager (interact objectives)
└── area_entered ──────────► (analytics, tutorials)

BattleManager
├── battle_started ────────► (UI, encounter system)
├── battle_ended ──────────► BondManager.award_battle_bond_points()
└── calls ─────────────────► GameManager.push_state/pop_state
                             PartyManager.get_active_party()
                             AudioManager.push_bgm/play_bgm

DialogueManager
├── dialogue_started ──────► (UI: show dialogue box)
├── dialogue_ended ────────► (UI: hide dialogue box)
├── line_displayed ────────► (UI: render text + portrait)
├── choice_presented ──────► (UI: show choice buttons)
└── calls ─────────────────► GameManager.push_state/pop_state

SaveManager
└── calls ─────────────────► PartyManager.serialize/deserialize
                             InventoryManager.serialize/deserialize
                             EquipmentManager.serialize/deserialize
                             QuestManager.serialize/deserialize
                             EventFlags.serialize/deserialize
                             ReputationManager.serialize/deserialize
                             BondManager.serialize/deserialize

InventoryManager
└── add_item ──────────────► EventBus.emit_item_acquired()
```

The key insight: **GameManager is the root.** Everything flows from game state. When GameManager transitions to BATTLE state, the overworld freezes, the battle scene loads, and the UI switches to battle mode. When it pops back to OVERWORLD, everything reverses. If GameManager's state stack gets corrupted, the entire game breaks.

## The Full Game Loop

Here is every step of a play session, from launch to quit. Understanding this flow is how you debug "the game works in pieces but breaks when I play it."

### 1. Launch and Title Screen

Godot loads `project.godot`, which specifies the main scene — your title screen. All autoloads initialize in the order they are registered in Project Settings.

```
Godot starts
  └── Autoloads initialize (in registration order):
        GameManager._ready()      # Creates transition overlay
        AudioManager._ready()     # Creates BGM + SFX players
        UILayer._ready()          # Creates HUD, DialogueBox, PauseMenu
        DialogueManager._ready()
        PartyManager._ready()
        BattleManager._ready()
        EquipmentManager._ready()
        InventoryManager._ready()
        QuestManager._ready()
        SaveManager._ready()
        EventBus._ready()         # Connects to GameManager.scene_changed
        BondManager._ready()      # Connects to BattleManager.battle_ended
  └── Main scene loads: TitleScreen
        └── TitleScreen._ready()  # Plays title BGM, shows menu
```

The title screen presents New Game, Continue, and Settings. "Continue" only appears if `SaveManager.has_save()` returns true for any slot.

### 2. New Game: Initialization

When the player selects New Game:

```gdscript
func _on_new_game_pressed() -> void:
	GameManager.change_scene(FIRST_SCENE_PATH, 1.0, "default_spawn")
```

The first scene's `_ready()` initializes the starting party:

```gdscript
func _ready() -> void:
	# If roster is empty, this is a new game — add the protagonist
	if PartyManager.get_active_party().is_empty():
		var kael := load("res://data/characters/kael.tres") as CharacterData
		PartyManager.add_character(kael)
```

GameManager is now in `OVERWORLD` state. The HUD appears. The player can move.

### 3. Overworld Exploration

The player walks around. Each frame:

1. `Player._physics_process()` reads input and calls `move_and_slide()`
2. `EncounterSystem._process()` increments a step counter and checks for random encounters
3. `GameManager._process()` ticks `playtime_seconds`
4. Camera follows the player automatically (child of Player node)

When the player walks into a trigger area:

```gdscript
func _on_exit_to_town_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.is_transitioning():
		return
	GameManager.change_scene(
		"res://scenes/roothollow/roothollow.tscn",
		GameManager.FADE_DURATION,
		"spawn_from_forest",
	)
```

`GameManager.change_scene()` fades to black, unloads the current scene, loads the new one, finds the spawn point by group name, positions the player, and fades back in.

### 4. NPC Interaction

The player faces an NPC and presses the interact button. The Player's `RayCast2D` detects the NPC's `StaticBody2D`:

```
Player presses interact
  └── RayCast2D hits NPC CollisionShape2D
  └── NPC.interact() called
  └── DialogueManager.start_dialogue(lines)
        └── GameManager.push_state(DIALOGUE)
        └── Player input disabled
        └── DialogueBox appears
        └── Player advances through lines
        └── DialogueManager.dialogue_ended emitted
        └── GameManager.pop_state() → back to OVERWORLD
```

### 5. Random Encounter → Battle

EncounterSystem detects enough steps have been taken:

```
EncounterSystem threshold reached
  └── encounter_triggered signal with enemy_group
  └── Scene script calls BattleManager.start_battle(enemy_group)
        └── AudioManager.push_bgm() (save current music)
        └── AudioManager.play_bgm(battle_theme)
        └── GameManager.push_state(BATTLE)
        └── BattleScene instantiated and added to tree
              └── PartyBattlers created from PartyManager.get_active_party()
              └── EnemyBattlers created from enemy_group
              └── TurnQueue initialized
              └── BattleStateMachine starts at PlayerTurn/EnemyTurn
        └── Battle plays out (see Chapters 10-12)
        └── Victory or Defeat
              └── XP/gold awarded
              └── BattleManager.battle_ended.emit(victory)
              └── BondManager receives signal, awards bond points
              └── BattleScene freed
              └── GameManager.pop_state() → back to OVERWORLD
              └── AudioManager.pop_bgm() (restore overworld music)
```

### 6. Quest Progression

Quest objectives complete when EventBus signals fire:

```
Player defeats a Creeping Vine
  └── EventBus.emit_enemy_defeated(&"creeping_vine")
  └── QuestManager listens, checks active quests
        └── Quest "herb_gathering" has objective "Defeat 3 Creeping Vines"
        └── Counter increments
        └── QuestManager.quest_progressed signal
        └── HUD updates objective tracker
```

### 7. Save at Save Point

The player interacts with a save point:

```
Player interacts with SavePoint
  └── Interactable.interact() → SavePointStrategy.execute()
        └── SaveSlotDialog opens
        └── Player selects slot
        └── SaveManager.save_game(
              slot, PartyManager, InventoryManager, EventFlags,
              current_scene_path, player_position,
              EquipmentManager, QuestManager, playtime,
            )
        └── JSON written to user://saves/save_N.json
        └── "Game saved" confirmation
```

### 8. Load from Title Screen

From the title screen or pause menu:

```
Player selects Continue → picks slot
  └── SaveManager.load_save_data(slot) → Dictionary
  └── SaveManager.apply_save_data(data, party, inventory, flags, ...)
        └── InventoryManager reset + repopulated
        └── EventFlags reset + repopulated
        └── PartyManager HP/EE restored
        └── EquipmentManager restored
        └── QuestManager restored
  └── GameManager.change_scene(data["scene_path"])
  └── Player repositioned to data["player_position"]
```

## The Scene Module Pattern

A naive approach puts all scene logic — tilemap setup, NPC dialogue, encounter configuration, quest logic — into a single script file. This quickly becomes unmanageable. A 500-line scene script is hard to read, hard to test, and hard to modify without breaking something.

The solution is to split scene logic into focused module files:

```
scenes/roothollow/
  roothollow.tscn          # Scene file (node hierarchy)
  roothollow.gd            # Main script: _ready(), transitions, event wiring
  roothollow_maps.gd       # Tilemap data: legends, map arrays, tile pickers
  roothollow_dialogue.gd   # NPC dialogue: flag-reactive line generators
  roothollow_quests.gd     # Quest text data and condition checks
  roothollow_shop.gd       # Shop item list computation
  roothollow_zone.gd       # Zone trigger condition computation
```

Each module is a `RefCounted` class with `class_name` and static methods. They have no dependencies on the scene tree, no `@onready` vars, and no signal connections. They take data in and return data out.

The main scene script preloads them as constants:

```gdscript
# roothollow.gd
extends Node2D

const Maps = preload("roothollow_maps.gd")
const Dialogue = preload("roothollow_dialogue.gd")
const Quests = preload("roothollow_quests.gd")
const Shop = preload("roothollow_shop.gd")
```

This pattern has three major benefits:

1. **Testability.** Module files are pure functions. You can test `Dialogue.get_maren_dialogue(flags)` without a scene tree.
2. **Readability.** The main script is a thin orchestration layer. You can read `_ready()` and see the high-level flow without getting lost in dialogue text or tilemap coordinates.
3. **Parallelism.** Different developers (or different sessions) can work on dialogue, maps, and quest logic independently.

### What Goes in Each Module

**`*_map.gd`** — tilemap constants (map arrays, legends, noise parameters), tile picker functions. Zero runtime dependencies.

**`*_dialogue.gd`** — functions that take an `EventFlags` dictionary and return dialogue lines. Handles flag-reactive dialogue where NPCs say different things depending on story progress.

**`*_encounters.gd`** — a `build_pool()` function that takes enemy Resources and returns an `Array[EncounterPoolEntry]`. Called once in `_ready()`.

**Main script (`*.gd`)** — `_ready()` orchestration, signal connections, scene transitions, event triggers. This is the only file that touches the scene tree.

## Common Integration Bugs

These are the bugs you will encounter when your individually-tested systems start talking to each other.

### Signal Connected but Emitter Freed

```gdscript
# Bug: NPC emits interaction_ended, but the NPC was freed during a scene transition
# The connected callback tries to access the freed node → crash
_npc.interaction_ended.connect(_on_npc_finished)
# Later: scene transitions, NPC gets queue_free()'d
# _on_npc_finished fires → accessing _npc properties → null reference
```

**Fix:** Check `is_instance_valid()` at the start of any callback that references a node which might have been freed:

```gdscript
func _on_npc_finished() -> void:
	if not is_instance_valid(_npc):
		return
	# Safe to access _npc here
```

Or use `CONNECT_ONE_SHOT` for callbacks that should fire exactly once.

### Autoload Not Registered

You write `InventoryManager.add_item(&"potion")` in a script, but the game crashes with "Identifier not found." The autoload script exists, but you forgot to register it in **Project > Project Settings > Globals (Autoload)**.

**Fix:** Every autoload must be registered in `project.godot`:

```ini
[autoload]
GameManager="*res://autoloads/game_manager.gd"
AudioManager="*res://autoloads/audio_manager.gd"
PartyManager="*res://autoloads/party_manager.gd"
...
```

The `*` prefix means "load as singleton." Without registration, the script exists but is not accessible by name.

### Resource Path Typo

```gdscript
var enemy := load("res://data/enemies/slime.tres") as EnemyData
# Returns null silently if the path is wrong — no error at this point
# Crash happens later when you try to access enemy.id
```

**Fix:** Always null-check after `load()`:

```gdscript
var enemy := load("res://data/enemies/slime.tres") as EnemyData
if not enemy:
	push_error("Failed to load enemy resource")
	return
```

### State Stack Corruption

```gdscript
# Bug: push_state(DIALOGUE) called, but pop_state() never called
# because an early return skips the cleanup
func _show_dialogue() -> void:
	GameManager.push_state(GameManager.GameState.DIALOGUE)
	if not DialogueManager.start_dialogue(lines):
		return  # BUG: state pushed but never popped
	await DialogueManager.dialogue_ended
	GameManager.pop_state()
```

**Fix:** Pop the state in the early return path:

```gdscript
func _show_dialogue() -> void:
	GameManager.push_state(GameManager.GameState.DIALOGUE)
	if not DialogueManager.start_dialogue(lines):
		GameManager.pop_state()
		return
	await DialogueManager.dialogue_ended
	GameManager.pop_state()
```

### Race Conditions in _ready() Order

Godot calls `_ready()` bottom-up: children before parents. If a child's `_ready()` tries to access a sibling node that has not been `_ready()`'d yet, you get null references.

**Fix:** Use `call_deferred()` for operations that depend on the full tree being initialized:

```gdscript
func _ready() -> void:
	_setup_tilemap()
	_maybe_trigger_event.call_deferred()  # Wait until tree is fully ready
```

## Performance: What Matters

Turn-based JRPGs are not performance-sensitive games. Your battles are menu-driven, your overworld is tile-based, and your target is 60 FPS on modest hardware. That said, there are a few things worth knowing.

### What Actually Matters

**Draw calls.** Each visible sprite, tile layer, and UI element is a draw call. Godot batches these aggressively in the 2D renderer, but hundreds of individual `Sprite2D` nodes in a single scene can slow things down. TileMapLayers are efficient because they batch an entire layer into a single draw call.

**Physics bodies.** Every `StaticBody2D`, `CharacterBody2D`, and `Area2D` participates in the physics step. A scene with 200 collision bodies will be slower than one with 20. Use collision bodies only for things the player can collide with or interact with — not for decorations.

**Node count.** Each node in the scene tree has overhead for `_process()` and `_physics_process()`, even if the functions do nothing. Keep your scene trees lean. A scene with 500 nodes is fine; 5000 is not.

**Memory: loaded Resources.** Every `.tres` file and texture you `load()` stays in memory until nothing references it. This is usually fine for a 2D game, but be aware that loading 500 unique textures simultaneously will use significant memory.

### What Does Not Matter

**GDScript execution speed.** For a turn-based game, GDScript is not your bottleneck. Damage calculations, state machine transitions, and inventory lookups happen once per turn, not once per frame. Do not rewrite game logic in C++ or C# for "performance" — the complexity cost far outweighs the speed gain.

**Premature optimization.** Do not add object pooling for damage number popups, spatial partitioning for tile collision, or lazy loading for resources until you have measured a real problem. Profile first, optimize second.

## The Minimum Viable JRPG

Before you worry about polish, ensure these core features work end-to-end. This is your definition of "playable demo":

1. Player can move through at least two connected scenes
2. Random encounters trigger and resolve (battle → victory → return to overworld)
3. At least 3 party members with unique stats and abilities
4. At least 4 enemy types with basic AI
5. Items can be found, stored, and used in battle
6. Equipment can be changed and affects stats
7. Save at a save point and load from the title screen
8. One complete quest (accept → objectives → complete → reward)
9. BGM plays per area, battle music plays during combat
10. HUD shows party HP, current area, and objective

Everything beyond this list — additional areas, more enemies, side quests, visual polish — is content. Get the core loop working first.

## Exporting Your Game

Godot can export to multiple platforms from a single project. Here is how to create a playable build.

### Export Templates

Before exporting, you need export templates — pre-compiled Godot engine binaries for each platform. Download them from within the editor: **Editor > Manage Export Templates > Download and Install**.

### Creating an Export Preset

Go to **Project > Export** and click **Add** to create a preset for your target platform.

**Desktop (Windows / macOS / Linux):**

```
Platform: Windows Desktop (or macOS, or Linux)
Export Path: builds/game.exe (or .app, or .x86_64)
Runnable: enabled
```

Key settings:
- **Application > Product Name** — your game's display name
- **Application > Icon** — your game icon
- **Resources > Include** — `*.tres, *.tscn, *.gd` (default includes all Resources)
- **Binary Format > Embed PCK** — embeds all game data into the executable (recommended for distribution)

**Web (HTML5):**

```
Platform: Web
Export Path: builds/web/index.html
```

Key settings:
- **HTML > Head Include** — custom HTML for the hosting page
- **Progressive Web App** — enable for offline support
- **Thread Support** — disable if targeting browsers without SharedArrayBuffer

Web exports produce an `.html` file, a `.wasm` binary, a `.pck` data file, and a `.js` loader script. Host all four files on any web server.

### Building

Click **Export Project** for a release build, or **Export PCK/ZIP** for just the data file. For testing, use **Export Project (Debug)** which includes debug symbols and error output.

### Platform-Specific Notes

**Windows:** The default export produces a `.exe` and a `.pck` file. Enable "Embed PCK" to create a single `.exe`. Windows SmartScreen may flag unsigned executables — code signing requires a certificate.

**macOS:** Exports as a `.app` bundle or `.dmg`. Apple's Gatekeeper requires notarization for distribution outside the App Store. For development builds, users can right-click and select "Open" to bypass Gatekeeper.

**Linux:** Exports as a self-contained binary. Mark it as executable: `chmod +x game.x86_64`.

**Web:** The most accessible option for sharing demos. Upload the export files to a web server or hosting service. Performance is slightly lower than native, but perfectly adequate for a turn-based JRPG.

## Scene Script Responsibilities Reference

Every area scene's `_ready()` follows the same pattern. Here is a complete reference for what happens and in what order:

```gdscript
func _ready() -> void:
	# 1. Build the visual world
	_setup_tilemap()
	MapBuilder.create_boundary_walls(self, map_width, map_height)

	# 2. Set the HUD location name
	UILayer.hud.location_name = "Area Name"

	# 3. Start background music
	var bgm := load(SCENE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 1.0)

	# 4. Register spawn points for scene transitions
	$Entities/SpawnFromForest.add_to_group("spawn_from_forest")
	$Entities/SpawnFromTown.add_to_group("spawn_from_town")

	# 5. Connect transition triggers
	$Triggers/ExitToForest.body_entered.connect(_on_exit_entered)

	# 6. Configure encounters (combat areas only)
	var pool := AreaEncounters.build_pool(enemy1, enemy2, ...)
	_encounter_system.setup(pool)

	# 7. Gate story events behind flags
	if EventFlags.has_flag("event_complete"):
		_event_zone.monitoring = false

	# 8. Set up NPC dialogue based on current flags
	_setup_npc_dialogue()

	# 9. Spawn companion followers
	var player_node := get_tree().get_first_node_in_group("player")
	if player_node:
		var controller := CompanionController.new()
		controller.setup(player_node)
		$Entities.add_child(controller)

	# 10. Deferred event triggers
	_maybe_trigger_story_event.call_deferred()
```

## Where To Go From Here

You have a working JRPG. Every system is built, tested, and integrated. The game loop runs from title screen through save/load and back. Now what?

**More content.** The engine supports it — add more scenes, enemies, party members, quests, and dialogue. Content creation is now your bottleneck, not technology.

**More systems.** The architecture supports extension. Crafting, fishing, a bestiary, achievement tracking, new game plus — each is a new autoload or system script following the same patterns you have used throughout.

**A different kind of game.** The patterns in this guide — state machines, Resource data classes, signal-driven architecture, autoload services, scene composition — apply to any Godot game. An action RPG replaces the turn-based battle with real-time combat but keeps everything else. A visual novel keeps the dialogue system and strips out the battle. A tactics game keeps the turn queue and adds grid-based movement.

The fundamentals transfer. You are no longer a software engineer who has never built a game — you are a software engineer who builds games.

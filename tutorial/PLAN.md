# JRPG in Godot 4: A Complete Tutorial Series

## Vision

This tutorial series takes a programmer with zero Godot experience and walks them through building a complete, playable JRPG demo called **Crystal Saga** from scratch. By the end, the reader will have built: a tile-based overworld with multiple areas, screen transitions, NPCs with dialogue, a turn-based battle system, inventory and equipment, a quest tracker, save/load, audio, and a title screen tying it all together.

The tutorial is organized into **six parts** containing **twenty-one modules**. Each module builds directly on the previous ones — there are no standalone lessons. The reader maintains a single Godot project throughout, and every module ends with something new they can run and see.

### Design Principles

1. **One project, start to finish.** Every module adds to "Crystal Saga." No throwaway examples.
2. **Show, then explain.** Code comes first, then we unpack what it does and why. *Exception: spatial/visual systems (TileMaps, dungeon design) get a brief conceptual model up front before code, because debugging visual problems without understanding the model is painful.*
3. **Cite everything.** Every Godot concept links to the official documentation so readers can go deeper.
4. **Spiral learning.** Concepts appear simply at first, then return with more depth. (e.g., signals appear in Module 3 for input, then again in Module 8 for dialogue events, then again in Module 11 for battle state changes. State machines are built in Module 5 for player movement, then applied at scale in Module 11 for battle flow.)
5. **JRPG-specific.** This isn't a generic game dev course. Every example, every pattern, every design decision is framed through the lens of "how does a JRPG do this?"
6. **Approachable but not patronizing.** We assume the reader can code. We don't assume they know Godot, game dev patterns, or GDScript.
7. **Runnable checkpoints.** Each module ends with a "What You Should See" section describing the expected state of the game. Readers can verify they're on track.

### The Demo Game: Crystal Saga

A small JRPG with enough scope to exercise every major system:

- **Setting:** A world where ancient crystals hold fragments of memory. The protagonist discovers they can "resonate" with these crystals.
- **Scope:** One town (Willowbrook), one forest path (Whisperwood), one dungeon (Crystal Cavern), one boss fight.
- **Party:** The hero (swordsman) and one recruitable companion (a mage met in town).
- **Systems:** Overworld exploration, NPC dialogue, a shop, an inn, random encounters, turn-based battles, inventory/equipment, one side quest, save/load, and a simple main quest line.

This scope is deliberately small — big enough to need real architecture, small enough to finish.

---

## Part I: Welcome to Godot

*Getting comfortable with the engine, the editor, and GDScript. By the end of Part I, you'll have a project set up and understand how Godot thinks about games.*

### Module 1: The Journey Begins
**File:** `tutorial/01_the_journey_begins.md`

**What the reader builds:** A new Godot project with a sprite on screen and a labeled scene.

**Topics:**
- What is Godot? Why Godot for a JRPG?
- Downloading and installing Godot 4.x
- Creating a new project (renderer choice: Compatibility for 2D pixel art)
- The editor interface: Scene dock, Inspector, FileSystem, Output
- Nodes: the atomic unit of Godot (what they are, why everything is a node)
- Scenes: reusable node trees (the scene = prefab mental model)
- Your first scene: a Sprite2D with a placeholder texture
- Running the project (F5 / play button)
- The main scene setting

**Godot Docs References:**
- `getting_started/introduction/introduction_to_godot.rst`
- `getting_started/step_by_step/nodes_and_scenes.rst`
- `getting_started/introduction/first_look_at_the_editor.rst`
- `tutorials/scripting/nodes_and_scene_instances.rst`

**Key Concepts Introduced:** Node, Scene, Scene Tree, Inspector, Main Scene

---

### Module 2: GDScript for Programmers
**File:** `tutorial/02_gdscript_for_programmers.md`

**What the reader builds:** A script that moves a sprite when you press arrow keys, printed debug output.

**Topics:**
- GDScript overview: Python-like, dynamically and statically typed, designed for Godot
- Creating and attaching scripts
- Variables, types, and static typing (why we use it)
- Functions, control flow, loops
- GDScript-specific: `@export`, `@onready`, `$NodePath`, `%UniqueNode`
- The `_ready()` and `_process(delta)` virtual functions
- Input basics: `Input.is_action_pressed()`, the Input Map
- A note on `Input`: this is your first autoload — a globally accessible singleton provided by Godot. We'll create our own in Module 6.
- Moving a sprite with code
- `print()` debugging and the Output panel
- Common gotchas for Python/JS/C# developers
- Keyboard vs gamepad: Godot's Input Map handles both — define an action once, bind it to keyboard AND gamepad buttons

**Godot Docs References:**
- `tutorials/scripting/gdscript/gdscript_basics.rst`
- `tutorials/scripting/gdscript/gdscript_styleguide.rst`
- `tutorials/scripting/overridable_functions.rst`
- `tutorials/scripting/idle_and_physics_processing.rst`
- `tutorials/inputs/input_examples.rst`
- `tutorials/inputs/inputevent.rst`

**Key Concepts Introduced:** GDScript, static typing, virtual functions, `_ready`, `_process`, delta time, Input Map, `@export`, `@onready`, autoloads (preview via `Input`)

---

### Module 3: Thinking in Scenes
**File:** `tutorial/03_thinking_in_scenes.md`

**What the reader builds:** The hero character as a reusable scene with a sprite and collision, instanced into a test world.

**Topics:**
- Scene composition: why scenes are the building block, not scripts
- CharacterBody2D vs RigidBody2D vs Area2D — when to use each
- Building the Player scene: CharacterBody2D → Sprite2D + CollisionShape2D
- `move_and_slide()` for physics-based movement
- `_physics_process()` vs `_process()` — when each matters
- Instancing scenes into other scenes
- The scene tree at runtime: parent/child relationships
- Signals: a first look (connecting `body_entered` in the editor)
- Signal auto-disconnection: when a node is freed, its signal connections are automatically cleaned up
- Saving scenes (`.tscn` files) and the resource system

**Godot Docs References:**
- `tutorials/scripting/nodes_and_scene_instances.rst`
- `tutorials/scripting/scene_tree.rst`
- `classes/class_characterbody2d.rst`
- `tutorials/physics/physics_introduction.rst`
- `tutorials/scripting/instancing_with_signals.rst`

**Key Concepts Introduced:** Scene composition, CharacterBody2D, `move_and_slide`, `_physics_process`, instancing, signals (intro), signal cleanup, `.tscn` files

---

## Part II: Building the World

*Creating the game world with tilemaps, camera, and connected areas. By the end of Part II, you'll have a town and a forest the player can walk between, with an animated hero.*

### Module 4: The Overworld — TileMaps and Terrain
**File:** `tutorial/04_tilemaps_and_terrain.md`

**What the reader builds:** The town of Willowbrook as a tiled map with ground, paths, water, and collision.

**Topics:**
- What is a TileMapLayer? The grid-based approach to 2D worlds
- Conceptual model: think of layers as transparent sheets stacked on top of each other — ground on the bottom, then details, then objects, then things that appear above the player
- TileSet: creating a tileset from a sprite sheet
- Atlas sources: importing tile sheets, configuring tile size (16x16 or 32x32)
- Painting terrain: the TileMapLayer editor tools
- Multiple TileMapLayers: Ground, Detail, Objects, AbovePlayer — one node per layer
- Why `TileMapLayer` and not `TileMap`? The old `TileMap` node is deprecated as of Godot 4.3. `TileMapLayer` is the replacement — one node per layer, simpler API.
- Physics layers on tiles: marking solid tiles for collision
- The Camera2D node: following the player, setting limits
- Pixel-perfect rendering: viewport settings, texture filtering (`Filter: Nearest`)
- Building Willowbrook: a small town with houses, paths, and a town square

**Godot Docs References:**
- `tutorials/2d/using_tilesets.rst`
- `tutorials/2d/using_tilemaps.rst`
- `classes/class_tilemaplayer.rst`
- `classes/class_tileset.rst`
- `classes/class_camera2d.rst`
- `tutorials/rendering/` (viewport and pixel snap settings)

**Key Concepts Introduced:** TileMapLayer, TileSet, Atlas source, tile layers, physics layers, Camera2D, pixel-perfect settings

---

### Module 5: Bringing the Player to Life
**File:** `tutorial/05_player_character.md`

**What the reader builds:** A player character with 4-directional sprite animation, a proper state machine (IDLE, WALK, INTERACT, DISABLED), and collision with the tilemap.

**Topics:**
- Sprite sheets for characters: walk cycles (down, left, right, up)
- AnimatedSprite2D vs using a Sprite2D with AnimationPlayer
- Setting up animation frames from a sprite sheet
- 4-directional movement script: facing direction, animation switching
- Grid-based movement vs free movement (tradeoffs for JRPGs)
- Implementing free movement with `move_and_slide()`
- Sorting: Y-sort for depth (the player walks behind and in front of objects)
- **The state machine pattern: enum-based implementation**
  - Why state machines? Preventing invalid state combinations
  - Four states: `IDLE`, `WALK`, `INTERACT`, `DISABLED`
  - The `match` statement as a state router
  - State transitions: when and how states change
  - *We'll revisit state machines in Module 11 when we build the battle system, which uses a more complex node-based approach.*
- Refining the Player scene from Module 3

**Godot Docs References:**
- `tutorials/2d/2d_sprite_animation.rst`
- `classes/class_animatedsprite2d.rst`
- `classes/class_animationplayer.rst`
- `tutorials/2d/2d_movement.rst`
- `classes/class_characterbody2d.rst`
- `classes/class_canvasitem.rst` (y_sort_enabled)

**Key Concepts Introduced:** AnimatedSprite2D, sprite sheets, facing direction, Y-sort, enum-based state machine, `match` statement, state transitions

---

### Module 6: Connecting Worlds — Scene Transitions
**File:** `tutorial/06_scene_transitions.md`

**What the reader builds:** A forest area (Whisperwood) connected to Willowbrook via door/exit zones, with a fade-to-black transition.

**Topics:**
- Why scenes map to areas in a JRPG (one scene per location)
- Area2D as a trigger zone (exit/entrance markers)
- Detecting the player entering a zone (`body_entered` signal)
- Changing scenes: `get_tree().change_scene_to_file()` and its limitations
- **Autoloads: creating your own singleton (SceneManager)**
  - You've already used autoloads — `Input`, `Engine`, and `Time` are all Godot built-ins that work this way. Now we create our own.
  - Registering autoloads in Project Settings
  - Why autoloads? Global state that persists across scene changes
- Building a SceneManager: fade-out, change scene, fade-in
- CanvasLayer for transition overlays (ColorRect + AnimationPlayer)
- Passing data between scenes: spawn points, direction facing
- Signal lifecycle reminder: when scenes are freed, their signals disconnect automatically. Autoload signals persist because autoloads are never freed.
- Building the Whisperwood forest scene
- Connecting town ↔ forest with bidirectional exits
- **Autoload reference card** — a running table of all autoloads we create (updated in future modules):
  | Autoload | Module | Purpose |
  |----------|--------|---------|
  | SceneManager | 6 | Scene transitions with fade effects |

**Godot Docs References:**
- `tutorials/scripting/singletons_autoload.rst`
- `tutorials/scripting/change_scenes_manually.rst`
- `classes/class_area2d.rst`
- `classes/class_canvaslayer.rst`
- `classes/class_animationplayer.rst`
- `classes/class_scenetree.rst`

**Key Concepts Introduced:** Autoload/singleton, SceneManager, Area2D triggers, `change_scene_to_file`, CanvasLayer, scene data passing, autoload reference card

---

## Part III: A Living World

*Populating the world with characters and systems for the player to interact with. By the end of Part III, you'll have NPCs who talk, an inventory, and a data-driven architecture.*

### Module 7: Resources — The Data Layer
**File:** `tutorial/07_resources_data_layer.md`

**What the reader builds:** Custom Resource classes for items, character stats, and NPC data — establishing the data-driven architecture before we need it.

**Topics:**
- What is a Resource? Godot's data container
- Custom Resource classes: `class_name`, `@export` properties
- `.tres` files: creating and editing in the Inspector
- Why Resources over dictionaries: type safety, editor integration, reusability
- Designing the ItemData resource: name, description, icon, type, effect_value
- Designing the CharacterData resource: name, max_hp, max_mp, attack, defense, speed, level
- Designing the NPCData resource: name, sprite, dialogue lines
- Loading resources: `preload()` vs `load()` and when to use each
- Null-check pattern: always verify `load()` results (`if resource == null: push_error(...)`)
- The three-file pattern: `resource_class.gd` → `data_instance.tres` → `consumer_script.gd`
- Creating initial data for Crystal Saga: a potion, a sword, a shield, the hero's stats

**Godot Docs References:**
- `tutorials/scripting/resources.rst`
- `classes/class_resource.rst`
- `tutorials/scripting/gdscript/gdscript_exports.rst`
- `tutorials/best_practices/` (data-driven design sections)

**Key Concepts Introduced:** Custom Resources, `.tres` files, `class_name`, `preload` vs `load`, null-check pattern, data-driven design, the three-file pattern

---

### Module 8: NPCs and Interaction
**File:** `tutorial/08_npcs_and_interaction.md`

**What the reader builds:** Stationary NPCs in Willowbrook that the player can walk up to and interact with via a button press, each configured with an NPCData resource.

**Topics:**
- Designing the NPC scene: Sprite2D + Area2D (interaction zone) + CollisionShape2D
- The interaction pattern: detecting nearby interactables, showing a prompt
- Input actions: defining a custom "interact" action in the Input Map (keyboard + gamepad)
- Raycasting vs Area2D overlap for interaction detection
- The Interactable interface: a convention for `interact()` methods
- Facing the NPC toward the player during interaction
- Using the player's INTERACT state from Module 5
- NPC variants: the same scene, different data (using NPCData resources from Module 7)
- `@export var npc_data: NPCData` for per-instance customization in the editor
- Placing NPCs in Willowbrook: a shopkeeper, an innkeeper, and a traveler

**Godot Docs References:**
- `classes/class_area2d.rst`
- `classes/class_raycast2d.rst`
- `tutorials/inputs/input_examples.rst`
- `tutorials/inputs/inputevent.rst`

**Key Concepts Introduced:** Interaction pattern, RayCast2D, `@export` with Resource types, interface convention, Input Map custom actions, player state integration

**Callback to Previous Modules:** State machine INTERACT state (Module 5), Resources/NPCData (Module 7)

---

### Module 9: The Dialogue System
**File:** `tutorial/09_dialogue_system.md`

**What the reader builds:** A dialogue box UI that displays NPC text with a typewriter effect, supports multi-page dialogue, and shows speaker names.

**Topics:**
- UI fundamentals in Godot: Control nodes, anchors, containers
- Building the dialogue box: PanelContainer → MarginContainer → VBoxContainer
- RichTextLabel for styled text (`bbcode_enabled`)
- **The typewriter effect: tween `visible_ratio` from 0.0 to 1.0**
  - Why `visible_ratio` (a float) and not `visible_characters` (an int): tweening an int produces choppy per-character jumps. `visible_ratio` gives smooth character-by-character reveal.
  - Tween lifecycle: `create_tween()` tweens are automatically killed when the creating node is freed. Store Tween references carefully — a Tween held in a variable can outlive its target node if the node is freed first.
- DialogueLine resource: speaker name, text, portrait (using the Resource pattern from Module 7)
- DialogueSequence: an array of DialogueLine resources
- Signals for dialogue flow: `dialogue_started`, `dialogue_finished`, `line_advanced`
- Freezing player movement during dialogue (setting player to DISABLED state)
- Advancing dialogue with the interact button
- Connecting NPCs to the dialogue system
- Choice/branching dialogue: presenting options, handling selection

**Godot Docs References:**
- `tutorials/ui/size_and_anchors.rst`
- `tutorials/ui/gui_containers.rst`
- `tutorials/ui/bbcode_in_richtextlabel.rst`
- `classes/class_richtextlabel.rst`
- `classes/class_tween.rst`
- `classes/class_panelcontainer.rst`
- `tutorials/ui/control_node_gallery.rst`

**Key Concepts Introduced:** Control nodes, anchors, containers, RichTextLabel, `visible_ratio`, Tween lifecycle, DialogueLine resource, UI layering with CanvasLayer

**Callback to Previous Modules:** Resources (Module 7), player DISABLED state (Module 5), NPC interaction (Module 8)

---

### Module 10: The Inventory System
**File:** `tutorial/10_inventory_system.md`

**What the reader builds:** An inventory system the player can open with a key, displaying items in a grid, with the ability to use consumable items.

**Topics:**
- InventoryManager as an autoload
- Storing items: Array of `{item: ItemData, count: int}` dictionaries
- Adding/removing items: methods with signal notifications (`item_added`, `item_removed`, `inventory_changed`)
- The inventory UI: GridContainer of item slots
- Item slot scene: TextureRect (icon) + Label (count)
- Opening/closing the inventory: input action, `get_tree().paused`, and `process_mode`
- Using items: consumables that heal HP
- Key items: items that can't be used but are checked by quest logic (*we'll use these in Module 16*)
- **Autoload reference card update:**
  | Autoload | Module | Purpose |
  |----------|--------|---------|
  | SceneManager | 6 | Scene transitions with fade effects |
  | InventoryManager | 10 | Item storage, add/remove, signals |

**Godot Docs References:**
- `tutorials/ui/gui_containers.rst`
- `classes/class_gridcontainer.rst`
- `tutorials/scripting/pausing_games.rst`
- `classes/class_texturerect.rst`
- `tutorials/ui/gui_navigation.rst`

**Key Concepts Introduced:** Inventory management, UI data binding, `get_tree().paused` and `process_mode`, item usage

---

## Part IV: The Battle System

*The heart of any JRPG. By the end of Part IV, you'll have a complete turn-based battle system with abilities, enemies, and rewards.*

### Module 11: Battle Foundations — State Machines and Turn Order
**File:** `tutorial/11_battle_foundations.md`

**What the reader builds:** A battle scene skeleton with party and enemies displayed, a turn order system, and transitions between battle phases.

**Topics:**
- **Scaling up the state machine: from enum to node-based**
  - In Module 5, we built a 4-state enum-based state machine for the player. That works great for simple cases.
  - The battle system has 7+ states with complex transitions. At this scale, an enum-based `match` block becomes unwieldy. We need a more flexible approach.
  - Node-based state machines: each state is a child Node with `enter()`, `exit()`, and `process()` methods
  - The BattleStateMachine node: managing current state, handling transitions
- Battle states: INTRO → TURN_START → PLAYER_CHOICE → ACTION_EXECUTE → CHECK_RESULT → VICTORY / DEFEAT
- The battle scene layout: party on the right, enemies on the left
- BattlerData: a Resource (Module 7 pattern) combining character stats with battle-specific data
- Turn order: speed-based sorting
- The turn queue: who goes next?
- Transitioning from overworld to battle: passing encounter data through the SceneManager
- Displaying party members and enemies as sprites in the battle scene
- The BattleManager: orchestrating state transitions via signals
- **Autoload reference card update:**
  | Autoload | Module | Purpose |
  |----------|--------|---------|
  | SceneManager | 6 | Scene transitions with fade effects |
  | InventoryManager | 10 | Item storage, add/remove, signals |
  | BattleManager | 11 | Battle state machine, turn queue |

**Godot Docs References:**
- `tutorials/best_practices/` (state machine patterns)
- `classes/class_node.rst` (node-based state machine)
- `tutorials/scripting/scene_tree.rst`

**Key Concepts Introduced:** Node-based state machine, battle states, turn queue, BattlerData, BattleManager, encounter data, enum vs node state machine tradeoffs

**Callback to Previous Modules:** Enum state machine (Module 5), SceneManager (Module 6), Resources (Module 7), signals (Modules 3, 9)

---

### Module 12: Player Actions — Attack, Defend, Magic, Items
**File:** `tutorial/12_player_actions.md`

**What the reader builds:** A battle menu (Attack/Magic/Defend/Item) with functional actions that deal damage, heal, and modify defense.

**Topics:**
- The battle menu UI: VBoxContainer of buttons
- Focus-based navigation for menus (keyboard/gamepad friendly)
- Action architecture: the Command pattern
- Attack action: selecting a target, calculating damage (attack vs defense)
- **Defend action as a temporary buff:** boosting defense for one turn using a simple modifier system
  - This is the simplest form of a status effect. *In Module 21 (next steps), we'll discuss how to generalize this into a full status effects system.*
- Magic/Ability system: AbilityData resource, MP costs, elemental types
- The target selection sub-state: choosing which enemy to hit
- Item usage in battle: opening a filtered inventory view
- Damage formula: `max(1, attacker.attack - defender.defense + randi_range(-2, 2))`
- Animating actions: Tween-based sprite movement (attacker slides forward, hits, slides back)
- Tween lifecycle in battle: creating tweens per action, ensuring cleanup between turns
- Damage numbers: floating labels that rise and fade
- Connecting the menu to the BattleManager state machine

**Godot Docs References:**
- `tutorials/ui/gui_navigation.rst`
- `classes/class_tween.rst`
- `classes/class_label.rst`
- `tutorials/ui/gui_containers.rst`

**Key Concepts Introduced:** Command pattern, target selection, damage formula, battle animations with Tweens, floating damage numbers, focus navigation, temporary buff pattern

---

### Module 13: The Crystal Cavern — Dungeon Design
**File:** `tutorial/13_crystal_cavern.md`

**What the reader builds:** A dungeon area (Crystal Cavern) with a distinct tilemap, multiple rooms connected by passages, a boss room, and encounter zones.

**Topics:**
- Dungeon vs overworld: different tileset, different layer needs, different collision
- Building the Crystal Cavern TileMapLayer setup: cave floor, walls, crystal formations, darkness overlay
- Room-based design: entry chamber, branching paths, dead ends with treasure, boss room
- Encounter zones: Area2D regions that define which enemies can appear (data only — enemies come in Module 14)
- Treasure chests: an interactable that gives items (reusing the interaction pattern from Module 8)
- The save crystal: an interactable object in the dungeon (*we'll wire it up for saving in Module 18*)
- Connecting Whisperwood → Crystal Cavern via scene transitions
- The boss room door: a locked passage that requires a key item
- Environmental storytelling: crystal formations, ancient ruins, visual narrative

**Godot Docs References:**
- `tutorials/2d/using_tilesets.rst`
- `tutorials/2d/using_tilemaps.rst`
- `classes/class_tilemaplayer.rst`

**Key Concepts Introduced:** Dungeon tilemap design, room-based level design, encounter zones, treasure chests, locked doors, environmental design

**Callback to Previous Modules:** TileMapLayer (Module 4), scene transitions (Module 6), interaction pattern (Module 8), Resources for chest loot (Module 7)

---

### Module 14: Enemies and AI
**File:** `tutorial/14_enemies_and_ai.md`

**What the reader builds:** Three enemy types with basic AI, random encounters triggered while walking in Whisperwood and Crystal Cavern, and a boss fight.

**Topics:**
- EnemyData resource: stats, abilities, AI type, sprite, loot table
- Enemy AI: simple decision-making (weighted random)
- AI behaviors: aggressive (always attacks strongest), cautious (defends when low), balanced (random mix)
- Encounter groups: EncounterData resource defining which enemies appear together
- **The random encounter system:**
  - Step counter: each movement tick increments a counter
  - Threshold with randomness: encounter triggers when counter exceeds a random threshold
  - Resetting after each encounter
- Encounter zones wired up: connecting Module 13's zones to encounter group data
- Boss design: the Crystal Guardian — higher stats, unique ability pattern, dialogue before fight
- The pre-boss cutscene: triggering dialogue before transitioning to battle
- Flee mechanic: probability-based escape (higher speed = better chance)

**Godot Docs References:**
- `tutorials/math/random_number_generation.rst`
- `classes/class_randomnumbergenerator.rst`

**Key Concepts Introduced:** Enemy AI patterns, encounter system, step-counter encounters, boss design, encounter groups

**Callback to Previous Modules:** Resources (Module 7), battle system (Modules 11-12), encounter zones (Module 13), dialogue (Module 9)

---

### Module 15: Victory, Rewards, and Leveling
**File:** `tutorial/15_victory_and_leveling.md`

**What the reader builds:** Post-battle victory screen with XP/gold rewards, a leveling system with stat growth, and the defeat/game-over flow.

**Topics:**
- Victory state: what happens when all enemies are dead
- The victory fanfare: a brief celebration screen
- Experience points: distributing XP to the party
- The level-up system: XP thresholds using a simple curve (`required_xp = level * level * 10`)
- Stat growth: per-character growth rates stored in CharacterData
- Level-up notification: showing stat increases with a Tween animation
- Gold rewards: adding to a `gold` property on InventoryManager
- Item drops: loot tables with probability on EnemyData
- The defeat state: what happens when all party members fall
- Game Over screen: retry (reload last save), return to title
- Returning to the overworld after battle: SceneManager restores previous scene and position

**Godot Docs References:**
- `classes/class_tween.rst` (for victory screen animations)
- `tutorials/math/` (for curves and interpolation)

**Key Concepts Introduced:** XP distribution, level curves, stat growth, loot tables, game over flow, post-battle state restoration

---

## Part V: Progression and Persistence

*Systems that give the game depth and let the player save their progress. By the end of Part V, you'll have quests, a party member, equipment, and save/load.*

### Module 16: The Quest System and Game Flags
**File:** `tutorial/16_quest_system.md`

**What the reader builds:** A game flags system for tracking world state, a quest tracker with a main quest ("Explore the Crystal Cavern") and a side quest ("Find the traveler's lost pendant"), with NPC dialogue that reacts to quest state.

**Topics:**
- **Game flags: the boolean backbone of JRPG state**
  - GameManager autoload: a dictionary of `flag_name → bool` for tracking world state
  - Examples: `has_met_lira`, `crystal_cavern_unlocked`, `pendant_found`, `boss_defeated`
  - Signals: `flag_changed(flag_name, value)` for reactive systems
  - Why flags and not just quest state: some state (doors opened, conversations had, items found) doesn't belong to any quest
- Quest data: QuestData resource with stages, objectives, rewards
- Quest states: NOT_STARTED → ACTIVE → COMPLETE → TURNED_IN
- QuestManager autoload: tracking active quests, checking conditions via game flags
- Objectives: collect item, talk to NPC, reach location, defeat boss
- Connecting quests to dialogue: NPCs check flags and quest state to choose dialogue
- The quest log UI: listing active and completed quests
- Quest rewards: items, gold, setting new flags
- The main quest: a breadcrumb trail from town → forest → cavern → boss
- A side quest: the traveler NPC lost a pendant in Whisperwood
- **Autoload reference card update:**
  | Autoload | Module | Purpose |
  |----------|--------|---------|
  | SceneManager | 6 | Scene transitions with fade effects |
  | InventoryManager | 10 | Item storage, add/remove, signals |
  | BattleManager | 11 | Battle state machine, turn queue |
  | GameManager | 16 | Game flags, world state tracking |
  | QuestManager | 16 | Quest tracking, objective checking |

**Godot Docs References:**
- `tutorials/scripting/resources.rst` (resource-based quest data)
- `tutorials/scripting/singletons_autoload.rst` (QuestManager, GameManager)

**Key Concepts Introduced:** Game flags, GameManager, quest state machine, quest objectives, reactive dialogue, quest log UI

**Callback to Previous Modules:** Resources (Module 7), dialogue (Module 9), NPCs (Module 8), autoloads (Module 6)

---

### Module 17: Party Management, Equipment, and Shops
**File:** `tutorial/17_party_and_equipment.md`

**What the reader builds:** A party system where a mage NPC joins after a dialogue event, equipment slots that modify stats, and a shop in Willowbrook.

**Topics:**
- **PartyManager autoload: the roster of characters**
  - Active party array, reserve party
  - Signals: `party_member_joined`, `party_member_removed`
- Party member data: extending CharacterData with abilities, equipment slots
- **Recruitment event: Lira the mage**
  - Dialogue sequence + game flag check (`has_met_lira`)
  - Triggering `party_member_joined` signal
  - She appears in battle with unique abilities (healing magic, elemental attack)
- **Equipment system**
  - Equipment slots: weapon, armor, accessory (stored on CharacterData)
  - Stat calculation: `effective_attack = base_attack + weapon.attack_bonus`
  - Equip/unequip: moving items between inventory and equipment slots
  - Equipment UI: viewing and changing equipment per party member
- **The shop system**
  - ShopData resource: list of items for sale with prices
  - Shop UI: reusing inventory grid patterns, buy/sell tabs
  - Gold management: checking affordability, completing purchases
  - The Willowbrook shopkeeper: sells potions, basic gear
  - The innkeeper: pays gold to restore HP/MP (simple interaction, no shop UI needed)
- The party menu: viewing stats, equipment, abilities for each member
- **Autoload reference card update:**
  | Autoload | Module | Purpose |
  |----------|--------|---------|
  | SceneManager | 6 | Scene transitions with fade effects |
  | InventoryManager | 10 | Item storage, add/remove, signals |
  | BattleManager | 11 | Battle state machine, turn queue |
  | GameManager | 16 | Game flags, world state tracking |
  | QuestManager | 16 | Quest tracking, objective checking |
  | PartyManager | 17 | Party roster, recruitment, stats |

**Godot Docs References:**
- `tutorials/scripting/singletons_autoload.rst`
- `classes/class_resource.rst`
- `tutorials/ui/gui_containers.rst`

**Key Concepts Introduced:** Party roster, recruitment events, equipment system, stat bonuses, shop system, ShopData resource

**Callback to Previous Modules:** Resources (Module 7), dialogue (Module 9), inventory UI patterns (Module 10), battle system (Modules 11-12), game flags (Module 16)

---

### Module 18: Save and Load
**File:** `tutorial/18_save_and_load.md`

**What the reader builds:** A save system with three slots using JSON, saving all game state (position, inventory, quests, party, flags), with save crystals in the world and a load option.

**Topics:**
- What needs saving? Identifying all persistent game state across our autoloads
- **The save format: JSON**
  - We use JSON for saves because it's human-readable (great for debugging), universally understood, and requires no custom class definitions
  - Alternative: Godot's `ResourceSaver` can save `.tres` files, which gives type safety but couples saves to your class definitions. JSON is simpler for a tutorial scope.
- File I/O in Godot: `FileAccess`, user data paths (`user://`)
- The save data structure: a dictionary with sections for each autoload's state
- Building `to_save_data()` and `from_save_data()` methods on each autoload
- The save flow: player interacts with a save crystal → write file
- The load flow: "Continue" option → read file → restore state
- Wiring up the save crystal from Module 13
- Restoring scene state: spawning in the right scene and position
- Restoring inventory, quests, party, equipment, and flags
- Multiple save slots: `user://saves/save_1.json`, `save_2.json`, `save_3.json`
- Save slot UI: showing playtime, location, party level
- Error handling: corrupt saves (`JSON.parse()` error checking), missing files (`FileAccess.file_exists()`)

**Godot Docs References:**
- `tutorials/io/saving_games.rst`
- `tutorials/io/data_paths.rst`
- `classes/class_fileaccess.rst`
- `classes/class_json.rst`

**Key Concepts Introduced:** FileAccess, `user://` path, JSON serialization, `to_save_data`/`from_save_data` pattern, save points, state restoration, save slots

---

## Part VI: Polish and Integration

*Making it feel like a real game. By the end of Part VI, you'll have a complete, playable JRPG demo with audio, menus, and a polished game loop.*

### Module 19: Audio — Music and Sound Effects
**File:** `tutorial/19_audio.md`

**What the reader builds:** Background music for each area, battle music with transitions, SFX for actions, and volume controls.

**Topics:**
- Audio in Godot: AudioStreamPlayer (non-positional), AudioStreamPlayer2D (positional)
- Importing audio: OGG for music (small files, good quality), WAV for SFX (no decode latency)
- Background music: one AudioStreamPlayer per scene vs a global music manager
- **MusicManager autoload: crossfading between tracks**
  - Two AudioStreamPlayers: one fading out, one fading in
  - Tween-based crossfade
  - Remembering the overworld track during battle, resuming after
- Sound effects: attack hits, menu cursor, level up jingle, dialogue blip
- **Audio buses: Master, Music, SFX**
  - What is an audio bus? A mixing channel with its own volume and effects
  - Setting up buses in the Audio tab (bottom panel)
  - Routing AudioStreamPlayers to the correct bus
  - `AudioServer.set_bus_volume_db()` for runtime volume control
- Volume settings: sliders that map to bus volume
- Looping music: the `loop` property on AudioStream
- **Autoload reference card (final):**
  | Autoload | Module | Purpose |
  |----------|--------|---------|
  | SceneManager | 6 | Scene transitions with fade effects |
  | InventoryManager | 10 | Item storage, add/remove, signals |
  | BattleManager | 11 | Battle state machine, turn queue |
  | GameManager | 16 | Game flags, world state tracking |
  | QuestManager | 16 | Quest tracking, objective checking |
  | PartyManager | 17 | Party roster, recruitment, stats |
  | MusicManager | 19 | BGM crossfading, battle music |

**Godot Docs References:**
- `tutorials/audio/audio_buses.rst`
- `classes/class_audiostreamplayer.rst`
- `classes/class_audioserver.rst`
- `classes/class_audiobuslayout.rst`

**Key Concepts Introduced:** AudioStreamPlayer, audio buses, AudioBusLayout, MusicManager, crossfading, SFX, `AudioServer`

---

### Module 20: Title Screen and Game Flow
**File:** `tutorial/20_title_screen_and_game_flow.md`

**What the reader builds:** A title screen with New Game / Continue / Settings, a pause menu, and the complete game flow from launch to credits.

**Topics:**
- The title screen scene: logo, menu options, background
- New Game: initializing fresh game state across all autoloads, loading the first scene
- Continue: loading the save slot selection screen, then restoring state
- Settings: volume sliders wired to audio buses from Module 19
- **The pause menu**
  - `get_tree().paused = true` and `process_mode = PROCESS_MODE_ALWAYS`
  - Menu options: Resume, Inventory, Quest Log, Save (only at save points), Settings, Quit to Title
  - Reusing existing UI scenes (inventory, quest log) inside the pause menu
- Game over → title screen flow
- Victory ending: defeating the Crystal Guardian triggers a simple ending scene
- Credits screen: scrolling text with a timer
- **The complete game loop:**
  ```
  Title Screen → New Game → Willowbrook → Whisperwood → Crystal Cavern → Boss → Ending → Credits → Title Screen
                → Continue → Load Save → Resume Play
  ```
- Integration checklist: verifying every system connects to every other system

**Godot Docs References:**
- `tutorials/scripting/pausing_games.rst`
- `classes/class_scenetree.rst`
- `tutorials/scripting/change_scenes_manually.rst`

**Key Concepts Introduced:** Game flow architecture, pause menu, `process_mode`, integration testing, game loop completion

---

### Module 21: Finish Line — Polish, Export, and Next Steps
**File:** `tutorial/21_finish_line.md`

**What the reader builds:** A polished, exported build of Crystal Saga, plus a roadmap for what to add next.

**Topics:**
- Playtesting walkthrough: playing through Crystal Saga from start to finish
- Common bugs and how to fix them (FAQ/troubleshooting section)
- Performance basics: what to watch for in a 2D JRPG
  - Object pooling for damage numbers
  - Avoiding `_process()` on nodes that don't need it
  - `@onready` caching vs repeated `get_node()` calls
- **Exporting the game**
  - Installing export templates
  - Configuring an export preset (Windows, macOS, Linux)
  - Building the executable
- **Where to go from here:**
  - **Status effects system:** Generalize the defend buff from Module 12 into poison, sleep, stun, regen, etc. with durations and turn-based ticking
  - **Elemental weakness/resistance:** Rock-paper-scissors damage modifiers
  - **Limit breaks:** Special abilities that charge as you take damage
  - **More party members:** Adding 3-4 more characters with unique ability trees
  - **Advanced dialogue:** Speaker portraits, animated text effects, branching quest chains
  - **Procedural dungeons:** Generating cave layouts from templates
  - **Controller support polish:** Deadzone tuning, button prompts that match the connected device
  - **Mobile export:** Touch controls, screen scaling
  - Adding more content: areas, enemies, quests, story
- Recommended resources: GDQuest, Godot community, official docs, asset packs
- Closing thoughts: what you've accomplished and what makes JRPGs special

**Godot Docs References:**
- `tutorials/export/` (exporting projects)
- `tutorials/performance/` (performance tips)

**Key Concepts Introduced:** Exporting, performance optimization, extension points, community resources

---

## Module Dependency Graph

```
Module 1 (Setup)
  └→ Module 2 (GDScript)
       └→ Module 3 (Scenes)
            ├→ Module 4 (TileMapLayer)
            │    └→ Module 5 (Player + State Machine)
            │         └→ Module 6 (Scene Transitions + Autoloads)
            │              ├→ Module 7 (Resources)
            │              │    ├→ Module 8 (NPCs)
            │              │    │    └→ Module 9 (Dialogue)
            │              │    │         └→ Module 10 (Inventory)
            │              │    │              └→ Module 11 (Battle Foundations)
            │              │    │                   └→ Module 12 (Player Actions)
            │              │    │                        └→ Module 13 (Crystal Cavern)
            │              │    │                             └→ Module 14 (Enemies + AI)
            │              │    │                                  └→ Module 15 (Victory + Leveling)
            │              │    │                                       └→ Module 16 (Quests + Flags)
            │              │    │                                            └→ Module 17 (Party + Equipment + Shops)
            │              │    │                                                 └→ Module 18 (Save/Load)
            │              │    └→ [Resources used by all subsequent modules]
            │              └→ Module 19 (Audio) ← can be done alongside Part V
            │                   └→ Module 20 (Title Screen + Game Flow)
            │                        └→ Module 21 (Finish Line)
            └→ [TileMapLayer knowledge reused in Module 13]
```

**Reading the graph:** Follow the main chain (1 → 2 → ... → 18 → 20 → 21). Module 19 (Audio) branches off from Module 6 and can be written/read somewhat independently, though it integrates with everything. Module 7 (Resources) feeds into everything after it.

## Estimated Module Lengths

| Module | Est. Words | Est. Code Lines | Complexity |
|--------|-----------|----------------|------------|
| 1. The Journey Begins | 2,500 | 20 | Low |
| 2. GDScript for Programmers | 4,000 | 150 | Low |
| 3. Thinking in Scenes | 3,000 | 100 | Low |
| 4. TileMaps and Terrain | 3,500 | 80 | Medium |
| 5. Player Character + State Machine | 4,000 | 250 | Medium |
| 6. Scene Transitions | 4,000 | 250 | Medium |
| 7. Resources — Data Layer | 3,500 | 200 | Medium |
| 8. NPCs and Interaction | 3,000 | 200 | Medium |
| 9. Dialogue System | 4,500 | 350 | Medium-High |
| 10. Inventory System | 3,500 | 300 | Medium |
| 11. Battle Foundations | 5,000 | 400 | High |
| 12. Player Actions | 4,500 | 350 | High |
| 13. Crystal Cavern — Dungeon | 3,000 | 150 | Medium |
| 14. Enemies and AI | 3,500 | 300 | High |
| 15. Victory and Leveling | 3,500 | 250 | Medium-High |
| 16. Quests and Game Flags | 4,500 | 350 | Medium-High |
| 17. Party, Equipment, Shops | 4,500 | 400 | High |
| 18. Save and Load | 4,000 | 300 | Medium-High |
| 19. Audio | 3,000 | 150 | Medium |
| 20. Title Screen + Game Flow | 3,500 | 250 | Medium |
| 21. Finish Line | 3,000 | 50 | Low |

**Total: ~78,000 words, ~4,850 lines of code across 21 modules**

## Cross-Cutting Concerns

These topics appear across multiple modules rather than having a dedicated module:

| Topic | Where It Appears |
|-------|-----------------|
| **Signals** | Introduced M3, deepened M6/M8/M9, heavily used M11-M15, M16-M17 |
| **State machines** | Enum-based M5 (player), node-based M11 (battle), applied M16 (quests) |
| **Resources** | Introduced M7, used in every module after |
| **Autoloads** | Previewed M2 (Input), created M6 (SceneManager), added M10-M11, M16-M17, M19 |
| **UI patterns** | Introduced M9 (dialogue), expanded M10 (inventory), M12 (battle menu), M16 (quest log), M17 (equipment/shop), M18 (save slots), M20 (title/pause) |
| **Tween** | Introduced M9 (typewriter), used M12 (battle anims), M15 (victory), M19 (crossfade) |
| **Game flags** | Introduced M16, checked in M17 (recruitment), M18 (save/load), M20 (game flow) |
| **Testing/debugging** | Tips in every module, dedicated troubleshooting in M21 |

## Conventions Across All Modules

1. **File naming:** All tutorial GDScript uses `snake_case.gd`, scenes use `snake_case.tscn`
2. **Code style:** Static typing everywhere, tabs, double quotes, following Godot style guide
3. **Doc citations:** Format is `> **See:** [Topic Name](link to Godot docs page)` in a blockquote after each major concept
4. **Checkpoint sections:** Every module ends with "What You Should See" describing the expected game state
5. **Callout boxes:**
   - `> **Note:**` for tips and extra context
   - `> **Warning:**` for common pitfalls and gotchas
   - `> **JRPG Pattern:**` for genre-specific design insight
   - `> **Spiral:**` for callbacks to previous modules ("remember when we did X?")
6. **Code blocks:** Full file contents shown the first time, then diffs/additions for modifications
7. **Recap sections:** Each module starts with "What We Have So Far" (1-2 sentences) and "What We're Building This Module"
8. **Forward references:** When a concept will be deepened later, note it: *"We'll revisit this in Module X when we build Y."*
9. **Autoload reference card:** Updated each time a new autoload is added, showing the running total

## Reviewer Feedback Incorporated

Changes made based on dual plan review:

| Feedback | Change Made |
|----------|-------------|
| Module count said "eighteen" but had 20 modules | Fixed: now says "twenty-one" and has 21 modules |
| Resources came after Dialogue, causing immediate refactor | Moved Resources to Module 7, before NPCs and Dialogue |
| TileMap is deprecated; plan cited deprecated class | Changed to TileMapLayer throughout with deprecation note |
| Module 10 tried to cover inventory + equipment + shop | Split: inventory in M10, equipment/shop in M17 |
| Module 5 state machine was "preview" not real | Made it a real 4-state enum implementation |
| Module 13 built dungeon + enemies + AI + boss simultaneously | Split: dungeon in M13, enemies/AI in M14 |
| `class_audiobus.rst` doesn't exist | Changed to `tutorials/audio/audio_buses.rst` and `classes/class_audiobuslayout.rst` |
| `visible_characters` vs `visible_ratio` not distinguished | Made explicit: use `visible_ratio`, explained why |
| Save format uncommitted ("JSON or Resource") | Committed to JSON with explanation of tradeoffs |
| Dependency graph had ambiguous M11→M16 branch | Simplified to linear chain with clear branching |
| Game flags never formally introduced | Added to Module 16 as first topic |
| Input as autoload not acknowledged | Added note in Module 2 and callback in Module 6 |
| Tween lifecycle not addressed | Added warnings in Modules 9 and 12 |
| Null-check pattern for `load()` missing | Added to Module 7 |
| Signal disconnection not covered | Added to Module 3 and Module 6 |

## File Structure

```
tutorial/
  PLAN.md                              ← this file
  01_the_journey_begins.md
  02_gdscript_for_programmers.md
  03_thinking_in_scenes.md
  04_tilemaps_and_terrain.md
  05_player_character.md
  06_scene_transitions.md
  07_resources_data_layer.md
  08_npcs_and_interaction.md
  09_dialogue_system.md
  10_inventory_system.md
  11_battle_foundations.md
  12_player_actions.md
  13_crystal_cavern.md
  14_enemies_and_ai.md
  15_victory_and_leveling.md
  16_quest_system.md
  17_party_and_equipment.md
  18_save_and_load.md
  19_audio.md
  20_title_screen_and_game_flow.md
  21_finish_line.md
```

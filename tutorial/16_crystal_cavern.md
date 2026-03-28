# Module 16: The Crystal Cavern, Dungeon Design

## What We Have So Far

A town, a forest, a battle system with actions and animations, and an inventory. We need a destination, somewhere that tests the player's skills and rewards their preparation.

## What We're Building This Module

The **Crystal Cavern**: a dungeon area with a distinct tileset, multiple rooms connected by passages, treasure chests, encounter zones for random battles, a save crystal, and a boss room at the end. This is level design, not system design. We're applying everything we've learned about TileMaps, scene transitions, and interactables.

Dungeons are where RPGs test everything the player has prepared. In Zelda, each dungeon introduces a new item and then builds puzzles around mastering it. In Final Fantasy, dungeons are gauntlets that drain your party's resources over time -- each random battle costs HP and MP, and the question is whether you can reach the boss with enough left to win. A well-designed dungeon creates a rising tension curve: easy rooms at the start, harder encounters deeper in, a save point right before the climax, and a boss that demands everything you've learned.

## Dungeon vs Overworld Design

Dungeons differ from overworld areas in several ways:

| Aspect | Overworld (Willowbrook, Whisperwood) | Dungeon (Crystal Cavern) |
|--------|--------------------------------------|--------------------------|
| Tile palette | Grass, trees, paths, buildings | Cave walls, stone floor, crystals |
| Layout | Open, organic, free-roaming | Corridors, rooms, controlled flow |
| Collision | Boundary trees and water | Walls everywhere, tight spaces |
| Encounters | Occasional (forest only) | Frequent, every few steps |
| Items | Shops (buy) | Treasure chests (find) |
| Save points | Towns (convenient) | Rare (crystals, strategic) |
| Goal | Exploration and socializing | Challenge and progression |

## Cave Tileset Assets

You'll need cave or dungeon tiles for the Crystal Cavern. Here are your options:

**Option 1, free tileset pack:** Download the [Kenney 1-Bit Pack](https://kenney.nl/assets/1-bit-pack) which includes cave and dungeon tiles. Extract it and copy the relevant tile sheets to `res://assets/tilesets/`.

**Option 2, reuse and recolor:** Duplicate the TileSet from Module 5. Open the new TileSet resource, and in the Physics/Terrain tabs, you can reuse the same workflow. Many JRPG tileset packs include both outdoor and dungeon tiles in the same set.

**Option 3, placeholder tiles:** Create a simple cave palette with colored rectangles: dark grey for walls (e.g., `Color(0.25, 0.25, 0.3)`), lighter grey for walkable floor (`Color(0.45, 0.45, 0.5)`), and blue-purple for crystal decorations (`Color(0.4, 0.3, 0.7)`). In the TileSet editor, you can draw directly onto a new atlas.

**Recommended:** Use Option 3 (placeholder tiles) to keep moving without interruption. You can swap in real art later. Options 1-2 look better but require downloading and importing external assets.

Whichever approach you use, the TileSet creation workflow is the same as Module 5:

1. Create a TileSet resource: right-click `res://scenes/crystal_cavern/` → New Resource → TileSet
2. Set the **Tile Size** to `16x16` (must be done before adding an atlas)
3. In the TileSet panel, click **+** → Atlas → drag your cave tile sheet into the Texture slot
4. Click **Yes** when prompted to create tiles automatically
5. Switch to the Paint tab, select **Physics Layer 0**, and paint collision on wall tiles
6. Save the TileSet as `res://scenes/crystal_cavern/cave_tileset.tres`
7. Assign it to each TileMapLayer in the Inspector

If any of these steps feel unclear, revisit Module 5's "Creating the TileSet" section for the full walkthrough.

## Building the Cave Tilemap

Create `res://scenes/crystal_cavern/crystal_cavern.tscn` with the familiar layer structure, but using cave-themed tiles:

```
CrystalCavern (Node2D)
├── Ground (TileMapLayer)      : stone floors, cave ground
├── Detail (TileMapLayer)      : cracks, rubble, small crystals
├── YSortGroup (Node2D, y_sort_enabled)
│   ├── Objects (TileMapLayer) : large crystal formations, stalagmites
│   ├── Player (instance)
│   └── ... (treasure chests, save crystal)
├── AbovePlayer (TileMapLayer) : cave ceiling overhangs, arches
├── Exits (Node2D)
│   ├── ExitToWhisperwood (Area2D + exit_zone.gd)
│   └── ... (spawn points)
├── EncounterZones (Node2D)
│   ├── MainCorridor (Area2D + CollisionShape2D)
│   └── DeepCavern (Area2D + CollisionShape2D)
├── EncounterSystem (Node)
├── DialogueBox (instance)
└── InventoryScreen (instance)
```

### Room-Based Layout

Design the dungeon as connected rooms:

```
[Entrance] → [Main Corridor] → [Fork]
                                  ├→ [Dead End, Treasure]
                                  └→ [Deep Cavern] → [Boss Room]
                                       ↑
                                  [Save Crystal]
```

Each "room" is a region of the tilemap. Passages connect them. The fork creates a simple decision: explore the dead end for treasure, or push ahead toward the boss.

### Design Tips

- **Walls on all sides.** Unlike overworld areas with natural boundaries (trees, water), dungeon rooms need explicit walls. Fill everything with wall tiles, then carve out rooms and corridors.
- **Varied room shapes.** Rectangles are fine, but an L-shaped room or a round cavern adds visual interest.
- **Visual landmarks.** Place unique crystal formations or broken pillars at decision points so the player can orient themselves.
- **Width variety.** Tight corridors create tension. Open rooms offer relief. Alternate between them.

> **Spiral:** All the TileMapLayer skills from Module 5 apply here: multiple layers, physics on wall tiles, pixel-perfect settings. The only difference is the tile palette.

## Treasure Chests

Treasure chests are the oldest reward mechanism in RPGs. In the original Dragon Quest, finding a chest in a dungeon was a moment of genuine excitement -- the player risked death to explore a dead end and the chest validated that risk. Chests serve two design purposes: they reward exploration (players who check every corner find better gear) and they pace the dungeon (a Potion in a mid-dungeon chest might be the difference between reaching the boss and having to retreat).

A chest is an interactable that gives the player an item. It's a reusable scene.

Create `res://entities/interactable/treasure_chest.tscn`:

```
TreasureChest (StaticBody2D)
├── Sprite (Sprite2D)          : closed/open chest image
├── CollisionShape2D           : blocks walking through
├── InteractionZone (Area2D)
│   └── CollisionShape2D
└── InteractionPrompt (Label, hidden)  : text "!", font_size 12
```

> **Note:** We use a `Label` for the interaction prompt (just like the NPC prompt in Module 10) because it works without any art assets. If you prefer, you can swap it for a `Sprite2D` with a custom icon later.

Script `res://entities/interactable/treasure_chest.gd`:

```gdscript
extends StaticBody2D
## A treasure chest that gives the player an item when opened.

signal opened

@export var item: ItemData
@export var item_count: int = 1
@export var chest_id: String = ""  # Unique ID for save/load tracking

var is_opened: bool = false

@onready var _sprite: Sprite2D = $Sprite
@onready var _prompt: Label = $InteractionPrompt
@onready var _zone: Area2D = $InteractionZone

var _player_in_range: bool = false


func _ready() -> void:
    _zone.body_entered.connect(_on_body_entered)
    _zone.body_exited.connect(_on_body_exited)
    _prompt.visible = false
    add_to_group("interactables")


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range or is_opened:
        return
    if event.is_action_pressed("interact"):
        _open()
        get_viewport().set_input_as_handled()


func _open() -> void:
    is_opened = true
    _prompt.visible = false
    # Change sprite to open chest (if you have one)
    # _sprite.frame = 1  # or swap texture

    if item:
        InventoryManager.add_item(item, item_count)
        print("Found: " + item.display_name + " x" + str(item_count))

    opened.emit()


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and not is_opened:
        _player_in_range = true
        _prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _prompt.visible = false
```

Place chests in the dungeon using the editor:
- **Dead End room:** A Potion and an Ether
- **Before boss room:** An Iron Sword (if the player hasn't bought one)

Set the `@export var item` in the Inspector by dragging the `.tres` file into the slot.

## The Save Crystal

The save crystal before a boss room is one of the most recognizable design patterns in JRPGs. In every Final Fantasy game, seeing that glowing crystal means two things: "danger is ahead" and "you won't lose your progress." Save points are as much a narrative device as a mechanical one -- they build anticipation. The absence of save points in a long corridor creates anxiety; their appearance after a tough fight creates relief.

A classic JRPG save point, a glowing crystal the player interacts with. For now, it just prints "Game saved!". We'll wire it to the actual save system in Module 22.

Create `res://entities/interactable/save_crystal.tscn`:

```
SaveCrystal (StaticBody2D)
├── Sprite (Sprite2D)          : crystal image (use any placeholder sprite)
├── CollisionShape2D           : blocks walking through (RectangleShape2D, 16x16)
├── InteractionZone (Area2D)
│   └── CollisionShape2D       : interaction radius (CircleShape2D, radius ~24)
└── InteractionPrompt (Label, visible = false)  : text "!", font_size 12
```

Script `res://entities/interactable/save_crystal.gd`:

```gdscript
extends StaticBody2D
## A save crystal. Lets the player save their game.

var _player_in_range: bool = false

@onready var _prompt: Label = $InteractionPrompt
@onready var _zone: Area2D = $InteractionZone


func _ready() -> void:
    _zone.body_entered.connect(_on_body_entered)
    _zone.body_exited.connect(_on_body_exited)
    _prompt.visible = false
    add_to_group("save_points")


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range:
        return
    if event.is_action_pressed("interact"):
        _activate()
        get_viewport().set_input_as_handled()


func _activate() -> void:
    # Module 22 will add actual saving here
    print("Your progress has been saved!")
    # Optional: heal the party at save points (common JRPG pattern)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _prompt.visible = false
```

Place the save crystal in the room before the boss, the classic "save point before the big fight" pattern.

## Encounter Zones

Encounter zones define where random battles can happen and which enemies appear. We'll set up the zones now and wire them to the encounter system in Module 17.

Add `Area2D` nodes to mark the encounter regions. For now, just create the Area2D nodes with CollisionShape2D children, but **don't attach scripts yet**. We'll create the encounter system and encounter zone scripts in Module 17.

For each encounter zone:
1. Create an **Area2D** node (e.g., `MainCorridor`) as a child of `EncounterZones`.
2. Add a **CollisionShape2D** child with a **RectangleShape2D**.
3. Size the rectangle to cover the room or corridor where encounters should happen (e.g., 200x100 pixels for a corridor).

Also add an **EncounterSystem** node (plain `Node`) as a direct child of the `CrystalCavern` root, **not** inside `EncounterZones`. We'll attach a script to this in Module 17.

Place two zones:
- **MainCorridor** covers the entrance corridor (easy enemies)
- **DeepCavern** covers the deeper rooms (harder enemies)

## The Boss Room Door

A locked passage that requires a key item or a quest flag. Create `res://entities/interactable/boss_door.tscn`:

```
BossDoor (StaticBody2D)
├── Sprite (Sprite2D)
├── CollisionShape2D
├── InteractionZone (Area2D)
│   └── InteractionShape (CollisionShape2D, larger radius)
└── InteractionPrompt (Label, text "!", visible = false)
```

Save the script as `res://entities/interactable/boss_door.gd`:

```gdscript
extends StaticBody2D
## A locked door that opens when the player has the right item or flag.

@export var required_item_id: String = ""
@export var unlock_message: String = "The door is locked."
@export var open_message: String = "The door opens!"

var is_unlocked: bool = false
var _player_in_range: bool = false

@onready var _interaction_zone: Area2D = $InteractionZone
@onready var _interaction_prompt: Label = $InteractionPrompt


func _ready() -> void:
    _interaction_zone.body_entered.connect(_on_body_entered)
    _interaction_zone.body_exited.connect(_on_body_exited)
    _interaction_prompt.visible = false


func _unhandled_input(event: InputEvent) -> void:
    if not _player_in_range or is_unlocked:
        return
    if event.is_action_pressed("interact"):
        _try_open()
        get_viewport().set_input_as_handled()


func _try_open() -> void:
    if required_item_id.is_empty() or InventoryManager.has_item(required_item_id):
        is_unlocked = true
        print(open_message)
        queue_free()
    else:
        print(unlock_message)


func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = true
        _interaction_prompt.visible = true


func _on_body_exited(body: Node2D) -> void:
    if body.is_in_group("player"):
        _player_in_range = false
        _interaction_prompt.visible = false
```

For Crystal Saga, the boss room door could require a "Crystal Key" found in the treasure room, creating a simple puzzle: explore the dead end before you can face the boss.

## Connecting the Scenes

Add scene transitions:
- **Whisperwood south exit** → Crystal Cavern entrance
- **Crystal Cavern entrance** → back to Whisperwood

Add spawn points (Marker2D nodes as children of Exits, added to the `spawn_points` group):
- `from_whisperwood` at the cave entrance
- `default` same position as `from_whisperwood`

> **See:** [TileMapLayer](https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html), the node used for each tile layer. Same class as Module 5, now with a cave tileset.

> **See:** [StaticBody2D](https://docs.godotengine.org/en/stable/classes/class_staticbody2d.html), used for treasure chests, save crystals, and boss doors (solid, non-moving objects).

> **See:** [Area2D](https://docs.godotengine.org/en/stable/classes/class_area2d.html), used for interaction zones and encounter regions. The `body_entered`/`body_exited` signals detect when the player enters.

## What We've Learned

- **Dungeon design** uses tight corridors, connected rooms, and controlled flow, different from open overworld areas.
- **Treasure chests** are interactable StaticBody2D nodes with `@export var item: ItemData`.
- **Save crystals** mark locations where the player can save (wired in Module 22).
- **Encounter zones** (Area2D) define regions where random battles trigger.
- **Locked doors** check for key items before opening, a simple puzzle design.
- **Room-based layout** with forks, dead ends, and a boss room creates exploration incentive.

## What You Should See

When you enter Crystal Cavern from Whisperwood:
- A distinct cave tilemap with stone floors and crystal walls
- Multiple connected rooms with corridors between them
- Treasure chests that give items when opened
- A save crystal that responds to interaction
- A boss room door at the far end
- Encounter zones marked (we'll add random battles next module)

## Next Module

The dungeon exists but is quiet, with no monsters. In **Module 17: Enemies and AI**, we'll create enemy types, build an encounter system that triggers random battles as you walk, design basic enemy AI, and create the Crystal Guardian boss.

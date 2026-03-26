# Module 21: Finish Line — Polish, Export, and Next Steps

## What We Have

A complete JRPG. Let that sink in. Over 20 modules, you've built:

- A tile-based overworld with three connected areas
- An animated player character with a state machine
- Scene transitions with fade effects
- NPCs with dialogue, a typewriter text effect, and branching choices
- A data-driven architecture using custom Resources
- An inventory system with consumable items
- A turn-based battle system with a node-based state machine
- Player actions: attack, defend, magic, items
- Enemy AI with three behavior types
- Random encounters with weighted probability
- A dungeon with treasure chests, a save crystal, and a boss fight
- XP, leveling, stat growth, and loot drops
- A quest system with game flags and reactive dialogue
- Party management with a recruitable companion
- Equipment that modifies combat stats
- Shops and an inn
- Save and load with JSON serialization
- Background music with crossfading
- Sound effects via audio buses
- A title screen, pause menu, ending, and credits
- A complete game loop

That's a real game. Not a demo, not a prototype — a playable JRPG with every major system in place. Everything else is content and polish.

## Playtesting Walkthrough

Play through Crystal Saga from start to finish and verify each checkpoint:

### 1. Title Screen
- [ ] Title screen appears on launch
- [ ] "New Game" starts with correct initial state (3 Potions, 100 gold, Aiden only)
- [ ] "Continue" is disabled when no saves exist

### 2. Willowbrook
- [ ] Player spawns in town center
- [ ] Town music plays
- [ ] Walking into NPCs shows interaction prompt
- [ ] Shopkeeper opens the shop (buy Potions, equipment)
- [ ] Innkeeper offers rest for 10 gold
- [ ] Fynn mentions his lost pendant (starts quest)
- [ ] Lira can be recruited after two conversations

### 3. Whisperwood
- [ ] Music crossfades when entering the forest
- [ ] Random encounters trigger after walking
- [ ] Battles work: actions, damage, animations, victory
- [ ] XP and gold are awarded after battles
- [ ] Level-ups show stat increases
- [ ] The pendant can be found (requires a pickup object in Whisperwood — see Module 13's treasure chest pattern)

### 4. Crystal Cavern
- [ ] Dungeon music plays
- [ ] Treasure chests give items
- [ ] Save crystal saves the game
- [ ] Encounter zones have harder enemies
- [ ] Boss room door requires the Crystal Key (if you created this item — otherwise leave `required_item_id` empty)
- [ ] Crystal Guardian dialogue plays before the fight

### 5. Boss Battle
- [ ] Boss has higher stats, tougher fight
- [ ] Defeating the boss triggers the ending
- [ ] Game over on party wipe returns to title

### 6. Ending and Credits
- [ ] Ending text displays after boss
- [ ] Credits scroll and return to title
- [ ] "Continue" loads the save (if the player saved before the boss)

### 7. Systems Integration
- [ ] Save/load preserves all state correctly
- [ ] Quest log shows correct objective states
- [ ] Equipment changes are reflected in battle
- [ ] Pause menu works at any time
- [ ] Audio volume controls work during the session (persistence requires the optional settings save extension from Module 19)

## Common Bugs and Fixes

### "Player walks through walls"
- **Cause:** TileMap tiles don't have physics collision set.
- **Fix:** Select the tile in the TileSet editor, add collision on the Physics Layer.

### "Scene change crashes with null reference"
- **Cause:** Code runs on a node that was just freed during scene change.
- **Fix:** Check `is_instance_valid(node)` before accessing nodes during transitions.

### "Dialogue box doesn't advance"
- **Cause:** Input event consumed by another system.
- **Fix:** Ensure the dialogue box uses `_unhandled_input()` and calls `set_input_as_handled()`.

### "Enemy HP goes negative"
- **Cause:** `take_damage()` doesn't clamp to 0.
- **Fix:** `current_hp = max(0, current_hp - damage)`.

### "Save file loads wrong data"
- **Cause:** Resource paths changed since the save was written.
- **Fix:** Use stable paths. Add a version field to saves for migration.

### "Music plays over itself"
- **Cause:** MusicManager not checking if the same track is already playing.
- **Fix:** Check `track_path == _current_track_path` before starting.

### "Inventory shows stale data after using an item in battle"
- **Cause:** Battle creates a new Tween that outlives the inventory reference.
- **Fix:** Refresh inventory UI on `inventory_changed` signal.

## Performance Basics

2D JRPGs are not performance-intensive, but a few things to watch:

### Avoid `_process()` on everything
Nodes with empty `_process()` methods still cost a function call per frame. Remove the template `_process()` from scripts that don't need per-frame updates.

### Cache node references with `@onready`
```gdscript
# Good: cached once
@onready var sprite: Sprite2D = $Sprite

# Bad: looked up every frame
func _process(delta):
    get_node("Sprite").visible = true
```

### Object pool for damage numbers
If you're creating many floating damage numbers per battle, consider reusing label nodes instead of creating and freeing them each time.

### TileMap optimization
Large tilemaps with thousands of tiles are fine — Godot optimizes them into rendering quadrants. But avoid calling `set_cell()` in `_process()`.

> **See:** [Performance best practices](https://docs.godotengine.org/en/stable/tutorials/performance/general_optimization.html) — the official performance guide.

## Exporting the Game

### Step 1: Install Export Templates

Go to **Editor → Manage Export Templates → Download and Install**. This downloads platform-specific build templates.

### Step 2: Create an Export Preset

1. Go to **Project → Export**.
2. Click **Add...** and choose your platform (Windows, macOS, or Linux).
3. Configure the preset name and output path.

### Step 3: Build

Click **Export Project** and choose where to save the build. Godot creates a standalone executable plus a `.pck` file containing all your game data.

Your game is now a real, distributable application.

> **See:** [Exporting projects](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html) — the full export guide for all platforms.

## Where to Go from Here

Crystal Saga is a foundation. Here's what you could add next, in rough order of complexity:

### More Content (Easy)
- New areas, NPCs, and quests using the existing systems
- More enemy types and encounter groups
- Additional items and equipment
- Extended dialogue for existing NPCs

### Status Effects System (Medium)
Generalize the Defend buff from Module 12 into a full system:
- **Poison:** Lose HP each turn (3 turns)
- **Sleep:** Skip turn, wakes on damage
- **Stun:** Skip one turn
- **Regen:** Heal HP each turn
- Each effect: type, duration (turns remaining), magnitude, tick behavior

### Elemental Weakness/Resistance (Medium)
Add elements to abilities and enemies:
- Fire, Ice, Lightning, Earth, Light, Dark
- Weakness = 2x damage, Resistance = 0.5x damage
- Adds strategic depth to magic and enemy design

### Limit Breaks (Medium)
Special abilities that charge as a character takes damage:
- A "limit gauge" that fills from 0 to 100
- At 100, a powerful unique ability becomes available
- Each character has a different limit break

### Advanced Dialogue (Medium-Hard)
- Speaker portraits that animate during dialogue
- Animated text effects (shake, wave, color change) via BBCode
- Cutscene system with camera movement and character positioning

### More Party Members (Medium)
Each new character needs: CharacterData, abilities, recruitment event, and unique battle behavior. The systems already support it — just add content.

### Procedural Dungeons (Hard)
Generate cave layouts from room templates:
- Define room shapes as small TileMapLayer sections
- Connect them with corridors via a generation algorithm
- Place enemies, chests, and the boss procedurally

### Controller Support Polish (Easy-Medium)
- Detect connected controller type (Xbox, PlayStation, Switch)
- Show matching button prompts in UI
- Analog stick deadzone tuning
- Vibration/rumble on hits

### Mobile Export (Medium)
- Touch controls (virtual D-pad, action buttons)
- Screen scaling for different aspect ratios
- Touch-friendly UI with larger buttons

## Recommended Resources

### Learning
- **[GDQuest](https://www.gdquest.com/)** — High-quality Godot tutorials and courses
- **[KidsCanCode](https://kidscancode.org/godot_recipes/)** — Godot recipes and patterns
- **[Official Godot docs](https://docs.godotengine.org/)** — The reference we've cited throughout
- **[Godot community forums](https://forum.godotengine.org/)** — Help and discussion

### Assets
- **[Kenney](https://kenney.nl/)** — Free, high-quality 2D/3D game assets
- **[OpenGameArt](https://opengameart.org/)** — Community-contributed free art
- **[itch.io asset packs](https://itch.io/game-assets)** — Free and paid 2D art, including JRPG-specific packs
- **[Time Fantasy](https://finalbossblues.com/timefantasy/)** — Professional JRPG tile and sprite packs

### Tools
- **[Aseprite](https://www.aseprite.org/)** — Pixel art editor (paid, open source)
- **[Tiled](https://www.mapeditor.org/)** — External tilemap editor (free)
- **[Audacity](https://www.audacityteam.org/)** — Audio editing (free)

## What You've Accomplished

You started with an empty Godot project and a blinking cursor. Twenty-one modules later, you have:

- **Thousands of lines of GDScript** across dozens of scripts
- **7 autoloads** managing global game state (SceneManager, InventoryManager, GameManager, QuestManager, PartyManager, SaveManager, MusicManager)
- **3 game areas** with hand-crafted tilemaps
- **A complete battle system** with state machines, AI, and animations
- **5 interlocking systems** (inventory, quests, party, save/load, audio)
- **A playable game** with a beginning, middle, and end

More importantly, you've learned the **patterns** that scale. The state machine pattern works for player movement, battle flow, quest tracking, and dialog flow. The Resource pattern works for items, characters, enemies, quests, and encounters. The autoload pattern works for scene management, inventory, battle, quests, party, and audio. These patterns repeat everywhere in game development, not just in JRPGs.

## Closing Thoughts

JRPGs are a labor of love. They require patience — for building systems, crafting worlds, writing dialogue, balancing combat, and testing everything together. But they're also one of the most rewarding genres to build, because every system connects to every other system, and when they all work together, the result is a game that feels whole.

Crystal Saga is small by commercial standards, but it's architecturally complete. You can expand it in any direction: more story, more areas, more characters, more mechanics. The foundation supports it.

The most important thing you can do now is **keep building**. Pick one of the "where to go from here" suggestions that excites you, and implement it. Then another. Each addition teaches you something new, and each one makes the game more yours.

Good luck. The world needs more JRPGs.

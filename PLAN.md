# Gemini Fantasy — Bootstrap Demo Implementation Plan

## Goal

Create a playable vertical slice demo covering the opening of Act I: Kael discovers Lyra in the ruins near Roothollow, recruits Iris, and completes the first combat encounters. The demo should showcase:

- Overworld exploration (Roothollow + surrounding forest)
- NPC interaction and dialogue
- Turn-based combat with the Resonance system
- Party management (Kael → Kael+Iris → Kael+Iris+Garrick)
- Echo collection (finding Lyra as a Conscious Echo)
- Basic UI (HUD, battle UI, dialogue box, pause menu)

---

## Architecture Overview

### Directory Structure (to be created)

```
game/
├── autoloads/                  # Global singletons
│   ├── game_manager.gd         # Game state, scene transitions
│   ├── battle_manager.gd       # Battle initiation and flow
│   ├── party_manager.gd        # Party roster and active party
│   ├── audio_manager.gd        # BGM/SFX playback
│   └── dialogue_manager.gd     # Dialogue queue and display
├── resources/                  # Custom Resource classes
│   ├── character_data.gd       # Character stats, growth rates
│   ├── enemy_data.gd           # Enemy definitions
│   ├── ability_data.gd         # Skill/ability definitions
│   ├── item_data.gd            # Consumable/equipment definitions
│   └── echo_data.gd            # Echo Fragment definitions
├── data/                       # .tres instances
│   ├── characters/             # Kael, Iris, Garrick .tres
│   ├── enemies/                # Memory Bloom, Ash Stalker, etc.
│   ├── abilities/              # Echo Strike, Heavy Strike, etc.
│   ├── items/                  # Potion, Ether, etc.
│   └── echoes/                 # Starting echoes
├── systems/                    # Core game systems
│   ├── battle/                 # Battle scene, state machine, turn queue
│   │   ├── battle_scene.tscn
│   │   ├── battle_scene.gd
│   │   ├── battle_state_machine.gd
│   │   ├── turn_queue.gd
│   │   ├── battler.gd          # Base battler component
│   │   ├── party_battler.gd    # Player-controlled battler
│   │   └── enemy_battler.gd    # AI-controlled battler
│   ├── dialogue/               # Dialogue box and data
│   │   ├── dialogue_box.tscn
│   │   └── dialogue_box.gd
│   └── state_machine/          # Generic state machine
│       ├── state_machine.gd
│       └── state.gd
├── entities/                   # Game entities
│   ├── player/
│   │   ├── player.tscn
│   │   └── player.gd
│   ├── npc/
│   │   ├── npc.tscn
│   │   └── npc.gd
│   └── interactable/
│       ├── interactable.tscn
│       └── interactable.gd
├── scenes/                     # Level scenes
│   ├── title_screen/
│   │   ├── title_screen.tscn
│   │   └── title_screen.gd
│   ├── roothollow/
│   │   ├── roothollow.tscn     # Town hub
│   │   └── roothollow.gd
│   ├── verdant_forest/
│   │   ├── verdant_forest.tscn # Overworld around Roothollow
│   │   └── verdant_forest.gd
│   └── overgrown_ruins/
│       ├── overgrown_ruins.tscn # First dungeon area
│       └── overgrown_ruins.gd
├── ui/                         # UI scenes
│   ├── hud/
│   │   ├── hud.tscn
│   │   └── hud.gd
│   ├── battle_ui/
│   │   ├── battle_ui.tscn      # Command menu, HP bars, turn order
│   │   └── battle_ui.gd
│   ├── pause_menu/
│   │   ├── pause_menu.tscn
│   │   └── pause_menu.gd
│   └── party_display/
│       ├── party_display.tscn  # Party status in menus
│       └── party_display.gd
└── assets/                     # (already exists with sprites)
```

---

## Implementation Phases

### Phase 0: Foundation (Must complete first — blocks everything)

These are the core building blocks every other system depends on.

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 0.1 | Generic State Machine | `/new-system state-machine` | `state_machine.gd`, `state.gd` | Nothing |
| 0.2 | Input Actions | `/setup-input` | project.godot input map | Nothing |
| 0.3 | GameManager autoload | `/new-system game-manager` | Scene transitions, game state tracking | 0.1 |
| 0.4 | AudioManager autoload | `/new-system audio` | BGM/SFX playback, audio buses | Nothing |

### Phase 1: Data Layer (Resource classes + .tres files)

Define all data structures before building systems that use them.

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 1.1 | CharacterData Resource | `/new-resource CharacterData` | Stats, growth rates, equipment slots | Nothing |
| 1.2 | AbilityData Resource | `/new-resource AbilityData` | Cost, damage, targeting, effects | Nothing |
| 1.3 | EnemyData Resource | `/new-resource EnemyData` | Stats, loot, AI type, abilities | Nothing |
| 1.4 | ItemData Resource | `/new-resource ItemData` | Type, effect, value, stack size | Nothing |
| 1.5 | EchoData Resource | `/new-resource EchoData` | Rarity, type, effect, lore text | Nothing |
| 1.6 | Seed character data | `/seed-game-data characters` | Kael, Iris, Garrick .tres | 1.1 |
| 1.7 | Seed ability data | `/seed-game-data abilities` | Early-game abilities .tres | 1.2 |
| 1.8 | Seed enemy data | `/seed-game-data enemies` | Memory Bloom, Ash Stalker, Creeping Vine .tres | 1.3 |
| 1.9 | Seed item data | `/seed-game-data items` | Potion, Ether, Antidote .tres | 1.4 |
| 1.10 | Seed echo data | `/seed-game-data echoes` | 3-4 starter echoes .tres | 1.5 |

### Phase 2: Core Game Systems

Build the managers and systems that power gameplay.

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 2.1 | PartyManager autoload | `/new-system party` | Party roster, active party, add/remove | 1.1, 1.6 |
| 2.2 | Battle System | `/new-system combat` | BattleScene, TurnQueue, Battler, state machine | 0.1, 0.3, 1.1-1.3 |
| 2.3 | Dialogue System | `/new-system dialogue` | DialogueManager + DialogueBox scene | 0.3 |
| 2.4 | Resonance System | `/implement-feature resonance` | Gauge, states (Focused/Resonant/Overload/Hollow) | 2.2 |

### Phase 3: Entities (Player, NPCs, Enemies)

Build the interactive entities that populate the world.

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 3.1 | Player character scene | `/new-scene character player` | Player.tscn with movement, interaction | 0.2, 0.3 |
| 3.2 | NPC base scene | `/new-scene npc base_npc` | NPC.tscn with dialogue trigger | 2.3 |
| 3.3 | Interactable base scene | `/new-scene item interactable` | Interactable.tscn for chests, signs, etc. | 0.3 |
| 3.4 | Party battler scene | `/new-scene character party_battler` | Battle sprite + action interface | 2.2 |
| 3.5 | Enemy battler scene | `/new-scene enemy enemy_battler` | Battle sprite + AI controller | 2.2 |

### Phase 4: UI Layer

Build all user-facing interface screens.

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 4.1 | Title Screen | `/new-ui title-screen title` | New Game / Continue / Settings | 0.3 |
| 4.2 | Overworld HUD | `/new-ui hud overworld_hud` | Mini-map placeholder, party HP | 2.1 |
| 4.3 | Battle UI | `/new-ui battle-hud battle_ui` | Command menu, HP/EE bars, turn order, Resonance gauge | 2.2, 2.4 |
| 4.4 | Dialogue Box | `/new-ui dialogue dialogue_box` | Text box with typewriter, portraits, advance indicator | 2.3 |
| 4.5 | Pause Menu | `/new-ui pause-menu pause` | Party status, items, save, quit | 2.1 |

### Phase 5: Levels & World

Build the actual playable spaces.

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 5.1 | Roothollow town | `/build-level roothollow town` | Town hub with NPCs, shops, inn | 3.1, 3.2 |
| 5.2 | Verdant Forest (overworld) | `/build-level verdant_forest overworld` | Forest area with encounter zones | 3.1 |
| 5.3 | Overgrown Ruins (dungeon) | `/build-level overgrown_ruins dungeon` | First dungeon with encounters, Lyra discovery | 3.1, 3.3 |

### Phase 6: Integration & Demo Flow

Wire everything together into a playable sequence.

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 6.1 | Opening cutscene/dialogue | `/implement-feature opening-sequence` | Kael in ruins, finds Lyra | 5.3, 2.3 |
| 6.2 | Random encounter system | `/implement-feature random-encounters` | Step counter, weighted enemy groups | 2.2, 5.2 |
| 6.3 | Scene transitions | `/implement-feature scene-transitions` | Fade in/out between areas | 0.3 |
| 6.4 | Iris recruitment event | `/implement-feature iris-recruitment` | Story event + joins party | 2.1, 2.3, 5.2 |
| 6.5 | Garrick recruitment event | `/implement-feature garrick-recruitment` | Story event + joins party | 2.1, 2.3, 5.1 |
| 6.6 | Quality pass | `/playtest-check` + `/integration-check` + `/gdscript-review` | Bug fixes, cleanup | All above |

---

## Agent Team Plan

### Team Structure: 5 Agents

Given the dependency graph, we can parallelize significantly. Here's the optimal team:

#### Agent 1: "foundation" — Core Systems Architect
**Role**: Builds the foundational systems everything else depends on.
**Phase 0 + Phase 2 work**:
1. `/new-system state-machine` → Generic state machine
2. `/setup-input` → Input actions (move, interact, cancel, menu, attack, defend)
3. `/new-system game-manager` → GameManager autoload (scene transitions, game state)
4. `/new-system audio` → AudioManager autoload
5. `/new-system party` → PartyManager autoload
6. `/new-system combat` → BattleManager + BattleScene + TurnQueue
7. `/implement-feature resonance` → Resonance gauge and state system
8. `/new-system dialogue` → DialogueManager + DialogueBox

**Why one agent**: These systems have sequential dependencies (state machine → game manager → battle system → resonance). Splitting them would cause constant blocking.

#### Agent 2: "data" — Data Architect
**Role**: Creates all Resource classes and populates .tres data files.
**Phase 1 work**:
1. `/new-resource CharacterData` → Stats, growth, equipment
2. `/new-resource AbilityData` → Cost, damage, targeting
3. `/new-resource EnemyData` → Stats, AI, loot
4. `/new-resource ItemData` → Type, effect, value
5. `/new-resource EchoData` → Rarity, effect, lore
6. `/seed-game-data characters` → Kael, Iris, Garrick .tres
7. `/seed-game-data abilities` → Early abilities (Echo Strike, Heavy Strike, Guardian's Stand, etc.)
8. `/seed-game-data enemies` → Memory Bloom, Ash Stalker, Creeping Vine, Cinder Wisp
9. `/seed-game-data items` → Potion, Ether, Antidote, Phoenix Down
10. `/seed-game-data echoes` → 3-4 starting echoes

**Why separate**: Resource classes have zero dependencies on systems. This agent can work in complete parallel with Agent 1 from the start.

#### Agent 3: "entities" — Entity Builder
**Role**: Builds player, NPC, and battle entity scenes.
**Phase 3 work** (starts after Agent 1 finishes core systems):
1. `/new-scene character player` → Player.tscn with 4-directional movement, interaction
2. `/new-scene npc base_npc` → NPC.tscn with dialogue trigger area
3. `/new-scene item interactable` → Interactable.tscn (chests, signs, save points)
4. `/new-scene character party_battler` → Battle sprite with action selection
5. `/new-scene enemy enemy_battler` → Enemy battle sprite with AI

**Blocks on**: Agent 1 (needs state machine, input, game manager, battle system)

#### Agent 4: "ui" — UI Developer
**Role**: Builds all UI screens and connects them to systems.
**Phase 4 work** (starts after Agent 1 finishes core systems):
1. `/new-ui title-screen title` → Title screen with menu
2. `/new-ui hud overworld_hud` → Overworld HUD
3. `/new-ui battle-hud battle_ui` → Full battle interface
4. `/new-ui dialogue dialogue_box` → Dialogue box with typewriter
5. `/new-ui pause-menu pause` → Pause menu with party info

**Blocks on**: Agent 1 (needs game manager, battle system, dialogue system, party manager)

#### Agent 5: "levels" — Level Designer
**Role**: Builds playable levels and wires together the demo flow.
**Phase 5 + 6 work** (starts after entities + UI exist):
1. `/build-level roothollow town` → Town hub
2. `/build-level verdant_forest overworld` → Forest with encounters
3. `/build-level overgrown_ruins dungeon` → First dungeon
4. `/implement-feature scene-transitions` → Fade transitions
5. `/implement-feature random-encounters` → Step-based encounters
6. `/implement-feature opening-sequence` → Lyra discovery event
7. `/implement-feature iris-recruitment` → Iris joins party
8. `/implement-feature garrick-recruitment` → Garrick joins party

**Blocks on**: Agents 3 + 4 (needs player, NPCs, UI to place in levels)

---

## Execution Timeline

```
Time ──────────────────────────────────────────────────────►

Agent 1 (foundation):
  ████████████████████████████████░░░░░░░░░░░░░░░░░░░░░░░░
  [state-machine][input][game-mgr][audio][party][combat][resonance][dialogue]

Agent 2 (data):
  ████████████████████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
  [resources x5][seed characters][seed abilities][seed enemies][seed items][seed echoes]

Agent 3 (entities):                    ← waits for foundation
  ░░░░░░░░░░░░░░░░░░████████████████░░░░░░░░░░░░░░░░░░░░░
                     [player][npc][interactable][party-battler][enemy-battler]

Agent 4 (ui):                          ← waits for foundation
  ░░░░░░░░░░░░░░░░░░████████████████░░░░░░░░░░░░░░░░░░░░░
                     [title][hud][battle-ui][dialogue-box][pause-menu]

Agent 5 (levels):                                 ← waits for entities + ui
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████████████████████░░
                                    [roothollow][forest][ruins][transitions][encounters][events]

Quality Pass (all agents):
  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░████
                                                      [playtest-check][integration-check][review]
```

### Parallelism Summary

| Time Slot | Active Agents | Work |
|-----------|--------------|------|
| Start | Agent 1 + Agent 2 | Foundation systems + Data layer (fully parallel) |
| After foundation done | Agent 3 + Agent 4 | Entities + UI (fully parallel with each other) |
| After entities + UI done | Agent 5 | Levels + demo integration |
| Final | All available | Quality checks in parallel |

---

## Demo Scope: What the Player Experiences

1. **Title Screen** → New Game
2. **Overgrown Ruins** → Kael exploring alone, tutorial combat vs Memory Blooms
3. **Lyra Discovery** → Cutscene dialogue, Lyra asks for help
4. **Verdant Forest** → Walk back toward Roothollow, random encounters (Creeping Vines, Ash Stalkers)
5. **Iris Recruitment** → Find Iris fighting Initiative soldiers, help her, she joins party
6. **Roothollow** → Hub area: inn (heal), shop (buy items), NPCs (lore), save point
7. **Garrick Recruitment** → Meet Garrick in Roothollow, story dialogue, he joins
8. **Return to Ruins** → With full 3-person party, deeper exploration
9. **Demo End** → "To be continued" after reaching a story milestone

### Combat Encounters in Demo

| Location | Enemies | Difficulty |
|----------|---------|-----------|
| Overgrown Ruins (solo) | 1-2 Memory Blooms | Tutorial |
| Verdant Forest | 2-3 Creeping Vines | Easy |
| Verdant Forest | 2 Ash Stalkers | Easy-Medium |
| Forest (Iris event) | 3 Initiative Soldiers | Medium (with Iris) |
| Ruins (3-person) | Mixed groups | Medium |

### Systems Exercised in Demo

- [x] 4-directional movement with sprite animation
- [x] NPC interaction and dialogue with portraits
- [x] Turn-based combat with full command menu
- [x] Resonance gauge building and Overload state
- [x] Echo Fragment usage in battle (1-2 equipped echoes)
- [x] Item usage (potions, ethers)
- [x] Party member recruitment mid-game
- [x] Scene transitions with fade effect
- [x] Random encounters in overworld
- [x] Town hub with services (inn heal, shop)
- [x] Pause menu with party status
- [x] Basic save/load (stretch goal — can defer)

---

## What We're NOT Building Yet

To keep scope manageable, these are explicitly deferred:

- **Save/Load system** — Can add post-demo
- **Equipment system** — Characters use default gear
- **Skill trees** — Characters have fixed abilities for demo
- **Echo tuning/crafting** — Just basic echo usage
- **Camp system** — Defer to Phase 2
- **World map / fast travel** — Single region only
- **Side quests** — Main story path only
- **Multiple difficulty modes** — Normal only
- **Character bonding** — Defer relationship system
- **Mini-games** — No Echo Arena or Archaeology
- **Vehicles** — Walking only

---

## Success Criteria

The demo is complete when:

1. Player can walk around all three areas (ruins, forest, town)
2. Player can talk to NPCs and see dialogue with portraits
3. Player can fight random encounters with full turn-based combat
4. Resonance gauge builds and Overload state triggers correctly
5. Party grows from 1 → 2 → 3 members through story events
6. All three party members have distinct battle roles
7. Items and Echoes are usable in combat
8. Scene transitions work smoothly between all areas
9. `/playtest-check` passes with no critical issues
10. `/integration-check` shows all systems properly wired

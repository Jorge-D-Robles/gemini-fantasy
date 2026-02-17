# Gemini Fantasy — Bootstrap Demo Implementation Plan

## Goal

Create a playable vertical slice demo covering the opening of Act I: Kael discovers Lyra in the ruins near Roothollow, recruits Iris, and completes the first combat encounters. The demo should showcase:

- Overworld exploration (Roothollow + surrounding forest)
- NPC interaction and dialogue with lore-rich environmental storytelling
- Turn-based combat with the Resonance system
- Party management (Kael → Kael+Iris → Kael+Iris+Garrick)
- Echo collection (finding Lyra as a Conscious Echo)
- **Echo Tuning** on equipment
- **Camp System** for healing and party bonding
- **Side Quest** based on world anomalies
- Basic UI (HUD, battle UI, dialogue box, pause menu, camp UI)

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
│   ├── dialogue_manager.gd     # Dialogue queue and display
│   ├── tuning_manager.gd       # Equipment modification
│   └── camp_manager.gd         # Camp state and interactions
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
│   ├── dialogue/               # Dialogue box and data
│   ├── tuning/                 # Tuning system logic
│   ├── camp/                   # Camp system logic
│   └── state_machine/          # Generic state machine
├── entities/                   # Game entities
│   ├── player/
│   ├── npc/
│   └── interactable/
├── scenes/                     # Level scenes
│   ├── title_screen/
│   ├── roothollow/
│   ├── verdant_forest/
│   └── overgrown_ruins/
├── ui/                         # UI scenes
│   ├── hud/
│   ├── battle_ui/
│   ├── pause_menu/
│   ├── camp_ui/                # Tuning and Rest interface
│   └── party_display/
└── assets/                     # (already exists with sprites)
```

---

## Implementation Phases

### Phase 0: Foundation (Must complete first — blocks everything)

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 0.1 | Generic State Machine | `/new-system state-machine` | `state_machine.gd`, `state.gd` | Nothing |
| 0.2 | Input Actions | `/setup-input` | project.godot input map | Nothing |
| 0.3 | GameManager autoload | `/new-system game-manager` | Scene transitions, game state tracking | 0.1 |
| 0.4 | AudioManager autoload | `/new-system audio` | BGM/SFX playback, audio buses | Nothing |

### Phase 1: Data Layer (Resource classes + .tres files)

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 1.1 | CharacterData Resource | `/new-resource CharacterData` | Stats, growth, equipment slots | Nothing |
| 1.2 | AbilityData Resource | `/new-resource AbilityData` | Cost, damage, effects | Nothing |
| 1.3 | EnemyData Resource | `/new-resource EnemyData` | Stats, AI, loot | Nothing |
| 1.4 | ItemData Resource | `/new-resource ItemData` | Type, effect, value | Nothing |
| 1.5 | EchoData Resource | `/new-resource EchoData` | Rarity, effect, lore | Nothing |
| 1.6 | Seed character data | `/seed-game-data characters` | Kael, Iris, Garrick .tres | 1.1 |
| 1.7 | Seed ability data | `/seed-game-data abilities` | Early abilities .tres | 1.2 |
| 1.8 | Seed enemy data | `/seed-game-data enemies` | Memory Bloom, Ash Stalker .tres | 1.3 |
| 1.9 | Seed item data | `/seed-game-data items` | Potion, Ether, Antidote .tres | 1.4 |
| 1.10 | Seed echo data | `/seed-game-data echoes` | 3-4 starter echoes .tres | 1.5 |

### Phase 2: Core Game Systems

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 2.1 | PartyManager autoload | `/new-system party` | Party roster, active party | 1.1, 1.6 |
| 2.2 | Battle System | `/new-system combat` | BattleScene, TurnQueue, Battler | 0.1, 0.3, 1.1-1.3 |
| 2.3 | Dialogue System | `/new-system dialogue` | DialogueManager + DialogueBox scene | 0.3 |
| 2.4 | Resonance System | `/implement-feature resonance` | Gauge, states (Focused/Resonant/Overload/Hollow) | 2.2 |
| 2.5 | Echo Tuning System | `/new-system tuning` | Modify gear stats with Echoes | 1.1, 1.5 |
| 2.6 | Camp System | `/new-system camp` | Rest/Heal, party dialogue, basic cooking | 2.1, 2.3 |

### Phase 3: Entities (Player, NPCs, Enemies)

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 3.1 | Player character scene | `/new-scene character player` | Player with movement/interaction | 0.2, 0.3 |
| 3.2 | NPC base scene | `/new-scene npc base_npc` | NPC with dialogue trigger | 2.3 |
| 3.3 | Interactable base scene | `/new-scene item interactable` | Chests, signs, save points | 0.3 |
| 3.4 | Party battler scene | `/new-scene character party_battler` | Battle sprite + interface | 2.2 |
| 3.5 | Enemy battler scene | `/new-scene enemy enemy_battler` | Battle sprite + AI | 2.2 |

### Phase 4: UI Layer

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 4.1 | Title Screen | `/new-ui title-screen title` | New Game / Continue / Settings | 0.3 |
| 4.2 | Overworld HUD | `/new-ui hud overworld_hud` | HP/EE bars, Mini-map | 2.1 |
| 4.3 | Battle UI | `/new-ui battle-hud battle_ui` | Command menu, HP/EE bars, Res gauge | 2.2, 2.4 |
| 4.4 | Dialogue Box | `/new-ui dialogue dialogue_box` | Typewriter text, portraits | 2.3 |
| 4.5 | Pause Menu | `/new-ui pause-menu pause` | Party status, items, save | 2.1 |
| 4.6 | Tuning & Camp UI | `/new-ui camp-ui camp` | Equipment modification, Rest/Talk menu | 2.5, 2.6 |

### Phase 5: Levels & World (Environmental Storytelling focus)

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 5.1 | Roothollow town | `/build-level roothollow town` | Hub with "Table of the Absent" storytelling | 3.1, 3.2 |
| 5.2 | Verdant Forest | `/build-level verdant_forest overworld` | Forest with "Echo Bleed" anomalies | 3.1 |
| 5.3 | Overgrown Ruins | `/build-level overgrown_ruins dungeon` | Dungeon with "Frozen Commute" environmentals | 3.1, 3.3 |

### Phase 6: Integration & Demo Flow

| # | Task | Skill | Output | Depends On |
|---|------|-------|--------|------------|
| 6.1 | Opening cutscene | `/implement-feature opening-sequence` | Kael in ruins, finds Lyra | 5.3, 2.3 |
| 6.2 | Random encounters | `/implement-feature random-encounters` | Step counter, weighted groups | 2.2, 5.2 |
| 6.3 | Scene transitions | `/implement-feature scene-transitions` | Fade in/out | 0.3 |
| 6.4 | Iris recruitment | `/implement-feature iris-recruitment` | Story event + joins party | 2.1, 2.3, 5.2 |
| 6.5 | Garrick recruitment | `/implement-feature garrick-recruitment` | Story event + joins party | 2.1, 2.3, 5.1 |
| 6.6 | Side Quest: The Clockmaker | `/implement-feature side-quest-demo` | First anomaly-based side quest | 5.1, 2.3 |
| 6.7 | Quality pass | `/playtest-check` + `/integration-check` | Bug fixes, cleanup | All above |

---

## Agent Team Plan

### Team Structure: 5 Agents

#### Agent 1: "foundation" — Core Systems Architect
**Phase 0 + Phase 2 work**:
1. State Machine, Input, GameManager, AudioManager, PartyManager
2. Battle System, Resonance System, Dialogue System
3. Echo Tuning System, Camp System

#### Agent 2: "data" — Data Architect
**Phase 1 work**:
1. All Resource classes (Character, Ability, Enemy, Item, Echo)
2. All .tres data seeding for Demo

#### Agent 3: "entities" — Entity Builder
**Phase 3 work**:
1. Player, NPC, Interactable base scenes
2. Party and Enemy battler scenes

#### Agent 4: "ui" — UI Developer
**Phase 4 work**:
1. Title Screen, Overworld HUD, Battle UI, Dialogue Box, Pause Menu
2. Tuning & Camp UI

#### Agent 5: "levels" — Level Designer
**Phase 5 + 6 work**:
1. Roothollow, Verdant Forest, Overgrown Ruins (with environmental storytelling)
2. Transitions, Encounters, Recruitment Events, Side Quest

---

## Demo Scope: What the Player Experiences

1. **Title Screen** → New Game
2. **Overgrown Ruins** → Kael explores alone, sees "Frozen Commute" environmentals, tutorial combat vs Memory Blooms.
3. **Lyra Discovery** → Cutscene, Lyra joins as Conscious Echo.
4. **Verdant Forest** → Walk back to Roothollow, see "Echo Bleed" anomalies, random encounters.
5. **Iris Recruitment** → Help Iris vs soldiers, she joins.
6. **Roothollow** → Hub area: see "Table of the Absent" in homes, inn, shop, save point.
7. **Side Quest** → Help Elara the Clockmaker solve her Recursive Echo problem.
8. **Garrick Recruitment** → Meet Garrick, he joins.
9. **Camp** → First camp: talk to party, tune gear with Echoes.
10. **Return to Ruins** → Full party exploration.
11. **Demo End** → "To be continued".

---

## What We're NOT Building Yet

- **Save/Load system** (beyond simple save point)
- **Skill trees** (fixed abilities for demo)
- **Advanced Cooking** (rest/heal only)
- **World map / fast travel** (single region only)
- **Character bonding levels** (fixed dialogue)
- **Mini-games** (no Echo Arena/Archaeology)
- **Vehicles** (walking only)

# Crystal Saga Demo - Tutorial Reference Implementation

This directory contains the complete GDScript code for **Crystal Saga**, the demo JRPG built across the 21-module tutorial. Use it as a reference when you get stuck, or to compare your implementation against the finished version.

## What's Included

All `.gd` scripts representing the **final state** after completing every tutorial module. Many scripts evolve across multiple modules (e.g., `character_data.gd` is defined in Module 7, extended in Module 15, and extended again in Module 17). Each file here is the fully merged final version.

## What's NOT Included

- **Scene files (`.tscn`)** - These must be created in the Godot editor following the tutorial's step-by-step instructions. Each module describes the scene tree structure.
- **Resource instances (`.tres`)** - Data files (items, characters, enemies, quests) need to be created in the Inspector per the tutorial instructions.
- **Art and audio assets** - The tutorial guides you to download free assets from Kenney and OpenGameArt.
- **TileMaps** - Painted in the editor, not expressible as code.

## Project Structure

```
demo/
├── resources/           # Custom Resource class definitions
│   ├── item_data.gd          (Module 7)
│   ├── character_data.gd     (Modules 7, 15, 17)
│   ├── npc_data.gd           (Modules 7, 9)
│   ├── dialogue_line.gd      (Module 9)
│   ├── enemy_data.gd         (Module 14)
│   ├── quest_data.gd         (Module 16)
│   ├── encounter_data.gd     (Module 14)
│   └── battler_data.gd       (Modules 11, 17)
├── autoloads/           # Global singleton scripts
│   ├── scene_manager.gd      (Modules 6, 11, 19)
│   ├── inventory_manager.gd  (Modules 10, 18)
│   ├── game_manager.gd       (Modules 16, 18)
│   ├── quest_manager.gd      (Modules 16, 18)
│   ├── party_manager.gd      (Modules 17, 18)
│   ├── save_manager.gd       (Module 18)
│   └── music_manager.gd      (Module 19)
├── player/              # Player character
│   └── player.gd             (Module 5)
├── npcs/                # NPC system
│   └── npc.gd                (Module 8)
├── entities/            # Reusable scene prefabs
│   ├── interactable/
│   │   ├── treasure_chest.gd  (Module 13)
│   │   ├── save_crystal.gd    (Modules 13, 18)
│   │   ├── boss_door.gd       (Module 13)
│   │   └── boss_trigger.gd    (Module 14)
│   └── battle/
│       └── battler_sprite.gd  (Module 11)
├── scenes/              # Area scene scripts
│   ├── exit_zone.gd           (Module 6)
│   ├── willowbrook/
│   │   └── willowbrook.gd    (Modules 8, 9, 16, 17)
│   ├── whisperwood/
│   │   └── whisperwood.gd    (Modules 6, 16)
│   └── crystal_cavern/
│       └── crystal_cavern.gd  (Modules 14, 16)
├── systems/             # Core game systems
│   ├── encounter_system.gd    (Module 14)
│   ├── encounter_zone.gd      (Module 14)
│   └── battle/
│       ├── battle_state.gd           (Module 11)
│       ├── battle_state_machine.gd   (Module 11)
│       ├── battle_manager.gd         (Module 11)
│       ├── ai_controller.gd          (Module 14)
│       └── states/
│           ├── intro_state.gd            (Module 11)
│           ├── turn_start_state.gd       (Module 11)
│           ├── player_choice_state.gd    (Modules 12, 14)
│           ├── action_execute_state.gd   (Module 12)
│           ├── check_result_state.gd     (Module 11)
│           ├── victory_state.gd          (Modules 11, 15, 20)
│           └── defeat_state.gd           (Module 20)
└── ui/                  # User interface scripts
    ├── dialogue_box/
    │   └── dialogue_box.gd        (Module 9)
    ├── inventory/
    │   ├── inventory_screen.gd    (Module 10)
    │   └── item_slot.gd           (Module 10)
    ├── battle/
    │   ├── battle_menu.gd         (Modules 12, 14)
    │   └── target_select.gd       (Module 12)
    ├── quest_log/
    │   └── quest_log.gd           (Module 16)
    ├── equipment/
    │   └── equipment_panel.gd     (Module 17)
    ├── title_screen/
    │   └── title_screen.gd        (Module 20)
    ├── pause_menu/
    │   └── pause_menu.gd          (Module 20)
    ├── game_over/
    │   └── game_over.gd           (Module 20)
    ├── ending/
    │   └── ending.gd              (Module 20)
    ├── credits/
    │   └── credits.gd             (Module 20)
    ├── save_slot_dialog/
    │   └── save_slot_dialog.gd    (Module 18)
    └── settings/
        └── settings_panel.gd     (Module 19)
```

## Autoload Registration

Register these autoloads in **Project -> Project Settings -> Autoload**:

| Name | File | Type |
|------|------|------|
| SceneManager | `autoloads/scene_manager.tscn` | Scene (has child nodes) |
| InventoryManager | `autoloads/inventory_manager.gd` | Script |
| GameManager | `autoloads/game_manager.gd` | Script |
| QuestManager | `autoloads/quest_manager.gd` | Script |
| PartyManager | `autoloads/party_manager.gd` | Script |
| SaveManager | `autoloads/save_manager.gd` | Script |
| MusicManager | `autoloads/music_manager.tscn` | Scene (has child nodes) |
| PauseMenu | `ui/pause_menu/pause_menu.tscn` | Scene (has child nodes) |

**Note:** SceneManager and MusicManager use `.tscn` files because they need child nodes (ColorRect/AnimationPlayer and AudioStreamPlayers respectively). All others use `.gd` files directly.

## How to Use

1. Follow the tutorial modules to build scenes (`.tscn`), paint tilemaps, create data files (`.tres`), and set up the editor
2. When your code doesn't work, compare your script against the corresponding file here
3. Pay attention to the module annotations in the structure above to find which tutorial module introduced each file

The scripts compile and work together as a complete system. The tutorial teaches you *why* each piece exists and how it connects.

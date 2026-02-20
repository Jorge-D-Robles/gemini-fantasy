# game/data/

`.tres` resource files — the actual game data instances. Each file is a serialized instance of a class from `game/resources/`. Schemas are defined there; this directory is the content.

## Directory Structure

```
data/
  abilities/     # AbilityData instances (skills and spells)
  characters/    # CharacterData instances (party members)
  echoes/        # EchoData instances (collectible Echo Fragments)
  enemies/       # EnemyData instances (enemy combatants)
  equipment/     # EquipmentData instances (weapons and armor)
  items/         # ItemData instances (consumables and key items)
  skill_trees/   # SkillTreeData instances (character skill trees)
```

## Current Entries

### abilities/ (7)
| ID | Display Name | Notes |
|----|-------------|-------|
| `echo_strike` | Echo Strike | Physical + resonance |
| `emp_burst` | EMP Burst | Wind element, multi-target |
| `guardians_stand` | Guardian's Stand | Defensive buff |
| `heavy_strike` | Heavy Strike | Physical, 30% stun chance |
| `memory_weave` | Memory Weave | Support/EchoData-linked |
| `purifying_light` | Purifying Light | Light element heal |
| `resonance_pulse` | Resonance Pulse | Resonance cost ability |

### characters/ (4)
| ID | Display Name | Weapon Types | Notes |
|----|-------------|-------------|-------|
| `kael` | Kael Voss | SWORD, DAGGER | Protagonist, balanced |
| `garrick` | Garrick Thorne | SHIELD, MACE | Tank/support archetype |
| `iris` | Iris Mantle | HAMMER, RIFLE | Physical DPS/debuffer |
| `lyra` | Lyra | TOME, WAND | Magic/heal specialist |

### echoes/ (4)
| ID | Display Name | Element | Target |
|----|-------------|---------|--------|
| `burning_village` | Burning Village | FIRE | ALL_ENEMIES |
| `childs_laughter` | Child's Laughter | — | — |
| `mothers_comfort` | Mother's Comfort | — | — |
| `soldiers_fear` | Soldier's Fear | — | — |

### enemies/ (8)
| ID | Display Name | AI Type | Weaknesses |
|----|-------------|---------|-----------|
| `ancient_sentinel` | Ancient Sentinel | — | — |
| `ash_stalker` | Ash Stalker | — | — |
| `cinder_wisp` | Cinder Wisp | — | — |
| `creeping_vine` | Creeping Vine | — | — |
| `ember_hound` | Ember Hound | — | — |
| `gale_harpy` | Gale Harpy | — | — |
| `hollow_specter` | Hollow Specter | BASIC | LIGHT (weak), DARK (resists) |
| `memory_bloom` | Memory Bloom | — | — |

### equipment/ (6)
| ID | Display Name | Slot | Weapon Type |
|----|-------------|------|-------------|
| `iron_hammer` | Iron Hammer | WEAPON | HAMMER |
| `iron_sword` | Iron Sword | WEAPON | SWORD |
| `leather_cap` | Leather Cap | HELMET | — |
| `leather_vest` | Leather Vest | CHEST | — |
| `oak_staff` | Oak Staff | WEAPON | STAFF |
| `speed_ring` | Speed Ring | ACCESSORY | — |

### items/ (7)
| ID | Display Name | Effect | Value |
|----|-------------|--------|-------|
| `antidote` | Antidote | CURE_STATUS | — |
| `crystal_wick` | Crystal Wick | HEAL_EE | 30 EE (unlocked after iris_recruited) |
| `ether` | Ether | HEAL_EE | 30 EE |
| `forest_remedy` | Forest Remedy | HEAL_HP | 80 HP (unlocked after iris_recruited) |
| `phoenix_down` | Phoenix Down | REVIVE | — |
| `potion` | Potion | HEAL_HP | 50 HP |
| `resonance_tonic` | Resonance Tonic | — | — |

### skill_trees/ (24)
Three paths per character. Full 6-node trees for Kael/Iris/Garrick/Nyx; 3-stub trees for Lyra/Sienna/Cipher/Ash.

| ID | Display Name | Character | Nodes |
|----|-------------|-----------|-------|
| `kael_hunter_path` | Hunter Path | Kael | 6 |
| `kael_memory_path` | Memory Path | Kael | 6 |
| `kael_bridge_path` | Bridge Path | Kael | 6 |
| `iris_arsenal_path` | Arsenal Path | Iris | 6 |
| `iris_engineering_path` | Engineering Path | Iris | 6 |
| `iris_cybernetics_path` | Cybernetics Path | Iris | 6 |
| `garrick_fortress_path` | Fortress Path | Garrick | 6 |
| `garrick_redemption_path` | Redemption Path | Garrick | 6 |
| `garrick_judgment_path` | Judgment Path | Garrick | 6 |
| `nyx_chaos_path` | Chaos Path | Nyx | 6 |
| `nyx_identity_path` | Identity Path | Nyx | 6 |
| `nyx_hollows_path` | Hollows Path | Nyx | 6 |
| `lyra_scholar_path` | Scholar Path | Lyra | 3 (stub) |
| `lyra_warrior_path` | Warrior Path | Lyra | 3 (stub) |
| `lyra_echo_path` | Echo Path | Lyra | 3 (stub) |
| `sienna_research_path` | Research Path | Sienna | 3 (stub) |
| `sienna_experimentation_path` | Experimentation Path | Sienna | 3 (stub) |
| `sienna_redemption_path` | Redemption Path | Sienna | 3 (stub) |
| `cipher_infiltration_path` | Infiltration Path | Cipher | 3 (stub) |
| `cipher_combat_path` | Combat Path | Cipher | 3 (stub) |
| `cipher_anchor_path` | Anchor Path | Cipher | 3 (stub) |
| `ash_silence_path` | Silence Path | Ash | 3 (stub) |
| `ash_harmony_path` | Harmony Path | Ash | 3 (stub) |
| `ash_future_path` | Future Path | Ash | 3 (stub) |

## .tres File Format

```gdresource
[gd_resource type="Resource" script_class="EnemyData" load_steps=2 format=3 uid="uid://b<id>"]

[ext_resource type="Script" path="res://resources/enemy_data.gd" id="1_script"]

[resource]
script = ExtResource("1_script")
id = &"<id>"
display_name = "<Name>"
...
```

- `uid` must be unique — use `uid://b<id>` pattern (e.g., `uid://biron_sword`)
- Enum fields store integer values — see `game/resources/CLAUDE.md` for enum value tables
- `abilities` array in CharacterData uses `ExtResource` references to ability `.tres` files

## Key Conventions

- **IDs use snake_case** and match the filename (e.g., `hollow_specter.tres` → `id = &"hollow_specter"`)
- **Enum values are integers** in `.tres` files — Element FIRE=1, ICE=2, etc. (see `game/resources/CLAUDE.md`)
- **Loot table format**: `[{"item_id": "potion", "drop_chance": 0.35}]`
- **Sprite paths** reference `res://assets/sprites/enemies/<name>.png` — must exist and be imported by Godot
- **Character abilities** are linked as `ExtResource` references, not inlined
- See `game/resources/CLAUDE.md` for the EnemyData schema and enum values

## Adding New Entries

For enemies, use the `.tres` format above as a template. For other types:

1. Copy an existing `.tres` of the same class as a template
2. Update `uid`, `id`, `display_name`, and all relevant fields
3. Place in the correct subdirectory
4. Reference from the system that loads it (e.g., `EncounterSystem`, `InventorySystem`)

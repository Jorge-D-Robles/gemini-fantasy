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

### characters/ (3)
| ID | Display Name | Weapon Types | Notes |
|----|-------------|-------------|-------|
| `kael` | Kael Voss | SWORD, DAGGER | Protagonist, balanced |
| `garrick` | Garrick | — | Tank archetype |
| `iris` | Iris | — | Magic specialist |

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

### items/ (5)
| ID | Display Name | Effect | Value |
|----|-------------|--------|-------|
| `antidote` | Antidote | CURE_STATUS | — |
| `ether` | Ether | HEAL_EE | — |
| `phoenix_down` | Phoenix Down | REVIVE | — |
| `potion` | Potion | HEAL_HP | 50 HP |
| `resonance_tonic` | Resonance Tonic | — | — |

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
- See root `CLAUDE.md` "Adding Monsters" section for the full enemy creation workflow

## Adding New Entries

Follow the template in root `CLAUDE.md` for enemies. For other types:

1. Copy an existing `.tres` of the same class as a template
2. Update `uid`, `id`, `display_name`, and all relevant fields
3. Place in the correct subdirectory
4. Reference from the system that loads it (e.g., `EncounterSystem`, `InventorySystem`)

# game/resources/

Custom Resource classes (`.gd` scripts) that define the data schemas for all game entities. Each file is a `class_name` that Godot exposes in the inspector. Actual data lives in `game/data/` as `.tres` files.

## File Index

| File | Class | Extends | Purpose |
|------|-------|---------|---------|
| `battler_data.gd` | `BattlerData` | `Resource` | Base stats for all combatants (id, hp, ee, atk, mag, def, res, spd, luck, abilities) |
| `character_data.gd` | `CharacterData` | `BattlerData` | Party member: adds growth rates, level/XP, equipment restrictions, portrait/sprite paths |
| `enemy_data.gd` | `EnemyData` | `BattlerData` | Enemy: adds AI type, rewards (exp/gold), elemental weaknesses/resistances, loot table, sprite sheet info |
| `ability_data.gd` | `AbilityData` | `Resource` | Skill/spell: cost (EE + resonance), damage, targeting, element, status effect chance/duration |
| `item_data.gd` | `ItemData` | `Resource` | Consumable/key item: effect type/value, targeting, buy/sell price, stack size, battle usability |
| `equipment_data.gd` | `EquipmentData` | `Resource` | Gear: slot type, weapon type, stat bonuses, element, crit bonus, economy |
| `status_effect_data.gd` | `StatusEffectData` | `Resource` | Status template: effect type, duration, tick damage/heal, stat modifiers, prevents_action flag |
| `echo_data.gd` | `EchoData` | `Resource` | Echo Fragment collectible: rarity, echo type, effect, element, targeting, uses per battle |
| `quest_data.gd` | `QuestData` | `Resource` | Quest definition: type, objectives (strings), rewards (gold/exp/items), prerequisites |
| `dialogue_line.gd` | `DialogueLine` | `Resource` | Single dialogue line: speaker, text, portrait texture, choices array |
| `encounter_pool_entry.gd` | `EncounterPoolEntry` | `Resource` | Weighted enemy group for random encounters: `enemies: Array[Resource]`, `weight: float` |
| `battle_action.gd` | `BattleAction` | `RefCounted` | Runtime battle action (not a .tres): type enum + target/ability/item payload; use static constructors |

## Inheritance Hierarchy

```
Resource
├── BattlerData         ← base combat stats
│   ├── CharacterData   ← party members
│   └── EnemyData       ← enemies
├── AbilityData
├── ItemData
├── EquipmentData
├── StatusEffectData
├── EchoData
├── QuestData
├── DialogueLine
└── EncounterPoolEntry

RefCounted
└── BattleAction        ← runtime-only, never saved as .tres
```

## Key Enums

| Enum | Defined In | Values |
|------|-----------|--------|
| `Element` | `AbilityData`, `EnemyData`, `EchoData` | `NONE, FIRE, ICE, WATER, WIND, EARTH, LIGHT, DARK` |
| `AiType` | `EnemyData` | `BASIC, AGGRESSIVE, DEFENSIVE, SUPPORT, BOSS` |
| `TargetType` | `AbilityData`, `ItemData`, `EchoData` | `SINGLE_ENEMY, ALL_ENEMIES, SINGLE_ALLY, ALL_ALLIES, SELF` |
| `SlotType` | `EquipmentData` | `WEAPON, HELMET, CHEST, ACCESSORY` |
| `WeaponType` | `EquipmentData` | `NONE, SWORD, DAGGER, HAMMER, RIFLE, SHIELD, MACE, STAFF, ORB, BOOK, ROD, DUAL_BLADES, HANDGUN, CRYSTAL, GRIMOIRE, BELL, TOTEM` |
| `QuestType` | `QuestData` | `MAIN, SIDE, CHARACTER, BOUNTY, COLLECTION` |
| `BattleAction.Type` | `BattleAction` | `ATTACK, ABILITY, DEFEND, WAIT, ITEM` |

## Conventions

- All persistent resources use `id: StringName` (e.g., `&"fire_potion"`) as the primary key
- `EquipmentData.element` references `AbilityData.Element` — import order matters
- `DialogueLine` and `EncounterPoolEntry` provide `static func create(...)` factory helpers — prefer these over `.new()`
- `BattleAction` uses static factories: `create_attack()`, `create_ability()`, `create_defend()`, `create_item()`, `create_wait()`
- `EnemyData.loot_table` is `Array[Dictionary]` with keys `"item_id"` (String) and `"drop_chance"` (float)
- `EnemyData.sprite_path` points to `res://assets/sprites/enemies/<name>.png`; guard with null check after `load()`

## Adding a New Resource Type

1. Create `game/resources/<name>.gd` with `class_name` + `extends Resource`
2. Follow the code order from root `CLAUDE.md` (enums → @export groups → methods)
3. Add corresponding `.tres` files under `game/data/<category>/`
4. Reference from root `CLAUDE.md` "Adding Monsters" section if it's an enemy-related resource

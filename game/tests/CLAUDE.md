# game/tests/

Unit test suite using the [GUT](https://github.com/bitwes/Gut) framework.

## Structure

```
tests/
  helpers/
    test_helpers.gd        # Shared factory functions (extend as needed)
  unit/
    autoloads/             # Tests for autoload singletons
    resources/             # Tests for custom Resource classes
    scenes/                # Tests for scene-specific logic
    state_machine/         # Tests for state machine transitions
    systems/
      battle/              # Battle system tests (battler, resonance, turn queue, etc.)
      encounter/           # Random encounter system tests
      progression/         # Level-up and XP system tests
```

## Framework

- Extends `GutTest` — every test file must begin with `extends GutTest`
- **Never** test against live autoload singletons — load fresh instances in `before_each()`
- Pattern: `load("res://path/to/script.gd").new()` + `add_child_autofree()`

```gdscript
extends GutTest

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _subject: MyClass

func before_each() -> void:
    _subject = load("res://systems/my_class.gd").new()
    add_child_autofree(_subject)

func test_some_behavior() -> void:
    assert_eq(_subject.some_method(), expected_value)
```

## test_helpers.gd — Factory Functions

All return fully initialized objects with sensible defaults. Pass an `overrides: Dictionary` to change specific fields.

| Factory | Returns | Key overrides |
|---------|---------|---------------|
| `make_battler_data(overrides)` | `BattlerData` | `id`, `max_hp`, `attack`, `magic`, `defense`, `resistance`, `speed`, `luck` |
| `make_battler(overrides)` | `Battler` | Same as BattlerData |
| `make_party_battler(overrides)` | `PartyBattler` | Same as BattlerData |
| `make_enemy_data(overrides)` | `EnemyData` | Same + `ai_type`, `exp_reward`, `gold_reward`, `loot_table` |
| `make_enemy_battler(overrides)` | `EnemyBattler` | Same as EnemyData |
| `make_ability(overrides)` | `AbilityData` | `ee_cost`, `damage_base`, `damage_stat`, `target_type`, `element`, `status_effect` |
| `make_item(overrides)` | `ItemData` | `item_type`, `effect_type`, `effect_value` |
| `make_status_effect(overrides)` | `StatusEffectData` | `effect_type`, `duration`, `tick_damage`, `prevents_action`, stat modifiers |
| `make_equipment(overrides)` | `EquipmentData` | `slot_type`, `weapon_type`, stat bonuses |
| `make_quest(overrides)` | `QuestData` | `objectives`, `reward_gold`, `reward_exp`, `reward_item_ids`, `quest_type` |

## Naming Convention

- File: `test_<module_name>.gd` in the subdirectory matching the source file's location
- Test functions: `test_<description_of_behavior>()`
- Setup: `before_each()` / `after_each()`

## Running Tests

```bash
# Static analysis
/Users/robles/Library/Python/3.10/bin/gdlint game/

# Unit tests (headless)
/Applications/Godot.app/Contents/MacOS/Godot --headless \
  --path /Users/robles/repos/games/gemini-fantasy/game/ \
  -d -s res://addons/gut/gut_cmdln.gd \
  -gdir=res://tests/ -ginclude_subdirs -gexit -glog=2
```

Or use `/run-tests` which runs both in sequence. **All tests must pass before committing.**

## TDD Rules

See root CLAUDE.md "MANDATORY: Test-Driven Development" section. Summary:
1. Write failing tests **before** writing implementation
2. Bug fixes **must** include a regression test first
3. Never push with failing tests

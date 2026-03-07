# Chapter 20: Testing

You have spent your career writing tests. You know the value of a fast, reliable test suite that catches regressions before they ship. Game code is no different — damage formulas, inventory management, state machine transitions, and save/load serialization are all pure logic that belongs under test.

This chapter introduces GUT (Godot Unit Testing), the testing framework for GDScript. If you have used Jest, Jasmine, or xUnit, every concept will feel familiar. The key difference: your "production services" are autoload singletons, and you must never test against the live ones.

## GUT: The Testing Framework

GUT is a GDScript testing framework that runs inside Godot. It provides test lifecycle hooks, assertion methods, signal watchers, and a headless CLI runner. Think of it as Jest for GDScript.

### Installation

Install GUT from the Godot AssetLib (search "GUT") or clone it manually into your project:

```
game/
  addons/
    gut/              # GUT framework lives here
      gut_cmdln.gd    # CLI runner script
      gut.tscn        # In-editor runner scene
      ...
  tests/
    helpers/
      test_helpers.gd # Shared factory functions
    unit/
      autoloads/      # Tests for autoload singletons
      resources/      # Tests for custom Resource classes
      systems/        # Tests for game systems
        battle/       # Battle-specific tests
        encounter/    # Encounter system tests
        progression/  # Level/XP tests
      state_machine/  # State machine tests
      scenes/         # Scene logic tests
      entities/       # Entity behavior tests
      ui/             # UI logic tests
```

After installation, enable the plugin in **Project > Project Settings > Plugins**.

Mirror your source directory structure under `tests/unit/`. If your source file is `autoloads/inventory_manager.gd`, its test file is `tests/unit/autoloads/test_inventory_manager.gd`. This convention makes it trivial to find the test for any file.

### Test File Structure

Every test file follows the same skeleton:

```gdscript
# tests/unit/autoloads/test_inventory_manager.gd
extends GutTest

## Tests for InventoryManager inventory and gold logic.
## Creates a fresh instance per test — never touches the global singleton.

var _inv: Node


func before_each() -> void:
	_inv = load("res://autoloads/inventory_manager.gd").new()
	add_child_autofree(_inv)


func test_add_item_creates_entry() -> void:
	_inv.add_item(&"potion")
	assert_true(_inv.has_item(&"potion"))
	assert_eq(_inv.get_item_count(&"potion"), 1)


func test_add_item_stacks() -> void:
	_inv.add_item(&"potion", 3)
	_inv.add_item(&"potion", 2)
	assert_eq(_inv.get_item_count(&"potion"), 5)
```

The key elements:

- **`extends GutTest`** — every test file must start with this. GUT discovers test files by this base class.
- **`before_each()`** — runs before every test function, creating a fresh subject. This is your `beforeEach()` / `setUp()`.
- **`after_each()`** — runs after every test function. Use it for cleanup like deleting temp files.
- **`func test_*()`** — any function prefixed with `test_` is a test case. GUT discovers and runs them automatically.
- **`add_child_autofree()`** — adds a node to the scene tree and automatically frees it when the test ends. This prevents memory leaks and ensures each test starts clean.

If you have used Angular's TestBed, `before_each()` + `add_child_autofree()` is your `TestBed.createComponent()` — it builds a fresh, isolated instance for every test.

## The Golden Rule: Never Test Against Live Autoloads

This is the single most important testing rule in Godot. When your game runs, autoload singletons like `InventoryManager`, `PartyManager`, and `QuestManager` are global instances attached to the scene tree root. They carry state from previous operations, they connect signals to other autoloads, and they depend on the full game being initialized.

**If you test against the live singleton, your tests are coupled to global state.** They will pass or fail depending on what other tests did before them, what order they run in, and whether the editor happens to have a scene open.

Instead, create a fresh instance of the autoload script:

```gdscript
func before_each() -> void:
	_manager = load("res://autoloads/equipment_manager.gd").new()
	add_child_autofree(_manager)
```

This gives you a brand-new `EquipmentManager` with empty state, no signal connections to other systems, and no dependency on the game being initialized. It behaves exactly like the real autoload — same script, same methods — but in complete isolation.

The parallel to web development is exact: you would never run your Jest tests against your production database. You create a fresh in-memory instance for each test. Same principle, different runtime.

### When You Need Multiple Autoloads

Some tests exercise interactions between systems. SaveManager, for example, needs a PartyManager, InventoryManager, and EventFlags to gather and apply save data. Create fresh instances of all of them:

```gdscript
# tests/unit/autoloads/test_save_manager.gd
extends GutTest

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _save: Node
var _party: Node
var _inventory: Node
var _flags: Node


func before_each() -> void:
	_save = load("res://autoloads/save_manager.gd").new()
	add_child_autofree(_save)

	_party = load("res://autoloads/party_manager.gd").new()
	add_child_autofree(_party)

	_inventory = load("res://autoloads/inventory_manager.gd").new()
	add_child_autofree(_inventory)

	_flags = load("res://events/event_flags.gd").new()
	add_child_autofree(_flags)


func after_each() -> void:
	_save.delete_save(99)  # Clean up test save file
```

You pass these instances as arguments to SaveManager's methods instead of letting it reach for the global singletons. This is dependency injection — the same pattern you use in Angular when you provide mock services in your test module.

## Test Helpers: Factory Functions

Hard-coding test data in every test file leads to duplication and brittle tests. Instead, create a shared helpers file with factory functions that produce fully initialized data objects with sensible defaults:

```gdscript
# tests/helpers/test_helpers.gd
extends RefCounted

## Shared test factories for creating test data without touching autoloads.


static func make_battler_data(overrides: Dictionary = {}) -> BattlerData:
	var d := BattlerData.new()
	d.id = overrides.get("id", &"test_battler")
	d.display_name = overrides.get("display_name", "Test Battler")
	d.max_hp = overrides.get("max_hp", 100)
	d.max_ee = overrides.get("max_ee", 50)
	d.attack = overrides.get("attack", 20)
	d.magic = overrides.get("magic", 15)
	d.defense = overrides.get("defense", 10)
	d.resistance = overrides.get("resistance", 10)
	d.speed = overrides.get("speed", 10)
	d.luck = overrides.get("luck", 5)
	return d


static func make_enemy_data(overrides: Dictionary = {}) -> EnemyData:
	var d := EnemyData.new()
	d.id = overrides.get("id", &"test_enemy")
	d.display_name = overrides.get("display_name", "Test Enemy")
	d.max_hp = overrides.get("max_hp", 80)
	d.attack = overrides.get("attack", 15)
	d.defense = overrides.get("defense", 8)
	d.speed = overrides.get("speed", 12)
	d.ai_type = overrides.get("ai_type", EnemyData.AiType.BASIC)
	d.exp_reward = overrides.get("exp_reward", 20)
	d.gold_reward = overrides.get("gold_reward", 10)
	return d


static func make_ability(overrides: Dictionary = {}) -> AbilityData:
	var a := AbilityData.new()
	a.id = overrides.get("id", &"test_ability")
	a.display_name = overrides.get("display_name", "Test Ability")
	a.ee_cost = overrides.get("ee_cost", 10)
	a.damage_base = overrides.get("damage_base", 30)
	a.damage_stat = overrides.get(
		"damage_stat", AbilityData.DamageStat.MAGIC
	)
	a.target_type = overrides.get(
		"target_type", AbilityData.TargetType.SINGLE_ENEMY
	)
	a.element = overrides.get("element", AbilityData.Element.FIRE)
	return a


static func make_item(overrides: Dictionary = {}) -> ItemData:
	var i := ItemData.new()
	i.id = overrides.get("id", &"test_item")
	i.display_name = overrides.get("display_name", "Test Potion")
	i.item_type = overrides.get(
		"item_type", ItemData.ItemType.CONSUMABLE
	)
	i.effect_type = overrides.get(
		"effect_type", ItemData.EffectType.HEAL_HP
	)
	i.effect_value = overrides.get("effect_value", 50)
	return i
```

Use them in tests by preloading the helpers:

```gdscript
const Helpers := preload("res://tests/helpers/test_helpers.gd")

func test_gather_save_data_includes_party_ids() -> void:
	var kael := Helpers.make_battler_data({"id": &"kael"})
	var iris := Helpers.make_battler_data({"id": &"iris"})
	_party.add_character(kael)
	_party.add_character(iris)

	var data: Dictionary = _save.gather_save_data(
		_party, _inventory, _flags,
		"res://test.tscn", Vector2.ZERO,
	)
	assert_eq(data["party"]["active"], ["kael", "iris"])
```

The `overrides` dictionary pattern lets you specify only what matters for a given test while using sensible defaults for everything else. This is the same principle behind Angular's `Object.assign({}, defaults, overrides)` pattern in test utilities — minimum ceremony, maximum clarity.

Add new factory functions as you create new Resource classes. Every Resource type in your game should have a corresponding `make_*()` helper.

## GUT Assertions

GUT provides a rich set of assertion methods. Here are the ones you will use constantly:

| Assertion | Purpose |
|-----------|---------|
| `assert_eq(got, expected)` | Equality check (values, strings, arrays, dicts) |
| `assert_ne(got, not_expected)` | Inequality check |
| `assert_true(condition)` | Boolean true |
| `assert_false(condition)` | Boolean false |
| `assert_null(value)` | Value is null |
| `assert_not_null(value)` | Value is not null |
| `assert_typeof(value, TYPE_*)` | Type check (TYPE_DICTIONARY, TYPE_ARRAY, etc.) |
| `assert_has(array, value)` | Array or dictionary contains value |
| `assert_almost_eq(got, expected, tolerance)` | Float comparison with epsilon |

Every assertion accepts an optional final `String` parameter for a custom failure message:

```gdscript
assert_eq(result, 20, "Should be base + stat * scaling")
```

### Testing Signals

GUT has built-in signal watching. Call `watch_signals()` on an object, then assert that signals were or were not emitted:

```gdscript
func test_add_item_emits_inventory_changed() -> void:
	watch_signals(_inv)
	_inv.add_item(&"potion")
	assert_signal_emitted(_inv, "inventory_changed")


func test_remove_item_no_signal_on_failure() -> void:
	watch_signals(_inv)
	_inv.remove_item(&"potion", 1)
	assert_signal_not_emitted(_inv, "inventory_changed")
```

You can also inspect signal parameters:

```gdscript
func test_state_changed_signal_params() -> void:
	_machine.initial_state = _state_a
	add_child_autofree(_machine)
	watch_signals(_machine)
	_machine.transition_to(&"StateB")
	var params: Array = get_signal_parameters(_machine, "state_changed")
	assert_eq(params[0], _state_a)  # old state
	assert_eq(params[1], _state_b)  # new state
```

If you have used Jasmine's `spyOn` to watch event emitters, `watch_signals()` is the same concept.

### Testing for Errors and Warnings

GUT can detect `push_error()` and `push_warning()` calls:

```gdscript
func test_transition_to_invalid_state_warns() -> void:
	_machine.initial_state = _state_a
	add_child_autofree(_machine)
	_machine.transition_to(&"NonExistent")
	assert_eq(_machine.current_state, _state_a)
	assert_push_error("NonExistent")
```

## TDD Workflow: RED, GREEN, REFACTOR

Test-Driven Development works the same in games as it does in web applications:

1. **RED** — Write a failing test that defines the behavior you want
2. **GREEN** — Write the minimum code to make the test pass
3. **REFACTOR** — Clean up the implementation while keeping tests green

Here is a concrete example. Say you want to add a `remove_gold()` method to InventoryManager.

### RED: Write the Failing Test

```gdscript
func test_remove_gold_success() -> void:
	_inv.add_gold(100)
	var result: bool = _inv.remove_gold(40)
	assert_true(result)
	assert_eq(_inv.gold, 60)


func test_remove_gold_fails_when_insufficient() -> void:
	_inv.add_gold(30)
	var result: bool = _inv.remove_gold(50)
	assert_false(result)
	assert_eq(_inv.gold, 30)


func test_remove_gold_emits_gold_changed() -> void:
	_inv.add_gold(100)
	watch_signals(_inv)
	_inv.remove_gold(40)
	assert_signal_emitted(_inv, "gold_changed")


func test_remove_gold_no_signal_on_failure() -> void:
	watch_signals(_inv)
	_inv.remove_gold(10)
	assert_signal_not_emitted(_inv, "gold_changed")
```

Run the tests — they fail because `remove_gold()` does not exist yet. This is correct.

### GREEN: Minimum Implementation

```gdscript
func remove_gold(amount: int) -> bool:
	if amount <= 0 or amount > gold:
		return false
	gold -= amount
	gold_changed.emit()
	return true
```

Run the tests — they pass.

### REFACTOR: Clean Up

In this case the implementation is already clean. In more complex scenarios, this is where you extract helper methods, simplify conditionals, or improve naming — always re-running tests after each change.

## What to Test

Not everything in a game needs automated tests. Focus your testing effort where it provides the most value:

### Always Test

**Static utility functions** are the easiest and highest-value tests. They are pure functions with no side effects:

```gdscript
# tests/unit/systems/battle/test_battler_damage.gd
extends GutTest

const BDamage = preload("res://systems/battle/battler_damage.gd")


func test_calculate_outgoing_base_plus_stat() -> void:
	var result := BDamage.calculate_outgoing(10, 20, 0, false)
	assert_eq(result, 20, "Should be base + stat * scaling")


func test_calculate_outgoing_overload_doubles() -> void:
	var result := BDamage.calculate_outgoing(10, 20, 2, false)
	assert_eq(result, 40, "Overload should double outgoing damage")


func test_calculate_incoming_minimum_one() -> void:
	var result := BDamage.calculate_incoming(1, 200, 0, false)
	assert_eq(result, 1, "Damage should never go below 1")
```

**Autoload logic** — add/remove operations, state queries, signal emissions:

```gdscript
func test_remove_item_decrements() -> void:
	_inv.add_item(&"potion", 3)
	var result: bool = _inv.remove_item(&"potion", 1)
	assert_true(result)
	assert_eq(_inv.get_item_count(&"potion"), 2)


func test_remove_item_fails_when_insufficient() -> void:
	_inv.add_item(&"potion", 2)
	var result: bool = _inv.remove_item(&"potion", 5)
	assert_false(result)
	assert_eq(_inv.get_item_count(&"potion"), 2)
```

**Resource validation** — required fields, type constraints, edge cases:

```gdscript
func test_abilities_accepts_ability_data() -> void:
	var d := BattlerData.new()
	var ability := AbilityData.new()
	ability.id = &"slash"
	var abilities: Array[Resource] = [ability]
	d.abilities = abilities
	assert_eq(d.abilities.size(), 1)
	assert_eq((d.abilities[0] as AbilityData).id, &"slash")
```

**State machine transitions** — initial state, valid transitions, invalid transitions, signal emissions:

```gdscript
func test_initial_state_entered_on_ready() -> void:
	_machine.initial_state = _state_a
	add_child_autofree(_machine)
	assert_eq(_machine.current_state, _state_a)


func test_transition_to_valid_state() -> void:
	_machine.initial_state = _state_a
	add_child_autofree(_machine)
	_machine.transition_to(&"StateB")
	assert_eq(_machine.current_state, _state_b)


func test_transition_to_same_state_is_noop() -> void:
	_machine.initial_state = _state_a
	add_child_autofree(_machine)
	watch_signals(_machine)
	_machine.transition_to(&"StateA")
	assert_signal_not_emitted(_machine, "state_changed")
```

**Save/load round-trips** — gather data, save to disk, load back, verify everything matches:

```gdscript
func test_round_trip_preserves_all_state() -> void:
	var kael := Helpers.make_battler_data({
		"id": &"kael", "max_hp": 120, "max_ee": 60,
	})
	_party.add_character(kael)
	_party.set_hp(&"kael", 55)
	_inventory.add_item(&"potion", 3)
	_inventory.add_gold(777)
	_flags.set_flag("chest_opened")

	_save.save_game(
		99, _party, _inventory, _flags,
		"res://scenes/forest.tscn", Vector2(123, 456),
	)

	# Reset all state
	_party.set_hp(&"kael", 120)
	_inventory.remove_item(&"potion", 3)
	_inventory.gold = 0
	_flags.clear_flag("chest_opened")

	# Reload
	var loaded: Dictionary = _save.load_save_data(99)
	_save.apply_save_data(loaded, _party, _inventory, _flags)

	assert_eq(_party.get_hp(&"kael"), 55)
	assert_eq(_inventory.get_item_count(&"potion"), 3)
	assert_eq(_inventory.gold, 777)
	assert_true(_flags.has_flag("chest_opened"))
```

### Do Not Test

- **Visual layout** — pixel positions of UI elements, sprite placement, animation frame counts. These change constantly during polish and provide no logic coverage.
- **Editor scenes** — whether a `.tscn` file has the right node hierarchy. If the scene loads and the game works, the structure is correct.
- **Animation timing** — how long a tween takes, whether a particle effect looks right. Use your eyes.
- **Godot engine behavior** — do not test that `Array.append()` works or that `Vector2.distance_to()` returns the right value. Trust the engine.

The rule of thumb: if a function takes inputs and produces outputs (a return value, a state change, a signal emission), test it. If it produces pixels on screen, verify it visually.

## Running Tests

### Headless CLI (Recommended for CI)

Run GUT from the command line without opening the editor:

```bash
/path/to/Godot --headless \
  --path /path/to/your/game/ \
  -d -s res://addons/gut/gut_cmdln.gd \
  -gdir=res://tests/ \
  -ginclude_subdirs \
  -gexit \
  -glog=2
```

Flags:
- `--headless` — no window, no GPU. Runs in pure script mode.
- `--path` — the Godot project root.
- `-d` — debug mode (enables `push_error` / `push_warning` assertions).
- `-s` — run this script instead of the main scene.
- `-gdir` — root directory for test discovery.
- `-ginclude_subdirs` — recurse into subdirectories.
- `-gexit` — exit Godot when tests finish (essential for CI).
- `-glog=2` — verbosity level (0=quiet, 1=failures only, 2=all results).

GUT exits with a non-zero code if any test fails, making it suitable for CI pipelines.

### In-Editor Runner

GUT also provides an in-editor panel. After enabling the plugin, open the GUT tab at the bottom of the editor. You can run all tests, run a single file, or run a single test function. This is useful during development when you want fast feedback on the test you are currently writing.

### Static Analysis with gdlint

GDScript does not have a compiler that catches style issues, but `gdlint` fills that gap. It checks for consistent formatting, naming conventions, and common mistakes:

```bash
pip install gdtoolkit
gdlint game/
```

Run both gdlint and GUT before every commit. A combined script makes this easy:

```bash
#!/bin/bash
# run_tests.sh
set -e
echo "=== gdlint ==="
gdlint game/
echo "=== GUT ==="
/path/to/Godot --headless \
  --path game/ \
  -d -s res://addons/gut/gut_cmdln.gd \
  -gdir=res://tests/ -ginclude_subdirs -gexit -glog=2
echo "=== All tests passed ==="
```

## Testing Patterns for JRPG Systems

### Pattern: Edge Case Coverage

Game logic is full of edge cases — what happens when you remove more items than you have? What about adding zero gold? Negative values? Test these exhaustively:

```gdscript
func test_add_gold_zero_ignored() -> void:
	watch_signals(_inv)
	_inv.add_gold(0)
	assert_eq(_inv.gold, 0)
	assert_signal_not_emitted(_inv, "gold_changed")


func test_add_gold_negative_ignored() -> void:
	watch_signals(_inv)
	_inv.add_gold(-10)
	assert_eq(_inv.gold, 0)
	assert_signal_not_emitted(_inv, "gold_changed")


func test_remove_gold_zero_returns_false() -> void:
	_inv.add_gold(100)
	var result: bool = _inv.remove_gold(0)
	assert_false(result)


func test_remove_gold_exact_amount() -> void:
	_inv.add_gold(50)
	var result: bool = _inv.remove_gold(50)
	assert_true(result)
	assert_eq(_inv.gold, 0)
```

Players will find every edge case. Your tests should find them first.

### Pattern: Testing Equipment Stat Aggregation

Equipment systems aggregate stat bonuses from multiple slots. Test individual slots and combined totals:

```gdscript
const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _manager: Node


func before_each() -> void:
	_manager = load("res://autoloads/equipment_manager.gd").new()
	add_child_autofree(_manager)


func test_stat_bonuses_empty() -> void:
	var bonuses: Dictionary = _manager.get_stat_bonuses(&"kael")
	assert_eq(bonuses["attack"], 0)
	assert_eq(bonuses["defense"], 0)


func test_stat_bonuses_all_slots_combined() -> void:
	var sword := Helpers.make_equipment({
		"slot_type": EquipmentData.SlotType.WEAPON,
		"attack_bonus": 10,
	})
	var helmet := Helpers.make_equipment({
		"slot_type": EquipmentData.SlotType.HELMET,
		"defense_bonus": 5,
	})
	var chest := Helpers.make_equipment({
		"slot_type": EquipmentData.SlotType.CHEST,
		"defense_bonus": 8, "max_hp_bonus": 20,
	})
	_manager.equip(&"kael", sword)
	_manager.equip(&"kael", helmet)
	_manager.equip(&"kael", chest)

	var bonuses: Dictionary = _manager.get_stat_bonuses(&"kael")
	assert_eq(bonuses["attack"], 10)
	assert_eq(bonuses["defense"], 13)  # 5 + 8
	assert_eq(bonuses["max_hp"], 20)
```

### Pattern: Testing Return Value Contracts

Many game operations return a boolean indicating success or failure. Test both paths and verify that state is unchanged on failure:

```gdscript
func test_remove_item_decrements() -> void:
	_inv.add_item(&"potion", 3)
	var result: bool = _inv.remove_item(&"potion", 1)
	assert_true(result)
	assert_eq(_inv.get_item_count(&"potion"), 2)


func test_remove_item_fails_when_insufficient() -> void:
	_inv.add_item(&"potion", 2)
	var result: bool = _inv.remove_item(&"potion", 5)
	assert_false(result)
	assert_eq(_inv.get_item_count(&"potion"), 2)  # unchanged
```

### Pattern: Defensive Copies

Verify that getters return copies, not references to internal state:

```gdscript
func test_get_all_items_returns_copy() -> void:
	_inv.add_item(&"potion", 2)
	var items: Dictionary = _inv.get_all_items()
	# Mutating the copy should not affect internal state
	items[&"potion"] = 99
	assert_eq(_inv.get_item_count(&"potion"), 2)
```

## Test Naming Conventions

Good test names describe the behavior, not the implementation:

```gdscript
# Good — describes behavior
func test_remove_gold_fails_when_insufficient() -> void:
func test_overload_doubles_outgoing_damage() -> void:
func test_transition_to_same_state_is_noop() -> void:

# Bad — describes implementation
func test_remove_gold_method() -> void:
func test_overload_case() -> void:
func test_transition_check() -> void:
```

Group related tests with comment headers:

```gdscript
# --- add_item ---

func test_add_item_creates_entry() -> void:
	...

func test_add_item_stacks() -> void:
	...

# --- remove_item ---

func test_remove_item_decrements() -> void:
	...
```

## Common Mistakes

**Testing the engine instead of your code.** If your test verifies that `Array.size()` returns the right number after `append()`, you are testing Godot, not your game. Test your logic — the formulas, the state changes, the business rules.

**Coupling tests to other tests.** If `test_b` assumes that `test_a` ran first and left certain state, your tests are order-dependent. The `before_each()` pattern prevents this by creating fresh instances for every test.

**Loading `.tres` files in unit tests.** Resource files require Godot's import system, which may not be fully available in headless mode. Use factory functions to create Resources in code instead:

```gdscript
# Bad — depends on import system
var enemy := load("res://data/enemies/slime.tres") as EnemyData

# Good — self-contained, always works
var enemy := Helpers.make_enemy_data({
	"id": &"slime", "max_hp": 30, "attack": 8,
})
```

**Ignoring signal behavior.** If a method is supposed to emit a signal, test that it does. If it is supposed to *not* emit a signal on failure, test that too. Signal behavior is part of your public API.

**Giant test functions.** Each test should verify one behavior. If you find yourself writing a test with 15 assertions and three setup stages, split it into multiple tests. Each test name should clearly communicate what it checks.

## What Is Next

With a tested, reliable codebase, the final chapter covers how all your systems connect into a playable game loop, how to export builds for different platforms, and how to plan your next steps beyond the first demo.

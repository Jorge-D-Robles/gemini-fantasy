# Chapter 11 — Battle Commands and Targeting

The state machine drives the flow. Battlers hold the stats. The turn queue decides who goes next. But none of that matters until the player can actually *do something* — pick "Attack," choose a target, and watch the sword swing.

This chapter builds the input layer: the command menu, ability and item selection, target picking, and the BattleAction container that carries the player's decision from the UI to the execution engine. We also build the enemy AI, which makes the same kinds of decisions without any UI at all.

## What We Are Building

- **BattleAction** — a runtime container with static factory methods for each action type
- **PlayerTurnState** — shows the command menu, routes to sub-states
- **ActionSelectState** — skill and item submenu selection
- **TargetSelectState** — cursor-based target picking
- **EnemyTurnState** — AI decision-making and execution
- **The signal contract** between BattleUI and battle states
- **Five AI patterns** — BASIC, AGGRESSIVE, DEFENSIVE, SUPPORT, BOSS

## BattleAction — The Decision Container

When a player picks "Attack" and selects a target, that decision needs to travel from the UI to the execution engine. The `BattleAction` class is the envelope that carries it.

```gdscript
# game/resources/battle_action.gd
class_name BattleAction
extends RefCounted

## Encapsulates a battle action chosen by a battler.

enum Type {
	ATTACK,
	ABILITY,
	DEFEND,
	WAIT,
	ITEM,
}

var type: Type = Type.WAIT
var target: Battler = null
var ability: AbilityData = null
var item: ItemData = null
```

BattleAction extends `RefCounted`, not `Resource`. It is a runtime-only object — never saved to disk, never loaded from a `.tres` file. It exists for the duration of one turn, then is discarded.

### Static Factory Methods

Instead of exposing the constructor and letting callers set fields manually, BattleAction provides static factory methods. Each one creates a correctly configured action in one call:

```gdscript
static func create_attack(p_target: Battler) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ATTACK
	action.target = p_target
	return action


static func create_ability(
	p_ability: AbilityData,
	p_target: Battler,
) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ABILITY
	action.ability = p_ability
	action.target = p_target
	return action


static func create_item(
	p_item: ItemData,
	p_target: Battler,
) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ITEM
	action.item = p_item
	action.target = p_target
	return action


static func create_defend() -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.DEFEND
	return action


static func create_wait() -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.WAIT
	return action
```

**Engineering parallel:** These are the same pattern as static factory methods in Java/TypeScript — `BattleAction.create_attack(target)` instead of `new BattleAction(Type.ATTACK, target, null, null)`. Factories make it impossible to create an ATTACK action without a target, or an ABILITY action without an AbilityData.

Notice that `create_ability()` and `create_item()` accept a `null` target. This is intentional — the target is often not known when the ability is selected. The ActionSelectState creates the action with a null target, and the TargetSelectState fills it in later:

```
ActionSelect: action = BattleAction.create_ability(fireball, null)
      │
      ▼
TargetSelect: action.target = selected_enemy
      │
      ▼
ActionExecute: execute(action)  ← now has both ability and target
```

## The Signal Contract Between UI and States

Battle states and the BattleUI communicate exclusively through signals. States never call UI methods directly to get input, and the UI never calls state methods. This keeps both sides decoupled.

The BattleUI emits these signals:

| Signal | Emitted When | Consumed By |
|--------|-------------|-------------|
| `command_selected(command: String)` | Player picks from Attack/Skill/Item/Defend/Flee | PlayerTurnState |
| `skill_selected(ability: Resource)` | Player picks a specific ability | ActionSelectState |
| `item_selected(item: Resource)` | Player picks a specific item | ActionSelectState |
| `submenu_cancelled` | Player presses back/cancel in a submenu | ActionSelectState |
| `target_selected(target: Battler)` | Player confirms a target | TargetSelectState |
| `target_cancelled` | Player presses back/cancel during targeting | TargetSelectState |

States connect to these signals in `enter()` and disconnect in `exit()`. This is crucial — if PlayerTurnState stays connected to `command_selected` while the game is in TargetSelectState, pressing a command button during target selection would trigger the wrong handler.

```gdscript
func enter() -> void:
	# ... show UI ...
	if not _battle_ui.command_selected.is_connected(_on_command_selected):
		_battle_ui.command_selected.connect(_on_command_selected)


func exit() -> void:
	if _battle_ui and _battle_ui.command_selected.is_connected(_on_command_selected):
		_battle_ui.command_selected.disconnect(_on_command_selected)
```

The `is_connected()` guard prevents double-connecting if a state is entered twice without exiting (which can happen during rapid transitions).

## PlayerTurnState — The Command Menu

When it is a party member's turn, PlayerTurnState shows the command menu and waits for the player's choice.

```gdscript
# game/systems/battle/states/player_turn_state.gd
extends State

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	# Clear defend stance from the previous turn
	if battle_scene.current_battler:
		battle_scene.current_battler.is_defending = false

	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	if not _battle_ui:
		push_error("PlayerTurnState: BattleUI not found.")
		state_machine.transition_to("TurnEnd")
		return

	_battle_ui.show_command_menu(battle_scene.current_battler)

	if not _battle_ui.command_selected.is_connected(_on_command_selected):
		_battle_ui.command_selected.connect(_on_command_selected)


func exit() -> void:
	if _battle_ui and _battle_ui.command_selected.is_connected(_on_command_selected):
		_battle_ui.command_selected.disconnect(_on_command_selected)
```

The first thing `enter()` does is clear `is_defending`. A character who defended last turn should not keep defending forever. The defend stance persists through TurnEnd (so enemies attacking between turns still hit the reduced damage), but clears when the character's next turn starts.

### Command Routing

When the player selects a command, the handler routes to the appropriate next state:

```gdscript
func _on_command_selected(command: String) -> void:
	match command:
		"attack":
			state_machine.transition_to("TargetSelect")
		"skill":
			battle_scene.pending_command = "skill"
			state_machine.transition_to("ActionSelect")
		"item":
			battle_scene.pending_command = "item"
			state_machine.transition_to("ActionSelect")
		"defend":
			battle_scene.current_battler.defend()
			_battle_ui.hide_command_menu()
			state_machine.transition_to("TurnEnd")
		"flee":
			if battle_scene.can_escape:
				battle_scene.end_battle(false)
			else:
				_battle_ui.show_command_menu(battle_scene.current_battler)
```

The routing logic:

| Command | Route | Why |
|---------|-------|-----|
| Attack | TargetSelect | Need to pick which enemy to hit |
| Skill | ActionSelect | Need to pick which skill, then a target |
| Item | ActionSelect | Need to pick which item, then a target |
| Defend | TurnEnd | No target needed — immediate effect |
| Flee | end_battle | Escape (if allowed) or show error |

Defend is the simplest command — it calls `battler.defend()` (which sets `is_defending = true` and adds resonance), then immediately ends the turn. No target selection needed.

Flee either ends the battle immediately (not a victory — the player ran away) or shows a "Can't escape!" message if the battle is non-escapable (boss fights, story encounters).

## ActionSelectState — Submenu Selection

When the player picks "Skill" or "Item" from the command menu, ActionSelectState shows the appropriate submenu.

```gdscript
# game/systems/battle/states/action_select_state.gd
extends State

var battle_scene: Node = null
var _battle_ui: Node = null
var _mode: String = ""


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	if not _battle_ui:
		state_machine.transition_to("PlayerTurn")
		return

	_mode = battle_scene.pending_command

	if _mode == "item":
		var usable: Array[ItemData] = InventoryManager.get_usable_items()
		if usable.is_empty():
			state_machine.transition_to("PlayerTurn")
			return
		var items_as_resource: Array[Resource] = []
		for item in usable:
			items_as_resource.append(item)
		_battle_ui.show_item_submenu(items_as_resource)
		if not _battle_ui.item_selected.is_connected(_on_item_selected):
			_battle_ui.item_selected.connect(_on_item_selected)
		if not _battle_ui.submenu_cancelled.is_connected(_on_cancelled):
			_battle_ui.submenu_cancelled.connect(_on_cancelled)
	else:
		var battler: Battler = battle_scene.current_battler
		if battler is PartyBattler:
			var party_battler := battler as PartyBattler
			var available := party_battler.get_available_abilities()
			if available.is_empty():
				state_machine.transition_to("PlayerTurn")
				return
			_battle_ui.show_skill_submenu(available)
			if not _battle_ui.skill_selected.is_connected(_on_skill_selected):
				_battle_ui.skill_selected.connect(_on_skill_selected)
			if not _battle_ui.submenu_cancelled.is_connected(_on_cancelled):
				_battle_ui.submenu_cancelled.connect(_on_cancelled)
		else:
			state_machine.transition_to("PlayerTurn")
```

Key behaviors:
- **Empty check:** If the player has no usable items or no affordable abilities, immediately return to the command menu. Do not show an empty submenu.
- **Filtered abilities:** `get_available_abilities()` only returns skills the character can afford (enough EE and resonance). Unaffordable skills are hidden, not grayed out.
- **Cancellation:** Pressing back/cancel emits `submenu_cancelled`, which returns to PlayerTurnState.

When a skill or item is selected, the state creates a `BattleAction` with a null target and transitions to TargetSelect:

```gdscript
func _on_skill_selected(ability: Resource) -> void:
	var ability_data := ability as AbilityData
	battle_scene.current_action = BattleAction.create_ability(ability_data, null)
	state_machine.transition_to("TargetSelect")


func _on_item_selected(item: Resource) -> void:
	var item_data := item as ItemData
	InventoryManager.remove_item(item_data.id)
	battle_scene.current_action = BattleAction.create_item(item_data, null)
	state_machine.transition_to("TargetSelect")
```

Notice that items are consumed immediately on selection (before targeting). This is a design choice — you spend the item when you pick it, not when you use it. If you cancel during targeting, the item is already gone. Some JRPGs handle this differently. Adjust based on your design preference.

### Signal Cleanup

`exit()` disconnects all signals that might have been connected:

```gdscript
func exit() -> void:
	if _battle_ui:
		if _battle_ui.skill_selected.is_connected(_on_skill_selected):
			_battle_ui.skill_selected.disconnect(_on_skill_selected)
		if _battle_ui.item_selected.is_connected(_on_item_selected):
			_battle_ui.item_selected.disconnect(_on_item_selected)
		if _battle_ui.submenu_cancelled.is_connected(_on_cancelled):
			_battle_ui.submenu_cancelled.disconnect(_on_cancelled)
```

Every `connect()` in `enter()` must have a matching `disconnect()` in `exit()`. Without this, you will get phantom signal connections that fire in wrong states.

## TargetSelectState — Picking a Target

After the player decides *what* to do (attack, use a specific skill), they need to decide *who* to do it to. TargetSelectState handles this.

```gdscript
# game/systems/battle/states/target_select_state.gd
extends State

const BAX = preload("res://systems/battle/battle_action_executor.gd")

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	if not _battle_ui:
		state_machine.transition_to("PlayerTurn")
		return

	# AoE and SELF abilities skip manual target selection
	var action: BattleAction = battle_scene.current_action
	if action and action.ability and BAX.is_auto_target(action.ability):
		state_machine.transition_to("ActionExecute")
		return

	# Determine valid targets
	var targets: Array[Battler] = _get_valid_targets()
	if targets.is_empty():
		state_machine.transition_to("PlayerTurn")
		return

	_battle_ui.show_target_selector(targets)

	if not _battle_ui.target_selected.is_connected(_on_target_selected):
		_battle_ui.target_selected.connect(_on_target_selected)
	if not _battle_ui.target_cancelled.is_connected(_on_cancelled):
		_battle_ui.target_cancelled.connect(_on_cancelled)
```

### Auto-Targeting

Not all abilities need manual target selection. AoE abilities (ALL_ENEMIES, ALL_ALLIES) and SELF-targeted abilities know their targets implicitly. When TargetSelectState detects one of these, it skips the targeting UI entirely and goes straight to ActionExecute.

The `BattleActionExecutor.is_auto_target()` helper checks the ability's `target_type`:

```gdscript
static func is_auto_target(ability: AbilityData) -> bool:
	if not ability:
		return false
	return (
		ability.target_type == AbilityData.TargetType.ALL_ENEMIES
		or ability.target_type == AbilityData.TargetType.ALL_ALLIES
		or ability.target_type == AbilityData.TargetType.SELF
	)
```

### Valid Target Determination

The valid targets depend on what action the player is taking:

```gdscript
func _get_valid_targets() -> Array[Battler]:
	var action: BattleAction = battle_scene.current_action
	if not action:
		return battle_scene.get_living_enemies()

	# Check if the action targets allies
	var target_type: int = -1
	if action.ability:
		target_type = action.ability.target_type
	elif action.item:
		target_type = action.item.target_type

	if target_type == AbilityData.TargetType.SINGLE_ALLY:
		return battle_scene.get_living_party()
	if target_type == AbilityData.TargetType.ALL_ALLIES:
		return battle_scene.get_living_party()
	if target_type == AbilityData.TargetType.SELF:
		var result: Array[Battler] = []
		if battle_scene.current_battler and battle_scene.current_battler.is_alive:
			result.append(battle_scene.current_battler)
		return result

	# Default: target enemies
	return battle_scene.get_living_enemies()
```

The targeting enum drives the UI:

| TargetType | Valid Targets | UI Behavior |
|-----------|--------------|------------|
| `SINGLE_ENEMY` | Living enemies | Cursor over enemy sprites |
| `ALL_ENEMIES` | All living enemies | Auto-target (no cursor) |
| `SINGLE_ALLY` | Living party members | Cursor over party sprites |
| `ALL_ALLIES` | All living party | Auto-target (no cursor) |
| `SELF` | Current battler only | Auto-target (no cursor) |

### Target Selection and Cancellation

```gdscript
func _on_target_selected(target: Battler) -> void:
	if battle_scene.current_action:
		battle_scene.current_action.target = target
	else:
		battle_scene.current_action = BattleAction.create_attack(target)
	state_machine.transition_to("ActionExecute")


func _on_cancelled() -> void:
	battle_scene.current_action = null
	state_machine.transition_to("PlayerTurn")
```

When the player confirms a target, the target is set on the existing BattleAction and control moves to ActionExecute. When they cancel, the action is discarded and control returns to the command menu.

For a basic "Attack" command (no intermediate ActionSelect step), there is no existing `current_action`, so a new attack action is created with the selected target.

## The Defend Command

Defend is the simplest command and does not need ActionSelect or TargetSelect. When the player picks "Defend" in PlayerTurnState, it executes immediately:

```gdscript
"defend":
	battle_scene.current_battler.defend()
	_battle_ui.hide_command_menu()
	state_machine.transition_to("TurnEnd")
```

The `defend()` method on Battler sets a flag and adds resonance:

```gdscript
func defend() -> void:
	is_defending = true
	if resonance_state != ResonanceState.HOLLOW:
		add_resonance(GB.DEFEND_RESONANCE_BASE * GB.RESONANCE_GAIN_DEFENDING)
```

`is_defending` stays `true` until the battler's *next* PlayerTurnState.enter() clears it. This means:
1. Character defends on turn 3.
2. Enemies attack the character on turns 3-4 — they hit into the defend stance (half damage).
3. Character's turn comes again on turn 5 — `is_defending` is cleared, and the character picks a new action.

This design gives Defend tactical value — it is not just "skip your turn," it actively reduces damage from every incoming attack until your next turn.

## EnemyTurnState — AI Decision-Making

When the TurnQueue determines that an enemy acts next, EnemyTurnState handles everything: AI decision, action execution, and transition.

```gdscript
# game/systems/battle/states/enemy_turn_state.gd
extends State

const BAX = preload("res://systems/battle/battle_action_executor.gd")
const ENEMY_TURN_DELAY: float = 0.4

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")

	var enemy := battle_scene.current_battler as EnemyBattler
	if not enemy or not enemy.is_alive:
		state_machine.transition_to("TurnQueueState")
		return

	var party: Array[Battler] = []
	party.assign(battle_scene.party_battlers)
	var allies: Array[Battler] = []
	allies.assign(battle_scene.enemy_battlers)
	var action := enemy.choose_action(party, allies)

	match action.type:
		BattleAction.Type.ATTACK:
			await BAX.execute_attack(enemy, action.target, battle_scene, _battle_ui)
		BattleAction.Type.ABILITY:
			enemy.use_ee(action.ability.ee_cost)
			await BAX.execute_ability(
				enemy, action.ability, action.target, battle_scene, _battle_ui,
			)
		BattleAction.Type.DEFEND:
			enemy.defend()

	battle_scene.refresh_battle_ui()
	await get_tree().create_timer(ENEMY_TURN_DELAY).timeout

	var result: int = battle_scene.check_battle_end()
	if result == 1:
		state_machine.transition_to("Victory")
	elif result == -1:
		state_machine.transition_to("Defeat")
	else:
		state_machine.transition_to("TurnEnd")
```

Unlike player turns (which span multiple states over multiple frames), enemy turns happen in a single state. The AI decides and executes in one `enter()` call. A 0.4-second delay after execution gives the player time to read the battle log before the next turn starts.

### The Five AI Patterns

Enemy AI is driven by the `ai_type` field on `EnemyData`. Each type implements a different strategy in `EnemyBattler.choose_action()`:

#### BASIC — Random Target

The simplest AI. Pick a random living party member and attack them.

```gdscript
func _basic_ai(party: Array[Battler]) -> BattleAction:
	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return BattleAction.create_wait()
	var target: Battler = living_targets[randi() % living_targets.size()]
	return BattleAction.create_attack(target)
```

Use for: Weak early-game enemies (slimes, rats, bats). Predictable and non-threatening.

#### AGGRESSIVE — Focus the Weak

Targets the party member with the lowest current HP. Uses abilities when available.

```gdscript
func _aggressive_ai(party: Array[Battler]) -> BattleAction:
	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return BattleAction.create_wait()

	# Pick lowest HP target
	var target: Battler = living_targets[0]
	for t in living_targets:
		if t.current_hp < target.current_hp:
			target = t

	# Use ability if available, else attack
	if not abilities.is_empty() and current_ee > 0:
		for ability_res in abilities:
			var ability_data := ability_res as AbilityData
			if ability_data and _can_use_ability_enemy(ability_data):
				return BattleAction.create_ability(ability_data, target)

	return BattleAction.create_attack(target)
```

Use for: Mid-game enemies, mini-bosses. Forces the player to heal or risk losing a party member.

#### DEFENSIVE — Self-Preservation

Defends when HP drops below 30%. Otherwise attacks randomly.

```gdscript
func _defensive_ai(party: Array[Battler]) -> BattleAction:
	if current_hp < max_hp * GB.AI_DEFENSIVE_HP_THRESHOLD:
		return BattleAction.create_defend()

	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return BattleAction.create_wait()
	var target: Battler = living_targets[randi() % living_targets.size()]
	return BattleAction.create_attack(target)
```

Use for: Tanky enemies, shield-bearers. Creates a "break through the defense" dynamic.

#### SUPPORT — Heal Allies

Checks if any allied enemy is below 50% HP. If so, tries to use a healing ability. Otherwise attacks.

```gdscript
func _support_ai(
	party: Array[Battler],
	allies: Array[Battler],
) -> BattleAction:
	var injured: Array = _get_living(allies).filter(
		func(b: Battler) -> bool:
			return b.current_hp < b.max_hp * GB.AI_SUPPORT_HEAL_THRESHOLD
	)
	if not injured.is_empty() and not abilities.is_empty():
		for ability_res in abilities:
			var ability_data := ability_res as AbilityData
			if not ability_data or not _can_use_ability_enemy(ability_data):
				continue
			if ability_data.status_effect == "cure_all":
				return BattleAction.create_ability(
					ability_data, injured[0] as Battler
				)

	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return BattleAction.create_wait()
	var target: Battler = living_targets[randi() % living_targets.size()]
	return BattleAction.create_attack(target)
```

Use for: Healer enemies that appear alongside damage-dealers. Forces the player to prioritize: kill the healer first, or burst through the healing.

#### BOSS — Phase-Based

Currently uses the aggressive pattern as a base. Boss AI is typically custom-scripted per boss with phase transitions based on HP thresholds. The BOSS enum value exists as a hook for that customization.

A full boss AI might look like:

```gdscript
# Not in the current codebase — example of where BOSS AI would evolve
func _boss_ai(party: Array[Battler], allies: Array[Battler]) -> BattleAction:
	var hp_percent := float(current_hp) / float(max_hp)
	if hp_percent < 0.25:
		# Phase 3: desperate — use strongest ability
		return _use_strongest_ability(party)
	elif hp_percent < 0.5:
		# Phase 2: aggressive — AoE attacks
		return _use_aoe_ability(party)
	else:
		# Phase 1: normal — aggressive pattern
		return _aggressive_ai(party)
```

### AI Design Principles

1. **AI never cheats.** Enemies follow the same rules as players — they spend EE for abilities, they check `_can_use_ability_enemy()` for costs, they can only target living battlers.
2. **AI uses the same BattleAction factories.** The execution pipeline does not care who created the action — player input and AI output produce identical BattleAction objects.
3. **AI is deterministic given inputs.** For testing, you can verify that a DEFENSIVE enemy with 20% HP will always choose to defend.

## BattleActionExecutor — Shared Execution Logic

Both player actions (via ActionExecuteState) and enemy actions (via EnemyTurnState) need to execute attacks and abilities. Rather than duplicating the logic, a shared static class handles it.

```gdscript
# game/systems/battle/battle_action_executor.gd
class_name BattleActionExecutor
extends RefCounted

static func execute_attack(
	attacker: Battler,
	target: Battler,
	scene: Node,
	battle_ui: Node,
) -> void:
	if not target or not target.is_alive:
		return

	var is_crit := BattlerDamage.roll_crit(attacker.luck)
	var damage := attacker.deal_damage(attacker.attack)
	if is_crit:
		damage = BattlerDamage.apply_crit(damage)
	var actual := target.take_damage(damage)

	# Audio and visual feedback
	if is_crit:
		AudioManager.play_sfx(load(SfxLibrary.COMBAT_CRITICAL_HIT))
	else:
		AudioManager.play_sfx(load(SfxLibrary.COMBAT_ATTACK_HIT))

	# Battle log
	if battle_ui:
		var prefix: String = "CRITICAL HIT! " if is_crit else ""
		battle_ui.add_battle_log(
			"%s%s attacks %s for %d damage!" % [
				prefix, attacker.get_display_name(),
				target.get_display_name(), actual,
			],
		)
```

The execution flow for an attack:
1. Roll for critical hit (based on attacker's luck stat).
2. Calculate outgoing damage (`attacker.deal_damage()` — includes stat bonus and resonance modifiers).
3. Apply crit multiplier if critical.
4. Apply damage to target (`target.take_damage()` — includes defense calculation and resonance state).
5. Play audio and visual feedback.
6. Log the result.

This same function is called whether the attacker is a party member or an enemy. The battle system does not distinguish — an attack is an attack.

## How It Connects

The complete flow for a player turn:

```
TurnQueueState
  → advance() returns PartyBattler
  → transition_to("PlayerTurn")

PlayerTurnState
  → show_command_menu()
  → player picks "Skill"
  → pending_command = "skill"
  → transition_to("ActionSelect")

ActionSelectState
  → show_skill_submenu(available_abilities)
  → player picks "Fireball"
  → current_action = BattleAction.create_ability(fireball, null)
  → transition_to("TargetSelect")

TargetSelectState
  → get_valid_targets() → living enemies
  → show_target_selector(enemies)
  → player picks Goblin
  → current_action.target = goblin
  → transition_to("ActionExecute")

ActionExecuteState
  → execute ability: spend EE, calculate damage, apply to target
  → check_battle_end()
  → transition_to("TurnEnd")

TurnEnd
  → tick_effects()
  → end_turn()
  → transition_to("TurnQueueState")
```

The complete flow for an enemy turn:

```
TurnQueueState
  → advance() returns EnemyBattler
  → transition_to("EnemyTurn")

EnemyTurnState
  → enemy.choose_action(party, allies)
  → execute attack/ability/defend directly
  → check_battle_end()
  → transition_to("TurnEnd")

TurnEnd
  → tick_effects()
  → end_turn()
  → transition_to("TurnQueueState")
```

## Common Mistakes

**Not disconnecting signals on state exit.** This is worth repeating. If ActionSelectState connects `skill_selected` in `enter()` and does not disconnect in `exit()`, and the player somehow triggers another state transition, the old connection fires in the new state context. Always mirror every `connect()` with a `disconnect()`.

**Forgetting the empty-list check.** If a character has no affordable abilities or the inventory has no usable items, showing an empty submenu is a dead end. Always check for empty lists before showing the UI.

**Executing the action in the wrong state.** Action execution happens in ActionExecuteState (for players) or EnemyTurnState (for enemies). TargetSelectState only *selects* the target — it does not execute. PlayerTurnState only *routes* — it does not execute (except Defend, which is simple enough to handle inline).

**Not checking `is_alive` on the target.** Between the time a target is selected and the time the action executes, another effect (status tick, counter-attack) could kill the target. Always guard with `if not target or not target.is_alive: return`.

## What Is Next

The player can pick commands and targets. Enemies have AI. Actions are created and dispatched. But what actually happens when an attack hits? How is damage calculated? What do the Resonance states do to your numbers? Chapter 12 dives into the math: damage formulas, elemental weaknesses, critical hits, the Resonance gauge, status effects, and the victory and defeat states that resolve the battle.

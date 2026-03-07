# Chapter 12 — Battle Math and Resolution

The battle system has a state machine, battlers, a turn queue, commands, targeting, and AI. Now we need the math. When a sword hits an enemy, how much damage does it deal? What happens when a fire spell hits a creature weak to fire? When does a character enter the Resonance state, and what does that mean for their numbers?

This chapter builds the pure calculation layer — static utility classes with no side effects, no state, and no dependencies on the scene tree. These are the most testable classes in the entire project.

## What We Are Building

- **BattlerDamage** — outgoing and incoming damage formulas, critical hits, elemental modifiers
- **BattlerResonance** — gauge management, state transitions, turn delay calculation
- **BattlerStatus** — status effect application, ticking, and removal
- **ActionExecuteState** — the state that applies actions and checks for battle end
- **VictoryState** — XP distribution, gold rewards, level-up checks
- **DefeatState** — game over flow
- **Persisting state** — writing HP/EE back to PartyManager after battle ends

## Why Static Utility Classes

Every damage calculation in this chapter is a static function. No instances. No state. No `self`.

```gdscript
static func calculate_outgoing(
	base: int,
	stat_value: int,
	resonance_state: int,
	is_ability: bool,
) -> int:
```

**Engineering parallel:** These are pure utility functions — the same pattern as a TypeScript utility module full of `export function calculateDamage(...)`. Given the same inputs, they always produce the same output. No side effects, no reading from globals.

This is not just a style choice. It has concrete benefits:

1. **Testable without a scene tree.** You can call `BattlerDamage.calculate_outgoing(50, 15, 0, false)` in a unit test with no nodes, no autoloads, no engine initialization.
2. **No circular dependencies.** If damage functions were methods on Battler, and Battler imported BattlerDamage, you would have a circular reference. Static utilities break the cycle.
3. **Single Responsibility.** Battler manages state and emits signals. BattlerDamage calculates numbers. BattlerResonance handles gauge transitions. Each class does one thing.

## BattlerDamage — The Damage Pipeline

### Outgoing Damage

When a battler attacks or uses an offensive ability, outgoing damage is calculated first:

```gdscript
# game/systems/battle/battler_damage.gd
class_name BattlerDamage
extends RefCounted

const GB = preload("res://systems/game_balance.gd")


static func calculate_outgoing(
	base: int,
	stat_value: int,
	resonance_state: int,
	is_ability: bool,
) -> int:
	var effective_stat := stat_value
	if resonance_state == 3:  # HOLLOW
		effective_stat = int(stat_value * GB.HOLLOW_STAT_PENALTY)

	var stat_bonus := effective_stat * GB.STAT_DAMAGE_SCALING
	var total := int(base + stat_bonus)

	if resonance_state == 2:  # OVERLOAD
		total = int(total * GB.OVERLOAD_OUTGOING_DAMAGE_MULT)
	elif resonance_state == 1 and is_ability:  # RESONANT + ability
		total = int(total * GB.RESONANT_ABILITY_BONUS)

	return total
```

The formula in plain language:

```
outgoing = base_power + (stat * 0.5)
```

Where `stat` is the attacker's Attack (for physical) or Magic (for magical). Then resonance modifiers apply:

| Resonance State | Modifier |
|----------------|----------|
| FOCUSED | None — normal damage |
| RESONANT | +20% to abilities only (not basic attacks) |
| OVERLOAD | x2 to everything |
| HOLLOW | -50% stat penalty (stat is halved before scaling) |

With concrete numbers: a character with 20 Attack using a basic attack (base 10) in FOCUSED state:
- `outgoing = 10 + (20 * 0.5) = 10 + 10 = 20`

Same attack in OVERLOAD:
- `outgoing = (10 + 10) * 2 = 40`

Same character using a 30-power ability in RESONANT:
- `outgoing = (30 + 10) * 1.2 = 48`

### Incoming Damage

After outgoing damage is calculated, the target's defenses reduce it:

```gdscript
static func calculate_incoming(
	base: int,
	def_stat: int,
	resonance_state: int,
	is_defending: bool,
) -> int:
	var effective_def := def_stat
	if resonance_state == 3:  # HOLLOW
		effective_def = int(def_stat * GB.HOLLOW_STAT_PENALTY)

	var defense_mod := 1.0 - (effective_def / GB.DEFENSE_SCALING_DIVISOR)
	defense_mod = clampf(defense_mod, GB.DEFENSE_MOD_MIN, 1.0)

	if is_defending:
		defense_mod *= GB.DEFEND_DAMAGE_REDUCTION

	if resonance_state == 2:  # OVERLOAD
		defense_mod *= GB.OVERLOAD_INCOMING_DAMAGE_MULT

	return maxi(int(base * defense_mod), 1)
```

The defense formula:

```
defense_mod = 1.0 - (defense / 200.0)    ← clamped to [0.1, 1.0]
incoming = outgoing * defense_mod          ← minimum 1 damage
```

A character with 40 defense:
- `defense_mod = 1.0 - (40 / 200) = 1.0 - 0.2 = 0.8`
- They take 80% of outgoing damage.

A character with 100 defense:
- `defense_mod = 1.0 - (100 / 200) = 0.5`
- They take 50% of outgoing damage.

Defense cannot reduce damage below 10% (the `DEFENSE_MOD_MIN` clamp), so even a tank with 200+ defense still takes some damage.

Additional modifiers stack multiplicatively:

| Modifier | Effect |
|----------|--------|
| Defending | x0.5 (halves incoming damage) |
| OVERLOAD | x2.0 (doubles incoming damage) |
| HOLLOW | Defense stat halved before calculation |

A defending character in OVERLOAD state: `defense_mod * 0.5 * 2.0 = defense_mod * 1.0`. The defend and overload multipliers cancel out — they take normal damage while defending in overload.

**Damage always deals at least 1.** The `maxi(..., 1)` ensures no attack is completely wasted.

### Critical Hits

Critical hits are determined by the attacker's luck stat:

```gdscript
static func compute_crit_chance(luck: int) -> float:
	return clampf(
		GB.CRIT_BASE_CHANCE + luck * GB.CRIT_LUCK_BONUS_PER_POINT,
		0.0,
		1.0,
	)


static func roll_crit(luck: int) -> bool:
	return randf() < compute_crit_chance(luck)


static func apply_crit(damage: int) -> int:
	return int(damage * GB.CRIT_DAMAGE_MULT)
```

The formula:

```
crit_chance = 0.05 + (luck * 0.005)    ← 5% base + 0.5% per luck point
crit_damage = damage * 1.5
```

A character with 10 luck has a `0.05 + 0.05 = 10%` crit chance. A character with 30 luck has `0.05 + 0.15 = 20%`. The chance is clamped to [0, 1], so it can theoretically reach 100% with enough luck (190 luck for guaranteed crits — unlikely in normal gameplay).

`compute_crit_chance()` is separated from `roll_crit()` so tests can verify the chance formula without involving randomness.

### Elemental Modifiers

Abilities can have an element (Fire, Ice, Water, Wind, Earth, Light, Dark). Enemies can be weak or resistant to elements:

```gdscript
static func compute_elemental_modifier(
	ability_element: int,
	weaknesses: Array,
	resistances: Array,
) -> float:
	if ability_element == 0:  # Element.NONE
		return 1.0
	for w in weaknesses:
		if int(w) == ability_element:
			return GB.ELEMENTAL_WEAKNESS_MULT    # 1.5x
	for r in resistances:
		if int(r) == ability_element:
			return GB.ELEMENTAL_RESISTANCE_MULT  # 0.5x
	return 1.0
```

| Match | Multiplier | Effect |
|-------|-----------|--------|
| Weakness | 1.5x | 50% more damage |
| Resistance | 0.5x | 50% less damage |
| Neither | 1.0x | Normal damage |
| NONE element | 1.0x | Always normal (physical attacks) |

Weakness takes priority — if an element appears in both arrays (a data error), the weakness applies. This is a deliberate design choice: when in doubt, reward the player for exploiting weaknesses.

### The Complete Damage Pipeline

Here is the full path a damage number takes:

```
1. Attacker.deal_damage(base, is_magical, is_ability)
   └─ BattlerDamage.calculate_outgoing(base, stat, resonance, is_ability)
      └─ Apply stat bonus: base + stat * 0.5
      └─ Apply resonance: OVERLOAD x2, RESONANT +20% (abilities only)

2. Roll critical hit: BattlerDamage.roll_crit(luck)
   └─ If crit: damage = BattlerDamage.apply_crit(damage) → x1.5

3. Apply elemental modifier: BattlerDamage.compute_elemental_modifier(...)
   └─ Weakness x1.5, Resistance x0.5, Neutral x1.0

4. Target.take_damage(amount, is_magical)
   └─ BattlerDamage.calculate_incoming(amount, def, resonance, is_defending)
      └─ Apply defense: damage * (1 - def/200)
      └─ Apply defend stance: x0.5
      └─ Apply overload: x2.0
      └─ Floor at 1

5. target.current_hp -= final_damage
   └─ Emit hp_changed, damage_taken
   └─ If hp <= 0: emit defeated
```

## BattlerResonance — The Gauge System

The Resonance gauge is a four-state system that adds risk/reward to combat. Using abilities and taking damage builds the gauge. Higher gauge levels grant bonuses but also increase risk.

```
FOCUSED (0-74)  →  RESONANT (75-99)  →  OVERLOAD (100-150)  →  HOLLOW
   normal           +20% abilities       x2 damage both ways    -50% all stats
                                                                 no abilities
```

### State Transitions

```gdscript
# game/systems/battle/battler_resonance.gd
class_name BattlerResonance
extends RefCounted

const GB = preload("res://systems/game_balance.gd")


static func add_to_gauge(current: float, amount: float) -> float:
	return clampf(current + amount, 0.0, GB.RESONANCE_MAX)


static func evaluate_state(gauge: float, current_state: int) -> int:
	if current_state == 3:  # HOLLOW is sticky
		return 3

	if gauge >= GB.RESONANCE_OVERLOAD_THRESHOLD:  # 100.0
		return 2  # OVERLOAD
	if gauge >= GB.RESONANCE_RESONANT_THRESHOLD:   # 75.0
		return 1  # RESONANT
	return 0  # FOCUSED
```

The gauge is a float from 0 to 150. The state is determined by which range it falls in:

| Range | State | Effect |
|-------|-------|--------|
| 0 - 74.9 | FOCUSED | Normal operation |
| 75 - 99.9 | RESONANT | +20% ability damage |
| 100 - 150 | OVERLOAD | x2 outgoing AND x2 incoming damage |
| (special) | HOLLOW | -50% all stats, no ability use |

HOLLOW is different from the other states — it is not determined by the gauge value. A battler enters HOLLOW only by being defeated while in OVERLOAD. Once HOLLOW, the gauge value does not matter; the state is "sticky" and must be cured explicitly.

### Entering HOLLOW

```gdscript
static func on_defeated(resonance_state: int) -> Dictionary:
	if resonance_state == 2:  # OVERLOAD
		return {"state": 3, "gauge": 0.0, "changed": true}  # HOLLOW
	return {"state": resonance_state, "gauge": 0.0, "changed": false}
```

When a battler is defeated:
- If they were in OVERLOAD → they become HOLLOW (even after being revived)
- If they were in any other state → no resonance change

This creates the core risk/reward loop: OVERLOAD doubles your damage output, but if you die while overloaded, you come back HOLLOW — weaker than normal. Players must decide: push into OVERLOAD for the power spike, or defend to stay safe?

### Curing HOLLOW

HOLLOW can only be cured in two ways:
1. The "Ground" command — another party member spends 25 resonance gauge points to cure an ally's HOLLOW state.
2. Special items — a Resonance Stabilizer item calls `battler.cure_hollow()`.

```gdscript
# On Battler:
func cure_hollow() -> void:
	if resonance_state != ResonanceState.HOLLOW:
		return
	var old_state := resonance_state
	resonance_state = ResonanceState.FOCUSED
	resonance_gauge = 0.0
	resonance_changed.emit(resonance_gauge)
	resonance_state_changed.emit(old_state, resonance_state)
```

### Resonance Gain Sources

The gauge builds from several sources, each with its own scaling:

| Source | Formula |
|--------|---------|
| Dealing damage | `damage * 0.6 * 0.1` |
| Taking damage | `damage * 1.0 * 0.1` |
| Defending | `10.0 * 1.5` = 15 points per defend |

The `RESONANCE_GAIN_SCALING` constant (0.1) keeps gains proportional to the damage numbers in the game. Without it, a single big hit could push the gauge from 0 to 100.

### Turn Delay Calculation

Resonance state also affects turn order:

```gdscript
static func calculate_turn_delay(
	p_speed: int, resonance_state: int,
) -> float:
	var effective_speed := p_speed
	if resonance_state == 3:  # HOLLOW
		effective_speed = int(p_speed * GB.HOLLOW_STAT_PENALTY)
	if effective_speed > 0:
		return GB.TURN_DELAY_BASE / float(effective_speed)
	return GB.TURN_DELAY_BASE
```

HOLLOW characters act at half speed (double delay). A character with 20 speed normally has delay 5.0; in HOLLOW, they have delay 10.0.

## BattlerStatus — Status Effects

Status effects are the "buff and debuff" layer. Poison drains HP each turn. A strength buff increases attack. Stun prevents action. Each effect is defined by a `StatusEffectData` Resource template and tracked as an active instance with a remaining turn count.

### The StatusEffectData Template

```gdscript
# game/resources/status_effect_data.gd
class_name StatusEffectData
extends Resource

enum EffectType {
	BUFF,
	DEBUFF,
	DAMAGE_OVER_TIME,
	HEAL_OVER_TIME,
	STUN,
}

@export var id: StringName = &""
@export var display_name: String = ""
@export var effect_type: EffectType = EffectType.DEBUFF
@export var duration: int = 3           # turns (0 = permanent)
@export var tick_damage: int = 0        # HP lost per tick
@export var tick_heal: int = 0          # HP gained per tick
@export var prevents_action: bool = false

# Stat modifiers (flat bonuses/penalties applied while active)
@export var attack_modifier: int = 0
@export var magic_modifier: int = 0
@export var defense_modifier: int = 0
@export var resistance_modifier: int = 0
@export var speed_modifier: int = 0
@export var luck_modifier: int = 0
```

Common effects built from this template:

| Effect | Type | tick_damage | tick_heal | prevents_action | Stat Modifiers |
|--------|------|-------------|-----------|-----------------|----------------|
| Poison | DOT | 8 | 0 | false | — |
| Burn | DOT | 12 | 0 | false | — |
| Stun | STUN | 0 | 0 | true | — |
| Regen | HOT | 0 | 10 | false | — |
| Strength Up | BUFF | 0 | 0 | false | attack: +5 |
| Defense Down | DEBUFF | 0 | 0 | false | defense: -5 |

### Applying Effects

```gdscript
# game/systems/battle/battler_status.gd
class_name BattlerStatus
extends RefCounted


static func apply(
	effects: Array[Dictionary],
	effect_data: StatusEffectData,
) -> StringName:
	# If already present, refresh duration
	for entry: Dictionary in effects:
		var existing: StatusEffectData = entry["data"]
		if existing.id == effect_data.id:
			entry["remaining"] = effect_data.duration
			return &""  # not new

	# Add new effect
	effects.append({
		"data": effect_data,
		"remaining": effect_data.duration,
	})
	return effect_data.id  # new
```

Effects are stored as an array of dictionaries: `{"data": StatusEffectData, "remaining": int}`. The `data` field is the template (what the effect does), and `remaining` tracks how many turns until it expires.

If an effect with the same `id` is already active, re-applying it refreshes the duration instead of stacking. Poison applied twice does not deal double damage — it just resets the countdown.

The return value tells the caller whether the effect is new (return the id) or a refresh (return empty StringName). The Battler uses this to decide whether to emit `status_effect_applied`.

### Ticking Effects

At the end of each turn (in TurnEndState), `tick_effects()` processes all active effects:

```gdscript
# On Battler:
func tick_effects() -> void:
	if not is_alive:
		return

	var expired: Array[int] = []
	for i in _active_effects.size():
		var entry: Dictionary = _active_effects[i]
		var eff: StatusEffectData = entry["data"]

		# Apply tick damage (cannot kill — leaves at least 1 HP)
		if eff.tick_damage > 0:
			current_hp = maxi(current_hp - eff.tick_damage, 1)
			hp_changed.emit(current_hp, max_hp)

		# Apply tick healing
		if eff.tick_heal > 0:
			current_hp = mini(current_hp + eff.tick_heal, max_hp)
			hp_changed.emit(current_hp, max_hp)

		# Decrement duration (0 = permanent, never expires)
		var remaining: int = entry["remaining"]
		if remaining > 0:
			remaining -= 1
			entry["remaining"] = remaining
			if remaining <= 0:
				expired.append(i)

	# Remove expired effects in reverse order
	for i in range(expired.size() - 1, -1, -1):
		var idx: int = expired[i]
		var eff: StatusEffectData = _active_effects[idx]["data"]
		_active_effects.remove_at(idx)
		status_effect_removed.emit(eff.id)
```

Three important design decisions:

1. **DoT cannot kill.** Poison damage is clamped to leave at least 1 HP (`maxi(..., 1)`). This prevents the frustrating experience of dying to a poison tick between turns with no chance to heal. Only direct attacks can deliver a killing blow.

2. **Duration 0 means permanent.** An effect with `duration: 0` never decrements and never expires. It must be removed explicitly (by a cure ability or the end of battle). Use this for boss debuffs that persist until cleansed.

3. **Reverse-order removal.** When removing multiple expired effects, iterate the indices in reverse to avoid invalidating later indices. This is a classic array removal pattern.

### Stat Modifiers

Active status effects can modify stats. The `get_modified_stat()` method on Battler sums all active modifiers:

```gdscript
func get_modified_stat(stat_name: String) -> int:
	var base: int = 0
	match stat_name:
		"attack":
			base = attack
		"defense":
			base = defense
		# ... other stats
	if resonance_state == ResonanceState.HOLLOW:
		base = int(base * GB.HOLLOW_STAT_PENALTY)
	var modifier := BattlerStatus.get_total_modifier(_active_effects, stat_name)
	return maxi(base + modifier, 0)
```

And the static helper that sums modifiers:

```gdscript
static func get_total_modifier(
	effects: Array[Dictionary], stat_name: String,
) -> int:
	var total: int = 0
	for entry: Dictionary in effects:
		var eff: StatusEffectData = entry["data"]
		match stat_name:
			"attack":
				total += eff.attack_modifier
			"defense":
				total += eff.defense_modifier
			# ... other stats
	return total
```

A character with 15 base attack, a +5 Strength Up buff, and a -3 Weakness debuff has modified attack: `15 + 5 + (-3) = 17`. If they are also HOLLOW: `floor(15 * 0.5) + 5 + (-3) = 7 + 2 = 9`.

### Action Prevention

The STUN effect prevents the battler from acting. TurnQueueState checks this:

```gdscript
static func is_action_prevented(effects: Array[Dictionary]) -> bool:
	for entry: Dictionary in effects:
		var eff: StatusEffectData = entry["data"]
		if eff.prevents_action:
			return true
	return false
```

If any active effect has `prevents_action = true`, the battler's turn is skipped entirely — TurnQueueState transitions directly to TurnEnd without going through PlayerTurn or EnemyTurn.

## ActionExecuteState — Applying the Action

This state is where decisions become reality. It receives the `BattleAction` created during the player's turn (or the enemy's AI), executes it, and checks if the battle is over.

```gdscript
# game/systems/battle/states/action_execute_state.gd
extends State

var battle_scene: Node = null
var _battle_ui: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	_battle_ui = battle_scene.get_node_or_null("BattleUI")
	var battler: Battler = battle_scene.current_battler
	var action: BattleAction = battle_scene.current_action

	if not action:
		state_machine.transition_to("TurnEnd")
		return

	match action.type:
		BattleAction.Type.ATTACK:
			await _execute_attack(battler, action.target)
		BattleAction.Type.ABILITY:
			await _execute_ability(battler, action.target, action.ability)
		BattleAction.Type.ITEM:
			await _execute_item(battler, action.target, action.item)

	battle_scene.current_action = null
	battle_scene.refresh_battle_ui()

	# Brief delay for visual feedback
	await get_tree().create_timer(0.3).timeout

	# Check battle end
	var result: int = battle_scene.check_battle_end()
	if result == 1:
		state_machine.transition_to("Victory")
	elif result == -1:
		state_machine.transition_to("Defeat")
	else:
		state_machine.transition_to("TurnEnd")
```

### Ability Execution with AoE

Single-target abilities apply to one target. AoE abilities loop over all valid targets:

```gdscript
func _execute_ability(
	attacker: Battler,
	target: Battler,
	ability: AbilityData,
) -> bool:
	if not ability:
		return false
	if not attacker.use_ee(ability.ee_cost):
		return false  # not enough EE

	if BAX.is_aoe(ability):
		# Hit every living enemy (or every living ally)
		var targets: Array[Battler] = []
		match ability.target_type:
			AbilityData.TargetType.ALL_ENEMIES:
				targets = battle_scene.get_living_enemies()
			AbilityData.TargetType.ALL_ALLIES:
				targets = battle_scene.get_living_party()
		for t: Battler in targets:
			await BAX.execute_ability(
				attacker, ability, t, battle_scene, _battle_ui,
			)
	else:
		await BAX.execute_ability(
			attacker, ability, target, battle_scene, _battle_ui,
		)
	return true
```

EE is spent once for AoE abilities, not once per target. A 20 EE fireball that hits all enemies costs 20 EE total, not 60 for three enemies.

If `use_ee()` returns false (not enough EE), the action fails and `enter()` returns the player to the command menu to pick a different action.

### Item Execution

Items have their own effect types:

```gdscript
func _execute_item(
	_attacker: Battler,
	target: Battler,
	item: ItemData,
) -> void:
	if not item or not target:
		return
	match item.effect_type:
		ItemData.EffectType.HEAL_HP:
			var healed := target.heal(item.effect_value)
			# Play heal SFX and VFX
		ItemData.EffectType.HEAL_EE:
			var restored := target.restore_ee(item.effect_value)
			# Play heal SFX and VFX
		ItemData.EffectType.CURE_HOLLOW:
			target.cure_hollow()
			# Play cure SFX
```

Items bypass the damage pipeline entirely — a healing potion directly calls `target.heal(50)`, which adds HP up to the maximum.

### Status Effect Application

Abilities can apply status effects with a probability roll:

```gdscript
static func try_apply_status(
	ability: AbilityData,
	target: Battler,
	battle_ui: Node,
) -> void:
	if ability.status_effect.is_empty() or ability.status_chance <= 0.0:
		return
	if randf() < ability.status_chance:
		var effect := StatusEffectData.new()
		effect.id = StringName(ability.status_effect)
		effect.display_name = ability.status_effect
		effect.duration = ability.status_effect_duration
		target.apply_status(effect)
```

The ability defines what effect it applies (`status_effect` string), the chance (0.0 to 1.0), and the duration. An ability with `status_chance: 0.3` has a 30% chance to apply its effect after dealing damage.

## VictoryState — Rewards

When all enemies are defeated, VictoryState handles rewards:

```gdscript
# game/systems/battle/states/victory_state.gd
extends State

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	# Play victory fanfare
	var fanfare := load("res://assets/music/Success!.ogg") as AudioStream
	if fanfare:
		AudioManager.play_bgm(fanfare, 0.0)

	# Calculate rewards from all defeated enemies
	var total_exp: int = 0
	var total_gold: int = 0
	var items: Array[String] = []

	for b in battle_scene.enemy_battlers:
		if b is EnemyBattler:
			total_exp += b.exp_reward
			total_gold += b.gold_reward
			for loot_entry in b.loot_table:
				var chance: float = loot_entry.get("drop_chance", 0.0)
				if randf() < chance:
					items.append(loot_entry.get("item_id", "unknown"))

	# Apply gold and item rewards
	var inv: Node = get_node_or_null("/root/InventoryManager")
	if inv:
		inv.add_gold(total_gold)
		for item_id in items:
			inv.add_item(StringName(item_id), 1)

	# Apply XP to all active party members
	var pm: Node = get_node_or_null("/root/PartyManager")
	var level_ups: Array[Dictionary] = []
	if pm:
		level_ups = apply_xp_rewards(pm.get_active_party(), total_exp)

	# Show victory screen and wait for player to dismiss
	var battle_ui: Node = battle_scene.get_node_or_null("BattleUI")
	if battle_ui:
		battle_ui.show_victory(total_exp, total_gold, items, level_ups)

	await get_tree().create_timer(0.5).timeout
	if battle_ui and battle_ui.has_signal("victory_dismissed"):
		battle_ui.show_victory_dismiss_prompt()
		await battle_ui.victory_dismissed

	battle_scene.end_battle(true)
```

### XP Distribution

XP is shared equally among all active party members. The `LevelManager.add_xp()` static method handles multi-level-ups (if a character gains enough XP to jump multiple levels):

```gdscript
static func apply_xp_rewards(
	party: Array[Resource], total_exp: int,
) -> Array[Dictionary]:
	var level_ups: Array[Dictionary] = []
	for member: Resource in party:
		if member is CharacterData:
			var results := LevelManager.add_xp(member, total_exp)
			for changes: Dictionary in results:
				level_ups.append({
					"character": member.display_name,
					"level": member.level,
					"changes": changes,
				})
	return level_ups
```

`LevelManager.add_xp()` returns an array of dictionaries describing each level-up that occurred. If a character gained 500 XP and that was enough for two level-ups, the array has two entries, each with the stat changes for that level.

### Loot Drops

Each enemy has a `loot_table` — an array of `{"item_id": String, "drop_chance": float}` entries. Each entry gets an independent probability roll. An enemy with three loot entries might drop zero, one, two, or all three items.

## DefeatState — Game Over

When all party members are defeated:

```gdscript
# game/systems/battle/states/defeat_state.gd
extends State

var battle_scene: Node = null


func set_battle_scene(scene: Node) -> void:
	battle_scene = scene


func enter() -> void:
	var defeat_bgm := load("res://assets/music/Game Over (For Now).ogg")
	if defeat_bgm:
		AudioManager.play_bgm(defeat_bgm, 0.5)

	var battle_ui: Node = battle_scene.get_node_or_null("BattleUI")
	if battle_ui:
		battle_ui.show_defeat()

	if battle_ui and battle_ui.has_signal("defeat_action_chosen"):
		var action: String = await battle_ui.defeat_action_chosen
		battle_scene.end_battle(false)
		if action == "load":
			# Load last save
			var data := SaveManager.load_save_data(0)
			if not data.is_empty():
				SaveManager.apply_save_data(data, ...)
				GameManager.change_scene(data.get("scene_path", "res://ui/title_screen.tscn"))
			else:
				GameManager.change_scene("res://ui/title_screen.tscn")
		else:
			GameManager.change_scene("res://ui/title_screen.tscn")
	else:
		await get_tree().create_timer(2.0).timeout
		battle_scene.end_battle(false)
```

The defeat screen presents two options:
1. **Load Last Save** — applies the most recent save data and returns to the saved scene.
2. **Return to Title** — goes back to the title screen.

## Persisting State After Battle

Every battle ends with `BattleScene.end_battle()`, which calls `_persist_party_state()`:

```gdscript
func _persist_party_state() -> void:
	var pm: Node = get_node_or_null("/root/PartyManager")
	if not pm:
		return
	for battler in party_battlers:
		if battler.character_id != &"":
			pm.set_hp(battler.character_id, battler.current_hp)
			pm.set_ee(battler.character_id, battler.current_ee)
```

This writes the final HP and EE of every party battler back to PartyManager. If a character was defeated (0 HP), that persists — the player must revive them before the next battle or they will enter that battle already dead.

The persistence cycle is now complete:

```
PartyManager (persistent)
    │ read
    ▼
BattleScene._apply_persistent_state()
    │ copies HP/EE to
    ▼
PartyBattler (battle instance)
    │ takes damage, uses EE, etc.
    ▼
BattleScene._persist_party_state()
    │ writes HP/EE back to
    ▼
PartyManager (updated)
```

## The Complete Battle Math Summary

| Calculation | Formula | Class |
|------------|---------|-------|
| Outgoing damage | `base + stat * 0.5` | BattlerDamage |
| Defense reduction | `damage * (1 - def/200)` | BattlerDamage |
| Critical hit chance | `0.05 + luck * 0.005` | BattlerDamage |
| Critical hit damage | `damage * 1.5` | BattlerDamage |
| Elemental weakness | `damage * 1.5` | BattlerDamage |
| Elemental resistance | `damage * 0.5` | BattlerDamage |
| Turn delay | `100 / speed` | BattlerResonance |
| Resonance: RESONANT | Abilities +20% | BattlerDamage |
| Resonance: OVERLOAD | All x2 (out and in) | BattlerDamage |
| Resonance: HOLLOW | All stats -50% | BattlerDamage |
| Defend | Incoming x0.5 | BattlerDamage |
| XP to level | `100 * level^2` | LevelManager |
| Stat at level | `base + floor(growth * (level-1))` | LevelManager |

## How It Connects

| System | Connection |
|--------|-----------|
| **PartyManager** | HP/EE read before battle, written after battle |
| **InventoryManager** | Items consumed in battle, gold/loot awarded on victory |
| **EquipmentManager** | Stat bonuses applied during battler initialization |
| **AudioManager** | Hit sounds, magic sounds, victory fanfare, defeat music |
| **LevelManager** | XP awards and level-up stat calculations |
| **SaveManager** | Defeat state can load a save to recover |

## Common Mistakes

**Putting resonance checks inside BattlerDamage.** The static damage class takes resonance_state as a parameter — it does not read it from a Battler. This keeps the function pure and testable. The Battler calls the static function and passes its own state.

**Forgetting minimum 1 damage.** Without `maxi(..., 1)`, a high-defense target could take 0 damage from every attack, making them invincible. Always floor at 1.

**Applying DoT damage after checking for battle end.** Status effect ticks happen in TurnEnd *before* returning to TurnQueueState. TurnQueueState then checks `battle_scene.check_battle_end()`. If you checked battle end before ticking, a poison tick that kills the last enemy would not be detected until the next turn.

**Not clearing `current_action` after execution.** ActionExecuteState sets `battle_scene.current_action = null` after executing. If you forget this, the next turn might re-execute the same action.

**Stacking status effects.** The current design refreshes duration on re-application instead of stacking. If you want stackable effects (e.g., poison that stacks to deal more damage per tick), you would need to change the `apply()` logic to allow multiple entries with the same id. This is a deliberate simplification — stacking effects are much harder to balance.

## What Is Next

The battle system is complete: state machine, commands, targeting, AI, damage math, resonance, status effects, victory, and defeat. The next chapters move to the systems that support the broader game: inventory and equipment (Chapter 13), quests (Chapter 14), save/load (Chapter 15), and events and cutscenes (Chapter 16).

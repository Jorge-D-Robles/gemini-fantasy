class_name Battler
extends Node2D

## Base class for all combatants in battle. Holds stats, status effects,
## and the Resonance gauge. Extended by PartyBattler and EnemyBattler.

## Emitted when HP changes. Provides current and maximum values.
signal hp_changed(new_hp: int, max_hp: int)
## Emitted when Echo Energy changes. Provides current and maximum values.
signal ee_changed(new_ee: int, max_ee: int)
## Emitted when this battler's HP reaches zero.
signal defeated
## Emitted when the resonance gauge value changes.
signal resonance_changed(new_value: float)
## Emitted when the resonance state transitions between phases.
signal resonance_state_changed(old_state: ResonanceState, new_state: ResonanceState)
## Emitted when a status effect is added to this battler.
signal status_effect_applied(effect: StringName)
## Emitted when a status effect is removed from this battler.
signal status_effect_removed(effect: StringName)
## Emitted when this battler finishes executing an action.
signal action_finished
## Emitted when this battler receives damage after defense calculation.
signal damage_taken(amount: int)

enum ResonanceState {
	FOCUSED,
	RESONANT,
	OVERLOAD,
	HOLLOW,
}

const RESONANCE_MAX: float = 150.0
const RESONANCE_RESONANT_THRESHOLD: float = 75.0
const RESONANCE_OVERLOAD_THRESHOLD: float = 100.0
const RESONANCE_GAIN_DAMAGE_TAKEN: float = 1.0
const RESONANCE_GAIN_DAMAGE_DEALT: float = 0.6
const RESONANCE_GAIN_DEFENDING: float = 1.5
const RESONANCE_GAIN_SCALING: float = 0.1
const DEFEND_RESONANCE_BASE: float = 10.0

# Damage formula constants
const DEFENSE_SCALING_DIVISOR: float = 200.0
const DEFENSE_MOD_MIN: float = 0.1
const HOLLOW_DEFENSE_PENALTY: float = 0.5
const DEFEND_DAMAGE_REDUCTION: float = 0.5
const OVERLOAD_INCOMING_DAMAGE_MULT: float = 2.0
const OVERLOAD_OUTGOING_DAMAGE_MULT: float = 2.0
const STAT_DAMAGE_SCALING: float = 0.5

## Character or enemy data resource.
@export var data: BattlerData

var current_hp: int = 0
var max_hp: int = 0
var current_ee: int = 0
var max_ee: int = 0
var attack: int = 0
var magic: int = 0
var defense: int = 0
var resistance: int = 0
var speed: int = 0
var luck: int = 0

var resonance_gauge: float = 0.0
var resonance_state: ResonanceState = ResonanceState.FOCUSED
var status_effects: Array[StringName] = []
var abilities: Array[Resource] = []
var is_defending: bool = false
var is_alive: bool = true

## Turn delay used by TurnQueue. Lower = acts sooner.
var turn_delay: float = 0.0


## Loads stats from [member data] and resets HP, EE, resonance to full.
func initialize_from_data() -> void:
	if not data:
		push_error("Battler: no data resource assigned.")
		return
	_load_stats_from_data()
	current_hp = max_hp
	current_ee = max_ee
	resonance_gauge = 0.0
	resonance_state = ResonanceState.FOCUSED
	is_alive = true
	is_defending = false
	_calculate_turn_delay()


## Applies damage after defense calculation. Returns actual damage dealt.
func take_damage(amount: int, is_magical: bool = false) -> int:
	if not is_alive:
		return 0
	var final_damage := _calculate_incoming_damage(amount, is_magical)
	current_hp = maxi(current_hp - final_damage, 0)
	hp_changed.emit(current_hp, max_hp)
	damage_taken.emit(final_damage)

	if resonance_state != ResonanceState.HOLLOW:
		add_resonance(
			final_damage * RESONANCE_GAIN_DAMAGE_TAKEN * RESONANCE_GAIN_SCALING
		)

	if current_hp <= 0:
		_on_defeated()

	return final_damage


## Restores HP up to max. Returns actual amount healed.
func heal(amount: int) -> int:
	if not is_alive:
		return 0
	var old_hp := current_hp
	current_hp = mini(current_hp + amount, max_hp)
	var healed := current_hp - old_hp
	hp_changed.emit(current_hp, max_hp)
	return healed


## Spends Echo Energy. Returns false if insufficient EE.
func use_ee(cost: int) -> bool:
	if current_ee < cost:
		return false
	current_ee -= cost
	ee_changed.emit(current_ee, max_ee)
	return true


## Restores Echo Energy up to max. Returns actual amount restored.
func restore_ee(amount: int) -> int:
	var old_ee := current_ee
	current_ee = mini(current_ee + amount, max_ee)
	var restored := current_ee - old_ee
	ee_changed.emit(current_ee, max_ee)
	return restored


## Calculates outgoing damage with stat bonus and resonance modifiers.
func deal_damage(base_amount: int, is_magical: bool = false) -> int:
	var stat_bonus: float
	if is_magical:
		stat_bonus = magic * STAT_DAMAGE_SCALING
	else:
		stat_bonus = attack * STAT_DAMAGE_SCALING
	var total := int(base_amount + stat_bonus)

	if resonance_state == ResonanceState.OVERLOAD:
		total = int(total * OVERLOAD_OUTGOING_DAMAGE_MULT)

	if resonance_state != ResonanceState.HOLLOW:
		add_resonance(
			total * RESONANCE_GAIN_DAMAGE_DEALT * RESONANCE_GAIN_SCALING
		)

	return total


## Enters defend stance, halving incoming damage and gaining resonance.
func defend() -> void:
	is_defending = true
	if resonance_state != ResonanceState.HOLLOW:
		add_resonance(DEFEND_RESONANCE_BASE * RESONANCE_GAIN_DEFENDING)


## Clears defend stance and recalculates turn delay for the next round.
func end_turn() -> void:
	is_defending = false
	_calculate_turn_delay()


## Adds to the resonance gauge and updates state. Ignored in HOLLOW state.
func add_resonance(amount: float) -> void:
	if resonance_state == ResonanceState.HOLLOW:
		return
	resonance_gauge = clampf(resonance_gauge + amount, 0.0, RESONANCE_MAX)
	resonance_changed.emit(resonance_gauge)
	_update_resonance_state()


## Returns the current resonance state.
func check_resonance_state() -> ResonanceState:
	return resonance_state


## Applies a status effect if not already present.
func apply_status_effect(effect: StringName) -> void:
	if effect not in status_effects:
		status_effects.append(effect)
		status_effect_applied.emit(effect)


## Removes a status effect by name.
func remove_status_effect(effect: StringName) -> void:
	var idx: int = status_effects.find(effect)
	if idx >= 0:
		status_effects.remove_at(idx)
		status_effect_removed.emit(effect)


## Returns true if this battler has the given status effect.
func has_status_effect(effect: StringName) -> bool:
	return effect in status_effects


## Revives a defeated battler with a percentage of max HP.
func revive(hp_percent: float = 0.25) -> void:
	if is_alive:
		return
	is_alive = true
	current_hp = maxi(int(max_hp * hp_percent), 1)
	hp_changed.emit(current_hp, max_hp)


## Returns the display name from data, or the node name as fallback.
func get_display_name() -> String:
	if data:
		return data.display_name
	return name


func _calculate_incoming_damage(base: int, is_magical: bool) -> int:
	var def_stat: int
	if is_magical:
		def_stat = resistance
	else:
		def_stat = defense

	if resonance_state == ResonanceState.HOLLOW:
		def_stat = int(def_stat * HOLLOW_DEFENSE_PENALTY)

	var defense_mod := 1.0 - (def_stat / DEFENSE_SCALING_DIVISOR)
	defense_mod = clampf(defense_mod, DEFENSE_MOD_MIN, 1.0)

	if is_defending:
		defense_mod *= DEFEND_DAMAGE_REDUCTION

	if resonance_state == ResonanceState.OVERLOAD:
		defense_mod *= OVERLOAD_INCOMING_DAMAGE_MULT

	return maxi(int(base * defense_mod), 1)


func _update_resonance_state() -> void:
	if resonance_state == ResonanceState.HOLLOW:
		return

	var old_state := resonance_state
	if resonance_gauge >= RESONANCE_OVERLOAD_THRESHOLD:
		resonance_state = ResonanceState.OVERLOAD
	elif resonance_gauge >= RESONANCE_RESONANT_THRESHOLD:
		resonance_state = ResonanceState.RESONANT
	else:
		resonance_state = ResonanceState.FOCUSED

	if old_state != resonance_state:
		resonance_state_changed.emit(old_state, resonance_state)


func _on_defeated() -> void:
	is_alive = false
	if resonance_state == ResonanceState.OVERLOAD:
		var old_state := resonance_state
		resonance_state = ResonanceState.HOLLOW
		resonance_gauge = 0.0
		resonance_changed.emit(resonance_gauge)
		resonance_state_changed.emit(old_state, resonance_state)
	defeated.emit()


func _calculate_turn_delay() -> void:
	if speed > 0:
		turn_delay = 100.0 / float(speed)
	else:
		turn_delay = 100.0


func _load_stats_from_data() -> void:
	if not data:
		return
	max_hp = data.max_hp
	max_ee = data.max_ee
	attack = data.attack
	magic = data.magic
	defense = data.defense
	resistance = data.resistance
	speed = data.speed
	luck = data.luck
	abilities = data.abilities

class_name Battler
extends Node2D

## Base class for all combatants in battle. Holds stats, status effects,
## and the Resonance gauge. Extended by PartyBattler and EnemyBattler.

signal hp_changed(new_hp: int, max_hp: int)
signal ee_changed(new_ee: int, max_ee: int)
signal defeated
signal resonance_changed(new_value: float)
signal resonance_state_changed(old_state: ResonanceState, new_state: ResonanceState)
signal status_effect_applied(effect: StringName)
signal status_effect_removed(effect: StringName)
signal action_finished
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

## Character or enemy data resource.
@export var data: Resource

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


func take_damage(amount: int, is_magical: bool = false) -> int:
	if not is_alive:
		return 0
	var final_damage := _calculate_incoming_damage(amount, is_magical)
	current_hp = maxi(current_hp - final_damage, 0)
	hp_changed.emit(current_hp, max_hp)
	damage_taken.emit(final_damage)

	if resonance_state != ResonanceState.HOLLOW:
		add_resonance(final_damage * RESONANCE_GAIN_DAMAGE_TAKEN * 0.1)

	if current_hp <= 0:
		_on_defeated()

	return final_damage


func heal(amount: int) -> int:
	if not is_alive:
		return 0
	var old_hp := current_hp
	current_hp = mini(current_hp + amount, max_hp)
	var healed := current_hp - old_hp
	hp_changed.emit(current_hp, max_hp)
	return healed


func use_ee(cost: int) -> bool:
	if current_ee < cost:
		return false
	current_ee -= cost
	ee_changed.emit(current_ee, max_ee)
	return true


func restore_ee(amount: int) -> int:
	var old_ee := current_ee
	current_ee = mini(current_ee + amount, max_ee)
	var restored := current_ee - old_ee
	ee_changed.emit(current_ee, max_ee)
	return restored


func deal_damage(base_amount: int, is_magical: bool = false) -> int:
	var stat_bonus: float
	if is_magical:
		stat_bonus = magic * 0.5
	else:
		stat_bonus = attack * 0.5
	var total := int(base_amount + stat_bonus)

	if resonance_state == ResonanceState.OVERLOAD:
		total *= 2

	if resonance_state != ResonanceState.HOLLOW:
		add_resonance(total * RESONANCE_GAIN_DAMAGE_DEALT * 0.1)

	return total


func defend() -> void:
	is_defending = true
	if resonance_state != ResonanceState.HOLLOW:
		add_resonance(10.0 * RESONANCE_GAIN_DEFENDING)


func end_turn() -> void:
	is_defending = false
	_calculate_turn_delay()


func add_resonance(amount: float) -> void:
	if resonance_state == ResonanceState.HOLLOW:
		return
	resonance_gauge = clampf(resonance_gauge + amount, 0.0, RESONANCE_MAX)
	resonance_changed.emit(resonance_gauge)
	_update_resonance_state()


func check_resonance_state() -> ResonanceState:
	return resonance_state


func apply_status_effect(effect: StringName) -> void:
	if effect not in status_effects:
		status_effects.append(effect)
		status_effect_applied.emit(effect)


func remove_status_effect(effect: StringName) -> void:
	var idx := status_effects.find(effect)
	if idx >= 0:
		status_effects.remove_at(idx)
		status_effect_removed.emit(effect)


func has_status_effect(effect: StringName) -> bool:
	return effect in status_effects


func revive(hp_percent: float = 0.25) -> void:
	if is_alive:
		return
	is_alive = true
	current_hp = maxi(int(max_hp * hp_percent), 1)
	hp_changed.emit(current_hp, max_hp)


func get_display_name() -> String:
	if data and "display_name" in data:
		return data.display_name
	return name


func _calculate_incoming_damage(base: int, is_magical: bool) -> int:
	var def_stat: int
	if is_magical:
		def_stat = resistance
	else:
		def_stat = defense

	if resonance_state == ResonanceState.HOLLOW:
		def_stat = int(def_stat * 0.5)

	var defense_mod := 1.0 - (def_stat / 200.0)
	defense_mod = clampf(defense_mod, 0.1, 1.0)

	if is_defending:
		defense_mod *= 0.5

	if resonance_state == ResonanceState.OVERLOAD:
		defense_mod *= 2.0

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
	if "max_hp" in data:
		max_hp = data.max_hp
	if "max_ee" in data:
		max_ee = data.max_ee
	if "attack" in data:
		attack = data.attack
	if "magic" in data:
		magic = data.magic
	if "defense" in data:
		defense = data.defense
	if "resistance" in data:
		resistance = data.resistance
	if "speed" in data:
		speed = data.speed
	if "luck" in data:
		luck = data.luck
	if "abilities" in data:
		abilities = data.abilities

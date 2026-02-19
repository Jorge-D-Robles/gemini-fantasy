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

const GB = preload("res://systems/game_balance.gd")

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
var abilities: Array[Resource] = []
var is_defending: bool = false
var is_alive: bool = true

## Turn delay used by TurnQueue. Lower = acts sooner.
var turn_delay: float = 0.0

## Active status effects: Array of { "data": StatusEffectData, "remaining": int }
var _active_effects: Array[Dictionary] = []


## Loads stats from [member data] and resets HP, EE, resonance to full.
## Pass an equipment manager to apply equipment stat bonuses.
func initialize_from_data(equip_manager: Node = null) -> void:
	if not data:
		push_error("Battler: no data resource assigned.")
		return
	_load_stats_from_data()
	_apply_equipment_bonuses(equip_manager)
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
			final_damage * GB.RESONANCE_GAIN_DAMAGE_TAKEN * GB.RESONANCE_GAIN_SCALING
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
## Set [param is_ability] to true for Resonance ability attacks (gets
## Resonant state bonus).
func deal_damage(
	base_amount: int,
	is_magical: bool = false,
	is_ability: bool = false,
) -> int:
	var stat_value: int
	if is_magical:
		stat_value = magic
	else:
		stat_value = attack

	if resonance_state == ResonanceState.HOLLOW:
		stat_value = int(stat_value * GB.HOLLOW_STAT_PENALTY)

	var stat_bonus := stat_value * GB.STAT_DAMAGE_SCALING
	var total := int(base_amount + stat_bonus)

	if resonance_state == ResonanceState.OVERLOAD:
		total = int(total * GB.OVERLOAD_OUTGOING_DAMAGE_MULT)
	elif resonance_state == ResonanceState.RESONANT and is_ability:
		total = int(total * GB.RESONANT_ABILITY_BONUS)

	if resonance_state != ResonanceState.HOLLOW:
		add_resonance(
			total * GB.RESONANCE_GAIN_DAMAGE_DEALT * GB.RESONANCE_GAIN_SCALING
		)

	return total


## Enters defend stance, halving incoming damage and gaining resonance.
func defend() -> void:
	is_defending = true
	if resonance_state != ResonanceState.HOLLOW:
		add_resonance(GB.DEFEND_RESONANCE_BASE * GB.RESONANCE_GAIN_DEFENDING)


## Clears defend stance and recalculates turn delay for the next round.
func end_turn() -> void:
	is_defending = false
	_calculate_turn_delay()


## Adds to the resonance gauge and updates state. Ignored in HOLLOW state.
func add_resonance(amount: float) -> void:
	if resonance_state == ResonanceState.HOLLOW:
		return
	resonance_gauge = clampf(resonance_gauge + amount, 0.0, GB.RESONANCE_MAX)
	resonance_changed.emit(resonance_gauge)
	_update_resonance_state()


## Returns the current resonance state.
func check_resonance_state() -> ResonanceState:
	return resonance_state


## Cures the HOLLOW state, resetting to FOCUSED with gauge at 0.
## No-op if not in HOLLOW state.
func cure_hollow() -> void:
	if resonance_state != ResonanceState.HOLLOW:
		return
	var old_state := resonance_state
	resonance_state = ResonanceState.FOCUSED
	resonance_gauge = 0.0
	resonance_changed.emit(resonance_gauge)
	resonance_state_changed.emit(old_state, resonance_state)
	_calculate_turn_delay()


## Applies a status effect from data. If already present, refreshes duration.
func apply_status(effect_data: StatusEffectData) -> void:
	if effect_data == null:
		return
	# Check if already present — refresh duration instead of stacking
	for entry: Dictionary in _active_effects:
		var existing: StatusEffectData = entry["data"]
		if existing.id == effect_data.id:
			entry["remaining"] = effect_data.duration
			return
	_active_effects.append({
		"data": effect_data,
		"remaining": effect_data.duration,
	})
	status_effect_applied.emit(effect_data.id)


## Legacy wrapper — applies a basic debuff with the given name.
func apply_status_effect(effect: StringName) -> void:
	var data_obj := StatusEffectData.new()
	data_obj.id = effect
	data_obj.display_name = String(effect)
	data_obj.duration = 0  # permanent until removed
	apply_status(data_obj)


## Removes a status effect by id.
func remove_status(effect_id: StringName) -> void:
	for i in range(_active_effects.size() - 1, -1, -1):
		var entry: Dictionary = _active_effects[i]
		var eff: StatusEffectData = entry["data"]
		if eff.id == effect_id:
			_active_effects.remove_at(i)
			status_effect_removed.emit(effect_id)
			return


## Legacy wrapper — removes a status effect by name.
func remove_status_effect(effect: StringName) -> void:
	remove_status(effect)


## Returns true if this battler has an active status effect with the given id.
func has_status(effect_id: StringName) -> bool:
	for entry: Dictionary in _active_effects:
		var eff: StatusEffectData = entry["data"]
		if eff.id == effect_id:
			return true
	return false


## Legacy wrapper.
func has_status_effect(effect: StringName) -> bool:
	return has_status(effect)


## Returns remaining turns for an effect, or -1 if not found.
func get_effect_remaining_turns(effect_id: StringName) -> int:
	for entry: Dictionary in _active_effects:
		var eff: StatusEffectData = entry["data"]
		if eff.id == effect_id:
			return entry["remaining"] as int
	return -1


## Returns the number of active status effects.
func get_active_effect_count() -> int:
	return _active_effects.size()


## Returns true if any active effect prevents acting.
func is_action_prevented() -> bool:
	for entry: Dictionary in _active_effects:
		var eff: StatusEffectData = entry["data"]
		if eff.prevents_action:
			return true
	return false


## Returns base stat + modifiers, with Hollow penalty applied, floored at 0.
func get_modified_stat(stat_name: String) -> int:
	var base: int = 0
	match stat_name:
		"attack":
			base = attack
		"magic":
			base = magic
		"defense":
			base = defense
		"resistance":
			base = resistance
		"speed":
			base = speed
		"luck":
			base = luck
		_:
			push_warning("Unknown stat: %s" % stat_name)
			return 0
	if resonance_state == ResonanceState.HOLLOW:
		base = int(base * GB.HOLLOW_STAT_PENALTY)
	var modifier := _get_total_modifier(stat_name)
	return maxi(base + modifier, 0)


## Removes all active status effects.
func clear_all_effects() -> void:
	_active_effects.clear()


## Ticks all active effects: applies DoT/HoT, decrements duration, expires.
func tick_effects() -> void:
	if not is_alive:
		return
	# Process ticks and collect expired indices
	var expired: Array[int] = []
	for i in _active_effects.size():
		var entry: Dictionary = _active_effects[i]
		var eff: StatusEffectData = entry["data"]
		# Apply tick damage
		if eff.tick_damage > 0:
			var dmg := eff.tick_damage
			# DoT cannot kill — leave at least 1 HP
			current_hp = maxi(current_hp - dmg, 1)
			hp_changed.emit(current_hp, max_hp)
		# Apply tick healing
		if eff.tick_heal > 0:
			current_hp = mini(current_hp + eff.tick_heal, max_hp)
			hp_changed.emit(current_hp, max_hp)
		# Decrement duration (0 = permanent)
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


## Revives a defeated battler with a percentage of max HP.
func revive(hp_percent: float = GB.REVIVE_HP_PERCENT) -> void:
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
		def_stat = int(def_stat * GB.HOLLOW_STAT_PENALTY)

	var defense_mod := 1.0 - (def_stat / GB.DEFENSE_SCALING_DIVISOR)
	defense_mod = clampf(defense_mod, GB.DEFENSE_MOD_MIN, 1.0)

	if is_defending:
		defense_mod *= GB.DEFEND_DAMAGE_REDUCTION

	if resonance_state == ResonanceState.OVERLOAD:
		defense_mod *= GB.OVERLOAD_INCOMING_DAMAGE_MULT

	return maxi(int(base * defense_mod), 1)


func _update_resonance_state() -> void:
	if resonance_state == ResonanceState.HOLLOW:
		return

	var old_state := resonance_state
	if resonance_gauge >= GB.RESONANCE_OVERLOAD_THRESHOLD:
		resonance_state = ResonanceState.OVERLOAD
	elif resonance_gauge >= GB.RESONANCE_RESONANT_THRESHOLD:
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
		_calculate_turn_delay()
	defeated.emit()


func _get_total_modifier(stat_name: String) -> int:
	var total: int = 0
	for entry: Dictionary in _active_effects:
		var eff: StatusEffectData = entry["data"]
		match stat_name:
			"attack":
				total += eff.attack_modifier
			"magic":
				total += eff.magic_modifier
			"defense":
				total += eff.defense_modifier
			"resistance":
				total += eff.resistance_modifier
			"speed":
				total += eff.speed_modifier
			"luck":
				total += eff.luck_modifier
	return total


func _calculate_turn_delay() -> void:
	var effective_speed := speed
	if resonance_state == ResonanceState.HOLLOW:
		effective_speed = int(speed * GB.HOLLOW_STAT_PENALTY)
	if effective_speed > 0:
		turn_delay = GB.TURN_DELAY_BASE / float(effective_speed)
	else:
		turn_delay = GB.TURN_DELAY_BASE


func _apply_equipment_bonuses(equip_manager: Node) -> void:
	if equip_manager == null:
		return
	if not (data is CharacterData):
		return
	var char_data := data as CharacterData
	if char_data.id == &"":
		return
	var bonuses: Dictionary = equip_manager.get_stat_bonuses(
		char_data.id
	)
	max_hp += bonuses.get("max_hp", 0)
	max_ee += bonuses.get("max_ee", 0)
	attack += bonuses.get("attack", 0)
	magic += bonuses.get("magic", 0)
	defense += bonuses.get("defense", 0)
	resistance += bonuses.get("resistance", 0)
	speed += bonuses.get("speed", 0)
	luck += bonuses.get("luck", 0)


func _load_stats_from_data() -> void:
	if not data:
		return
	if data is CharacterData:
		var char_data := data as CharacterData
		max_hp = LevelManager.get_stat_at_level(
			char_data.max_hp, char_data.hp_growth, char_data.level
		)
		max_ee = LevelManager.get_stat_at_level(
			char_data.max_ee, char_data.ee_growth, char_data.level
		)
		attack = LevelManager.get_stat_at_level(
			char_data.attack, char_data.attack_growth, char_data.level
		)
		magic = LevelManager.get_stat_at_level(
			char_data.magic, char_data.magic_growth, char_data.level
		)
		defense = LevelManager.get_stat_at_level(
			char_data.defense, char_data.defense_growth, char_data.level
		)
		resistance = LevelManager.get_stat_at_level(
			char_data.resistance,
			char_data.resistance_growth,
			char_data.level,
		)
		speed = LevelManager.get_stat_at_level(
			char_data.speed, char_data.speed_growth, char_data.level
		)
		luck = LevelManager.get_stat_at_level(
			char_data.luck, char_data.luck_growth, char_data.level
		)
	else:
		max_hp = data.max_hp
		max_ee = data.max_ee
		attack = data.attack
		magic = data.magic
		defense = data.defense
		resistance = data.resistance
		speed = data.speed
		luck = data.luck
	abilities = data.abilities

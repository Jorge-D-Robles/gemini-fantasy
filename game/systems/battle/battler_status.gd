class_name BattlerStatus
extends RefCounted

## Static status effect query and mutation utilities extracted from Battler.
## Operates on an Array[Dictionary] where each entry is:
##   {"data": StatusEffectData, "remaining": int}


## Adds a new effect or refreshes duration if already present.
## Returns effect id if NEW (caller should emit signal), empty StringName if refresh.
static func apply(
	effects: Array[Dictionary],
	effect_data: StatusEffectData,
) -> StringName:
	for entry: Dictionary in effects:
		var existing: StatusEffectData = entry["data"]
		if existing.id == effect_data.id:
			entry["remaining"] = effect_data.duration
			return &""
	effects.append({
		"data": effect_data,
		"remaining": effect_data.duration,
	})
	return effect_data.id


## Removes an effect by id. Returns true if found and removed.
static func remove(
	effects: Array[Dictionary], effect_id: StringName,
) -> bool:
	for i in range(effects.size() - 1, -1, -1):
		var entry: Dictionary = effects[i]
		var eff: StatusEffectData = entry["data"]
		if eff.id == effect_id:
			effects.remove_at(i)
			return true
	return false


## Returns true if an effect with the given id is active.
static func has(
	effects: Array[Dictionary], effect_id: StringName,
) -> bool:
	for entry: Dictionary in effects:
		var eff: StatusEffectData = entry["data"]
		if eff.id == effect_id:
			return true
	return false


## Returns remaining turns for an effect, or -1 if not found.
static func get_remaining_turns(
	effects: Array[Dictionary], effect_id: StringName,
) -> int:
	for entry: Dictionary in effects:
		var eff: StatusEffectData = entry["data"]
		if eff.id == effect_id:
			return entry["remaining"] as int
	return -1


## Returns true if any active effect prevents acting.
static func is_action_prevented(effects: Array[Dictionary]) -> bool:
	for entry: Dictionary in effects:
		var eff: StatusEffectData = entry["data"]
		if eff.prevents_action:
			return true
	return false


## Returns the sum of all active modifiers for a given stat.
static func get_total_modifier(
	effects: Array[Dictionary], stat_name: String,
) -> int:
	var total: int = 0
	for entry: Dictionary in effects:
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

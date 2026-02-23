extends Node

## NOTE: No class_name — autoloads are already global singletons.
## Tracks faction reputation for the three major factions.
## Reputation values range from -100 (hostile) to 100 (allied).

signal reputation_changed(
	faction_id: StringName, old_value: int, new_value: int,
)

enum Tier {
	HOSTILE,
	UNFRIENDLY,
	NEUTRAL,
	FRIENDLY,
	ALLIED,
}

const SHEPHERDS: StringName = &"shepherds"
const INITIATIVE: StringName = &"initiative"
const FREE_RESONANTS: StringName = &"free_resonants"
const ALL_FACTIONS: Array[StringName] = [
	SHEPHERDS, INITIATIVE, FREE_RESONANTS,
]
const REP_MIN: int = -100
const REP_MAX: int = 100

var _reputations: Dictionary = {
	SHEPHERDS: 0,
	INITIATIVE: 0,
	FREE_RESONANTS: 0,
}


func add_reputation(faction_id: StringName, amount: int) -> void:
	if not _is_valid_faction(faction_id):
		push_warning(
			"ReputationManager: unknown faction '%s'" % faction_id
		)
		return
	if amount == 0:
		return
	var old: int = _reputations[faction_id]
	_reputations[faction_id] = clampi(old + amount, REP_MIN, REP_MAX)
	var new_val: int = _reputations[faction_id]
	if old != new_val:
		reputation_changed.emit(faction_id, old, new_val)


func get_reputation(faction_id: StringName) -> int:
	return _reputations.get(faction_id, 0)


func set_reputation(faction_id: StringName, value: int) -> void:
	if not _is_valid_faction(faction_id):
		push_warning(
			"ReputationManager: unknown faction '%s'" % faction_id
		)
		return
	var old: int = _reputations[faction_id]
	_reputations[faction_id] = clampi(value, REP_MIN, REP_MAX)
	var new_val: int = _reputations[faction_id]
	if old != new_val:
		reputation_changed.emit(faction_id, old, new_val)


func get_tier(faction_id: StringName) -> Tier:
	return compute_tier(get_reputation(faction_id))


func get_price_modifier(faction_id: StringName) -> float:
	return compute_price_modifier(get_tier(faction_id))


func has_tier(faction_id: StringName, min_tier: Tier) -> bool:
	return get_tier(faction_id) >= min_tier


func get_all_reputations() -> Dictionary:
	return _reputations.duplicate()


func reset_all() -> void:
	for faction_id: StringName in ALL_FACTIONS:
		var old: int = _reputations[faction_id]
		if old != 0:
			_reputations[faction_id] = 0
			reputation_changed.emit(faction_id, old, 0)


func serialize() -> Dictionary:
	var data := {}
	for faction_id: StringName in ALL_FACTIONS:
		data[String(faction_id)] = _reputations[faction_id]
	return data


func deserialize(data: Dictionary) -> void:
	for faction_id: StringName in ALL_FACTIONS:
		var key := String(faction_id)
		var raw: int = int(data.get(key, 0))
		_reputations[faction_id] = clampi(raw, REP_MIN, REP_MAX)


static func compute_tier(value: int) -> Tier:
	if value <= -50:
		return Tier.HOSTILE
	if value <= -10:
		return Tier.UNFRIENDLY
	if value <= 9:
		return Tier.NEUTRAL
	if value <= 49:
		return Tier.FRIENDLY
	return Tier.ALLIED


static func compute_price_modifier(tier: Tier) -> float:
	match tier:
		Tier.HOSTILE:
			return 1.5
		Tier.UNFRIENDLY:
			return 1.2
		Tier.NEUTRAL:
			return 1.0
		Tier.FRIENDLY:
			return 0.9
		Tier.ALLIED:
			return 0.8
	return 1.0


func _is_valid_faction(faction_id: StringName) -> bool:
	return ALL_FACTIONS.has(faction_id)

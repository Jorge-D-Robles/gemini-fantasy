class_name BondData
extends Resource

## Static-only helper for bond pair IDs, level computation, and combat bonuses.
## No instance fields — all state lives in BondManager autoload.
## Mirrors the Fire Emblem D-C-B-A-S support level system.

enum BondLevel { D, C, B, A, S }

## Points required to reach each level (indexed by BondLevel enum value).
const LEVEL_THRESHOLDS: Array[int] = [0, 10, 25, 50, 80]

## Combat bonuses per level: {damage_bonus: float, defense_bonus: float}.
const LEVEL_BONUSES: Array[Dictionary] = [
	{"damage_bonus": 0.0, "defense_bonus": 0.0},
	{"damage_bonus": 0.05, "defense_bonus": 0.0},
	{"damage_bonus": 0.10, "defense_bonus": 0.05},
	{"damage_bonus": 0.15, "defense_bonus": 0.10},
	{"damage_bonus": 0.20, "defense_bonus": 0.15},
]

const MAX_PARTY_DAMAGE_BONUS: float = 0.40
const MAX_PARTY_DEFENSE_BONUS: float = 0.25


## Returns a canonical pair ID (alphabetical order) for two characters.
static func make_pair_id(a: StringName, b: StringName) -> StringName:
	var sa: String = String(a)
	var sb: String = String(b)
	if sa <= sb:
		return StringName(sa + "+" + sb)
	return StringName(sb + "+" + sa)


## Returns the bond level for the given point total.
## Walks thresholds backward to find the highest level reached.
static func compute_level(points: int) -> BondLevel:
	for i: int in range(LEVEL_THRESHOLDS.size() - 1, -1, -1):
		if points >= LEVEL_THRESHOLDS[i]:
			return i as BondLevel
	return BondLevel.D


## Returns the combat bonus dictionary for a given bond level.
static func compute_combat_bonus(level: BondLevel) -> Dictionary:
	var idx: int = int(level)
	if idx >= 0 and idx < LEVEL_BONUSES.size():
		return LEVEL_BONUSES[idx].duplicate()
	return {"damage_bonus": 0.0, "defense_bonus": 0.0}

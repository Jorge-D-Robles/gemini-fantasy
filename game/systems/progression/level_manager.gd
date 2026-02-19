class_name LevelManager
extends RefCounted

## Static utility class for XP and leveling calculations.
## Not an autoload — use static methods directly: LevelManager.add_xp(...)

const GB = preload("res://systems/game_balance.gd")


## Returns the total XP required to reach the given level.
## Formula: XP_CURVE_BASE * level * level (L2=400, L3=900, L4=1600, etc.)
static func xp_for_level(level: int) -> int:
	return GB.XP_CURVE_BASE * level * level


## Returns XP remaining until the character's next level.
static func xp_to_next_level(character: CharacterData) -> int:
	return xp_for_level(character.level + 1) - character.current_xp


## Returns true if the character has enough XP to level up.
static func can_level_up(character: CharacterData) -> bool:
	return character.current_xp >= xp_for_level(character.level + 1)


## Calculates a stat value at a given level from base and growth rate.
## Formula: base + floor(growth * (level - 1))
static func get_stat_at_level(base: int, growth: float, level: int) -> int:
	return base + int(floor(growth * float(level - 1)))


## Applies one level-up: increments level, returns dict of stat changes.
## Does NOT modify base stats — use get_stat_at_level() for scaled values.
static func level_up(character: CharacterData) -> Dictionary:
	var old_level := character.level
	character.level += 1
	var new_level := character.level

	var changes := {}
	changes["hp"] = (
		get_stat_at_level(character.max_hp, character.hp_growth, new_level)
		- get_stat_at_level(character.max_hp, character.hp_growth, old_level)
	)
	changes["ee"] = (
		get_stat_at_level(character.max_ee, character.ee_growth, new_level)
		- get_stat_at_level(character.max_ee, character.ee_growth, old_level)
	)
	changes["attack"] = (
		get_stat_at_level(character.attack, character.attack_growth, new_level)
		- get_stat_at_level(character.attack, character.attack_growth, old_level)
	)
	changes["magic"] = (
		get_stat_at_level(character.magic, character.magic_growth, new_level)
		- get_stat_at_level(character.magic, character.magic_growth, old_level)
	)
	changes["defense"] = (
		get_stat_at_level(character.defense, character.defense_growth, new_level)
		- get_stat_at_level(character.defense, character.defense_growth, old_level)
	)
	changes["resistance"] = (
		get_stat_at_level(
			character.resistance, character.resistance_growth, new_level
		)
		- get_stat_at_level(
			character.resistance, character.resistance_growth, old_level
		)
	)
	changes["speed"] = (
		get_stat_at_level(character.speed, character.speed_growth, new_level)
		- get_stat_at_level(character.speed, character.speed_growth, old_level)
	)
	changes["luck"] = (
		get_stat_at_level(character.luck, character.luck_growth, new_level)
		- get_stat_at_level(character.luck, character.luck_growth, old_level)
	)

	return changes


## Adds XP and processes all resulting level-ups. Returns array of
## stat change dicts (one per level gained, may be empty).
static func add_xp(
	character: CharacterData, amount: int
) -> Array[Dictionary]:
	character.current_xp += amount
	var level_ups: Array[Dictionary] = []
	while can_level_up(character):
		level_ups.append(level_up(character))
	return level_ups

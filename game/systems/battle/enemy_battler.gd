class_name EnemyBattler
extends Battler

## AI-controlled battler. Selects actions based on AI patterns from EnemyData.

signal ai_action_chosen(action: Dictionary)

enum AIType {
	BASIC,
	AGGRESSIVE,
	DEFENSIVE,
	SUPPORT,
	BOSS,
}

@export var ai_type: AIType = AIType.BASIC

var loot_table: Array[Dictionary] = []
var exp_reward: int = 0
var gold_reward: int = 0


func initialize_from_data() -> void:
	super.initialize_from_data()
	if data:
		if "ai_type" in data:
			ai_type = data.ai_type as AIType
		if "loot_table" in data:
			loot_table = data.loot_table
		if "exp_reward" in data:
			exp_reward = data.exp_reward
		if "gold_reward" in data:
			gold_reward = data.gold_reward


func choose_action(party: Array[Battler], allies: Array[Battler]) -> Dictionary:
	var action: Dictionary = {}
	match ai_type:
		AIType.BASIC:
			action = _basic_ai(party)
		AIType.AGGRESSIVE:
			action = _aggressive_ai(party)
		AIType.DEFENSIVE:
			action = _defensive_ai(party)
		AIType.SUPPORT:
			action = _support_ai(party, allies)
		AIType.BOSS:
			action = _aggressive_ai(party)
	ai_action_chosen.emit(action)
	return action


func _basic_ai(party: Array[Battler]) -> Dictionary:
	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return {"type": "wait"}

	var target: Battler = living_targets[randi() % living_targets.size()]
	return {"type": "attack", "target": target}


func _aggressive_ai(party: Array[Battler]) -> Dictionary:
	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return {"type": "wait"}

	# Pick lowest HP target
	var target: Battler = living_targets[0]
	for t in living_targets:
		if t.current_hp < target.current_hp:
			target = t

	# Use ability if available, else attack
	if not abilities.is_empty() and current_ee > 0:
		for ability in abilities:
			if _can_use_ability_enemy(ability):
				return {
					"type": "ability",
					"ability": ability,
					"target": target,
				}

	return {"type": "attack", "target": target}


func _defensive_ai(party: Array[Battler]) -> Dictionary:
	# Defend if HP low
	if current_hp < max_hp * 0.3:
		return {"type": "defend"}

	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return {"type": "wait"}

	var target: Battler = living_targets[randi() % living_targets.size()]
	return {"type": "attack", "target": target}


func _support_ai(
	party: Array[Battler],
	allies: Array[Battler],
) -> Dictionary:
	# Heal injured ally if possible
	var injured: Array = _get_living(allies).filter(
		func(b: Battler) -> bool: return b.current_hp < b.max_hp * 0.5
	)
	if not injured.is_empty() and not abilities.is_empty():
		for ability in abilities:
			if not _can_use_ability_enemy(ability):
				continue
			if "status_effect" in ability and ability.status_effect == "cure_all":
				return {
					"type": "ability",
					"ability": ability,
					"target": injured[0],
				}

	# Otherwise attack
	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return {"type": "wait"}
	var target: Battler = living_targets[randi() % living_targets.size()]
	return {"type": "attack", "target": target}


func _get_living(battlers: Array[Battler]) -> Array[Battler]:
	var living: Array[Battler] = []
	for b in battlers:
		if b.is_alive:
			living.append(b)
	return living


func _can_use_ability_enemy(ability: Resource) -> bool:
	if "ee_cost" in ability and current_ee < ability.ee_cost:
		return false
	return true

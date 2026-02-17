class_name EnemyBattler
extends Battler

## AI-controlled battler. Selects actions based on AI patterns from EnemyData.

signal ai_action_chosen(action: BattleAction)

@export var ai_type: EnemyData.AiType = EnemyData.AiType.BASIC

var loot_table: Array[Dictionary] = []
var exp_reward: int = 0
var gold_reward: int = 0


func initialize_from_data(equip_manager: Node = null) -> void:
	super.initialize_from_data(equip_manager)
	var enemy_data := data as EnemyData
	if enemy_data:
		ai_type = enemy_data.ai_type
		loot_table = enemy_data.loot_table
		exp_reward = enemy_data.exp_reward
		gold_reward = enemy_data.gold_reward


func choose_action(
	party: Array[Battler],
	allies: Array[Battler],
) -> BattleAction:
	var action: BattleAction
	match ai_type:
		EnemyData.AiType.BASIC:
			action = _basic_ai(party)
		EnemyData.AiType.AGGRESSIVE:
			action = _aggressive_ai(party)
		EnemyData.AiType.DEFENSIVE:
			action = _defensive_ai(party)
		EnemyData.AiType.SUPPORT:
			action = _support_ai(party, allies)
		EnemyData.AiType.BOSS:
			action = _aggressive_ai(party)
		_:
			action = BattleAction.create_wait()
	ai_action_chosen.emit(action)
	return action


func _basic_ai(party: Array[Battler]) -> BattleAction:
	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return BattleAction.create_wait()

	var target: Battler = living_targets[randi() % living_targets.size()]
	return BattleAction.create_attack(target)


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


func _defensive_ai(party: Array[Battler]) -> BattleAction:
	# Defend if HP low
	if current_hp < max_hp * 0.3:
		return BattleAction.create_defend()

	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return BattleAction.create_wait()

	var target: Battler = living_targets[randi() % living_targets.size()]
	return BattleAction.create_attack(target)


func _support_ai(
	party: Array[Battler],
	allies: Array[Battler],
) -> BattleAction:
	# Heal injured ally if possible
	var injured: Array = _get_living(allies).filter(
		func(b: Battler) -> bool: return b.current_hp < b.max_hp * 0.5
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

	# Otherwise attack
	var living_targets := _get_living(party)
	if living_targets.is_empty():
		return BattleAction.create_wait()
	var target: Battler = living_targets[randi() % living_targets.size()]
	return BattleAction.create_attack(target)


func _get_living(battlers: Array[Battler]) -> Array[Battler]:
	var living: Array[Battler] = []
	for b in battlers:
		if b.is_alive:
			living.append(b)
	return living


func _can_use_ability_enemy(ability: AbilityData) -> bool:
	if current_ee < ability.ee_cost:
		return false
	if ability.resonance_cost > 0.0 and resonance_gauge < ability.resonance_cost:
		return false
	return true

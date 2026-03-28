class_name AIController
extends RefCounted
## Enemy AI decision-making. Static methods, no instance needed.


static func choose_enemy_action(
	battler: BattlerData,
	enemy_data: EnemyData,
	party: Array[BattlerData],
	_allies: Array[BattlerData],
) -> Dictionary:
	match enemy_data.ai_type:
		EnemyData.AIType.AGGRESSIVE:
			return _ai_aggressive(battler, party)
		EnemyData.AIType.CAUTIOUS:
			return _ai_cautious(battler, party)
		_:
			return _ai_balanced(battler, party)


static func _ai_aggressive(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
	var weakest: BattlerData = targets[0]
	for t in targets:
		if t.current_hp < weakest.current_hp:
			weakest = t
	return {action = "attack", battler = battler, target = weakest}


static func _ai_cautious(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
	var hp_ratio: float = float(battler.current_hp) / float(battler.character_data.max_hp)
	if hp_ratio < 0.3:
		return {action = "defend", battler = battler, target = battler}
	var target: BattlerData = targets[randi() % targets.size()]
	return {action = "attack", battler = battler, target = target}


static func _ai_balanced(battler: BattlerData, targets: Array[BattlerData]) -> Dictionary:
	var target: BattlerData = targets[randi() % targets.size()]
	if randf() < 0.3:
		return {action = "defend", battler = battler, target = battler}
	return {action = "attack", battler = battler, target = target}


static func attempt_flee(party: Array[BattlerData], enemies: Array[BattlerData]) -> bool:
	var party_speed: float = 0.0
	for b in party:
		party_speed += b.current_speed
	party_speed /= party.size()

	var enemy_speed: float = 0.0
	for b in enemies:
		enemy_speed += b.current_speed
	enemy_speed /= enemies.size()

	var chance: float = 0.5 + (party_speed - enemy_speed) * 0.05
	chance = clampf(chance, 0.1, 0.9)
	return randf() < chance

class_name BattleAction
extends RefCounted

## Encapsulates a battle action chosen by a battler.

enum Type {
	ATTACK,
	ABILITY,
	DEFEND,
	WAIT,
}

var type: Type = Type.WAIT
var target: Battler = null
var ability: AbilityData = null


static func create_attack(target: Battler) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ATTACK
	action.target = target
	return action


static func create_ability(
	ability: AbilityData,
	target: Battler,
) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ABILITY
	action.ability = ability
	action.target = target
	return action


static func create_defend() -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.DEFEND
	return action


static func create_wait() -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.WAIT
	return action

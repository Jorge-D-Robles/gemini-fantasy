class_name BattleAction
extends RefCounted

## Encapsulates a battle action chosen by a battler.

enum Type {
	ATTACK,
	ABILITY,
	DEFEND,
	WAIT,
	ITEM,
	ECHO,
}

var type: Type = Type.WAIT
var target: Battler = null
var ability: AbilityData = null
var item: ItemData = null
var echo: EchoData = null


static func create_attack(p_target: Battler) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ATTACK
	action.target = p_target
	return action


static func create_ability(
	p_ability: AbilityData,
	p_target: Battler,
) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ABILITY
	action.ability = p_ability
	action.target = p_target
	return action


static func create_defend() -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.DEFEND
	return action


static func create_item(
	p_item: ItemData,
	p_target: Battler,
) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ITEM
	action.item = p_item
	action.target = p_target
	return action


static func create_echo(
	p_echo: EchoData,
	p_target: Battler,
) -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.ECHO
	action.echo = p_echo
	action.target = p_target
	return action


static func create_wait() -> BattleAction:
	var action := BattleAction.new()
	action.type = Type.WAIT
	return action

extends GutTest

## Tests for BattleAction static factory methods.

const Helpers = preload("res://tests/helpers/test_helpers.gd")

var _target: Battler


func before_each() -> void:
	_target = Helpers.make_battler()
	add_child_autofree(_target)


func test_create_attack() -> void:
	var action := BattleAction.create_attack(_target)
	assert_eq(action.type, BattleAction.Type.ATTACK)
	assert_eq(action.target, _target)
	assert_null(action.ability)
	assert_null(action.item)


func test_create_ability() -> void:
	var ability := Helpers.make_ability()
	var action := BattleAction.create_ability(ability, _target)
	assert_eq(action.type, BattleAction.Type.ABILITY)
	assert_eq(action.ability, ability)
	assert_eq(action.target, _target)


func test_create_defend() -> void:
	var action := BattleAction.create_defend()
	assert_eq(action.type, BattleAction.Type.DEFEND)
	assert_null(action.target)


func test_create_item() -> void:
	var item := Helpers.make_item()
	var action := BattleAction.create_item(item, _target)
	assert_eq(action.type, BattleAction.Type.ITEM)
	assert_eq(action.item, item)
	assert_eq(action.target, _target)


func test_create_wait() -> void:
	var action := BattleAction.create_wait()
	assert_eq(action.type, BattleAction.Type.WAIT)
	assert_null(action.target)
	assert_null(action.ability)
	assert_null(action.item)

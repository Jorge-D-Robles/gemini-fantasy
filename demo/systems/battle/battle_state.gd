extends Node
class_name BattleState
## Base class for all battle states.

var battle_manager: Node


func enter(_context: Dictionary = {}) -> void:
	pass


func process(_delta: float) -> void:
	pass


func exit() -> void:
	pass

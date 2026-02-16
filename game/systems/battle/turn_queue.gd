class_name TurnQueue
extends Node

## Manages turn order based on speed. Lower turn_delay = acts sooner.

signal turn_ready(battler: Battler)
signal turn_order_changed(order: Array[Battler])

var _battlers: Array[Battler] = []
var _turn_order: Array[Battler] = []


func initialize(battlers: Array[Battler]) -> void:
	_battlers = battlers
	_calculate_turn_order()


func advance() -> Battler:
	if _turn_order.is_empty():
		_calculate_turn_order()
	if _turn_order.is_empty():
		return null
	var next: Battler = _turn_order.pop_front()
	turn_ready.emit(next)
	return next


func peek_order(count: int = 5) -> Array[Battler]:
	if _turn_order.is_empty():
		_calculate_turn_order()
	var result: Array[Battler] = []
	var limit := mini(count, _turn_order.size())
	for i in limit:
		result.append(_turn_order[i])
	return result


func remove_battler(battler: Battler) -> void:
	_battlers.erase(battler)
	_turn_order.erase(battler)
	turn_order_changed.emit(_turn_order)


func add_battler(battler: Battler) -> void:
	if battler not in _battlers:
		_battlers.append(battler)
	_calculate_turn_order()


func get_turn_order() -> Array[Battler]:
	return _turn_order.duplicate()


func clear() -> void:
	_battlers.clear()
	_turn_order.clear()


func _calculate_turn_order() -> void:
	_turn_order.clear()
	for b in _battlers:
		if b.is_alive:
			_turn_order.append(b)
	_turn_order.sort_custom(_compare_by_delay)
	turn_order_changed.emit(_turn_order)


func _compare_by_delay(a: Battler, b: Battler) -> bool:
	return a.turn_delay < b.turn_delay

extends GutTest

## Tests for TurnQueue — turn order calculation, advance, remove, add, peek.

const Helpers = preload("res://tests/helpers/test_helpers.gd")

var _queue: TurnQueue


func before_each() -> void:
	_queue = TurnQueue.new()
	add_child_autofree(_queue)


# ---- Initialize ----

func test_initialize_populates_turn_order() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)
	var b := Helpers.make_battler({"speed": 20})
	add_child_autofree(b)

	_queue.initialize([a, b])
	var order := _queue.get_turn_order()
	assert_eq(order.size(), 2, "Should have 2 battlers in order")


func test_initialize_sorts_by_speed_fastest_first() -> void:
	var slow := Helpers.make_battler({"speed": 5})
	add_child_autofree(slow)
	var fast := Helpers.make_battler({"speed": 20})
	add_child_autofree(fast)

	_queue.initialize([slow, fast])
	var order := _queue.get_turn_order()
	assert_eq(order[0], fast, "Fastest battler should be first")
	assert_eq(order[1], slow, "Slowest battler should be second")


func test_initialize_excludes_dead_battlers() -> void:
	var alive := Helpers.make_battler({"speed": 10})
	add_child_autofree(alive)
	var dead := Helpers.make_battler({"speed": 20})
	add_child_autofree(dead)
	dead.is_alive = false

	_queue.initialize([alive, dead])
	var order := _queue.get_turn_order()
	assert_eq(order.size(), 1, "Dead battler should be excluded")
	assert_eq(order[0], alive)


# ---- Advance ----

func test_advance_returns_fastest_battler() -> void:
	var slow := Helpers.make_battler({"speed": 5})
	add_child_autofree(slow)
	var fast := Helpers.make_battler({"speed": 20})
	add_child_autofree(fast)

	_queue.initialize([slow, fast])
	var next := _queue.advance()
	assert_eq(next, fast, "Advance should return the fastest battler")


func test_advance_pops_from_front() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)
	var b := Helpers.make_battler({"speed": 20})
	add_child_autofree(b)

	_queue.initialize([a, b])
	var first := _queue.advance()
	var second := _queue.advance()
	assert_ne(first, second, "Advance should return different battlers")


func test_advance_recalculates_when_exhausted() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)

	_queue.initialize([a])
	var first := _queue.advance()
	assert_eq(first, a)

	# Queue is now empty — advance should recalculate
	var second := _queue.advance()
	assert_eq(second, a, "Should recalculate and return the battler again")


func test_advance_returns_null_when_no_battlers() -> void:
	_queue.initialize([])
	var result := _queue.advance()
	assert_null(result, "Should return null with no battlers")


# ---- Remove ----

func test_remove_battler_removes_from_order() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)
	var b := Helpers.make_battler({"speed": 20})
	add_child_autofree(b)

	_queue.initialize([a, b])
	_queue.remove_battler(b)
	var order := _queue.get_turn_order()
	assert_eq(order.size(), 1)
	assert_eq(order[0], a)


func test_remove_battler_emits_turn_order_changed() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)
	var b := Helpers.make_battler({"speed": 20})
	add_child_autofree(b)

	_queue.initialize([a, b])
	watch_signals(_queue)
	_queue.remove_battler(b)
	assert_signal_emitted(_queue, "turn_order_changed")


# ---- Add ----

func test_add_battler_recalculates_order() -> void:
	var slow := Helpers.make_battler({"speed": 5})
	add_child_autofree(slow)

	_queue.initialize([slow])
	assert_eq(_queue.get_turn_order().size(), 1)

	var fast := Helpers.make_battler({"speed": 20})
	add_child_autofree(fast)
	_queue.add_battler(fast)

	var order := _queue.get_turn_order()
	assert_eq(order.size(), 2)
	assert_eq(order[0], fast, "New faster battler should be first")


func test_add_battler_no_duplicates() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)

	_queue.initialize([a])
	_queue.add_battler(a)
	# _battlers should not have duplicates; order should have 1
	var order := _queue.get_turn_order()
	assert_eq(order.size(), 1)


# ---- Peek ----

func test_peek_order_returns_upcoming() -> void:
	var a := Helpers.make_battler({"speed": 5})
	add_child_autofree(a)
	var b := Helpers.make_battler({"speed": 10})
	add_child_autofree(b)
	var c := Helpers.make_battler({"speed": 20})
	add_child_autofree(c)

	_queue.initialize([a, b, c])
	var peek := _queue.peek_order(2)
	assert_eq(peek.size(), 2, "Should return only 2 entries")
	assert_eq(peek[0], c, "First peeked should be fastest")


func test_peek_order_does_not_consume() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)

	_queue.initialize([a])
	_queue.peek_order(1)
	var order := _queue.get_turn_order()
	assert_eq(order.size(), 1, "Peek should not remove from order")


# ---- Clear ----

func test_clear_empties_all() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)

	_queue.initialize([a])
	_queue.clear()
	assert_eq(_queue.get_turn_order().size(), 0)
	assert_null(_queue.advance(), "Advance after clear should return null")


# ---- Signals ----

func test_turn_ready_signal_on_advance() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)

	_queue.initialize([a])
	watch_signals(_queue)
	_queue.advance()
	assert_signal_emitted(_queue, "turn_ready")


func test_turn_order_changed_on_initialize() -> void:
	var a := Helpers.make_battler({"speed": 10})
	add_child_autofree(a)

	watch_signals(_queue)
	_queue.initialize([a])
	assert_signal_emitted(_queue, "turn_order_changed")

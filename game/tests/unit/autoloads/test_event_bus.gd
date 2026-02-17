extends GutTest

## Tests for EventBus autoload — central signal hub for gameplay events.

const EventBusScript := preload("res://autoloads/event_bus.gd")

var _bus: Node


func before_each() -> void:
	_bus = EventBusScript.new()
	add_child_autofree(_bus)


# --- Signal Existence Tests ---


func test_has_player_interacted_signal() -> void:
	assert_true(_bus.has_signal("player_interacted"))


func test_has_npc_talked_to_signal() -> void:
	assert_true(_bus.has_signal("npc_talked_to"))


func test_has_npc_interaction_ended_signal() -> void:
	assert_true(_bus.has_signal("npc_interaction_ended"))


func test_has_interactable_used_signal() -> void:
	assert_true(_bus.has_signal("interactable_used"))


func test_has_enemy_defeated_signal() -> void:
	assert_true(_bus.has_signal("enemy_defeated"))


func test_has_item_acquired_signal() -> void:
	assert_true(_bus.has_signal("item_acquired"))


func test_has_area_entered_signal() -> void:
	assert_true(_bus.has_signal("area_entered"))


# --- Emission Tests ---


func test_emit_player_interacted() -> void:
	watch_signals(_bus)
	var target := Node.new()
	add_child_autofree(target)
	_bus.emit_player_interacted(target)
	assert_signal_emitted(_bus, "player_interacted")


func test_emit_npc_talked_to() -> void:
	watch_signals(_bus)
	_bus.emit_npc_talked_to("Elder Thessa")
	assert_signal_emitted(_bus, "npc_talked_to")


func test_emit_npc_interaction_ended() -> void:
	watch_signals(_bus)
	_bus.emit_npc_interaction_ended("Elder Thessa")
	assert_signal_emitted(_bus, "npc_interaction_ended")


func test_emit_interactable_used() -> void:
	watch_signals(_bus)
	_bus.emit_interactable_used("save_point_01")
	assert_signal_emitted(_bus, "interactable_used")


func test_emit_enemy_defeated() -> void:
	watch_signals(_bus)
	_bus.emit_enemy_defeated(&"slime")
	assert_signal_emitted(_bus, "enemy_defeated")


func test_emit_item_acquired() -> void:
	watch_signals(_bus)
	_bus.emit_item_acquired(&"potion", 3)
	assert_signal_emitted(_bus, "item_acquired")


func test_emit_area_entered() -> void:
	watch_signals(_bus)
	_bus.emit_area_entered("verdant_forest")
	assert_signal_emitted(_bus, "area_entered")


# --- Signal Parameter Tests ---
# GDScript lambdas don't update captured outer-scope variables,
# so use GUT's assert_signal_emitted_with_parameters instead.


func test_player_interacted_passes_target() -> void:
	watch_signals(_bus)
	var target := Node.new()
	add_child_autofree(target)
	_bus.emit_player_interacted(target)
	assert_signal_emitted_with_parameters(
		_bus, "player_interacted", [target]
	)


func test_npc_talked_to_passes_name() -> void:
	watch_signals(_bus)
	_bus.emit_npc_talked_to("Garrick")
	assert_signal_emitted_with_parameters(
		_bus, "npc_talked_to", ["Garrick"]
	)


func test_npc_interaction_ended_passes_name() -> void:
	watch_signals(_bus)
	_bus.emit_npc_interaction_ended("Garrick")
	assert_signal_emitted_with_parameters(
		_bus, "npc_interaction_ended", ["Garrick"]
	)


func test_interactable_used_passes_name() -> void:
	watch_signals(_bus)
	_bus.emit_interactable_used("chest_01")
	assert_signal_emitted_with_parameters(
		_bus, "interactable_used", ["chest_01"]
	)


func test_enemy_defeated_passes_id() -> void:
	watch_signals(_bus)
	_bus.emit_enemy_defeated(&"moss_golem")
	assert_signal_emitted_with_parameters(
		_bus, "enemy_defeated", [&"moss_golem"]
	)


func test_item_acquired_passes_id_and_quantity() -> void:
	watch_signals(_bus)
	_bus.emit_item_acquired(&"herb", 5)
	assert_signal_emitted_with_parameters(
		_bus, "item_acquired", [&"herb", 5]
	)


func test_area_entered_passes_area_name() -> void:
	watch_signals(_bus)
	_bus.emit_area_entered("overgrown_ruins")
	assert_signal_emitted_with_parameters(
		_bus, "area_entered", ["overgrown_ruins"]
	)


# --- Multiple Listeners Test ---
# Use mutable Array container since GDScript lambdas can mutate
# captured objects but cannot reassign captured variables.


func test_multiple_listeners_all_receive() -> void:
	var counts := [0, 0]
	_bus.npc_talked_to.connect(
		func(_n: String) -> void: counts[0] += 1
	)
	_bus.npc_talked_to.connect(
		func(_n: String) -> void: counts[1] += 1
	)
	_bus.emit_npc_talked_to("Iris")
	assert_eq(counts[0], 1)
	assert_eq(counts[1], 1)

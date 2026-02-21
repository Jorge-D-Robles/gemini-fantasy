extends GutTest

## Tests for BattleScene spawn helpers — signal connections wired by
## _connect_battler_signals().

const Helpers = preload("res://tests/helpers/test_helpers.gd")
const BattleSceneScript = preload("res://systems/battle/battle_scene.gd")


# ---- _connect_battler_signals ----

func _make_minimal_battle_scene() -> Node:
	# Create without add_child to avoid _ready() — @onready vars need the
	# full .tscn tree which unit tests don't have.
	var scene := BattleSceneScript.new()
	autofree(scene)
	return scene


func test_connect_battler_signals_wires_defeated() -> void:
	var scene: Node = _make_minimal_battle_scene()
	var battler := Helpers.make_battler()
	add_child_autofree(battler)

	scene._connect_battler_signals(battler)

	assert_true(
		battler.defeated.is_connected(scene._on_battler_defeated.bind(battler)),
		"defeated signal should be connected after _connect_battler_signals",
	)


func test_connect_battler_signals_wires_resonance_changed() -> void:
	var scene: Node = _make_minimal_battle_scene()
	var battler := Helpers.make_battler()
	add_child_autofree(battler)

	scene._connect_battler_signals(battler)

	assert_true(
		battler.resonance_state_changed.is_connected(
			scene._on_resonance_state_changed.bind(battler),
		),
		"resonance_state_changed signal should be connected",
	)


func test_connect_battler_signals_does_not_double_connect() -> void:
	var scene: Node = _make_minimal_battle_scene()
	var battler := Helpers.make_battler()
	add_child_autofree(battler)

	scene._connect_battler_signals(battler)
	# Verify signal is wired after a single call
	assert_true(
		battler.defeated.is_connected(scene._on_battler_defeated.bind(battler)),
		"Signal should be connected after first call",
	)

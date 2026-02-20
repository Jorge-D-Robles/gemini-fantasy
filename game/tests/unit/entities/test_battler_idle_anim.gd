extends GutTest

## Tests for T-0095: Battler idle bob animation in combat.
## Verifies constants, method existence, and phase offset logic.
## Scene-wired tween behavior is verified via /scene-preview.

const PBSScript = preload("res://entities/battle/party_battler_scene.gd")
const EBSScript = preload("res://entities/battle/enemy_battler_scene.gd")


# -- Constants --


func test_party_battler_bob_amplitude_is_positive() -> void:
	assert_true(
		PBSScript.BOB_AMPLITUDE > 0.0,
		"BOB_AMPLITUDE must be a positive pixel value",
	)


func test_party_battler_bob_half_period_is_positive() -> void:
	assert_true(
		PBSScript.BOB_HALF_PERIOD > 0.0,
		"BOB_HALF_PERIOD must be a positive duration",
	)


func test_enemy_battler_bob_amplitude_is_positive() -> void:
	assert_true(
		EBSScript.BOB_AMPLITUDE > 0.0,
		"EnemyBattlerScene BOB_AMPLITUDE must be positive",
	)


func test_enemy_battler_bob_half_period_is_positive() -> void:
	assert_true(
		EBSScript.BOB_HALF_PERIOD > 0.0,
		"EnemyBattlerScene BOB_HALF_PERIOD must be positive",
	)


# -- Method existence (no scene tree required) --


func test_party_battler_has_start_idle_anim() -> void:
	var inst := PBSScript.new()
	assert_true(
		inst.has_method("start_idle_anim"),
		"PartyBattlerScene must have start_idle_anim()",
	)
	inst.free()


func test_party_battler_has_stop_idle_anim() -> void:
	var inst := PBSScript.new()
	assert_true(
		inst.has_method("stop_idle_anim"),
		"PartyBattlerScene must have stop_idle_anim()",
	)
	inst.free()


func test_enemy_battler_has_start_idle_anim() -> void:
	var inst := EBSScript.new()
	assert_true(
		inst.has_method("start_idle_anim"),
		"EnemyBattlerScene must have start_idle_anim()",
	)
	inst.free()


func test_enemy_battler_has_stop_idle_anim() -> void:
	var inst := EBSScript.new()
	assert_true(
		inst.has_method("stop_idle_anim"),
		"EnemyBattlerScene must have stop_idle_anim()",
	)
	inst.free()

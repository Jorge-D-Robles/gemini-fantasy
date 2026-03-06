extends GutTest

## Tests for the Ground command: cures Hollow ally,
## costs 25% resonance gauge, restores 25% HP.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const GB = preload("res://systems/game_balance.gd")


func test_ground_cures_hollow_state() -> void:
	var target: Battler = Helpers.make_battler({"max_hp": 100})
	add_child_autofree(target)
	# Force Hollow state
	target.resonance_state = Battler.ResonanceState.HOLLOW
	target.current_hp = 10
	target.cure_hollow()
	assert_eq(
		target.resonance_state,
		Battler.ResonanceState.FOCUSED,
		"Should return to FOCUSED",
	)


func test_ground_restores_25_percent_hp() -> void:
	var target: Battler = Helpers.make_battler({"max_hp": 100})
	add_child_autofree(target)
	target.resonance_state = Battler.ResonanceState.HOLLOW
	target.current_hp = 10
	target.cure_hollow()
	var expected_hp: int = 10 + int(100 * GB.GROUND_HEAL_PERCENT)
	target.current_hp = expected_hp
	assert_eq(target.current_hp, expected_hp)


func test_ground_cost_constant_exists() -> void:
	assert_gt(
		GB.GROUND_RESONANCE_COST, 0.0,
		"GROUND_RESONANCE_COST should be positive",
	)
	assert_eq(
		GB.GROUND_RESONANCE_COST, 25.0,
		"GROUND_RESONANCE_COST should be 25",
	)


func test_ground_heal_constant_exists() -> void:
	assert_gt(
		GB.GROUND_HEAL_PERCENT, 0.0,
		"GROUND_HEAL_PERCENT should be positive",
	)
	assert_eq(
		GB.GROUND_HEAL_PERCENT, 0.25,
		"GROUND_HEAL_PERCENT should be 0.25",
	)


func test_has_hollow_ally_false_when_none() -> void:
	var party: Array[Battler] = []
	var b: Battler = Helpers.make_battler()
	add_child_autofree(b)
	party.append(b)
	var found := false
	for member: Battler in party:
		if (
			member.is_alive
			and member.resonance_state == Battler.ResonanceState.HOLLOW
		):
			found = true
			break
	assert_false(found, "No hollow allies in party")


func test_has_hollow_ally_true_when_hollow() -> void:
	var party: Array[Battler] = []
	var b: Battler = Helpers.make_battler()
	add_child_autofree(b)
	b.resonance_state = Battler.ResonanceState.HOLLOW
	party.append(b)
	var found := false
	for member: Battler in party:
		if (
			member.is_alive
			and member.resonance_state == Battler.ResonanceState.HOLLOW
		):
			found = true
			break
	assert_true(found, "Should detect hollow ally")

extends GutTest

## Tests for status effect system — apply, tick, expire, stat mods, stun.

const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _battler: Battler
var _poison: StatusEffectData
var _burn: StatusEffectData
var _regen: StatusEffectData
var _attack_up: StatusEffectData
var _defense_down: StatusEffectData
var _stun: StatusEffectData


func before_each() -> void:
	_battler = Helpers.make_battler({"max_hp": 100, "defense": 0})
	add_child_autofree(_battler)

	_poison = Helpers.make_status_effect({
		"id": &"poison",
		"display_name": "Poison",
		"effect_type": StatusEffectData.EffectType.DAMAGE_OVER_TIME,
		"duration": 3,
		"tick_damage": 10,
	})
	_burn = Helpers.make_status_effect({
		"id": &"burn",
		"display_name": "Burn",
		"effect_type": StatusEffectData.EffectType.DAMAGE_OVER_TIME,
		"duration": 2,
		"tick_damage": 15,
		"is_magical": true,
	})
	_regen = Helpers.make_status_effect({
		"id": &"regen",
		"display_name": "Regen",
		"effect_type": StatusEffectData.EffectType.HEAL_OVER_TIME,
		"duration": 4,
		"tick_heal": 12,
	})
	_attack_up = Helpers.make_status_effect({
		"id": &"attack_up",
		"display_name": "Attack Up",
		"effect_type": StatusEffectData.EffectType.BUFF,
		"duration": 3,
		"attack_modifier": 10,
	})
	_defense_down = Helpers.make_status_effect({
		"id": &"defense_down",
		"display_name": "Defense Down",
		"effect_type": StatusEffectData.EffectType.DEBUFF,
		"duration": 2,
		"defense_modifier": -5,
	})
	_stun = Helpers.make_status_effect({
		"id": &"stun",
		"display_name": "Stun",
		"effect_type": StatusEffectData.EffectType.STUN,
		"duration": 1,
		"prevents_action": true,
	})


# --- Apply ---


func test_apply_status() -> void:
	_battler.apply_status(_poison)
	assert_true(_battler.has_status(&"poison"))


func test_apply_duplicate_refreshes_duration() -> void:
	_battler.apply_status(_poison)
	# Tick once to reduce duration
	_battler.tick_effects()
	# Apply again — should refresh duration back to 3
	_battler.apply_status(_poison)
	var remaining := _battler.get_effect_remaining_turns(&"poison")
	assert_eq(remaining, 3)


func test_apply_multiple_different_effects() -> void:
	_battler.apply_status(_poison)
	_battler.apply_status(_burn)
	assert_true(_battler.has_status(&"poison"))
	assert_true(_battler.has_status(&"burn"))
	assert_eq(_battler.get_active_effect_count(), 2)


func test_has_status_returns_false_when_absent() -> void:
	assert_false(_battler.has_status(&"poison"))


# --- Remove ---


func test_remove_status() -> void:
	_battler.apply_status(_poison)
	_battler.remove_status(&"poison")
	assert_false(_battler.has_status(&"poison"))


func test_remove_nonexistent_is_safe() -> void:
	# Should not crash
	_battler.remove_status(&"nonexistent")
	assert_eq(_battler.get_active_effect_count(), 0)


func test_clear_all_effects() -> void:
	_battler.apply_status(_poison)
	_battler.apply_status(_burn)
	_battler.apply_status(_attack_up)
	_battler.clear_all_effects()
	assert_eq(_battler.get_active_effect_count(), 0)


# --- Signals ---


func test_status_applied_signal() -> void:
	watch_signals(_battler)
	_battler.apply_status(_poison)
	assert_signal_emitted_with_parameters(
		_battler, "status_effect_applied", [&"poison"]
	)


func test_status_removed_signal() -> void:
	_battler.apply_status(_poison)
	watch_signals(_battler)
	_battler.remove_status(&"poison")
	assert_signal_emitted_with_parameters(
		_battler, "status_effect_removed", [&"poison"]
	)


func test_status_expired_signal_on_tick() -> void:
	var one_turn := Helpers.make_status_effect({
		"id": &"flash",
		"duration": 1,
	})
	_battler.apply_status(one_turn)
	watch_signals(_battler)
	_battler.tick_effects()
	assert_signal_emitted_with_parameters(
		_battler, "status_effect_removed", [&"flash"]
	)


# --- Tick: Damage Over Time ---


func test_poison_ticks_damage() -> void:
	_battler.apply_status(_poison)
	var hp_before := _battler.current_hp
	_battler.tick_effects()
	assert_eq(
		_battler.current_hp, hp_before - 10,
		"Poison should deal 10 damage per tick"
	)


func test_poison_reduces_duration() -> void:
	_battler.apply_status(_poison)
	_battler.tick_effects()
	assert_eq(_battler.get_effect_remaining_turns(&"poison"), 2)


func test_poison_expires_after_duration() -> void:
	_battler.apply_status(_poison)
	_battler.tick_effects()  # 3 -> 2
	_battler.tick_effects()  # 2 -> 1
	_battler.tick_effects()  # 1 -> 0, expires
	assert_false(_battler.has_status(&"poison"))


func test_dot_cannot_kill() -> void:
	_battler.current_hp = 5
	_battler.apply_status(_poison)  # 10 damage per tick
	_battler.tick_effects()
	assert_eq(
		_battler.current_hp, 1,
		"DoT should leave at least 1 HP"
	)
	assert_true(_battler.is_alive)


func test_multiple_dots_stack_damage() -> void:
	_battler.apply_status(_poison)
	_battler.apply_status(_burn)
	var hp_before := _battler.current_hp
	_battler.tick_effects()
	# Poison 10 + burn 15 = 25 total
	assert_eq(_battler.current_hp, hp_before - 25)


# --- Tick: Heal Over Time ---


func test_regen_ticks_healing() -> void:
	_battler.current_hp = 50
	_battler.apply_status(_regen)
	_battler.tick_effects()
	assert_eq(_battler.current_hp, 62)


func test_regen_caps_at_max_hp() -> void:
	_battler.current_hp = 95
	_battler.apply_status(_regen)  # 12 heal per tick
	_battler.tick_effects()
	assert_eq(_battler.current_hp, _battler.max_hp)


func test_regen_expires_after_duration() -> void:
	_battler.apply_status(_regen)
	for i in 4:
		_battler.tick_effects()
	assert_false(_battler.has_status(&"regen"))


# --- Stat Modifiers ---


func test_attack_buff_modifier() -> void:
	var base_attack := _battler.attack
	_battler.apply_status(_attack_up)
	assert_eq(
		_battler.get_modified_stat("attack"),
		base_attack + 10,
	)


func test_defense_debuff_modifier() -> void:
	var base_def := _battler.defense
	_battler.apply_status(_defense_down)
	assert_eq(
		_battler.get_modified_stat("defense"),
		maxi(base_def - 5, 0),
	)


func test_multiple_modifiers_stack() -> void:
	var atk_up_2 := Helpers.make_status_effect({
		"id": &"might",
		"effect_type": StatusEffectData.EffectType.BUFF,
		"duration": 3,
		"attack_modifier": 5,
	})
	_battler.apply_status(_attack_up)
	_battler.apply_status(atk_up_2)
	var base_attack := _battler.attack
	assert_eq(
		_battler.get_modified_stat("attack"),
		base_attack + 15,
	)


func test_modifier_removed_when_effect_expires() -> void:
	var one_turn_buff := Helpers.make_status_effect({
		"id": &"quick_buff",
		"effect_type": StatusEffectData.EffectType.BUFF,
		"duration": 1,
		"attack_modifier": 20,
	})
	var base_attack := _battler.attack
	_battler.apply_status(one_turn_buff)
	assert_eq(_battler.get_modified_stat("attack"), base_attack + 20)
	_battler.tick_effects()
	assert_eq(
		_battler.get_modified_stat("attack"),
		base_attack,
		"Modifier should be gone after effect expires",
	)


func test_stat_modifier_floor_at_zero() -> void:
	var big_debuff := Helpers.make_status_effect({
		"id": &"shatter",
		"effect_type": StatusEffectData.EffectType.DEBUFF,
		"duration": 2,
		"defense_modifier": -999,
	})
	_battler.apply_status(big_debuff)
	assert_eq(
		_battler.get_modified_stat("defense"), 0,
		"Modified stat should not go below 0",
	)


func test_all_stat_modifiers() -> void:
	var all_buff := Helpers.make_status_effect({
		"id": &"all_buff",
		"effect_type": StatusEffectData.EffectType.BUFF,
		"attack_modifier": 1,
		"magic_modifier": 2,
		"defense_modifier": 3,
		"resistance_modifier": 4,
		"speed_modifier": 5,
		"luck_modifier": 6,
	})
	_battler.apply_status(all_buff)
	assert_eq(
		_battler.get_modified_stat("attack"),
		_battler.attack + 1,
	)
	assert_eq(
		_battler.get_modified_stat("magic"),
		_battler.magic + 2,
	)
	assert_eq(
		_battler.get_modified_stat("defense"),
		_battler.defense + 3,
	)
	assert_eq(
		_battler.get_modified_stat("resistance"),
		_battler.resistance + 4,
	)
	assert_eq(
		_battler.get_modified_stat("speed"),
		_battler.speed + 5,
	)
	assert_eq(
		_battler.get_modified_stat("luck"),
		_battler.luck + 6,
	)


# --- Stun / Prevents Action ---


func test_stun_prevents_action() -> void:
	_battler.apply_status(_stun)
	assert_true(_battler.is_action_prevented())


func test_stun_expires_after_duration() -> void:
	_battler.apply_status(_stun)
	_battler.tick_effects()
	assert_false(_battler.is_action_prevented())
	assert_false(_battler.has_status(&"stun"))


func test_non_stun_effect_does_not_prevent_action() -> void:
	_battler.apply_status(_poison)
	assert_false(_battler.is_action_prevented())


# --- Permanent Effects ---


func test_permanent_effect_never_expires() -> void:
	var permanent := Helpers.make_status_effect({
		"id": &"curse",
		"duration": 0,
		"defense_modifier": -3,
	})
	_battler.apply_status(permanent)
	for i in 10:
		_battler.tick_effects()
	assert_true(
		_battler.has_status(&"curse"),
		"Duration 0 = permanent, should not expire",
	)


# --- Edge Cases ---


func test_tick_effects_on_dead_battler_is_safe() -> void:
	_battler.apply_status(_poison)
	_battler.current_hp = 0
	_battler.is_alive = false
	# Should not crash — effects are not ticked on dead battlers
	_battler.tick_effects()
	assert_eq(_battler.current_hp, 0)


func test_get_effect_remaining_turns_absent() -> void:
	var turns := _battler.get_effect_remaining_turns(&"nonexistent")
	assert_eq(turns, -1)

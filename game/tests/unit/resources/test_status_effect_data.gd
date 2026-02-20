extends GutTest

## Tests for StatusEffectData resource — factory helper verification.

const Helpers := preload("res://tests/helpers/test_helpers.gd")


func test_factory_creates_poison() -> void:
	var poison := Helpers.make_status_effect({
		"id": &"poison",
		"display_name": "Poison",
		"effect_type": StatusEffectData.EffectType.DAMAGE_OVER_TIME,
		"duration": 3,
		"tick_damage": 10,
	})
	assert_eq(poison.id, &"poison")
	assert_eq(poison.display_name, "Poison")
	assert_eq(
		poison.effect_type,
		StatusEffectData.EffectType.DAMAGE_OVER_TIME,
	)
	assert_eq(poison.duration, 3)
	assert_eq(poison.tick_damage, 10)


func test_factory_creates_buff() -> void:
	var buff := Helpers.make_status_effect({
		"id": &"attack_up",
		"effect_type": StatusEffectData.EffectType.BUFF,
		"duration": 5,
		"attack_modifier": 10,
	})
	assert_eq(buff.effect_type, StatusEffectData.EffectType.BUFF)
	assert_eq(buff.duration, 5)
	assert_eq(buff.attack_modifier, 10)


func test_factory_creates_stun() -> void:
	var stun := Helpers.make_status_effect({
		"id": &"stun",
		"effect_type": StatusEffectData.EffectType.STUN,
		"duration": 1,
		"prevents_action": true,
	})
	assert_eq(stun.effect_type, StatusEffectData.EffectType.STUN)
	assert_eq(stun.duration, 1)
	assert_true(stun.prevents_action)


func test_factory_creates_regen() -> void:
	var regen := Helpers.make_status_effect({
		"id": &"regen",
		"effect_type": StatusEffectData.EffectType.HEAL_OVER_TIME,
		"duration": 4,
		"tick_heal": 15,
	})
	assert_eq(
		regen.effect_type,
		StatusEffectData.EffectType.HEAL_OVER_TIME,
	)
	assert_eq(regen.tick_heal, 15)

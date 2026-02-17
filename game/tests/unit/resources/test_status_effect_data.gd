extends GutTest

## Tests for StatusEffectData resource class.

const Helpers := preload("res://tests/helpers/test_helpers.gd")


func test_default_values() -> void:
	var e := StatusEffectData.new()
	assert_eq(e.id, &"")
	assert_eq(e.display_name, "")
	assert_eq(e.effect_type, StatusEffectData.EffectType.DEBUFF)
	assert_eq(e.duration, 3)
	assert_eq(e.tick_damage, 0)
	assert_eq(e.tick_heal, 0)
	assert_false(e.is_magical)
	assert_false(e.prevents_action)
	assert_eq(e.attack_modifier, 0)
	assert_eq(e.magic_modifier, 0)
	assert_eq(e.defense_modifier, 0)
	assert_eq(e.resistance_modifier, 0)
	assert_eq(e.speed_modifier, 0)
	assert_eq(e.luck_modifier, 0)


func test_effect_type_enum_values() -> void:
	assert_eq(StatusEffectData.EffectType.BUFF, 0)
	assert_eq(StatusEffectData.EffectType.DEBUFF, 1)
	assert_eq(StatusEffectData.EffectType.DAMAGE_OVER_TIME, 2)
	assert_eq(StatusEffectData.EffectType.HEAL_OVER_TIME, 3)
	assert_eq(StatusEffectData.EffectType.STUN, 4)


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


func test_factory_default_values() -> void:
	var e := Helpers.make_status_effect()
	assert_eq(e.id, &"test_effect")
	assert_eq(e.display_name, "Test Effect")
	assert_eq(e.effect_type, StatusEffectData.EffectType.DEBUFF)
	assert_eq(e.duration, 3)

extends GutTest

## Tests that all core status effect .tres files load correctly and have valid fields.

const EFFECTS_DIR: String = "res://data/status_effects/"
const EFFECT_IDS: Array[String] = [
	"poison", "burn", "stun", "haste", "slow",
	"shield", "weakness", "regen",
]


func test_all_effects_load() -> void:
	for effect_id: String in EFFECT_IDS:
		var path := EFFECTS_DIR + effect_id + ".tres"
		var res := load(path)
		assert_not_null(res, "%s should load" % path)
		assert_true(res is StatusEffectData, "%s should be StatusEffectData" % path)


func test_all_effects_have_id() -> void:
	for effect_id: String in EFFECT_IDS:
		var eff: StatusEffectData = load(EFFECTS_DIR + effect_id + ".tres")
		assert_eq(
			String(eff.id), effect_id,
			"%s id should match filename" % effect_id,
		)


func test_all_effects_have_display_name() -> void:
	for effect_id: String in EFFECT_IDS:
		var eff: StatusEffectData = load(EFFECTS_DIR + effect_id + ".tres")
		assert_ne(
			eff.display_name, "",
			"%s should have display_name" % effect_id,
		)


func test_dot_effects_have_tick_damage() -> void:
	var dot_ids: Array[String] = ["poison", "burn"]
	for effect_id: String in dot_ids:
		var eff: StatusEffectData = load(EFFECTS_DIR + effect_id + ".tres")
		assert_gt(
			eff.tick_damage, 0,
			"%s should have tick_damage > 0" % effect_id,
		)
		assert_eq(
			eff.effect_type,
			StatusEffectData.EffectType.DAMAGE_OVER_TIME,
			"%s should be DAMAGE_OVER_TIME" % effect_id,
		)


func test_regen_has_tick_heal() -> void:
	var eff: StatusEffectData = load(EFFECTS_DIR + "regen.tres")
	assert_gt(eff.tick_heal, 0, "regen should have tick_heal > 0")
	assert_eq(
		eff.effect_type,
		StatusEffectData.EffectType.HEAL_OVER_TIME,
	)


func test_stun_prevents_action() -> void:
	var eff: StatusEffectData = load(EFFECTS_DIR + "stun.tres")
	assert_true(eff.prevents_action, "stun should prevent action")
	assert_eq(eff.duration, 1, "stun should last 1 turn")


func test_buff_effects_have_positive_modifiers() -> void:
	var haste: StatusEffectData = load(EFFECTS_DIR + "haste.tres")
	assert_gt(haste.speed_modifier, 0, "haste should boost speed")

	var shield: StatusEffectData = load(EFFECTS_DIR + "shield.tres")
	assert_gt(shield.defense_modifier, 0, "shield should boost defense")


func test_debuff_effects_have_negative_modifiers() -> void:
	var slow: StatusEffectData = load(EFFECTS_DIR + "slow.tres")
	assert_lt(slow.speed_modifier, 0, "slow should reduce speed")

	var weakness: StatusEffectData = load(EFFECTS_DIR + "weakness.tres")
	assert_lt(weakness.defense_modifier, 0, "weakness should reduce defense")

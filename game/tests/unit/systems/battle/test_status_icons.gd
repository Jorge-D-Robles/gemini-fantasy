extends GutTest

## Tests for T-0054: Status effect icons/badges on battler panels.
## Covers Battler accessors, UITheme status colors, and BattleUI badge computation.

const BattlerScript := preload("res://systems/battle/battler.gd")
const UITheme := preload("res://ui/ui_theme.gd")
const BattleUIScript := preload(
	"res://ui/battle_ui/battle_ui_status.gd"
)
const Helpers := preload("res://tests/helpers/test_helpers.gd")

var _battler: Node2D


func before_each() -> void:
	_battler = BattlerScript.new()
	_battler.data = Helpers.make_battler_data()
	_battler.initialize_from_data()
	add_child_autofree(_battler)


# -- Battler.get_effect_data() --


func test_battler_get_effect_data_found() -> void:
	var eff := Helpers.make_status_effect({
		"id": &"poison",
		"effect_type": StatusEffectData.EffectType.DAMAGE_OVER_TIME,
	})
	_battler.apply_status(eff)
	var result: StatusEffectData = _battler.get_effect_data(&"poison")
	assert_not_null(result, "Should return data for applied effect")
	assert_eq(
		result.effect_type,
		StatusEffectData.EffectType.DAMAGE_OVER_TIME,
		"Should have correct effect type",
	)


func test_battler_get_effect_data_not_found() -> void:
	var result: StatusEffectData = _battler.get_effect_data(&"nonexistent")
	assert_null(result, "Should return null for unknown effect id")


func test_battler_get_effect_data_legacy_defaults_debuff() -> void:
	# Legacy apply_status_effect creates StatusEffectData with default DEBUFF
	_battler.apply_status_effect(&"weakness")
	var result: StatusEffectData = _battler.get_effect_data(&"weakness")
	assert_not_null(result)
	assert_eq(
		result.effect_type,
		StatusEffectData.EffectType.DEBUFF,
		"Legacy wrapper should default to DEBUFF",
	)


# -- Battler.get_status_effect_list() --


func test_battler_get_status_effect_list_empty() -> void:
	var result: Array = _battler.get_status_effect_list()
	assert_eq(result.size(), 0, "Should be empty initially")


func test_battler_get_status_effect_list_contains_applied() -> void:
	var buff := Helpers.make_status_effect({
		"id": &"shield",
		"effect_type": StatusEffectData.EffectType.BUFF,
	})
	var dot := Helpers.make_status_effect({
		"id": &"burn",
		"effect_type": StatusEffectData.EffectType.DAMAGE_OVER_TIME,
	})
	_battler.apply_status(buff)
	_battler.apply_status(dot)
	var result: Array = _battler.get_status_effect_list()
	assert_eq(result.size(), 2, "Should contain both effects")


func test_battler_get_status_effect_list_safe_copy() -> void:
	var eff := Helpers.make_status_effect({"id": &"regen"})
	_battler.apply_status(eff)
	var result: Array = _battler.get_status_effect_list()
	result.clear()
	assert_eq(
		_battler.get_active_effect_count(), 1,
		"Clearing returned list should not affect battler",
	)


# -- UITheme.get_status_color() --


func test_get_status_color_buff() -> void:
	var color: Color = UITheme.get_status_color(
		StatusEffectData.EffectType.BUFF,
	)
	assert_eq(color, UITheme.STATUS_BUFF)


func test_get_status_color_debuff() -> void:
	var color: Color = UITheme.get_status_color(
		StatusEffectData.EffectType.DEBUFF,
	)
	assert_eq(color, UITheme.STATUS_DEBUFF)


func test_get_status_color_dot() -> void:
	var color: Color = UITheme.get_status_color(
		StatusEffectData.EffectType.DAMAGE_OVER_TIME,
	)
	assert_eq(color, UITheme.STATUS_DOT)


func test_get_status_color_hot() -> void:
	var color: Color = UITheme.get_status_color(
		StatusEffectData.EffectType.HEAL_OVER_TIME,
	)
	assert_eq(color, UITheme.STATUS_HOT)


func test_get_status_color_stun() -> void:
	var color: Color = UITheme.get_status_color(
		StatusEffectData.EffectType.STUN,
	)
	assert_eq(color, UITheme.STATUS_STUN)


# -- BattleUI.compute_status_badges() --


func test_compute_status_badges_empty() -> void:
	var effects: Array[StatusEffectData] = []
	var result: Array = BattleUIScript.compute_status_badges(effects)
	assert_eq(result.size(), 0, "Empty effects -> empty badges")


func test_compute_status_badges_single() -> void:
	var eff := Helpers.make_status_effect({
		"id": &"strength_up",
		"effect_type": StatusEffectData.EffectType.BUFF,
	})
	var effects: Array[StatusEffectData] = [eff]
	var result: Array = BattleUIScript.compute_status_badges(effects)
	assert_eq(result.size(), 1, "One effect -> one badge")
	assert_eq(result[0]["text"], "ST", "2-char abbreviation of id")
	assert_eq(
		result[0]["color"], UITheme.STATUS_BUFF,
		"BUFF should use green",
	)


func test_compute_status_badges_multiple() -> void:
	var buff := Helpers.make_status_effect({
		"id": &"shield",
		"effect_type": StatusEffectData.EffectType.BUFF,
	})
	var dot := Helpers.make_status_effect({
		"id": &"poison",
		"effect_type": StatusEffectData.EffectType.DAMAGE_OVER_TIME,
	})
	var stun := Helpers.make_status_effect({
		"id": &"stun",
		"effect_type": StatusEffectData.EffectType.STUN,
	})
	var effects: Array[StatusEffectData] = [buff, dot, stun]
	var result: Array = BattleUIScript.compute_status_badges(effects)
	assert_eq(result.size(), 3)
	assert_eq(result[0]["color"], UITheme.STATUS_BUFF)
	assert_eq(result[1]["color"], UITheme.STATUS_DOT)
	assert_eq(result[2]["color"], UITheme.STATUS_STUN)

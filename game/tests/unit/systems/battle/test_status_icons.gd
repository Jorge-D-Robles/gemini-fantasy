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


func test_battler_get_effect_data_debuff_type() -> void:
	var effect := Helpers.make_status_effect({"id": &"weakness"})
	_battler.apply_status(effect)
	var result: StatusEffectData = _battler.get_effect_data(&"weakness")
	assert_not_null(result)
	assert_eq(
		result.effect_type,
		StatusEffectData.EffectType.DEBUFF,
		"make_status_effect defaults to DEBUFF",
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


# -- BattleUIStatus.compute_defend_badge() --


func test_defend_badge_not_defending_returns_empty() -> void:
	var result: Array = BattleUIScript.compute_defend_badge(false)
	assert_eq(result.size(), 0, "Not defending -> no badge")


func test_defend_badge_defending_returns_one_badge() -> void:
	var result: Array = BattleUIScript.compute_defend_badge(true)
	assert_eq(result.size(), 1, "Defending -> one badge")


func test_defend_badge_text_is_def() -> void:
	var result: Array = BattleUIScript.compute_defend_badge(true)
	assert_eq(result[0]["text"], "DEF", "Defend badge text should be DEF")


func test_defend_badge_color_matches_theme() -> void:
	var result: Array = BattleUIScript.compute_defend_badge(true)
	assert_eq(
		result[0]["color"],
		UITheme.DEFEND_BADGE_COLOR,
		"Defend badge should use UITheme.DEFEND_BADGE_COLOR",
	)


# -- BattleUIStatus.compute_turn_order_entries() --

func test_turn_order_active_battler_shown_first_with_brackets() -> void:
	var pb := Helpers.make_party_battler({"display_name": "Kael"})
	add_child_autofree(pb)
	var result: Array = BattleUIScript.compute_turn_order_entries(pb, [])
	assert_eq(result.size(), 1, "Active battler alone should produce one entry")
	assert_true(result[0]["text"].begins_with("["), "Active entry should start with '['")
	assert_true(result[0]["text"].ends_with("]"), "Active entry should end with ']'")


func test_turn_order_active_battler_uses_active_highlight() -> void:
	var pb := Helpers.make_party_battler()
	add_child_autofree(pb)
	var result: Array = BattleUIScript.compute_turn_order_entries(pb, [])
	assert_eq(result[0]["color"], UITheme.ACTIVE_HIGHLIGHT, "Active battler uses ACTIVE_HIGHLIGHT")


func test_turn_order_party_battler_in_queue_is_blue() -> void:
	var pb := Helpers.make_party_battler()
	add_child_autofree(pb)
	var result: Array = BattleUIScript.compute_turn_order_entries(null, [pb])
	# Filter out separators
	var battler_entries: Array = result.filter(
		func(e: Dictionary) -> bool: return not e["is_separator"]
	)
	assert_eq(
		battler_entries[0]["color"],
		Color(0.7, 0.85, 1.0),
		"Party battler queue entry should use blue tint",
	)


func test_turn_order_enemy_battler_in_queue_is_red() -> void:
	var eb := Helpers.make_enemy_battler()
	add_child_autofree(eb)
	var result: Array = BattleUIScript.compute_turn_order_entries(null, [eb])
	var battler_entries: Array = result.filter(
		func(e: Dictionary) -> bool: return not e["is_separator"]
	)
	assert_eq(
		battler_entries[0]["color"],
		Color(1.0, 0.5, 0.5),
		"Enemy battler queue entry should use red tint",
	)


func test_turn_order_null_active_shows_only_queue() -> void:
	var pb := Helpers.make_party_battler()
	add_child_autofree(pb)
	var result: Array = BattleUIScript.compute_turn_order_entries(null, [pb])
	var battler_entries: Array = result.filter(
		func(e: Dictionary) -> bool: return not e["is_separator"]
	)
	assert_eq(battler_entries.size(), 1, "One queue entry shown with null active")
	assert_false(
		battler_entries[0]["text"].begins_with("["),
		"Queue entry should not have brackets when active is null",
	)


func test_turn_order_separator_between_active_and_queue() -> void:
	var pb := Helpers.make_party_battler()
	var eb := Helpers.make_enemy_battler()
	add_child_autofree(pb)
	add_child_autofree(eb)
	var result: Array = BattleUIScript.compute_turn_order_entries(pb, [eb])
	assert_eq(result.size(), 3, "Active + separator + one queue entry = 3 elements")
	assert_true(result[1]["is_separator"], "Middle element should be separator")

extends GutTest

## Tests for BattleUI.compute_target_info() static method.
## Validates name extraction, color selection, and null safety.

const BattleUI = preload("res://ui/battle_ui/battle_ui.gd")
const UITheme = preload("res://ui/ui_theme.gd")
const Helpers = preload("res://tests/helpers/test_helpers.gd")


func test_compute_target_info_enemy() -> void:
	var enemy := Helpers.make_enemy_battler({"id": "goblin"})
	add_child_autofree(enemy)
	var info: Dictionary = BattleUI.compute_target_info(enemy)
	assert_true(info["is_enemy"], "Should identify as enemy")
	assert_eq(info["color"], UITheme.TARGET_HIGHLIGHT_ENEMY)


func test_compute_target_info_party() -> void:
	var ally := Helpers.make_party_battler({"id": "kael"})
	add_child_autofree(ally)
	var info: Dictionary = BattleUI.compute_target_info(ally)
	assert_false(info["is_enemy"], "Should identify as party member")
	assert_eq(info["color"], UITheme.TARGET_HIGHLIGHT_PARTY)


func test_compute_target_info_display_name() -> void:
	var enemy := Helpers.make_enemy_battler({"id": "slime_king"})
	add_child_autofree(enemy)
	var info: Dictionary = BattleUI.compute_target_info(enemy)
	assert_eq(info["name"], enemy.get_display_name())


func test_compute_target_info_null_battler() -> void:
	var info: Dictionary = BattleUI.compute_target_info(null)
	assert_eq(info["name"], "???")
	assert_eq(info["color"], Color.WHITE)
	assert_true(info["is_enemy"], "Null defaults to enemy")


func test_compute_target_info_no_data() -> void:
	var battler := Battler.new()
	add_child_autofree(battler)
	var info: Dictionary = BattleUI.compute_target_info(battler)
	assert_eq(info["name"], battler.get_display_name())
	assert_eq(info["color"], UITheme.TARGET_HIGHLIGHT_ENEMY)

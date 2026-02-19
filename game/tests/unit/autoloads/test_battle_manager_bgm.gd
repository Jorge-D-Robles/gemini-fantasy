extends GutTest

## Tests for BGM integration: boss detection, BGM path selection,
## AudioManager accessor, and scene BGM constants.

const Helpers := preload("res://tests/helpers/test_helpers.gd")
const BM := preload("res://autoloads/battle_manager.gd")


# -- AudioManager.get_current_bgm_path() --


func test_get_current_bgm_path_empty_when_no_stream() -> void:
	var script: GDScript = load("res://autoloads/audio_manager.gd")
	var am: Node = script.new()
	add_child_autofree(am)
	assert_eq(am.get_current_bgm_path(), "")


# -- BattleManager boss detection --


func test_is_boss_encounter_false_for_basic_enemies() -> void:
	var group: Array[Resource] = [
		Helpers.make_enemy_data({"ai_type": EnemyData.AiType.BASIC}),
		Helpers.make_enemy_data({
			"ai_type": EnemyData.AiType.AGGRESSIVE,
		}),
	]
	assert_false(BM.is_boss_encounter(group))


func test_is_boss_encounter_true_when_boss_present() -> void:
	var group: Array[Resource] = [
		Helpers.make_enemy_data({"ai_type": EnemyData.AiType.BASIC}),
		Helpers.make_enemy_data({"ai_type": EnemyData.AiType.BOSS}),
	]
	assert_true(BM.is_boss_encounter(group))


func test_is_boss_encounter_false_for_empty_group() -> void:
	var group: Array[Resource] = []
	assert_false(BM.is_boss_encounter(group))


# -- BattleManager BGM path selection --


func test_get_battle_bgm_path_standard_for_non_boss() -> void:
	var group: Array[Resource] = [
		Helpers.make_enemy_data({"ai_type": EnemyData.AiType.BASIC}),
	]
	assert_eq(BM.get_battle_bgm_path(group), BM.BATTLE_BGM_PATH)


func test_get_battle_bgm_path_boss_for_boss_encounter() -> void:
	var group: Array[Resource] = [
		Helpers.make_enemy_data({"ai_type": EnemyData.AiType.BOSS}),
	]
	assert_eq(BM.get_battle_bgm_path(group), BM.BOSS_BGM_PATH)


# -- BGM path constants defined --


func test_battle_bgm_constants_defined() -> void:
	assert_ne(BM.BATTLE_BGM_PATH, "", "BATTLE_BGM_PATH should be set")
	assert_ne(BM.BOSS_BGM_PATH, "", "BOSS_BGM_PATH should be set")
	assert_true(
		BM.BATTLE_BGM_PATH.ends_with(".ogg"),
		"Battle BGM should be an OGG file",
	)
	assert_true(
		BM.BOSS_BGM_PATH.ends_with(".ogg"),
		"Boss BGM should be an OGG file",
	)


func test_scene_bgm_constants_defined() -> void:
	# Use FileAccess to verify constants exist without triggering
	# engine parse warnings from loading full scene scripts.
	var scenes: Dictionary = {
		"res://scenes/roothollow/roothollow.gd": "SCENE_BGM_PATH",
		"res://scenes/verdant_forest/verdant_forest.gd": "SCENE_BGM_PATH",
		"res://scenes/overgrown_ruins/overgrown_ruins.gd": "SCENE_BGM_PATH",
		"res://ui/title_screen/title_screen.gd": "TITLE_BGM_PATH",
		"res://systems/battle/states/victory_state.gd": "FANFARE_PATH",
	}
	for path: String in scenes:
		var source := FileAccess.get_file_as_string(path)
		assert_false(
			source.is_empty(),
			"Script file should exist: " + path,
		)
		var const_name: String = scenes[path]
		assert_true(
			source.contains(
				"const " + const_name + ": String"
			),
			path + " should define " + const_name,
		)
		assert_true(
			source.contains(".ogg"),
			path + " BGM path should reference an OGG file",
		)

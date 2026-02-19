extends GutTest

## Tests for BattleVFX — element-to-VFX config mapping and SpriteFrames building.

const BattleVFXScript = preload("res://entities/battle/battle_vfx.gd")


func test_get_vfx_config_returns_config_for_fire() -> void:
	var config: Dictionary = BattleVFXScript.get_vfx_config(
		AbilityData.Element.FIRE,
	)
	assert_eq(config["file"], "fire.png")
	assert_eq(config["frames"], 30)


func test_get_vfx_config_none_returns_impact() -> void:
	var config: Dictionary = BattleVFXScript.get_vfx_config(
		AbilityData.Element.NONE,
	)
	assert_eq(config["file"], "impact1.png")
	assert_eq(config["frames"], 30)


func test_get_vfx_config_returns_config_for_all_elements() -> void:
	var elements := [
		AbilityData.Element.NONE,
		AbilityData.Element.FIRE,
		AbilityData.Element.ICE,
		AbilityData.Element.WATER,
		AbilityData.Element.WIND,
		AbilityData.Element.EARTH,
		AbilityData.Element.LIGHT,
		AbilityData.Element.DARK,
	]
	for element in elements:
		var config: Dictionary = BattleVFXScript.get_vfx_config(element)
		assert_true(
			config.has("file"),
			"Element %d should have 'file' key" % element,
		)
		assert_true(
			config.has("frames"),
			"Element %d should have 'frames' key" % element,
		)
		assert_gt(
			config["frames"], 0,
			"Element %d should have positive frame count" % element,
		)


func test_get_heal_config_returns_heal() -> void:
	var config: Dictionary = BattleVFXScript.get_heal_config()
	assert_eq(config["file"], "heal.png")
	assert_eq(config["frames"], 50)


func test_build_sprite_frames_creates_animation() -> void:
	var image := Image.create(320, 384, false, Image.FORMAT_RGBA8)
	var texture := ImageTexture.create_from_image(image)
	var frames: SpriteFrames = BattleVFXScript.build_sprite_frames(
		texture, 30, 20.0,
	)
	assert_not_null(frames)
	assert_true(frames.has_animation("default"))
	assert_eq(frames.get_frame_count("default"), 30)


func test_build_sprite_frames_sets_fps() -> void:
	var image := Image.create(320, 384, false, Image.FORMAT_RGBA8)
	var texture := ImageTexture.create_from_image(image)
	var frames: SpriteFrames = BattleVFXScript.build_sprite_frames(
		texture, 30, 24.0,
	)
	assert_almost_eq(
		frames.get_animation_speed("default"), 24.0, 0.01,
	)


func test_all_vfx_configs_have_valid_file_names() -> void:
	var elements := [
		AbilityData.Element.NONE,
		AbilityData.Element.FIRE,
		AbilityData.Element.ICE,
		AbilityData.Element.WATER,
		AbilityData.Element.WIND,
		AbilityData.Element.EARTH,
		AbilityData.Element.LIGHT,
		AbilityData.Element.DARK,
	]
	for element in elements:
		var config: Dictionary = BattleVFXScript.get_vfx_config(element)
		var file_name: String = config["file"]
		assert_true(
			file_name.length() > 0,
			"Element %d should have non-empty file name" % element,
		)
		assert_true(
			file_name.ends_with(".png"),
			"Element %d file should be a PNG" % element,
		)
	var heal_config: Dictionary = BattleVFXScript.get_heal_config()
	assert_true(heal_config["file"].ends_with(".png"))

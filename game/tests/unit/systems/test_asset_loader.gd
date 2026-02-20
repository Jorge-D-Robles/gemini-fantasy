extends GutTest

## Tests for AssetLoader static helpers — null-guard and type-cast behavior.
## Audio files are gitignored so we test null-return for wrong/missing types
## using known-good GDScript paths as a stand-in for "wrong type" cases.

const KNOWN_SCRIPT_PATH: String = "res://systems/asset_loader.gd"
const MISSING_PATH: String = "res://nonexistent_asset_that_does_not_exist.ogg"


# -- load_sfx --

func test_load_sfx_returns_null_for_missing_path() -> void:
	var result: AudioStream = AssetLoader.load_sfx(MISSING_PATH)
	assert_null(result)


func test_load_sfx_returns_null_for_wrong_type() -> void:
	# A .gd file is a valid Resource but not an AudioStream — cast yields null.
	var result: AudioStream = AssetLoader.load_sfx(KNOWN_SCRIPT_PATH)
	assert_null(result)


# -- load_bgm --

func test_load_bgm_returns_null_for_missing_path() -> void:
	var result: AudioStream = AssetLoader.load_bgm(MISSING_PATH)
	assert_null(result)


func test_load_bgm_returns_null_for_wrong_type() -> void:
	var result: AudioStream = AssetLoader.load_bgm(KNOWN_SCRIPT_PATH)
	assert_null(result)


# -- load_texture --

func test_load_texture_returns_null_for_missing_path() -> void:
	var result: Texture2D = AssetLoader.load_texture(MISSING_PATH)
	assert_null(result)


func test_load_texture_returns_null_for_wrong_type() -> void:
	var result: Texture2D = AssetLoader.load_texture(KNOWN_SCRIPT_PATH)
	assert_null(result)


# -- load_scene --

func test_load_scene_returns_null_for_missing_path() -> void:
	var result: PackedScene = AssetLoader.load_scene(MISSING_PATH)
	assert_null(result)


func test_load_scene_returns_null_for_wrong_type() -> void:
	var result: PackedScene = AssetLoader.load_scene(KNOWN_SCRIPT_PATH)
	assert_null(result)


# -- load_resource --

func test_load_resource_returns_null_for_missing_path() -> void:
	var result: Resource = AssetLoader.load_resource(MISSING_PATH)
	assert_null(result)


func test_load_resource_returns_resource_for_valid_path() -> void:
	# asset_loader.gd is a committed GDScript resource — always present.
	var result: Resource = AssetLoader.load_resource(KNOWN_SCRIPT_PATH)
	assert_not_null(result)

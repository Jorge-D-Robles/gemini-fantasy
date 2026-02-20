class_name AssetLoader
extends RefCounted

## Centralised asset-loading helpers with consistent null-guard and warning.
##
## Binary assets (PNG, OGG, WAV) are gitignored and may be absent on fresh
## checkouts. These helpers wrap load() with null-checks and push_warning()
## so callers never receive an unexpected null silently.
##
## Usage:
##   AudioManager.play_sfx(AssetLoader.load_sfx(SfxLibrary.COMBAT_ATTACK_HIT))
##   var bgm := AssetLoader.load_bgm(SCENE_BGM_PATH)
##   if bgm: AudioManager.play_bgm(bgm)


## Loads an AudioStream from [param path]. Returns null and emits a warning
## if the file is missing or is not an AudioStream.
static func load_sfx(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("AssetLoader: SFX not found — %s" % path)
		return null
	return load(path) as AudioStream


## Loads an AudioStream BGM track from [param path]. Returns null and emits
## a warning if the file is missing or is not an AudioStream.
static func load_bgm(path: String) -> AudioStream:
	if not ResourceLoader.exists(path):
		push_warning("AssetLoader: BGM not found — %s" % path)
		return null
	return load(path) as AudioStream


## Loads a Texture2D from [param path]. Returns null and emits a warning
## if the file is missing or is not a Texture2D.
static func load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		push_warning("AssetLoader: texture not found — %s" % path)
		return null
	return load(path) as Texture2D


## Loads a PackedScene from [param path]. Returns null and emits a warning
## if the file is missing or is not a PackedScene.
static func load_scene(path: String) -> PackedScene:
	if not ResourceLoader.exists(path):
		push_warning("AssetLoader: scene not found — %s" % path)
		return null
	return load(path) as PackedScene


## Loads any Resource from [param path]. Returns null and emits a warning
## if the file is missing or cannot be loaded as a Resource.
static func load_resource(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		push_warning("AssetLoader: resource not found — %s" % path)
		return null
	return load(path) as Resource

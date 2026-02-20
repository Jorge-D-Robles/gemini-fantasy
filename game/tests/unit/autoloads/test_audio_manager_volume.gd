extends GutTest

## Tests for T-0128: AudioManager.play_bgm() should respect set_bgm_volume().
## Verifies that _bgm_volume_db field is stored and used as the fade-in target,
## so that crossfades and cold-starts preserve any player-level volume setting.

const AMScript := preload("res://autoloads/audio_manager.gd")

var _am: Node


func before_each() -> void:
	_am = AMScript.new()
	add_child_autofree(_am)


func test_set_bgm_volume_updates_stored_field() -> void:
	_am.set_bgm_volume(-20.0)
	assert_eq(
		_am._bgm_volume_db,
		-20.0,
		"set_bgm_volume should persist in _bgm_volume_db field",
	)


func test_set_bgm_volume_updates_player_immediately() -> void:
	_am.set_bgm_volume(-12.0)
	assert_eq(
		_am._bgm_player.volume_db,
		-12.0,
		"set_bgm_volume should update _bgm_player.volume_db immediately",
	)


func test_set_bgm_volume_negative_infinity_floor() -> void:
	_am.set_bgm_volume(-80.0)
	assert_eq(_am._bgm_volume_db, -80.0)


func test_set_bgm_volume_positive_value() -> void:
	_am.set_bgm_volume(3.0)
	assert_eq(_am._bgm_volume_db, 3.0)

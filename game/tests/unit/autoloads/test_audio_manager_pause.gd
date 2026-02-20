extends GutTest

## Tests for BGM-pause fix: AudioManager BGM players must have
## PROCESS_MODE_ALWAYS so music continues when the pause menu calls
## get_tree().paused = true.

const AMScript := preload("res://autoloads/audio_manager.gd")

var _am: Node


func before_each() -> void:
	_am = AMScript.new()
	add_child_autofree(_am)


func test_bgm_player_process_mode_is_always() -> void:
	assert_eq(
		_am._bgm_player.process_mode,
		Node.PROCESS_MODE_ALWAYS,
		"_bgm_player must have PROCESS_MODE_ALWAYS so BGM plays through pause",
	)


func test_bgm_fade_player_process_mode_is_always() -> void:
	assert_eq(
		_am._bgm_fade_player.process_mode,
		Node.PROCESS_MODE_ALWAYS,
		"_bgm_fade_player must have PROCESS_MODE_ALWAYS so crossfades play through pause",
	)


func test_audio_manager_itself_process_mode_is_always() -> void:
	assert_eq(
		_am.process_mode,
		Node.PROCESS_MODE_ALWAYS,
		"AudioManager node must have PROCESS_MODE_ALWAYS so tweens keep running during pause",
	)

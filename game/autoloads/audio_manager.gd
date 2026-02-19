extends Node

## Manages BGM playback with crossfade and SFX via a pool of players.

signal bgm_changed(stream: AudioStream)

const SFX_POOL_SIZE: int = 8
const DEFAULT_FADE_TIME: float = 1.0

var _bgm_player: AudioStreamPlayer
var _bgm_fade_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0


func _ready() -> void:
	_setup_bgm_players()
	_setup_sfx_pool()


func play_bgm(stream: AudioStream, fade_time: float = DEFAULT_FADE_TIME) -> void:
	if not stream:
		stop_bgm(fade_time)
		return
	if _bgm_player.stream == stream and _bgm_player.playing:
		return

	if _bgm_player.playing:
		_crossfade_bgm(stream, fade_time)
	else:
		_bgm_player.stream = stream
		_bgm_player.volume_db = 0.0
		_bgm_player.play()

	bgm_changed.emit(stream)


func stop_bgm(fade_time: float = DEFAULT_FADE_TIME) -> void:
	if not _bgm_player.playing:
		return
	var tween := create_tween()
	tween.tween_property(_bgm_player, "volume_db", -80.0, fade_time)
	tween.tween_callback(_bgm_player.stop)


func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream:
		return
	var player := _sfx_pool[_sfx_index]
	player.stream = stream
	player.volume_db = volume_db
	player.play()
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE


func get_current_bgm_path() -> String:
	if _bgm_player.stream:
		return _bgm_player.stream.resource_path
	return ""


func set_bgm_volume(volume_db: float) -> void:
	_bgm_player.volume_db = volume_db


func _crossfade_bgm(new_stream: AudioStream, fade_time: float) -> void:
	_bgm_fade_player.stream = _bgm_player.stream
	_bgm_fade_player.volume_db = _bgm_player.volume_db
	_bgm_fade_player.play(
		_bgm_player.get_playback_position()
	)

	_bgm_player.stream = new_stream
	_bgm_player.volume_db = -80.0
	_bgm_player.play()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_bgm_player, "volume_db", 0.0, fade_time)
	tween.tween_property(_bgm_fade_player, "volume_db", -80.0, fade_time)
	tween.set_parallel(false)
	tween.tween_callback(_bgm_fade_player.stop)


func _setup_bgm_players() -> void:
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	_bgm_player.bus = "BGM"
	add_child(_bgm_player)

	_bgm_fade_player = AudioStreamPlayer.new()
	_bgm_fade_player.name = "BGMFadePlayer"
	_bgm_fade_player.bus = "BGM"
	add_child(_bgm_fade_player)


func _setup_sfx_pool() -> void:
	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % i
		player.bus = "SFX"
		add_child(player)
		_sfx_pool.append(player)

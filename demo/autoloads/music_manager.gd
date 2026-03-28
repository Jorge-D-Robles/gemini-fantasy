extends Node
## Manages background music with crossfading. Autoload as MusicManager.

@onready var _player_a: AudioStreamPlayer = $PlayerA
@onready var _player_b: AudioStreamPlayer = $PlayerB

var _active_player: AudioStreamPlayer
var _current_track_path: String = ""
var _previous_track_path: String = ""
var _crossfade_duration: float = 1.0


func _ready() -> void:
	_active_player = _player_a
	_player_a.bus = "Music"
	_player_b.bus = "Music"


func play_music(track_path: String, crossfade: bool = true) -> void:
	if track_path == _current_track_path:
		return

	var stream: AudioStream = load(track_path) as AudioStream
	if not stream:
		push_error("MusicManager: failed to load " + track_path)
		return

	_current_track_path = track_path

	if crossfade and _active_player.playing:
		_crossfade_to(stream)
	else:
		_active_player.stream = stream
		_active_player.volume_db = 0.0
		_active_player.play()


func _crossfade_to(new_stream: AudioStream) -> void:
	var old_player := _active_player
	var new_player := _player_b if _active_player == _player_a else _player_a

	new_player.stream = new_stream
	new_player.volume_db = -40.0
	new_player.play()

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(old_player, "volume_db", -40.0, _crossfade_duration)
	tween.tween_property(new_player, "volume_db", 0.0, _crossfade_duration)
	tween.chain().tween_callback(old_player.stop)

	_active_player = new_player


func stop_music(fade_duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(_active_player, "volume_db", -40.0, fade_duration)
	tween.tween_callback(_active_player.stop)
	_current_track_path = ""


func remember_track() -> void:
	_previous_track_path = _current_track_path


func resume_previous_track() -> void:
	if _previous_track_path:
		play_music(_previous_track_path)

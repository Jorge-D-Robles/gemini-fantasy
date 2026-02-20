extends GutTest

## Tests for defeat_state.gd BGM path constant.
## Ensures the defeat screen plays "Game Over (For Now).mp3".

const DefeatStateScript := preload(
	"res://systems/battle/states/defeat_state.gd"
)

var _state: Node


func before_each() -> void:
	_state = DefeatStateScript.new()
	add_child_autofree(_state)


func test_defeat_bgm_path_constant_exists() -> void:
	assert_true(
		_state.get("DEFEAT_BGM_PATH") != null,
		"defeat_state must declare DEFEAT_BGM_PATH",
	)


func test_defeat_bgm_path_points_to_game_over_track() -> void:
	assert_eq(
		_state.DEFEAT_BGM_PATH,
		"res://assets/music/Game Over (For Now).ogg",
		"DEFEAT_BGM_PATH should reference 'Game Over (For Now).mp3'",
	)

extends GutTest

## Tests for victory_state.gd level-up BGM path constant.
## Ensures the level-up jingle plays when characters level up.

const VictoryStateScript := preload(
	"res://systems/battle/states/victory_state.gd"
)

var _state: Node


func before_each() -> void:
	_state = VictoryStateScript.new()
	add_child_autofree(_state)


func test_level_up_bgm_path_constant_exists() -> void:
	assert_true(
		_state.get("LEVEL_UP_BGM_PATH") != null,
		"victory_state must declare LEVEL_UP_BGM_PATH for the level-up jingle",
	)


func test_level_up_bgm_path_points_to_level_up_track() -> void:
	assert_eq(
		_state.LEVEL_UP_BGM_PATH,
		"res://assets/music/Level Up.ogg",
		"LEVEL_UP_BGM_PATH should reference 'Level Up.mp3'",
	)

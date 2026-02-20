extends GutTest

## Tests for T-0140: AudioManager SFX priority channels.
## Tests the pure static compute_sfx_player_index() helper and the
## SfxPriority enum values. All tests run without audio hardware.

const AMScript := preload("res://autoloads/audio_manager.gd")

var _am: Node


func before_each() -> void:
	_am = AMScript.new()
	add_child_autofree(_am)


# ---------- Enum values ----------

func test_sfx_priority_critical_is_zero() -> void:
	assert_eq(
		_am.SfxPriority.CRITICAL,
		0,
		"SfxPriority.CRITICAL should be 0",
	)


func test_sfx_priority_normal_is_one() -> void:
	assert_eq(
		_am.SfxPriority.NORMAL,
		1,
		"SfxPriority.NORMAL should be 1",
	)


func test_sfx_priority_ambient_is_two() -> void:
	assert_eq(
		_am.SfxPriority.AMBIENT,
		2,
		"SfxPriority.AMBIENT should be 2",
	)


# ---------- NORMAL priority (round-robin, always claims current_index) ----------

func test_compute_normal_returns_current_index_when_all_free() -> void:
	var busy: Array[bool] = [false, false, false, false]
	var idx: int = AMScript.compute_sfx_player_index(4, 2, busy, AMScript.SfxPriority.NORMAL)
	assert_eq(idx, 2, "NORMAL priority should return current_index regardless")


func test_compute_normal_returns_current_index_when_all_busy() -> void:
	var busy: Array[bool] = [true, true, true, true]
	var idx: int = AMScript.compute_sfx_player_index(4, 0, busy, AMScript.SfxPriority.NORMAL)
	assert_eq(idx, 0, "NORMAL priority always returns current_index even when all busy")


# ---------- AMBIENT priority (skip if all busy) ----------

func test_compute_ambient_returns_first_free_player() -> void:
	var busy: Array[bool] = [true, true, false, true]
	var idx: int = AMScript.compute_sfx_player_index(4, 0, busy, AMScript.SfxPriority.AMBIENT)
	assert_eq(idx, 2, "AMBIENT priority should return index of first free player")


func test_compute_ambient_returns_minus_one_when_all_busy() -> void:
	var busy: Array[bool] = [true, true, true, true]
	var idx: int = AMScript.compute_sfx_player_index(4, 0, busy, AMScript.SfxPriority.AMBIENT)
	assert_eq(idx, -1, "AMBIENT priority should return -1 when all players are busy")


func test_compute_ambient_returns_zero_when_first_slot_free() -> void:
	var busy: Array[bool] = [false, true, true, true]
	var idx: int = AMScript.compute_sfx_player_index(4, 3, busy, AMScript.SfxPriority.AMBIENT)
	assert_eq(idx, 0, "AMBIENT priority should find slot 0 even when current_index is 3")


# ---------- CRITICAL priority (prefer free player, fall back to round-robin) ----------

func test_compute_critical_returns_first_free_player() -> void:
	var busy: Array[bool] = [true, false, true, true]
	var idx: int = AMScript.compute_sfx_player_index(4, 0, busy, AMScript.SfxPriority.CRITICAL)
	assert_eq(idx, 1, "CRITICAL priority should return first free player index")


func test_compute_critical_falls_back_to_round_robin_when_all_busy() -> void:
	var busy: Array[bool] = [true, true, true, true]
	var idx: int = AMScript.compute_sfx_player_index(4, 2, busy, AMScript.SfxPriority.CRITICAL)
	assert_eq(idx, 2, "CRITICAL priority falls back to current_index when all players are busy")


func test_compute_critical_never_returns_minus_one() -> void:
	var busy: Array[bool] = [true, true, true, true]
	var idx: int = AMScript.compute_sfx_player_index(4, 0, busy, AMScript.SfxPriority.CRITICAL)
	assert_true(idx >= 0, "CRITICAL priority must never return -1 — always plays")

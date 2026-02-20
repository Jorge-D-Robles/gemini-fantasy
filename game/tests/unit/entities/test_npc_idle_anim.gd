extends GutTest

## Tests for T-0100: NPC idle animations (breathing + head turn).
## Verifies constants and method existence only.
## Tween behavior is verified visually via /scene-preview.

const NPCScript = preload("res://entities/npc/npc.gd")


# -- Constants --


func test_breathe_scale_delta_is_positive() -> void:
	assert_true(
		NPCScript.BREATHE_SCALE_DELTA > 0.0,
		"BREATHE_SCALE_DELTA must be a positive scale offset",
	)


func test_breathe_scale_delta_is_subtle() -> void:
	assert_true(
		NPCScript.BREATHE_SCALE_DELTA < 0.1,
		"BREATHE_SCALE_DELTA should be subtle (< 0.1) to avoid cartoonish scaling",
	)


func test_breathe_half_duration_is_positive() -> void:
	assert_true(
		NPCScript.BREATHE_HALF_DURATION > 0.0,
		"BREATHE_HALF_DURATION must be a positive seconds value",
	)


func test_head_turn_min_interval_is_positive() -> void:
	assert_true(
		NPCScript.HEAD_TURN_MIN_INTERVAL > 0.0,
		"HEAD_TURN_MIN_INTERVAL must be positive",
	)


func test_head_turn_max_exceeds_min() -> void:
	assert_true(
		NPCScript.HEAD_TURN_MAX_INTERVAL > NPCScript.HEAD_TURN_MIN_INTERVAL,
		"HEAD_TURN_MAX_INTERVAL must be greater than MIN to allow random range",
	)


# -- Method existence (no scene tree required) --


func test_npc_has_start_idle_animation() -> void:
	var inst := NPCScript.new()
	assert_true(
		inst.has_method("start_idle_animation"),
		"NPC must have start_idle_animation()",
	)
	inst.free()


func test_npc_has_stop_idle_animation() -> void:
	var inst := NPCScript.new()
	assert_true(
		inst.has_method("stop_idle_animation"),
		"NPC must have stop_idle_animation()",
	)
	inst.free()


func test_stop_idle_animation_clears_idle_running_flag() -> void:
	var inst := NPCScript.new()
	inst.stop_idle_animation()
	assert_false(
		inst._idle_running,
		"stop_idle_animation() must clear _idle_running so head turn loop stops",
	)
	inst.free()

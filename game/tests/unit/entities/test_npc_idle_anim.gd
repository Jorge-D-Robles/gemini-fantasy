extends GutTest

## Tests for NPC idle animations — behavioral state test.
## Constant and method existence checks removed; tween behavior is
## verified visually via /scene-preview.

const NPCScript = preload("res://entities/npc/npc.gd")


func test_stop_idle_animation_clears_idle_running_flag() -> void:
	var inst := NPCScript.new()
	inst.stop_idle_animation()
	assert_false(
		inst._idle_running,
		"stop_idle_animation() must clear _idle_running so head turn loop stops",
	)
	inst.free()

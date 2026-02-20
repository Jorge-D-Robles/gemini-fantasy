class_name BattleShake
extends RefCounted

## Static helpers for screen-shake on heavy damage.
##
## Pure logic helpers (is_heavy_hit, compute_intensity) are fully testable
## without a scene tree. The shake() method drives a Tween on the given Node2D
## and is fire-and-forget — callers do not need to await it.


const HEAVY_HIT_THRESHOLD: float = 0.25
const SHAKE_INTENSITY_BASE: float = 3.0
const SHAKE_INTENSITY_MAX: float = 7.0
const SHAKE_DURATION: float = 0.35


## Returns true when [param damage] is at or above 25 % of [param max_hp].
static func is_heavy_hit(damage: int, max_hp: int) -> bool:
	if max_hp <= 0:
		return false
	return float(damage) / float(max_hp) >= HEAVY_HIT_THRESHOLD


## Returns the shake amplitude in pixels, linearly scaled from
## SHAKE_INTENSITY_BASE (at threshold) to SHAKE_INTENSITY_MAX (at full damage).
## Sub-threshold damage is clamped to SHAKE_INTENSITY_BASE; max_hp == 0 returns 0.
static func compute_intensity(damage: int, max_hp: int) -> float:
	if max_hp <= 0:
		return 0.0
	var ratio := float(damage) / float(max_hp)
	return clampf(
		lerp(
			SHAKE_INTENSITY_BASE,
			SHAKE_INTENSITY_MAX,
			(ratio - HEAVY_HIT_THRESHOLD) / (1.0 - HEAVY_HIT_THRESHOLD),
		),
		SHAKE_INTENSITY_BASE,
		SHAKE_INTENSITY_MAX,
	)


## Shakes [param node] by tweening its position through decaying random offsets,
## then restoring the original position. Fire-and-forget — do not await.
static func shake(node: Node2D, intensity: float, duration: float) -> void:
	if not is_instance_valid(node):
		return
	var original_pos := node.position
	var tween := node.create_tween()
	const STEPS: int = 6
	var step_time := duration / (STEPS + 1)
	for i in STEPS:
		var decay := 1.0 - float(i) / STEPS
		tween.tween_property(
			node,
			"position",
			original_pos + Vector2(
				randf_range(-intensity, intensity) * decay,
				randf_range(-intensity, intensity) * decay,
			),
			step_time,
		).set_trans(Tween.TRANS_SINE)
	tween.tween_property(
		node, "position", original_pos, step_time,
	).set_trans(Tween.TRANS_SINE)

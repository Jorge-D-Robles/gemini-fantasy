class_name BattleParticles
extends RefCounted

## Static visual feedback helpers for resonance state transitions and
## critical hit flashes. All functions are static: pure logic, no scene
## dependency. Scene-level flash calls use the returned Color/duration values.


## Returns the sprite tint color for a given resonance state transition.
## RESONANT → warm gold; OVERLOAD → warning red; others → no tint (WHITE).
static func compute_resonance_flash_color(
	state: Battler.ResonanceState,
) -> Color:
	match state:
		Battler.ResonanceState.RESONANT:
			return Color(1.0, 0.9, 0.3, 1.0)
		Battler.ResonanceState.OVERLOAD:
			return Color(1.0, 0.25, 0.15, 1.0)
		_:
			return Color.WHITE


## Returns true when crossing into RESONANT or OVERLOAD.
## Dropping back to FOCUSED/HOLLOW uses other visual cues and does not flash.
static func should_show_resonance_flash(
	old_state: Battler.ResonanceState,
	new_state: Battler.ResonanceState,
) -> bool:
	if old_state == new_state:
		return false
	return new_state == Battler.ResonanceState.RESONANT \
		or new_state == Battler.ResonanceState.OVERLOAD


## Returns the scene-wide flash tint for a critical hit — bright gold-white.
static func compute_crit_flash_color() -> Color:
	return Color(1.0, 0.95, 0.6, 1.0)


## Returns the total duration of the critical-hit flash in seconds.
static func compute_crit_flash_duration() -> float:
	return 0.18

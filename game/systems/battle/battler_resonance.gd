class_name BattlerResonance
extends RefCounted

## Static resonance gauge and state transition utilities extracted from Battler.
## All resonance_state params use int values matching Battler.ResonanceState:
## 0=FOCUSED, 1=RESONANT, 2=OVERLOAD, 3=HOLLOW

const GB = preload("res://systems/game_balance.gd")

# ResonanceState int constants (avoid circular preload of battler.gd)
const _FOCUSED: int = 0
const _RESONANT: int = 1
const _OVERLOAD: int = 2
const _HOLLOW: int = 3


## Adds amount to gauge and clamps to [0, RESONANCE_MAX].
static func add_to_gauge(current: float, amount: float) -> float:
	return clampf(current + amount, 0.0, GB.RESONANCE_MAX)


## Evaluates which resonance state the gauge value maps to.
## HOLLOW state is sticky — it never transitions out via gauge alone.
static func evaluate_state(gauge: float, current_state: int) -> int:
	if current_state == _HOLLOW:
		return _HOLLOW

	if gauge >= GB.RESONANCE_OVERLOAD_THRESHOLD:
		return _OVERLOAD
	if gauge >= GB.RESONANCE_RESONANT_THRESHOLD:
		return _RESONANT
	return _FOCUSED


## Returns the resonance transition result when a battler is defeated.
## If in OVERLOAD, transitions to HOLLOW with gauge reset.
## Returns {state: int, gauge: float, changed: bool}.
static func on_defeated(resonance_state: int) -> Dictionary:
	if resonance_state == _OVERLOAD:
		return {"state": _HOLLOW, "gauge": 0.0, "changed": true}
	return {"state": resonance_state, "gauge": 0.0, "changed": false}


## Calculates turn delay from speed, with Hollow penalty applied.
static func calculate_turn_delay(
	p_speed: int, resonance_state: int,
) -> float:
	var effective_speed := p_speed
	if resonance_state == _HOLLOW:
		effective_speed = int(p_speed * GB.HOLLOW_STAT_PENALTY)
	if effective_speed > 0:
		return GB.TURN_DELAY_BASE / float(effective_speed)
	return GB.TURN_DELAY_BASE

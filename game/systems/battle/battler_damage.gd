class_name BattlerDamage
extends RefCounted

## Static damage calculation utilities extracted from Battler.
## All resonance_state params use int values matching Battler.ResonanceState:
## 0=FOCUSED, 1=RESONANT, 2=OVERLOAD, 3=HOLLOW

const GB = preload("res://systems/game_balance.gd")

# ResonanceState int constants (avoid circular preload of battler.gd)
const _RESONANT: int = 1
const _OVERLOAD: int = 2
const _HOLLOW: int = 3


## Calculates outgoing damage with stat bonus and resonance modifiers.
## Does NOT include resonance gain — caller handles that.
static func calculate_outgoing(
	base: int,
	stat_value: int,
	resonance_state: int,
	is_ability: bool,
) -> int:
	var effective_stat := stat_value
	if resonance_state == _HOLLOW:
		effective_stat = int(stat_value * GB.HOLLOW_STAT_PENALTY)

	var stat_bonus := effective_stat * GB.STAT_DAMAGE_SCALING
	var total := int(base + stat_bonus)

	if resonance_state == _OVERLOAD:
		total = int(total * GB.OVERLOAD_OUTGOING_DAMAGE_MULT)
	elif resonance_state == _RESONANT and is_ability:
		total = int(total * GB.RESONANT_ABILITY_BONUS)

	return total


## Calculates incoming damage after defense, defend stance, and resonance.
static func calculate_incoming(
	base: int,
	def_stat: int,
	resonance_state: int,
	is_defending: bool,
) -> int:
	var effective_def := def_stat
	if resonance_state == _HOLLOW:
		effective_def = int(def_stat * GB.HOLLOW_STAT_PENALTY)

	var defense_mod := 1.0 - (effective_def / GB.DEFENSE_SCALING_DIVISOR)
	defense_mod = clampf(defense_mod, GB.DEFENSE_MOD_MIN, 1.0)

	if is_defending:
		defense_mod *= GB.DEFEND_DAMAGE_REDUCTION

	if resonance_state == _OVERLOAD:
		defense_mod *= GB.OVERLOAD_INCOMING_DAMAGE_MULT

	return maxi(int(base * defense_mod), 1)

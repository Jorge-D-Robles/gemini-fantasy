class_name SfxLibrary
extends RefCounted

## Centralized SFX asset path constants.
## Usage: AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))

# UI SFX
const UI_CONFIRM: String = "res://assets/sfx/ui/confirm.ogg"
const UI_CANCEL: String = "res://assets/sfx/ui/cancel.ogg"
const UI_MENU_OPEN: String = "res://assets/sfx/ui/menu_open.ogg"
const UI_DIALOGUE_ADVANCE: String = (
	"res://assets/sfx/ui/dialogue_advance.ogg"
)

# Combat SFX
const COMBAT_ATTACK_HIT: String = (
	"res://assets/sfx/combat/attack_hit.ogg"
)
const COMBAT_MAGIC_CAST: String = (
	"res://assets/sfx/combat/magic_cast.ogg"
)
const COMBAT_HEAL_CHIME: String = (
	"res://assets/sfx/combat/heal_chime.ogg"
)
const COMBAT_DEATH: String = "res://assets/sfx/combat/death.ogg"
const COMBAT_CRITICAL_HIT: String = (
	"res://assets/sfx/combat/critical_hit.ogg"
)
const COMBAT_STATUS_APPLY: String = (
	"res://assets/sfx/combat/status_apply.ogg"
)

# Aggregate arrays
const ALL_UI_PATHS: Array[String] = [
	UI_CONFIRM,
	UI_CANCEL,
	UI_MENU_OPEN,
	UI_DIALOGUE_ADVANCE,
]
const ALL_COMBAT_PATHS: Array[String] = [
	COMBAT_ATTACK_HIT,
	COMBAT_MAGIC_CAST,
	COMBAT_HEAL_CHIME,
	COMBAT_DEATH,
	COMBAT_CRITICAL_HIT,
	COMBAT_STATUS_APPLY,
]
const ALL_PATHS: Array[String] = [
	UI_CONFIRM,
	UI_CANCEL,
	UI_MENU_OPEN,
	UI_DIALOGUE_ADVANCE,
	COMBAT_ATTACK_HIT,
	COMBAT_MAGIC_CAST,
	COMBAT_HEAL_CHIME,
	COMBAT_DEATH,
	COMBAT_CRITICAL_HIT,
	COMBAT_STATUS_APPLY,
]

## SFX paths that must always play regardless of pool state.
## Use AudioManager.SfxPriority.CRITICAL for these.
const CRITICAL_PRIORITY_PATHS: Array[String] = [
	COMBAT_DEATH,
	COMBAT_CRITICAL_HIT,
]


static func compute_sfx_priority(sfx_path: String) -> int:
	## Returns the AudioManager.SfxPriority value for the given SFX path.
	## CRITICAL (0): death and critical hit sounds always play.
	## NORMAL (1): all other sounds use round-robin pool.
	if sfx_path in CRITICAL_PRIORITY_PATHS:
		return 0  # AudioManager.SfxPriority.CRITICAL
	return 1  # AudioManager.SfxPriority.NORMAL

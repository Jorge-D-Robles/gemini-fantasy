extends RefCounted

## Shared UI color palette and theme constants.
## Import via: const UITheme = preload("res://ui/ui_theme.gd")

# ---- Battle log message types ----
enum LogType {
	INFO = 0,
	DAMAGE = 1,
	HEAL = 2,
	STATUS = 3,
	SYSTEM = 4,
	VICTORY = 5,
	DEFEAT = 6,
}

# ---- Panel colors ----
const PANEL_BG := Color(0.12, 0.07, 0.22, 0.85)
const PANEL_INNER_BG := Color(0.08, 0.05, 0.15, 0.9)
const PANEL_BORDER := Color(0.45, 0.35, 0.65, 0.6)
const PANEL_HOVER := Color(0.18, 0.12, 0.32, 0.9)

# ---- Battle panel (slightly different tint) ----
const BATTLE_PANEL_BG := Color(0.08, 0.08, 0.15, 0.9)
const BATTLE_PANEL_BORDER := Color(0.35, 0.35, 0.5, 1.0)

# ---- Text colors ----
const TEXT_PRIMARY := Color(0.85, 0.75, 1.0)
const TEXT_SECONDARY := Color(0.6, 0.55, 0.7)
const TEXT_DISABLED := Color(0.4, 0.35, 0.5)
const TEXT_GOLD := Color(0.85, 0.75, 0.45)

# ---- Accent colors ----
const ACCENT_GOLD := Color(0.85, 0.75, 0.45, 0.8)
const ACTIVE_HIGHLIGHT := Color(1.0, 0.9, 0.5)

# ---- Bar colors ----
const HP_BAR_COLOR := Color(0.2, 0.8, 0.3)
const HP_BAR_LOW_COLOR := Color(0.9, 0.3, 0.2)
const HP_LOW_THRESHOLD: float = 0.25
const EE_BAR_COLOR := Color(0.3, 0.5, 0.9)

# ---- Stat comparison ----
const TEXT_POSITIVE := Color(0.4, 0.85, 0.4)
const TEXT_NEGATIVE := Color(0.85, 0.4, 0.4)

# ---- Overlay ----
const DIM_COLOR := Color(0, 0, 0, 0.6)

# ---- Battle log colors ----
const LOG_INFO := Color(0.8, 0.75, 0.9)
const LOG_DAMAGE := Color(0.95, 0.4, 0.35)
const LOG_HEAL := Color(0.4, 0.9, 0.45)
const LOG_STATUS := Color(0.7, 0.55, 0.95)
const LOG_SYSTEM := Color(0.95, 0.75, 0.3)
const LOG_VICTORY := Color(0.95, 0.85, 0.3)
const LOG_DEFEAT := Color(0.85, 0.15, 0.15)

# ---- Damage popup colors ----
const POPUP_CRITICAL := Color(1.0, 0.85, 0.2)

# ---- Status effect colors ----
const STATUS_BUFF := Color(0.4, 0.85, 0.4)
const STATUS_DEBUFF := Color(0.85, 0.4, 0.4)
const STATUS_DOT := Color(0.95, 0.6, 0.2)
const STATUS_HOT := Color(0.3, 0.9, 0.8)
const STATUS_STUN := Color(0.95, 0.75, 0.3)

const LOG_COLORS: Dictionary = {
	LogType.INFO: LOG_INFO,
	LogType.DAMAGE: LOG_DAMAGE,
	LogType.HEAL: LOG_HEAL,
	LogType.STATUS: LOG_STATUS,
	LogType.SYSTEM: LOG_SYSTEM,
	LogType.VICTORY: LOG_VICTORY,
	LogType.DEFEAT: LOG_DEFEAT,
}

const STATUS_COLORS: Dictionary = {
	0: STATUS_BUFF,   # StatusEffectData.EffectType.BUFF
	1: STATUS_DEBUFF, # StatusEffectData.EffectType.DEBUFF
	2: STATUS_DOT,    # StatusEffectData.EffectType.DAMAGE_OVER_TIME
	3: STATUS_HOT,    # StatusEffectData.EffectType.HEAL_OVER_TIME
	4: STATUS_STUN,   # StatusEffectData.EffectType.STUN
}


static func get_log_color(log_type: int) -> Color:
	return LOG_COLORS.get(log_type, Color(0.8, 0.75, 0.9))


## Returns color for a StatusEffectData.EffectType int value.
static func get_status_color(effect_type: int) -> Color:
	return STATUS_COLORS.get(effect_type, LOG_STATUS)

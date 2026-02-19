extends RefCounted

## Shared UI color palette and theme constants.
## Import via: const UITheme = preload("res://ui/ui_theme.gd")

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

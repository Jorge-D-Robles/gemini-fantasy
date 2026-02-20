class_name BattleUIStatus
extends RefCounted

## Static UI computation utilities for party status and targeting.
## No instance state — all methods are static. Do not instantiate.

const UITheme = preload("res://ui/ui_theme.gd")


## Returns a one-element array [{text: "DEF", color: DEFEND_BADGE_COLOR}]
## when [param is_defending] is true, otherwise an empty array.
static func compute_defend_badge(is_defending: bool) -> Array[Dictionary]:
	if not is_defending:
		return []
	return [{"text": "DEF", "color": UITheme.DEFEND_BADGE_COLOR}]


## Returns [{text: String, color: Color}, ...] for each active
## status effect.
static func compute_status_badges(
	effects: Array[StatusEffectData],
) -> Array[Dictionary]:
	var badges: Array[Dictionary] = []
	for eff: StatusEffectData in effects:
		badges.append({
			"text": String(eff.id).left(2).to_upper(),
			"color": UITheme.get_status_color(eff.effect_type),
		})
	return badges


## Returns {name: String, color: Color, is_enemy: bool} for a
## target battler.
static func compute_target_info(battler: Node) -> Dictionary:
	if not is_instance_valid(battler):
		return {
			"name": "???",
			"color": Color.WHITE,
			"is_enemy": true,
		}
	var display_name := "???"
	if battler.has_method("get_display_name"):
		display_name = battler.get_display_name()
	var is_enemy: bool = not (battler is PartyBattler)
	var highlight := UITheme.TARGET_HIGHLIGHT_ENEMY
	if not is_enemy:
		highlight = UITheme.TARGET_HIGHLIGHT_PARTY
	return {
		"name": display_name,
		"color": highlight,
		"is_enemy": is_enemy,
	}

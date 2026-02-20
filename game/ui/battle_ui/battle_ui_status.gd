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


## Returns an ordered list of display entries for the turn order bar.
## Each entry: {text: String, color: Color, is_active: bool, is_separator: bool}.
## The [param active_battler] is shown first in "[Name]" brackets with ACTIVE_HIGHLIGHT.
## [param queue] is the upcoming battlers from TurnQueue.peek_order().
static func compute_turn_order_entries(
	active_battler: Node,
	queue: Array,
) -> Array[Dictionary]:
	const PARTY_COLOR := Color(0.7, 0.85, 1.0)
	const ENEMY_COLOR := Color(1.0, 0.5, 0.5)
	const SEP_COLOR := Color(0.4, 0.4, 0.5)
	var entries: Array[Dictionary] = []

	if (
		is_instance_valid(active_battler)
		and active_battler.has_method("get_display_name")
		and "is_alive" in active_battler and active_battler.is_alive
	):
		entries.append({
			"text": "[%s]" % active_battler.get_display_name().left(4),
			"color": UITheme.ACTIVE_HIGHLIGHT,
			"is_active": true,
			"is_separator": false,
		})

	for battler: Node in queue:
		if not entries.is_empty():
			entries.append({
				"text": ">",
				"color": SEP_COLOR,
				"is_active": false,
				"is_separator": true,
			})
		var color: Color = ENEMY_COLOR
		if battler is PartyBattler:
			color = PARTY_COLOR
		var display: String = ""
		if battler.has_method("get_display_name"):
			display = battler.get_display_name().left(4)
		entries.append({
			"text": display,
			"color": color,
			"is_active": false,
			"is_separator": false,
		})

	return entries


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

class_name BattleUILog
extends RefCounted

## Static formatting helpers for the battle log.
## No instance state — all methods are static. Do not instantiate.

const UITheme = preload("res://ui/ui_theme.gd")


## Returns the BBCode-formatted string for a single battle log entry.
## The entry ends with a newline so successive calls to append_text()
## produce separate lines.
static func compute_log_entry(
	text: String,
	log_type: int = UITheme.LogType.INFO,
) -> String:
	var color: Color = UITheme.get_log_color(log_type)
	var hex := color.to_html(false)
	return "[color=#%s]%s[/color]\n" % [hex, text]

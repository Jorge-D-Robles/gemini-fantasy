extends RefCounted

## Shared UI utility functions used across all UI screens.
## Import via: const UIHelpers = preload("res://ui/ui_helpers.gd")

const UITheme = preload("res://ui/ui_theme.gd")


## Removes and frees all children of [param parent].
static func clear_children(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()


## Wires focus neighbors with wrapping for a list of controls.
## Set [param horizontal] to true for left/right instead of top/bottom.
static func setup_focus_wrap(
	controls: Array,
	horizontal: bool = false,
) -> void:
	if controls.size() < 2:
		return
	for i in controls.size():
		var prev_prop: String
		var next_prop: String
		if horizontal:
			prev_prop = "focus_neighbor_left"
			next_prop = "focus_neighbor_right"
		else:
			prev_prop = "focus_neighbor_top"
			next_prop = "focus_neighbor_bottom"
		if i > 0:
			controls[i].set(prev_prop, controls[i - 1].get_path())
		if i < controls.size() - 1:
			controls[i].set(next_prop, controls[i + 1].get_path())
	# Wrap first <-> last
	var first: Control = controls[0]
	var last: Control = controls[-1]
	if horizontal:
		first.focus_neighbor_left = last.get_path()
		last.focus_neighbor_right = first.get_path()
	else:
		first.focus_neighbor_top = last.get_path()
		last.focus_neighbor_bottom = first.get_path()


## Creates a styled [StyleBoxFlat] panel with consistent border and radius.
static func create_panel_style(
	bg: Color = UITheme.PANEL_BG,
	border: Color = UITheme.PANEL_BORDER,
	border_width: int = 2,
	corner_radius: int = 3,
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	return style

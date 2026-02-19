extends Control

## Demo end screen — "Thanks for Playing!" with party lineup and
## return-to-title button. Built entirely in _ready() via code.

const SP = preload("res://systems/scene_paths.gd")
const UITheme = preload("res://ui/ui_theme.gd")


static func compute_party_summary(
	roster: Array[Resource],
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for member: Resource in roster:
		var char_data := member as CharacterData
		if char_data:
			result.append({
				"name": char_data.display_name,
				"level": char_data.level,
			})
	return result


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# Full-screen black background
	var bg := ColorRect.new()
	bg.color = Color(0.02, 0.01, 0.05, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Centered content container
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var content := VBoxContainer.new()
	content.add_theme_constant_override(
		"separation", 16,
	)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(content)

	# Title
	var title := Label.new()
	title.text = "Thanks for Playing!"
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override(
		"font_color", UITheme.TEXT_PRIMARY,
	)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)

	# Subtitle
	var subtitle := Label.new()
	subtitle.text = "Gemini Fantasy \u2014 Demo"
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override(
		"font_color", UITheme.TEXT_SECONDARY,
	)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(subtitle)

	# Spacer
	var spacer_top := Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 16)
	content.add_child(spacer_top)

	# Party lineup
	var party_list := VBoxContainer.new()
	party_list.add_theme_constant_override("separation", 8)
	content.add_child(party_list)

	var roster: Array[Resource] = []
	for member: Resource in PartyManager.get_roster():
		roster.append(member)
	var summary: Array[Dictionary] = compute_party_summary(
		roster,
	)
	for entry: Dictionary in summary:
		var member_label := Label.new()
		member_label.text = "%s  —  Lv. %d" % [
			entry["name"], entry["level"],
		]
		member_label.add_theme_font_size_override(
			"font_size", 14,
		)
		member_label.add_theme_color_override(
			"font_color", UITheme.ACCENT_GOLD,
		)
		member_label.horizontal_alignment = (
			HORIZONTAL_ALIGNMENT_CENTER
		)
		party_list.add_child(member_label)

	# Spacer
	var spacer_bottom := Control.new()
	spacer_bottom.custom_minimum_size = Vector2(0, 24)
	content.add_child(spacer_bottom)

	# Return to title button
	var button := Button.new()
	button.text = "Return to Title"
	button.add_theme_font_size_override("font_size", 14)
	button.custom_minimum_size = Vector2(200, 40)
	button.pressed.connect(_on_return_pressed)
	content.add_child(button)
	button.grab_focus()


func _on_return_pressed() -> void:
	GameManager.change_scene(SP.TITLE_SCREEN)

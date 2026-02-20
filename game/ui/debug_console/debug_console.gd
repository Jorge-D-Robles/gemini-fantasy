extends CanvasLayer

## Dev-only debug console. Toggle with backtick (`) key.
## Disabled automatically in export builds via OS.is_debug_build() guard in UILayer.
## Commands: heal_all, set_level, add_item, teleport, set_flag

const DebugCommandsScript := preload(
	"res://ui/debug_console/debug_commands.gd"
)
const UITheme = preload("res://ui/ui_theme.gd")

var _input_line: LineEdit
var _output_label: Label
var _panel: Panel


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.physical_keycode == KEY_QUOTELEFT and key_event.is_pressed():
			_toggle()
			get_viewport().set_input_as_handled()


func _toggle() -> void:
	visible = not visible
	if visible and _input_line:
		_input_line.grab_focus()
		_input_line.select_all()


func _on_command_submitted(text: String) -> void:
	if _input_line:
		_input_line.text = ""
	var result := DebugCommandsScript.compute_debug_command_result(text)
	_show_output(result["message"] as String, result["ok"] as bool)
	DebugCommandsScript.execute_command(result, self)


func _show_output(message: String, success: bool) -> void:
	if not _output_label:
		return
	_output_label.text = message
	_output_label.add_theme_color_override(
		"font_color",
		UITheme.TEXT_GOLD if success else Color(1.0, 0.4, 0.4, 1.0),
	)


func _build_ui() -> void:
	_panel = Panel.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_panel.custom_minimum_size = Vector2(0, 60)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.9)
	style.border_color = UITheme.ACCENT_GOLD
	style.set_border_width_all(1)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 2)
	var margin := 6
	vbox.set_offset(SIDE_LEFT, margin)
	vbox.set_offset(SIDE_TOP, margin)
	vbox.set_offset(SIDE_RIGHT, -margin)
	vbox.set_offset(SIDE_BOTTOM, -margin)
	_panel.add_child(vbox)

	var header := Label.new()
	header.text = "[ Debug Console — ` to close ]"
	header.add_theme_font_size_override("font_size", 9)
	header.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	vbox.add_child(header)

	_input_line = LineEdit.new()
	_input_line.placeholder_text = "Enter command..."
	_input_line.add_theme_font_size_override("font_size", 11)
	_input_line.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	_input_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_input_line.text_submitted.connect(_on_command_submitted)
	vbox.add_child(_input_line)

	_output_label = Label.new()
	_output_label.add_theme_font_size_override("font_size", 9)
	_output_label.add_theme_color_override("font_color", UITheme.TEXT_SECONDARY)
	vbox.add_child(_output_label)

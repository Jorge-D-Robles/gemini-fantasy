extends CanvasLayer
## Displays dialogue with a typewriter effect and optional choices.

signal dialogue_started
signal dialogue_finished
signal line_advanced
signal choice_made(choice_index: int)

@export var characters_per_second: float = 30.0

var _lines: Array[DialogueLine] = []
var _current_line_index: int = 0
var _is_typing: bool = false
var _current_tween: Tween = null

@onready var _panel: PanelContainer = $PanelContainer
@onready var _speaker_label: Label = $PanelContainer/MarginContainer/VBoxContainer/SpeakerLabel
@onready var _text_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/TextLabel
@onready var _choice_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ChoiceContainer


func _ready() -> void:
	_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if _is_typing:
			_skip_typing()
		else:
			_advance()


func start_dialogue(lines: Array[DialogueLine]) -> void:
	if lines.is_empty():
		return
	_lines = lines
	_current_line_index = 0
	_panel.visible = true
	dialogue_started.emit()
	_show_current_line()


func _show_current_line() -> void:
	var line: DialogueLine = _lines[_current_line_index]
	_speaker_label.text = line.speaker_name
	_speaker_label.visible = line.speaker_name != ""
	_text_label.text = line.text
	_text_label.visible_ratio = 0.0
	for child in _choice_container.get_children():
		child.queue_free()
	_choice_container.visible = false
	_start_typing()


func _start_typing() -> void:
	_is_typing = true
	var char_count: int = _text_label.get_total_character_count()
	var duration: float = char_count / characters_per_second
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_current_tween = create_tween()
	_current_tween.tween_property(_text_label, "visible_ratio", 1.0, duration)
	_current_tween.finished.connect(_on_typing_finished)


func _skip_typing() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_text_label.visible_ratio = 1.0
	_is_typing = false


func _on_typing_finished() -> void:
	_is_typing = false


func _advance() -> void:
	var current_line: DialogueLine = _lines[_current_line_index]
	if not current_line.choices.is_empty() and _choice_container.get_child_count() == 0:
		_show_choices(current_line.choices)
		return
	_current_line_index += 1
	line_advanced.emit()
	if _current_line_index >= _lines.size():
		_close()
	else:
		_show_current_line()


func _show_choices(choices: Array[String]) -> void:
	_choice_container.visible = true
	for i in choices.size():
		var button := Button.new()
		button.text = choices[i]
		button.pressed.connect(_on_choice_pressed.bind(i))
		_choice_container.add_child(button)
	await get_tree().process_frame
	if _choice_container.get_child_count() > 0:
		_choice_container.get_child(0).grab_focus()


func _on_choice_pressed(index: int) -> void:
	choice_made.emit(index)
	_choice_container.visible = false
	for child in _choice_container.get_children():
		child.queue_free()
	_current_line_index += 1
	if _current_line_index >= _lines.size():
		_close()
	else:
		_show_current_line()


func _close() -> void:
	_panel.visible = false
	_lines.clear()
	_current_line_index = 0
	dialogue_finished.emit()

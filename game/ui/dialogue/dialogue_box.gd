extends CanvasLayer

## Enhanced dialogue box with typewriter, portraits, choices,
## and slide animation. Responds to DialogueManager signals.

signal dialogue_line_finished
signal dialogue_complete

const UIHelpers = preload("res://ui/ui_helpers.gd")
const CHARS_PER_SECOND: float = 30.0
const SLIDE_DURATION: float = 0.2

var _is_typing: bool = false
var _current_tween: Tween = null
var _choice_buttons: Array[Button] = []

@onready var _panel: PanelContainer = $Panel
@onready var _portrait: TextureRect = %Portrait
@onready var _speaker_name: Label = %SpeakerName
@onready var _dialogue_text: RichTextLabel = %DialogueText
@onready var _advance_indicator: Label = %AdvanceIndicator
@onready var _choices_container: VBoxContainer = %ChoicesContainer


func _ready() -> void:
	_panel.visible = false
	_advance_indicator.visible = false
	_choices_container.visible = false

	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.line_displayed.connect(_on_line_displayed)
	DialogueManager.choice_presented.connect(_on_choice_presented)


func _unhandled_input(event: InputEvent) -> void:
	if not _panel.visible:
		return
	if _choices_container.visible:
		return

	if event.is_action_pressed("interact"):
		if _is_typing:
			_skip_typing()
		else:
			DialogueManager.advance()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cancel"):
		if _is_typing:
			_skip_typing()
		get_viewport().set_input_as_handled()


func _on_dialogue_started() -> void:
	_panel.visible = true
	_panel.position.y = _panel.size.y
	var tween := create_tween()
	tween.tween_property(_panel, "position:y", 0.0, SLIDE_DURATION)


func _on_dialogue_ended() -> void:
	_stop_tween()
	var tween := create_tween()
	tween.tween_property(_panel, "position:y", _panel.size.y, SLIDE_DURATION)
	tween.tween_callback(func() -> void: _panel.visible = false)
	dialogue_complete.emit()


func _on_line_displayed(
	speaker: String,
	text: String,
	portrait_texture: Texture2D,
) -> void:
	_speaker_name.text = speaker
	_dialogue_text.text = text
	_dialogue_text.visible_ratio = 0.0
	_advance_indicator.visible = false
	_choices_container.visible = false

	if portrait_texture:
		_portrait.texture = portrait_texture
		_portrait.visible = true
	else:
		_portrait.visible = false

	_start_typewriter(text)


func _on_choice_presented(choices: Array[String]) -> void:
	_clear_choices()
	_choices_container.visible = true

	for i in choices.size():
		var btn := Button.new()
		btn.text = choices[i]
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(_on_choice_selected.bind(i))
		_choices_container.add_child(btn)
		_choice_buttons.append(btn)

	_setup_choice_focus()
	if not _choice_buttons.is_empty():
		_choice_buttons[0].grab_focus()


func _start_typewriter(text: String) -> void:
	_is_typing = true
	_stop_tween()

	var duration := text.length() / CHARS_PER_SECOND
	_current_tween = create_tween()
	_current_tween.tween_property(
		_dialogue_text, "visible_ratio", 1.0, duration
	)
	_current_tween.tween_callback(_on_typing_finished)


func _skip_typing() -> void:
	_stop_tween()
	_dialogue_text.visible_ratio = 1.0
	_on_typing_finished()


func _on_typing_finished() -> void:
	_is_typing = false
	_advance_indicator.visible = true
	DialogueManager.on_line_display_complete()
	dialogue_line_finished.emit()


func _on_choice_selected(index: int) -> void:
	_choices_container.visible = false
	_clear_choices()
	DialogueManager.select_choice(index)


func _clear_choices() -> void:
	for btn in _choice_buttons:
		btn.queue_free()
	_choice_buttons.clear()


func _setup_choice_focus() -> void:
	UIHelpers.setup_focus_wrap(_choice_buttons)


func _stop_tween() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_current_tween = null

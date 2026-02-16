extends CanvasLayer

## UI scene for displaying dialogue. Responds to DialogueManager signals.

const CHAR_DISPLAY_TIME: float = 0.03

var _is_typing: bool = false
var _current_tween: Tween = null

@onready var panel: Panel = $Panel
@onready var name_label: Label = $Panel/MarginContainer/VBoxContainer/NameLabel
@onready var text_label: RichTextLabel = $Panel/MarginContainer/VBoxContainer/TextLabel
@onready var portrait: TextureRect = $Panel/Portrait
@onready var advance_indicator: TextureRect = $Panel/AdvanceIndicator


func _ready() -> void:
	visible = false
	advance_indicator.visible = false
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	DialogueManager.line_displayed.connect(_on_line_displayed)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("cancel"):
		if _is_typing:
			_skip_typing()
		else:
			DialogueManager.advance()
		get_viewport().set_input_as_handled()


func _on_dialogue_started() -> void:
	visible = true


func _on_dialogue_ended() -> void:
	visible = false
	_stop_tween()


func _on_line_displayed(
	speaker: String,
	text: String,
	portrait_texture: Texture2D,
) -> void:
	name_label.text = speaker
	text_label.text = text
	text_label.visible_ratio = 0.0
	advance_indicator.visible = false

	if portrait_texture:
		portrait.texture = portrait_texture
		portrait.visible = true
	else:
		portrait.visible = false

	_start_typewriter(text)


func _start_typewriter(text: String) -> void:
	_is_typing = true
	_stop_tween()

	var duration := text.length() * CHAR_DISPLAY_TIME
	_current_tween = create_tween()
	_current_tween.tween_property(
		text_label, "visible_ratio", 1.0, duration
	)
	_current_tween.tween_callback(_on_typing_finished)


func _skip_typing() -> void:
	_stop_tween()
	text_label.visible_ratio = 1.0
	_on_typing_finished()


func _on_typing_finished() -> void:
	_is_typing = false
	advance_indicator.visible = true
	DialogueManager.on_line_display_complete()


func _stop_tween() -> void:
	if _current_tween and _current_tween.is_valid():
		_current_tween.kill()
	_current_tween = null

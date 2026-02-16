extends Node

## Manages dialogue flow globally. Emits signals consumed by the DialogueBox UI.

signal dialogue_started
signal dialogue_ended
signal line_displayed(speaker: String, text: String, portrait: Texture2D)
signal line_finished
signal choice_presented(choices: Array[String])
signal choice_selected(index: int)

var _queue: Array[DialogueLine] = []
var _current_index: int = -1
var _is_active: bool = false
var _waiting_for_advance: bool = false
var _waiting_for_choice: bool = false


func start_dialogue(lines: Array[DialogueLine]) -> void:
	if _is_active:
		push_warning("DialogueManager: dialogue already active.")
		return
	_queue = lines
	_current_index = -1
	_is_active = true
	_waiting_for_advance = false
	_waiting_for_choice = false

	GameManager.push_state(GameManager.GameState.DIALOGUE)
	dialogue_started.emit()
	advance()


func advance() -> void:
	if not _is_active:
		return
	if _waiting_for_choice:
		return

	_current_index += 1
	if _current_index >= _queue.size():
		_end_dialogue()
		return

	var line := _queue[_current_index]

	if line.has_choices():
		_waiting_for_choice = true
		line_displayed.emit(line.speaker, line.text, line.portrait)
		choice_presented.emit(line.choices)
	else:
		_waiting_for_advance = true
		line_displayed.emit(line.speaker, line.text, line.portrait)


func select_choice(index: int) -> void:
	if not _waiting_for_choice:
		return
	if _current_index < 0 or _current_index >= _queue.size():
		return
	var line := _queue[_current_index]
	if index < 0 or index >= line.choices.size():
		push_warning("DialogueManager: choice index %d out of range." % index)
		return
	_waiting_for_choice = false
	choice_selected.emit(index)
	advance()


func skip() -> void:
	if not _is_active:
		return
	if _waiting_for_advance:
		line_finished.emit()


func on_line_display_complete() -> void:
	_waiting_for_advance = true


func is_active() -> bool:
	return _is_active


func _end_dialogue() -> void:
	_is_active = false
	_queue.clear()
	_current_index = -1
	_waiting_for_advance = false
	_waiting_for_choice = false
	GameManager.pop_state()
	dialogue_ended.emit()

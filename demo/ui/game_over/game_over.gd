extends Control
## The Game Over screen.

@onready var _retry_btn: Button = $VBox/RetryButton
@onready var _title_btn: Button = $VBox/TitleButton


func _ready() -> void:
	_retry_btn.pressed.connect(_on_retry)
	_title_btn.pressed.connect(_on_title)
	var has_save: bool = false
	for i in range(1, SaveManager.MAX_SLOTS + 1):
		if SaveManager.slot_exists(i):
			has_save = true
			break
	_retry_btn.disabled = not has_save
	if has_save:
		_retry_btn.grab_focus()
	else:
		_title_btn.grab_focus()


func _on_retry() -> void:
	SaveManager.load_game(1)


func _on_title() -> void:
	SceneManager.change_scene("res://ui/title_screen/title_screen.tscn")

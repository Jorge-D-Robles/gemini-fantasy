extends Control
## Scrolling credits.

@onready var _credits_label: Label = $CreditsLabel


func _ready() -> void:
	_credits_label.text = "CRYSTAL SAGA\n\n"
	_credits_label.text += "Created with Godot Engine\n\n"
	_credits_label.text += "Game Design & Programming\nYour Name\n\n"
	_credits_label.text += "Art Assets\n[Your source]\n\n"
	_credits_label.text += "Music\n[Your source]\n\n"
	_credits_label.text += "Built following the JRPG in Godot tutorial\n\n"
	_credits_label.text += "Thank you for playing!"

	_credits_label.position.y = get_viewport_rect().size.y
	await get_tree().process_frame

	var tween := create_tween()
	tween.tween_property(
		_credits_label, "position:y",
		-_credits_label.size.y,
		15.0,
	)
	tween.finished.connect(_return_to_title)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_return_to_title()


func _return_to_title() -> void:
	SceneManager.change_scene("res://ui/title_screen/title_screen.tscn")

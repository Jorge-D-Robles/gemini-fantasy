extends Control
## The victory ending scene.

var _can_skip: bool = false


func _ready() -> void:
	var label := $StoryText as RichTextLabel
	label.text = "[center]The Crystal Guardian falls, and the cavern fills with light.\n\n"
	label.text += "The ancient crystals hum with renewed energy.\n\n"
	label.text += "Aiden and Lira emerge from the cavern,\n"
	label.text += "the fragments of memory swirling around them.\n\n"
	label.text += "The world is safe... for now.\n\n"
	label.text += "[b]Thank you for playing Crystal Saga.[/b][/center]"

	await get_tree().create_timer(2.0).timeout
	_can_skip = true
	await get_tree().create_timer(6.0).timeout
	_go_to_credits()


func _unhandled_input(event: InputEvent) -> void:
	if _can_skip and (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")):
		_go_to_credits()


func _go_to_credits() -> void:
	SceneManager.change_scene("res://ui/credits/credits.tscn")

extends PanelContainer
## Shows a list of targets for the player to select.

signal target_selected(target: BattlerData)
signal cancelled

@onready var _target_list: VBoxContainer = $MarginContainer/TargetList


func show_targets(targets: Array[BattlerData]) -> void:
	visible = true
	for child in _target_list.get_children():
		child.queue_free()
	await get_tree().process_frame
	for target in targets:
		var button := Button.new()
		button.text = target.character_data.display_name + " (HP: " + str(target.current_hp) + ")"
		button.pressed.connect(func() -> void: target_selected.emit(target))
		_target_list.add_child(button)
	await get_tree().process_frame
	if _target_list.get_child_count() > 0:
		_target_list.get_child(0).grab_focus()


func hide_targets() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		cancelled.emit()
		get_viewport().set_input_as_handled()

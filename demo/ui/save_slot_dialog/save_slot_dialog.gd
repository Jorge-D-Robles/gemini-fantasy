extends PanelContainer
## A 3-slot save/load selection dialog.

signal slot_selected(slot: int)
signal cancelled

@onready var _buttons: Array[Button] = [
	$VBox/Slot1Button,
	$VBox/Slot2Button,
	$VBox/Slot3Button,
]
@onready var _cancel_btn: Button = $VBox/CancelButton


func _ready() -> void:
	for i in range(_buttons.size()):
		var slot_num: int = i + 1
		_buttons[i].pressed.connect(func() -> void: slot_selected.emit(slot_num))
	_cancel_btn.pressed.connect(func() -> void: cancelled.emit())
	refresh()
	_buttons[0].grab_focus()


func refresh() -> void:
	for i in range(_buttons.size()):
		var slot_num: int = i + 1
		var info: Dictionary = SaveManager.get_slot_info(slot_num)
		if info.is_empty():
			_buttons[i].text = "Slot " + str(slot_num) + ": Empty"
		else:
			_buttons[i].text = "Slot " + str(slot_num) + ": " + info.get("scene_name", "Unknown")

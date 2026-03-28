extends PanelContainer
## A single item slot in the inventory grid.

signal slot_selected(item: ItemData)
signal slot_activated(item: ItemData)

var item_data: ItemData
var count: int = 0

@onready var _icon: TextureRect = $MarginContainer/VBoxContainer/Icon
@onready var _count_label: Label = $MarginContainer/VBoxContainer/CountLabel


func setup(item: ItemData, item_count: int) -> void:
	item_data = item
	count = item_count
	_icon.texture = item.icon
	_count_label.text = str(item_count) if item_count > 1 else ""
	focus_mode = Control.FOCUS_ALL


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		slot_activated.emit(item_data)
		accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_FOCUS_ENTER:
		slot_selected.emit(item_data)

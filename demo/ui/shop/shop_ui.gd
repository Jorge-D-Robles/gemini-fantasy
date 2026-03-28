extends CanvasLayer
## Shop interface for buying items.

signal shop_closed

var _shop_data: ShopData

@onready var _item_list: VBoxContainer = $Panel/Margin/VBox/ItemList
@onready var _gold_label: Label = $Panel/Margin/VBox/GoldLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_shop()
		get_viewport().set_input_as_handled()


func open_shop(shop_data: ShopData) -> void:
	_shop_data = shop_data
	visible = true
	get_tree().paused = true
	_refresh()


func close_shop() -> void:
	visible = false
	get_tree().paused = false
	shop_closed.emit()


func _refresh() -> void:
	for child in _item_list.get_children():
		child.queue_free()

	await get_tree().process_frame

	_gold_label.text = "Gold: " + str(InventoryManager.gold)

	for item in _shop_data.items_for_sale:
		var button := Button.new()
		button.text = item.display_name + " - " + str(item.buy_price) + "g"
		if InventoryManager.gold < item.buy_price:
			button.disabled = true
		button.pressed.connect(_buy_item.bind(item))
		_item_list.add_child(button)

	if _item_list.get_child_count() > 0:
		await get_tree().process_frame
		_item_list.get_child(0).grab_focus()


func _buy_item(item: ItemData) -> void:
	if InventoryManager.spend_gold(item.buy_price):
		InventoryManager.add_item(item)
		print("Bought " + item.display_name + "!")
		_refresh()

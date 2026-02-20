extends CanvasLayer

## Shop UI for buying and selling items/equipment.
## Opened via ShopManager.shop_opened signal; closes on cancel input.

signal shop_ui_closed

enum Mode { BUY, SELL }

const UIHelpers = preload("res://ui/ui_helpers.gd")
const UITheme = preload("res://ui/ui_theme.gd")
const ShopUIDetail = preload("res://ui/shop_ui/shop_ui_detail.gd")
const ShopUIList = preload("res://ui/shop_ui/shop_ui_list.gd")

var _is_open: bool = false
var _mode: Mode = Mode.BUY
var _shop_data: ShopData = null
var _item_buttons: Array[Button] = []
var _selected_item: Resource = null

@onready var _main_panel: PanelContainer = %MainPanel
@onready var _shop_name_label: Label = %ShopNameLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _buy_tab: Button = %BuyTab
@onready var _sell_tab: Button = %SellTab
@onready var _item_list: VBoxContainer = %ItemList
@onready var _detail_panel: PanelContainer = %DetailPanel
@onready var _item_name_label: Label = %ItemNameLabel
@onready var _item_desc_label: RichTextLabel = %ItemDescLabel
@onready var _stats_list: VBoxContainer = %StatsList
@onready var _price_label: Label = %PriceLabel
@onready var _action_button: Button = %ActionButton
@onready var _close_button: Button = %CloseButton


func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_panel_styles()
	_buy_tab.pressed.connect(_switch_to_buy)
	_sell_tab.pressed.connect(_switch_to_sell)
	_action_button.pressed.connect(_on_action_pressed)
	_close_button.pressed.connect(close)


func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event.is_action_pressed("cancel"):
		close()
		get_viewport().set_input_as_handled()


func open(shop_data: ShopData) -> void:
	if shop_data == null:
		return
	if _is_open:
		close()
	AudioManager.play_sfx(load(SfxLibrary.UI_MENU_OPEN))
	_shop_data = shop_data
	_is_open = true
	_mode = Mode.BUY
	visible = true
	_shop_name_label.text = shop_data.shop_name
	_update_gold_display()
	_update_tab_styles()
	_refresh_item_list()
	_clear_detail_panel()
	get_tree().paused = true
	_grab_initial_focus()


func close() -> void:
	if not _is_open:
		return
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	_is_open = false
	_shop_data = null
	_selected_item = null
	_item_buttons.clear()
	visible = false
	get_tree().paused = false
	shop_ui_closed.emit()


func _switch_to_buy() -> void:
	if _mode == Mode.BUY:
		return
	_mode = Mode.BUY
	_selected_item = null
	_update_tab_styles()
	_refresh_item_list()
	_clear_detail_panel()
	_grab_initial_focus()


func _switch_to_sell() -> void:
	if _mode == Mode.SELL:
		return
	_mode = Mode.SELL
	_selected_item = null
	_update_tab_styles()
	_refresh_item_list()
	_clear_detail_panel()
	_grab_initial_focus()


func _update_gold_display() -> void:
	var inv: Node = get_node_or_null("/root/InventoryManager")
	if inv:
		_gold_label.text = "%d G" % inv.gold
	else:
		_gold_label.text = "0 G"


func _update_tab_styles() -> void:
	_buy_tab.add_theme_stylebox_override(
		"normal", _create_tab_style(_mode == Mode.BUY)
	)
	_sell_tab.add_theme_stylebox_override(
		"normal", _create_tab_style(_mode == Mode.SELL)
	)
	_buy_tab.add_theme_color_override(
		"font_color",
		UITheme.TEXT_GOLD if _mode == Mode.BUY else UITheme.TEXT_SECONDARY,
	)
	_sell_tab.add_theme_color_override(
		"font_color",
		UITheme.TEXT_GOLD if _mode == Mode.SELL else UITheme.TEXT_SECONDARY,
	)


func _refresh_item_list() -> void:
	UIHelpers.clear_children(_item_list)
	_item_buttons.clear()

	if _mode == Mode.BUY:
		_refresh_buy_list()
	else:
		_refresh_sell_list()

	_setup_item_focus()


func _refresh_buy_list() -> void:
	if _shop_data == null:
		return
	var items: Array[Resource] = _shop_data.get_items()
	var inv: Node = get_node_or_null("/root/InventoryManager")
	var player_gold: int = inv.gold if inv else 0
	var price_fn := _shop_data.get_buy_price
	var entries := ShopUIList.compute_buy_entries(
		items, player_gold, price_fn,
	)

	for entry: Dictionary in entries:
		var btn := _create_item_button(
			entry["item"], entry["price"],
			entry["can_afford"], true,
		)
		_item_list.add_child(btn)
		_item_buttons.append(btn)

	if entries.is_empty():
		var empty := Label.new()
		empty.text = "No items for sale"
		empty.add_theme_font_size_override("font_size", 10)
		empty.add_theme_color_override(
			"font_color", UITheme.TEXT_SECONDARY,
		)
		_item_list.add_child(empty)


func _refresh_sell_list() -> void:
	var inv: Node = get_node_or_null("/root/InventoryManager")
	if inv == null:
		return
	var all_items: Dictionary = inv.get_all_items()
	var sell_price_fn := func(item: Resource) -> int:
		return _shop_data.get_sell_price(item) if _shop_data else 0
	var entries := ShopUIList.compute_sell_entries(
		all_items, _load_item_data, sell_price_fn,
	)

	for entry: Dictionary in entries:
		var btn := _create_item_button(
			entry["item"], entry["price"], true, false,
		)
		btn.text += " x%d" % entry["count"]
		_item_list.add_child(btn)
		_item_buttons.append(btn)

	if entries.is_empty():
		var empty := Label.new()
		empty.text = "No items to sell"
		empty.add_theme_font_size_override("font_size", 10)
		empty.add_theme_color_override(
			"font_color", UITheme.TEXT_SECONDARY,
		)
		_item_list.add_child(empty)


func _create_item_button(
	item: Resource,
	price: int,
	enabled: bool,
	is_buy: bool,
) -> Button:
	var btn := Button.new()
	var name_text: String = item.display_name if "display_name" in item else "???"
	if is_buy:
		btn.text = "%s  %dG" % [name_text, price]
	else:
		btn.text = "%s  +%dG" % [name_text, price]

	btn.add_theme_font_size_override("font_size", 10)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT

	var normal_style := _create_button_style()
	var hover_style := _create_button_style()
	hover_style.bg_color = UITheme.PANEL_HOVER
	hover_style.border_color = UITheme.ACCENT_GOLD
	var focus_style := hover_style.duplicate() as StyleBoxFlat
	var pressed_style := hover_style.duplicate() as StyleBoxFlat

	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("focus", focus_style)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	if enabled:
		btn.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
		btn.add_theme_color_override(
			"font_hover_color", UITheme.TEXT_GOLD
		)
		btn.add_theme_color_override(
			"font_focus_color", UITheme.TEXT_GOLD
		)
	else:
		btn.disabled = true
		btn.add_theme_color_override("font_color", UITheme.TEXT_DISABLED)
		btn.add_theme_color_override(
			"font_disabled_color", UITheme.TEXT_DISABLED
		)
		var disabled_style := _create_button_style()
		disabled_style.bg_color = Color(0.08, 0.05, 0.15, 0.6)
		btn.add_theme_stylebox_override("disabled", disabled_style)

	btn.focus_entered.connect(_on_item_focused.bind(item))
	btn.pressed.connect(_on_item_selected.bind(item))

	return btn


func _on_item_focused(item: Resource) -> void:
	_selected_item = item
	_update_detail_panel(item)


func _on_item_selected(item: Resource) -> void:
	_selected_item = item
	_update_detail_panel(item)
	_action_button.grab_focus()


func _update_detail_panel(item: Resource) -> void:
	var buy_price: int = 0
	var sell_price: int = 0
	if _shop_data:
		buy_price = _shop_data.get_buy_price(item)
		sell_price = _shop_data.get_sell_price(item)
	var mode_int: int = (
		ShopUIDetail.MODE_SELL if _mode == Mode.SELL
		else ShopUIDetail.MODE_BUY
	)
	var info := ShopUIDetail.compute_detail_info(
		item, mode_int, buy_price, sell_price,
	)

	_item_name_label.text = info["name"]
	_item_name_label.add_theme_color_override(
		"font_color", UITheme.TEXT_GOLD,
	)
	_item_desc_label.text = info["description"]

	UIHelpers.clear_children(_stats_list)

	if item is EquipmentData:
		_add_equip_stats(item)
	elif item is ItemData:
		_add_item_info(item)

	_price_label.text = info["price_text"]
	var price_color: Color = (
		UITheme.TEXT_GOLD if info["is_buy"]
		else UITheme.TEXT_POSITIVE
	)
	_price_label.add_theme_color_override("font_color", price_color)

	_action_button.text = info["action_text"]
	_action_button.visible = true


func _add_equip_stats(equip: EquipmentData) -> void:
	var lines := ShopUIDetail.compute_equip_stat_lines(equip)
	for line: String in lines:
		var lbl := Label.new()
		lbl.text = line
		lbl.add_theme_font_size_override("font_size", 9)
		if line.begins_with("Slot:"):
			lbl.add_theme_color_override(
				"font_color", UITheme.TEXT_SECONDARY,
			)
		else:
			lbl.add_theme_color_override(
				"font_color", UITheme.TEXT_POSITIVE,
			)
		_stats_list.add_child(lbl)


func _add_item_info(item: ItemData) -> void:
	var effect_text := ShopUIDetail.compute_item_effect_text(item)
	if not effect_text.is_empty():
		var lbl := Label.new()
		lbl.text = effect_text
		lbl.add_theme_font_size_override("font_size", 9)
		lbl.add_theme_color_override(
			"font_color", UITheme.TEXT_POSITIVE,
		)
		_stats_list.add_child(lbl)

	var inv: Node = get_node_or_null("/root/InventoryManager")
	if inv:
		var owned: int = inv.get_item_count(item.id)
		if owned > 0:
			var owned_lbl := Label.new()
			owned_lbl.text = "Owned: %d" % owned
			owned_lbl.add_theme_font_size_override("font_size", 9)
			owned_lbl.add_theme_color_override(
				"font_color", UITheme.TEXT_SECONDARY,
			)
			_stats_list.add_child(owned_lbl)


func _clear_detail_panel() -> void:
	_item_name_label.text = "Select an item"
	_item_name_label.add_theme_color_override(
		"font_color", UITheme.TEXT_SECONDARY
	)
	_item_desc_label.text = ""
	UIHelpers.clear_children(_stats_list)
	_price_label.text = ""
	_action_button.visible = false
	_selected_item = null


func _on_action_pressed() -> void:
	if _selected_item == null:
		return
	var shop_mgr: Node = get_node_or_null("/root/ShopManager")
	if shop_mgr == null:
		push_warning("ShopUI: ShopManager not found")
		return

	var success: bool = false
	var item_id: StringName = _selected_item.id

	if _mode == Mode.BUY:
		success = shop_mgr.buy_item(item_id)
	else:
		success = shop_mgr.sell_item(item_id)

	if success:
		_update_gold_display()
		_refresh_item_list()
		# Re-select the same item if still available
		if _selected_item:
			_update_detail_panel(_selected_item)
		_grab_initial_focus()


func _grab_initial_focus() -> void:
	if not _item_buttons.is_empty():
		_item_buttons[0].grab_focus()
	else:
		_close_button.grab_focus()


func _setup_item_focus() -> void:
	UIHelpers.setup_focus_wrap(_item_buttons)
	# Wire right from item list to action/close buttons
	for btn in _item_buttons:
		btn.focus_neighbor_right = _action_button.get_path()
	# Wire left from action/close back to item list
	if not _item_buttons.is_empty():
		_action_button.focus_neighbor_left = (
			_item_buttons[0].get_path()
		)
		_close_button.focus_neighbor_left = (
			_item_buttons[0].get_path()
		)
	# Wire action <-> close vertical navigation
	UIHelpers.setup_focus_wrap([_action_button, _close_button])


func _load_item_data(id: StringName) -> Resource:
	var item_path := "res://data/items/%s.tres" % id
	if ResourceLoader.exists(item_path):
		return load(item_path)
	var equip_path := "res://data/equipment/%s.tres" % id
	if ResourceLoader.exists(equip_path):
		return load(equip_path)
	return null


func _apply_panel_styles() -> void:
	if _main_panel:
		_main_panel.add_theme_stylebox_override(
			"panel", UIHelpers.create_panel_style()
		)
	if _detail_panel:
		var inner := UIHelpers.create_panel_style(
			UITheme.PANEL_INNER_BG, UITheme.PANEL_BORDER, 1,
		)
		_detail_panel.add_theme_stylebox_override("panel", inner)


func _create_tab_style(active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	if active:
		style.bg_color = UITheme.PANEL_HOVER
		style.border_color = UITheme.ACCENT_GOLD
	else:
		style.bg_color = Color(0.08, 0.05, 0.15, 0.6)
		style.border_color = UITheme.PANEL_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	return style


func _create_button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = UITheme.PANEL_BG
	style.border_color = UITheme.PANEL_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 3.0
	style.content_margin_bottom = 3.0
	return style



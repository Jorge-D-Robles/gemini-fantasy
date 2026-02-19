extends Control

## Inventory screen for browsing, using, and equipping items.
## Standalone scene instanced by the pause menu.

signal inventory_closed

enum Category {
	ALL,
	CONSUMABLES,
	EQUIPMENT,
	KEY_ITEMS,
}

const UIHelpers = preload("res://ui/ui_helpers.gd")
const UITheme = preload("res://ui/ui_theme.gd")
const InventoryUIFilter = preload(
	"res://ui/inventory_ui/inventory_ui_filter.gd"
)
const InventoryUIDetail = preload(
	"res://ui/inventory_ui/inventory_ui_detail.gd"
)

var _is_open: bool = false
var _current_category: Category = Category.ALL
var _displayed_entries: Array[Dictionary] = []
var _selected_index: int = -1
var _char_select_active: bool = false
var _pending_item_data: Resource = null
var _pending_action: String = ""

@onready var _main_panel: PanelContainer = %MainPanel
@onready var _gold_label: Label = %GoldLabel
@onready var _all_btn: Button = %AllCategoryBtn
@onready var _consumables_btn: Button = %ConsumablesCategoryBtn
@onready var _equipment_btn: Button = %EquipmentCategoryBtn
@onready var _key_items_btn: Button = %KeyItemsCategoryBtn
@onready var _item_list_vbox: VBoxContainer = %ItemListVBox
@onready var _item_scroll: ScrollContainer = %ItemScroll
@onready var _item_name_label: Label = %ItemNameLabel
@onready var _item_desc_label: Label = %ItemDescLabel
@onready var _stats_vbox: VBoxContainer = %StatsVBox
@onready var _use_button: Button = %UseButton
@onready var _equip_button: Button = %EquipButton
@onready var _char_select_panel: PanelContainer = %CharSelectPanel
@onready var _char_select_vbox: VBoxContainer = %CharSelectVBox
@onready var _detail_panel: PanelContainer = %DetailPanel


func _ready() -> void:
	visible = false
	_apply_styles()
	_connect_category_buttons()
	_setup_category_focus()
	_use_button.pressed.connect(_on_use_pressed)
	_equip_button.pressed.connect(_on_equip_pressed)


func open() -> void:
	if _is_open:
		return
	AudioManager.play_sfx(load(SfxLibrary.UI_MENU_OPEN))
	_is_open = true
	visible = true
	_current_category = Category.ALL
	_char_select_active = false
	_char_select_panel.visible = false
	_refresh()


func close() -> void:
	if not _is_open:
		return
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	_is_open = false
	visible = false
	_char_select_active = false
	inventory_closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event.is_action_pressed("cancel"):
		if _char_select_active:
			_hide_character_select()
		else:
			close()
		get_viewport().set_input_as_handled()


func _refresh() -> void:
	_update_gold()
	_update_category_highlights()
	_refresh_item_list()
	_clear_detail()


func _update_gold() -> void:
	_gold_label.text = "Gold: %d" % InventoryManager.gold


func _refresh_item_list() -> void:
	UIHelpers.clear_children(_item_list_vbox)
	_displayed_entries.clear()
	_selected_index = -1

	var items := InventoryManager.get_all_items()
	_displayed_entries = InventoryUIFilter.compute_item_entries(
		items, _resolve_item, _current_category,
	)

	if _displayed_entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No items"
		empty_label.add_theme_font_size_override(
			"font_size", 10
		)
		empty_label.add_theme_color_override(
			"font_color", UITheme.TEXT_SECONDARY
		)
		_item_list_vbox.add_child(empty_label)
		_all_btn.grab_focus()
		return

	for i in _displayed_entries.size():
		var entry: Dictionary = _displayed_entries[i]
		var btn := Button.new()
		var qty: int = entry["count"]
		var display: String = entry["display_name"]
		if qty > 1:
			btn.text = "%s  x%d" % [display, qty]
		else:
			btn.text = display
		btn.add_theme_font_size_override("font_size", 10)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_item_pressed.bind(i))
		btn.focus_entered.connect(
			_on_item_focused.bind(i)
		)
		_item_list_vbox.add_child(btn)

	_setup_button_focus_wrap(_item_list_vbox)
	if _item_list_vbox.get_child_count() > 0:
		_item_list_vbox.get_child(0).grab_focus()


func _resolve_item(id: StringName) -> Dictionary:
	var item_data := InventoryManager.get_item_data(id)
	if item_data:
		return {"data": item_data, "is_equipment": false}
	var equip_path := "res://data/equipment/%s.tres" % id
	if ResourceLoader.exists(equip_path):
		var equip_data := load(equip_path) as EquipmentData
		if equip_data:
			return {
				"data": equip_data, "is_equipment": true,
			}
	return {}


func _on_item_pressed(index: int) -> void:
	_selected_index = index
	_update_detail(index)


func _on_item_focused(index: int) -> void:
	_selected_index = index
	_update_detail(index)


func _update_detail(index: int) -> void:
	if index < 0 or index >= _displayed_entries.size():
		_clear_detail()
		return

	var entry: Dictionary = _displayed_entries[index]
	var detail := InventoryUIDetail.compute_item_detail(
		entry
	)

	_item_name_label.text = detail["name"]
	_item_desc_label.text = detail["description"]
	UIHelpers.clear_children(_stats_vbox)

	if entry.get("is_equipment", false):
		var equip := entry["data"] as EquipmentData
		if equip:
			var eq_stats := (
				InventoryUIDetail
				.compute_equipment_stats(equip)
			)
			for line: String in eq_stats:
				_add_stat_line(line)
	else:
		for line: String in detail["stats"]:
			_add_stat_line(line)

	_use_button.visible = detail["show_use"]
	_equip_button.visible = detail["show_equip"]
	_update_action_focus(index)


func _add_stat_line(text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 9)
	label.add_theme_color_override(
		"font_color", UITheme.TEXT_SECONDARY
	)
	_stats_vbox.add_child(label)


func _clear_detail() -> void:
	_item_name_label.text = "Select an item"
	_item_desc_label.text = ""
	UIHelpers.clear_children(_stats_vbox)
	_use_button.visible = false
	_equip_button.visible = false


func _update_action_focus(item_index: int) -> void:
	if item_index < 0:
		return
	if item_index >= _item_list_vbox.get_child_count():
		return
	var item_btn: Node = _item_list_vbox.get_child(
		item_index
	)
	if not item_btn is Button:
		return

	var action_btn: Button = null
	if _use_button.visible:
		action_btn = _use_button
	elif _equip_button.visible:
		action_btn = _equip_button

	if action_btn:
		item_btn.focus_neighbor_right = (
			action_btn.get_path()
		)
		action_btn.focus_neighbor_left = (
			item_btn.get_path()
		)


# -- Use / Equip actions --


func _on_use_pressed() -> void:
	if _selected_index < 0:
		return
	if _selected_index >= _displayed_entries.size():
		return
	var entry: Dictionary = _displayed_entries[
		_selected_index
	]
	if entry["is_equipment"]:
		return
	var item := entry["data"] as ItemData
	if not item:
		return
	if item.item_type != ItemData.ItemType.CONSUMABLE:
		return

	if item.target_type == ItemData.TargetType.ALL_ALLIES:
		_apply_item_to_all(item, entry["id"])
	else:
		_pending_item_data = item
		_pending_action = "use"
		_show_character_select()


func _on_equip_pressed() -> void:
	if _selected_index < 0:
		return
	if _selected_index >= _displayed_entries.size():
		return
	var entry: Dictionary = _displayed_entries[
		_selected_index
	]
	if not entry["is_equipment"]:
		return
	_pending_item_data = entry["data"]
	_pending_action = "equip"
	_show_character_select()


func _show_character_select() -> void:
	UIHelpers.clear_children(_char_select_vbox)
	var party := PartyManager.get_active_party()

	var header := Label.new()
	header.text = "Select Character:"
	header.add_theme_font_size_override("font_size", 10)
	header.add_theme_color_override(
		"font_color", UITheme.TEXT_PRIMARY
	)
	_char_select_vbox.add_child(header)

	for member in party:
		var bd := member as BattlerData
		if not bd:
			continue
		var btn := Button.new()
		var hp := PartyManager.get_hp(bd.id)
		var ee := PartyManager.get_ee(bd.id)
		btn.text = "%s  HP:%d/%d  EE:%d/%d" % [
			bd.display_name,
			hp, bd.max_hp,
			ee, bd.max_ee,
		]
		btn.add_theme_font_size_override("font_size", 10)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(
			_on_character_chosen.bind(bd)
		)
		_char_select_vbox.add_child(btn)

	_setup_button_focus_wrap(_char_select_vbox)
	_char_select_panel.visible = true
	_char_select_active = true
	# Focus first character button (skip header label)
	if _char_select_vbox.get_child_count() > 1:
		_char_select_vbox.get_child(1).grab_focus()


func _hide_character_select() -> void:
	_char_select_panel.visible = false
	_char_select_active = false
	_pending_item_data = null
	_pending_action = ""
	# Return focus to item list
	if _selected_index >= 0:
		if _selected_index < _item_list_vbox.get_child_count():
			var child: Node = _item_list_vbox.get_child(
				_selected_index
			)
			if child is Button:
				child.grab_focus()


func _on_character_chosen(character: BattlerData) -> void:
	if _pending_action == "use":
		_apply_item_to_character(
			_pending_item_data as ItemData,
			character,
			_displayed_entries[_selected_index]["id"],
		)
	elif _pending_action == "equip":
		_equip_to_character(
			_pending_item_data as EquipmentData,
			character,
			_displayed_entries[_selected_index]["id"],
		)
	_hide_character_select()
	_refresh()


func _apply_item_to_character(
	item: ItemData,
	character: BattlerData,
	item_id: StringName,
) -> void:
	if not item or not character:
		return
	var applied := false
	match item.effect_type:
		ItemData.EffectType.HEAL_HP:
			var current := PartyManager.get_hp(
				character.id
			)
			PartyManager.set_hp(
				character.id,
				current + item.effect_value,
			)
			applied = true
		ItemData.EffectType.HEAL_EE:
			var current := PartyManager.get_ee(
				character.id
			)
			PartyManager.set_ee(
				character.id,
				current + item.effect_value,
			)
			applied = true
		ItemData.EffectType.REVIVE:
			if PartyManager.get_hp(character.id) <= 0:
				PartyManager.set_hp(
					character.id, item.effect_value
				)
				applied = true
	if applied:
		InventoryManager.remove_item(item_id)


func _apply_item_to_all(
	item: ItemData,
	item_id: StringName,
) -> void:
	var party := PartyManager.get_active_party()
	var applied := false
	for member in party:
		var bd := member as BattlerData
		if not bd:
			continue
		match item.effect_type:
			ItemData.EffectType.HEAL_HP:
				var current := PartyManager.get_hp(bd.id)
				PartyManager.set_hp(
					bd.id, current + item.effect_value
				)
				applied = true
			ItemData.EffectType.HEAL_EE:
				var current := PartyManager.get_ee(bd.id)
				PartyManager.set_ee(
					bd.id, current + item.effect_value
				)
				applied = true
	if applied:
		InventoryManager.remove_item(item_id)
	_refresh()


func _equip_to_character(
	equip: EquipmentData,
	character: BattlerData,
	equip_id: StringName,
) -> void:
	if not equip or not character:
		return
	var char_data := character as CharacterData
	if char_data:
		if not EquipmentManager.can_equip_weapon(
			char_data, equip
		):
			return
	var old := EquipmentManager.equip(
		character.id, equip
	)
	InventoryManager.remove_item(equip_id)
	if old:
		InventoryManager.add_item(old.id)


# -- Category buttons --


func _connect_category_buttons() -> void:
	_all_btn.pressed.connect(
		_set_category.bind(Category.ALL)
	)
	_consumables_btn.pressed.connect(
		_set_category.bind(Category.CONSUMABLES)
	)
	_equipment_btn.pressed.connect(
		_set_category.bind(Category.EQUIPMENT)
	)
	_key_items_btn.pressed.connect(
		_set_category.bind(Category.KEY_ITEMS)
	)


func _setup_category_focus() -> void:
	UIHelpers.setup_focus_wrap(
		[_all_btn, _consumables_btn, _equipment_btn, _key_items_btn],
		true,
	)


func _set_category(cat: Category) -> void:
	_current_category = cat
	_update_category_highlights()
	_refresh_item_list()
	_clear_detail()


func _update_category_highlights() -> void:
	var btns: Array[Button] = [
		_all_btn, _consumables_btn,
		_equipment_btn, _key_items_btn,
	]
	var cats: Array[int] = [
		Category.ALL, Category.CONSUMABLES,
		Category.EQUIPMENT, Category.KEY_ITEMS,
	]
	for i in btns.size():
		if cats[i] == _current_category:
			btns[i].add_theme_color_override(
				"font_color", UITheme.ACCENT_GOLD
			)
		else:
			btns[i].add_theme_color_override(
				"font_color", UITheme.TEXT_SECONDARY
			)


# -- Styling --


func _apply_styles() -> void:
	_main_panel.add_theme_stylebox_override(
		"panel", UIHelpers.create_panel_style(),
	)
	var inner := UIHelpers.create_panel_style(
		UITheme.PANEL_INNER_BG, UITheme.PANEL_BORDER, 1,
	)

	var item_list_panel := (
		_item_scroll.get_parent() as PanelContainer
	)
	if item_list_panel:
		item_list_panel.add_theme_stylebox_override(
			"panel", inner
		)
	_detail_panel.add_theme_stylebox_override(
		"panel", inner.duplicate()
	)

	var char_style := inner.duplicate() as StyleBoxFlat
	char_style.border_color = UITheme.ACCENT_GOLD
	_char_select_panel.add_theme_stylebox_override(
		"panel", char_style
	)


func _setup_button_focus_wrap(container: Container) -> void:
	var buttons: Array[Control] = []
	for child in container.get_children():
		if child is Button:
			buttons.append(child)
	UIHelpers.setup_focus_wrap(buttons)

extends CanvasLayer

## Battle UI overlay handling commands, submenus, targeting,
## party status, resonance gauge, battle log, and victory/defeat.

signal command_selected(command: String)
signal target_selected(target: Battler)
signal skill_selected(ability: Resource)
signal item_selected(item: Resource)

enum Command {
	ATTACK,
	SKILL,
	ITEM,
	DEFEND,
	FLEE,
}

var _active_battler: Battler = null
var _target_list: Array[Battler] = []
var _target_index: int = 0
var _target_callback: Callable

@onready var _turn_order_container: HBoxContainer = %TurnOrderContainer
@onready var _command_menu: PanelContainer = %CommandMenu
@onready var _attack_button: Button = %AttackButton
@onready var _skill_button: Button = %SkillButton
@onready var _item_button: Button = %ItemButton
@onready var _defend_button: Button = %DefendButton
@onready var _flee_button: Button = %FleeButton
@onready var _skill_submenu: PanelContainer = %SkillSubmenu
@onready var _skill_list: VBoxContainer = %SkillList
@onready var _item_submenu: PanelContainer = %ItemSubmenu
@onready var _item_list: VBoxContainer = %ItemList
@onready var _target_selector: Node2D = %TargetSelector
@onready var _party_status_panel: PanelContainer = %PartyStatusPanel
@onready var _party_rows: VBoxContainer = %PartyRows
@onready var _resonance_bar: ProgressBar = %ResonanceBar
@onready var _resonance_state_label: Label = %ResonanceStateLabel
@onready var _battle_log: RichTextLabel = %BattleLog
@onready var _victory_screen: PanelContainer = %VictoryScreen
@onready var _victory_exp_label: Label = %VictoryExpLabel
@onready var _victory_gold_label: Label = %VictoryGoldLabel
@onready var _victory_items_label: Label = %VictoryItemsLabel
@onready var _defeat_screen: PanelContainer = %DefeatScreen
@onready var _retry_button: Button = %RetryButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	_command_menu.visible = false
	_skill_submenu.visible = false
	_item_submenu.visible = false
	_target_selector.visible = false
	_victory_screen.visible = false
	_defeat_screen.visible = false
	_resonance_bar.max_value = Battler.RESONANCE_MAX

	_connect_command_buttons()
	_connect_defeat_buttons()


func _unhandled_input(event: InputEvent) -> void:
	if _target_selector.visible:
		if event.is_action_pressed("move_up") or event.is_action_pressed("move_left"):
			_change_target(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("move_down") or event.is_action_pressed("move_right"):
			_change_target(1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("interact"):
			_confirm_target()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("cancel"):
			_cancel_target_selection()
			get_viewport().set_input_as_handled()

	elif _skill_submenu.visible:
		if event.is_action_pressed("cancel"):
			_hide_skill_submenu()
			get_viewport().set_input_as_handled()

	elif _item_submenu.visible:
		if event.is_action_pressed("cancel"):
			_hide_item_submenu()
			get_viewport().set_input_as_handled()


func show_command_menu(battler: Battler) -> void:
	_active_battler = battler
	_command_menu.visible = true
	_skill_submenu.visible = false
	_item_submenu.visible = false
	_target_selector.visible = false
	_attack_button.grab_focus()


func hide_command_menu() -> void:
	_command_menu.visible = false
	_skill_submenu.visible = false
	_item_submenu.visible = false


func show_skill_submenu(abilities: Array[Resource]) -> void:
	_clear_children(_skill_list)
	_command_menu.visible = false

	for ability in abilities:
		var btn := Button.new()
		var ee_cost: int = ability.ee_cost if "ee_cost" in ability else 0
		btn.text = "%s (%d EE)" % [ability.display_name, ee_cost]
		btn.add_theme_font_size_override("font_size", 10)
		if _active_battler and _active_battler.current_ee < ee_cost:
			btn.disabled = true
		btn.pressed.connect(_on_skill_pressed.bind(ability))
		_skill_list.add_child(btn)

	_setup_button_focus_wrap(_skill_list)
	_skill_submenu.visible = true
	if _skill_list.get_child_count() > 0:
		_skill_list.get_child(0).grab_focus()


func show_item_submenu(items: Array[Resource]) -> void:
	_clear_children(_item_list)
	_command_menu.visible = false

	for item in items:
		var btn := Button.new()
		btn.text = item.display_name if "display_name" in item else "???"
		btn.add_theme_font_size_override("font_size", 10)
		btn.pressed.connect(_on_item_pressed.bind(item))
		_item_list.add_child(btn)

	_setup_button_focus_wrap(_item_list)
	_item_submenu.visible = true
	if _item_list.get_child_count() > 0:
		_item_list.get_child(0).grab_focus()


func show_target_selector(
	targets: Array[Battler],
	callback: Callable,
) -> void:
	_target_list = targets
	_target_callback = callback
	_target_index = 0
	_target_selector.visible = true
	_command_menu.visible = false
	_skill_submenu.visible = false
	_item_submenu.visible = false
	_update_target_cursor()


func update_party_status(party: Array[Battler]) -> void:
	_clear_children(_party_rows)

	for battler in party:
		var row := _create_party_row(battler)
		_party_rows.add_child(row)


func update_turn_order(queue: Array[Battler]) -> void:
	_clear_children(_turn_order_container)

	for battler in queue:
		var icon := Label.new()
		icon.text = battler.get_display_name().left(3)
		icon.add_theme_font_size_override("font_size", 9)
		icon.add_theme_color_override(
			"font_color",
			Color(0.7, 0.85, 1.0) if battler is PartyBattler else Color(1.0, 0.5, 0.5),
		)
		_turn_order_container.add_child(icon)


func update_resonance(gauge_value: float, state: Battler.ResonanceState) -> void:
	_resonance_bar.value = gauge_value

	match state:
		Battler.ResonanceState.FOCUSED:
			_resonance_bar.add_theme_stylebox_override(
				"fill", _create_color_stylebox(Color(0.3, 0.5, 0.9))
			)
			_resonance_state_label.text = "Focused"
			_resonance_state_label.add_theme_color_override(
				"font_color", Color(0.5, 0.7, 1.0)
			)
		Battler.ResonanceState.RESONANT:
			_resonance_bar.add_theme_stylebox_override(
				"fill", _create_color_stylebox(Color(0.9, 0.8, 0.2))
			)
			_resonance_state_label.text = "Resonant"
			_resonance_state_label.add_theme_color_override(
				"font_color", Color(1.0, 0.9, 0.3)
			)
		Battler.ResonanceState.OVERLOAD:
			_resonance_bar.add_theme_stylebox_override(
				"fill", _create_color_stylebox(Color(0.9, 0.2, 0.2))
			)
			_resonance_state_label.text = "Overload!"
			_resonance_state_label.add_theme_color_override(
				"font_color", Color(1.0, 0.3, 0.3)
			)
		Battler.ResonanceState.HOLLOW:
			_resonance_bar.add_theme_stylebox_override(
				"fill", _create_color_stylebox(Color(0.3, 0.3, 0.3))
			)
			_resonance_state_label.text = "Hollow"
			_resonance_state_label.add_theme_color_override(
				"font_color", Color(0.5, 0.5, 0.5)
			)


func add_battle_log(text: String) -> void:
	_battle_log.append_text(text + "\n")
	_battle_log.scroll_to_line(_battle_log.get_line_count() - 1)


func show_victory(exp: int, gold: int, items: Array[String]) -> void:
	hide_command_menu()
	_target_selector.visible = false
	_victory_exp_label.text = "EXP: +%d" % exp
	_victory_gold_label.text = "Gold: +%d" % gold
	var items_text := "Items: "
	if items.is_empty():
		items_text += "None"
	else:
		items_text += ", ".join(items)
	_victory_items_label.text = items_text
	_victory_screen.visible = true


func show_defeat() -> void:
	hide_command_menu()
	_target_selector.visible = false
	_defeat_screen.visible = true
	_retry_button.grab_focus()


func clear_battle_log() -> void:
	_battle_log.clear()


func _connect_command_buttons() -> void:
	_attack_button.pressed.connect(
		func() -> void: command_selected.emit("attack")
	)
	_skill_button.pressed.connect(
		func() -> void: command_selected.emit("skill")
	)
	_item_button.pressed.connect(
		func() -> void: command_selected.emit("item")
	)
	_defend_button.pressed.connect(
		func() -> void: command_selected.emit("defend")
	)
	_flee_button.pressed.connect(
		func() -> void: command_selected.emit("flee")
	)

	var buttons: Array[Button] = [
		_attack_button,
		_skill_button,
		_item_button,
		_defend_button,
		_flee_button,
	]
	for i in buttons.size():
		if i > 0:
			buttons[i].focus_neighbor_top = buttons[i - 1].get_path()
		if i < buttons.size() - 1:
			buttons[i].focus_neighbor_bottom = buttons[i + 1].get_path()
	buttons[0].focus_neighbor_top = buttons[-1].get_path()
	buttons[-1].focus_neighbor_bottom = buttons[0].get_path()


func _connect_defeat_buttons() -> void:
	_retry_button.pressed.connect(_on_retry_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_retry_button.focus_neighbor_bottom = _quit_button.get_path()
	_quit_button.focus_neighbor_top = _retry_button.get_path()
	_retry_button.focus_neighbor_top = _quit_button.get_path()
	_quit_button.focus_neighbor_bottom = _retry_button.get_path()


func _create_party_row(battler: Battler) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var name_lbl := Label.new()
	name_lbl.text = battler.get_display_name()
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.custom_minimum_size.x = 50
	row.add_child(name_lbl)

	var hp_bar := ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(44, 6)
	hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hp_bar.show_percentage = false
	hp_bar.max_value = battler.max_hp
	hp_bar.value = battler.current_hp
	row.add_child(hp_bar)

	var hp_lbl := Label.new()
	hp_lbl.text = "%d/%d" % [battler.current_hp, battler.max_hp]
	hp_lbl.add_theme_font_size_override("font_size", 8)
	row.add_child(hp_lbl)

	var ee_bar := ProgressBar.new()
	ee_bar.custom_minimum_size = Vector2(30, 6)
	ee_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ee_bar.show_percentage = false
	ee_bar.max_value = battler.max_ee
	ee_bar.value = battler.current_ee
	row.add_child(ee_bar)

	var ee_lbl := Label.new()
	ee_lbl.text = "%d" % battler.current_ee
	ee_lbl.add_theme_font_size_override("font_size", 8)
	row.add_child(ee_lbl)

	return row


func _change_target(direction: int) -> void:
	if _target_list.is_empty():
		return
	_target_index = wrapi(
		_target_index + direction, 0, _target_list.size()
	)
	_update_target_cursor()


func _update_target_cursor() -> void:
	if _target_list.is_empty():
		return
	var target := _target_list[_target_index]
	_target_selector.global_position = target.global_position + Vector2(0, -20)


func _confirm_target() -> void:
	if _target_list.is_empty():
		return
	var target := _target_list[_target_index]
	_target_selector.visible = false
	target_selected.emit(target)
	if _target_callback.is_valid():
		_target_callback.call(target)


func _cancel_target_selection() -> void:
	_target_selector.visible = false
	show_command_menu(_active_battler)


func _hide_skill_submenu() -> void:
	_skill_submenu.visible = false
	show_command_menu(_active_battler)


func _hide_item_submenu() -> void:
	_item_submenu.visible = false
	show_command_menu(_active_battler)


func _on_skill_pressed(ability: Resource) -> void:
	skill_selected.emit(ability)


func _on_item_pressed(item: Resource) -> void:
	item_selected.emit(item)


func _on_retry_pressed() -> void:
	_defeat_screen.visible = false
	GameManager.change_scene(
		get_tree().current_scene.scene_file_path
	)


func _on_quit_pressed() -> void:
	_defeat_screen.visible = false
	GameManager.change_scene(
		"res://ui/title_screen/title_screen.tscn"
	)


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


func _setup_button_focus_wrap(container: Container) -> void:
	var buttons: Array[Button] = []
	for child in container.get_children():
		if child is Button:
			buttons.append(child)
	for i in buttons.size():
		if i > 0:
			buttons[i].focus_neighbor_top = buttons[i - 1].get_path()
		if i < buttons.size() - 1:
			buttons[i].focus_neighbor_bottom = buttons[i + 1].get_path()
	if buttons.size() > 1:
		buttons[0].focus_neighbor_top = buttons[-1].get_path()
		buttons[-1].focus_neighbor_bottom = buttons[0].get_path()


func _create_color_stylebox(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	return style

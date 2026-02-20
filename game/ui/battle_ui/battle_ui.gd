extends CanvasLayer

## Battle UI overlay handling commands, submenus, targeting,
## party status, resonance gauge, battle log, and victory/defeat.
## Features active character portrait and styled JRPG panel layout.

signal command_selected(command: String)
signal target_selected(target: Battler)
signal skill_selected(ability: Resource)
signal item_selected(item: Resource)
signal submenu_cancelled
signal target_cancelled
signal victory_dismissed

enum Command {
	ATTACK,
	SKILL,
	ITEM,
	DEFEND,
	FLEE,
}

const BattleUIStatus = preload(
	"res://ui/battle_ui/battle_ui_status.gd"
)
const BattleUIVictory = preload(
	"res://ui/battle_ui/battle_ui_victory.gd"
)
const GameBalance = preload("res://systems/game_balance.gd")
const SP = preload("res://systems/scene_paths.gd")
const UIHelpers = preload("res://ui/ui_helpers.gd")
const UITheme = preload("res://ui/ui_theme.gd")

var _active_battler: Battler = null
var _target_list: Array[Battler] = []
var _target_index: int = 0
var _party_cache: Array[Battler] = []
var _resonance_tween: Tween = null
var _highlighted_target: Node = null
var _original_modulate: Color = Color.WHITE
var _name_label: Label = null
var _victory_party_container: VBoxContainer = null
var _waiting_for_victory_dismiss: bool = false
var _victory_dismiss_label: Label = null

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
@onready var _portrait: TextureRect = %Portrait
@onready var _active_name_label: Label = %ActiveNameLabel


func _ready() -> void:
	_command_menu.visible = false
	_skill_submenu.visible = false
	_item_submenu.visible = false
	_target_selector.visible = false
	_victory_screen.visible = false
	_defeat_screen.visible = false
	_resonance_bar.max_value = GameBalance.RESONANCE_MAX

	_setup_target_name_label()
	_setup_victory_party_container()
	_apply_panel_styles()
	_connect_command_buttons()
	_connect_defeat_buttons()


func _unhandled_input(event: InputEvent) -> void:
	if _waiting_for_victory_dismiss:
		if event.is_action_pressed("interact"):
			_dismiss_victory()
			get_viewport().set_input_as_handled()
		return

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
	_update_active_portrait(battler)


func hide_command_menu() -> void:
	_command_menu.visible = false
	_skill_submenu.visible = false
	_item_submenu.visible = false


func show_skill_submenu(abilities: Array[Resource]) -> void:
	UIHelpers.clear_children(_skill_list)
	_command_menu.visible = false

	for ability in abilities:
		var btn := Button.new()
		var ee_cost: int = ability.ee_cost if "ee_cost" in ability else 0
		btn.text = "%s (%d EE)" % [ability.display_name, ee_cost]
		btn.add_theme_font_size_override("font_size", 9)
		if _active_battler and _active_battler.current_ee < ee_cost:
			btn.disabled = true
		btn.pressed.connect(_on_skill_pressed.bind(ability))
		_skill_list.add_child(btn)

	_setup_button_focus_wrap(_skill_list)
	_skill_submenu.visible = true
	if _skill_list.get_child_count() > 0:
		_skill_list.get_child(0).grab_focus()


func show_item_submenu(items: Array[Resource]) -> void:
	UIHelpers.clear_children(_item_list)
	_command_menu.visible = false

	for item in items:
		var btn := Button.new()
		btn.text = item.display_name if "display_name" in item else "???"
		btn.add_theme_font_size_override("font_size", 9)
		btn.pressed.connect(_on_item_pressed.bind(item))
		_item_list.add_child(btn)

	_setup_button_focus_wrap(_item_list)
	_item_submenu.visible = true
	if _item_list.get_child_count() > 0:
		_item_list.get_child(0).grab_focus()


func show_target_selector(
	targets: Array[Battler],
	_callback: Callable = Callable(),
) -> void:
	_target_list = targets
	_target_index = 0
	_target_selector.visible = true
	_command_menu.visible = false
	_skill_submenu.visible = false
	_item_submenu.visible = false
	_update_target_cursor()


func update_party_status(party: Array[Battler]) -> void:
	_party_cache = party
	UIHelpers.clear_children(_party_rows)

	for battler in party:
		var row := _create_party_row(battler)
		_party_rows.add_child(row)


func update_turn_order(queue: Array[Battler]) -> void:
	UIHelpers.clear_children(_turn_order_container)

	for battler in queue:
		var icon := Label.new()
		icon.text = battler.get_display_name().left(4)
		icon.add_theme_font_size_override("font_size", 8)
		if battler is PartyBattler:
			icon.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
		else:
			icon.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))

		if battler == _active_battler:
			icon.add_theme_color_override("font_color", UITheme.ACTIVE_HIGHLIGHT)

		_turn_order_container.add_child(icon)

		# Add separator arrow between entries
		if battler != queue.back():
			var sep := Label.new()
			sep.text = ">"
			sep.add_theme_font_size_override("font_size", 7)
			sep.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
			_turn_order_container.add_child(sep)


func update_resonance(gauge_value: float, state: Battler.ResonanceState) -> void:
	if _resonance_tween:
		_resonance_tween.kill()
	_resonance_tween = create_tween()
	_resonance_tween.tween_property(
		_resonance_bar, "value", gauge_value, 0.3
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

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


func add_battle_log(
	text: String, log_type: int = UITheme.LogType.INFO,
) -> void:
	var color: Color = UITheme.get_log_color(log_type)
	var hex := color.to_html(false)
	_battle_log.append_text(
		"[color=#%s]%s[/color]\n" % [hex, text]
	)
	_battle_log.scroll_to_line(_battle_log.get_line_count() - 1)


func show_victory(
	exp: int, gold: int, items: Array[String],
	party: Array[Resource] = [],
	level_ups: Array[Dictionary] = [],
) -> void:
	hide_command_menu()
	_clear_highlight()
	_target_selector.visible = false

	var data := BattleUIVictory.compute_victory_display(
		party, exp, gold, items, level_ups,
	)
	_victory_exp_label.text = data["exp_text"]
	_victory_gold_label.text = data["gold_text"]
	_victory_items_label.text = data["items_text"]

	# Build party member rows with portraits and level-ups
	_build_victory_party_section(data["members"])

	_victory_screen.visible = true


func show_defeat() -> void:
	hide_command_menu()
	_clear_highlight()
	_target_selector.visible = false
	_defeat_screen.visible = true
	_retry_button.grab_focus()


func show_victory_dismiss_prompt() -> void:
	var vbox: VBoxContainer = _victory_screen.get_node_or_null(
		"MarginContainer/VBoxContainer"
	)
	if not vbox:
		return
	_victory_dismiss_label = Label.new()
	_victory_dismiss_label.text = BattleUIVictory.compute_dismiss_prompt_text()
	_victory_dismiss_label.add_theme_font_size_override("font_size", 9)
	_victory_dismiss_label.add_theme_color_override(
		"font_color", UITheme.TEXT_SECONDARY,
	)
	_victory_dismiss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_victory_dismiss_label)
	_waiting_for_victory_dismiss = true


func clear_battle_log() -> void:
	_battle_log.clear()


func _dismiss_victory() -> void:
	_waiting_for_victory_dismiss = false
	if is_instance_valid(_victory_dismiss_label):
		_victory_dismiss_label.queue_free()
		_victory_dismiss_label = null
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
	victory_dismissed.emit()


func _update_active_portrait(battler: Battler) -> void:
	_active_name_label.text = battler.get_display_name()

	if battler is PartyBattler:
		var char_data := battler.data as CharacterData
		if char_data and not char_data.portrait_path.is_empty():
			var tex := load(char_data.portrait_path) as Texture2D
			if tex:
				# Portrait sheets are 192x96 (2 faces). Extract first face.
				var atlas := AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(0, 0, 96, 96)
				_portrait.texture = atlas
				return

	_portrait.texture = null


func _apply_panel_styles() -> void:
	var base_style := UIHelpers.create_panel_style(
		UITheme.BATTLE_PANEL_BG, UITheme.BATTLE_PANEL_BORDER, 1, 2,
	)
	var panels: Array[PanelContainer] = [
		get_node("TopBar") as PanelContainer,
		get_node("BottomPanel") as PanelContainer,
		get_node("BattleLogPanel") as PanelContainer,
	]
	for panel in panels:
		if panel:
			panel.add_theme_stylebox_override("panel", base_style)

	# Slightly different style for inner panels
	var inner_style := UIHelpers.create_panel_style(
		Color(0.06, 0.06, 0.12, 0.7), UITheme.BATTLE_PANEL_BORDER, 1, 2,
	)

	if _command_menu:
		_command_menu.add_theme_stylebox_override("panel", inner_style)
	if _party_status_panel:
		_party_status_panel.add_theme_stylebox_override("panel", inner_style)
	if _skill_submenu:
		_skill_submenu.add_theme_stylebox_override("panel", inner_style)
	if _item_submenu:
		_item_submenu.add_theme_stylebox_override("panel", inner_style)

	# Portrait frame style
	var portrait_frame: PanelContainer = get_node(
		"BottomPanel/MarginContainer/HBoxContainer/PortraitSection/PortraitFrame"
	) as PanelContainer
	if portrait_frame:
		var portrait_style := UIHelpers.create_panel_style(
			Color(0.05, 0.05, 0.1, 0.9), Color(0.6, 0.5, 0.3), 1, 2,
		)
		portrait_frame.add_theme_stylebox_override("panel", portrait_style)

	# Victory/defeat screen styles
	var overlay_style := UIHelpers.create_panel_style(
		Color(0.05, 0.05, 0.1, 0.95), Color(0.5, 0.5, 0.6),
	)

	if _victory_screen:
		_victory_screen.add_theme_stylebox_override("panel", overlay_style)
	if _defeat_screen:
		var defeat_style := overlay_style.duplicate() as StyleBoxFlat
		defeat_style.border_color = Color(0.6, 0.2, 0.2)
		_defeat_screen.add_theme_stylebox_override("panel", defeat_style)


func _connect_command_buttons() -> void:
	_attack_button.pressed.connect(func() -> void:
		AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
		command_selected.emit("attack")
	)
	_skill_button.pressed.connect(func() -> void:
		AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
		command_selected.emit("skill")
	)
	_item_button.pressed.connect(func() -> void:
		AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
		command_selected.emit("item")
	)
	_defend_button.pressed.connect(func() -> void:
		AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
		command_selected.emit("defend")
	)
	_flee_button.pressed.connect(func() -> void:
		AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
		command_selected.emit("flee")
	)

	var buttons: Array[Button] = [
		_attack_button,
		_skill_button,
		_item_button,
		_defend_button,
		_flee_button,
	]
	UIHelpers.setup_focus_wrap(buttons)


func _connect_defeat_buttons() -> void:
	_retry_button.pressed.connect(_on_retry_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	UIHelpers.setup_focus_wrap([_retry_button, _quit_button])


func _create_party_row(battler: Battler) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	# Name label
	var name_lbl := Label.new()
	name_lbl.text = battler.get_display_name().left(6)
	name_lbl.add_theme_font_size_override("font_size", 8)
	name_lbl.custom_minimum_size.x = 40
	if battler == _active_battler:
		name_lbl.add_theme_color_override("font_color", UITheme.ACTIVE_HIGHLIGHT)
	row.add_child(name_lbl)

	# HP label
	var hp_label := Label.new()
	hp_label.text = "HP"
	hp_label.add_theme_font_size_override("font_size", 7)
	hp_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	row.add_child(hp_label)

	# HP bar
	var hp_bar := ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(50, 6)
	hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hp_bar.show_percentage = false
	hp_bar.max_value = battler.max_hp
	hp_bar.value = battler.current_hp
	var hp_ratio: float = float(battler.current_hp) / float(maxi(battler.max_hp, 1))
	var hp_color := UITheme.HP_BAR_COLOR
	if hp_ratio <= UITheme.HP_LOW_THRESHOLD:
		hp_color = UITheme.HP_BAR_LOW_COLOR
	hp_bar.add_theme_stylebox_override("fill", _create_color_stylebox(hp_color))
	row.add_child(hp_bar)

	# HP numbers
	var hp_lbl := Label.new()
	hp_lbl.text = "%d/%d" % [battler.current_hp, battler.max_hp]
	hp_lbl.add_theme_font_size_override("font_size", 7)
	hp_lbl.custom_minimum_size.x = 44
	row.add_child(hp_lbl)

	# EE label
	var ee_label := Label.new()
	ee_label.text = "EE"
	ee_label.add_theme_font_size_override("font_size", 7)
	ee_label.add_theme_color_override("font_color", Color(0.5, 0.6, 0.9))
	row.add_child(ee_label)

	# EE bar
	var ee_bar := ProgressBar.new()
	ee_bar.custom_minimum_size = Vector2(36, 6)
	ee_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	ee_bar.show_percentage = false
	ee_bar.max_value = battler.max_ee
	ee_bar.value = battler.current_ee
	ee_bar.add_theme_stylebox_override("fill", _create_color_stylebox(UITheme.EE_BAR_COLOR))
	row.add_child(ee_bar)

	# EE numbers
	var ee_lbl := Label.new()
	ee_lbl.text = "%d" % battler.current_ee
	ee_lbl.add_theme_font_size_override("font_size", 7)
	row.add_child(ee_lbl)

	# Resonance state indicator
	var res_lbl := Label.new()
	res_lbl.add_theme_font_size_override("font_size", 6)
	match battler.resonance_state:
		Battler.ResonanceState.FOCUSED:
			res_lbl.text = ""
		Battler.ResonanceState.RESONANT:
			res_lbl.text = "RES"
			res_lbl.add_theme_color_override(
				"font_color", Color(1.0, 0.9, 0.3)
			)
		Battler.ResonanceState.OVERLOAD:
			res_lbl.text = "OVL"
			res_lbl.add_theme_color_override(
				"font_color", Color(1.0, 0.3, 0.3)
			)
		Battler.ResonanceState.HOLLOW:
			res_lbl.text = "HLW"
			res_lbl.add_theme_color_override(
				"font_color", Color(0.5, 0.5, 0.5)
			)
	row.add_child(res_lbl)

	# Status effect badges
	var badges := BattleUIStatus.compute_status_badges(
		battler.get_status_effect_list(),
	)
	for badge: Dictionary in badges:
		var badge_lbl := Label.new()
		badge_lbl.text = badge["text"]
		badge_lbl.add_theme_font_size_override("font_size", 6)
		badge_lbl.add_theme_color_override("font_color", badge["color"])
		row.add_child(badge_lbl)

	return row


func _setup_target_name_label() -> void:
	_name_label = Label.new()
	_name_label.name = "TargetName"
	_name_label.add_theme_font_size_override("font_size", 8)
	_name_label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
	_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name_label.position = Vector2(-30, 10)
	_name_label.custom_minimum_size.x = 60
	_target_selector.add_child(_name_label)


func _setup_victory_party_container() -> void:
	_victory_party_container = VBoxContainer.new()
	_victory_party_container.name = "PartySection"
	_victory_party_container.add_theme_constant_override("separation", 2)
	# Insert after VictoryTitle (index 0) in the VBox
	var vbox: VBoxContainer = _victory_screen.get_node(
		"MarginContainer/VBoxContainer"
	)
	if vbox:
		vbox.add_child(_victory_party_container)
		vbox.move_child(_victory_party_container, 1)


func _build_victory_party_section(
	members: Array,
) -> void:
	UIHelpers.clear_children(_victory_party_container)
	if members.is_empty():
		return

	for m: Dictionary in members:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)

		# Portrait (small 32x32)
		var portrait_path: String = m.get("portrait_path", "")
		if not portrait_path.is_empty():
			var tex := load(portrait_path) as Texture2D
			if tex:
				var tr := TextureRect.new()
				var atlas := AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(0, 0, 96, 96)
				tr.texture = atlas
				tr.expand_mode = TextureRect.EXPAND_FIT_WIDTH
				tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
				tr.custom_minimum_size = Vector2(24, 24)
				row.add_child(tr)

		# Name + Level
		var name_lbl := Label.new()
		var level: int = m.get("level", 1)
		name_lbl.text = "%s Lv%d" % [m.get("name", "???"), level]
		name_lbl.add_theme_font_size_override("font_size", 8)
		name_lbl.custom_minimum_size.x = 70
		row.add_child(name_lbl)

		# Level-up callout
		if m.get("leveled_up", false):
			var lu_lbl := Label.new()
			lu_lbl.text = "LEVEL UP!"
			lu_lbl.add_theme_font_size_override("font_size", 7)
			lu_lbl.add_theme_color_override(
				"font_color", UITheme.TEXT_GOLD,
			)
			row.add_child(lu_lbl)

			# Top stat changes
			var changes: Dictionary = m.get("stat_changes", {})
			var parts: Array[String] = []
			for stat_key: String in changes:
				var val: int = changes[stat_key]
				parts.append(
					"+%d %s" % [
						val,
						BattleUIVictory.stat_abbreviation(
							stat_key,
						),
					]
				)
			if not parts.is_empty():
				var stats_lbl := Label.new()
				stats_lbl.text = ", ".join(parts)
				stats_lbl.add_theme_font_size_override("font_size", 6)
				stats_lbl.add_theme_color_override(
					"font_color", UITheme.TEXT_POSITIVE,
				)
				row.add_child(stats_lbl)

		_victory_party_container.add_child(row)


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

	# Update name label
	var info := BattleUIStatus.compute_target_info(target)
	if _name_label:
		_name_label.text = info["name"]

	# Apply highlight to visual scene
	_apply_highlight(target, info["color"])


func _apply_highlight(battler: Battler, color: Color) -> void:
	_clear_highlight()
	var visual: Node2D = _find_visual_scene(battler)
	if visual:
		_highlighted_target = visual
		_original_modulate = visual.modulate
		visual.modulate = color


func _clear_highlight() -> void:
	if is_instance_valid(_highlighted_target) and _highlighted_target is CanvasItem:
		_highlighted_target.modulate = _original_modulate
	_highlighted_target = null
	_original_modulate = Color.WHITE


func _find_visual_scene(battler: Battler) -> Node2D:
	for child in battler.get_children():
		if child is PartyBattlerScene or child is EnemyBattlerScene:
			return child
	return null


func _confirm_target() -> void:
	if _target_list.is_empty():
		return
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
	var target := _target_list[_target_index]
	_clear_highlight()
	_target_selector.visible = false
	target_selected.emit(target)


func _cancel_target_selection() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	_clear_highlight()
	_target_selector.visible = false
	target_cancelled.emit()


func _hide_skill_submenu() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	_skill_submenu.visible = false
	submenu_cancelled.emit()


func _hide_item_submenu() -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CANCEL))
	_item_submenu.visible = false
	submenu_cancelled.emit()


func _on_skill_pressed(ability: Resource) -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
	skill_selected.emit(ability)


func _on_item_pressed(item: Resource) -> void:
	AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
	item_selected.emit(item)


func _on_retry_pressed() -> void:
	_defeat_screen.visible = false
	var current := get_tree().current_scene
	if current:
		GameManager.change_scene(current.scene_file_path)
	else:
		GameManager.change_scene(SP.TITLE_SCREEN)


func _on_quit_pressed() -> void:
	_defeat_screen.visible = false
	GameManager.change_scene(SP.TITLE_SCREEN)


func _setup_button_focus_wrap(container: Container) -> void:
	var buttons: Array[Control] = []
	for child in container.get_children():
		if child is Button:
			buttons.append(child)
	UIHelpers.setup_focus_wrap(buttons)


func _create_color_stylebox(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	return style

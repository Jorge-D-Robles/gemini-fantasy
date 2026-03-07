# Chapter 18 — UI and Menus

A game without UI is a tech demo. You have built systems that track party state, manage inventory, resolve battles, and persist saves — but the player has no way to see or interact with most of it. This chapter builds the visual layer that connects the player to those systems.

If you have built enterprise applications, you already know the pattern: a backend provides data and operations, a frontend renders that data and captures user input. In Angular terms, your autoloads are services and your UI scenes are components. The difference in games is that you have multiple UI layers stacked on top of each other — a HUD that is always visible, menus that appear on demand, dialogue that overlays everything, and transition effects that cover the screen. Managing which layer is visible and which captures input is the core challenge.

## What We Are Building

- **CanvasLayer stacking strategy** for managing UI depth
- **Container-based layout** that adapts to different screen sizes
- **Focus navigation** for keyboard and gamepad control
- **Title screen** with animated menu buttons
- **HUD** showing party status, gold, location, and quest objectives
- **Pause menu** with sub-screens for party, items, quests, and settings
- **Battle UI** with command buttons, target selection, and party status
- **Shop UI** with buy/sell tabs, item detail, and price display
- **Settings menu** with volume sliders
- **Programmatic theming** with `StyleBoxFlat`

## CanvasLayer Stacking

In a web browser, you control stacking order with `z-index`. In Godot, you use **CanvasLayer** nodes. Each CanvasLayer has a `layer` property — higher numbers draw on top of lower ones. Regular scene nodes (your tilemap, player, NPCs) live at layer 0.

Our layer assignments:

| Layer | UI Element | Purpose |
|-------|-----------|---------|
| 0 | Game world | Tilemap, player, NPCs, enemies |
| 10 | HUD | Always-visible overworld status |
| 15 | Dialogue | Bottom-screen dialogue panel |
| 20 | Pause menu | Full-screen pause overlay |
| 30 | Battle UI | In-battle command and status interface |
| 40 | Transitions | Fade rectangle for scene changes |
| 50 | Debug | Developer overlay (hidden in release) |

**Why CanvasLayer instead of z-index on Control nodes?** CanvasLayers are completely independent of the game camera. When the camera follows the player across the map, the HUD stays fixed in place. Without CanvasLayer, your HP bars would scroll with the world.

**Engineering parallel:** CanvasLayers are CSS stacking contexts. Each one creates an isolated rendering plane. Nodes within the same CanvasLayer can use regular z-ordering, but between layers, the `layer` property controls which one draws on top.

### Creating a CanvasLayer UI Scene

Every UI screen follows the same pattern:

```gdscript
# ui/hud/hud.gd
extends CanvasLayer

func _ready() -> void:
	layer = 10
	# ... setup
```

Or set the `layer` property in the scene inspector. The script just needs to extend `CanvasLayer`.

## Container-Based Layout

If you have used CSS Flexbox or CSS Grid, Godot's container system will feel familiar. The rule is the same: **never use absolute positioning**. Use containers to manage layout, and let the engine handle pixel math.

### Core Containers

**VBoxContainer** — stacks children vertically, top to bottom. Like `flex-direction: column`.

```gdscript
var vbox := VBoxContainer.new()
vbox.add_theme_constant_override("separation", 8)  # 8px gap between children
```

**HBoxContainer** — stacks children horizontally, left to right. Like `flex-direction: row`.

```gdscript
var hbox := HBoxContainer.new()
hbox.add_theme_constant_override("separation", 4)
```

**MarginContainer** — adds padding around its single child. Like CSS `padding`.

```gdscript
var margin := MarginContainer.new()
margin.add_theme_constant_override("margin_left", 16)
margin.add_theme_constant_override("margin_right", 16)
margin.add_theme_constant_override("margin_top", 12)
margin.add_theme_constant_override("margin_bottom", 12)
```

**GridContainer** — arranges children in a grid with a fixed column count. Like CSS Grid with `grid-template-columns: repeat(N, auto)`.

```gdscript
var grid := GridContainer.new()
grid.columns = 2
grid.add_theme_constant_override("h_separation", 12)
grid.add_theme_constant_override("v_separation", 2)
```

**PanelContainer** — wraps its child in a styled box (the "panel"). Useful as a visual frame around content.

### Size Flags

Control nodes use `size_flags_horizontal` and `size_flags_vertical` to tell their parent container how to allocate space — the equivalent of `flex-grow` and `flex-shrink`:

```gdscript
var label := Label.new()
label.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # take all available width
```

| Flag | Behavior |
|------|----------|
| `SIZE_SHRINK_BEGIN` | Minimum size, aligned to start |
| `SIZE_SHRINK_CENTER` | Minimum size, centered |
| `SIZE_SHRINK_END` | Minimum size, aligned to end |
| `SIZE_FILL` | Fill allocated space (no expand) |
| `SIZE_EXPAND_FILL` | Expand to take remaining space, then fill |

**`custom_minimum_size`** sets a minimum width/height in pixels. Containers will never make the control smaller than this:

```gdscript
var button := Button.new()
button.custom_minimum_size = Vector2(120, 32)
```

### Anchors and Presets

For top-level positioning within a CanvasLayer, use **anchor presets** to pin elements to screen edges:

```gdscript
var label := Label.new()
label.anchors_preset = Control.PRESET_CENTER_TOP   # centered horizontally, pinned to top
label.anchors_preset = Control.PRESET_BOTTOM_RIGHT  # pinned to bottom-right corner
label.anchors_preset = Control.PRESET_FULL_RECT     # fill entire screen
```

This handles different screen resolutions automatically — the control stays anchored to the correct edge regardless of window size.

## Focus Navigation

In web development, keyboard navigation happens automatically through tab order. In Godot, you must wire it explicitly. Every focusable Control (Button, Slider, LineEdit) has four directional focus neighbors:

```gdscript
button.focus_neighbor_top = other_button.get_path()
button.focus_neighbor_bottom = another_button.get_path()
button.focus_neighbor_left = left_button.get_path()
button.focus_neighbor_right = right_button.get_path()
```

These control where the focus moves when the player presses a directional input. For sequential navigation (Tab key), use `focus_next` and `focus_previous`.

### Focus Wrapping

A common JRPG pattern: pressing Down on the last menu item wraps to the first, and pressing Up on the first wraps to the last. Build a utility function for this:

```gdscript
# ui/ui_helpers.gd
extends RefCounted

static func setup_focus_wrap(
	controls: Array,
	horizontal: bool = false,
) -> void:
	if controls.size() < 2:
		return
	for i in controls.size():
		var prev_prop: String
		var next_prop: String
		if horizontal:
			prev_prop = "focus_neighbor_left"
			next_prop = "focus_neighbor_right"
		else:
			prev_prop = "focus_neighbor_top"
			next_prop = "focus_neighbor_bottom"
		if i > 0:
			controls[i].set(prev_prop, controls[i - 1].get_path())
		if i < controls.size() - 1:
			controls[i].set(next_prop, controls[i + 1].get_path())
	# Wrap: first <-> last
	var first: Control = controls[0]
	var last: Control = controls[-1]
	if horizontal:
		first.focus_neighbor_left = last.get_path()
		last.focus_neighbor_right = first.get_path()
	else:
		first.focus_neighbor_top = last.get_path()
		last.focus_neighbor_bottom = first.get_path()
```

Usage:

```gdscript
UIHelpers.setup_focus_wrap([attack_btn, skill_btn, item_btn, defend_btn, flee_btn])
```

After calling this, pressing Down on `flee_btn` moves focus to `attack_btn`, and pressing Up on `attack_btn` moves to `flee_btn`.

**Engineering parallel:** This is Angular CDK's `FocusTrap` — constraining keyboard navigation within a bounded group of elements.

### Grabbing Focus

To programmatically set which control is focused (equivalent to calling `.focus()` on a DOM element):

```gdscript
new_game_button.grab_focus()
```

Always grab focus when a menu opens, or the player will need to click or Tab to reach the first button.

## Programmatic Theming with StyleBoxFlat

Rather than creating theme resource files in the editor, we build styles in code. `StyleBoxFlat` is the equivalent of a CSS box model — it has a background color, border, corner radius, and content margins:

```gdscript
static func create_panel_style(
	bg: Color = Color(0.12, 0.07, 0.22, 0.85),
	border: Color = Color(0.45, 0.35, 0.65, 0.6),
	border_width: int = 2,
	corner_radius: int = 3,
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(corner_radius)
	return style
```

Apply a style to a node using theme overrides:

```gdscript
var panel := PanelContainer.new()
panel.add_theme_stylebox_override("panel", create_panel_style())
```

For buttons, you set different styles for each state:

```gdscript
func _apply_button_style(btn: Button) -> void:
	var normal := create_panel_style(
		Color(0.12, 0.07, 0.22, 0.85),
		Color(0.45, 0.35, 0.65, 0.6),
		1, 2,
	)
	var hover := create_panel_style(
		Color(0.18, 0.12, 0.32, 0.9),
		Color(0.85, 0.75, 0.45, 0.8),
		1, 2,
	)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("focus", hover.duplicate())
	btn.add_theme_stylebox_override("pressed", hover.duplicate())
	btn.add_theme_color_override("font_color", Color(0.85, 0.75, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(0.85, 0.75, 0.45))
	btn.add_theme_color_override("font_focus_color", Color(0.85, 0.75, 0.45))
```

**Why `hover.duplicate()`?** Each override needs its own StyleBoxFlat instance. If you reuse the same object for `hover`, `focus`, and `pressed`, changing one changes all of them. `duplicate()` creates an independent copy.

### Centralizing Your Color Palette

Define all UI colors in a single shared script to avoid magic numbers scattered across files:

```gdscript
# ui/ui_theme.gd
extends RefCounted

const PANEL_BG := Color(0.12, 0.07, 0.22, 0.85)
const PANEL_BORDER := Color(0.45, 0.35, 0.65, 0.6)
const PANEL_HOVER := Color(0.18, 0.12, 0.32, 0.9)

const TEXT_PRIMARY := Color(0.85, 0.75, 1.0)
const TEXT_SECONDARY := Color(0.6, 0.55, 0.7)
const TEXT_GOLD := Color(0.85, 0.75, 0.45)
const TEXT_DISABLED := Color(0.4, 0.35, 0.5)

const ACCENT_GOLD := Color(0.85, 0.75, 0.45, 0.8)

const HP_BAR_COLOR := Color(0.2, 0.8, 0.3)
const HP_BAR_LOW_COLOR := Color(0.9, 0.3, 0.2)
const HP_LOW_THRESHOLD: float = 0.25
const EE_BAR_COLOR := Color(0.3, 0.5, 0.9)
```

Import it in every UI script:

```gdscript
const UITheme = preload("res://ui/ui_theme.gd")

var label := Label.new()
label.add_theme_color_override("font_color", UITheme.TEXT_PRIMARY)
```

**Engineering parallel:** This is your design token file — the single source of truth for the visual language. Change a color here and it propagates everywhere, like CSS custom properties.

## Title Screen

The title screen is the player's first impression. It shows the game title, menu buttons, and plays the title BGM. It extends `Control` instead of `CanvasLayer` because it is the entire scene, not an overlay on top of gameplay.

```gdscript
# ui/title_screen/title_screen.gd
extends Control

signal new_game_pressed
signal continue_pressed

const UITheme = preload("res://ui/ui_theme.gd")
const TITLE_BGM_PATH: String = "res://assets/music/Welcoming Heart Piano.ogg"

@onready var title_label: Label = %TitleLabel
@onready var menu_container: VBoxContainer = %MenuContainer
@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton


func _ready() -> void:
	_start_title_music()
	_connect_buttons()
	_setup_focus_navigation()
	_check_save_data()
	_animate_intro()
	new_game_button.grab_focus()


func _start_title_music() -> void:
	var bgm := load(TITLE_BGM_PATH) as AudioStream
	if bgm:
		AudioManager.play_bgm(bgm, 0.0)  # no fade — start immediately


func _setup_focus_navigation() -> void:
	UIHelpers.setup_focus_wrap([
		new_game_button, continue_button, settings_button,
	])


func _check_save_data() -> void:
	var has_save: bool = SaveManager.has_save(0)
	continue_button.disabled = not has_save


func _animate_intro() -> void:
	# Start everything invisible
	title_label.modulate.a = 0.0
	menu_container.modulate.a = 0.0

	# Fade in sequentially
	var tween := create_tween()
	tween.tween_property(title_label, "modulate:a", 1.0, 1.0)
	tween.tween_property(menu_container, "modulate:a", 1.0, 0.5)
	tween.tween_callback(new_game_button.grab_focus)
```

Key patterns:

- **`%NodeName` syntax** — unique name references. In the scene editor, mark a node as "unique" (right-click > Access as Unique Name). Then reference it with `%` instead of a fragile path like `$VBoxContainer/MarginContainer/MenuContainer`.
- **`modulate.a`** — the alpha channel of a node's color modulate. Setting it to `0.0` makes the node invisible; tweening it to `1.0` fades it in. This works on any node, not just Controls.
- **`0.0` fade for initial BGM** — the title music starts at full volume instantly. No need to crossfade from silence.

## HUD

The HUD is a CanvasLayer at layer 10 that shows persistent overworld information: party HP, gold, location name, and quest objectives. It hides during battles and cutscenes.

```gdscript
# ui/hud/hud.gd
extends CanvasLayer

@onready var _location_label: Label = %LocationLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _party_status: VBoxContainer = %PartyStatus
@onready var _interaction_prompt: Label = %InteractionPrompt
@onready var _objective_tracker: PanelContainer = %ObjectiveTracker


func _ready() -> void:
	visible = false
	_interaction_prompt.visible = false
	_objective_tracker.visible = false

	PartyManager.party_changed.connect(_on_party_changed)
	GameManager.game_state_changed.connect(_on_game_state_changed)
	GameManager.scene_changed.connect(_on_scene_changed)

	var inv: Node = get_node_or_null("/root/InventoryManager")
	if inv:
		inv.gold_changed.connect(_on_gold_changed)
```

### Responding to Game State

The HUD shows and hides based on the current game state:

```gdscript
func _on_game_state_changed(
	_old_state: GameManager.GameState,
	new_state: GameManager.GameState,
) -> void:
	match new_state:
		GameManager.GameState.OVERWORLD:
			visible = true
		GameManager.GameState.BATTLE, GameManager.GameState.CUTSCENE:
			visible = false
```

### Interaction Prompt

When the player is near an interactable object, the HUD shows a prompt:

```gdscript
func show_interaction_prompt(text: String) -> void:
	_interaction_prompt.text = text
	_interaction_prompt.visible = true


func hide_interaction_prompt() -> void:
	_interaction_prompt.visible = false
```

The interactable entity (from Chapter 8) calls these when the player enters or exits its detection area.

### Area Name Popup

When entering a new zone, the area name slides in from the top, holds briefly, then fades out:

```gdscript
var _area_name_popup: Label

func _setup_area_name_popup() -> void:
	_area_name_popup = Label.new()
	_area_name_popup.anchors_preset = Control.PRESET_CENTER_TOP
	_area_name_popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_area_name_popup.add_theme_font_size_override("font_size", 20)
	_area_name_popup.modulate.a = 0.0
	add_child(_area_name_popup)


func _show_area_name(area_name: String) -> void:
	_area_name_popup.text = area_name
	var tween := create_tween()
	tween.tween_property(_area_name_popup, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.0)  # hold for 2 seconds
	tween.tween_property(_area_name_popup, "modulate:a", 0.0, 0.5)
```

The `tween_interval()` call inserts a pause between the fade-in and fade-out. The three-step sequence — fade in, hold, fade out — is the standard toast notification pattern.

### Party Status Bars

The HUD displays HP bars for each active party member. The display is rebuilt whenever the party changes:

```gdscript
func update_party_display() -> void:
	for child in _party_status.get_children():
		child.queue_free()

	var party := PartyManager.get_active_party()
	for member in party:
		var row := _create_member_row(member)
		_party_status.add_child(row)


func _create_member_row(member: Resource) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var name_label := Label.new()
	name_label.text = member.display_name
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.custom_minimum_size.x = 48
	row.add_child(name_label)

	var hp_bar := ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(50, 8)
	hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hp_bar.show_percentage = false
	hp_bar.max_value = member.max_hp
	hp_bar.value = member.max_hp  # or read from PartyManager runtime state
	row.add_child(hp_bar)

	return row
```

**Why clear and rebuild instead of updating in place?** The party roster can change size — members join, leave, or swap between active and reserve. Rebuilding is simpler and more reliable than tracking which rows need updating, which need deleting, and which need creating. For a list of 4 items, the performance difference is negligible.

## Pause Menu

The pause menu opens when the player presses the `menu` input action. It pauses the scene tree, pushes a `MENU` game state, and presents sub-screens for party details, items, quests, and settings.

```gdscript
# ui/pause_menu/pause_menu.gd
extends CanvasLayer

signal menu_opened
signal menu_closed

var _is_open: bool = false

@onready var _menu_panel: PanelContainer = %MenuPanel
@onready var _party_button: Button = %PartyButton
@onready var _items_button: Button = %ItemsButton
@onready var _quests_button: Button = %QuestsButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_connect_buttons()
	UIHelpers.setup_focus_wrap([
		_party_button, _items_button, _quests_button,
		_settings_button, _quit_button,
	])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if _is_open:
			close()
			get_viewport().set_input_as_handled()
		elif _can_open():
			open()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("cancel") and _is_open:
		close()
		get_viewport().set_input_as_handled()
```

### Opening and Closing

```gdscript
func open() -> void:
	if _is_open:
		return
	_is_open = true
	visible = true
	GameManager.push_state(GameManager.GameState.MENU)
	get_tree().paused = true
	_party_button.grab_focus()
	menu_opened.emit()


func close() -> void:
	if not _is_open:
		return
	_is_open = false
	visible = false
	get_tree().paused = false
	GameManager.pop_state()
	menu_closed.emit()
```

Key decisions:

- **`process_mode = PROCESS_MODE_ALWAYS`** — the pause menu must still process input while the game is paused. Without this, pausing the game would also freeze the menu, making it impossible to unpause.
- **`get_tree().paused = true`** — pauses all nodes except those with `PROCESS_MODE_ALWAYS`. Game logic, enemy AI, and player movement freeze. Audio (which we set to `PROCESS_MODE_ALWAYS` in Chapter 17) continues.
- **`_unhandled_input`** instead of `_input` — unhandled input lets other systems (dialogue, battle) consume events first. The pause menu only processes input that nothing else has claimed.
- **`get_viewport().set_input_as_handled()`** — prevents the input from propagating further down the tree. Without this, pressing Escape might both close the menu and trigger another action.

### Sub-Screen Pattern

When the player selects "Items" from the pause menu, we open an inventory sub-screen. The pattern is consistent:

1. Hide the main menu panel
2. Instantiate the sub-screen
3. Add it as a child
4. Connect its "closed" signal
5. When it closes, free it and restore the main panel

```gdscript
var _inventory_ui: Control = null

func _open_inventory() -> void:
	if _inventory_ui != null:
		return
	_menu_panel.visible = false
	_inventory_ui = INVENTORY_UI_SCENE.instantiate()
	_inventory_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_inventory_ui)
	_inventory_ui.inventory_closed.connect(_on_inventory_closed)
	_inventory_ui.open()


func _on_inventory_closed() -> void:
	if _inventory_ui != null:
		_inventory_ui.queue_free()
		_inventory_ui = null
	_menu_panel.visible = true
	_items_button.grab_focus()
```

The null guard (`if _inventory_ui != null: return`) prevents double-opening. Restoring focus to `_items_button` after closing ensures the player can immediately continue navigating the menu.

## Battle UI

The battle UI is the most complex interface in the game. It manages command buttons, skill/item submenus, target selection, party status, a resonance gauge, and a scrolling battle log. It communicates with the battle state machine through signals.

### Architecture

The battle UI does not run the battle — it only displays state and captures input. The battle state machine (from Chapters 10-12) drives all logic. This separation keeps the UI testable and replaceable.

```
BattleScene (state machine)
    │
    ├── calls show_command_menu(battler)
    ├── calls update_party_status(party)
    ├── calls add_battle_log("Kael attacks!")
    │
    └── listens to ─┬─ command_selected("attack")
                    ├─ target_selected(battler)
                    ├─ skill_selected(ability)
                    └─ submenu_cancelled
```

### Signal-Based Communication

```gdscript
# ui/battle_ui/battle_ui.gd
extends CanvasLayer

signal command_selected(command: String)
signal target_selected(target: Battler)
signal skill_selected(ability: Resource)
signal item_selected(item: Resource)
signal submenu_cancelled
signal target_cancelled
```

The battle state machine connects to these signals and drives the flow:

```gdscript
# In the battle state machine:
battle_ui.command_selected.connect(_on_command_selected)
battle_ui.target_selected.connect(_on_target_selected)
```

### Command Menu

When it is a player-controlled battler's turn, the state machine calls `show_command_menu()`:

```gdscript
func show_command_menu(battler: Battler) -> void:
	_active_battler = battler
	_command_menu.visible = true
	_attack_button.grab_focus()
```

Each button emits the `command_selected` signal:

```gdscript
func _connect_command_buttons() -> void:
	_attack_button.pressed.connect(func() -> void:
		AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
		command_selected.emit("attack")
	)
	_skill_button.pressed.connect(func() -> void:
		AudioManager.play_sfx(load(SfxLibrary.UI_CONFIRM))
		command_selected.emit("skill")
	)
	# ... same pattern for item, defend, flee

	UIHelpers.setup_focus_wrap([
		_attack_button, _skill_button, _item_button,
		_defend_button, _flee_button,
	])
```

### Skill and Item Submenus

When the player selects "Skill," the state machine queries the battler's abilities and passes them to the UI:

```gdscript
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

	_skill_submenu.visible = true
	if _skill_list.get_child_count() > 0:
		_skill_list.get_child(0).grab_focus()
```

Skills the battler cannot afford (not enough EE) are shown but disabled. This is better UX than hiding them — the player can see what abilities exist and plan accordingly.

### Target Selection

After choosing an attack or skill, the player must select a target. The UI shows a cursor that moves between valid targets:

```gdscript
func show_target_selector(targets: Array[Battler]) -> void:
	_target_list = targets
	_target_index = 0
	_target_selector.visible = true
	_command_menu.visible = false
	_update_target_cursor()


func _update_target_cursor() -> void:
	if _target_list.is_empty():
		return
	var target := _target_list[_target_index]
	_target_selector.global_position = target.global_position + Vector2(0, -20)
```

Target cycling uses `_unhandled_input`:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
	if _target_selector.visible:
		if event.is_action_pressed("move_up") or event.is_action_pressed("move_left"):
			_target_index = wrapi(_target_index - 1, 0, _target_list.size())
			_update_target_cursor()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("move_down") or event.is_action_pressed("move_right"):
			_target_index = wrapi(_target_index + 1, 0, _target_list.size())
			_update_target_cursor()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("interact"):
			target_selected.emit(_target_list[_target_index])
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("cancel"):
			target_cancelled.emit()
			get_viewport().set_input_as_handled()
```

`wrapi()` is a Godot built-in that wraps an integer within a range — so pressing Down past the last target wraps to the first.

### Party Status Display

The battle UI shows HP and EE for each party member, updated after every action:

```gdscript
func update_party_status(party: Array[Battler]) -> void:
	UIHelpers.clear_children(_party_rows)
	for battler in party:
		var row := _create_party_row(battler)
		_party_rows.add_child(row)
```

HP bars change color when health is low:

```gdscript
var hp_ratio: float = float(battler.current_hp) / float(maxi(battler.max_hp, 1))
var hp_color := UITheme.HP_BAR_COLOR  # green
if hp_ratio <= UITheme.HP_LOW_THRESHOLD:  # 25%
	hp_color = UITheme.HP_BAR_LOW_COLOR  # red
hp_bar.add_theme_stylebox_override("fill", _create_color_stylebox(hp_color))
```

### Battle Log

A scrolling text log records every action — attacks, damage, status effects, and results:

```gdscript
func add_battle_log(text: String, log_type: int = UITheme.LogType.INFO) -> void:
	var color: Color = UITheme.get_log_color(log_type)
	var color_hex: String = color.to_html(false)
	_battle_log.append_text("[color=#%s]%s[/color]\n" % [color_hex, text])
	_battle_log.scroll_to_line(_battle_log.get_line_count() - 1)
```

The log uses `RichTextLabel` with BBCode formatting for colored text. Different message types get different colors — damage in red, healing in green, system messages in gold.

### Victory and Defeat Screens

After a battle concludes, the UI shows results:

```gdscript
func show_victory(exp: int, gold: int, items: Array[String]) -> void:
	hide_command_menu()
	_target_selector.visible = false
	_victory_exp_label.text = "EXP: +%d" % exp
	_victory_gold_label.text = "Gold: +%d" % gold
	_victory_items_label.text = ", ".join(items) if not items.is_empty() else ""
	_victory_screen.visible = true


func show_defeat() -> void:
	hide_command_menu()
	_target_selector.visible = false
	_defeat_screen.visible = true
	_retry_button.visible = SaveManager.has_save(0)
	if _retry_button.visible:
		_retry_button.grab_focus()
	else:
		_quit_button.grab_focus()
```

The defeat screen conditionally shows a "Load Last Save" button — only if a save file exists.

## Shop UI

The shop uses a tabbed interface with buy/sell modes, an item list, a detail panel, and a price display:

```gdscript
# ui/shop_ui/shop_ui.gd
extends CanvasLayer

signal shop_ui_closed

enum Mode { BUY, SELL }

var _mode: Mode = Mode.BUY
var _shop_data: ShopData = null


func open(shop_data: ShopData) -> void:
	_shop_data = shop_data
	_mode = Mode.BUY
	visible = true
	get_tree().paused = true
	_refresh_item_list()


func close() -> void:
	visible = false
	get_tree().paused = false
	shop_ui_closed.emit()
```

### Tab Switching

Tabs use styled buttons that indicate the active mode:

```gdscript
func _update_tab_styles() -> void:
	_buy_tab.add_theme_stylebox_override(
		"normal", _create_tab_style(_mode == Mode.BUY)
	)
	_sell_tab.add_theme_stylebox_override(
		"normal", _create_tab_style(_mode == Mode.SELL)
	)


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
```

### Cross-Panel Focus

The shop needs focus navigation between two areas — the item list on the left and the action button on the right:

```gdscript
func _setup_item_focus() -> void:
	UIHelpers.setup_focus_wrap(_item_buttons)
	# Wire right from item list to action button
	for btn in _item_buttons:
		btn.focus_neighbor_right = _action_button.get_path()
	# Wire left from action button back to item list
	if not _item_buttons.is_empty():
		_action_button.focus_neighbor_left = _item_buttons[0].get_path()
```

This creates a natural flow: navigate the item list with Up/Down, press Right to reach the Buy/Sell button, press Left to go back.

## Settings Menu

The settings menu provides volume sliders for Master, BGM, and SFX. It is a script-only Control (no `.tscn` file) that builds its entire UI programmatically:

```gdscript
# ui/settings_menu/settings_menu.gd
extends Control

signal settings_menu_closed

var _master_slider: HSlider
var _bgm_slider: HSlider
var _sfx_slider: HSlider


func _ready() -> void:
	_build_ui()
	_load_current_values()
	_master_slider.grab_focus()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)

	# Dim background
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	dim.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	# Center panel
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(PRESET_CENTER)
	panel.custom_minimum_size = Vector2(300, 200)
	panel.add_theme_stylebox_override("panel", UIHelpers.create_panel_style())
	add_child(panel)

	# Margin + VBox layout
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	# Volume sliders
	_master_slider = _create_slider(vbox, "Master")
	_bgm_slider = _create_slider(vbox, "Music")
	_sfx_slider = _create_slider(vbox, "Sound")

	_master_slider.value_changed.connect(_on_master_changed)
	_bgm_slider.value_changed.connect(_on_bgm_changed)
	_sfx_slider.value_changed.connect(_on_sfx_changed)

	UIHelpers.setup_focus_wrap([_master_slider, _bgm_slider, _sfx_slider])


func _create_slider(parent: Node, label_text: String) -> HSlider:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	parent.add_child(hbox)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size.x = 52
	label.add_theme_font_size_override("font_size", 11)
	hbox.add_child(label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = 100.0
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size.x = 120
	slider.focus_mode = Control.FOCUS_ALL
	hbox.add_child(slider)

	return slider
```

Sliders apply volume changes in real time — the player hears the effect immediately:

```gdscript
func _on_master_changed(value: float) -> void:
	SettingsData.apply_volume("Master", int(value))

func _on_bgm_changed(value: float) -> void:
	SettingsData.apply_volume("BGM", int(value))

func _on_sfx_changed(value: float) -> void:
	SettingsData.apply_volume("SFX", int(value))
```

When the menu closes, settings are saved to disk:

```gdscript
func close() -> void:
	SettingsData.save_settings(
		int(_master_slider.value),
		int(_bgm_slider.value),
		int(_sfx_slider.value),
	)
	settings_menu_closed.emit()
```

## How It Connects

- **AudioManager (Ch 17):** Every button press plays a UI SFX. BGM plays on scene enter. Settings menu adjusts bus volumes through AudioServer.
- **GameManager (Ch 5):** HUD visibility is driven by `game_state_changed`. Pause menu pushes/pops MENU state. Scene changes trigger area name popups.
- **PartyManager (Ch 9):** HUD reads active party for HP bars. Pause menu reads full roster for detail view.
- **InventoryManager (Ch 13):** HUD syncs gold display. Pause menu opens inventory sub-screen.
- **QuestManager (Ch 14):** HUD shows active quest objective. Pause menu opens quest log.
- **SaveManager (Ch 15):** Title screen checks for save data. Pause menu opens save dialog. Settings persist to separate JSON file.
- **BattleManager (Ch 10-12):** Battle UI receives commands via signals. State machine drives display updates.

## Common Mistakes

**Using `_input` instead of `_unhandled_input` for menus.** `_input` fires for every event, even ones already consumed by other nodes. `_unhandled_input` only fires for events that were not handled — meaning the dialogue box or battle UI gets priority.

**Forgetting `set_input_as_handled()`.** Without this, an input event consumed by the pause menu might also trigger something behind it — like the player starting to walk while the menu is open.

**Absolute positioning instead of containers.** Placing a label at pixel (120, 45) works on one screen resolution and breaks on every other. Use containers, anchor presets, and `custom_minimum_size` instead.

**Not setting `PROCESS_MODE_ALWAYS` on pause menu UI.** If the pause menu uses the default process mode, pausing the scene tree will also freeze the menu. The player will be stuck — paused with no way to unpause.

**Reusing StyleBoxFlat instances across theme overrides.** If you set `btn.add_theme_stylebox_override("hover", style)` and then `btn.add_theme_stylebox_override("focus", style)`, both overrides share the same object. Modifying one modifies both. Always call `style.duplicate()` when reusing a base style.

**Forgetting to grab focus when opening menus.** Without `grab_focus()`, the player must Tab or click to reach the first button. Every menu should focus its first interactive control in its open function.

## What Is Next

The systems work. The UI displays them. But everything still feels mechanical — menus appear and disappear instantly, damage is reported as text, and the world is static. In the next chapter, we add visual polish: screen shake, damage popups, companion followers, and animations that transform a functional game into one that feels alive.

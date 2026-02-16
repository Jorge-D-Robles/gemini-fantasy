---
name: new-ui
description: Create a new UI screen (menu, HUD, dialogue box, inventory screen, etc.) with proper Control node hierarchy, theme support, and keyboardgamepad navigation.
argument-hint: <ui-type> <name> [details...]
disable-model-invocation: true
---

# Create New UI Screen

Create a new UI screen for: **$ARGUMENTS**

## Step 1 — Determine UI Type

Parse arguments to determine the UI type:

| Type | Root Node | Key Children | Directory |
|------|-----------|-------------|-----------|
| `hud` | CanvasLayer > Control | MarginContainer, Labels, ProgressBars | `gameuihud/` |
| `menu` / `main-menu` | Control (full rect) | VBoxContainer with Buttons | `gameuimenus/` |
| `pause-menu` | CanvasLayer > Control | Panel, VBoxContainer, Buttons | `gameuimenus/` |
| `dialogue` / `dialog` | CanvasLayer > Control | Panel, NinePatchRect, RichTextLabel, Labels | `gameuidialogue/` |
| `inventory` | Control (full rect) | GridContainer, TextureRects, Labels | `gameuiinventory/` |
| `battle-hud` / `combat-ui` | CanvasLayer > Control | Party stats, Action menu, Enemy display | `gameuicombat/` |
| `character-screen` / `stats` | Control (full rect) | Labels, ProgressBars, TextureRects | `gameuiscreens/` |
| `shop` | Control (full rect) | ItemList, Labels, Buttons | `gameuiscreens/` |
| `popup` / `confirm` | Control | Panel, Label, Buttons | `gameuipopups/` |
| `title-screen` | Control (full rect) | TextureRect (background), VBoxContainer, Buttons | `gameuimenus/` |

## Step 2 — Look Up Documentation (MANDATORY — do not skip)

**You MUST complete ALL of these before writing any code:**

1. **Call the `godot-docs` skill** for the Control node types you will use:
   ```
   activate_skill("godot-docs") # Look up [Control types: e.g. MarginContainer, VBoxContainer, RichTextLabel, Button]. I need properties, methods, signals, and layout patterns for creating a [UI_TYPE] screen. Also include container layout, anchoring, and focus navigation tutorials.
   ```
2. **Read the UI best practices**:
   ```
   Read("docsbest-practices/08-ui-patterns.md")
   ```
3. If this UI has signals, also read `docsbest-practices/02-signals-and-communication.md`

## Step 3 — Create the Scene (.tscn)

Create a `.tscn` file with proper Control node hierarchy.

### Key Layout Principles

- Use **Containers** (VBox, HBox, Margin, Grid) for layout — never hardcode positions
- Set **anchors** to `FULL_RECT` on the root Control for responsive scaling
- Use **MarginContainer** for padding from screen edges
- Use **NinePatchRect** for scalable bordered panels
- Set **focus neighbors** for keyboardgamepad navigation
- Use **theme overrides** for consistent styling

### Scene File Structure

```
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res:/ui/<category>/<name>.gd" id="1"]

[node name="<RootName>" type="Control"]
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
script = ExtResource("1")

[node name="MarginContainer" type="MarginContainer" parent="."]
layout_mode = 1
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
theme_override_constantsmargin_left = 16
theme_override_constantsmargin_top = 16
theme_override_constantsmargin_right = 16
theme_override_constantsmargin_bottom = 16
```

## Step 4 — Create the Script (.gd)

Generate a UI script following these patterns:

```gdscript
class_name <PascalCaseName>
extends Control
## <Brief description of this UI screen.>


signal closed
signal <action_performed>(params)


@onready var <element_ref>: <ControlType> = $<Path/To/Node>


func _ready() -> void:
	_connect_signals()
	_initialize_display()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


## Show this UI screen.
func open() -> void:
	show()
	# Grab focus on the first interactive element
	# $MarginContainer/VBoxContainer/FirstButton.grab_focus()


## Hide this UI screen.
func close() -> void:
	hide()
	closed.emit()


## Update displayed data.
func refresh() -> void:
	pass


func _connect_signals() -> void:
	pass


func _initialize_display() -> void:
	pass
```

### UI Code Patterns

- Always provide `open()` and `close()` methods
- Emit `closed` signal when hiding so parent can react
- Handle `ui_cancel` action in `_unhandled_input` for backclose
- Call `grab_focus()` on the first interactive element when opening
- Use `_connect_signals()` in `_ready()` for clean signal wiring
- Use `refresh()` to update display from data (separates data from presentation)

## Step 5 — Set Up Focus/Navigation

For keyboardgamepad support:

1. Set `focus_mode = FOCUS_ALL` on interactive elements
2. Set `focus_neighbor_*` properties for navigation flow
3. Call `grab_focus()` on the default element when the screen opens
4. Handle `ui_cancel` for closinggoing back

## Step 6 — Report

After creating files, report:
1. Files created (with full paths)
2. Node hierarchy diagram
3. Signals defined
4. Focusnavigation flow
5. How to open this UI from other scripts
6. Suggested next steps (theming, data binding, animations)

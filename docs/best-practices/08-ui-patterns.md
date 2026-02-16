# UI Patterns Best Practices

Patterns for JRPG menus, HUDs, and dialogue systems in Godot.

## Container-Based Layout

**Always use containers** for UI layout. Never position Control nodes manually.

```
Panel (NinePatchRect for JRPG frame)
  └── MarginContainer (padding)
        └── VBoxContainer (vertical stacking)
              ├── Label (title)
              ├── HSeparator
              └── GridContainer (content grid)
```

## Anchor Strategy

- Root UI node: `FULL_RECT` anchors (fills parent)
- HUD elements: anchored to screen edges
- Popups/menus: centered or anchored to content area
- Use `MarginContainer` for consistent padding

## JRPG Menu Pattern

```gdscript
class_name GameMenu
extends Control

## Base pattern for JRPG menu screens.

signal closed

@export var open_sound: AudioStream
@export var close_sound: AudioStream
@export var cursor_sound: AudioStream

var _is_open: bool = false


func open() -> void:
	if _is_open:
		return
	_is_open = true
	visible = true
	_play_sound(open_sound)
	_refresh()
	_grab_initial_focus()


func close() -> void:
	if not _is_open:
		return
	_is_open = false
	_play_sound(close_sound)
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func _refresh() -> void:
	pass  # Override to update display


func _grab_initial_focus() -> void:
	pass  # Override to set first focusable element


func _play_sound(stream: AudioStream) -> void:
	if stream:
		AudioManager.play_sfx(stream)
```

## Focus Navigation for Gamepad/Keyboard

```gdscript
# Set focus neighbors for grid navigation
func _setup_focus(buttons: Array[Button]) -> void:
	for i in buttons.size():
		var btn := buttons[i]
		if i > 0:
			btn.focus_neighbor_top = buttons[i - 1].get_path()
		if i < buttons.size() - 1:
			btn.focus_neighbor_bottom = buttons[i + 1].get_path()
	# Wrap around
	buttons[0].focus_neighbor_top = buttons[-1].get_path()
	buttons[-1].focus_neighbor_bottom = buttons[0].get_path()
```

## Dialogue Box Pattern

```gdscript
class_name DialogueBox
extends CanvasLayer

signal dialogue_finished
signal choice_made(choice_index: int)

@onready var name_label: Label = $Panel/NameLabel
@onready var text_label: RichTextLabel = $Panel/TextLabel
@onready var portrait: TextureRect = $Panel/Portrait
@onready var advance_indicator: TextureRect = $Panel/AdvanceIndicator

var _is_typing: bool = false
var _current_speed: float = 0.03


func show_line(speaker: String, text: String, portrait_tex: Texture2D = null) -> void:
	name_label.text = speaker
	portrait.texture = portrait_tex
	text_label.text = text
	text_label.visible_ratio = 0.0
	_is_typing = true
	advance_indicator.visible = false

	var tween := create_tween()
	tween.tween_property(text_label, "visible_ratio", 1.0, text.length() * _current_speed)
	tween.tween_callback(_on_typing_finished)


func _on_typing_finished() -> void:
	_is_typing = false
	advance_indicator.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if _is_typing:
			text_label.visible_ratio = 1.0
			_on_typing_finished()
		else:
			dialogue_finished.emit()
		get_viewport().set_input_as_handled()
```

## Theme System

- Use a single `Theme` resource for the entire game
- Override font, font size, colors at the theme level
- Use `NinePatchRect` for JRPG-style window frames
- Create theme variations for different contexts (battle, menu, dialogue)

## UI Layering with CanvasLayer

```
CanvasLayer (layer 1) -- HUD (always visible)
CanvasLayer (layer 2) -- Menus (above HUD)
CanvasLayer (layer 3) -- Dialogue (above menus)
CanvasLayer (layer 4) -- Transitions (above everything)
```

## Anti-Patterns

- Manual positioning instead of containers
- Hard-coded pixel sizes (won't scale)
- Mouse-only UI (JRPGs need keyboard/gamepad)
- Forgetting `set_input_as_handled()` (input bleeds through)
- Not wrapping focus navigation (can't navigate past last item)
- Using `_process()` for typing effect (use Tween)

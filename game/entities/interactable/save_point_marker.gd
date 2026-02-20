class_name SavePointMarker
extends Node2D

## Persistent glowing ★ marker for save point interactables.
## Script-only component — no .tscn. Scene scripts add via SavePointMarker.new(),
## then add_child() to the save point node. Tweens start automatically in _ready()
## and loop until freed.

const UITheme = preload("res://ui/ui_theme.gd")

const GLYPH_TEXT: String = "★"
const GLYPH_FONT_SIZE: int = 12
const GLYPH_OFFSET_Y: float = -20.0
const PULSE_HALF_PERIOD: float = 0.8
const ALPHA_MIN: float = 0.4
const ALPHA_MAX: float = 1.0

var _glyph: Label = null
var _pulse_tween: Tween = null


func _ready() -> void:
	z_index = 1
	_glyph = Label.new()
	_glyph.text = GLYPH_TEXT
	_glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_glyph.position = Vector2(-6.0, GLYPH_OFFSET_Y)
	_glyph.custom_minimum_size = Vector2(12.0, 0.0)
	_glyph.add_theme_font_size_override("font_size", GLYPH_FONT_SIZE)
	_glyph.add_theme_color_override("font_color", UITheme.TEXT_GOLD)
	_glyph.modulate.a = ALPHA_MAX
	add_child(_glyph)

	_pulse_tween = create_tween().set_loops()
	_pulse_tween.set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(_glyph, "modulate:a", ALPHA_MIN, PULSE_HALF_PERIOD)
	_pulse_tween.tween_property(_glyph, "modulate:a", ALPHA_MAX, PULSE_HALF_PERIOD)


func _exit_tree() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()

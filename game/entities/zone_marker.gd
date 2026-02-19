class_name ZoneMarker
extends Node2D

## Animated chevron arrow marking zone transition exits.
## Set direction, marker_color, and destination_name before add_child().
## Tweens start automatically in _ready() and loop until freed.

enum Direction {
	LEFT,
	RIGHT,
	UP,
	DOWN,
}

const DEFAULT_COLOR := Color(1.0, 0.9, 0.5, 1.0)
const CHEVRON_SIZE: float = 6.0
const ALPHA_MIN: float = 0.3
const ALPHA_MAX: float = 1.0
const ALPHA_DURATION: float = 1.2
const BOB_DISTANCE: float = 3.0
const BOB_DURATION: float = 1.6
const LABEL_FONT_SIZE: int = 7
const LABEL_OFFSET_Y: float = 10.0

var direction: Direction = Direction.RIGHT
var marker_color: Color = DEFAULT_COLOR
var destination_name: String = ""

var _alpha_tween: Tween
var _bob_tween: Tween
var _destination_label: Label


func _ready() -> void:
	z_index = 1
	_start_animation()
	if not destination_name.is_empty():
		_create_destination_label()


func _exit_tree() -> void:
	if _alpha_tween:
		_alpha_tween.kill()
	if _bob_tween:
		_bob_tween.kill()


func _draw() -> void:
	var pts: PackedVector2Array = _get_chevron_points()
	draw_colored_polygon(pts, marker_color)


func _start_animation() -> void:
	# Alpha pulse via modulate:a
	_alpha_tween = create_tween()
	_alpha_tween.set_loops(0)
	_alpha_tween.tween_property(
		self, "modulate:a", ALPHA_MIN, ALPHA_DURATION / 2.0,
	).set_trans(Tween.TRANS_SINE).from(ALPHA_MAX)
	_alpha_tween.tween_property(
		self, "modulate:a", ALPHA_MAX, ALPHA_DURATION / 2.0,
	).set_trans(Tween.TRANS_SINE)

	# Directional bob along arrow axis
	var prop: String = _get_bob_property()
	var base_val: float = (
		position.x if prop == "position:x" else position.y
	)
	_bob_tween = create_tween()
	_bob_tween.set_loops(0)
	_bob_tween.tween_property(
		self, prop,
		base_val + BOB_DISTANCE * _get_bob_sign(),
		BOB_DURATION / 2.0,
	).set_trans(Tween.TRANS_SINE)
	_bob_tween.tween_property(
		self, prop,
		base_val - BOB_DISTANCE * _get_bob_sign(),
		BOB_DURATION / 2.0,
	).set_trans(Tween.TRANS_SINE)


func _create_destination_label() -> void:
	_destination_label = Label.new()
	_destination_label.text = destination_name
	_destination_label.add_theme_font_size_override(
		"font_size", LABEL_FONT_SIZE,
	)
	_destination_label.add_theme_color_override(
		"font_color", marker_color,
	)
	_destination_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	_destination_label.position.y = LABEL_OFFSET_Y
	_destination_label.position.x = -30
	_destination_label.custom_minimum_size.x = 60
	add_child(_destination_label)


func _get_chevron_points() -> PackedVector2Array:
	var s: float = CHEVRON_SIZE
	match direction:
		Direction.LEFT:
			return PackedVector2Array([
				Vector2(s, -s),
				Vector2(0, 0),
				Vector2(s, s),
				Vector2(s * 0.4, 0),
			])
		Direction.UP:
			return PackedVector2Array([
				Vector2(-s, s),
				Vector2(0, 0),
				Vector2(s, s),
				Vector2(0, s * 0.4),
			])
		Direction.DOWN:
			return PackedVector2Array([
				Vector2(-s, -s),
				Vector2(0, 0),
				Vector2(s, -s),
				Vector2(0, -s * 0.4),
			])
		_:  # RIGHT (default)
			return PackedVector2Array([
				Vector2(-s, -s),
				Vector2(0, 0),
				Vector2(-s, s),
				Vector2(-s * 0.4, 0),
			])


func _get_bob_property() -> String:
	match direction:
		Direction.UP, Direction.DOWN:
			return "position:y"
		_:
			return "position:x"


func _get_bob_sign() -> float:
	match direction:
		Direction.LEFT, Direction.UP:
			return -1.0
		_:
			return 1.0

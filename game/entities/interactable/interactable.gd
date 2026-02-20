class_name Interactable
extends StaticBody2D

## Generic interactable object. Delegates behavior to an InteractionStrategy
## resource (sign, chest, save point, item pickup, door, etc.).
## Shows a floating indicator icon when the player is in range.

signal interacted

enum IndicatorType {
	NONE = 0,
	INTERACT = 1,
	SAVE = 2,
}

const _INDICATOR_ICONS: Dictionary = {
	IndicatorType.INTERACT: "!",
	IndicatorType.SAVE: "★",
}

const _INDICATOR_OFFSET_Y: float = -28.0
const _BOB_AMOUNT: float = 2.0
const _BOB_HALF_DURATION: float = 0.6

const UITheme = preload("res://ui/ui_theme.gd")

@export var strategy: InteractionStrategy
@export var one_time: bool = true
@export var indicator_type: IndicatorType = IndicatorType.NONE:
	set(value):
		indicator_type = value
		if is_node_ready():
			_update_indicator()

var has_been_used: bool = false
var _player_in_range: bool = false
var _indicator: Label
var _indicator_tween: Tween

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea


static func compute_indicator_text(type: IndicatorType) -> String:
	return _INDICATOR_ICONS.get(type, "")


static func compute_indicator_visible(
	player_in_range: bool,
	has_been_used: bool,
	is_one_time: bool,
) -> bool:
	if not player_in_range:
		return false
	if is_one_time and has_been_used:
		return false
	return true


func _ready() -> void:
	add_to_group("interactables")
	if strategy == null:
		push_warning("Interactable '%s' has no strategy assigned." % name)
	_update_indicator()
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered_range)
		interaction_area.body_exited.connect(_on_body_exited_range)


func _exit_tree() -> void:
	if _indicator_tween:
		_indicator_tween.kill()


func interact() -> void:
	if one_time and has_been_used:
		return
	if strategy == null:
		return

	strategy.execute(self)
	interacted.emit()
	var bus := get_node_or_null("/root/EventBus")
	if bus:
		bus.emit_interactable_used(name)

	if one_time:
		has_been_used = true
		if _indicator:
			_indicator.visible = false


func _update_indicator() -> void:
	if _indicator_tween:
		_indicator_tween.kill()
		_indicator_tween = null
	if _indicator:
		_indicator.queue_free()
		_indicator = null

	if indicator_type == IndicatorType.NONE:
		return

	_indicator = Label.new()
	_indicator.text = compute_indicator_text(indicator_type)
	_indicator.position = Vector2(0.0, _INDICATOR_OFFSET_Y)
	_indicator.z_index = 1
	_indicator.visible = false
	_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicator.add_theme_font_size_override("font_size", 10)
	_indicator.add_theme_color_override("font_color", _get_indicator_color())
	add_child(_indicator)

	_indicator_tween = create_tween()
	_indicator_tween.set_loops(0)
	_indicator_tween.set_trans(Tween.TRANS_SINE)
	_indicator_tween.tween_property(
		_indicator, "position:y",
		_INDICATOR_OFFSET_Y - _BOB_AMOUNT, _BOB_HALF_DURATION
	)
	_indicator_tween.tween_property(
		_indicator, "position:y",
		_INDICATOR_OFFSET_Y + _BOB_AMOUNT, _BOB_HALF_DURATION
	)


func _get_indicator_color() -> Color:
	match indicator_type:
		IndicatorType.SAVE:
			return UITheme.TEXT_GOLD
		_:
			return Color.WHITE


func _on_body_entered_range(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	if _indicator and compute_indicator_visible(true, has_been_used, one_time):
		_indicator.visible = true


func _on_body_exited_range(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = false
	if _indicator:
		_indicator.visible = false

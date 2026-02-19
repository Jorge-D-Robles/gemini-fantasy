class_name DamagePopup
extends Node2D

## Reusable floating damage/heal number that animates upward and fades out.
## Instantiate via DamagePopup.new(), add_child(), then call setup().
## Self-destructs via queue_free() after animation completes.

enum PopupType {
	DAMAGE,
	HEAL,
	CRITICAL,
}

const UITheme = preload("res://ui/ui_theme.gd")

const POPUP_DURATION: float = 0.8
const FLOAT_DISTANCE: float = 30.0
const FADE_DELAY: float = 0.3
const BASE_FONT_SIZE: int = 10
const CRITICAL_FONT_SIZE: int = 14
const X_OFFSET_RANGE: float = 8.0

const POPUP_COLORS: Dictionary = {
	PopupType.DAMAGE: UITheme.LOG_DAMAGE,
	PopupType.HEAL: UITheme.LOG_HEAL,
	PopupType.CRITICAL: UITheme.POPUP_CRITICAL,
}

var _label: Label


func _ready() -> void:
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", BASE_FONT_SIZE)
	add_child(_label)


## Configures text, color, and starts the float-up + fade animation.
## Call immediately after add_child(). Fire-and-forget — not awaitable.
func setup(amount: int, type: PopupType = PopupType.DAMAGE) -> void:
	var color: Color = POPUP_COLORS.get(type, UITheme.LOG_DAMAGE)
	_label.add_theme_color_override("font_color", color)

	match type:
		PopupType.HEAL:
			_label.text = "+%d" % amount
		PopupType.CRITICAL:
			_label.text = "%d!" % amount
			_label.add_theme_font_size_override(
				"font_size", CRITICAL_FONT_SIZE,
			)
		_:
			_label.text = str(amount)

	var rand_x := randf_range(-X_OFFSET_RANGE, X_OFFSET_RANGE)
	position = Vector2(rand_x, -20.0)

	_animate()


func _animate() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		self, "position:y",
		position.y - FLOAT_DISTANCE, POPUP_DURATION,
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self, "modulate:a", 0.0, POPUP_DURATION - FADE_DELAY,
	).set_delay(FADE_DELAY)
	tween.chain().tween_callback(queue_free)

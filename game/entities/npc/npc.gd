class_name NPC
extends StaticBody2D

## Base NPC scene. Supports dialogue via DialogueManager
## and optionally faces the player on interaction.
## Includes floating indicator icons above NPC head.

signal interaction_started
signal interaction_ended

enum IndicatorType {
	NONE = 0,
	CHAT = 1,
	QUEST = 2,
	QUEST_ACTIVE = 3,
	SHOP = 4,
}

const _INDICATOR_ICONS: Dictionary = {
	IndicatorType.CHAT: "...",
	IndicatorType.QUEST: "!",
	IndicatorType.QUEST_ACTIVE: "?",
	IndicatorType.SHOP: "$",
}

const _INDICATOR_OFFSET_Y: float = -24.0
const _BOB_AMOUNT: float = 2.0
const _BOB_HALF_DURATION: float = 0.6

const UITheme = preload("res://ui/ui_theme.gd")

@export var npc_name: String = ""
@export var dialogue_lines: Array[String] = []
@export var portrait_path: String = ""
@export var face_player: bool = true
@export var indicator_type: IndicatorType = IndicatorType.NONE:
	set(value):
		indicator_type = value
		if is_node_ready():
			_update_indicator()

var _is_talking: bool = false
var _player_in_range: bool = false
var _indicator: Label
var _indicator_tween: Tween

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = $InteractionArea


func _ready() -> void:
	add_to_group("npcs")
	_update_indicator()
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered_range)
		interaction_area.body_exited.connect(_on_body_exited_range)


func _exit_tree() -> void:
	if _indicator_tween:
		_indicator_tween.kill()


func interact() -> void:
	if dialogue_lines.is_empty():
		return
	if _is_talking:
		return

	if face_player:
		_face_toward_player()

	_is_talking = true
	if _indicator:
		_indicator.visible = false
	interaction_started.emit()
	var bus := get_node_or_null("/root/EventBus")
	if bus:
		bus.emit_npc_talked_to(npc_name)

	var lines: Array[DialogueLine] = []
	var portrait: Texture2D = null
	if not portrait_path.is_empty():
		portrait = load(portrait_path) as Texture2D
		if portrait == null:
			push_warning(
				"NPC '%s': portrait failed to load '%s'"
				% [npc_name, portrait_path]
			)

	for line_text in dialogue_lines:
		lines.append(DialogueLine.create(npc_name, line_text, portrait))

	DialogueManager.dialogue_ended.connect(
		_on_dialogue_ended, CONNECT_ONE_SHOT
	)
	DialogueManager.start_dialogue(lines)


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
	_indicator.text = _INDICATOR_ICONS.get(indicator_type, "")
	_indicator.position = Vector2(0.0, _INDICATOR_OFFSET_Y)
	_indicator.z_index = 1
	_indicator.visible = false
	_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_indicator.add_theme_font_size_override("font_size", 10)
	_indicator.add_theme_color_override(
		"font_color", _get_indicator_color()
	)
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
		IndicatorType.QUEST, IndicatorType.SHOP:
			return UITheme.TEXT_GOLD
		IndicatorType.QUEST_ACTIVE:
			return UITheme.TEXT_PRIMARY
		_:
			return Color.WHITE


func _on_body_entered_range(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = true
	if _indicator and not _is_talking:
		_indicator.visible = true


func _on_body_exited_range(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_in_range = false
	if _indicator:
		_indicator.visible = false


func _face_toward_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return
	var dir: Vector2 = (
		(player.global_position - global_position).normalized()
	)
	if absf(dir.x) > absf(dir.y):
		sprite.flip_h = dir.x < 0.0


func _on_dialogue_ended() -> void:
	_is_talking = false
	if _indicator and _player_in_range:
		_indicator.visible = true
	interaction_ended.emit()
	var bus := get_node_or_null("/root/EventBus")
	if bus:
		bus.emit_npc_interaction_ended(npc_name)

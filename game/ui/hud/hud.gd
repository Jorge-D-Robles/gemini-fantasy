extends CanvasLayer

## Overworld HUD showing location, gold, party status, interaction prompts.

@export var location_name: String = "" :
	set(value):
		location_name = value
		if is_node_ready():
			_location_label.text = value

var _gold: int = 0

@onready var _location_label: Label = %LocationLabel
@onready var _gold_label: Label = %GoldLabel
@onready var _party_status: VBoxContainer = %PartyStatus
@onready var _interaction_prompt: Label = %InteractionPrompt


func _ready() -> void:
	_interaction_prompt.visible = false
	_location_label.text = location_name
	_update_gold_display()
	update_party_display()

	PartyManager.party_changed.connect(_on_party_changed)
	GameManager.game_state_changed.connect(_on_game_state_changed)


func show_interaction_prompt(text: String) -> void:
	_interaction_prompt.text = text
	_interaction_prompt.visible = true


func hide_interaction_prompt() -> void:
	_interaction_prompt.visible = false


func update_party_display() -> void:
	for child in _party_status.get_children():
		child.queue_free()

	var party := PartyManager.get_active_party()
	for member in party:
		var row := _create_member_row(member)
		_party_status.add_child(row)


func set_gold(amount: int) -> void:
	_gold = amount
	_update_gold_display()


func _update_gold_display() -> void:
	_gold_label.text = "Gold: %d" % _gold


func _create_member_row(member: Resource) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var data := member as BattlerData

	var name_label := Label.new()
	name_label.text = data.display_name if data else "???"
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.custom_minimum_size.x = 48
	row.add_child(name_label)

	var max_val: int = data.max_hp if data else 100

	var hp_bar := ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(50, 8)
	hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hp_bar.show_percentage = false
	hp_bar.max_value = max_val
	hp_bar.value = max_val
	hp_bar.add_theme_color_override(
		"font_color", Color(0.2, 0.8, 0.2)
	)
	row.add_child(hp_bar)

	var hp_label := Label.new()
	hp_label.text = "%d/%d" % [max_val, max_val]
	hp_label.add_theme_font_size_override("font_size", 8)
	row.add_child(hp_label)

	return row


func _on_party_changed() -> void:
	update_party_display()


func _on_game_state_changed(
	_old_state: GameManager.GameState,
	new_state: GameManager.GameState,
) -> void:
	match new_state:
		GameManager.GameState.OVERWORLD:
			visible = true
		GameManager.GameState.BATTLE, GameManager.GameState.CUTSCENE:
			visible = false
		_:
			pass

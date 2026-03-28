extends PanelContainer
## The main battle action menu.

signal action_chosen(action: String)

@onready var _attack_btn: Button = $MarginContainer/ActionList/AttackButton
@onready var _magic_btn: Button = $MarginContainer/ActionList/MagicButton
@onready var _defend_btn: Button = $MarginContainer/ActionList/DefendButton
@onready var _item_btn: Button = $MarginContainer/ActionList/ItemButton
@onready var _flee_btn: Button = $MarginContainer/ActionList/FleeButton


func _ready() -> void:
	_attack_btn.pressed.connect(func() -> void: action_chosen.emit("attack"))
	_magic_btn.pressed.connect(func() -> void: action_chosen.emit("magic"))
	_defend_btn.pressed.connect(func() -> void: action_chosen.emit("defend"))
	_item_btn.pressed.connect(func() -> void: action_chosen.emit("item"))
	_flee_btn.pressed.connect(func() -> void: action_chosen.emit("flee"))


func show_menu() -> void:
	visible = true
	_attack_btn.grab_focus()


func hide_menu() -> void:
	visible = false

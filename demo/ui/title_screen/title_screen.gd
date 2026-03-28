extends Control
## The game's title screen.

@onready var _new_game_btn: Button = $MenuContainer/NewGameButton
@onready var _continue_btn: Button = $MenuContainer/ContinueButton
@onready var _settings_btn: Button = $MenuContainer/SettingsButton


func _ready() -> void:
	_new_game_btn.pressed.connect(_on_new_game)
	_continue_btn.pressed.connect(_on_continue)
	_settings_btn.pressed.connect(_on_settings)
	_continue_btn.disabled = not _any_saves_exist()
	_new_game_btn.grab_focus()


func _on_new_game() -> void:
	_initialize_fresh_state()
	SceneManager.change_scene("res://scenes/willowbrook/willowbrook.tscn")


func _on_continue() -> void:
	SaveManager.load_game(1)


func _on_settings() -> void:
	var settings_scene := preload("res://ui/settings/settings_panel.tscn")
	var panel: PanelContainer = settings_scene.instantiate()
	add_child(panel)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grab_focus()


func _initialize_fresh_state() -> void:
	GameManager.load_flags({})
	InventoryManager.from_save_data({gold = 100, items = []})
	var potion: ItemData = load("res://data/items/potion.tres")
	if potion:
		InventoryManager.add_item(potion, 3)
	PartyManager.from_save_data({members = []})
	var aiden: CharacterData = load("res://data/characters/aiden.tres")
	if aiden:
		aiden = aiden.duplicate()
		aiden.current_hp = aiden.max_hp
		aiden.current_mp = aiden.max_mp
		aiden.current_xp = 0
		aiden.level = 1
		PartyManager.add_member(aiden)
	QuestManager.from_save_data({active = [], completed = [], turned_in = []})


func _any_saves_exist() -> bool:
	for i in range(1, SaveManager.MAX_SLOTS + 1):
		if SaveManager.slot_exists(i):
			return true
	return false

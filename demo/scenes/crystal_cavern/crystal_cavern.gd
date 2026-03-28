extends Node2D
## Crystal Cavern dungeon scene.

@onready var _encounter_system: Node = $EncounterSystem


func _ready() -> void:
	GameManager.set_flag("entered_crystal_cavern")
	_encounter_system.encounter_triggered.connect(_on_encounter_triggered)


func _on_encounter_triggered(encounter: EncounterData) -> void:
	var enemy_battlers: Array[BattlerData] = []
	for ed in encounter.enemies:
		var battler := BattlerData.new()
		var char_data := CharacterData.new()
		char_data.display_name = ed.display_name
		char_data.max_hp = ed.max_hp
		char_data.attack = ed.attack
		char_data.defense = ed.defense
		char_data.speed = ed.speed
		battler.character_data = char_data
		battler.is_player_controlled = false
		battler.enemy_data = ed
		enemy_battlers.append(battler)

	var party_battlers: Array[BattlerData] = []
	for char_data in PartyManager.get_members():
		var battler := BattlerData.new()
		battler.character_data = char_data
		battler.is_player_controlled = true
		party_battlers.append(battler)

	SceneManager.start_battle({party = party_battlers, enemies = enemy_battlers})

extends Area2D
## Triggers the boss fight with a pre-battle cutscene.

@export var boss_data: EnemyData
var _triggered: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not _triggered:
		_triggered = true
		_start_boss_sequence()


func _start_boss_sequence() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("set_disabled"):
		player.set_disabled(true)

	var line := DialogueLine.new()
	line.speaker_name = "Crystal Guardian"
	line.text = "You dare disturb the crystals? Prepare yourself!"

	var dialogue_box = get_tree().current_scene.get_node_or_null("DialogueBox")
	if dialogue_box:
		dialogue_box.start_dialogue([line])
		await dialogue_box.dialogue_finished

	if player and player.has_method("set_disabled"):
		player.set_disabled(false)

	_start_boss_battle()


func _start_boss_battle() -> void:
	var party_battlers: Array[BattlerData] = []
	for char_data in PartyManager.get_members():
		var battler := BattlerData.new()
		battler.character_data = char_data
		battler.is_player_controlled = true
		party_battlers.append(battler)

	var boss_char := CharacterData.new()
	boss_char.display_name = boss_data.display_name
	boss_char.max_hp = boss_data.max_hp
	boss_char.attack = boss_data.attack
	boss_char.defense = boss_data.defense
	boss_char.speed = boss_data.speed

	var boss := BattlerData.new()
	boss.character_data = boss_char
	boss.is_player_controlled = false
	boss.enemy_data = boss_data

	SceneManager.start_battle({party = party_battlers, enemies = [boss]})

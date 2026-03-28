extends Resource
class_name BattlerData
## Runtime data for a combatant in battle.

@export var character_data: CharacterData
@export var is_player_controlled: bool = true

var current_hp: int = 0
var current_mp: int = 0
var current_attack: int = 0
var current_defense: int = 0
var current_speed: int = 0
var defense_boost: int = 0

var enemy_data: EnemyData = null


func initialize_from_character() -> void:
	if not character_data:
		return
	current_hp = character_data.current_hp if character_data.current_hp > 0 else character_data.max_hp
	current_mp = character_data.current_mp if character_data.current_mp > 0 else character_data.max_mp
	current_attack = character_data.get_effective_attack()
	current_defense = character_data.get_effective_defense()
	current_speed = character_data.get_effective_speed()


func get_effective_defense() -> int:
	return current_defense + defense_boost


func is_alive() -> bool:
	return current_hp > 0


func take_damage(amount: int) -> int:
	var actual_damage: int = max(1, amount)
	current_hp = max(0, current_hp - actual_damage)
	return actual_damage


func heal(amount: int) -> int:
	var old_hp := current_hp
	current_hp = min(current_hp + amount, character_data.max_hp)
	return current_hp - old_hp

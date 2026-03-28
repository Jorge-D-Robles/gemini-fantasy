extends Node2D
## Visual representation of a combatant in battle.

var battler_data: BattlerData

@onready var _sprite: Sprite2D = $Sprite


func setup(data: BattlerData) -> void:
	battler_data = data
	add_to_group("battler_sprites")
	if data.character_data and data.character_data.portrait:
		_sprite.texture = data.character_data.portrait
	else:
		_sprite.texture = preload("res://icon.svg")

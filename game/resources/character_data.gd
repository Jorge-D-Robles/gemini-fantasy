class_name CharacterData
extends BattlerData

## Defines a playable character's growth rates and visual metadata.

enum DamageStat {
	ATTACK,
	MAGIC,
}

@export_group("Growth Rates")
@export var hp_growth: float = 10.0
@export var ee_growth: float = 5.0
@export var attack_growth: float = 1.5
@export var magic_growth: float = 1.5
@export var defense_growth: float = 1.5
@export var resistance_growth: float = 1.5
@export var speed_growth: float = 1.0
@export var luck_growth: float = 1.0

@export_group("Visuals")
@export var portrait_path: String = ""
@export var sprite_path: String = ""
@export var battle_sprite_path: String = ""

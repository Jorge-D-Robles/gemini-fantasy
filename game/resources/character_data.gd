class_name CharacterData
extends Resource

## Defines a playable character's base stats, growth rates, and metadata.

enum DamageStat {
	ATTACK,
	MAGIC,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Base Stats")
@export var max_hp: int = 100
@export var max_ee: int = 50
@export var attack: int = 10
@export var magic: int = 10
@export var defense: int = 10
@export var resistance: int = 10
@export var speed: int = 10
@export var luck: int = 10

@export_group("Growth Rates")
@export var hp_growth: float = 10.0
@export var ee_growth: float = 5.0
@export var attack_growth: float = 1.5
@export var magic_growth: float = 1.5
@export var defense_growth: float = 1.5
@export var resistance_growth: float = 1.5
@export var speed_growth: float = 1.0
@export var luck_growth: float = 1.0

@export_group("Abilities")
@export var abilities: Array[Resource] = []

@export_group("Visuals")
@export var portrait_path: String = ""
@export var sprite_path: String = ""
@export var battle_sprite_path: String = ""

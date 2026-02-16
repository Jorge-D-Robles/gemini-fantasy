class_name AbilityData
extends Resource

## Defines an ability's cost, damage, targeting, and effects.

enum DamageStat {
	ATTACK,
	MAGIC,
}

enum TargetType {
	SINGLE_ENEMY,
	ALL_ENEMIES,
	SINGLE_ALLY,
	ALL_ALLIES,
	SELF,
}

enum Element {
	NONE,
	FIRE,
	ICE,
	WATER,
	WIND,
	EARTH,
	LIGHT,
	DARK,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Cost")
@export var ee_cost: int = 0
@export var resonance_cost: float = 0.0

@export_group("Damage")
@export var damage_base: int = 0
@export var damage_stat: DamageStat = DamageStat.ATTACK

@export_group("Targeting")
@export var target_type: TargetType = TargetType.SINGLE_ENEMY
@export var element: Element = Element.NONE

@export_group("Status Effect")
@export var status_effect: String = ""
@export var status_chance: float = 0.0

@export_group("Visuals")
@export var animation_name: String = ""

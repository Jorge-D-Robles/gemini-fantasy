class_name EchoData
extends Resource

## Defines an Echo Fragment's rarity, type, and battle effect.

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY,
	UNIQUE,
}

enum EchoType {
	ATTACK,
	SUPPORT,
	DEBUFF,
	UNIQUE_ECHO,
}

enum EffectType {
	DAMAGE,
	HEAL,
	BUFF,
	DEBUFF,
	SPECIAL,
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

enum TargetType {
	SINGLE_ENEMY,
	ALL_ENEMIES,
	SINGLE_ALLY,
	ALL_ALLIES,
	SELF,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_multiline var lore_text: String = ""

@export_group("Classification")
@export var rarity: Rarity = Rarity.COMMON
@export var echo_type: EchoType = EchoType.ATTACK

@export_group("Effect")
@export var effect_type: EffectType = EffectType.DAMAGE
@export var effect_value: int = 0
@export var element: Element = Element.NONE
@export var target_type: TargetType = TargetType.SINGLE_ENEMY
@export var uses_per_battle: int = 1

@export_group("Visuals")
@export var icon_path: String = ""

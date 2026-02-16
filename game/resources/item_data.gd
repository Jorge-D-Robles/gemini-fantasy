class_name ItemData
extends Resource

## Defines an item's type, effect, targeting, and shop pricing.

enum ItemType {
	CONSUMABLE,
	KEY_ITEM,
	MATERIAL,
}

enum EffectType {
	HEAL_HP,
	HEAL_EE,
	CURE_STATUS,
	REVIVE,
	BUFF,
	DAMAGE,
}

enum TargetType {
	SINGLE_ALLY,
	ALL_ALLIES,
	SINGLE_ENEMY,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Type")
@export var item_type: ItemType = ItemType.CONSUMABLE

@export_group("Effect")
@export var effect_type: EffectType = EffectType.HEAL_HP
@export var effect_value: int = 0
@export var target_type: TargetType = TargetType.SINGLE_ALLY

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0
@export var max_stack: int = 99

@export_group("Visuals")
@export var icon_path: String = ""

@export_group("Usage")
@export var usable_in_battle: bool = true

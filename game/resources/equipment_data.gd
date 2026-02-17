class_name EquipmentData
extends Resource

## Defines an equipment piece's stats, slot, and type restrictions.

enum SlotType {
	WEAPON,
	HELMET,
	CHEST,
	ACCESSORY,
}

enum WeaponType {
	NONE,
	SWORD,
	DAGGER,
	HAMMER,
	RIFLE,
	SHIELD,
	MACE,
	STAFF,
	ORB,
	BOOK,
	ROD,
	DUAL_BLADES,
	HANDGUN,
	CRYSTAL,
	GRIMOIRE,
	BELL,
	TOTEM,
}

@export_group("Identity")
@export var id: StringName = &""
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("Slot")
@export var slot_type: SlotType = SlotType.WEAPON
@export var weapon_type: WeaponType = WeaponType.NONE

@export_group("Stat Bonuses")
@export var attack_bonus: int = 0
@export var magic_bonus: int = 0
@export var defense_bonus: int = 0
@export var resistance_bonus: int = 0
@export var speed_bonus: int = 0
@export var luck_bonus: int = 0
@export var max_hp_bonus: int = 0
@export var max_ee_bonus: int = 0

@export_group("Properties")
@export var element: AbilityData.Element = AbilityData.Element.NONE
@export var crit_rate_bonus: float = 0.0

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0

@export_group("Visuals")
@export var icon_path: String = ""

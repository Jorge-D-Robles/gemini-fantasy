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

@export_group("Resonance Tuning")
## Number of Echo Fragment slots (0-3). Common: 1, Rare: 2, Legendary: 3.
@export_range(0, 3) var tuning_slots: int = 0
## Echo Fragments currently tuned into this equipment.
@export var tuned_echoes: Array[Resource] = []

@export_group("Economy")
@export var buy_price: int = 0
@export var sell_price: int = 0

@export_group("Visuals")
@export var icon_path: String = ""


func can_tune() -> bool:
	return tuned_echoes.size() < tuning_slots


func tune_echo(echo: Resource) -> bool:
	if not can_tune():
		return false
	tuned_echoes.append(echo)
	return true


func replace_echo(slot_index: int, echo: Resource) -> Resource:
	if slot_index < 0 or slot_index >= tuned_echoes.size():
		return null
	var old := tuned_echoes[slot_index]
	tuned_echoes[slot_index] = echo
	return old


func remove_echo(slot_index: int) -> Resource:
	if slot_index < 0 or slot_index >= tuned_echoes.size():
		return null
	var old := tuned_echoes[slot_index]
	tuned_echoes.remove_at(slot_index)
	return old

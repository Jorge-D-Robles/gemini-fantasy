extends Resource
class_name CharacterData
## Base data for a party member or NPC.

@export var id: String = ""
@export var display_name: String = ""
@export var portrait: Texture2D
@export var overworld_sprite: SpriteFrames

@export_group("Base Stats")
@export var max_hp: int = 100
@export var max_mp: int = 20
@export var attack: int = 10
@export var defense: int = 8
@export var speed: int = 10
@export var level: int = 1

@export_group("Growth per Level")
@export var hp_growth: int = 12
@export var mp_growth: int = 4
@export var attack_growth: int = 2
@export var defense_growth: int = 1
@export var speed_growth: int = 1

# Runtime state (not saved to .tres)
var current_xp: int = 0
var current_hp: int = 0
var current_mp: int = 0

# Equipment slots
var equipped_weapon: ItemData = null
var equipped_armor: ItemData = null
var equipped_accessory: ItemData = null


static func xp_for_level(level: int) -> int:
	return level * level * 10


func level_up() -> Dictionary:
	level += 1
	var gains: Dictionary = {
		hp = hp_growth + randi_range(0, 2),
		mp = mp_growth + randi_range(0, 1),
		attack = attack_growth + randi_range(0, 1),
		defense = defense_growth + randi_range(0, 1),
		speed = speed_growth,
	}
	max_hp += gains.hp
	max_mp += gains.mp
	attack += gains.attack
	defense += gains.defense
	speed += gains.speed
	return gains


func get_effective_attack() -> int:
	var bonus: int = equipped_weapon.attack_bonus if equipped_weapon else 0
	return attack + bonus


func get_effective_defense() -> int:
	var bonus: int = equipped_armor.defense_bonus if equipped_armor else 0
	bonus += equipped_accessory.defense_bonus if equipped_accessory else 0
	return defense + bonus


func get_effective_speed() -> int:
	var bonus: int = 0
	if equipped_accessory:
		bonus += equipped_accessory.speed_bonus
	return speed + bonus


func equip(item: ItemData) -> ItemData:
	## Equips an item, returning the previously equipped item (or null).
	var previous: ItemData = null
	match item.equip_slot:
		ItemData.EquipSlot.WEAPON:
			previous = equipped_weapon
			equipped_weapon = item
		ItemData.EquipSlot.ARMOR:
			previous = equipped_armor
			equipped_armor = item
		ItemData.EquipSlot.ACCESSORY:
			previous = equipped_accessory
			equipped_accessory = item
	return previous


func unequip(slot: ItemData.EquipSlot) -> ItemData:
	var item: ItemData = null
	match slot:
		ItemData.EquipSlot.WEAPON:
			item = equipped_weapon
			equipped_weapon = null
		ItemData.EquipSlot.ARMOR:
			item = equipped_armor
			equipped_armor = null
		ItemData.EquipSlot.ACCESSORY:
			item = equipped_accessory
			equipped_accessory = null
	return item

extends PanelContainer
## Equipment management for a party member.

signal equipment_changed

var _character: CharacterData

@onready var _name_label: Label = $VBox/NameLabel
@onready var _stats_label: RichTextLabel = $VBox/StatsLabel
@onready var _weapon_button: Button = $VBox/Slots/WeaponButton
@onready var _armor_button: Button = $VBox/Slots/ArmorButton


func _ready() -> void:
	_weapon_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.WEAPON))
	_armor_button.pressed.connect(_on_slot_pressed.bind(ItemData.EquipSlot.ARMOR))


func show_character(character: CharacterData) -> void:
	_character = character
	_refresh()


func _refresh() -> void:
	_name_label.text = _character.display_name + " (Lv. " + str(_character.level) + ")"
	_stats_label.text = (
		"HP: " + str(_character.max_hp) +
		"  ATK: " + str(_character.get_effective_attack()) +
		"  DEF: " + str(_character.get_effective_defense()) +
		"  SPD: " + str(_character.get_effective_speed())
	)
	_weapon_button.text = "Weapon: " + (_character.equipped_weapon.display_name if _character.equipped_weapon else "(none)")
	_armor_button.text = "Armor: " + (_character.equipped_armor.display_name if _character.equipped_armor else "(none)")


func _on_slot_pressed(slot: ItemData.EquipSlot) -> void:
	var equipable: Array = []
	for entry in InventoryManager.get_all_items():
		var item: ItemData = entry.item
		if item.item_type == ItemData.ItemType.EQUIPMENT and item.equip_slot == slot:
			equipable.append(item)
	if equipable.is_empty():
		print("No equipment for this slot in inventory.")
		return
	var item: ItemData = equipable[0]
	var previous: ItemData = _character.equip(item)
	InventoryManager.remove_item(item)
	if previous:
		InventoryManager.add_item(previous)
	_refresh()
	equipment_changed.emit()

class_name PartyBattler
extends Battler

## Player-controlled battler. Waits for player input to select actions.

signal action_requested
signal target_requested(valid_targets: Array[Battler])

var character_id: StringName = &""
var equipped_echoes: Array[Resource] = []


func initialize_from_data() -> void:
	super.initialize_from_data()
	if data:
		if "id" in data:
			character_id = data.id
		if "abilities" in data:
			abilities = data.abilities
		if "equipped_echoes" in data:
			equipped_echoes = data.equipped_echoes


func request_action() -> void:
	action_requested.emit()


func request_targets(valid_targets: Array[Battler]) -> void:
	target_requested.emit(valid_targets)


func get_available_abilities() -> Array[Resource]:
	if resonance_state == ResonanceState.HOLLOW:
		return []
	var available: Array[Resource] = []
	for ability in abilities:
		if _can_use_ability(ability):
			available.append(ability)
	return available


func _can_use_ability(ability: Resource) -> bool:
	if "ee_cost" in ability and current_ee < ability.ee_cost:
		return false
	if "resonance_cost" in ability and resonance_gauge < ability.resonance_cost:
		return false
	if "min_resonance_state" in ability:
		if resonance_state < ability.min_resonance_state:
			return false
	return true

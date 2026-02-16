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
		character_id = data.id


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
	var ability_data := ability as AbilityData
	if not ability_data:
		return false
	if current_ee < ability_data.ee_cost:
		return false
	if ability_data.resonance_cost > 0.0 and resonance_gauge < ability_data.resonance_cost:
		return false
	return true

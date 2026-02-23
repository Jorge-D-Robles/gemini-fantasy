extends Node

## Tracks bond levels between party member pairs. Awards points from
## battles and camp rests. Serializes for save/load integration.
## Fire Emblem-style D-C-B-A-S support system.

signal bond_level_changed(
	char_a: StringName,
	char_b: StringName,
	old_level: int,
	new_level: int,
)

const BATTLE_BOND_POINTS: int = 2
const CAMP_BOND_POINTS: int = 3

## Internal storage: pair_id (StringName) -> {points: int}
var _bonds: Dictionary = {}


func _ready() -> void:
	var bm: Node = get_node_or_null("/root/BattleManager")
	if bm and bm.has_signal("battle_ended"):
		bm.battle_ended.connect(_on_battle_ended)


func _exit_tree() -> void:
	var bm: Node = get_node_or_null("/root/BattleManager")
	if bm and bm.has_signal("battle_ended"):
		if bm.battle_ended.is_connected(_on_battle_ended):
			bm.battle_ended.disconnect(_on_battle_ended)


func _on_battle_ended(victory: bool) -> void:
	if not victory:
		return
	var pm: Node = get_node_or_null("/root/PartyManager")
	if not pm or not pm.has_method("get_active_party"):
		return
	var party: Array = pm.get_active_party()
	var ids: Array[StringName] = []
	for member in party:
		if member and "id" in member:
			ids.append(member.id)
	award_battle_bond_points(ids)


## Adds bond points to a character pair. Emits bond_level_changed if level
## increases.
func add_bond_points(
	char_a: StringName, char_b: StringName, amount: int,
) -> void:
	var pair_id: StringName = BondData.make_pair_id(char_a, char_b)
	var old_points: int = _get_points(pair_id)
	var old_level: int = int(BondData.compute_level(old_points))
	var new_points: int = old_points + amount
	_bonds[pair_id] = {"points": new_points}
	var new_level: int = int(BondData.compute_level(new_points))
	if new_level > old_level:
		var a: StringName = char_a if String(char_a) <= String(char_b) else char_b
		var b: StringName = char_b if String(char_a) <= String(char_b) else char_a
		bond_level_changed.emit(a, b, old_level, new_level)


## Returns the current bond level for a character pair.
func get_bond_level(
	char_a: StringName, char_b: StringName,
) -> BondData.BondLevel:
	var pair_id: StringName = BondData.make_pair_id(char_a, char_b)
	return BondData.compute_level(_get_points(pair_id))


## Returns the raw bond points for a character pair.
func get_bond_points(
	char_a: StringName, char_b: StringName,
) -> int:
	var pair_id: StringName = BondData.make_pair_id(char_a, char_b)
	return _get_points(pair_id)


## Returns the combat bonus for a specific pair.
func get_combat_bonus(
	char_a: StringName, char_b: StringName,
) -> Dictionary:
	var level: BondData.BondLevel = get_bond_level(char_a, char_b)
	return BondData.compute_combat_bonus(level)


## Returns the aggregate combat bonus for all pairs in the active party.
## Sums bonuses across all unique pairs, capped at max values.
func get_party_combat_bonus(
	party_ids: Array[StringName],
) -> Dictionary:
	var total_damage: float = 0.0
	var total_defense: float = 0.0
	for i: int in range(party_ids.size()):
		for j: int in range(i + 1, party_ids.size()):
			var bonus: Dictionary = get_combat_bonus(
				party_ids[i], party_ids[j],
			)
			total_damage += bonus.get("damage_bonus", 0.0)
			total_defense += bonus.get("defense_bonus", 0.0)
	total_damage = minf(total_damage, BondData.MAX_PARTY_DAMAGE_BONUS)
	total_defense = minf(total_defense, BondData.MAX_PARTY_DEFENSE_BONUS)
	return {
		"damage_bonus": total_damage,
		"defense_bonus": total_defense,
	}


## Awards battle bond points (+2) to every unique pair in the party.
func award_battle_bond_points(party_ids: Array[StringName]) -> void:
	_award_to_all_pairs(party_ids, BATTLE_BOND_POINTS)


## Awards camp bond points (+3) to every unique pair in the party.
func award_camp_bond_points(party_ids: Array[StringName]) -> void:
	_award_to_all_pairs(party_ids, CAMP_BOND_POINTS)


## Returns all bonds as a Dictionary for UI display.
## Keys are pair_id StringNames, values are {points, level} Dictionaries.
func get_all_bonds() -> Dictionary:
	var result: Dictionary = {}
	for pair_id: StringName in _bonds:
		var pts: int = _get_points(pair_id)
		result[pair_id] = {
			"points": pts,
			"level": int(BondData.compute_level(pts)),
		}
	return result


## Serializes all bond data for saving.
func serialize() -> Dictionary:
	var data: Dictionary = {}
	for pair_id: StringName in _bonds:
		data[String(pair_id)] = _bonds[pair_id]["points"]
	return data


## Restores bond data from a save dictionary.
func deserialize(data: Dictionary) -> void:
	_bonds.clear()
	for key: String in data:
		_bonds[StringName(key)] = {"points": int(data[key])}


## Clears all bond data.
func reset_all() -> void:
	_bonds.clear()


func _get_points(pair_id: StringName) -> int:
	if _bonds.has(pair_id):
		return int(_bonds[pair_id].get("points", 0))
	return 0


func _award_to_all_pairs(ids: Array[StringName], amount: int) -> void:
	for i: int in range(ids.size()):
		for j: int in range(i + 1, ids.size()):
			add_bond_points(ids[i], ids[j], amount)

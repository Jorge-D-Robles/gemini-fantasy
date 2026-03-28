extends Node
## Tracks active quests and checks objectives. Autoload as QuestManager.

signal quest_started(quest: QuestData)
signal quest_completed(quest: QuestData)
signal quest_turned_in(quest: QuestData)

var _active_quests: Array[QuestData] = []
var _completed_quests: Array[QuestData] = []
var _turned_in_quests: Array[QuestData] = []


func _ready() -> void:
	GameManager.flag_changed.connect(_on_flag_changed)


func start_quest(quest: QuestData) -> void:
	if _is_quest_active(quest.id) or _is_quest_done(quest.id):
		return
	_active_quests.append(quest)
	quest_started.emit(quest)


func is_quest_active(quest_id: String) -> bool:
	return _is_quest_active(quest_id)


func is_quest_complete(quest_id: String) -> bool:
	for q in _completed_quests:
		if q.id == quest_id:
			return true
	return false


func turn_in_quest(quest: QuestData) -> void:
	_completed_quests.erase(quest)
	_turned_in_quests.append(quest)

	if quest.xp_reward > 0:
		if get_node_or_null("/root/PartyManager"):
			for member in PartyManager.get_members():
				member.current_xp += quest.xp_reward
	if quest.gold_reward > 0:
		InventoryManager.add_gold(quest.gold_reward)
	for item in quest.reward_items:
		InventoryManager.add_item(item)
	if not quest.completion_flag.is_empty():
		GameManager.set_flag(quest.completion_flag)

	quest_turned_in.emit(quest)


func get_active_quests() -> Array[QuestData]:
	return _active_quests


func get_completed_quests() -> Array[QuestData]:
	return _turned_in_quests


func _on_flag_changed(_flag_name: String, _value: bool) -> void:
	var newly_completed: Array[QuestData] = []
	for quest in _active_quests:
		if _all_objectives_met(quest):
			newly_completed.append(quest)
	for quest in newly_completed:
		_active_quests.erase(quest)
		_completed_quests.append(quest)
		quest_completed.emit(quest)


func _all_objectives_met(quest: QuestData) -> bool:
	for flag in quest.objective_flags:
		if not GameManager.has_flag(flag):
			return false
	return true


func _is_quest_active(quest_id: String) -> bool:
	return _active_quests.any(func(q: QuestData) -> bool: return q.id == quest_id)


func _is_quest_done(quest_id: String) -> bool:
	return _turned_in_quests.any(func(q: QuestData) -> bool: return q.id == quest_id)


func to_save_data() -> Dictionary:
	return {
		active = _active_quests.map(func(q: QuestData) -> String: return q.resource_path),
		completed = _completed_quests.map(func(q: QuestData) -> String: return q.resource_path),
		turned_in = _turned_in_quests.map(func(q: QuestData) -> String: return q.resource_path),
	}


func from_save_data(data: Dictionary) -> void:
	_active_quests.clear()
	_completed_quests.clear()
	_turned_in_quests.clear()
	for path in data.get("active", []):
		var q: QuestData = load(path) as QuestData
		if q:
			_active_quests.append(q)
	for path in data.get("completed", []):
		var q: QuestData = load(path) as QuestData
		if q:
			_completed_quests.append(q)
	for path in data.get("turned_in", []):
		var q: QuestData = load(path) as QuestData
		if q:
			_turned_in_quests.append(q)

extends Node

## NOTE: No class_name — autoloads are already global singletons.
## Tracks quest acceptance, objective progress, and completion state.

signal quest_accepted(quest_id: StringName)
signal quest_progressed(quest_id: StringName, objective_index: int)
signal quest_completed(quest_id: StringName)
signal quest_failed(quest_id: StringName)

## Runtime quest states.
enum State {
	ACTIVE,
	COMPLETED,
	FAILED,
}

## Stored QuestData resources keyed by id.
var _quest_data: Dictionary = {}

## Objective completion arrays keyed by quest id.
var _objectives: Dictionary = {}
## Quest state keyed by quest id.
var _states: Dictionary = {}
## Optional callback to check event flags for prerequisites.
var _flag_checker: Callable = Callable()


func _ready() -> void:
	var flags := get_node_or_null("/root/EventFlags")
	if flags:
		_flag_checker = flags.has_flag


## Accepts a quest and starts tracking its objectives.
func accept_quest(quest: Resource) -> void:
	if quest == null or quest.id == &"":
		return
	if _states.has(quest.id):
		return
	_quest_data[quest.id] = quest
	var obj_count: int = quest.objectives.size()
	var completion: Array[bool] = []
	completion.resize(obj_count)
	completion.fill(false)
	_objectives[quest.id] = completion
	_states[quest.id] = State.ACTIVE
	quest_accepted.emit(quest.id)


## Marks a specific objective as complete. Auto-completes the quest
## when all objectives are done.
func complete_objective(
	quest_id: StringName,
	objective_index: int,
) -> void:
	if not _states.has(quest_id):
		return
	if _states[quest_id] != State.ACTIVE:
		return
	var objectives: Array = _objectives[quest_id]
	if objective_index < 0 or objective_index >= objectives.size():
		return
	if objectives[objective_index]:
		return
	objectives[objective_index] = true
	quest_progressed.emit(quest_id, objective_index)
	# Check if all objectives complete
	var all_done := true
	for done: bool in objectives:
		if not done:
			all_done = false
			break
	if all_done:
		_states[quest_id] = State.COMPLETED
		quest_completed.emit(quest_id)


## Marks a quest as failed.
func fail_quest(quest_id: StringName) -> void:
	if not _states.has(quest_id):
		return
	if _states[quest_id] != State.ACTIVE:
		return
	_states[quest_id] = State.FAILED
	quest_failed.emit(quest_id)


## Returns true if the quest is currently active.
func is_quest_active(quest_id: StringName) -> bool:
	return _states.get(quest_id, -1) == State.ACTIVE


## Returns true if the quest has been completed.
func is_quest_completed(quest_id: StringName) -> bool:
	return _states.get(quest_id, -1) == State.COMPLETED


## Returns true if the quest has failed.
func is_quest_failed(quest_id: StringName) -> bool:
	return _states.get(quest_id, -1) == State.FAILED


## Returns objective completion status as an Array[bool], or empty array.
func get_objective_status(quest_id: StringName) -> Array:
	if not _objectives.has(quest_id):
		return []
	return _objectives[quest_id]


## Returns stored QuestData for a quest, or null.
func get_quest_data(quest_id: StringName) -> Resource:
	return _quest_data.get(quest_id, null)


## Returns all active quest ids.
func get_active_quests() -> Array[StringName]:
	var result: Array[StringName] = []
	for qid: StringName in _states:
		if _states[qid] == State.ACTIVE:
			result.append(qid)
	return result


## Returns all completed quest ids.
func get_completed_quests() -> Array[StringName]:
	var result: Array[StringName] = []
	for qid: StringName in _states:
		if _states[qid] == State.COMPLETED:
			result.append(qid)
	return result


## Returns all failed quest ids.
func get_failed_quests() -> Array[StringName]:
	var result: Array[StringName] = []
	for qid: StringName in _states:
		if _states[qid] == State.FAILED:
			result.append(qid)
	return result


## Checks whether a quest's prerequisites are met.
func can_accept_quest(quest: Resource) -> bool:
	if quest == null:
		return false
	if quest.prerequisites.is_empty():
		return true
	if not _flag_checker.is_valid():
		return false
	for flag: String in quest.prerequisites:
		if not _flag_checker.call(flag):
			return false
	return true


## Sets a callable that checks event flags for prerequisites.
## Signature: func(flag_name: String) -> bool
func set_flag_checker(checker: Callable) -> void:
	_flag_checker = checker


## Serializes all quest state for saving.
func serialize() -> Dictionary:
	var active := {}
	var completed: Array[String] = []
	var failed: Array[String] = []
	for qid: StringName in _states:
		var state: int = _states[qid]
		match state:
			State.ACTIVE:
				var obj_bools: Array = _objectives.get(qid, [])
				active[String(qid)] = {"objectives": obj_bools}
			State.COMPLETED:
				completed.append(String(qid))
			State.FAILED:
				failed.append(String(qid))
	return {
		"active": active,
		"completed": completed,
		"failed": failed,
	}


## Restores quest state from saved data. Requires quest data resources
## to rebuild internal tracking.
func deserialize(
	data: Dictionary,
	quest_resources: Array,
) -> void:
	_quest_data.clear()
	_objectives.clear()
	_states.clear()
	var lookup := {}
	for q in quest_resources:
		if q and q.id != &"":
			lookup[String(q.id)] = q
	_restore_active_quests(data.get("active", {}), lookup)
	_restore_completed_quests(data.get("completed", []), lookup)
	_restore_failed_quests(data.get("failed", []), lookup)


func _restore_active_quests(active: Dictionary, lookup: Dictionary) -> void:
	for qid_str: String in active:
		var qid := StringName(qid_str)
		var quest: Resource = lookup.get(qid_str, null)
		if not quest:
			continue
		_quest_data[qid] = quest
		_states[qid] = State.ACTIVE
		var saved_obj: Array = active[qid_str].get("objectives", [])
		var obj_count: int = quest.objectives.size()
		var completion: Array[bool] = []
		completion.resize(obj_count)
		for i in obj_count:
			completion[i] = bool(saved_obj[i]) if i < saved_obj.size() else false
		_objectives[qid] = completion


func _restore_completed_quests(completed: Array, lookup: Dictionary) -> void:
	for qid_str in completed:
		var qid := StringName(qid_str)
		var quest: Resource = lookup.get(String(qid_str), null)
		if quest:
			_quest_data[qid] = quest
		_states[qid] = State.COMPLETED


func _restore_failed_quests(failed_arr: Array, lookup: Dictionary) -> void:
	for qid_str in failed_arr:
		var qid := StringName(qid_str)
		var quest: Resource = lookup.get(String(qid_str), null)
		if quest:
			_quest_data[qid] = quest
		_states[qid] = State.FAILED

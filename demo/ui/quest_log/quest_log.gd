extends PanelContainer
## Displays active and completed quests.

@onready var _quest_list: VBoxContainer = $MarginContainer/VBoxContainer/QuestList
@onready var _detail_label: RichTextLabel = $MarginContainer/VBoxContainer/DetailLabel


func refresh() -> void:
	for child in _quest_list.get_children():
		child.queue_free()
	await get_tree().process_frame
	var active := QuestManager.get_active_quests()
	for quest in active:
		var button := Button.new()
		button.text = quest.title
		button.pressed.connect(_show_detail.bind(quest))
		_quest_list.add_child(button)
	if _quest_list.get_child_count() > 0:
		await get_tree().process_frame
		_quest_list.get_child(0).grab_focus()


func _show_detail(quest: QuestData) -> void:
	var text := "[b]" + quest.title + "[/b]\n\n"
	text += quest.description + "\n\n[b]Objectives:[/b]\n"
	for i in quest.objectives.size():
		var done: bool = false
		if i < quest.objective_flags.size():
			done = GameManager.has_flag(quest.objective_flags[i])
		var marker: String = "[x]" if done else "[ ]"
		text += marker + " " + quest.objectives[i] + "\n"
	_detail_label.text = text

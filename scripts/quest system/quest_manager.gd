extends Node

var active_quests: Array[Quest] = []
var completed_quests: Array[Quest] = []
var quest_data: Dictionary = {}

signal quest_started(quest: Quest)
signal quest_completed(quest: Quest)
signal quest_updated(quest: Quest)

func _ready():
	load_quest_data()

func load_quest_data():
	var file = FileAccess.open("res://data/quests.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			quest_data = json.data
		file.close()

func start_quest(quest_id: String):
	if quest_id in quest_data:
		var new_quest = Quest.new()
		new_quest.initialize(quest_data[quest_id])
		active_quests.append(new_quest)
		quest_started.emit(new_quest)
		return new_quest
	return null

func complete_quest(quest_id: String):
	for i in range(active_quests.size()):
		if active_quests[i].id == quest_id:
			var quest = active_quests[i]
			active_quests.remove_at(i)
			completed_quests.append(quest)
			quest_completed.emit(quest)
			return
			
func update_quest_progress(quest_id: String, objective_id: String):
	for quest in active_quests:
		if quest.id == quest_id:
			quest.update_objective(objective_id)
			quest_updated.emit(quest)
			if quest.is_completed():
				complete_quest(quest_id)
			return

extends Node

var dialogue_data: Dictionary = {}
var current_dialogue: DialogueTree = null

signal dialogue_started(npc_id: String)
signal dialogue_ended()
signal dialogue_choice_made(choice_id: String)

func _ready():
	load_dialogue_data()

func load_dialogue_data():
	var file = FileAccess.open("res://data/dialogues.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			dialogue_data = json.data
		file.close()

func start_dialogue(npc_id: String, dialogue_id: String = "default"):
	if npc_id in dialogue_data and dialogue_id in dialogue_data[npc_id]:
		current_dialogue = DialogueTree.new()
		current_dialogue.initialize(dialogue_data[npc_id][dialogue_id])
		dialogue_started.emit(npc_id)
		return current_dialogue.get_current_node()
	return null

func make_choice(choice_id: String):
	if current_dialogue:
		current_dialogue.make_choice(choice_id)
		dialogue_choice_made.emit(choice_id)
		
		if current_dialogue.is_ended():
			end_dialogue()
			return null
		else:
			return current_dialogue.get_current_node()
	return null

func end_dialogue():
	current_dialogue = null
	dialogue_ended.emit()

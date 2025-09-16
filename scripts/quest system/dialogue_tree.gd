class_name DialogueTree
extends Resource

var nodes: Dictionary = {}
var current_node_id: String = ""
var is_dialogue_ended: bool = false

func initialize(data: Dictionary):
	nodes = data.get("nodes", {})
	current_node_id = data.get("start_node", "")
	is_dialogue_ended = false

func get_current_node() -> Dictionary:
	if current_node_id in nodes:
		return nodes[current_node_id]
	return {}

func make_choice(choice_id: String):
	var current_node = get_current_node()
	if "choices" in current_node:
		for choice in current_node.choices:
			if choice.get("id") == choice_id:
				# Execute any actions
				if "actions" in choice:
					_execute_actions(choice.actions)
				
				# Move to next node or end dialogue
				if "next_node" in choice:
					current_node_id = choice.next_node
				else:
					is_dialogue_ended = true
				return

func _execute_actions(actions: Array):
	for action in actions:
		match action.get("type"):
			"start_quest":
				QuestManager.start_quest(action.get("quest_id"))
			"complete_quest":
				QuestManager.complete_quest(action.get("quest_id"))
			"update_objective":
				QuestManager.update_quest_progress(
					action.get("quest_id"), 
					action.get("objective_id")
				)

func is_ended() -> bool:
	return is_dialogue_ended

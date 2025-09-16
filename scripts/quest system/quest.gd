class_name Quest
extends Resource

@export var id: String
@export var title: String
@export var description: String
@export var objectives: Array[QuestObjective]
@export var rewards: Dictionary
@export var prerequisites: Array[String]

enum QuestState {
	INACTIVE,
	ACTIVE,
	COMPLETED,
	FAILED
}

var state: QuestState = QuestState.INACTIVE

func initialize(data: Dictionary):
	id = data.get("id", "")
	title = data.get("title", "")
	description = data.get("description", "")
	rewards = data.get("rewards", {})
	prerequisites = data.get("prerequisites", [])
	
	objectives.clear()
	for obj_data in data.get("objectives", []):
		var objective = QuestObjective.new()
		objective.initialize(obj_data)
		objectives.append(objective)
	
	state = QuestState.ACTIVE

func update_objective(objective_id: String):
	for objective in objectives:
		if objective.id == objective_id:
			objective.complete()
			return

func is_completed() -> bool:
	for objective in objectives:
		if not objective.is_completed:
			return false
	return true

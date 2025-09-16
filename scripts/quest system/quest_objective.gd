class_name QuestObjective
extends Resource

@export var id: String
@export var description: String
@export var target_count: int = 1
@export var current_count: int = 0
@export var is_completed: bool = false

func initialize(data: Dictionary):
	id = data.get("id", "")
	description = data.get("description", "")
	target_count = data.get("target_count", 1)
	current_count = 0
	is_completed = false

func update_progress(amount: int = 1):
	current_count += amount
	if current_count >= target_count:
		complete()

func complete():
	is_completed = true
	current_count = target_count

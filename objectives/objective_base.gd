extends Node3D
class_name ObjectiveBase

## Base Objective Class
##
## Common foundation for all objectives (Interactable NPCs, QTEs, etc.)
## Handles completion, failure, scoring, and signal standardization.

signal objective_started
signal objective_completed
signal objective_failed
signal objective_reset

@export var objective_name: String
@export var enabled: bool = true
@export var completed_points: int = 50
@export var failed_points: int = 0
@export var is_required: bool = false  # For REQUIRED_OBJECTIVES tracking
@export var auto_start: bool = false   # Whether it starts immediately on level load
@export var is_invisible: bool = false

@export var ideal_completion_time: float = 10
var elapsed_time: float = 0
var completion_time: float = 0
@export var completed_message: String = "You have completed this objective!"
@export var fail_message: String = "You have failed this objective!"


var active: bool = false
var completed: bool = false
var failed: bool = false

#signal time(float)

func _ready():
	if auto_start:
		start_objective()

func _process(delta: float) -> void:
	#if active and not completed:
		#elapsed_time += delta
		#time.emit(elapsed_time)
	#elif completed and not failed:
	pass
		
func start_objective():
	if not enabled or active:
		return
	active = true
	completed = false
	failed = false
	print("Objective Started: ", objective_name)
	emit_signal("objective_started")

func complete_objective():
	if not active or completed:
		return
	active = false
	completed = true
	completion_time = elapsed_time
	print("Objective Completed: ", objective_name)
	emit_signal("objective_completed")

func fail_objective():
	if not active or failed:
		return
	active = false
	failed = true
	completion_time = elapsed_time
	print("Objective Failed:", objective_name)
	emit_signal("objective_failed")

func reset_objective():
	active = false
	completed = false
	failed = false
	
	elapsed_time = 0
	completion_time = 0
	
	_on_reset() # hook for child classes
	
	if auto_start:
		start_objective()
	
	emit_signal("objective_reset")

func get_completion_time():
	return elapsed_time

func _on_reset():
	pass

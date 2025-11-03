extends Node3D
class_name ObjectiveBase

## Base Objective Class
##
## Common foundation for all objectives (Interactable NPCs, QTEs, etc.)
## Handles completion, failure, scoring, and signal standardization.

signal objective_started
signal objective_completed
signal objective_failed

@export var enabled: bool = true
@export var completed_points: int = 50
@export var failed_points: int = 0
@export var is_required: bool = false  # For REQUIRED_OBJECTIVES tracking
@export var auto_start: bool = false   # Whether it starts immediately on level load

var active: bool = false
var completed: bool = false
var failed: bool = false

func _ready():
	if auto_start:
		start_objective()

func start_objective():
	if not enabled or active:
		return
	active = true
	completed = false
	failed = false
	print("Objective Started: ", name)
	emit_signal("objective_started")

func complete_objective():
	if not active or completed:
		return
	active = false
	completed = true
	print("Objective Completed: ", name)
	emit_signal("objective_completed")

func fail_objective():
	if not active or failed:
		return
	active = false
	failed = true
	print("Objective Failed:", name)
	emit_signal("objective_failed")

func reset_objective():
	active = false
	completed = false
	failed = false

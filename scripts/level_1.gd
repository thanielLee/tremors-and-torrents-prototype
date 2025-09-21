extends XRToolsSceneBase

## Level 1 Script
##
## This script extends XRToolsSceneBase and deals with the game elements
## specifically for Level 1
##
## This could serve as a guide/reference for future level creation  
##
## Handles initialization, hazards, objectives, and level flow.

var hazards : Node
var objectives : Node
var world_shaker : Node
var earthquake_triggered: bool = false
signal shake_world

var level_active = false
var level_timer : float = 0.0
var score : int = 0 # Temporary basic scoring system 

var triggered_hazards: Array[String] = []
var completed_objectives: Array[String] = []

# Conditions
const HAZARD_LIMIT := 2
const REQUIRED_OBJECTIVES := ["Victim"]

func _ready():
	start_level()

### LEVEL LIFECYCLE ###

func start_level():
	print("Level started")
	level_active = true
	level_timer = 0
	
	# Cache references
	hazards = get_node("Hazards")
	world_shaker = get_node("WorldShaker")
	objectives = get_node("Objectives")

	enable_hazards()
	enable_objectives()

func end_level(success: bool):
	level_active = false
	disable_hazards()
	
	if success:
		print("Level complete! Score: %s" % score)
		exit_to_main_menu()
	else:
		print("Level failed! Score: %s" % score)
		exit_to_main_menu()
	
	# TODO: trigger scene switch or results UI


### HAZARDS ###

func enable_hazards():
	# For connecting all hazard signals to call function _on_hazard_triggered(name)
	if not hazards: return
	for hazard in hazards.get_children():
		if hazard.has_signal("hazard_triggered"):
			hazard.hazard_triggered.connect(_on_hazard_triggered.bind(hazard.name))

func disable_hazards():
	if not hazards: return
	for hazard in hazards.get_children():
		if hazard.has_signal("hazard_triggered"):
			if hazard.hazard_triggered.is_connected(_on_hazard_triggered):
				hazard.hazard_triggered.disconnect(_on_hazard_triggered)

# Temporary function
func _on_hazard_triggered(hazard_name: String):
	print("Hazard: %s triggered!" % hazard_name)
	#reset_scene()
	
	if hazard_name not in triggered_hazards:
		triggered_hazards.append(hazard_name)
		
		if triggered_hazards.size() >= HAZARD_LIMIT:
			end_level(false)
	
	# TODO: log hazard for feedback


### OBJECTIVES ###

func enable_objectives():
	### VERY TEMPORARY
	var victim: RigidBody3D = $Objectives/Victim
	victim.victim_safe.connect(_on_objective_completed.bind(victim.name))
	victim.victim_triggered_hazard.connect(_on_objective_failed.bind(victim.name))
	
	var injured: Node3D = $Objectives/Injured
	injured.injured_cleared.connect(_on_objective_completed.bind(injured.name))


func _on_objective_completed(objective_name: String):
	if objective_name not in completed_objectives:
		completed_objectives.append(objective_name)
		print("Objective Complete:", objective_name)
		score += 50
		
		check_level_end()

func _on_objective_failed(objective_name: String):
	print("Objective %s failed!" % objective_name)
	exit_to_main_menu()


### LEVEL END CHECK ###

func check_level_end():
	var all_objectives_done := REQUIRED_OBJECTIVES.all(
		func(req): return req in completed_objectives
	)
	
	if all_objectives_done and triggered_hazards.size() < HAZARD_LIMIT:
		end_level(true)

### PROCESS LOOP ###

func _process(delta: float) -> void:
	if level_active:
		level_timer += delta
		
		if not earthquake_triggered and level_timer > 60.0:
			emit_signal("shake_world")
			earthquake_triggered = true
		
		# Time ran out
		if level_timer > 120.0:
			end_level(false)
	

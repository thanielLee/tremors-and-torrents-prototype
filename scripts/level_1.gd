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
var shakers : Node
var world_shaker : Node
var objectives : Node

var level_active = false
var level_timer : float = 0.0
var score : int = 0 # Temporary basic scoring system 

func _ready():
	start_level()

### LEVEL LIFECYCLE ###

func start_level():
	print("Level started")
	level_active = true
	level_timer = 0
	
	# Cache references
	hazards = get_node("Hazards")
	shakers = get_node("Shakers")
	world_shaker = get_node("WorldShaker")
	objectives = get_node("Objectives")

	enable_hazards()
	enable_objectives()

func end_level(success: bool):
	level_active = false
	# disable hazards
	
	if success:
		print("Level complete! Score: %s" % score)
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
			hazard.hazard_triggered.connect(_on_hazard_triggered)

func disable_hazards():
	if not hazards: return
	for hazard in hazards.get_children():
		if hazard.has_signal("hazard_triggered"):
			if hazard.hazard_triggered.is_connected(_on_hazard_triggered):
				hazard.hazard_triggered.disconnect(_on_hazard_triggered)

# Temporary function
func _on_hazard_triggered(hazard_name: String):
	print("Hazard: %s triggered!" % hazard_name)
	reset_scene()
	
	# TODO: log hazard for feedback


### OBJECTIVES ###

func enable_objectives():
	# TODO: implement objectives
	return


### PROCESS LOOP ###

func _process(delta: float) -> void:
	if level_active:
		level_timer += delta
		# Example: fail condition after 120s
		if level_timer > 120.0:
			end_level(false)
	

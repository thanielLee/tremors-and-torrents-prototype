extends XRToolsSceneBase

## Level 1 Script
##
## This script extends XRToolsSceneBase and deals with the game elements
## specifically for Level 1
##
## This could serve as a guide/reference for future level creation  

var hazards

func _ready():
	hazards = get_node("Hazards")
	
	# For connecting all hazard signals to call function _on_hazard_triggered(name)
	for hazard in hazards.get_children():
		hazard.hazard_triggered.connect(_on_hazard_triggered)

# Temporary function
func _on_hazard_triggered(name: String):
	print("Hazard: " + name + " has been triggered!")

extends Node3D
class_name LevelButton

@export var objective: Node3D
@onready var interactable_area: XRToolsInteractableAreaButton = $XRToolsInteractableAreaButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_area.connect("button_pressed", _trigger_button_effect) 

func _trigger_button_effect(button) -> void:
	if objective is not ObjectiveBase:
		var obj_logic = objective.get_node("ObjectiveLogic") as ObjectiveBase
		objective = obj_logic
	print("reset Button Pressed! " + objective.objective_name)
	objective.reset_objective()

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#print(interactable_area.get_overlapping_areas())
	#print(interactable_area.get_overlapping_bodies())

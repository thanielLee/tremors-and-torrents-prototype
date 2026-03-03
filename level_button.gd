extends Node3D
class_name LevelButton

@export var objective: Node3D
@export var fire_extinguisher: Node3D
@export var door_button: bool = false

@onready var interactable_area: XRToolsInteractableAreaButton = $XRToolsInteractableAreaButton

#signal reset_objective_button(obj: ObjectiveBase)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable_area.connect("button_pressed", _trigger_button_effect) 

func _trigger_button_effect(button) -> void:
	if door_button:
		var current_node = self
		while current_node is not XRToolsSceneBase:
			current_node = current_node.get_parent_node_3d()
		
		for child in current_node.get_children():
			if "JammedDoor" in child.name:
				child._reset_door()
		return

	if objective is not ObjectiveBase and objective != null:
		var obj_logic = objective.get_node("ObjectiveLogic") as ObjectiveBase
		objective = obj_logic

	print("reset Button Pressed! " + objective.objective_name)
	objective.reset_objective()

	if fire_extinguisher:
		var logic = fire_extinguisher.get_node("FireExtinguisherManager") as FireExtinguisherManager
		if logic:
			logic.reset_fire()
		else:
			print("fire ext missing!!")
	else:
		print("no fire ext, resetting " + objective.objective_name)
	
	

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#print(interactable_area.get_overlapping_areas())
	#print(interactable_area.get_overlapping_bodies())

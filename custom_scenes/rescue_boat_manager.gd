extends Node3D
class_name RescueBoat

@onready var handle_pickable: XRToolsPickable = $"../Handle/XRToolsPickable"
@onready var handle_node: Node3D = $"../Handle"
var handle_transform: Transform3D

func _ready():
	handle_transform = handle_node.global_transform
	pass
	
func _process(delta):
	pass


func _physics_process(delta):
	if !handle_pickable.grabbed:
		handle_node.global_transform = handle_transform

extends Node3D
class_name BoatMesh

@onready var handle_node = $RescueBoat/Cylinder_001
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_handle_rotation(deg):
	handle_node.global_rotation.y = deg

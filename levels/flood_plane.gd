extends MeshInstance3D
class_name FloodPlane

var flood_speed : float = 0.05
var is_currently_flooding : bool = false
var start_y : float
var end_y : float

func _ready():
	start_y = position.y

func _process(delta):
	
	if is_currently_flooding:
		if position.y + flood_speed * delta >= end_y:
			position.y = end_y
			is_currently_flooding = false
		else:
			position.y += flood_speed * delta

func start_flooding(flood_height : float):
	is_currently_flooding = true
	end_y = start_y + flood_height

extends Node3D
class_name GrassManager

@onready var mesh_instance: MultiMeshInstance3D = $GrassMeshInstance
@onready var floor_body: StaticBody3D = $"../../WorldShaker/Floor"
@export var density: float = 1
@export var noise_intensity: = 5
@export var noise_object: FastNoiseLite

var grass_positions: Array[Vector3] = []


var floor_min: Vector3
var floor_max: Vector3
func _ready() -> void:
	var floor_mesh: MeshInstance3D
	
	for child in floor_body.get_children():
		if child is MeshInstance3D:
			floor_mesh = child
	
	var local_aabb = floor_mesh.get_aabb()
	var global_aabb = floor_mesh.global_transform * local_aabb
	floor_min = local_aabb.position
	floor_max = local_aabb.position + local_aabb.size
	
	var x_bounds = floor_max.x-floor_min.x
	var z_bounds = floor_max.z-floor_min.z
	
	var interval_x = 1 / density
	var interval_z = 1 / density
	
	var total_x = floor(x_bounds / interval_x)
	var total_z = floor(z_bounds / interval_z)
	
	var total_grass = total_x * total_z * 3
	
	for i in range(total_x):
		for j in range(total_z):
			for k in range(3):
				var current_position = Vector3(i*interval_x, 0, j*interval_z) - Vector3(x_bounds/2, 0, z_bounds/2)
				var noise_val = noise_object.get_noise_2d(current_position.x, current_position.y)
				var final_vec = current_position*noise_val
				final_vec.y = 3
				grass_positions.push_back(floor_mesh.global_transform * final_vec)
				
	mesh_instance.multimesh.instance_count = grass_positions.size()
	
	for i in range(grass_positions.size()):
		mesh_instance.multimesh.set_instance_transform(i, Transform3D(Basis().rotated(Vector3.UP, deg_to_rad((i%3)*60)), grass_positions[i]))
	
	
		
	
	
	
	
	
	

extends Node3D

@onready var parent_pickable = $".."
@onready var debug_line = $"../DebugLine"
@onready var circle_debug = $"../CircleDebug"
@onready var smoke_node = $"../VfxSmoke"
var line_material: StandardMaterial3D
var is_active = false
var forward_vector
var space_state 
var smoke_particles: GPUParticles3D
@export var displace_vector: Vector3

func _ready():
	parent_pickable.connect("action_pressed", start_action)
	parent_pickable.connect("action_released", end_action)
	smoke_particles = smoke_node.get_child(0)
	line_material = StandardMaterial3D.new()
	line_material.vertex_color_use_as_albedo = true
	line_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

func _physics_process(delta):
	circle_debug.global_position = global_position + Vector3(0, 1, 0)
	smoke_particles.process_material.direction = Vector3(0, 0, -1)
	if is_active:
		send_raycast()
		debug_line.mesh.clear_surfaces()
		_draw_line(Vector3(0,0.15,0), Vector3(0,0.15,0)+Vector3(0,0,-1)*3, Color.BLACK)
		
func _draw_line(start_point, end_point, color):
	debug_line.mesh.surface_begin(Mesh.PRIMITIVE_LINES, line_material)
	debug_line.mesh.surface_set_color(color)
	debug_line.mesh.surface_add_vertex(start_point)
	debug_line.mesh.surface_add_vertex(end_point)
	debug_line.mesh.surface_end()
	

func start_action(pickable: XRToolsPickable):
	#print("action started! ")
	#print(pickable._grab_points[0].global_position-global_position)
	#print(forward_vector)
	is_active = true
	smoke_particles.emitting = true
	pass
	

func send_raycast():
	forward_vector = -global_transform.basis.z
	space_state = get_world_3d().direct_space_state
	var raycast_query = PhysicsRayQueryParameters3D.create(global_position+global_transform.basis.y*0.15, global_position+global_transform.basis.y*0.15 + forward_vector*3)
	raycast_query.collide_with_areas = true
	var str = ""
	for i in range(33):
		if raycast_query.collision_mask & (1<<i) != 0:
			str += "1"
		else:
			str += "0"
	#print(str)
	
	var result = space_state.intersect_ray(raycast_query)
	 
	if result.has("collider"):
		var object_hit = result["collider"]
		#print("HIT: " + object_hit.name)
		var object_parent = object_hit.get_parent()
		if object_parent is Hazard:
			if object_parent.hazard_name == "Electrical Fire":
				var vfx_node: Node3D = object_parent.get_child(1)
				for child in vfx_node.get_children():
					child.emitting = false
					

func end_action(pickable):
	print("action ended!")
	is_active = false
	smoke_particles.emitting = false
	pass

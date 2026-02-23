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

var original_particle_settings := {}

@export var extinguish_speed: float = 0.2

var current_fire_vfx: Node3D = null
var fire_progress: float = 1.0
var is_extinguishing_fire := false

var obj_logic: ObjectiveBase
var started: bool = false
var completed: bool = false

var object_parent: Node

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
		send_raycast(delta)
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
	

func send_raycast_old(delta):
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
				object_parent.is_active = false
				obj_logic = object_parent.get_node("ObjectiveLogic") as ObjectiveBase
				obj_logic.start_objective()
				for child in vfx_node.get_children():
					child.emitting = false

func send_raycast(delta):
	forward_vector = -global_transform.basis.z
	space_state = get_world_3d().direct_space_state

	var start = global_position + global_transform.basis.y * 0.15
	var end = start + forward_vector * 3

	var query = PhysicsRayQueryParameters3D.create(start, end)
	query.collide_with_areas = true

	var result = space_state.intersect_ray(query)

	var hitting_fire := false

	if result.has("collider"):
		var object_hit = result["collider"]
		object_parent = object_hit.get_parent()

		if object_parent is Hazard and object_parent.hazard_name == "Electrical Fire" and not completed:

			var vfx_node: Node3D = object_parent.get_child(1)

			if current_fire_vfx == null:
				original_particle_settings.clear()
				for child in vfx_node.get_children():
					if child is GPUParticles3D:
						original_particle_settings[child] = {
							"amount_ratio": child.amount_ratio,
							"speed_scale": child.speed_scale,
							"emitting": child.emitting
					}
				
				current_fire_vfx = vfx_node
				fire_progress = 1.0
				is_extinguishing_fire = true

				if not obj_logic:
					obj_logic = object_parent.get_node("ObjectiveLogic") as ObjectiveBase

				if obj_logic and not started:
					obj_logic.start_objective()
					started = true

			hitting_fire = true

	if hitting_fire and is_extinguishing_fire:
		_reduce_fire(delta)

func end_action(pickable):
	print("action ended!")
	is_active = false
	smoke_particles.emitting = false
	pass

func _reduce_fire(delta):
	fire_progress -= delta * extinguish_speed
	fire_progress = clamp(fire_progress, 0.0, 1.0)
	#print(fire_progress)
	if current_fire_vfx:
		for child in current_fire_vfx.get_children():
			if child is GPUParticles3D:
				child.amount_ratio = fire_progress
				#child.speed_scale = fire_progress
	
	print(fire_progress)
	if fire_progress <= 0.0:
		_finish_extinguish()

func _finish_extinguish():
	if not current_fire_vfx or completed:
		return

	for child in current_fire_vfx.get_children():
		if child is GPUParticles3D:
			child.emitting = false

	is_extinguishing_fire = false
	completed = true
	
	if obj_logic:
		obj_logic.complete_objective()
	
	current_fire_vfx = null
	object_parent.is_active = false

func reset_fire():
	started = false
	completed = false
	fire_progress = 1.0
	is_extinguishing_fire = false
	
	if current_fire_vfx:
		for child in current_fire_vfx.get_children():
			if child is GPUParticles3D and original_particle_settings.has(child):
				var data = original_particle_settings[child]
				child.amount_ratio = data["amount_ratio"]
				child.speed_scale = data["speed_scale"]
				child.emitting = data["emitting"]
			elif child is AudioStreamPlayer3D:
				child.play()

	current_fire_vfx = null
	obj_logic = null

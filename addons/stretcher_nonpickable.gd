extends AnimatableBody3D
class_name StretcherNonPickable

@onready var handle_one: XRToolsPickable = $PickableObject
@onready var handle_two: XRToolsPickable = $PickableObject2
@onready var debug_mesh_1: MeshInstance3D = $DebugCube1
@onready var debug_mesh_2: MeshInstance3D = $DebugCube2
@onready var position_vector: Vector3 = Vector3(0.0, 0.0, 2.3)
var handle_one_transform: Transform3D
var handle_two_transform: Transform3D
var handle_one_position: Vector3
var handle_two_position: Vector3
var handle_one_hand: XRController3D
var handle_two_hand: XRController3D 
var grab_plane: Plane
var did_setup_info: bool
var starting_player_vector: Vector3
var player_body: Node3D
var xr_origin: XROrigin3D
var one_handed_keeping_track: bool = false
var one_handed_time: float = 0.0
var is_on_ground: bool = false
var physics_state_space: PhysicsDirectSpaceState3D

signal strecher_one_handed(time: float)
signal stretcher_dropped(distance: float)

func _ready() -> void:
	handle_one_transform = global_transform.affine_inverse() * handle_one.global_transform
	handle_two_transform = global_transform.affine_inverse() * handle_two.global_transform
	handle_one_position = handle_one.global_position-global_position
	handle_two_position = handle_two.global_position-global_position
	debug_mesh_1.visible = false
	debug_mesh_2.visible = false
	handle_one.released.connect(_return_handle_one)
	handle_two.released.connect(_return_handle_two)
	handle_one.grabbed.connect(_handle_one_picked_up)
	handle_two.grabbed.connect(_handle_two_picked_up)
	did_setup_info = false
	physics_state_space = get_world_3d().direct_space_state
	
func _handle_one_picked_up(pickable, by) -> void:
	handle_one_hand = by.get_parent()
	debug_mesh_1.visible = true
	
func _handle_two_picked_up(pickable, by) -> void:
	handle_two_hand = by.get_parent()
	debug_mesh_2.visible = true
	
func _return_handle_one(pickable, by) -> void:
	handle_one_hand = null
	handle_one.global_transform = global_transform * handle_one_transform
	debug_mesh_1.visible = false
	did_setup_info = false
	
func _return_handle_two(pickable, by) -> void:
	handle_two_hand = null
	handle_two.global_transform = global_transform * handle_two_transform
	debug_mesh_2.visible = false
	did_setup_info = false
	
func _setup_player_info() -> void:
	did_setup_info = true
	
	var current_parent = get_parent()
	
	while current_parent is not XRToolsSceneBase:
		current_parent = current_parent.get_parent()
	
	xr_origin = current_parent.get_child(0)
	player_body = xr_origin.get_child(3)
	
	starting_player_vector = Plane(Vector3.ZERO, Vector3.UP).project(-xr_origin.basis.z).normalized()
	
	if (handle_one_hand != null) != (handle_two_hand != null):
		one_handed_keeping_track = true
	
	is_on_ground = false

func _put_stretcher_on_ground():
	is_on_ground = true
	
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = global_position
	ray_query.to = global_position + Vector3(0., -20.0, 0.0)
	ray_query.exclude = [self]
	ray_query.collision_mask = 1
	
	var result: Dictionary = physics_state_space.intersect_ray(ray_query)
	var intersection_point: Vector3 = result["position"]
	var distance = (global_position-intersection_point).length()
	stretcher_dropped.emit(distance)
	
	global_position = intersection_point + Vector3(0.0, 0.30, 0.0)
	
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	if handle_one_hand != null and handle_two_hand != null:
		if not did_setup_info:
			_setup_player_info()
			
		var hands_midpoint = (handle_one_hand.global_position + handle_two_hand.global_position) / 2
		#var hand_two_vec = (handle_two_hand.global_position - hands_midpoint).normalized()
		#
		#var hand_two_angle = acos(hand_two_vec.dot(Vector3(-1.0, 0.0, 0.0)))
		
		var new_transform = Transform3D(Basis.IDENTITY, hands_midpoint - (-xr_origin.basis.z * 2.3))
		global_transform = new_transform.looking_at(hands_midpoint, Vector3.UP, true)
	#elif handle_one_hand != null or handle_two_hand != null:
		#pass
		#if not did_setup_info:
			#_setup_player_info()
		#if one_handed_keeping_track:
			#one_handed_time += delta
			#strecher_one_handed.emit(one_handed_time)
		#
		#var current_active_hand
		#var displacement_vec: Vector3
		#
		#if handle_one_hand != null:
			#current_active_hand = handle_one_hand
			#displacement_vec = Vector3(-0.484, 0.0, 0.0)
		#else:
			#current_active_hand = handle_two_hand
			#displacement_vec = Vector3(0.484, 0.0, 0.0)
		#
		#
		#var hands_midpoint = current_active_hand.global_position + displacement_vec.rotated(Vector3.UP, -deg_to_rad(global_rotation.y))
		#var new_transform = Transform3D(Basis.IDENTITY, hands_midpoint - (-xr_origin.basis.z * 2.3))
		#global_transform = new_transform
	else:
		one_handed_keeping_track = false
		one_handed_time = 0.0
		
		if not is_on_ground:
			_put_stretcher_on_ground()
		
		did_setup_info = false
		
		
	if handle_one_hand == null:
		handle_one.global_transform = global_transform * handle_one_transform
	else:
		debug_mesh_1.global_transform = handle_one_hand.global_transform
		
	if handle_two_hand == null:
		handle_two.global_transform = global_transform * handle_two_transform
	else:
		debug_mesh_2.global_transform = handle_two_hand.global_transform
		

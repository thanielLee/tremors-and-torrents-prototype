extends AnimatableBody3D
class_name StretcherNonPickable

@onready var handle_one: XRToolsPickable = $PickableObject
@onready var handle_two: XRToolsPickable = $PickableObject2
@onready var debug_mesh_1: MeshInstance3D = $DebugCube1
@onready var debug_mesh_2: MeshInstance3D = $DebugCube2
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

func _ready() -> void:
	handle_one_transform = handle_one.global_transform
	handle_two_transform = handle_two.global_transform
	handle_one_position = handle_one.global_position-global_position
	handle_two_position = handle_two.global_position-global_position
	debug_mesh_1.visible = false
	debug_mesh_2.visible = false
	handle_one.released.connect(_return_handle_one)
	handle_two.released.connect(_return_handle_two)
	handle_one.grabbed.connect(_handle_one_picked_up)
	handle_two.grabbed.connect(_handle_two_picked_up)
	did_setup_info = false
	
func _handle_one_picked_up(pickable, by) -> void:
	handle_one_hand = by.get_parent()
	debug_mesh_1.visible = true
	
	
func _handle_two_picked_up(pickable, by) -> void:
	handle_two_hand = by.get_parent()
	debug_mesh_2.visible = true
	
func _return_handle_one(pickable, by) -> void:
	handle_one_hand = null
	var new_transform: Transform3D = Transform3D()
	
	new_transform = new_transform.rotated(Vector3.UP, global_rotation.y)
	new_transform = new_transform.translated(handle_one_position.rotated(Vector3.UP, global_rotation.y) + global_position)
	handle_one.global_transform = handle_one_transform
	debug_mesh_1.visible = false
	
func _return_handle_two(pickable, by) -> void:
	handle_two_hand = null
	var new_transform: Transform3D = Transform3D()
	new_transform = new_transform.rotated(Vector3.UP, global_rotation.y)
	new_transform = new_transform.translated(handle_two_position.rotated(Vector3.UP, global_rotation.y) + global_position)
	handle_one.global_transform = handle_two_transform
	debug_mesh_1.visible = false
	
func _setup_player_info() -> void:
	did_setup_info = true
	
	var current_parent = get_parent()
	
	while current_parent is not XRToolsSceneBase:
		current_parent = current_parent.get_parent()
	
	xr_origin = current_parent.get_child(0)
	player_body = xr_origin.get_child(3)
	
	starting_player_vector = Plane(Vector3.ZERO, Vector3.UP).project(-xr_origin.basis.z).normalized()
	
func _process(delta: float) -> void:
	
	if handle_one.is_picked_up() and handle_one_hand != null:
		debug_mesh_1.global_transform = handle_one_hand.global_transform
	else:
		handle_one.global_transform = handle_one_transform
		handle_one.global_position = handle_one_position + global_position
		
		
	
	if handle_two.is_picked_up() and handle_two_hand != null:
		debug_mesh_2.global_transform = handle_two_hand.global_transform
	else:
		handle_two.global_transform = handle_two_transform
		handle_two.global_position = handle_two_position + global_position
	
		
		
func _physics_process(delta):
	if handle_one_hand != null and handle_two_hand != null:
		if not did_setup_info:
			_setup_player_info()
			
		var hands_midpoint = (handle_one_hand.global_position + handle_two_hand.global_position) / 2
		var position_vector = Vector3(0.0, 0.0, 2.3)
		
		var new_transform = Transform3D(Basis.IDENTITY, hands_midpoint - (-xr_origin.basis.z * 2.3))
		global_transform = new_transform.looking_at(hands_midpoint, Vector3.UP)
		
		print("SET NEW POSITION")
	
	
		

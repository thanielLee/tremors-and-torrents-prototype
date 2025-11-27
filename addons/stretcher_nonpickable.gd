extends RigidBody3D
class_name StretcherNonPickable

@onready var handle_one: XRToolsPickable = $PickableObject
@onready var handle_two: XRToolsPickable = $PickableObject2
@onready var debug_mesh_1: MeshInstance3D = $DebugCube1
@onready var debug_mesh_2: MeshInstance3D = $DebugCube2
var handle_one_transform: Transform3D
var handle_two_transform: Transform3D
var handle_one_hand: XRController3D
var handle_two_hand: XRController3D 

func _ready() -> void:
	handle_one_transform = handle_one.global_transform
	handle_two_transform = handle_two.global_transform
	debug_mesh_1.visible = false
	debug_mesh_2.visible = false
	handle_one.released.connect(_return_handle_one)
	handle_two.released.connect(_return_handle_two)
	handle_one.grabbed.connect(_handle_one_picked_up)
	handle_two.grabbed.connect(_handle_two_picked_up)
	
func _handle_one_picked_up(pickable, by) -> void:
	handle_one_hand = by.get_parent()
	debug_mesh_1.visible = true
	
func _handle_two_picked_up(pickable, by) -> void:
	handle_two_hand = by.get_parent()
	debug_mesh_2.visible = true
	
func _return_handle_one(pickable, by) -> void:
	handle_one.global_transform = handle_one_transform
	handle_one_hand = null
	
func _return_handle_two(pickable, by) -> void:
	handle_two.global_transform = handle_two_transform
	handle_two_hand = null
	
func _process(delta: float) -> void:
	if handle_one.is_picked_up() and handle_one_hand != null:
		print('HANDLE ONE PICKED UP')
		debug_mesh_1.global_transform = handle_one_hand.global_transform
	
	if handle_two.is_picked_up() and handle_two_hand != null:
		print('HANDLE TWO PICKED UP')
		debug_mesh_2.global_transform = handle_two_hand.global_transform

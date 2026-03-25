extends RigidBody3D


@export var float_force: float =  1.0
@export var water_linear_drag: float = 0.05
@export var water_angular_drag: float = 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")	
@onready var water_node: FloodPlane = $"../FloodPlane"

@onready var probes = $Probes.get_children()
@onready var boat_mesh_container: BoatMesh = $BoatMeshContainer

var mouse_movement: Vector2 = Vector2()

const water_height := 0.0
var submerged := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_movement += event.relative

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	submerged = false
	#boat_mesh_container.set_handle_rotation(0)
	if mouse_movement != Vector2():
		$H.rotation_degrees.y += -mouse_movement.x
		$H/V.rotation_degrees.x += -mouse_movement.y
		
		mouse_movement = Vector2()
		
		if $H/V.rotation_degrees.x <= -90:
			$H/V.rotation_degrees.x = -90
		
		if $H/V.rotation_degrees.x >= 90:
			$H/V.rotation_degrees.x = 90
		
	#
	if Input.is_action_pressed("w"):
		apply_central_force(-global_transform.basis.z * 20)
		if Input.is_action_pressed("a"):
			apply_torque(Vector3(0, 1, 0)*5)
			#boat_mesh_container.set_handle_rotation(90)
		elif Input.is_action_pressed('d'):
			apply_torque(Vector3(0, -1, 0)*5)
			#boat_mesh_container.set_handle_rotation(-90)
	elif Input.is_action_pressed("s"):
		apply_central_force(global_transform.basis.z * 20)
		if Input.is_action_pressed("a"):
			#boat_mesh_container.set_handle_rotation(90)
			apply_torque(Vector3(0, -1, 0)*5)
		elif Input.is_action_pressed('d'):
			#boat_mesh_container.set_handle_rotation(-90)
			apply_torque(Vector3(0, 1, 0)*5)
	
	
		
	
	for p in probes:
		var depth = water_node.get_height(p.global_position) - p.global_position.y
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * depth, p.global_position - global_position)
		


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if submerged:
		state.linear_velocity *= 1 - water_linear_drag
		state.angular_velocity *= 1 - water_angular_drag

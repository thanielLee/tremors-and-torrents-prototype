extends Node3D

@onready var parent_pickable = $".."
var is_active = false

func _ready():
	parent_pickable.connect("action_pressed", start_action)
	parent_pickable.connect("action_released", end_action)

func _physics_process(delta):
	if is_active:
		send_raycast()

func start_action(pickable):
	print("action started!")
	is_active = true
	pass
	

func send_raycast():
	var forward_vector = -global_transform.basis.z
	var space_state = get_world_3d().direct_space_state
	var raycast_query = PhysicsRayQueryParameters3D.create(global_position, global_position + forward_vector*20)
	
	var str = ""
	for i in range(33):
		if raycast_query.collision_mask & (1<<i) != 0:
			str += "1"
		else:
			str += "0"
	print(str)
	
	var result = space_state.intersect_ray(raycast_query)
	 
	if result.has("collider"):
		var object_hit = result["collider"]
		print("HIT: " + object_hit.name)
		if object_hit.get_parent().get_parent().name == "ElectricalFire":
			print("YIPPEE")


func end_action(pickable):
	print("action ended!")
	is_active = false
	pass

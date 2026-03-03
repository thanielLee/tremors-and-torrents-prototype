extends Node3D

signal door_cleared()

@onready var mesh: Node3D = $Mesh
@onready var break_door_sound: AudioStreamPlayer3D = $BreakDoorSound
@onready var break_sound: AudioStreamPlayer3D = $BreakSound
@onready var hit_points: Node3D = $HitPoints
@onready var hit_sound: AudioStreamPlayer3D = $HitSound
@onready var break_particles: GPUParticles3D = $BreakParticles
@onready var door_mesh: Node3D 
var door_mesh_child: Node
var hit_point_count : int
var door_mesh_children: Array = []

# For rumble
@export var strike_rumble_event: XRToolsRumbleEvent
@export var break_rumble_event: XRToolsRumbleEvent
var last_controller: XRController3D = null
var id_counter: int = 0

func _ready() -> void:
	hit_point_count = hit_points.get_child_count()
	
	for hit_point in hit_points.get_children():
		for child in hit_point.get_children():
			if child is OISStrikeReceiver:
				child.action_completed.connect(_on_hit_point_completed.bind(hit_point)) # for hit point desrtoyed
				child.action_started.connect(_on_hit_point_started)
				child.rumble_hand.connect(_on_rumble_hand)
				
		hit_point.hitpoint_id = id_counter
		id_counter += 1
	door_mesh = $Mesh
	var door_mesh_child
	for child in door_mesh.get_children():
		print(child.name + " " + str(child))
		if child.name == "broken_door":
			door_mesh_child = child
			
	for child in door_mesh_child.get_children():
		if "broken_door" in child.name:
			door_mesh_children.push_back(child)

func _reset_door():
	for door_child in door_mesh_children:
		door_child.visible = true
		
	for hit_point in hit_points.get_children():
		for child in hit_point.get_children():
			if child is OISStrikeReceiver:
				print("RESETTING RECEIVER")
				child.hit_already = false
				child.total_progress = 0
				child.completed = false
	enable_door()
	hit_point_count = 4

func check_finished():
	if hit_point_count <= 0:
		disable_door()
		# TODO: implement break door sound and particles

func _on_hit_point_started(requirement: Variant, total_progress: Variant) -> void:
	if hit_sound and not hit_sound.playing:
		hit_sound.play()
	## TODO: implement hit particles

func _on_hit_point_completed(requirement: Variant, total_progress: Variant, hit_point: Node) -> void:
	print("HitPoint cleared: ", hit_point.name)
	
	break_particles.position = hit_point.position
	break_particles.emitting = true
	
	var receiver: OISStrikeReceiver = hit_point.find_child("OISStrikeReceiver")
	var receiver_area3d: Area3D = hit_point.find_child("Area3D")
	
	receiver_area3d.collision_layer = 0
	receiver_area3d.collision_mask = 0
	hit_point_count -= 1
	
	door_mesh_children[hit_point.hitpoint_id].visible = false
	
	if break_sound:
		break_sound.play()
	
	if last_controller:
		XRToolsRumbleManager.add("door_break", break_rumble_event, [last_controller])
	
	check_finished()

## gets reference to controller first
func _on_rumble_hand(controller: XRController3D):
	last_controller = controller
	print("controller: ", controller)
	if strike_rumble_event:
		print("rumbling")
		XRToolsRumbleManager.add("door_strike", strike_rumble_event, [last_controller])

func disable_door():
	print("Door cleared")
	emit_signal("door_cleared")
	mesh.visible = false
	break_door_sound.play()
		
	var static_body_node:StaticBody3D = get_child(0)
	static_body_node.collision_layer = 0
	for point in hit_points.get_children():
		for child in point.get_children():
			if child is OISStrikeReceiver:
				for grandchild in child.get_children():
					if grandchild is Area3D:
						grandchild.collision_layer = 0
						grandchild.collision_mask = 0

func enable_door():
	mesh.visible = true
	var static_body_node:StaticBody3D = get_child(0)
	static_body_node.collision_layer = (1<<0) | (1<<29)
	for point in hit_points.get_children():
		for child in point.get_children():
			if child is OISStrikeReceiver:
				for grandchild in child.get_children():
					if grandchild is Area3D:
						grandchild.collision_layer = (1<<29)
						grandchild.collision_mask = (1<<29)


func _on_break_door_sound_finished() -> void:
	#disable_door()
	pass
	#queue_free()

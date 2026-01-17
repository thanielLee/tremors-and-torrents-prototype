extends ObjectiveBase

signal victim_safe
signal victim_triggered_hazard

@export var follow_strength: float = 10.0
@export var max_force: float = 80.0
@export var dialogue_states: Array[String] = []

@onready var body: RigidBody3D = $RigidBody3D
@onready var mesh_instance_3d: MeshInstance3D = $RigidBody3D/MeshInstance3D
@onready var area_3d: Area3D = $RigidBody3D/Area3D
@onready var pickable: XRToolsPickable = $RigidBody3D/XRToolsPickable

var dialogue_sys
var cur_state: String
var state_index = 0

# movement logic
var following: bool = false
var player

var left_hand_held := false
var right_hand_held := false
var assisted_walk_active := false


func _ready():
	super._ready()
	active = true
	victim_safe.connect(_on_victim_safe)
	victim_triggered_hazard.connect(_on_victim_hazard)
	
	# dialogue
	if dialogue_states.size() > 0:
		cur_state = dialogue_states[state_index]
	
	# movement setup
	pickable.grabbed.connect(_on_grabbed)
	pickable.released.connect(_on_released)
	#pickable.action_pressed.connect(_on_action_pressed)
	#pickable.action_released.connect(_on_action_released)
	
	body.linear_damp = 10.0
	body.angular_damp = 10.0
	body.freeze = true

func _on_grabbed(pickable, by):
	var grab_point = pickable.get_active_grab_point()
	#print(grab_point)
	if grab_point == null:
		return
	if grab_point.name == "GrabPointHandLeft":
		left_hand_held = true
	elif grab_point.name == "GrabPointHandRight":
		right_hand_held = true

	_update_assisted_walk_state()

func _on_released(pickable, by):
	var grab_point = pickable.get_active_grab_point()
	#print(grab_point)
	if grab_point == null:
		return
	if grab_point.name == "GrabPointHandLeft":
		left_hand_held = false
	elif grab_point.name == "GrabPointHandRight":
		right_hand_held = false

	_update_assisted_walk_state()

#func _on_action_pressed():
	#pass
#
#func _on_action_released():
	#pass

func _update_assisted_walk_state():
	print("left_hand_held ", left_hand_held)
	print("right_hand_held ", right_hand_held)
	assisted_walk_active = left_hand_held and right_hand_held
	
	if assisted_walk_active:
		body.freeze = false
	else:
		body.freeze = true
	
	print("body.freeze ", body.freeze)
	print(pickable.get_picked_up_by())


func next_state_dialogue():
	state_index += 1
	
	if dialogue_states.size() > state_index:
		cur_state = dialogue_states[state_index]

func _on_victim_safe():
	complete_objective()

func _on_victim_hazard():
	fail_objective()

func _physics_process(delta: float) -> void:
	if not active or not enabled:
		return
	#if not following or target_node == null:
		#return

	#var victim_pos = body.global_position
	#var target_pos = target_node.global_position
	#
	#var direction = target_pos - victim_pos
	#var distance = direction.length()
#
	## Do nothing if very close
	#if distance < 0.3:
		#return
#
	## Correct direction (move toward player)
	#var force = direction.normalized() * follow_strength
#
	## Clamp force
	#if force.length() > max_force:
		#force = force.normalized() * max_force
#
	#body.apply_central_force(force)
	
	if not assisted_walk_active:
		return

	#var pickup_node := pickable.get_picked_up_by()
	#if pickup_node != null:
		#var player = pickup_node.get_parent().get_parent() # gets XROrigin3D
	#print("player ", player)
	#if not player:
		#return

	var target_pos = player.global_position
	target_pos.y = body.global_position.y  # prevent floating

	var direction = target_pos - body.global_position
	body.global_position += direction * delta * 2.0


# detecting the player
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not enabled or not active:
		return
	
	player = body
	#following = true
	set_capsule_color(Color.GREEN)


# detecting hazards or safe zone
func _on_area_3d_area_entered(area: Area3D) -> void:
	#print(area.name)
	
	if area.name == "SafeArea":
		emit_signal("victim_safe")
		following = false
	elif area.get_parent().get_script() == Hazard:
		emit_signal("victim_triggered_hazard")
		print("fail rescue")
	else:
		return

func set_capsule_color(color: Color):
	var material := mesh_instance_3d.get_surface_override_material(0)
	
	# If mesh has no material
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance_3d.set_surface_override_material(0, material)
	
	material.albedo_color = color


func _on_xr_tools_interactable_area_pointer_event(event: Variant) -> void:
	if !dialogue_sys:
		dialogue_sys = get_tree().get_first_node_in_group("dialogue_system")
	
	if !dialogue_sys.dialogue_active():
		if (event.event_type == XRToolsPointerEvent.Type.PRESSED):
			dialogue_sys.start_dialogue(name, cur_state, objective_name)

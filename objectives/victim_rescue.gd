extends ObjectiveBase

signal victim_safe
signal victim_triggered_hazard

#@export var follow_strength: float = 10.0
#@export var max_force: float = 80.0
@export var side_offset: float = 0.6	# meters to the right
@export var back_offset: float = 0.2	# slightly behind player

@export var dialogue_states: Array[String] = []
@export var offset: Vector3 = Vector3(-0.5, 1, -0.5)

@onready var body: RigidBody3D = $RigidBody3D
@onready var mesh_instance_3d: MeshInstance3D = $RigidBody3D/MeshInstance3D
@onready var area_3d: Area3D = $RigidBody3D/Area3D
@onready var pickable: XRToolsPickable = $RigidBody3D/XRToolsPickable
@onready var interactable_handle_right: XRToolsInteractableHandle = $RigidBody3D/RightHandle/InteractableHandleRight
@onready var interactable_handle_left: XRToolsInteractableHandle = $RigidBody3D/LeftHandle/InteractableHandleLeft


var dialogue_sys
var cur_state: String
var state_index = 0

# movement logic
var following: bool = false
var player: XROrigin3D

var left_hand_held := false
var right_hand_held := false


func _ready():
	super._ready()
	active = true
	victim_safe.connect(_on_victim_safe)
	victim_triggered_hazard.connect(_on_victim_hazard)
	
	# dialogue
	if dialogue_states.size() > 0:
		cur_state = dialogue_states[state_index]
	
	interactable_handle_right.grabbed.connect(_on_grabbed)
	interactable_handle_left.grabbed.connect(_on_grabbed)
	interactable_handle_right.released.connect(_on_released)
	interactable_handle_left.released.connect(_on_released)
	
	body.linear_damp = 10.0
	body.angular_damp = 10.0
	body.freeze = true

func _on_grabbed(handle, by):
	var grab_point = handle.get_child(1).target # GrabPointRedirect
	if grab_point == null:
		return
	if grab_point.name == "GrabPointHandRight":
		right_hand_held = true
	elif grab_point.name == "GrabPointHandLeft":
		left_hand_held = true

func _on_released(handle, by):
	var grab_point = handle.get_child(1).target # GrabPointRedirect
	if grab_point == null:
		return
	if grab_point.name == "GrabPointHandRight":
		right_hand_held = false
	elif grab_point.name == "GrabPointHandLeft":
		left_hand_held = false


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
	
	if not (left_hand_held and right_hand_held and player):
		return
	
	var pbasis := player.global_transform.basis
	var right := pbasis.x.normalized()
	var forward := -pbasis.x.normalized()
	
	var target_pos := player.global_position + right*side_offset - forward*back_offset
	
	target_pos.y = body.global_position.y
	
	body.global_position = target_pos
	body.global_transform.basis = Basis().looking_at(forward, Vector3.UP)

# detecting the player
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not enabled or not active:
		return
	
	player = body.get_parent()


# detecting hazards or safe zone
func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.name == "SafeArea":
		emit_signal("victim_safe")
		following = false
	elif area.get_parent().get_script() == Hazard:
		emit_signal("victim_triggered_hazard")
		print("fail rescue")
	else:
		return

func _on_xr_tools_interactable_area_pointer_event(event: Variant) -> void:
	if !dialogue_sys:
		dialogue_sys = get_tree().get_first_node_in_group("dialogue_system")
	
	if !dialogue_sys.dialogue_active():
		if (event.event_type == XRToolsPointerEvent.Type.PRESSED):
			dialogue_sys.start_dialogue(name, cur_state, objective_name)

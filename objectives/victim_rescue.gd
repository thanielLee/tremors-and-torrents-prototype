extends ObjectiveBase

signal victim_safe
signal victim_triggered_hazard

@export var follow_strength: float = 5.0
@export var max_force: float = 50.0
@export var dialogue_states: Array[String] = []

@onready var rigid_body_3d: RigidBody3D = $RigidBody3D
@onready var mesh_instance_3d: MeshInstance3D = $RigidBody3D/MeshInstance3D
#@onready var area_3d: Area3D = $Area3D
@onready var area_3d: Area3D = $RigidBody3D/Area3D

var dialogue_sys
var cur_state: String
var state_index = 0

var following: bool = false
var target_node

func _ready():
	super._ready()
	active = true
	victim_safe.connect(_on_victim_safe)
	victim_triggered_hazard.connect(_on_victim_hazard)
	
	# dialogue
	if dialogue_states.size() > 0:
		cur_state = dialogue_states[state_index]

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
	if not following or target_node == null:
		return
	
	var direction = (target_node.position - position)
	var distance = direction.length()
	
	if distance > 0.1:
		var force = direction.normalized() * follow_strength
		rigid_body_3d.apply_central_force(force)

# detecting the player
func _on_area_3d_body_entered(body: Node3D) -> void:
	if not enabled or not active:
		return
	
	target_node = body
	following = true
	set_capsule_color(Color.GREEN)


# detecting hazards or safe zone
func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area.name)
	
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

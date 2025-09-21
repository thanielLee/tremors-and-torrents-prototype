extends RigidBody3D

# If objective is active or not
@export var active: bool

@export var follow_strength: float = 5.0
@export var max_force: float = 50.0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

# Victim is following player
var following: bool
var target_node

# Dialogue
@onready var interactable_area = $XRToolsInteractableArea
@onready var instructions: Node3D = $Instructions

signal victim_triggered_hazard
signal victim_safe
#func _ready():
	#interactable_area.pointer_event.connect(_on_pointer_event)

func _physics_process(delta: float) -> void:
	if not active:
		return
	
	if not following:
		return
	
	var direction = (target_node.global_transform.origin - global_transform.origin)
	var distance = direction.length()
	
	if distance > 0.1:
		var force = direction.normalized() * follow_strength
		apply_central_force(force)

func _on_detection_area_body_entered(body: Node3D) -> void:
	if not active:
		return
	
	target_node = body
	following = true
	set_capsule_color(Color.GREEN)
	
func _on_detection_area_area_entered(area: Area3D) -> void:
	print(area)
	if area.get_parent().get_script() == Hazard:
		emit_signal("victim_triggered_hazard")
	else:
		emit_signal("victim_safe")
		following = false

func set_capsule_color(color: Color):
	var material := mesh_instance_3d.get_surface_override_material(0)
	
	# If mesh has no material
	if material == null:
		material = StandardMaterial3D.new()
		mesh_instance_3d.set_surface_override_material(0, material)
	
	material.albedo_color = color

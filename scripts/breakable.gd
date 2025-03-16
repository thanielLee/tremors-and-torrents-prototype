@tool
class_name Breakable
extends RigidBody3D

## Breakable Object (Requires [Area3D])
##
## This script allows a [RigidBody3D] with an [Area3D] to be 
## broken by objects that belong to the "can_break" group. 
## 
## Default layer of held tools is on Layer 17

@export var health: int = 3

# Area3D to detect collisions
var area: Area3D

var hit_sound: AudioStreamPlayer3D

func _ready():
	area = get_node_or_null("Area3D")
	if area == null:
		push_error("Breakable does not have an Area3D node.")
		return
	
	hit_sound = $AudioStreamPlayer3D
	hit_sound.pitch_scale = randf_range(0.9, 1.1)  # Small variation in pitch
	
	# Setting up Area3D for collision
	area.collision_layer = 2
	area.collision_mask = 1 << 16 # Bitwise shift left operator. Layer 17 is on the 16th bit
	
	# Connecting signal automatically if not already 
	if not area.body_entered.is_connected(_on_area_3d_body_entered):
		area.body_entered.connect(_on_area_3d_body_entered)

func apply_damage():
	if hit_sound:
		hit_sound.play()
	health -= 1
	if health <= 0:
		break_object()

# This is where destruction animation logic can be placed
# For now, just delete object from tree
func break_object():
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("can_break"):
		apply_damage()

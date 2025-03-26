@tool
class_name Breakable
extends StaticBody3D

## Breakable Object (Requires [Area3D])
##
## This script allows a [StaticBody3D] with an [Area3D] to be 
## broken by objects that belong to the "can_break" group. 
## 
## Default layer of held tools is on Layer 17

@export var health: int = 3
@export var damage_cooldown: float = 1.0 # Damage cooldown

# Area3D to detect collisions
var area: Area3D
var can_take_damage: bool = true

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
	# Only apply damage if cooldown has passed 
	if not can_take_damage:
		return

	if hit_sound:
		hit_sound.play()

	can_take_damage = false
	health -= 1
	if health <= 0:
		# Ensures sound plays before destroying
		var sfx_length: float = 0.0
		if hit_sound and hit_sound.stream:
			sfx_length = hit_sound.stream.get_length()
		await get_tree().create_timer(sfx_length).timeout
		
		break_object()
	else:
		await get_tree().create_timer(damage_cooldown).timeout
		can_take_damage = true

# This is where destruction animation logic can be placed
# For now, just delete object from tree
func break_object():
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("can_break"):
		apply_damage()

extends Node3D


@export var shake_duration := 0.5
@export var shake_intensity := 0.1
var time_left = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if time_left > 0:
		time_left -= delta
		var shake_offset = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_intensity
		global_position = shake_offset
		#print(shake_offset)
	else:
		global_position = Vector3.ZERO

func shake_world():
	time_left = shake_duration

func on_shake_hazard_triggered(name: String):
	shake_world()

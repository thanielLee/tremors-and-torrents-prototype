extends Node3D


@export var shake_duration := 0.5
@export var shake_intensity := 0.1
var time_left = 0.0
@onready var xr_tools_rumbler: XRToolsRumbler = $XRToolsRumbler
@onready var xr_tools_rumbler_2: XRToolsRumbler = $XRToolsRumbler2


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
	xr_tools_rumbler.rumble()
	xr_tools_rumbler_2.rumble()
	

func _on_level_1_shake_world() -> void:
	shake_world()

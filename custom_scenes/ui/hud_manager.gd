extends Node3D
class_name HUDManager

@export var xr_origin_3d: XROrigin3D
@export var xr_camera: Node3D
@export var ui_distance: float = 2.5
@export var ui_height: float = -0.5

@onready var hud: XRToolsViewport2DIn3D = $HUD
@onready var result_log: Node3D = $ResultLog

var hud_script
var result_log_script
var elapsed_time: float = 0.0

func _ready():
	hud_script = hud.get_scene_instance()
	result_log_script = result_log.get_scene_instance()
	set_process(true)

func _process(delta):
	if xr_origin_3d:
		_update_ui_position()
	
	elapsed_time += delta
	hud_script.set_timer(elapsed_time)

func _update_ui_position():
	var forward = -xr_camera.global_transform.basis.z
	var target_pos = xr_camera.global_position + forward * ui_distance
	target_pos.y += ui_height
	hud.global_position = target_pos
	#hud.rotation = xr_camera.rotation
	#hud.rotation = xr_camera.rotation
	hud.look_at(xr_origin_3d.global_position + Vector3(0, (xr_camera.global_position-xr_origin_3d.global_position).length(), 0), Vector3.UP, true)
	
	# only rotate horizontally to face player. needs testing
	#var look_dir = xr_origin_3d.global_transform.basis.z
	#hud.look_at(hud.global_position - look_dir, Vector3.UP)
	
	## fixing orientation
	#var origin_forward = -xr_origin_3d.global_transform.basis.z
	#origin_forward.y = 0 # yaw only
	#origin_forward = origin_forward.normalized()
	#
	## combine yaw from origin + pitch from camera
	#var look_dir = origin_forward
	#look_dir.y = camera_forward.y
	#look_dir = look_dir.normalized()
	#
	## face player
	#hud.look_at(hud.global_position + look_dir, Vector3.UP)

func show_prompt(message: String, duration: float = 2.0):
	hud_script.show_prompt(message, duration)

func on_qte_started(obj: Node):
	hud_script.on_qte_started(obj)

func on_qte_completed():
	hud_script.on_qte_completed()

func on_qte_failed():
	hud_script.on_qte_failed()

func on_obj_started(obj: Node):
	hud_script.on_obj_started(obj)

func on_obj_completed(obj: Node):
	hud_script.on_obj_completed(obj)

func update_obj_status_label(time: float):
	hud_script.update_obj_status_label(time)

func qte_update_status(status: bool):
	hud_script.update_qte_status_label(status)

func end_level_prompt(success: bool, score: int, message: String = ""):
	hud_script.end_level_prompt(success, score, message)

func update_score(new_score: int):
	hud_script.update_score(new_score)

func reset_timer():
	elapsed_time = 0.0
	hud_script.reset_timer()

func hide_timer():
	hud_script.hide_timer()

func log_results(message: String):
	# print("logging results in hud manager")
	result_log_script.log_results(message)
	result_log.visible = true

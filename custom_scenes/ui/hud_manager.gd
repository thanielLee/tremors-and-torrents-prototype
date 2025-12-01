extends Node3D

@export var xr_origin_3d: XROrigin3D
@export var xr_camera: Node3D
@export var ui_distance: float = 2.5
@export var ui_height: float = -0.5

@onready var hud: XRToolsViewport2DIn3D = $HUD
var hud_script
var elapsed_time: float = 0.0

func _ready():
	hud_script = hud.get_scene_instance()
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
	hud.rotation = xr_camera.rotation
	#hud.global_rotation = xr_origin_3d.global_position
	
	# only rotate horizontally to face player. needs testing
	#var look_dir = xr_origin_3d.global_transform.basis.z
	#hud.look_at(hud.global_position - look_dir, Vector3.UP)

func show_prompt(message: String, duration: float = 2.0):
	hud_script.show_prompt(message, duration)

func on_qte_started(obj: Node):
	hud_script.on_qte_started(obj)

func on_qte_completed():
	hud_script.on_qte_completed()

func on_qte_failed():
	hud_script.on_qte_failed()

func qte_update_status(status: bool):
	hud_script.update_qte_status_label(status)

func end_level_prompt(success: bool, score: int):
	hud_script.end_level_prompt(success, score)

func update_score(new_score: int):
	hud_script.update_score(new_score)

func reset_timer():
	elapsed_time = 0.0
	hud_script.reset_timer()

func hide_timer():
	hud_script.hide_timer()

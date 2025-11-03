extends Node3D
class_name GameHUD

@export var xr_camera: XRCamera3D
@export var distance_from_camera: float = 2.0
@export var height_offset: float = -0.2

@onready var dialogue_ui = $DialogueUI
@onready var timer_ui = $TimerUI
@onready var prompt_ui = $PromptUI
@onready var qte_ui = $QTEUI

var level_time: float = 0.0
var is_timer_running: bool = false

func _ready():
	set_physics_process(true)


### POSITION ###

func _process(delta):
	if xr_camera:
		var forward = xr_camera.global_transform.basis.z
		global_position = xr_camera.global_position + forward * distance_from_camera
		look_at(xr_camera.global_position, Vector3.UP)

#### TIMER LOGIC ###
#func start_timer(time_sec: float):
	#level_time = time_sec
	#is_timer_running = true
	#timer_ui.get_node("")

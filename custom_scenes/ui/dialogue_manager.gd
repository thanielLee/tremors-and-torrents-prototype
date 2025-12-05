extends Node3D

@export var xr_origin_3d: XROrigin3D
@export var xr_camera: Node3D
@export var ui_distance: float = 2.5
@export var ui_height: float = -0.5
@export var dialogue_button_hand : XRController3D
@export_enum("ax_button", "by_button") var dialogue_button : String = "ax_button"
@export var dialogue_toggler_hand : XRController3D
@export var dialogue_toggler_button : String

var dialogue_button_pressed : bool

@onready var dialogue_ui: XRToolsViewport2DIn3D = $DialogueUI
#@onready var hud: XRToolsViewport2DIn3D = $HUD
var dialogue_script : DialogueUI
var elapsed_time: float = 0.0

func _ready():
	dialogue_script = dialogue_ui.get_scene_instance()
	dialogue_button_hand.button_pressed.connect(_dialogue_progress_pressed)
	
	#print(dialogue_script)
	set_process(true)

func _process(delta):
	if xr_origin_3d:
		_update_ui_position()
	
	elapsed_time += delta
	#dialogue_script.set_timer(elapsed_time)

func _update_ui_position():
	var forward = -xr_origin_3d.global_transform.basis.z
	var target_pos = xr_camera.global_position + forward * ui_distance
	target_pos.y += ui_height
	dialogue_ui.global_position = target_pos
	dialogue_ui.rotation = xr_origin_3d.rotation


func _dialogue_progress_pressed(event: String):
	if dialogue_active():
		if event == dialogue_button:
			dialogue_script.force_advance()
		
func start_dialogue(name: String, state: String, display_name: String):
	dialogue_script.start_dialogue(name, state, display_name)

func dialogue_active() -> bool:
	return dialogue_script.active

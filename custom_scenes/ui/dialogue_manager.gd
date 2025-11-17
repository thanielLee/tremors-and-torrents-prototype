extends Node3D

@export var xr_camera: Node3D
@export var ui_distance: float = 2.5
@export var ui_height: float = -0.5
@export var dialogue_button_hand : XRController3D
@export var dialogue_button : String
@export var dialogue_toggler_hand : XRController3D
@export var dialogue_toggler_button : String

var dialogue_button_pressed : bool

#signal button_pressed


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
	if xr_camera:
		_update_ui_position()
	
	elapsed_time += delta
	#dialogue_script.set_timer(elapsed_time)

func _update_ui_position():
	var forward = -xr_camera.global_transform.basis.z
	var target_pos = xr_camera.global_position + forward * ui_distance
	target_pos.y += ui_height
	dialogue_ui.global_position = target_pos
	dialogue_ui.rotation = xr_camera.rotation

func _dialogue_progress_pressed():
	dialogue_script.fore_advance()

func start_dialogue(name: String, state: String):
	print(name + " " + state)
	dialogue_script.start_dialogue(name, state)

#func show_prompt(message: String, duration: float = 2.0):
	#dialogue_script.show_prompt(message, duration)
#
#func on_qte_started(obj: Node):
	#hud_script.on_qte_started(obj)
#
#func on_qte_completed():
	#hud_script.on_qte_completed()
#
#func on_qte_failed():
	#hud_script.on_qte_failed()

extends XRToolsSceneBase
class_name Level2Briefing

@onready var dialogue_manager: DialogueManager = $DialogueManager
@onready var dialogue_ui: DialogueUI = $DialogueManager/DialogueUI.get_scene_instance()

@export_file('*.tscn') var scene : String

@export var left_controller: XRController3D
@export var right_controller: XRController3D

var briefing_complete: bool = false
var hold_time: float = 0.0
var required_hold_time: float = 2.0

func _ready() -> void:
	_start_briefing()
	dialogue_ui.dialogue_finished.connect(_on_briefing_finished)
	set_process(true)


func _start_briefing():
	dialogue_manager.start_dialogue("TeamCaptain", "level_2_briefing", "Captain")


func _on_briefing_finished():
	briefing_complete = true
	_show_deploy_prompt()


func _show_deploy_prompt():
	dialogue_manager.dialogue_ui.get_scene_instance().show()
	dialogue_manager.dialogue_ui.get_scene_instance().dialogue_text_label.text = "Hold both triggers to deploy."
	dialogue_manager.dialogue_ui.get_scene_instance().npc_name_label.text = "Ready"
	

func _process(delta):
	if not briefing_complete:
		return
	
	if _both_triggers_pressed():
		hold_time += delta
		if hold_time >= required_hold_time:
			to_level()
	else:
		hold_time = 0.0


func _both_triggers_pressed() -> bool:
	if not left_controller or not right_controller:
		return false
	print("both pressed!")
	#return false
	return left_controller.is_button_pressed("trigger") and right_controller.is_button_pressed("trigger")


func to_level():
	load_scene(scene)

extends XRToolsSceneBase
class_name Level2Briefing

@onready var dialogue_manager: DialogueManager = $DialogueManager
@onready var dialogue_ui: DialogueUI = $DialogueManager/DialogueUI.get_scene_instance()
@onready var teleport: Teleport = $Teleport

@export_file('*.tscn') var scene : String
@export_file('*.tscn') var scene2 : String

@export var left_controller: XRController3D
@export var right_controller: XRController3D

var briefing_complete: bool = false
var hold_time: float = 0.0
var required_hold_time: float = 2.0

func _ready() -> void:
	teleport.active = false
	_start_briefing()
	dialogue_ui.dialogue_finished.connect(_on_briefing_finished)
	set_process(true)
	
	var randomint = randi_range(0, 0)
	if randomint == 0:
		teleport.scene = scene
	elif randomint == 1:
		teleport.scene = scene2

func _start_briefing():
	dialogue_manager.start_dialogue("TeamCaptain", "briefing", "Captain")


func _on_briefing_finished(npc_name: String):
	print("briefing complete")
	briefing_complete = true
	#_show_deploy_prompt()
	teleport.active = true


#func _show_deploy_prompt():
	#dialogue_manager.dialogue_ui.get_scene_instance().show()
	#dialogue_manager.dialogue_ui.get_scene_instance().dialogue_text_label.text = "Hold both triggers to deploy."
	#dialogue_manager.dialogue_ui.get_scene_instance().npc_name_label.text = "Ready"
	

func _process(delta):
	if not briefing_complete:
		return
	
	if _both_triggers_pressed():
		hold_time += delta
		if hold_time >= required_hold_time:
			exit_to_main_menu()
	else:
		hold_time = 0.0


func _both_triggers_pressed() -> bool:
	if not left_controller or not right_controller:
		return false

	return left_controller.is_button_pressed("trigger") and right_controller.is_button_pressed("trigger")

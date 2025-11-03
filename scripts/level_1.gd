extends XRToolsSceneBase

## Level 1 Script
##
## This script extends XRToolsSceneBase and deals with the game elements
## specifically for Level 1
##
## This could serve as a guide/reference for future level creation  
##
## Handles initialization, hazards, objectives, and level flow.
@onready var xr_origin_3d = $XROrigin3D
var level_ended: bool = false

var hazards : Node
var objectives : Node
var world_shaker : Node
var qtes : Node
var earthquake_triggered: bool = false
var start_pos: Vector3
var brief_pos: Vector3

signal shake_world

var level_active = false
var level_timer : float = 0.0
var time_elapsed : float = 0.0
var score : int = 0 # Temporary basic scoring system 

var triggered_hazards: Array[String] = []
var completed_objectives: Array[String] = []
var UI_node
#var tooltip_node : DialogueElement

# Conditions
const HAZARD_LIMIT := 2
#const REQUIRED_OBJECTIVES := ["Victim"]

#@onready var dialogue_ui = $DialogueUI

func _ready():
	brief_player()
	#UI_node = $UI
	#tooltip_node = UI_node.get_child(0)

### LEVEL LIFECYCLE ###

func brief_player():
	print("brief player")
	start_pos = $StartPos.position
	brief_pos = xr_origin_3d.position
	
	#dialogue_ui.xr_camera_path = xr_origin_3d.get_path_to(xr_origin_3d.get_node("XRCamera3D"))
	#dialogue_ui.start_dialogue()

func start_level():
	xr_origin_3d.position = start_pos
	print("Level started")
	level_active = true
	level_timer = 0
	
	# Cache references
	hazards = get_node("Hazards")
	objectives = get_node("Objectives")
	world_shaker = get_node("WorldShaker")
	qtes = get_node("QTEs")

	enable_hazards()
	enable_objectives()

func end_level(success: bool):
	level_active = false
	level_ended = true
	level_timer = 0
	disable_hazards()
	
	
	if success:
		var output = "Level complete! Score: %s" % score
		print(output)
		#tooltip_node._change_text_timelimited(output, 24, false, output.length(), 5)
		#exit_to_main_menu()
		xr_origin_3d.position = start_pos
	else:
		var output = "Level failed! Score: %s" % score
		print(output)
		#tooltip_node._change_text_timelimited(output, 24, false, output.length(), 5)
		#exit_to_main_menu()
	
	
	# TODO: trigger results UI

### HAZARDS ###

func enable_hazards():
	# For connecting all hazard signals to call function _on_hazard_triggered(name)
	if not hazards: return
	for hazard in hazards.get_children():
		if hazard.has_signal("hazard_triggered"):
			hazard.hazard_triggered.connect(_on_hazard_triggered.bind(hazard))

func disable_hazards():
	if not hazards: return
	for hazard in hazards.get_children():
		if hazard.has_signal("hazard_triggered"):
			if hazard.hazard_triggered.is_connected(_on_hazard_triggered):
				hazard.hazard_triggered.disconnect(_on_hazard_triggered)

func _on_hazard_triggered(hazard: Variant):
	var hazard_name = hazard.name
	
	if hazard_name not in triggered_hazards:
		#tooltip_node._appear_text("Hazard: %s triggered!" % hazard_name, true)
		print("Hazard: %s triggered!" % hazard_name)
		triggered_hazards.append(hazard_name)
		
		score += hazard.penalty_points
		print(score)
		
		if triggered_hazards.size() >= HAZARD_LIMIT:
			end_level(false)
	
	# TODO: display logged hazards for results


### OBJECTIVES ###

func enable_objectives():
	if not objectives:
		return

	for obj in objectives.get_children():
		if obj.has_signal("objective_completed"):
			obj.objective_completed.connect(_on_objective_completed.bind(obj))
		if obj.has_signal("objective_failed"):
			obj.objective_failed.connect(_on_objective_failed.bind(obj))
		#print(obj.name)
		
	# VERY TEMPORARY
	#var victim: RigidBody3D = $Objectives/Victim
	#victim.victim_safe.connect(_on_objective_completed.bind(victim.name))
	#victim.victim_triggered_hazard.connect(_on_objective_failed.bind(victim.name))
	#
	#var injured: Node3D = $Objectives/Injured
	#injured.injured_cleared.connect(_on_objective_completed.bind(injured.name))


func _on_objective_completed(obj: Node):
	var name = obj.name
	if name not in completed_objectives:
		completed_objectives.append(name)
		print("Objective completed:", name)

		var points = obj.completed_points
		score += points
		print("Score:", score)

		check_level_end()

func _on_objective_failed(obj: Node):
	print("Objective failed:", obj.name)
	if obj.failed_points != 0:
		score += obj.failed_points
	end_level(false)

### LEVEL END CHECK ###
func check_level_end():
	if not objectives:
		return
	
	var all_required_done := true
	
	for obj in objectives.get_children():
		if obj.is_required:
			if obj.name not in completed_objectives:
				all_required_done = false
				break
	
	if all_required_done and triggered_hazards.size() < HAZARD_LIMIT:
		end_level(true)

### QTEs ###
#
#func enable_qtes():
	#if not qtes: return
	#for qte in qtes.get_children():
		#if qte.has_signal("qte_completed"):
			#qte.qte_completed.connect(_on_qte_completed.bind(qte))
		#if qte.has_signal("qte_failed"):
			#qte.qte_failed.connect(_on_qte_failed.bind(qte))
#
#func _on_qte_completed(qte: Variant):
	#var qte_name = qte.name
	#print("QTE: %s completed!" % qte_name)
	#
	#score += qte.completed_points
	#print(score)
#
#func _on_qte_failed(qte: Variant):
	#var qte_name = qte.name
	#print("QTE: %s failed!" % qte_name)


### PROCESS LOOP ###

func _process(delta: float) -> void:
	if level_active:
		level_timer += delta
		
		if not earthquake_triggered and level_timer > 10.0:
			emit_signal("shake_world")
			earthquake_triggered = true
		
		# Time ran out
		if level_timer > 120.0:
			end_level(false)
	# brief player
	else:
		time_elapsed += delta
		if time_elapsed > 1:
			start_level()
	
	if level_ended:
		time_elapsed += delta
		if time_elapsed > 5.0:
			exit_to_main_menu()
		
	

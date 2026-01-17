extends XRToolsSceneBase
class_name Level1

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

# Conditions
const HAZARD_LIMIT := 2
#const REQUIRED_OBJECTIVES := ["Victim"]
@onready var hud_manager: Node3D = $HUDManager


func is_xr_class(name : String) -> bool:
	return name == "Level1"

func _ready():
	brief_player()
	
	# save brief player
	brief_pos = xr_origin_3d.position

### LEVEL LIFECYCLE ###

func brief_player():
	pass
	
func start_level():
	xr_origin_3d.position = start_pos
	print("Level started")
	level_active = true
	level_timer = 0
	
	# Cache references
	hazards = get_node("Hazards")
	objectives = get_node("Objectives")
	world_shaker = get_node("WorldShaker")

	enable_hazards()
	enable_objectives()
	
	hud_manager.reset_timer()

func end_level(success: bool):
	level_active = false
	level_ended = true
	level_timer = 0
	time_elapsed = 0
	disable_hazards()

	hud_manager.end_level_prompt(success, score)
	hud_manager.hide_timer()
	xr_origin_3d.position = brief_pos

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
	var hazard_name = hazard.hazard_name
	
	if hazard_name not in triggered_hazards:
		score += hazard.penalty_points
		triggered_hazards.append(hazard_name)
		
		var message = "Hazard: %s triggered! %d" % [hazard_name, hazard.penalty_points]
		hud_manager.show_prompt(message, 3.0)
		hud_manager.update_score(score)
		
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
		if obj.has_signal("qte_started"):
			obj.qte_started.connect(_on_qte_started.bind(obj))
		if obj.has_signal("pose"):
			obj.pose.connect(_on_qte_update_status)
		if obj.has_signal("shake_world"):
			obj.shake_world.connect(do_earthquake)
		if obj.has_signal("stretcher_dropped"):
			var obj_logic = obj.get_node("ObjectiveLogic")
			obj_logic.objective_completed.connect(_on_objective_completed.bind(obj_logic))



func _on_objective_completed(obj: Node):
	if obj.name not in completed_objectives:
		completed_objectives.append(obj.name)
		
		score += obj.completed_points
		
		if obj.has_signal("qte_started"): # for qtes
			hud_manager.on_qte_completed()
		else: # for objectives
			var message = "Objective: %s completed! +%d" % [obj.objective_name, obj.completed_points]
			hud_manager.show_prompt(message, 3.0)
		
		hud_manager.update_score(score)
		check_level_end()

func _on_objective_failed(obj: Node):
	if obj.has_signal("qte_started"):
		hud_manager.on_qte_failed()
	else:
		var message = "Objective: %s failed! %d" % [obj.name, obj.failed_points]
		hud_manager.show_prompt(message, 3.0)

	if obj.failed_points != 0:
		score += obj.failed_points
	hud_manager.update_score(score)
	
	if obj.is_required:
		end_level(false)

func _on_qte_started(obj: Node):
	hud_manager.on_qte_started(obj)

func _on_qte_update_status(status: bool):
	hud_manager.qte_update_status(status)

### Helper function
func do_earthquake(duration):
	earthquake_triggered = true # for e.quake on time
	world_shaker.shake_world(duration)

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


### PROCESS LOOP ###

func _process(delta: float) -> void:
	if level_active:
		level_timer += delta
		
		if not earthquake_triggered and level_timer > 10.0:
			do_earthquake(5.0)
		
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
		if time_elapsed > 10.0:
			exit_to_main_menu()
		
	

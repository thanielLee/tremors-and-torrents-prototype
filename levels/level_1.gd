extends XRToolsSceneBase
class_name Level1

## Level 1 Script
##
## This script extends XRToolsSceneBase and deals with the game elements
## specifically for Level 1
##
## Handles initialization, hazards, objectives, and level flow.
@onready var objectives: Node3D = $Objectives
@onready var hud_manager: HUDManager = $HUDManager


var current_objective: ObjectiveBase = null
var obj_elapsed_time: float = 0.0
var obj_active: bool = false

func setup_objectives():
	if not objectives:
		return

	for obj in objectives.get_children():
		if obj.has_signal("objective_completed"):
			obj.objective_completed.connect(_on_objective_completed.bind(obj))
		if obj.has_signal("objective_failed"):
			obj.objective_failed.connect(_on_objective_failed.bind(obj))
		if obj.has_signal("objective_started"):
			obj.objective_started.connect(_on_objective_started.bind(obj))
		#if obj.has_signal("time"):
			#obj.time.connect(_on_obj_update_status)
		if obj.has_signal("qte_started"):
			obj.qte_started.connect(_on_qte_started.bind(obj))
		if obj.has_signal("pose"):
			obj.pose.connect(_on_qte_update_status)
		#if obj.has_signal("shake_world"):
			#obj.shake_world.connect(do_earthquake)
		if obj.has_signal("stretcher_dropped"):
			var obj_logic = obj.get_node("ObjectiveStretcher") as ObjectiveBase
			obj_logic.objective_started.connect(_on_objective_started.bind(obj_logic))
			obj_logic.objective_completed.connect(_on_objective_completed.bind(obj_logic))
			obj_logic.objective_failed.connect(_on_objective_failed.bind(obj_logic))

func _on_objective_started(obj: ObjectiveBase):
	current_objective = obj
	hud_manager.reset_timer()
	hud_manager.show_tim
	
	obj_active = true
	obj_elapsed_time = 0
	# disable other objectives right now
	#disable_other_objectives(obj)

func _on_obj_update_status(time: float):
	hud_manager.reset(time)

func _on_objective_completed(obj: ObjectiveBase):
	#if obj not in completed_objectives:
		#completed_objectives.append(obj)
		#completed_obj_times.append(obj_elapsed_time)
	obj_active = false
	
	#score += obj.completed_points
	
	if obj.has_signal("qte_started"): # for qtes
		hud_manager.on_qte_completed()
	else: # for objectives
		var message = "Objective: %s completed! +%d" % [obj.objective_name, obj.completed_points]
		hud_manager.show_prompt(message, 3.0)
		hud_manager.on_obj_completed(obj)
	
	#hud_manager.update_score(score)
	#
	#enable_objectives()
	#check_level_end()

func _on_objective_failed(obj: ObjectiveBase):
	obj_active = false
	if obj.has_signal("qte_started"):
		hud_manager.on_qte_failed()
	else:
		var message = "Objective: %s failed! %d" % [obj.name, obj.failed_points]
		hud_manager.show_prompt(message, 3.0)

	#if obj.failed_points != 0:
		#score += obj.failed_points
	#hud_manager.update_score(score)
	#
	#if obj.is_required:
		#fail_level("Required objective failed")
	#
	#enable_objectives()

func _on_qte_started(obj: Node):
	hud_manager.on_qte_started(obj)

func _on_qte_update_status(status: bool):
	hud_manager.qte_update_status(status)

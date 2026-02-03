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

@export var level_time_limit: float = 120

@onready var xr_origin_3d = $XROrigin3D
@onready var start_pos: Node3D = $StartPos
var level_ended: bool = false

var hazards : Node
var objectives : Node
var world_shaker : Node
var earthquake_triggered: bool = false
#var start_pos: Vector3
var brief_pos: Vector3

# signal shake_world

var level_active = false
var level_timer : float = 0.0
var time_elapsed : float = 0.0
var score : int = 0 

var completed_objectives: Array[ObjectiveBase] = [] # for obj completion tracking
var completed_obj_times: Array[float] = []
var triggered_hazards: Array[String] = []
const HAZARD_LIMIT := 2

# Global Audio Nodes
@onready var earthquake_rumble: AudioStreamPlayer = $GlobalAudioManager/EarthquakePlayer
@onready var background_music: AudioStreamPlayer = $GlobalAudioManager/BGMPlayer

var elapsed_time: float = 0
var obj_active: bool = false
# Conditions
@onready var hud_manager: Node3D = $HUDManager


func _ready():
	# save brief player
	brief_pos = xr_origin_3d.position
	hazards = get_node("Hazards")
	objectives = get_node("Objectives")
	world_shaker = get_node("WorldShaker")

	enable_hazards()
	setup_objectives()

### LEVEL LIFECYCLE ###

func start_level():
	xr_origin_3d.position = start_pos.position
	print("Level started")
	level_active = true
	level_timer = 0
	
	hud_manager.reset_timer()

func _reset_level_state():
	level_active = false
	level_ended = true
	level_timer = 0
	time_elapsed = 0
	disable_hazards()
	xr_origin_3d.position = brief_pos

func complete_level():
	_reset_level_state()
	log_results()
	hud_manager.end_level_prompt(true, score, "")
	hud_manager.hide_timer()

func fail_level(message: String):
	_reset_level_state()
	log_results()
	hud_manager.end_level_prompt(false, score, message)
	hud_manager.hide_timer()

func check_level_end():
	var all_required_done := true
	
	for obj in objectives.get_children():
		if obj.has_signal("stretcher_dropped"):
			continue
		if obj.is_required:
			if obj not in completed_objectives:
				all_required_done = false
				break
	
	if all_required_done and triggered_hazards.size() < HAZARD_LIMIT:
		complete_level()

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
			fail_level("Hazard limit reached")
		
	# TODO: display logged hazards for results


### OBJECTIVES ###

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
		if obj.has_signal("shake_world"):
			obj.shake_world.connect(do_earthquake)
		if obj.has_signal("stretcher_dropped"):
			var obj_logic = obj.get_node("ObjectiveStretcher") as ObjectiveBase
			obj_logic.objective_started.connect(_on_objective_started.bind(obj_logic))
			obj_logic.objective_completed.connect(_on_objective_completed.bind(obj_logic))
			obj_logic.objective_failed.connect(_on_objective_failed.bind(obj_logic))

func enable_objectives():
	for o in objectives.get_children():
		var obj = o as ObjectiveBase
		if not obj:
			continue
		if obj.completed or obj.failed:
			continue
		
		obj.enabled = true

func disable_other_objectives(obj: ObjectiveBase):
	for o in objectives.get_children():
		if o.name == obj.name:
			continue
		
		var other_obj = o as ObjectiveBase
		if other_obj:
			other_obj.enabled = false

func _on_objective_started(obj: ObjectiveBase):
	hud_manager.on_obj_started(obj)
	
	obj_active = true
	elapsed_time = 0
	# disable other objectives right now
	disable_other_objectives(obj)

func _on_obj_update_status(time: float):
	hud_manager.update_obj_status_label(time)

func _on_objective_completed(obj: ObjectiveBase):
	if obj not in completed_objectives:
		completed_objectives.append(obj)
		completed_obj_times.append(elapsed_time)
		obj_active = false
		
		score += obj.completed_points
		
		if obj.has_signal("qte_started"): # for qtes
			hud_manager.on_qte_completed()
		else: # for objectives
			var message = "Objective: %s completed! +%d" % [obj.objective_name, obj.completed_points]
			hud_manager.show_prompt(message, 3.0)
			hud_manager.on_obj_completed(obj)
		
		hud_manager.update_score(score)
		
		enable_objectives()
		check_level_end()

func _on_objective_failed(obj: ObjectiveBase):
	obj_active = false
	if obj.has_signal("qte_started"):
		hud_manager.on_qte_failed()
	else:
		var message = "Objective: %s failed! %d" % [obj.name, obj.failed_points]
		hud_manager.show_prompt(message, 3.0)

	if obj.failed_points != 0:
		score += obj.failed_points
	hud_manager.update_score(score)
	
	if obj.is_required:
		fail_level("Required objective failed")
	
	enable_objectives()

func _on_qte_started(obj: Node):
	hud_manager.on_qte_started(obj)

func _on_qte_update_status(status: bool):
	hud_manager.qte_update_status(status)

### Helper functionw
func do_earthquake(duration):
	#print(earthquake_rumble.stream.get_length() - duration)
	earthquake_rumble.play(earthquake_rumble.stream.get_length() - duration - 4.5)
	
	earthquake_triggered = true # for e.quake on time
	world_shaker.shake_world(duration)


### LOGGING

func log_results():
	var message: String = "Results:\n\n"
	for i in range(completed_objectives.size()):
		var obj_name = completed_objectives[i].objective_name
		var obj_time = completed_obj_times[i]
		message += "%s: %.2f seconds\n" % [obj_name, obj_time]
	
	hud_manager.log_results(message)

### PROCESS LOOP ###

func _process(delta: float) -> void:
	if level_ended:
		_handle_level_ended(delta)
	elif level_active:
		_handle_level_active(delta)
	else:
		_handle_level_briefing(delta)


func _handle_level_active(delta: float) -> void:
	level_timer += delta
	
	if obj_active:
		elapsed_time += delta
		_on_obj_update_status(elapsed_time)
	
	if level_timer >= level_time_limit:
		fail_level("Time limit exceeded")


func _handle_level_briefing(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed > 1.0:
		start_level()


func _handle_level_ended(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed > 10.0:
		exit_to_main_menu()
		
	

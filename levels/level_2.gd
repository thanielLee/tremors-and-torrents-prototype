extends XRToolsSceneBase
class_name Level2

## Level 2 Script
##
## This script extends XRToolsSceneBase and deals with the game elements
## specifically for Level 2
##
## This could serve as a guide/reference for future level creation  
##
## Handles initialization, hazards, objectives, and level flow.

@export var level_time_limit: float = 120.0
@export var briefing_time_limit: float = 15.0

@onready var xr_origin_3d = $XROrigin3D
@onready var start_pos: Vector3 = $StartPos.position
var brief_pos: Vector3
@onready var left_hand: XRController3D = $XROrigin3D/LeftHand
@onready var right_hand: XRController3D = $XROrigin3D/RightHand


var hazards : Node
var objectives : Node
var world_shaker : Node
var earthquake_triggered: bool = false


var level_ended: bool = false
var level_active: bool = false
var level_failed_obj_active: bool = false
var level_timer : float = 0.0
var time_elapsed : float = 0.0
var score : int = 0 

var seen_injured: bool = false
var seen_victim: bool = false

var completed_objectives: Array[ObjectiveBase] = [] # for obj completion tracking
var completed_obj_times: Array[float] = []
var triggered_hazards: Array[String] = []
const HAZARD_LIMIT := 2

# Global Audio Nodes
@onready var earthquake_rumble: AudioStreamPlayer = $GlobalAudioManager/EarthquakePlayer
@onready var background_music: AudioStreamPlayer = $GlobalAudioManager/BGMPlayer

var current_objective: ObjectiveBase = null
var obj_elapsed_time: float = 0.0
var obj_active: bool = false
var camera_forward: Vector3 = Vector3(0.0, 0.0, 1.0)
# Conditions
@onready var hud_manager: HUDManager = $HUDManager

@onready var injured = $Objectives/Injured
@onready var victim = $Objectives/VictimRescue
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
	hud_manager.reset_timer()

	print("Level started")
	level_active = true
	level_timer = 0
	teleport_player(start_pos)


func _reset_level_state():
	level_active = false
	level_ended = true
	level_timer = 0
	time_elapsed = 0
	disable_hazards()
	# xr_origin_3d.position = brief_pos

func complete_level():
	level_ended = true
	disable_hazards()

	if current_objective and obj_active:
		disable_other_objectives(current_objective)
	else:
		disable_objectives()
	# _reset_level_state()
	log_results()
	hud_manager.end_level_prompt(true, score, "")
	hud_manager.hide_timer()
	await get_tree().create_timer(5.0).timeout
	level_ended = true

func fail_level(message: String):
	disable_hazards()

	if current_objective and obj_active:
		disable_other_objectives(current_objective)
		level_ended = true
		level_failed_obj_active = true
		
		hud_manager.end_level_prompt(false, score, message)
		hud_manager.show_prompt("Finish current active objective to end level!", 3.0)
	else:
		disable_objectives()
		log_results()
		hud_manager.hide_timer()
		hud_manager.end_level_prompt(false, score, message)
		
		await get_tree().create_timer(5.0).timeout
		level_ended = true
		teleport_player(brief_pos)
	# _reset_level_state()

func check_level_end():
	var required_done := false
	
	for obj in objectives.get_children():
		if obj.has_signal("stretcher_dropped"):
			if obj.objective_script in completed_objectives:
				required_done = true
			continue
		if obj.is_required:
			if obj in completed_objectives:
				required_done = true
				break
	
	if required_done and triggered_hazards.size() < HAZARD_LIMIT:
		complete_level()

### HAZARDS ###

func enable_hazards():
	# For connecting all hazard signals to call function _on_hazard_triggered(name)
	if not hazards: return
	for h in hazards.get_children():
		var hazard = h as Hazard
		if hazard.has_signal("hazard_triggered"):
			hazard.hazard_triggered.connect(_on_hazard_triggered.bind(hazard))

func disable_hazards():
	if not hazards: return
	for h in hazards.get_children():
		var hazard = h as Hazard
		if hazard.has_signal("hazard_triggered"):
			if hazard.hazard_triggered.is_connected(_on_hazard_triggered):
				hazard.hazard_triggered.disconnect(_on_hazard_triggered)

func _on_hazard_triggered(hazard: Variant):
	var hazard_name = hazard.hazard_name
	
	if hazard_name == "Electrical Fire":
		if hazard.is_active:
			fail_level("Ran into fire")
		return
	
	if hazard_name not in triggered_hazards:
		score += hazard.penalty_points
		triggered_hazards.append(hazard_name)
		
		var message = "Hazard: %s triggered! %d" % [hazard_name, hazard.penalty_points]
		hud_manager.show_prompt(message, 3.0)
		hud_manager.update_score(score)
		
		if triggered_hazards.size() >= HAZARD_LIMIT:
			fail_level("Hazard limit reached")


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

func disable_objectives():
	for o in objectives.get_children():
		var obj = o as ObjectiveBase
		if obj:
			obj.enabled = false

func disable_other_objectives(obj: ObjectiveBase):
	for o in objectives.get_children():
		if o.name == obj.name:
			continue
		
		var other_obj = o as ObjectiveBase
		if other_obj:
			other_obj.enabled = false

func _on_objective_started(obj: ObjectiveBase):
	current_objective = obj
	hud_manager.on_obj_started(obj)
	
	obj_active = true
	obj_elapsed_time = 0
	# disable other objectives right now
	disable_other_objectives(obj)

func _on_obj_update_status(time: float):
	hud_manager.update_obj_status_label(time)

func _on_objective_completed(obj: ObjectiveBase):
	if obj not in completed_objectives:
		completed_objectives.append(obj)
		completed_obj_times.append(obj_elapsed_time)
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

func teleport_player(new_position: Vector3):
	xr_origin_3d.position = new_position

### LOGGING

func log_results():
	var message: String = "Results:\n\n"
	if completed_objectives.size() == 0:
		message += "No objectives completed.\n"
	else:
		for i in range(completed_objectives.size()):
			var obj_name = completed_objectives[i].objective_name
			var obj_time = completed_obj_times[i]
			message += "%s: %.2f seconds\n" % [obj_name, obj_time]
	
	message += "\nTime Taken: %.2f seconds\n" % level_timer
	message += "Total Score: %d\n" % score
	message += "Hazards Triggered: %d / %d\n" % [triggered_hazards.size(), HAZARD_LIMIT]

	hud_manager.log_results(message)

### PROCESS LOOP ###

func _process(delta: float) -> void:
	#print(str(injured.injured_seen) + " " + str(victim.victim_seen))
	
	
	
	if level_ended and not level_failed_obj_active:
		_handle_level_ended(delta)
	elif level_failed_obj_active:
		_handle_level_failed(delta)
	elif level_active:
		_handle_level_active(delta)
	else:
		#_handle_level_briefing(delta)
		start_level()
	
	camera_forward = $XROrigin3D/XRCamera3D.global_transform.basis.z * -1
	

func _physics_process(delta: float) -> void:
	
	seen_injured = seen_injured or _check_player_seen($Objectives/Injured/VisibleArea)
	seen_victim = seen_victim or _check_player_seen($Objectives/VictimRescue)
	
	#print("Seen Injured: " + str(seen_injured) + " Seen Victim: " + str(seen_victim))

func _handle_level_active(delta: float) -> void:
	level_timer += delta
	
	if obj_active:
		obj_elapsed_time += delta
		_on_obj_update_status(obj_elapsed_time)

	if level_timer >= level_time_limit:
		fail_level("Time limit exceeded")


#func _handle_level_briefing(delta: float) -> void:
	#level_timer += delta
	#if level_timer > briefing_time_limit:
		#start_level()
func _both_triggers_pressed() -> bool:
	if not left_hand or not right_hand:
		return false
	#print("both pressed!")
	#return false
	return left_hand.is_button_pressed("trigger") and right_hand.is_button_pressed("trigger")



func _handle_level_ended(delta: float) -> void:
	#teleport_player(brief_pos)
	#level_timer += delta
	#if level_timer > 20.0:
		#exit_to_main_menu()
	if level_timer > 60.0 or _both_triggers_pressed():
		exit_to_main_menu()

func _handle_level_failed(delta: float) -> void:
	level_timer += delta
	obj_elapsed_time += delta
	_on_obj_update_status(obj_elapsed_time)
	if current_objective in completed_objectives:
		log_results()
		hud_manager.end_level_prompt(false, score, "")
		await get_tree().create_timer(5.0).timeout
		teleport_player(brief_pos)

func _check_player_seen(check_node: Node3D) -> bool:
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var xr_camera: XRCamera3D = xr_origin_3d.get_child(0)
	var camera_origin = xr_camera.global_position
	var camera_front = -xr_camera.global_basis.z.normalized()
	var query = PhysicsRayQueryParameters3D.create(camera_origin, check_node.global_position)
	query.collide_with_areas = true
	query.collision_mask = query.collision_mask | (1<<30)
	var result = space_state.intersect_ray(query)
	#print(result)
	#print()
	var theta = rad_to_deg(acos(camera_front.dot((check_node.global_position-camera_origin).normalized())))
	#print(str(theta) + " " + str(xr_camera.global_position))
	if result and theta <= 45:
		var object: Node3D = result["collider"]
		return object == check_node
	return false
	

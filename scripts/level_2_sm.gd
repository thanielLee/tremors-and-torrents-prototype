extends XRToolsSceneBase
class_name Level2SM

## Level 2 Script
##
## This script extends XRToolsSceneBase and deals with the game elements
## specifically for Level 2
##
## This could serve as a guide/reference for future level creation  
##
## Handles initialization, hazards, objectives, and level flow.

@export var level_time_limit: float = 120.0
@export var briefing_time_limit: float = 5.0

@onready var xr_origin_3d = $XROrigin3D
@onready var start_pos: Vector3 = $StartPos.position
var brief_pos: Vector3

# State Machine Variables
enum State {BRIEFING, LEVEL_LOADING, ACTIVE_NO_OBJECTIVE, INVISIBLE_OBJECTIVE, ACTIVE_SEEN_OBJECTIVE, LEVEL_FAIL, OBJECTIVE_ACTIVE, ACTIVE_OBJECTIVE_DONE, LEVEL_FAIL_TIME_FAILED, LEVEL_COMPLETE, LEVEL_ENDED}

var current_state: State
var prev_state: State
var completed_briefing: bool = false
var started_loading: bool = false
var completed_loading: bool = false
var player_started: bool = false
var seen_objectives: Array = []
var required_objectives: Array = []
var prev_completed_objectives: int = 0
var failure_message: String = ""


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
@onready var check_position_1: MeshInstance3D = $CheckPosition1
@onready var check_position_2: MeshInstance3D = $CheckPosition2
@onready var check_position_3: MeshInstance3D = $CheckPosition3
@onready var raycast_check: Node3D = $RayCheck
@onready var hit_position: MeshInstance3D = $HitPosition1
func _ready():
	# save brief player
	brief_pos = xr_origin_3d.position
	hazards = get_node("Hazards")
	objectives = get_node("Objectives")
	world_shaker = get_node("WorldShaker")
	
	current_state = State.BRIEFING
	prev_state = State.BRIEFING

	#enable_hazards()
	#setup_objectives()



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
	log_results()
	hud_manager.end_level_prompt(true, score, "")
	hud_manager.hide_timer()

func fail_level(message: String):
	level_ended = true
	disable_hazards()

	if current_objective and obj_active:
		disable_other_objectives(current_objective)
		level_failed_obj_active = true		
		
		hud_manager.end_level_prompt(false, score, message)
		hud_manager.show_prompt("Finish current active objective to end level!", 3.0)
	else:
		disable_objectives()
		log_results()
		hud_manager.hide_timer()
		hud_manager.end_level_prompt(false, score, message)
		
		await get_tree().create_timer(5.0).timeout
		teleport_player(brief_pos)

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
		#if obj.has_signal("stretcher_dropped"):
			#var obj_logic = obj.get_node("ObjectiveStretcher") as ObjectiveBase
			#obj_logic.objective_started.connect(_on_objective_started.bind(obj_logic))
			#obj_logic.objective_completed.connect(_on_objective_completed.bind(obj_logic))
			#obj_logic.objective_failed.connect(_on_objective_failed.bind(obj_logic))
		
		if obj.is_required:
			required_objectives.append(obj)

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
	if obj is StretcherObjective:
		var cur_obj: StretcherObjective = obj as StretcherObjective
		if !cur_obj.can_be_enabled:
			return
	current_objective = obj
	hud_manager.on_obj_started(obj)
	
	obj_active = true
	obj_elapsed_time = 0
	if !obj.is_invisible:
		current_state = State.OBJECTIVE_ACTIVE
	else:
		current_state = State.INVISIBLE_OBJECTIVE
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
			#hud_manager.on_qte_completed()
			hud_manager.show_prompt(obj.completed_message, 3.0)
			hud_manager.on_obj_completed(obj)
		else: # for objectives
			var message = "Objective: %s completed! +%d" % [obj.objective_name, obj.completed_points]
			#hud_manager.show_prompt(message, 3.0)
			hud_manager.show_prompt(obj.completed_message, 3.0)
			hud_manager.on_obj_completed(obj)
		
		hud_manager.update_score(score)
		
		enable_objectives()
		#check_level_end()

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
		current_state = State.LEVEL_FAIL
		failure_message = obj.fail_message
		#fail_level("Required objective failed")
	
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
	_get_next_state(delta)
	hud_manager.show_prompt("CURRENT STATE: " + str(State.find_key(current_state)), delta)
	#print(str(injured.injured_seen) + " " + str(victim.victim_seen))
	
	#if level_ended and not level_failed_obj_active:
		#_handle_level_ended(delta)
	#elif level_failed_obj_active:
		#_handle_level_failed(delta)
	#elif level_active:
		#_handle_level_active(delta)
	#else:
		#_handle_level_briefing(delta)
	
	camera_forward = $XROrigin3D/XRCamera3D.global_transform.basis.z * -1
	
func _get_next_state(delta: float):
	if current_state != prev_state:
		print("CURRENT STATE: " + str(State.find_key(current_state)))
		print("REQUIRED OBJECTIVES: " + str(len(required_objectives)))
		prev_state = current_state
	match current_state:
		State.BRIEFING:
			_handle_level_briefing(delta)
			if completed_briefing:
				current_state = State.LEVEL_LOADING
		State.LEVEL_LOADING:
			if not started_loading:
				teleport_player(start_pos)
				enable_hazards()
				setup_objectives()
				hud_manager.reset_timer()
				started_loading = true
				completed_loading = true
			elif completed_loading:
				current_state = State.ACTIVE_NO_OBJECTIVE
		State.ACTIVE_NO_OBJECTIVE:
			_update_timer(delta)
			var objective_seen = _update_seen_objectives()
			if not player_started:
				player_started = true
				enable_objectives()
			if time_elapsed > level_time_limit or len(triggered_hazards) >= 3:
				current_state = State.LEVEL_FAIL
			
			if objective_seen:
				current_state = State.ACTIVE_SEEN_OBJECTIVE
		State.INVISIBLE_OBJECTIVE:
			_update_timer(delta)
			var objective_seen = _update_seen_objectives()
			
			if prev_completed_objectives != len(completed_objectives):
				prev_completed_objectives = len(completed_objectives)
				
				if len(seen_objectives) > 0:
					current_state = State.ACTIVE_SEEN_OBJECTIVE
				else:
					current_state = State.ACTIVE_NO_OBJECTIVE
				
				if time_elapsed >= level_time_limit:
					current_state = State.LEVEL_FAIL_TIME_FAILED
				
				
		State.ACTIVE_SEEN_OBJECTIVE:
			_update_timer(delta)
			var objective_seen = _update_seen_objectives()
			
			if len(triggered_hazards) >= 3:
				current_state = State.LEVEL_FAIL
			
		State.OBJECTIVE_ACTIVE:
			_update_timer(delta)
			var objective_seen = _update_seen_objectives()
			
			if time_elapsed >= level_time_limit:
				current_state = State.LEVEL_FAIL_TIME_FAILED
			
			if prev_completed_objectives != len(completed_objectives):
				prev_completed_objectives = len(completed_objectives)
				current_state = State.ACTIVE_OBJECTIVE_DONE
				
		State.ACTIVE_OBJECTIVE_DONE:
			var state_changed = false
			for objective in required_objectives:
				if objective in seen_objectives and !objective.completed:
					current_state = State.ACTIVE_SEEN_OBJECTIVE
					state_changed = true
			
			if !state_changed:
				current_state = State.LEVEL_COMPLETE
		State.LEVEL_FAIL:
			if time_elapsed >= level_time_limit:
				fail_level("You took too long!")
			elif len(triggered_hazards) >= 3:
				fail_level("Triggered too many hazards!")
			else:
				fail_level(failure_message)
			_reset_level_state()
			current_state = State.LEVEL_ENDED
		State.LEVEL_FAIL_TIME_FAILED:
			fail_level("You took too long!")
			_reset_level_state()
			current_state = State.LEVEL_ENDED
		State.LEVEL_COMPLETE:
			complete_level()
			_reset_level_state()
			current_state = State.LEVEL_ENDED
		State.LEVEL_ENDED:
			_update_timer(delta)
			if level_timer > 20.0:
				exit_to_main_menu()

func _update_seen_objectives():
	var return_val = false
	for child in objectives.get_children():
		if child in seen_objectives:
			continue
		if child is AnimatableBody3D:
			continue
		if child.is_invisible:
			continue
		if !child.is_required:
			continue
		var did_see = _check_player_seen(child)
		print("DID SEE " + str(child.name) + ": " + str(did_see))
		if did_see:
			seen_objectives.push_back(child)
			return_val = true
	
	return return_val
	
		

#func _physics_process(delta: float) -> void:
	
	#for child in objectives.get_children():
		#if child in seen_objectives:
			#continue
		#if _check_player_seen(child):
			#seen_objectives.push_back(child)
		
	#seen_injured = seen_injured or _check_player_seen($Objectives/Injured/VisibleArea)
	#seen_victim = seen_victim or _check_player_seen($Objectives/VictimRescue)
	
	#print("Seen Injured: " + str(seen_injured) + " Seen Victim: " + str(seen_victim))
	
func _update_timer(delta: float) -> void:
	level_timer += delta

func _handle_level_active(delta: float) -> void:
	level_timer += delta
	
	if obj_active:
		obj_elapsed_time += delta
		_on_obj_update_status(obj_elapsed_time)

	if level_timer >= level_time_limit:
		fail_level("Time limit exceeded")


func _handle_level_briefing(delta: float):
	_update_timer(delta)
	if level_timer > briefing_time_limit:
		#start_level()
		completed_briefing = true


func _handle_level_ended(delta: float):
	level_timer += delta
	if level_timer > 20.0:
		exit_to_main_menu()

func _handle_level_failed(delta: float):
	level_timer += delta
	obj_elapsed_time += delta
	_on_obj_update_status(obj_elapsed_time)
	if current_objective in completed_objectives:
		log_results()
		hud_manager.end_level_prompt(false, score, "")
		await get_tree().create_timer(5.0).timeout
		teleport_player(brief_pos)

func _check_player_seen(check_node: Node3D):
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var xr_camera: XRCamera3D = xr_origin_3d.get_child(0)
	var camera_origin = xr_camera.global_position
	var camera_front = -xr_camera.global_basis.z.normalized()
	var query = PhysicsRayQueryParameters3D.create(camera_origin, check_node.global_position)
	query.collide_with_areas = true
	query.collision_mask = (1<<29)
	check_position_1.global_position = camera_origin
	
	var result = space_state.intersect_ray(query)
	if result:
		var ray_position = result["position"]
		if check_node == injured:
			check_position_2.global_position = check_node.global_position
			raycast_check.global_position = (camera_origin+ray_position)/2
			raycast_check.look_at(ray_position, Vector3.UP)
			var raycast_mesh: MeshInstance3D = raycast_check.get_child(0)
			raycast_mesh.mesh.height = (check_node.global_position-camera_origin).length()
			hit_position.global_position = ray_position
		elif check_node == victim:
			check_position_3.global_position = check_node.global_position
	#print(result)
	#print()
	var theta = rad_to_deg(acos(camera_front.dot((check_node.global_position-camera_origin).normalized())))
	#print(str(theta) + " " + str(xr_camera.global_position))
	if result and theta <= 45:
		var object: Node3D = result["collider"]
		return check_node.is_ancestor_of(object)
	return false
	

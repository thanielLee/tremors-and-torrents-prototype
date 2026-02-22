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
@onready var dialogue_manager: DialogueManager = $DialogueManager
@onready var world_shaker: Node3D = $Environment/WorldShaker
@onready var earthquake_player: AudioStreamPlayer = $GlobalAudioManager/EarthquakePlayer


var current_objective: ObjectiveBase = null
var obj_elapsed_time: float = 0.0
var obj_active: bool = false

func _ready() -> void:
	setup_objectives()
	
	hud_manager.hide_timer()
	
	_start_briefing()

func _process(delta: float) -> void:
	if obj_active:
		obj_elapsed_time += delta
		_on_obj_update_status(obj_elapsed_time)

func _start_briefing():
	dialogue_manager.start_dialogue("SandboxGuide", "sandbox_welcome", "Guide")

func setup_objectives():
	if not objectives:
		return

	for obj in objectives.get_children():
		if obj.has_signal("objective_completed"):
			obj.objective_completed.connect(_on_objective_completed.bind(obj))
			print("connected objective_completed for %s" % obj.name)
		if obj.has_signal("objective_failed"):
			obj.objective_failed.connect(_on_objective_failed.bind(obj))
			print("connected objective_failed for %s" % obj.name)
		if obj.has_signal("objective_reset"):
			obj.objective_reset.connect(_on_objective_reset.bind(obj))
			print("connected objective_reset for %s" % obj.name)
		if obj.has_signal("objective_started"):
			obj.objective_started.connect(_on_objective_started.bind(obj))
			print("connected objective_started for %s" % obj.name)
		#if obj.has_signal("time"):
			#obj.time.connect(_on_obj_update_status)
		#if obj.has_signal("qte_started"):
			#obj.qte_started.connect(_on_qte_started.bind(obj))
			#print("connected qte_started for %s" % obj.name)
		if obj.has_signal("pose"):
			obj.pose.connect(_on_qte_update_status)
			print("connected pose for %s" % obj.name)
		#if obj.has_signal("shake_world"):
			#obj.shake_world.connect(do_earthquake)
		if obj.get_node("ObjectiveLogic"):
			var obj_logic = obj.get_node("ObjectiveLogic") as ObjectiveBase
			obj_logic.objective_started.connect(_on_objective_started.bind(obj_logic))
			obj_logic.objective_completed.connect(_on_objective_completed.bind(obj_logic))
			obj_logic.objective_failed.connect(_on_objective_failed.bind(obj_logic))
			obj_logic.objective_reset.connect(_on_objective_reset.bind(obj_logic))
			print("connected " + obj.name)

func _on_objective_started(obj: ObjectiveBase):
	#print("started: " + obj.objective_name)
	current_objective = obj
	hud_manager.reset_timer()
	hud_manager.show_timer()
	hud_manager.on_obj_started(obj)
	
	obj_active = true
	obj_elapsed_time = 0
	# disable other objectives right now
	#disable_other_objectives(obj)

func _on_obj_update_status(time: float):
	hud_manager.update_obj_status_label(time)


func _on_objective_completed(obj: ObjectiveBase):
	#if obj not in completed_objectives:
		#completed_objectives.append(obj)
		#completed_obj_times.append(obj_elapsed_time)
	obj_active = false
	
	#score += obj.completed_points
	
	var message = "Objective: %s completed! +%d" % [obj.objective_name, obj.completed_points]
	hud_manager.show_prompt(message, 3.0)
	hud_manager.on_obj_completed(obj)
	
	#hud_manager.update_score(score)
	#
	#enable_objectives()
	#check_level_end()

func _on_objective_failed(obj: ObjectiveBase):
	obj_active = false
	var message = "Objective: %s failed! %d" % [obj.name, obj.failed_points]
	hud_manager.show_prompt(message, 3.0)
	hud_manager.on_obj_failed(obj)

func _on_objective_reset(obj: ObjectiveBase):
	obj_active = false
	hud_manager.hide_timer()
	# Reset the objective state
	if current_objective == obj:
		current_objective = null
	obj_elapsed_time = 0.0

func _on_qte_update_status(status: bool):
	hud_manager.qte_update_status(status)


# helper functions
func do_earthquake(duration):
	#print(earthquake_rumble.stream.get_length() - duration)
	earthquake_player.play(earthquake_player.stream.get_length() - duration - 4.5)
	
	#earthquake_triggered = true # for e.quake on time
	world_shaker.shake_world(duration)

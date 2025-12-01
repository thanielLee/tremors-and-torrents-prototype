extends QuickTimeEvent

@export var head_threshold_y := 1.2
@export var hand_distance_threshold := 1.0
@export var hold_duration := 5.0

@onready var xr_origin = get_parent().get_parent().get_node("XROrigin3D")
@onready var camera = xr_origin.get_node("XRCamera3D")
@onready var left_hand = xr_origin.get_node("LeftHand")
@onready var right_hand = xr_origin.get_node("RightHand")

var hold_timer: float = 0.0
var is_holding_pose := false

signal shake_world

func _ready():
	super._ready()
	set_process(false)

func start_qte():
	super.start_objective()
	set_process(true)
	emit_signal("shake_world", duration)
	print("started DUCKCOVERHOLD")

func _process(delta):
	if not active or not enabled:
		return
	
	var head_y = camera.global_position.y
	#var hand_distance = left_hand.global_position.distance_to(right_hand.global_position)
	var left_hand_distance = camera.global_position.distance_to(left_hand.global_position)
	var right_hand_distance = camera.global_position.distance_to(right_hand.global_position)
	
	var is_ducked = head_y < head_threshold_y
	var is_holding = (left_hand_distance < hand_distance_threshold) and (right_hand_distance < hand_distance_threshold)
	
	#print("head_y: ", head_y)
	#print("left_hand_distance: ", left_hand_distance)
	#print("right_hand_distance: ", right_hand_distance)
	#print("is_ducked: ", is_ducked)
	#print("is_holding: ", is_holding)
	#print("hand_distance_threshold: ", hand_distance_threshold)
	
	if is_ducked and is_holding:
		#print("is_holding_pose: ", is_holding_pose)
		if not is_holding_pose:
			is_holding_pose = true
			print("Holding posture detected")
		add_progress(delta / hold_duration)
	else:
		if is_holding_pose:
			is_holding_pose = false
			print("Lost holding posture")
		#reset_progress()
		add_progress(-delta * 0.5 / hold_duration) # optional gradual decay
	
	super._process(delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if enabled and not active:
		start_objective()

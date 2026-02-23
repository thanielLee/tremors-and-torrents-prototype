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

signal shake_world(float)
signal pose(bool)

func _ready():
	super._ready()
	set_process(false)

func start_qte():
	if one_shot and done > 0:
		return
	super.start_objective()
	set_process(true)
	emit_signal("shake_world", duration)

func _process(delta):
	if not active or not enabled:
		return
	
	var head_y = camera.global_position.y
	var left_hand_distance = camera.global_position.distance_to(left_hand.global_position)
	var right_hand_distance = camera.global_position.distance_to(right_hand.global_position)
	
	var is_ducked = head_y < head_threshold_y
	var is_holding = (left_hand_distance < hand_distance_threshold) and (right_hand_distance < hand_distance_threshold)
	
	if is_ducked and is_holding:
		if not is_holding_pose:
			is_holding_pose = true
			pose.emit(true)
		add_progress(delta / hold_duration)
	else:
		if is_holding_pose:
			is_holding_pose = false
			pose.emit(false)
		add_progress(-delta * 0.5 / hold_duration) # optional gradual decay
	
	super._process(delta)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if enabled and not active:
		start_qte()
